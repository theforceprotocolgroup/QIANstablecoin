//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 治理拍卖

pragma solidity >=0.5.0;

contract IAsset {
    function move(address from, address to, uint256 amt) public;
}

contract IWallet {
    function get(address tok) public returns(address);
}

contract Govauction {

    struct state {
        uint256 bid;    //竞拍出价(FOR)
        address rve;    //接收拍卖收入的账户
        uint256 oam;    //被拍卖的资产数量
        address oss;    //被拍卖资产的合约地址(QIAN)
        address iss;    //要买入资产的合约地址(FOR)
        address win;    //当前最高出价者
        uint48  ttl;    //当前出价的到期时间
        uint48  exp;    //拍卖结束时间
    }

    event End(uint256 id);
    event Auction(uint256 id, address rve, address iss, address oss, uint256 oam, uint bid);

    mapping (uint => state) public states;

    IWallet public wet; //wallet

    constructor(address w) public {
        wet = IWallet(w);
    }

    /** 拍卖参数 */

    uint256 public inc = 1.05E18;   //最小竞拍加/减价数量(5%); 
    uint32  public ttl = 2 hours;   //单次竞价有效时间.
    uint32  public exp = 1 days;    //整个拍卖持续时间.
    uint256 public nonce = 0;       //拍卖 id

    //发起竞拍. 
    //@rve 拍卖收益接收账户, 
    //@oam 被拍卖的资产数量
    //@bid 底价(FOR)

    function auction(address rve, address iss, address oss, uint256 oam, uint bid) public returns(uint id) {
        id = nonce++;
        states[id].bid = bid;
        states[id].oam = oam;
        states[id].oss = oss;
        states[id].iss = iss;
        states[id].win = rve;
        states[id].rve = rve;
        states[id].exp = uint32(now) + exp;
        states[id].ttl = 0;

        emit Auction(id, rve, iss, oss, oam, bid);
    }

    //  参与竞拍
    //  @id 拍卖id
    //  @oam 被拍卖的资产数量
    //  @bid 竞拍出价(FOR)

    function upward(uint id, uint oam, uint bid) public {
        state memory a = states[id];

        require(a.win != address(0));
        require(a.ttl > now || a.ttl == 0);
        require(a.exp > now);

        require(oam == a.oam);
        require(bid >  a.bid);
        require(bid >= umul(inc, a.bid));

        //将竞拍资产转给当前合约.
        IAsset(wet.get(a.iss)).move(msg.sender, address(this), bid);
        //将FOR还给上一个最高出价者
        IAsset(wet.get(a.iss)).move(address(this), a.win, a.bid);

        //设置新的最高出价者.
        states[id].win = msg.sender;
        states[id].bid = bid;
        states[id].ttl = uint32(now) + ttl;
    }

    //拍卖结算
    function end(uint id) public {
        state memory a = states[id];
        require(a.ttl != 0 && (a.ttl < now || a.exp < now));
        //将拍卖品(QIAN)转给最高出价者.
        IAsset(wet.get(a.oss)).move(address(this), a.win, a.oam);
        //将拍卖收益(FOR)转给接收者.
        IAsset(wet.get(a.iss)).move(address(this), a.rve, a.bid);
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