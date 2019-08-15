
const Web3 = require("web3");
var Etx = require('ethereumjs-tx');

function TxImpl(host) {
    this.web3 = new Web3(new Web3.providers.HttpProvider(host));
    let _this = this;
    this.call = async function(options) {
        return await _this.web3.eth.call(options);
    }

    this.invoke = function(pk, options) {
        let _this = this;
        return new Promise(function(resolve, reject) {
            const pkb = new Buffer(pk.substring(2), 'hex')
            let tx = new Etx(options);
            tx.sign(pkb);
            const stx = tx.serialize();

            _this.web3.eth.sendSignedTransaction('0x' + stx.toString('hex'))
            .on('confirmation', function(confirmationNumber, receipt){
                resolve(receipt);
            })
            .on('error', function(error){
                reject(error);
            });
        });
    }
    
    this.getLogs = async function(address, fromBlock, toBlock, topics, cb) {

        const filter = {
            fromBlock: fromBlock,
            toBlock: toBlock,
            address: address,
            topics: topics
        };

        return await this.web3.eth.getPastLogs(filter);
    }

    this.getBlockNumber = async function() {
        return await this.web3.eth.getBlockNumber();
    }
}

function Tx(host) {
    TxImpl.call(this, host);
}

module.exports = Tx;