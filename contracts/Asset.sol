//COPYRIGHT  THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol stablecoin system - Cryptoasset manager, also wallet for single asset.
//原力协议稳定币系统 - 数字资产管理合约, 可以视为单一资产的钱包.

pragma solidity >= 0.5.0;


contract Transferable {
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
}


contract Asset {
    event Approval(address who, address spender, uint256 amount);
    event Move(address who, address from, address to, uint256 amount);
    event Withdraw(address sender, address who, uint256 amount);
    event Deposit(address sender, address who, uint256 amount);
    event Lock(address who, address payer, uint256 amount);
    event Unlock(address who, address payer, uint256 amount);
    event Movel(address who, address from, address to, uint256 amount);

    address public token;

    mapping(address => uint256) public balance;
    uint256 public tot;

    mapping(address=>mapping(address=>uint256)) public allowance;
    mapping(address=>mapping(address=>uint256)) public locked;

    constructor(address t) public {
        token = t;
    }
    
    function deposit(address who, uint256 amount) public payable {
        balance[who] = uadd(balance[who], amount);
        tot = uadd(tot, amount);
        if(token == address(0)) {
            require(amount == msg.value, "amount mismatch with msg.value");
            return;
        }
        require(transferable(token).transferFrom(who, address(this), amount));
        emit Deposit(msg.sender, who, amount);
    }

    function withdraw(address payable who, uint256 amount) public {
        balance[who] = usub(balance[who], amount);
        tot = usub(tot, amount);
        if(token == address(0)) {
            who.transfer(amount);
            return;
        }
        require(transferable(token).transfer(who, amount));
        emit Withdraw(msg.sender, who, amount);
    }

    function lock(address who, uint256 amount) public {
        require(balance[msg.sender] >= amount, "insufficient balance");
        balance[msg.sender] = usub(balance[msg.sender], amount);
        locked[msg.sender][who] = uadd(locked[msg.sender][who], amount);
        emit Lock(msg.sender, who, amount);
    }

    function unlock(address who, uint256 amount) public {
        require(locked[msg.sender][who] >= amount, "insufficient locked balance");
        locked[msg.sender][who] = usub(locked[msg.sender][who], amount);
        balance[msg.sender] = uadd(balance[msg.sender], amount);
        emit Unlock(msg.sender, who, amount);
    }

    function movel(address to, address who, uint256 amount) public {
        require(locked[msg.sender][who] >= amount, "insufficient locked balance");
        locked[msg.sender][who]= usub(locked[msg.sender][who], amount);
        locked[to][who] = uadd(locked[to][who], amount);
        emit Movel(msg.sender, to, who, amount);
    }

    function approve(address spender, uint256 amount) public returns(bool) {
        allowance[msg.sender][spender]
            = uadd(allowance[msg.sender][spender], amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function move(address from, address to, uint256 amount) public {
        require(balance[from] >= amount, "insufficient balance");
        if(from != msg.sender) {
            require(allowance[from][msg.sender] >= amount, "unapproved to move");
            allowance[from][msg.sender] 
                = usub(allowance[from][msg.sender], amount);
        }
        balance[from] = usub(balance[from], amount);
        balance[to] = uadd(balance[to], amount);
        emit Move(msg.sender, from, to, amount);
    }

    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }

    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }
}
