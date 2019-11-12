//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Price Feeder
//原力协议稳定币系统 - 喂价器

pragma solidity >= 0.5.0;

import "./Authority.sol";

contract Feeder is Authority {

    uint256  public pce;
    uint256  public exp;

    function get() public view returns (uint256) {
        require(valid(), "price expired");
        return pce;
    }

    function valid() public view returns (bool) {
        return now < exp;
    }

    // 设置价格为 @p, 保持有效时间为 @e sec.
    function set(uint256 p, uint256 e) external auth {
        pce = p;
        exp = now + e;
    }
}
