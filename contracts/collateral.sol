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

    uint256 public upp;        //允许抵押物产生的稳定币总量上限(upper)
    uint256 public low;        //允许抵押物产生的稳定币总量下限(lower)
    uint256 public ove;        //最小抵押率(overflow)
    uint256 public gth;        //利率增长量(growth)
    uint256 public seg;        //单次清算数量(segmentation).
    uint256 public fin;        //清算罚金(fine)
    ifeeder public fer;        //喂价器

    /** 清算拍卖 */

    ifixedseller public ser; 

    /** 债务管理 */

    idebtor public dor;      //债务管理器

    /** 合约运行状态 */

    bool public wel;          //合约是否禁止数据流动

    /** 事件通知 */

    event Feed(uint256 val, uint256 exr);
    event Notfeed(address who);
    event Mint(address indexed who, uint256 amount);
    event Burn(address indexed who, uint256 amount);
    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    /** 初始化 */

    constructor(address d) public {
        dor = idebtor(d);
        wel = true;
        lrt = now;
        rat = PRE;
    }

    /** 治理 */

    function setlow(uint256 v) public auth {
        low = v;
    }
    function setupp(uint256 v) public auth {
        upp = v;
    }
    function setove(uint256 v) public auth {
        ove = v;
    }
    function setgth(uint256 v) public auth {
        gth = v;
    }
    function setseg(uint256 v) public auth {
        seg = v;
    }
    function setfin(uint256 v) public auth {
        fin = v;
    }

    function setfer(address v) public auth {
        fer = ifeeder(v);
    }
    function setser(address v) public auth {
        ser = ifixedseller(v);
    }

    /** 系统运行开关 */

    function stop() public auth {
        wel = false;
    }

    function start() public auth {
        wel = true;
    }

    /** 喂价 */

    function feed() public {
        uint256 val = fer.get();
        //抵押物价格(val): 1 USD
        //最小抵押率(ove): 150%
        //兑换比(exr): val/ove = 1/1.5, 表示1.5个抵押物才兑换1个Dai, 或者说1个抵押物大约能兑换 0.6666666666666666... 个 Dai
        //乘以PRE(10 ** 18)是防止0.6666...被抹成0
        exr = (val * PRE * PRE9) / ove;  //[10^27]
        emit Feed(val, exr);
    }

    /** 抵押/赎回 */
    
    //赎回(稳定币=>抵押物)
