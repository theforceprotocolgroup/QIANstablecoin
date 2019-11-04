//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - ETH collateral management
//原力协议稳定币系统 - ETH抵押物管理

pragma solidity >= 0.5.0;

import "./collateral.sol";

contract ceth is collateral {

    //@d dor
    constructor(address d) collateral(d) public {

    }

    //存入 @msg.value 数量的抵押物
    function deposit() public payable {
        hol[msg.sender].c = uadd(hol[msg.sender].c, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    //取出 @amount 数量的抵押物
    function withdraw(uint256 amount) public {
        hol[msg.sender].c = usub(hol[msg.sender].c, amount);
        require(umul(hol[msg.sender].s, rat) <= (umul(hol[msg.sender].c, exr) / PRE9), 
            "bad exchange ratio");
        msg.sender.transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
}
