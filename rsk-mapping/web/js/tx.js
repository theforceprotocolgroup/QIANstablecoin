//FOR TOKEN:

//   {
// "dd62ed3e": "allowance(address,address)",
// "095ea7b3": "approve(address,uint256)",
// "cae9ca51": "approveAndCall(address,uint256,bytes)",
// "70a08231": "balanceOf(address)",
// "313ce567": "decimals()",
// "06fdde03": "name()",
// "95d89b41": "symbol()",
// "18160ddd": "totalSupply()",
// "a9059cbb": "transfer(address,uint256)",
// "23b872dd": "transferFrom(address,address,uint256)"
// }


//BRIDGE:

// {
//     "282d3fdf": "lock(address,uint256)",
//     "481c6a75": "manager()",
//     "f83fc96c": "maps(address)",
//     "d0ebdbe7": "setManager(address)",
//     "fc0c546a": "token()",
//     "7eee288d": "unlock(address,uint256)"
// }

var tx = {
    pad64: function(data) {
        console.log("data: ", data);
        if(data.substr(0,2) == "0x") {
            return data.substr(2).padStart(64, '0');
        }
        return data.padStart(64, '0');
    },

    //balanceOf(from)
    balanceOf: function(from, to, cb){
        who = this.pad64(from);
        const transactionParameters = {
            to: to,
            from: from, 
            value: '0x0',
            data: '0x70a08231' + who
        };
        if(!cb) {
            cb = function(e, v) {

            }
        }
        ethereum.sendAsync({method: 'eth_call', params: [transactionParameters], from: from}, cb);
    },
    //approve(who, amount);
    approve: function(from, to, who, /*hex*/amount, cb) {
        if(typeof amount == 'number') {
            amount = amount.toString(16);
        }
        amount = this.pad64(amount);
        who = this.pad64(who);
        const transactionParameters = {
            to: to,
            from: from, 
            value: '0x0',
            data: '0x095ea7b3' + who + amount
        }
        if(!cb) {
            cb = function(e, v) {

            }
        }
        ethereum.sendAsync({method: 'eth_sendTransaction', params: [transactionParameters], from: from}, cb);
    },

    getTransactionReceipt: function(txh) {
        return new Promise(function(resolve, reject){
            ethereum.sendAsync({method: 'eth_getTransactionReceipt', params: [txh]}, function(e, v){
                if(e) {
                    reject(e);
                } else {
                    resolve(v);
                }
            }); 
        });
    },

    //allowance[from][who]
    allowance: function(from, to, who, cb) {
        const spender = this.pad64(who);
        const owner = this.pad64(from);
        const transactionParameters = {
            to: to,
            from: from, 
            value: '0x0',
            data: '0xdd62ed3e' + owner + spender
        };
        if(!cb) {
            cb = function(e, v) {

            }
        }
        ethereum.sendAsync({method: 'eth_call', params: [transactionParameters], from: from}, cb);
    },

    //mapped[from][who]
    mapping: function(from, to, who, amount, cb) {
        if(typeof amount == 'number') {
            amount = amount.toString(16);
        }
        amount = this.pad64(amount);
        who = this.pad64(who);
        const transactionParameters = {
            to: to,
            from: from, 
            value: '0x0',
            data: '0x282d3fdf' + who + amount
        }
        if(!cb) {
            cb = function(e, v) {

            }
        }
        ethereum.sendAsync({method: 'eth_sendTransaction', params: [transactionParameters], from: from}, cb);
    },
    getBlockNumber: function() {
        return new Promise(function(resolve, reject){
            ethereum.sendAsync({method: 'eth_blockNumber', params: []}, function(e, v){
                if(e) {
                    reject(e);
                } else {
                    resolve(v);
                }
            }); 
        });
    },
    waitTx: function(txh) {
        let _this = this;
        
        return new Promise(async function(resolve, reject) {

            const loop = async function() {
                await _this.getTransactionReceipt(txh).then(async function(receipt){

                    //交易还没有产生回执时, receipt.result == null, 所以需要继续等待产生回执.
                    if(!receipt.result) { 
                        setTimeout(loop, 1000);
                        return;
                    }
                    
                    const rr = receipt.result;

                    //交易回执中的status表示交易成功(0x1)或失败(0x0), 如果失败, 则立即返回.
                    if (rr.status == 0x0) {
                        resolve(0); 
                    }   

                    /*rr.status == 0x1*/
                    
                    //产生交易回执并不等同于交易被确认, 只有当包含该交易的块被打包时才视为被第1个块确认.
    
                    const receiptBlockNumber = rr.blockNumber;
                    
                    await _this.getBlockNumber().then(function(v){

                        if(!v.result) {
                            reject(new Error("tx.getBlockNumber bad result: ", v));
                        }
                        
                        const blockNumber = parseInt(v.result);

                        //获取当前最新的块号与交易所在的块号对比, 如果两个块号相同则继续等待, 仅当至少有一个块被确认时才视为成功.
                        if(blockNumber - receiptBlockNumber >= 1) {
                            resolve(1);
                            return;
                        }
                        
                        setTimeout(loop, 1000); //setInterval 执行间隔存在不稳定性, 事件会被延迟或累积.

                    }).catch(function(e) {
                        reject(e);
                    });

                }).catch(function(e){
                    reject(e);
                })
            }

            loop();
        });
    }
}