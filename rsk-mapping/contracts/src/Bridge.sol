pragma solidity >=0.5.0;

contract ERC20Like {
    function transfer(address to, uint value) public returns (bool success);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
}

contract Bridge {
    address                             owner;
    mapping (address => address) public maps;
    address public                      manager;
    ERC20Like public                    token;

    modifier ownable() {
        require(msg.sender == owner, "require-owner");
        _;
    }

    modifier managerable() {
        require(msg.sender == manager, "require-manager");
        _;
    }

    constructor(address mgr, address tok) public {
        owner = msg.sender;
        manager = mgr;
        token = ERC20Like(tok);
    }
    
    function unlock(address receiver, uint256 amount) public managerable returns(bool) {
        return token.transfer(receiver, amount);
    }
    
    //设置目标链的映射地址
    //合成一个交易来做是为了防止在转账和设置映射地址两个交易之间被事件监听程序捕获到转账交易.
    function lock(address to, uint256 amount) public {
        require(token.allowance(msg.sender, address(this)) >= amount);
        token.transferFrom(msg.sender, address(this), amount);
        maps[msg.sender] = to;
    }
    
    function setManager(address who) public ownable {
        require(who != address(0), "bad-manager-address");

        if(manager != who) {
            manager = who;
        }
    }
}