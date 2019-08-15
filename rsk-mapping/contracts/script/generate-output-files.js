const fs = require('fs');
const util = require('util')
const deployconf = require("../deploy-config.json");

const outdir = deployconf.outdir;

const mainoutfile = outdir + '/' + deployconf.main.outfile;
const sideoutfile = outdir + '/' + deployconf.side.outfile;

console.log("Test is exists: ", mainoutfile);
if(!fs.existsSync(mainoutfile)) {
    throw new Error("Deploy output file for mainnet is not exists: ", mainoutfile);
}

console.log("Test is exists: ", sideoutfile);
if(!fs.existsSync(sideoutfile)) {
    throw new Error("Deploy output file for sidenet is not exists: ", sideoutfile);
}

const mainconf = require("../" + mainoutfile);
console.log("Load mainnet deploy output file: \n", 
    JSON.stringify(mainconf, null, 4), "\n");

const sideconf = require("../" + sideoutfile);
console.log("Load sidenet deploy output file: \n", 
    JSON.stringify(sideconf, null, 4), "\n");

let clientconf = {
    main: {},
    side: {},
};

clientconf.main.token = mainconf.token;
clientconf.main.bridge = mainconf.bridge;
clientconf.main.networkId = mainconf.networkId;

clientconf.side.token = sideconf.token;
clientconf.side.bridge = sideconf.bridge;
clientconf.side.networkId = sideconf.networkId;

const clientoutpath = outdir + '/client-conf.js';

console.log("Generate output '" + clientoutpath + "'for client: \n", 
    util.inspect(clientconf), '\n');

fs.writeFileSync(clientoutpath, 
    `const conf = ${util.inspect(clientconf)}`, 
    "utf-8");

let serverconf = {
    main: {},
    side: {}
};

serverconf.main = mainconf;
serverconf.main.confirmations = 12;
serverconf.main.interval = 30000; //30s;

serverconf.side = sideconf;
serverconf.side.confirmations = 12;
serverconf.side.interval = 30000; //30s;

let federators = [];

for(let i = 0, n = deployconf.federators.length; i < n; ++i) {
    federators.push({pkey: "0x", address: deployconf.federators[i]});
}

serverconf.federators = federators;

const serveroutpath = outdir + '/server-conf.json';

console.log("Generate output '" + serveroutpath + "' for server: \n", 
    JSON.stringify(serverconf, null, 4), '\n');

fs.writeFileSync(serveroutpath,
    JSON.stringify(serverconf, null, 4));

console.log('Generate success\n');


