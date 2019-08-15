
const simpleabi = require('simpleabi');

// {
//     "282d3fdf": "lock(address,uint256)",
//     "481c6a75": "manager()",
//     "f83fc96c": "maps(address)",
//     "d0ebdbe7": "setManager(address)",
//     "fc0c546a": "token()",
//     "7eee288d": "unlock(address,uint256)"
// }

function Bridge(tx, address) {

    this.tx = tx;
    this.address = address;
    
    this.maps = async function (who, options) {
        let _this = this;
        return await this.tx.call({
            from: options.from,
            to: _this.address,
            value: "0",
            data: "0xf83fc96c" + simpleabi.encodeValue(who)
        });
    }
}

module.exports = Bridge;
