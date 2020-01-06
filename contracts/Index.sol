//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 用户账户记录

pragma solidity >= 0.5.0;

import "./Authority.sol";

contract Index is Authority {
    mapping (uint256 => address) public accounts;
    mapping (address => uint256) public indexs;

    uint256 public index = 1;

    function inc(address who) public auth returns(uint256) {
        if(indexs[who] == 0) {
            accounts[index] = who;
            indexs[who] = index;
            ++index;
        }
        return indexs[who];
    }
}
