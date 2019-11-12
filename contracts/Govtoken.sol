//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Governance Token encapsulation
//原力协议稳定币系统 - 治理代币封装

pragma solidity >= 0.5.0;

import "./Authority.sol";

contract Fortoken {
    function transfer(address to, uint amt) public;       //FOR不是标准的ERC20 Token.
    function transferFrom(address from, address to, uint amt) public returns (bool);
    function balanceOf(address owner) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
}

//FOR government implementation

contract Govtoken is Authority {
    mapping(address => uint) public donors; //单人累计捐赠总量, 只增不减;
    uint256                  public tot;    //全部累计捐赠总量, 只增不减;
    Fortoken                 public tok;    //治理代币 FOR
    bool                     public well;   //结束标记, 停止所有的代币流动, 并允许捐助者按比例取回
    uint256                  public left;   //系统结束时剩余的代币总量.

    event Transfer(address indexed from, address indexed to, uint256 amt);
    event Contribute(address indexed who, uint256 amt, uint256 tot);
    event Back(address indexed who, uint256 amt);
    event End(address indexed who, uint256 left);

    constructor(address t) public {
        tok = Fortoken(t);
        well = true;
    }

    //当系统停止后由owner调用, 设置 @well = false, 将允许捐助者按捐助数量占总捐助数量的比例取回相应的代币.
    function end() public auth {
        well = false;
        left = tok.balanceOf(address(this));

        emit End(msg.sender, left);
    }

    //捐助 @amt 数量的代币, 需要tok.approve(msg.sender)授权.
    function contribute(uint256 amt) public {
        require(amt > 0);
        require(well);
        donors[msg.sender] = uadd(donors[msg.sender], amt);
        tot = uadd(tot, amt);
        require(tok.allowance(msg.sender, address(this)) >= amt);
        tok.transferFrom(msg.sender, address(this), amt);

        emit Contribute(msg.sender, amt, donors[msg.sender]);
    }

    //按捐助数量占总捐助数量的比例取回, 仅当 @well = false 时才允许调用.
    function back() public {
        require(!well);
        require(donors[msg.sender] > 0);
        uint256 amt = (left * donors[msg.sender]) / tot;
        require(amt > 0);
        tok.transfer(msg.sender, amt);

        emit Back(msg.sender, amt);
    }

    //给 @user 解锁 @amt 数量的代币. 仅允许核心合约调用.
    function mint(address user, uint256 amt) public auth {
        require(well);
        tok.transfer(user, amt);
        emit Transfer(address(this), user, amt);
    }

    //为 @user 锁定 @amt 数量的代币
    function burn(address who, uint256 amt) public auth {
        require(well);
        tok.transferFrom(who, address(this), amt);
        emit Transfer(who, address(this), amt);
    }

    //从 @src 转账 @amt 到 @dst, 仅允许核心合约调用.
    //需要tok.approve(src)授权.
    function move(address src, address dst, uint256 amt) public auth {
        require(well);
        if(src == address(this)) {
            tok.transfer(dst, amt);
        } else {
            tok.transferFrom(src, dst, amt);
        }
        emit Transfer(src, dst, amt);
    }

    //获取 @address(this) 当前的剩余资产数量.
    function balance() public view returns (uint256) {
       return tok.balanceOf(address(this));
    }

    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }
}