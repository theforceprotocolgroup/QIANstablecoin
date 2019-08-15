
const simpleabi = require('simpleabi');

// {
//     "c452d026": "addFederator(address)",
//     "e78cea92": "bridge()",
//     "05939ecc": "delFederator(address)",
//     "d39e4fe0": "federators(address)",
//     "95a030bb": "generateVoteId(bytes32,address,uint256)",
//     "b64a185f": "nfederators()",
//     "38d11add": "processed(bytes32,address,uint256)",
//     "8dd14802": "setBridge(address)",
//     "25c66de2": "vote(bytes32,address,uint256)"
// }

function Manager(tx, address) {

    this.tx = tx;
    this.address = address;

    this.vote = async function (transactionHash, receiver, amount, options) {
        const gasPrice = await tx.web3.eth.getGasPrice() * 1.50;
        const nonce = await tx.web3.eth.getTransactionCount(options.from);
        const data = "0x25c66de2" + simpleabi.encodeValues([ transactionHash, receiver, amount ]);
        const op = {
            from: options.from,
            to: this.address,
            value: "0", 
            gasPrice: gasPrice,
            nonce: nonce,
            data: data
        };
        const gas = await tx.web3.eth.estimateGas(op) * 1.50;
        op.gas = gas;
        return await this.tx.invoke(options.pkey, op);
    };

    this.processed = async function (transactionHash, receiver, amount, options) {
        return await this.tx.call({
            from: options.from, 
            to: this.address,
            value: "0",
            data: "0x38d11add" + simpleabi.encodeValues([ transactionHash, receiver, amount ])
        });
    };
}

module.exports = Manager;

