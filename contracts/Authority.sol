//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol stablecoin system - authority administration
//原力协议稳定币系统 - 权限管理

pragma solidity >= 0.5.0;

contract IAuthority {
    function accessible(address who, address code, bytes4 sig) public view returns (bool);
}

contract Authority
{
    IAuthority public next;          //指向其他任何 @IAuthority, 只要实现了 @accessible 方法, 构成权限检查链.
    uint8 countofowners;
    mapping(address => bool) public owners;    //管理员权限
    address public pendingowner;       //
    mapping(address => mapping(address => mapping(bytes4 => bool))) acl;    //访问控制列表

    //验证合约的操作是否被授权.
    modifier auth {
        require(accessible(msg.sender, address(this), msg.sig), "access unauthorized");
        _;
    }

    function accessible(address who, address code, bytes4 sig) public view returns (bool) {
         return who == code
                || owners[who]
                || acl[who][code][sig]
                || (next == IAuthority(0)
                    ? false 
                    : next.accessible(who, code, sig));
    }

    constructor() public {
        owners[msg.sender] = true;
        countofowners = 1;
    }

    //重新设置 @other 作为下一个权限管理器.
    function relink(address other) public auth {
        next = IAuthority(other);
    }

    //添加 @who 具有owner权限.
    function setowner(address who) public auth {    //approve
        ++countofowners;
        require(countofowners < uint8(-1), "setowner: out of owners");
        pendingowner = who;
    }

    function confirmowner() public auth {
        require(msg.sender == pendingowner, "confirmowner: not pending owner");
        owners[msg.sender] = true;
        pendingowner = address(0);
    }
    
    //取消 @who 的owner权限.
    function unsetowner(address who) public auth {
        require((countofowners - 1) > 0, "unsetowner: at least one owner");
        --countofowners;
        owners[who] = false;
    }
    
    //添加访问控制: 允许 @who 访问 @code 的 @sig 方法
    function enable(address who, address code, bytes4 sig) public auth {  
        acl[who][code][sig] = true;
    }

    function enable(address who, bytes4 sig) public auth {
        this.enable(who, address(this), sig);
    }
    
    //取消访问控制: 禁止 @who 访问 @code 的 @sig 方法
    function disable(address who, address code, bytes4 sig) public auth {
        acl[who][code][sig] = false;
    }

    function disable(address who, bytes4 sig) public auth {
        this.disable(who, address(this), sig);
    }
}