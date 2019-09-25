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