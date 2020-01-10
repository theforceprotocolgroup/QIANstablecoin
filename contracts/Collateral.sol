//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Collateral management
//原力协议稳定币系统 - 抵押物管理

pragma solidity >= 0.5.0;

import "./Authority.sol";

contract IToken {
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
    function approve(address who, uint amount) public returns (bool);
}

contract IFeeder {
    function get() public view returns (uint256);
    function valid() public view returns (bool);
}

contract IDebtor {
    function mint(address who, uint256 amount) public;
    function burn(address who, uint256 amount) public;
    function inci(uint256 amount) public;
    function deci(uint256 amount) public;
    function incb(uint256 amount) public;
    
    function tok() public view returns(address);
    function tot() public view returns(uint256);
}

contract IAsset {
    function deposit(address who, uint256 amount) public payable;
    function move(address from, address to, uint256 amount) public;
}

contract IWallet {
    function get(address tok) public returns(address);
}

contract IIndex {
    function inc(address who) public returns(uint256);
}

contract Collateral is Authority {

    struct hstate {
        uint256 c; //locked-collateral,   锁定状态的抵押物数量
        uint256 s; //stablecoin,          已借出的稳定币数量
        uint256 k; //unlocked-collateral, 未锁定状态的抵押物数量
    }

    uint256 public tot;                        //抵押物产生的稳定币总量(total)
    mapping (address => hstate) public hol;    //以账户为单位记录持有状态(hold state of address)

    uint256 public rat;                        //利率(rate)
    uint256 public rit;                        //最后rise时间(rise-time), rise 计算一段时间内产生的利息并累计到债务管理器
    uint256 public exr;                        //兑换比率, 基于ove计算(exchange rate)
    address public tok;             

    IDebtor public dor;                        //债务管理器(debtor)
    bool    public hea;                        //系统状态标记(healthy), false 表示系统已经停止运行, 并允许捐助者按比例取回

    uint256 public pce;                        //当前抵押物价格(price);
    address public wet;                        //wallet

    address public idx;                        //Index, 记录已经使用过系统的账户.

    uint256 public fee;                        //年利率.

    /** 治理参数 */

    uint256 public upp;        //允许抵押物产生的稳定币总量上限(upper)
    uint256 public low;        //允许抵押物产生的稳定币总量下限(lower)
    uint256 public ove;        //最小抵押率(overflow)
    uint256 public gth;        //利率增长量(growth)
    uint256 public seg;        //单次清算数量(segmentation).
    uint256 public fin;        //清算罚金(fine)
    address public fer;        //喂价器(feeder)
    address public pxy;        //清算器代理账户(liquidation auction).

    event Feed(uint256 val, uint256 exr);
    event Payback(address indexed who, uint256 s, uint256 c);
    event Borrow(address indexed who, uint256 c, uint256 s);
    event Deposit(address indexed sender, address indexed who, uint256 amount);
    event Withdraw(address indexed sender, address indexed who, uint256 amount);
    
    event Liquidate(address who, address rve, address oss, uint256 oam, address iss, uint256 iam, uint256 bid);

    /** 初始化 */

    constructor(address w, address t, address d, address p, address i) public {
        wet = w;
        tok = t;
        dor = IDebtor(d);
        pxy = p;
        idx = i;
        hea = true;
        rit = now;
        rat = PRE;
    }

    /** 治理 */

    function setupp(uint256 v) public auth {
        upp = v;
    }
    function setlow(uint256 v) public auth {
        low = v;
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
        fer = v;
    }
    function setpxy(address v) public auth {
        pxy = v;
    }
    function sethea(bool v) public auth {
        hea = v;
    }
    function setidx(address v) public auth {
        idx = v;
    }
    function setfee(uint256 v) public auth {
        fee = v;
    }

    /** 喂价 */

    function feed() public {
        pce = IFeeder(fer).get();
        //抵押物价格(val): 1 USD
        //最小抵押率(ove): 150%
        //兑换比(exr): val/ove = 1/1.5, 表示1.5个抵押物才兑换1个Qian, 或者说1个抵押物大约能兑换 0.6666666666666666... 个 Qian
        //乘以PRE(10 ** 18)是防止0.6666...被抹成0
        exr = (pce * PRE27) / ove;  //[10^27]
        emit Feed(pce, exr);
    }

    /** 抵押/赎回 */
    
    //赎回(稳定币=>抵押物)
    
    //调用赎回接口分两种情况:
    //1. 仅归还稳定币, 仅为用户减少 @snt 的稳定币持有数量(hol[u].s - @snt), 不减少抵押物的数量(@cnt为0, 即 hol[u].e 不变), 
    //  相当于提高了质押率, 但是那些没有稳定币对应的抵押物可以随时取出(从 hol[u].e 转移到 hol[u].c)), 
    //  如果稳定币的持有数量不足以归还系统债务, 则未还的债务必须存在相应数量的的抵押物.
    //2. 仅取走抵押物, 仅为用户减少 @cnt 的抵押物持有数量(hol[u].e - @cnt), 不减少稳定币的数量(@s为0, 即 hol[u].s 不变).
    //  相当于降低了质押率, 但剩余的抵押物数量最少要满足未还债务的最小抵押率.
    //
    //后续需要区分 @hol[u].e 中有多少是属于稳定币对应的抵押物和多少没有稳定币对应的抵押物, 算法为:
    //计算稳定币对应的抵押物数量(amount): 
    //  hol[u].s * rat = amount * exr;
    //  amount = hol[u].s * rat / exr;
    //  amount = hol[u].s * rat / (price / ove)
    //  amount = hol[u].s * rat * ove / price;
    //计算没有稳定币对应的抵押物数量: 
    //  hol[u].e - amount;
    function payback(address who, uint256 s, uint256 c) public {
        address u = who;

        require(rat != 0, "rate must not be 0");
        require(hea, "system has been stopped");
        
        //增加未锁定的抵押物持有记录.
        hol[u].k = uadd(hol[u].k, c);
        //减少抵押物持有记录
        hol[u].c = usub(hol[u].c, c);
        //减少相应的稳定币记录.
        hol[u].s = usub(hol[u].s, s);
        //减少该类型抵押物对应的稳定币总量.
        tot = usub(tot, s);
        //检查当前抵押物生成的稳定币总量下限.
        require(umul(hol[u].s, rat) >= low, "out of collateral ceiling");
        //检查剩余的抵押物和稳定币之间的抵押比, 必须保持大于等于ove.
        uint256 cc = (umul(exr, ove) / PRE9) < pce 
                        ? umul(hol[u].c, exr) / PRE9 + 1 
                        : umul(hol[u].c, exr) / PRE9;
        require(umul(hol[u].s, rat) <= cc, "bad collateral ratio");

        uint256 ss = umul(s, rat);
        //给 @u 销毁 @s * @rat 数量的稳定币.
        dor.burn(u, ss);
        emit Payback(u, s, c);
    }

    //抵押(抵押物=>稳定币), 使用 @cnt (collateralamount) 数量的抵押物来兑换 @snt (stablecoinamount) 数量的稳定币.
    //给定抵押物数量 @cnt, 最大的稳定币兑换数量为 @snt = @cnt * @exr / @rat 或者 @snt = (@cnt * @price) / (@rat * @ove)
    //其中@cnt * @exr 或者 (@cnt * @price) / @ove 是在不考虑利息的情况下可兑换的最大数量, 但是实际上的最大可兑换数量还要考虑利息, 所以 / @rat.
    //例如要兑换10个稳定币, 那 @snt 不是 10, 而是 10 / rat.

    function borrow(address who, uint256 s, uint256 c) public {
        address u = who;

        require(hea, "system has been stopped");
        require(rat != 0, "rate must not be 0");

        //减少未锁定的抵押物记录.
        hol[u].k = usub(hol[u].k, c);
        //增加抵押物持有记录
        hol[u].c = uadd(hol[u].c, c);
        //增加相应的稳定币记录
        hol[u].s = uadd(hol[u].s, s);
        //增加该类型抵押物对应的稳定币总量
        tot = uadd(tot, s);
        //检查当前生成的稳定币总量上限和下限
        require(umul(tot, rat) <= upp && umul(hol[u].s, rat) >= low, "out of collateral ceiling");
        //检查剩余的抵押物和稳定币之间的抵押比, 必须保持大于等于ove.
        uint256 cc = (umul(exr, ove) / PRE9) < pce 
                        ? umul(hol[u].c, exr) / PRE9 + 1 
                        : umul(hol[u].c, exr) / PRE9;
        require(umul(hol[u].s, rat) <= cc, "bad collateral ratio");
        
        uint256 ss = umul(s, rat);
        //给 @msg.sender 增发 @s * @rat 数量的稳定币
        dor.mint(u, ss);
        IIndex(idx).inc(who);
        emit Borrow(u, s, c);
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
        require(hea);

        if(now == rit) {
            return;
        }
        //@gth 是被表示为 @PRE(10 ** 18) 的值, 如果直接计算 @gth ** (now - rit) 结果会超级巨大, 
        //如果先除以 @PRE(10 ** 18), 又可能会出现结果被抹成0的情况(0.XXXX...), 所以这里使用专用的 pow 算法.
        uint256 crat = umul(rat, pow(gth, (now - rit)));

        int256 b = diff(crat, rat);
        int256 t = int256(tot);
        int256 i = t * b;
        require(b == 0 || i / b == t);

        i < 0 ? dor.deci(uint256(i * -1) / PRE) : dor.inci(uint256(i) / PRE);
        rat = b < 0 ? usub(rat, uint256(b * -1)) : uadd(rat, uint256(b));

        //处理债务的误差 

        uint256 dt = dor.tot();
        uint256 tt = umul(tot, rat);

        uint256 cge = dt < tt ? tt - dt : 0;
        dor.inci(cge);
        
        rit = now;
    }

    /** 抵押物清算 */

    //对 @who 发起清算, 减少 @who 的债务同时并拍卖相应的抵押物.
    function liquidate(address who) public {
        require(hea);

        hstate memory h = hol[who];

        require((umul(h.c, exr) / PRE9) < umul(h.s, rat));
        //计算待清算抵押物的数量, MIN(持有的抵押物数量, 单次清算数量)
        uint256 c = min(h.c, seg);
        //计算待清算的抵押物对应的稳定币数量, MIN(持有的稳定币数量, 稳定币数量 * 清算的抵押物数量 / 持有的抵押物数量)
        uint256 s = min(h.s, udiv(umul(h.s, c), h.c));
        uint256 d = umul(s, rat);
        //从 @who 的持有数量中去掉待清算的抵押物记录.
        hol[who].c = usub(hol[who].c, c);
        //从 @who 的持有数量中去掉待拍卖的抵押物对应的稳定币记录.
        hol[who].s = usub(hol[who].s, s);
        //从总的稳定币数量中去掉待拍卖的抵押物对应的稳定币记录.
        tot = usub(tot, s);
        
        address a = IWallet(wet).get(tok);
        require(a != address(0), "not find asset");
        
        IToken(tok).approve(a, c);
        IAsset(a).deposit(address(this), c);
        IAsset(a).move(address(this), pxy, c);

        //增加系统坏账记录, 在清算回稳定币之前属于一笔无抵押物对应的坏账.
        //并且此时用户持有的稳定币(@debtor.hol[who])数量没有变化, 
        //但是被清算的抵押物和对应的稳定币将以系统坏账的形式存在;
        dor.incb(d);

        emit Liquidate(who, address(dor), tok, c, dor.tok(), umul(d, fin), 0);
    }

    //获取用户 @who 由当前抵押物中产生的负债(稳定币总量 + 利息)
    function debt(address who) public view returns(uint256) {
        return umul(hol[who].s, rat);
    }
    
    //获取账户 @who 当前的抵押率 (c * pce)/(s * rat), 返回 0 表示当前用户没有抵押物记录.
    function cratio(address who) public view returns (uint256) {
        uint256 s = umul(hol[who].s, rat);
        uint256 c = umul(hol[who].c, pce);
        return s == 0 ? 0 : udiv(c, s);
    }

    function liquidationprice(address who) public view returns(uint256) {
        //r = (c * pce)/(s * rat)
        //pce = (s * rat * r / c);
        return udiv(umul(umul(hol[who].s, rat), ove), hol[who].c);
    }

    function evaluateratio(uint256 c, uint256 s) public view returns(uint256) {
        uint256 ss = umul(s, rat);
        uint256 cc = umul(c, pce);
        return ss == 0 ? 0 : udiv(cc, ss);
    }

    function evaluateborrowc(uint256 s) public view returns(uint256) {
        //c = ((s * rat * ove) / pce)
        return udiv(umul(umul(s, rat), ove), pce);
    }

    function evaluateborrows(uint256 s) public view returns(uint256) {
        uint256 ss = udiv(s, rat);
        return umul(ss, rat) < s ? ss + 1 : ss;
    }

    function evaluatepaybacks(address who, uint256 s) public view returns(uint256) {
        uint256 ss = udiv(s, rat);
        ss = umul(ss, rat) < s ? ss + 1 : ss;
        return ss <= hol[who].s ? ss : hol[who].s;
    }

    function borrowable(address who) public view returns(uint256) {
        uint256 s = borrowedby(hol[who].c);
        uint256 d = debt(who);
        return s <= d ? 0 : usub(s, d);
    }
    
    //计算 @c 个抵押物最大可借的稳定币数量 ( c * pce ) / ove
    function borrowedby(uint256 c) public view returns(uint256) {
        return udiv(umul(c, pce), ove);
    }

    //@who 已借出的稳定币对应的抵押物的数量.
    function collateralized(address who) public view returns(uint256) {
        return evaluateborrowc(hol[who].s);
    }

    //@who 可取回的抵押物的数量.
    function uncollateralized(address who) public view returns(uint256) {
        uint256 c = evaluateborrowc(hol[who].s);
        return hol[who].c <= c ? 0 : usub(hol[who].c, c);
    }
    
    function move(address from, address to, uint256 amount) public auth {
        hol[from].k = usub(hol[from].k, amount);
        hol[to].k = uadd(hol[to].k, amount);
    }

    function deposit(address who, uint256 amount) public payable {
        hol[who].k = uadd(hol[who].k, amount);
        if(tok == address(0)) {
            require(amount == msg.value, "amount mismatch with msg.value");
            return;
        }
        require(IToken(tok).transferFrom(who, address(this), amount));
        emit Deposit(msg.sender, who, amount);
    }

    function withdraw(address payable who, uint256 amount) public {
        hol[who].k = usub(hol[who].k, amount);
        if(tok == address(0)) {
            who.transfer(amount);
            return;
        }
        require(IToken(tok).transfer(who, amount));
        emit Withdraw(msg.sender, who, amount);
    }

    function holc(address who) public view returns(uint256) {
        return hol[who].c;
    }
    function hols(address who) public view returns(uint256) {
        return hol[who].s;
    }
    function holk(address who) public view returns(uint256) {
        return hol[who].k;
    }

    function pow(uint256 x, uint256 n, uint256 base) internal pure returns (uint256 z) {
	//TODO
    }

    function pow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        return pow(x, n, PRE);
    }

    function min(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = (x <= y ? x : y);
    }

    function umul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / PRE;
    }

    function udiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * PRE;
        require(x == 0 || z / x == PRE);
        z = z / y;
    }

    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }

    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }

    function diff(uint256 x, uint256 y) internal pure returns (int z) {
        z = int(x) - int(y);
        require(int(x) >= 0 && int(y) >= 0);
    }

    /** 系统内部精度 */
    uint256 constant public PRE  = 10 ** 18;
    uint256 constant public PRE9 = 10 ** 9;
    uint256 constant public PRE27 = 10 ** 27;
}
