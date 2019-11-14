//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//The Force Protocol Stablecoin system - Contract Wallet
//原力协议稳定币系统 - 合约钱包

pragma solidity >= 0.5.0;

import "./Asset.sol";
import "./Authority.sol";

contract Wallet is Authority {
    mapping(address=>address) public assets;

    function create(address tok) public auth returns(address) {
        require(assets[tok] == address(0), "asset has been created");
        Asset a = new Asset(tok);
        assets[tok] = address(a);
        return assets[tok];
    }

    function join(address asset) public returns(address) {
        require(assets[asset] == address(0), "asset has been joined");
        assets[asset] = asset;
        return asset;
    }

    function get(address tok) public view returns(address) {
        return assets[tok];
    }
}