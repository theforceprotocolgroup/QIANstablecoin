//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 债务拍卖(竞买)

pragma solidity >= 0.5.0;

contract IAsset {
    function move(address from, address to, uint256 amt) public;
}

contract IWallet {
    function get(address tok) public returns(address);
}

contract Debtauction {

    struct state {
        uint256 iam;  // 卖方出价数量
        address iss;  // 要买入的资产合约地址(QIAN)
        address oss;  // 被拍卖的资产合约地址(Govtoken)
        uint256 bid;  // 预期要买入的资产数量
        address win;  // 当前最高出价者
        uint48  ttl;  // 当前出价的到期时间
        uint48  exp;  // 拍卖结束时间
    }

    event End(uint256 id);
    event Auction(uint256 id, address rve, address iss, address oss, uint256 iam, uint256 bid);

    mapping (uint256 => state) public states;

    IWallet public wet; 

    constructor(address w) public {
        wet = IWallet(w);
    }

    /** 拍卖参数 */

    uint256 public inc = 1.05E18;       //最小竞拍加/减价数量(5%).
    uint32  public ttl = 2 hours;      //单次竞价有效时间.
    uint32  public exp = 1 days;       //整个拍卖持续时间.
    uint256 public nonce = 0;              //拍卖 id

    //发起竞拍
    //@rve 表示竞拍收益的接受者
    //@oss 被拍卖的资产合约地址(Govtoken)
    //@iss 要买入资产合约地址(QIAN)
    //@bid 预期要买入的资产数量

    function auction(address rve, address iss, address oss, uint256 iam, uint256 bid) public returns (uint id) {
        id = nonce++;
        states[id].iam = iam;
        states[id].iss = iss;
        states[id].oss = oss;
        states[id].bid = bid;
        states[id].win = rve;
        states[id].exp = uint32(now) + exp;
        states[id].ttl = 0;

        emit Auction(id, rev, iss, oss, iam, bid);
    }

    //  参与竞拍
    //  @id 拍卖id
    //  @iam 竞拍出价
    //  @bid 预期要买入的资产数量

    function downward(uint id, uint iam, uint bid) public {
        state memory a = states[id];
        require(a.win != address(0), "require: invalid address a.win");
        require(a.ttl > now || a.ttl == 0, "require: bid has expired");
        require(a.exp > now, "require: auction has ended");
        //要求竞拍必须固定 @bid.
        require(bid == a.bid, "require: bid == a.bid");
        //每次竞拍出价必须低于比上一次出价.
        require(iam <  a.iam, "require: iam <  a.iam");
        //检查单次竞拍降价的数量是否满足最小竞拍降价步长.
        require(umul(inc, iam) <= a.iam, "require: umul(inc, iam) <= a.iam");
        
        //将当前出价者的稳定币转给上一个出价者
        IAsset(wet.get(a.iss)).move(msg.sender, a.win, bid);
        
        //更新当前拍卖记录.
        states[id].win = msg.sender;
        states[id].iam = iam;
        states[id].ttl = uint32(now) + ttl;
    }

    //拍卖结算
    function end(uint id) public {
        state memory a = states[id];
        require(a.ttl != 0 && (a.ttl < now || a.exp < now));
        IAsset(wet.get(a.oss)).move(address(this), a.win, a.iam);
        delete states[id];
        emit End(id);
    }

    function umul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / PRE;
    }

    uint256 constant public PRE = 10 ** 18;
}