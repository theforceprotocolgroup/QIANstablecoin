//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - ERC20 collateral management
//原力协议稳定币系统 - ERC20抵押物管理

pragma solidity >= 0.5.0;

import "./collateral.sol";


contract Transferable {
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
}


contract Ctoken is Collateral {
    transferable public tok;        //Collateral address（抵押物地址）

    //@t tok, @d dor
    constructor(address t, address d) collateral(d) public {
        tok = transferable(t);
    }
    
    //Deposit collateral amount of @msg.value, accumulate to @holdstate.c （存入 @msg.value 数量的抵押物, 累加到 @holdstate.c）
    function deposit(uint256 amount) public {
        hol[msg.sender].c = uadd(hol[msg.sender].c, amount);
        require(tok.transferFrom(msg.sender, address(this), amount));
        emit Deposit(msg.sender, amount);
    }

    //Withdraw collateral of @amount, @amount could only be limited within the range in record of @holdstate.c （取出 @amount 数量的抵押物, @amount 仅能从 @holdstate.c 记录的数量中转出.）
    function withdraw(uint256 amount) public {
        hol[msg.sender].c = usub(hol[msg.sender].c, amount);
        require(umul(hol[msg.sender].s, rat) <= (umul(hol[msg.sender].c, exr) / PRE9),
            "bad exchange ratio");
        require(tok.transfer(msg.sender, amount));
        emit Withdraw(msg.sender, amount);
    }
}
