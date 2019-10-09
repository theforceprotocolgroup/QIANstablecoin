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

    //调用赎回接口分两种情况:
    //1. 仅归还稳定币, 仅为用户减少 @snt 的稳定币持有数量(hol[u].s - @snt), 不减少抵押物的数量(@cnt为0, 即 hol[u].c 不变), 
    //  相当于提高了质押率, 但是那些没有稳定币对应的(超额抵押的)抵押物可以随时取出,
    //  如果稳定币的持有数量不足以归还系统债务, 则未还的债务必须存在相应数量的的抵押物.
    //2. 仅取走抵押物, 仅为用户减少 @cnt 的抵押物持有数量(hol[u].c - @cnt), 不减少稳定币的数量(@snt为0, 即 hol[u].s 不变).
    //  相当于降低了质押率, 但剩余的抵押物数量最少要满足未还债务的最小抵押率.
    //
    //后续需要区分 @hol[u].c 中有多少是属于稳定币对应的抵押物和多少没有稳定币对应的抵押物, 算法为:
    //计算稳定币对应的抵押物数量(amount): 
    //  hol[u].s * rat = amount * exr;
    //  amount = hol[u].s * rat / exr;
    //  amount = hol[u].s * rat / (price / ove)
    //  amount = hol[u].s * rat * ove / price;
    //计算没有稳定币对应的抵押物数量: 
    //  hol[u].c - amount;
    function exchangefrom(uint256 snt, uint256 cnt) public {
        address u = msg.sender;

        require(rat != 0, "bat @rat: rat == 0");
        require(wel, "system has been stopped");

        //减少抵押物持有记录
        hol[u].c = usub(hol[u].c, cnt);
        //减少相应的稳定币记录.
        hol[u].s = usub(hol[u].s, snt);
        //减少该类型抵押物对应的稳定币总量.
        tot = usub(tot, snt);
        //检查当前抵押物生成的稳定币总量下限.
        require(umul(hol[u].s, rat) >= low);
        //检查剩余的抵押物和稳定币之间的兑换比, 必须保持大于等于exr.
        require(umul(hol[u].s, rat) <= (umul(hol[u].c, exr) / PRE9));

        uint256 amount = umul(snt, rat);
        //给 @msg.sender 销毁 @snt * @rat 数量的稳定币.
        dor.burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    //抵押(抵押物=>稳定币), 使用 @cnt (collateralamount) 数量的抵押物来兑换 @snt (stablecoinamount) 数量的稳定币.
    //给定抵押物数量 @cnt, 最大的稳定币兑换数量为 @snt = @cnt * @exr / @rat 或者 @snt = (@cnt * @price) / (@rat * @ove)
    //其中@cnt * @exr 或者 (@cnt * @price) / @ove 是在不考虑利息的情况下可兑换的最大数量, 但是实际上的最大可兑换数量还要考虑利息, 所以 / @rat.
    //例如要兑换10个稳定币, 那 @snt 不是 10, 而是 10 / rat.

    function exchangeto(uint256 cnt, uint256 snt) public {
        address u = msg.sender;

        require(wel, "system has been stopped");
        require(rat != 0, "bat @rat: rat == 0");

        //增加抵押物持有记录
        hol[u].c = uadd(hol[u].c, cnt);
        //增加相应的稳定币记录
        hol[u].s = uadd(hol[u].s, snt);
        //增加该类型抵押物对应的稳定币总量
        tot = uadd(tot, snt);
        //检查当前生成的稳定币总量上限和下限
        require(umul(tot, rat) <= upp
            && umul(hol[u].s, rat) >= low, "out of exchange ceiling");
        //检查剩余的抵押物和稳定币之间的兑换比, 必须保持大于等于exr.
        require(umul(hol[u].s, rat) <= (umul(hol[u].c, exr) / PRE9), "bad exchange ratio");
        
        uint256 amount = umul(snt, rat);
        //给 @msg.sender 增发 @snt * @rat数量的稳定币(意味着从当前时刻开始计息)
        dor.mint(msg.sender, amount);
        emit Mint(msg.sender, amount);
    }

    /** 更新利率 */

    //累加一段时间内的利率

    //https://wiki.mbalib.com/wiki/%E5%90%8D%E4%B9%89%E5%88%A9%E7%8E%87
    //https://wiki.mbalib.com/wiki/%E6%9C%89%E6%95%88%E5%B9%B4%E5%88%A9%E7%8E%87
    //r0 = (1+(r/n))^n − 1, 有效年利率计算公式, r表示名义利率, n表示复利期数(年复利时n=1).

    //https://wiki.mbalib.com/wiki/%E6%9C%89%E6%95%88%E5%B9%B4%E5%88%A9%E7%8E%87
    //r0 = 2.5%, 设名义年利率为2.5%, 则 r0 表示按年计息的复利率(有效年利率).

    //https://wiki.mbalib.com/wiki/%E8%BF%9E%E7%BB%AD%E5%A4%8D%E5%88%A9%E6%94%B6%E7%9B%8A%E7%8E%87
    //r1 = ln(r0 + 1), r1 表示按年计息的连续复利收益率(对数收益率). 
    //r2 = r1 / (60 * 60 * 24 * 365), r2 表示按秒计息的连续复利收益率

    //https://wiki.mbalib.com/wiki/%E8%BF%9E%E7%BB%AD%E5%A4%8D%E5%88%A9
    //F = P * e ^ (r2 * t), 连续复利计算公式, 其中:
    //  P0 是初始值, 
    //  e 是自然对数,
    //  r2 是按秒计息的连续复利收益率,
    //  t 是计息周期(秒数),
    //  F 是终值. 
    
    //在计算利息时, P表示本金, F表示复利计息后的利息+本金, 但这里并不是用这个公式来直接计算利息, 
    //而是用来算利率的增长, 所以P表示该抵押物当前的利率, F表示以r2复合增长t秒后的新利率, 而实际的利息 = 利率 * 债务.
    //这个公式中F和t这两个值来自于系统运行时, 但是除此之外, e, r2 都是系统外部可知的, 所以 e^r2 将被作为外部可配置的参数部分(gth);
    //所以 F = P * e ^ (r2 * t) 
    //    F = P * (e^r2)^t
    //    F = P * gth ^ t

    //其中P表示当前利率(rat), F表示新利率(rat * gth ^ t), F - P 表示的是以r2复合增长t秒后的利率增长(可能是负值, 视配置而定), 
    //所以最新的利率为 rat += (F - P)

    function rise() public {
        require(wel);
        //@gth 是被扩大了 @PRE(10 ** 18) 的值, 如果直接计算 @gth ** (now - lrt) 结果会超级巨大.
        //但是如果先除以 @PRE(10 ** 18), 又可能会出现结果被抹成0的情况(0.XXXX...)
        //所以这里使用专用的 @pow 算法.
        uint256 crat = umul(rat, pow(gth, (now - lrt)));

        int256 b = diff(crat, rat);
        int256 c = int256(tot);
        int256 i = c * b;
        require(b == 0 || i / b == c);
        
        i < 0 ? dor.decinterest(uint256(i * -1) / PRE)
            : dor.incinterest(uint256(i) / PRE);

        rat = b < 0 ? usub(rat, uint256(b * -1)) 
            : uadd(rat, uint256(b));

        lrt = now;
    }

    /** 抵押物清算 */

    //对 @who 发起清算, 减少 @who 的债务同时并拍卖相应的抵押物.
    function liquidate(address who) public {
        require(wel);
        hstate memory h = hol[who];
        require((umul(h.c, exr) / PRE9) < umul(h.s, rat));
  