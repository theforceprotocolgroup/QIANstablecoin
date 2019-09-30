//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 稳定币购买

pragma solidity >= 0.5.0;

contract moveable {
    function move(address from, address to, uint256 amt) public;
}

contract buyer {

    struct auctionstate {
        address cor;  // 拍卖品管理器, 负责拍卖品记录转移.
        address dor;  // 资产管理器, 负责出价人的资产记录转移.
        address per;  // 付款人 payer
        uint256 amt;  // 卖方出价(FOR)
        uint256 bid;  // 预期要买入的稳定币数量
        address win;  // 当前最高出价者
        uint48  ttl;  // 当前出价的到期时间
        uint48  exp;  // 拍卖结束时间
    }

    mapping (uint => auctionstate) public auctions;

    /** 拍卖参数 */

    uint256 public inc; // = 1.05E27(5%);  //最小竞拍加/减价数量.
    uint32  public ttl; // = 3 hours;      //单次竞价有效时间.
    uint32  public exp; // = 2 days;       //整个拍卖持续时间.
    uint256 public nonce = 0;              //拍卖 id

    //发起竞拍, 仅能被 @debtor 调用
    //@cor 拍卖品管理器
    //@dor 资产管理器,
    //@per 支付者, 付款人.
    //@rec 表示购买到的稳定币的接受者, 
    //@bid 预期要买入的稳定币数量
<<<<<<< Updated upstream
=======

    function auction(address cor, address dor, address per, address rec, uint256 bid) public returns (uint id) {
        id = nonce++;
        auctions[id].cor = cor;
        auctions[id].dor = dor;
        auctions[id].per = per;
        auctions[id].win = rec;
        auctions[id].amt = uint256(-1);
        auctions[id].bid = bid;
        auctions[id].exp = uint32(now) + exp;
    }

    //参与竞拍. @id 拍卖id, @amt 竞拍出价, @bid 预期要买入的稳定币数量, 
    function downward(uint id, uint amt, uint bid) public {
        auctionstate memory a = auctions[id];
        require(a.win != address(0));
        require(a.ttl > now || a.ttl == 0);
        require(a.exp > now);
        //要求竞拍必须固定 @bid.
        require(bid == a.bid);
        //每次竞拍出价必须低于比上一次出价.
        require(amt <  a.amt);
        //检查单次竞拍降价的数量是否满足最小竞拍降价步长.
        require(inc * amt <= a.amt);
        //将当前出价者的稳定币转给上一个出价者
        moveable(a.dor).move(msg.sender, a.win, bid);
>>>>>>> Stashed changes
