//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 清算拍卖

pragma solidity >= 0.5.0;

contract IAsset {
    function move(address from, address to, uint256 amt) public;
}

contract IWallet {
    function get(address tok) public returns(address);
}

contract Liquidauction {

    struct state {
        uint256 bid; //当前出价
        address win; //当前最高出价者

        uint32  ttl; //当前出价的过期时间
        uint32  exp; //本次拍卖结束时间
        
        address who; //拍卖品所属账户, 接收卖出的资产退回();
        uint256 rem; //未卖出的抵押物数量(remainder);
        
        address rve; //接收拍卖收益的账户(received)

        uint256 oam; //被拍卖的资产数量(out amount)
        uint256 iam; //预期收益资产数量(int amount)

        address oss; //被拍卖的资产地址(out address)
        address iss; //收益资产地址(in address)
    }

    event End(uint256 id);
    event Auction(uint256 id, address who, address rve, address oss, 
        uint256 oam, address iss, uint256 iam, uint256 bid);

    mapping (uint256 => state) public states;

    IWallet public wet;                   //wallet

    constructor(address w) public {
        wet = IWallet(w);
    }

    /** 拍卖参数 */

    uint256 public inc = 1.05E18;      //最小竞拍加价 (5%)
    uint32  public ttl = 2 hours;      //单次竞价有效时间.
    uint32  public exp = 1 days;       //整个拍卖持续时间.
    uint256 public nonce = 0;          //拍卖 id

    //发起拍卖

    //@who 拍卖品所属账户, 接收卖出的资产退回
    //@rve 接收拍卖收益的账户(received)
    //@oam 被拍卖的资产数量(out amount)
    //@iam 预期收益资产数量(in amount)
    //@bid 起拍价
    //@oss 被拍卖的资产地址
    //@iss 收益资产地址(QIAN)

    function auction(address who, address rve, address oss, 
                    uint256 oam, address iss, uint256 iam, uint256 bid) 
                        public returns(uint256) {

        uint256 id = nonce++;

        states[id].bid = bid;
        states[id].win = rve;

        states[id].exp = uint32(now) + exp;
        states[id].ttl = 0;

        states[id].who = who;
        states[id].rve = rve;
        states[id].rem = oam;

        states[id].oam = oam;
        states[id].oss = oss;

        states[id].iam = iam;
        states[id].iss = iss;

        emit Auction(id, who, rve, oss, oam, iss, iam, bid);
    }

    //拍卖第一阶段, 固定抵押物数量, 直到出价高于预期要拍卖的稳定币数量 @auction.iam 后转为第二阶段竞拍.
    function upward(uint id, uint oam, uint bid) public {
        state memory a = states[id];

        //检查当前出价者是否有效
        require(a.win != address(0), "require: invalid address a.win");
        //检测当前叫价是否过期
        require(a.ttl > now || a.ttl == 0, "require: bid has expired");
        //检测拍卖是否结束
        require(a.exp > now, "require: auction has ended");
        //固定拍卖物数量的前提下增高叫价 @bid.
        require(oam == a.oam, "require: oam == a.oam");
        //第一阶段最高出价只能到预期要拍卖的资产数量, 也就是说拍卖出价上限为 a.iam.
        require(bid <= a.iam, "require: bid < a.iam");
        //最新的出价只能比之前的价格更高.
        require(bid > a.bid, "require: bid > a.bid");
        //每次出价必须比上一次的出价高出 @inc, 或者出价已经是最大(等于 @a.iam)
        require(bid >= umul(inc, a.bid) || bid == a.iam, "require: bid >= umul(inc, a.bid) || bid == a.iam");  

        //从钱包中读取资产对象.
        IAsset bet = IAsset(wet.get(a.iss));

        //将竞拍者的出价转给当前合约.
        bet.move(msg.sender, address(this), bid);
        //将上一次竞拍者 @a.win 的出价资产归还
        bet.move(address(this), a.win, a.bid);

        //更新本次出价者为最高出价者, 本次出价为最高出价, 本次出价过期时间.
        states[id].win = msg.sender;
        states[id].bid = bid;
        states[id].ttl = uint32(now) + ttl;
    }

    //拍卖第二阶段, 固定价格, 竞拍者通过降低拍卖物数量来参与竞拍, 数量最低者将成交.
    function downward(uint id, uint oam, uint bid) public {
        state memory a = states[id];
        
        require(a.win != address(0), "require: invalid address a.win");
        require(a.ttl > now || a.ttl == 0, "require: bid has expired");
        require(a.exp > now, "require: auction has ended");
        
        //固定出价的前提下减少抵押物的数量 @oam
        require(bid == a.bid);
        require(bid == a.iam);
        require(oam < a.oam);

        //竞拍减少的抵押物数量必须满足 @inc 配置的步长.
        require(umul(inc, oam) <= a.oam);

        //将上一次的竞拍者 @a.win 的出价资产归还
        IAsset(wet.get(a.iss)).move(msg.sender, a.win, bid);

        //更新最新的最高出价者, 拍卖品数量, 本次出价的过期时间.
        states[id].win = msg.sender;
        states[id].oam = oam;
        states[id].ttl = uint32(now) + ttl;
    }

    //结束拍卖, 仅当拍卖有至少一次竞拍时才允许调用.
    function end(uint id) public {
        state memory a = states[id];
        //检测拍卖是否完成(并且有参与竞拍)
        require(a.ttl != 0 && (a.ttl < now || a.exp < now), "auction is not end yet");
        //派发拍卖品
        IAsset(wet.get(a.oss)).move(address(this), a.win, a.oam);
        //将剩余拍卖品转给原持有者(退回到钱包中)
        IAsset(wet.get(a.oss)).move(address(this), a.who, usub(a.rem, a.oam));
        //派发收益
        IAsset(wet.get(a.iss)).move(address(this), a.rve, a.bid);
        delete states[id];

        emit End(id);
    }

    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }
    function umul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / PRE;
    }

    uint256 constant public PRE = 10 ** 18;
}