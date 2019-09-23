/*
COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
原力协议稳定币系统 - 权限管理
The Force Protocol stablecoin system - authority administration
*/

pragma solidity >= 0.5.0;

contract duckauthority {
    function accessible(address who, address code, bytes4 sig) public view returns (bool);
}

contract authority
{
    duckauthority public next;          //指向其他任何 @duckauthority, 只要实现了 @accessible 方法, 构成权限检查链.
    mapping(address => bool) owners;    //管理员权限
    mapping(address => mapping(address => mapping(bytes4 => bool))) acl;    //访问控制列表

    constructor() public {
        owners[msg.sender] = true;
    }

    //重新设置 @other 作为下一个权限管理器.
    function relink(address other) public auth {
        next = duckauthority(other);
    }

    //添加 @who 具有owner权限.
    function setowner(address who) public auth {    //approve
        owners[who] = true;
    }
    //取消 @who 的owner权限.
    function unsetowner(address who) public auth {
        owners[who] = false;
    }
    