//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - debt manager
//原力协议稳定币系统 - 债务管理器

pragma solidity >= 0.5.0;

import "./authority.sol";
import "./arith.sol";


contract istablecoin {
    function burn(address who, uint amt) public;
    function mint(address who, uint amt) public;
}


contract ireverseauction {
    function auction(address cor, address dor, address per, address rec, uint256 amt) public returns(uint256);
}


contract iforwardauction {
    function auction(address cor, address dor, address per, address rec, uint256 amt, uint256 bid) public returns(uint256);
}


contract debtor is authority, arith {
    /** 系统债务状态 */

    mapping (address => uint256) public hol;       //稳定币持有者及数量.

    uint256 public tot;                            //已发行的稳定币总量(total)
    uint256 public bad;                            //坏账(baddebt)
    uint256 public ext;                            //购买的稳定币数量(extracoin)
    
    /** 结算参数 */

    uint256 public seg;                            //单次购买稳定币的数量.
    uint256 public sel;                            //单次卖出稳定币的数量.

    ireverseauction public ber;                    //稳定币购买合约(buy);
    iforwardauction public ser;                    //稳定币拍卖合约(sell);

    address             public gov;                //治理代币

    /** 稳定币 */

    istablecoin public tok;

    /** 风险参数 */

    uint256 public tdc;                            //总债务上限(Total Debt Ceiling);

    /** 合约运行状态 */
        
    bool public wel;                               //禁止数据流动
    
    function stop() public auth {
        wel = false;
    }

    function start() public auth {
        wel = true;
    }

    /** 初始化 */
    
    constructor(address s, address g) public {
        tok = istablecoin(s);
        gov = g;
        wel = true;
    }

    /** 治理 */
    
    function settdc(uint256 v) public auth {
        tdc = v;
    }

    function setber(address v) public auth {
        ber = ireverseauction(v);
    }

    function setser(address v) public auth {
        ser = iforwardauction(v);
    }

    /** 稳定币管理 */

    //为 @who 增发 @amt 数量的稳定币, 仅能被 @collateral.exchangeto 方法调用.
    function mint(address who, uint256 amt) public auth {
        tok.mint(who, amt);
        hol[who] = uadd(hol[who], amt);
        tot = uadd(tot, amt);
        //检查是否超过允许的稳定币发行总量.
        require(tot <= tdc, "out of total debt ceiling");
    }

    //为 @who 销毁 @amt 数量的稳定币, 仅能被 @collateral.exchangefrom 方法调用.
    //需要 tok.approve 授权
    function burn(address who, uint256 amt) public auth {
        require(hol[who] >= amt);
        tok.burn(who, amt);
        hol[who] = usub(hol[who], amt);
        tot = usub(tot, amt);
    }

    /** 稳定币转入转出 */

    //转入(销毁)稳定币token, 增加稳定币持有记录.
    //销毁稳定币, 需要 @tok.approve 授权.
    function deposit(uint256 amt) public {
        require(wel);
        require(amt > 0);
        tok.burn(msg.sender, amt);
        //增加系统中的稳定币持有记录
        hol[msg.sender] = uadd(hol[msg.sender], amt);
    }

    //转出(增发)稳定币token, 减少稳定币持有记录.
    function withdraw(uint256 amt) public {
        require(wel);
        require(amt > 0);
        require(hol[msg.sender] >= amt);
        //增发稳定币
        tok.mint(msg.sender, amt);
        //减少系统中的稳定币持有记录
        hol[msg.sender] = usub(hol[msg.sender], amt);
    }

    /** 累计利息 */

    function incinterest(uint256 amt) public auth {
        require(wel);
        tot = uadd(tot, amt);
        hol[address(this)] = uadd(hol[address(this)], amt);
    }

    function decinterest(uint256 amt) public auth {
        require(wel);
        tot = usub(tot, amt);
        hol[address(this)] = usub(hol[address(this)], amt);
    }

    /** 累加系统坏账 */

    function incbaddebt(uint256 amt) public auth {
        bad = uadd(bad, amt);
    }

    /** 债务转移 */

    //仅允许 @ser, @ber 调用
    function move(address from, address to, uint256 amt) public auth {
        hol[from] = usub(hol[from], amt);
        hol[to] = uadd(hol[to], amt); //当to == address(this) 时, 实际上是累加系统收入.
    }

    /** 坏账处理 */

    //购买稳定币
    function buy() public returns (uint id) {
        //确保当前系统中没有盈余, 如果有盈余需要先通过 @repay 归还部分债务.
        require(hol[address(this)] == 0);
        //确保剩余的债务大于购买数量: 当前合约债务 - 稳定币已购买总量 >= 本次要购买的稳定币数量 @seg
        //当前合约的债务在 @collateral.liquidate 中产生
        require(bad >= ext && (bad - ext) >= seg);
        //累计当前已购买的稳定币总量, 防止多买.
        ext = uadd(ext, seg);
        //发起竞买拍卖
        //government token. => stablecoin 
        id = ber.auction(gov, address(this), gov, address(this), seg); //gov.mint
    }
    
    //拍卖稳定币
    function sell() public returns (uint id) {
        //仅当当前合约没有债务并且没有额外购买的稳定币时才允许拍卖多余的稳定币.
        require(bad == 0 && ext == 0);
        require(hol[address(this)] >= sel);
        //stablecoin => government token.
        id = ser.auction(address(this), gov, address(this), gov, sel, 0);
    }

    //归还债务
    function repay() public {
        require(hol[address(this)] > 0 && bad > 0);
        //确定当前需要归还给系统的债务与当前系统的盈余, 取较小者作为待归还数量.
        uint256 amt = min(hol[address(this)], bad);
        //结算债务
        hol[address(this)] = usub(hol[address(this)], amt);
        bad = usub(bad, amt);
        tot = usub(tot, amt);
        //减少稳定币购买记录.
        amt = min(amt, ext);
        ext = usub(ext, amt);
    }
}
