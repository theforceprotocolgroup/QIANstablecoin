//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Debt Manager
//原力协议稳定币系统 - 债务管理器

pragma solidity >= 0.5.0;

import "./Authority.sol";

contract IStablecoin {
    function burn(address who, uint amount) public;
    function mint(address who, uint amount) public;
}

contract IAsset {
    function withdraw(address who, uint256 amount) public;
    function deposit(address who, uint256 amount) public payable;
    function balance(address who) public view returns(uint256);
}

contract IWallet {
    function get(address tok) public returns(address);
}

contract IGovtoken {
    function tok() public returns(address);
}

contract Debtor is Authority {
    /** 系统债务状态 */

    mapping (address => uint256) public hol;       //稳定币持有者及数量(hold)

    uint256 public tot;                            //已发行的稳定币总量(total)
    uint256 public bad;                            //坏账(baddebt)
    uint256 public cum;                            //累计购买的稳定币数量(cumulative)
    
    /** 结算参数 */

    address public pxy;                    //债务拍卖/治理拍卖的代理账户(debt auction)

    /** 稳定币 */

    IStablecoin public tok;

    /** 治理token */

    address public gov;

    /** 风险参数 */

    uint256 public tdc;                    //总债务上限(Total Debt Ceiling);
    IWallet public wet;                    //钱包

    /** 合约运行状态 */
        
    bool public hea;                      //系统状态标记(healthy), false 表示系统已经停止运行, 并允许捐助者按比例取回
    
    /** 事件 */
    event Buy(address rve, address iss, address oss, uint256 iam, uint256 bid);
    event Sel(address rve, address iss, address oss, uint256 oam, uint bid);

    /** 初始化 */
    
    constructor(address w, address s, address g) public {
        tok = IStablecoin(s);
        wet = IWallet(w);
        gov = g;
        hea = true;
    }

    /** 治理 */
    
    function setgov(address v) public auth {
        gov = v;
    }
    function settdc(uint256 v) public auth {
        tdc = v;
    }
    function setpxy(address v) public auth {
        pxy = v;
    }
    function sethea(bool v) public auth {
        hea = v;
    }


    /** 稳定币管理 */

    //为 @who 增发 @amount 数量的稳定币, 仅能被 @collateral.borrow 方法调用.
    function mint(address who, uint256 amount) public auth {
        require(hea);
        tok.mint(who, amount);
        hol[who] = uadd(hol[who], amount);
        tot = uadd(tot, amount);
        //检查是否超过允许的稳定币发行总量.
        require(tot <= tdc, "out of total debt");
    }

    //为 @who 销毁 @amount 数量的稳定币, 仅能被 @collateral.payback 方法调用.
    //需要 tok.approve 授权
    function burn(address who, uint256 amount) public auth {
        require(hea);
        require(hol[who] >= amount);
        tok.burn(who, amount);
        hol[who] = usub(hol[who], amount);
        tot = usub(tot, amount);
    }

    /** 稳定币转入转出 */

    //转入(销毁)稳定币token, 增加稳定币持有记录.
    //销毁稳定币, 需要 @tok.approve 授权.
    function deposit(address who, uint256 amount) public {
        require(hea);
        tok.burn(who, amount);
        //增加系统中的稳定币持有记录
        hol[who] = uadd(hol[who], amount);
    }

    //转出(增发)稳定币token, 减少稳定币持有记录.
    function withdraw(address who, uint256 amount) public {
        require(hea);
        require(hol[who] >= amount);
        //增发稳定币
        tok.mint(who, amount);
        //减少系统中的稳定币持有记录
        hol[who] = usub(hol[who], amount);
    }

    /** 累计利息 */

    function inci(uint256 amount) public auth {
        require(hea);
        tot = uadd(tot, amount);
        hol[address(this)] = uadd(hol[address(this)], amount);
    }

    function deci(uint256 amount) public auth {
        require(hea);
        tot = usub(tot, amount);
        hol[address(this)] = usub(hol[address(this)], amount);
    }

    /** 累加系统坏账 */
    function incb(uint256 amount) public auth {
        require(hea);
        bad = uadd(bad, amount);
    }
    
    /** 从钱包中把抵押物拍卖所得取回 */

    function take(uint256 s) public auth {
        require(hea);
        IAsset(wet.get(address(tok))).withdraw(address(this), s);
        hol[address(this)] = uadd(hol[address(this)], s);
    }

    /** 购买稳定币 */
    //(event) Liquidauction.End 
    //  => this.take 
    //  => this.repay 
    //  => this.buy 
    //  => this.repay
    // [=> this.buy => this.repay ...]

    function buy(uint256 s) public auth {
        require(hol[address(this)] == 0,
            "require: hol[address(this)] == 0");
        require(usub(bad, cum) >= s,
            "require: usub(bad, cum) >= s");
        cum = uadd(cum, s);

        emit Buy(address(this), address(tok), gov, uint16(-1), s);
    }

    /** 拍卖稳定币 */

    function sel(uint256 s) public auth {
        require(bad == 0 && cum == 0,
            "require: bad == 0 && cum == 0");
        hol[address(this)] = usub(hol[address(this)], s);
        tok.mint(pxy, s);
        IAsset(wet.get(address(tok))).deposit(pxy, s);

        emit Sel(gov, IGovtoken(gov).tok(), address(tok), s, 0);
    }

    //归还债务
    function repay() public {
        require(hol[address(this)] > 0 && bad > 0, 
            "require: hol[address(this)] > 0 && bad > 0");
        //确定当前需要归还给系统的债务与当前系统的盈余, 取较小者作为待归还数量.
        uint256 pay = min(hol[address(this)], bad);
        hol[address(this)] = usub(hol[address(this)], pay);
        bad = usub(bad, pay);
        tot = usub(tot, pay);

        pay = min(pay, cum);
        cum = usub(cum, pay);
    }
    
    function min(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = (x <= y ? x : y);
    }
    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }
    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }
}