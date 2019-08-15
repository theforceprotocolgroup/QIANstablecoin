pragma solidity >= 0.5.0;

contract DSAuthority {
    function canCall(address src, address dst, bytes4 sig) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract ERC20Like {
    function transfer(address to, uint value) public;
    function transferFrom(address from, address to, uint value) public returns (bool);
    function balanceOf(address owner) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
}

//Gov FOR wapper
contract Gfor is DSAuth {

    mapping(address => uint) public donors;     //单人累计捐赠总量, 只增不减;
    uint256 public totalcont;                   //全部累计捐赠总量, 只增不减;
    ERC20Like public basicToken;                //治理代币 FOR
    bool public live;                           //结束标记, 停止所有的代币流动, 并允许捐助者按比例取回
    uint256 public leftover;                    //系统结束时剩余的代币总量.

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Contribute(address indexed who, uint256 value, uint256 total);
    event Back(address indexed who, uint256 value);
    event End(address indexed who, uint256 leftover);

    modifier ownable {
        require(msg.sender == owner, "Ownable");
        _;
    }

    constructor(address token) public {
        basicToken = ERC20Like(token);
        live = true;
    }

    //当系统停止后由owner调用, 设置 @live = false, 将允许捐助者按捐助数量占总捐助数量的比例取回相应的代币.
    function end() public ownable {
        live = false;
        leftover = basicToken.balanceOf(address(this));

        emit End(msg.sender, leftover);
    }

    //捐助 @value 数量的代币.
    //前置条件: msg.sender = donor (捐赠者), FOR.approve(address(this), value);
    function contribute(uint256 value) public {
        require(value > 0, "Bad contribute value");
        require(live, "System ended");
        donors[msg.sender] += value;
        totalcont += value;
        require(basicToken.allowance(msg.sender, address(this)) >= value, "Bad allowance");
        basicToken.transferFrom(msg.sender, address(this), value);

        emit Contribute(msg.sender, value, donors[msg.sender]);
    }

    //按捐助数量占总捐助数量的比例取回, 仅当 @live = false 时才允许调用.
    function back() public {
        require(!live, "System live");
        require(donors[msg.sender] > 0, "Not donor");
        uint256 value = (leftover * donors[msg.sender]) / totalcont;
        require(value > 0, "Bad value");
        basicToken.transfer(msg.sender, value);

        emit Back(msg.sender, value);
    }

    //给 @user 增发/解锁 @value 数量的代币. 仅允许flop合约调用.
    function mint(address user, uint256 value) public auth {
        require(live, "System ended");
        basicToken.transfer(user, value);

        emit Transfer(address(this), user, value);
    }

    //为 @user 销毁/锁定 @value 数量的代币, 暂时未使用(不允许调用)
    function burn(address user, uint256 value) public auth {
        require(live, "System ended");
        //TODO: require allowance ?
        require(basicToken.allowance(user, address(this)) >= value, "Bad allowance");
        basicToken.transferFrom(user, address(this), value);

        emit Transfer(user, address(this), value);
    }

    //从 @src 转账 @value 到 @dst, 仅允许flap合约调用.
    //当 @src = bidder(竞拍者), @dst = address(this) 时, 同burn, 作为mint的反操作.
    //前置条件: msg.sender = bidder, FOR.approve(address(this), value);
    function move(address src, address dst, uint256 value) public auth {
        require(live, "System ended");
        require(basicToken.allowance(src, address(this)) >= value, "Bad allowance");
        basicToken.transferFrom(src, dst, value);

        emit Transfer(src, dst, value);
    }

    //获取 @address(this) 当前的剩余资产数量.
    function balanceOf() public view returns (uint256) {
       return basicToken.balanceOf(address(this));
    }
}
