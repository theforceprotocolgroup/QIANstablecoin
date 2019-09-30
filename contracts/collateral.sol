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

contract collateral is authority, arith {
    /** 抵押物与稳定币持有状态 */

    struct hstate {
        uint256 c; //exchanged-collateral,   已兑换成稳定币的抵押物数量, 应该满足最小抵押率(ove)
        uint256 s; //exchanged-stablecoin,   已兑换的稳定币的数量.
    }

    mapping (address => hstate) public hol;    //以账户为单位记录持有状态(hold state)
    uint256 public tot;                        //抵押物产生的稳定币总量(total)
    uint256 public rat;                        //利率(rate)
    uint256 public lrt;                        //最后rise时间(last rise time), rise 计算一段时间内产生的利息并累计到债务管理器
    uint256 public exr;                        //兑换比率, 基于ove计算(exchange rate)

    /** 风险参数 */