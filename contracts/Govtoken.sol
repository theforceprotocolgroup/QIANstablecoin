//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Governance Token encapsulation
//原力协议稳定币系统 - 治理代币封装

pragma solidity >= 0.5.0;

import "./Authority.sol";

contract Fortoken {
    function transfer(address to, uint amount) public;       //FOR不是标准的ERC20 Token.
    function transferFrom(address from, address to, uint amount) public returns (bool);
    function balanceOf(address owner) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
}

//FOR government implementation
//为了视债务拍卖合约具有更泛化的实现, 这个合约将其作为一个 Asset 加入到 Wallet 中(但是仅支持move方法),
//当拍卖结束后需要解锁FOR来支付拍卖品, 调用合约的 move 方法. 
//(需要先对调用方进行额度授权: address(this).approvemint(@Debtauction, uint256(-1))).

contract Govtoken is Authority {
    mapping(address => uint) public donors; //单人累计捐赠总量, 只增不减;
    uint256                  public tot;    //全部累计捐赠总量, 只增不减;
    Fortoken                 public tok;    //治理代币 FOR
    bool                     public hea;    //系统状态标记(healthy), false 表示系统已经停止运行, 并允许捐助者按比例取回
    uint256                  public left;   //系统结束时剩余的代币总量.

    mapping(address=>uint256) public mintance;

    event Contribute(address indexed who, uint256 amount, uint256 tot);
    event Back(address indexed who, uint256 amount);
    event End(address indexed who, uint256 left);
    event Mint(address indexed sender, address who, uint256 amount);
    event Burn(address indexed sender, address who, uint256 amount);
    event Approvalmint(address indexed sender, address spender, uint256 amount);
    event Move(address indexed from, address to, uint256 amount);

    constructor(address t) public {
        tok = Fortoken(t);
        hea = true;
    }

    function settok(address v) public auth {
        tok = Fortoken(v);
    }

    //当系统停止后由owner调用, 设置 @hea = false, 将允许捐助者按捐助数量占总捐助数量的比例取回相应的代币.
    function end() public auth {
        hea = false;
        left = tok.balanceOf(address(this));
        emit End(msg.sender, left);
    }

    //捐助 @amount 数量的代币, 需要tok.approve(msg.sender)授权.
    function contribute(uint256 amount) public {
        require(hea);
        donors[msg.sender] = uadd(donors[msg.sender], amount);
        tot = uadd(tot, amount);
        tok.transferFrom(msg.sender, address(this), amount);
        emit Contribute(msg.sender, amount, donors[msg.sender]);
    }

    //按捐助数量占总捐助数量的比例取回, 仅当 @hea = false 时才允许调用.
    function back() public {
        require(!hea);
        require(donors[msg.sender] > 0);
        uint256 amount = udiv(umul(left, donors[msg.sender]), tot);
        require(amount > 0);
        tok.transfer(msg.sender, amount);
        emit Back(msg.sender, amount);
    }

    //给 @user 解锁 @amount 数量的代币. 仅允许核心合约调用.
    function mint(address who, uint256 amount) public auth {
        require(hea);
        tok.transfer(who, amount);
        emit Mint(msg.sender, who, amount);
    }

    //为 @user 锁定 @amount 数量的代币.
    //需要who => tok.approve(address(this), amount)授权.
    function burn(address who, uint256 amount) public auth {
        require(hea);
        tok.transferFrom(who, address(this), amount);
        emit Burn(msg.sender, who, amount);
    }

    //从 @src 转账 @amount 到 @dst, 仅允许核心合约调用.
    function move(address from, address to, uint256 amount) public {
        require(hea);
        require(from != to, "require: from != to");

        if(to == address(this)) {
            //需要 tok.approve(address(this), amount)
            tok.transferFrom(from, address(this), amount);
        } else {
            //这里本质上是在从 address(this) 向 to 账户转账, 所以首先检查当前合约余额.
            require(balance() >= amount, "insufficient balance");
            //被检查的授权方 @form 必须和调用方 @msg.sender 是同一个账户, 防止恶意调用方使用一个已授权的账户来调用本方法.
            require(from == msg.sender, "require: from == msg.sender");
            //当调用方不是当前合约时, 检查授权额度.
            if(from != address(this)) {
                require(mintance[from] >= amount, "insufficient mintance to move");
                mintance[from] = usub(mintance[from], amount);
            }
            tok.transfer(to, amount);
        }

        emit Move(from, to, amount);
    }

    function approvemint(address spender, uint256 amount) public auth {
        mintance[spender] = uadd(mintance[spender], amount);
        emit Approvalmint(msg.sender, spender, amount);
    }

    //获取 @address(this) 当前的剩余资产数量.
    function balance() public view returns (uint256) {
       return tok.balanceOf(address(this));
    }

    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }
    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }

    function umul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / PRE;
    }

    function udiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * PRE;
        require(x == 0 || z / x == PRE);
        z = z / y;
    }

    uint256 constant public PRE = 10 ** 18;
}