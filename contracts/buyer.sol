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
