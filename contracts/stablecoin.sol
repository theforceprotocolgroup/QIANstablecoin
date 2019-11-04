//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Stablecoin management
//原力协议稳定币系统 - 稳定币管理

pragma solidity >= 0.5.0;

import "./authority.sol";
import "./stderc20.sol";


contract Stablecoin is stderc20, authority {

    //@n name, @s symbol, @d decimals
    constructor(string memory n, string memory s, uint8 d) 
        stderc20 (n, s, d, 0) public {
    }

    //给 @who 增发 @amount 数量的稳定币, 仅允许被debtor合约(和owner)调用;
    function mint(address who, uint256 amount) public auth {
        balanceOf[who] = uadd(balanceOf[who], amount);
        totalSupply = uadd(totalSupply, amount);
        emit Transfer(address(0), who, amount);
    }
    
    //给 @who 销毁 @amount 数量的稳定币, 仅允许被debtor合约(和owner)调用
    function burn(address who, uint256 amount) public auth {
        require(balanceOf[who] >= amount);
        require(allowance[who][msg.sender] >= amount);
        allowance[who][msg.sender] = usub(allowance[who][msg.sender], amount);
        balanceOf[who] = usub(balanceOf[who], amount);
        totalSupply = usub(totalSupply, amount);
        emit Transfer(who, address(0), amount);
    }
}
