const fs = require('fs');

const Manager = artifacts.require("Manager");
const Bridge = artifacts.require("Bridge");
const Token = artifacts.require("Token");

let deployconf = require("../deploy-config.json");

module.exports = async function(callback) {
    
    try {
        console.log("Deploy sidenet ...\n");
        console.log("Load deploy-config.json: \n", JSON.stringify(deployconf, null, 4), "\n");
    
        console.log("Mananger deploy with constructor arguments: \n[1]: ", deployconf.federators, '\n');
        const manager = await Manager.new(deployconf.federators);
        console.log('Manager success deployed at', manager.address, '\n');
        
        console.log("Token deploy with out argumtns\n");
        const token = await Token.new();
        console.log('Token success deployed at', token.address, '\n');

        console.log("Mananger deploy with constructor arguments: \n", 
                            "[1]: ", manager.address, '\n',
                            "[2]: ", token.address, '\n');
        const bridge = await Bridge.new(manager.address, token.address);
        console.log('Bridge success deployed at', bridge.address, '\n');
 
        console.log('Mananger set bridge: ', bridge.address, '\n');
        await manager.setBridge(bridge.address);

        console.log('Token set bridge: ', bridge.address, '\n');
        await token.setBridge(bridge.address);

        let blockNumber = await web3.eth.getBlockNumber().catch(function(e) {
            console.log("Ingore error within web3.eth.getBlockNumber: ", e);
        });
        let networkType = await web3.eth.net.getNetworkType().catch(function(e){
            console.log("Ingore error within web3.eth.net.getNetworkType: ", e);
        });
        let networkId = await web3.eth.net.getId().catch(function(e){
            console.log("Ingore error within web3.eth.net.getId: ", e);
        });

        let output = {};

        output.token = token.address || "undefined"
        output.bridge = bridge.address || "undefined";
        output.networkId = networkId.toString() || "NaN";
        output.networkType = networkType || "undefined";
        output.host = web3.currentProvider.host || "undefined";
        output.manager = manager.address || "undefined";
        output.startBlockNumber = blockNumber || "NaN";

        const outfile = deployconf.side.outfile;
        const outdir = deployconf.outdir;

        console.log("Test dir is exists: ", outdir);
        if(!fs.existsSync(outdir)) {
            console.log("Create dir: ", outdir);
            fs.mkdirSync(outdir);
        }

        const outpath = outdir + "/" + outfile;

        console.log('Write to: ', outpath, '\n', 
            JSON.stringify(output, null, 4), '\n');

        fs.writeFileSync(outpath, JSON.stringify(output, null, 4));

        console.log('Deploy success\n');
        callback(null);
    } catch(e) {
        console.log('Deploy fail\n');
        console.log(e);
        callback(e);
    }
}

