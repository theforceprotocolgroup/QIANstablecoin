//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 抵押物管理

pragma solidity >= 0.5.0;

import "./authority.sol";
import "./arith.sol";

contract duckdebtor {
    function burn(address who, uint256 amount) public;
    function mint(address who, uint256 amount) public;
    function incinterest(uint256 amount) public;
    function decinterest(uint256 amount) public;
    function incbaddebt(uint256 amount) public;
}

contract ifixedseller {
    function auction(address cor, address dor, address per, address who, address rec, uint256 qua, uint256 amt, uint256 bid) public returns(uint256);
}

contract ifeeder {
    function get() public view returns (uint256);
    function valid() public view returns (bool);
}
