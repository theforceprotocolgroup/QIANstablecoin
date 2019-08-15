const assert = require("assert");

const logger = require("./logger");
const Tx = require("./tx");
const Bridge = require("./bridge");
const Manager = require("./manager");


function Federator(mainconf, sideconf, federator) {

    const mainBridgeAddress = '0x' + mainconf.bridge.substr(2).padStart(64, 0).toLowerCase();
    const transferEventHash = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
    
    this.address = federator.address;
    this.pkey = federator.pkey;
    
    this.mainTx = new Tx(mainconf.host);
    this.sideTx = new Tx(sideconf.host);

    this.mainBridge = new Bridge(this.mainTx, mainconf.bridge);
    this.sideManager = new Manager(this.sideTx, sideconf.manager);

    this.confirmations = mainconf.confirmations;
    this.interval = mainconf.interval;
    this.mainToken = mainconf.token;

    this.vote = async function(log) {

        logger.info("vote argument log: ", log);

        const from = log.topics[1];
        const to = log.topics[2];
        const amount = log.data;

        logger.info('transfer from: ', from);
        logger.info('transfer to: ', to);
        logger.info('transfer amount: ', amount);
        logger.info('transaction hash', log.transactionHash);

        const receiver = await this.mainBridge.maps(from, {from: this.address}).catch(function(err){
            logger.error("mainBridge.maps error: ", err);
        });
        
        logger.info("vote: mainBridge.maps: \n", 
            "from: ", from, '\n',
            "receiver: " + receiver);

        if(receiver == "0x") { //0x
            logger.error("mainBridge.maps: receiver is address(0)");
            return;
        }

        const processed = await this.sideManager.processed(log.transactionHash, receiver, amount, { from: this.address }).catch(function(err){
            logger.error("sideManager.processed error: ", err);
        });

        logger.info("vote: sideManager.processed: \n",
            "msg.sender: ", this.address, '\n',
            "processed: " + processed);
        
        if (processed != "0x" && parseInt(processed) != 0) {
            logger.warn('Transaction already processed');
            return;
        }

        await this.sideManager.vote(log.transactionHash,
                                    receiver, 
                                    amount, 
                                    {from: this.address, pkey: this.pkey}
                                    ).catch(function(err) {
            logger.error("sideManager.vote error: ", err);
        });
        
        logger.info("sideManager.vote: \n",
            "msg.sender: ", this.address, '\n',
            "receiver: " + receiver, '\n',
            "amount: " + amount);
    }

    this.work = async function(beginBlockNumber, endBlockNumber) {
        logger.info("work: beginBlockNumber: " + beginBlockNumber 
            + ", endBlockNumber: ", endBlockNumber);
        
        if(endBlockNumber > beginBlockNumber) {

            let beginBlockNumberHex = beginBlockNumber.toString(16);
            let endBlockNumberHex = endBlockNumber.toString(16);
            
            beginBlockNumberHex = "0x" + ((beginBlockNumberHex.length % 2)
                ? "0" + beginBlockNumberHex : beginBlockNumberHex);
            endBlockNumberHex =  "0x" + ((endBlockNumberHex.length % 2) 
                ? "0" + endBlockNumberHex : endBlockNumberHex); 
            
            const logs = await this.mainTx.getLogs(this.mainToken, 
                                                    beginBlockNumberHex,
                                                    endBlockNumberHex, 
                                                    [ transferEventHash ]
                                                    ).catch(function(err) {
                logger.error("mainTx.getLogs: ", err);
            });
            
            //logger.info(logs);
            
            for (let k = 0; k < logs.length; k++) {
                const log = logs[k];
                
                if (log.topics[2] !== mainBridgeAddress)
                    continue;

                await this.vote(log);
            }
        } else {
            endBlockNumber = beginBlockNumber;
        }

        const _this = this;
        logger.info("wait... " + this.interval + " ms");
        setTimeout(function() {
            _this.loop(endBlockNumber);
        }, this.interval);
    }

    this.loop = async function(beginBlockNumber) {
        logger.info("loop: beginBlockNumber: " + beginBlockNumber);
        const blockNumber = await this.mainTx.getBlockNumber().catch(function(e){
            logger.error("mainTx.getBlockNumber error: ", e);
        });
        
        logger.info("loop: mainTx.getBlockNumber: " + blockNumber);

        let endBlockNumber;
        if(blockNumber) {
            endBlockNumber = blockNumber - this.confirmations;
        } else {
            endBlockNumber = beginBlockNumber;
        }
        this.work(beginBlockNumber, endBlockNumber);
    }
}

function main() {

    assert(process.argv.length == 4, 
        "Require args: <config-file> <federator-id>");

    const confile = process.argv[2];
    const federatorId = process.argv[3];
        
    logger.info("Command arguments: ", process.argv);

    logger.info("Configfile: ", confile);
    
    const conf = require(confile);
    logger.info("Load config file: ", conf);
     
    const mainconf = conf.main;
    const sideconf = conf.side;

    assert(federatorId < conf.federators.length, 
        "Require federatorId < conf.federator.length");
    
    assert(mainconf.startBlockNumber >= 0, 
        "Require main.startBlockNumber >= 0");

    let federator = new Federator(mainconf, sideconf, conf.federators[federatorId]);

    federator.loop(mainconf.startBlockNumber);
}

main();