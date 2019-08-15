const Manager = artifacts.require("Manager");
const Bridge = artifacts.require("Bridge");
const SideToken = artifacts.require("SideToken");

module.exports = function(deployer, network) {
    if(network == "main") { //rinkeby
      //...
    }

    if(network == "side") { //kovan
      //...
    }
};
