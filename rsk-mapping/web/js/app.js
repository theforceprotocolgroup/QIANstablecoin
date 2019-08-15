
//Debugger
window.run_as_debug = true;

let debuger = {
    log: function (...args) {
        if (window.run_as_debug) {
            console.log(...args);
        }
    }
}

function DOMWapper () {

    let context = this;

    this.runtimeData = {
        balance: null,	/*balance*/
        allowance: null,	/*allowance*/
        bridge: null, /*bridge address*/
        token: null,	/*token address*/
        networkId: null, /*network Id*/

        setNetworkConf: function (networkId) {
            //debuger.log("conf: ", conf);

            this.networkId = networkId;

            if (networkId == conf.main.networkId) {
                this.bridge = conf.main.bridge;
                this.token = conf.main.token;
            }
            if (networkId == conf.side.networkId) {
                this.bridge = conf.side.bridge;
                this.token = conf.side.token;
            }
        }
    };

    this.window = {
        msgWindow: document.getElementById("msg-window"),
        msgWindowTitle: document.getElementById("msg-window-title"),
        msgWindowMsg: document.getElementById("msg-window-msg"),
        msgWindowBtn: document.getElementById("msg-window-btn"),

        showMsgWindow: function (title, msg, cb) {
            this.msgWindowTitle.innerHTML = title;
            this.msgWindowMsg.innerHTML = msg || "";
            this.msgWindowBtn.className = "btn";
            let _this = this;
            this.msgWindowBtn.onclick = function () {
                _this.msgWindow.className = "hidden";
                if (cb) cb();
            }
            this.msgWindow.className = "msg-window";
        },

        showMsgWindowWithoutBtn: function (title, msg) {
            this.msgWindowTitle.innerHTML = title;
            this.msgWindowMsg.innerHTML = msg || "";
            this.msgWindowBtn.onclick = null;
            this.msgWindowBtn.className = "hidden";
            this.msgWindow.className = "msg-window";
        },

        hiddenMsgWindow: function () {
            this.msgWindow.className = "hidden";
        }
    };

    this.mask = {
        ethereumMainnetMask: document.getElementById("ethereum-mainnet-mask"),
        rskMainnetMask: document.getElementById("rsk-mainnet-mask"),
        showEthereumMainnetMask: function (msg) {
            this.ethereumMainnetMask.innerHTML = msg;
            this.ethereumMainnetMask.className = "mask-show";
        },
        hiddenEthereumMainnetMask: function () {
            this.ethereumMainnetMask.className = "hidden";
        },
        showRskMainnetMask: function (msg) {
            this.rskMainnetMask.innerHTML = msg;
            this.rskMainnetMask.className = "mask-show";
        },
        hiddenRskMainnetMask: function () {
            this.rskMainnetMask.className = "hidden";
        }
    };


    this.info = {
        ethereumMainnetAccount: document.getElementById("ethereum-mainnet-account"),
        ethereumMainnetBalance: document.getElementById("ethereum-mainnet-balance"),
        rskMainnetAccount: document.getElementById("rsk-mainnet-account"),
        rskMainnetBalance: document.getElementById("rsk-mainnet-balance"),
        setEthereumMainnetAccount: function (account) {
            this.ethereumMainnetAccount.innerHTML = account;
        },
        setEthereumMainnetBalance: function (balance) {
            this.ethereumMainnetBalance.innerHTML = balance;
        },
        setRskMainnetAccount: function (account) {
            this.rskMainnetAccount.innerHTML = account;
        },
        setRskMainnetBalance: function (balance) {
            this.rskMainnetBalance.innerHTML = balance;
        },
        loadAccountBalance: function (selectedAddress, networkVersion) {
            debuger.log("selectedAddress: ", selectedAddress);
            debuger.log("networkVersion: ", networkVersion);

            //'1': Ethereum Main Network
            //'2': Morden Test network
            //'3': Ropsten Test Network
            //'4': Rinkeby Test Network
            //'42': Kovan Test Network
            switch (networkVersion) {
                case conf.main.networkId:
                    {
                        let _this = this;
                        tx.balanceOf(selectedAddress, context.runtimeData.token, function (e, v) {
                            _this.setEthereumMainnetAccount(selectedAddress);
                            if (e) {
                                debuger.log("tx.balanceOf error: ", e);
                                _this.setEthereumMainnetBalance("NaN");
                                return;
                            }

                            debuger.log("tx.balanceOf result:", v);
                            if (v.result) {
                                const balance = (Math.floor((parseInt(v.result.toString()) / 1000000000000000000) * 1000) / 1000).toFixed(3);
                                debuger.log("balance: ", balance);
                                _this.setEthereumMainnetBalance(balance);
                            } else {
                                debuger.log("Bad v.result");
                                _this.setEthereumMainnetBalance("NaN");
                            }
                        });
                    }
                    break;
                case conf.side.networkId:
                    {
                        let _this = this;
                        tx.balanceOf(selectedAddress, context.runtimeData.token, function (e, v) {
                            _this.setRskMainnetAccount(selectedAddress);
                            if (e) {
                                debuger.log("tx.balanceOf error: ", e);
                                _this.setRskMainnetBalance("NaN");
                                return;
                            }
                            debuger.log("tx.balanceOf result:", v);
                            if (v.result) {
                                const balance = (Math.floor((parseInt(v.result.toString()) / 1000000000000000000) * 1000) / 1000).toFixed(3);
                                debuger.log("balance: ", balance);
                                _this.setRskMainnetBalance(balance);
                            } else {
                                debuger.log("Bad v.result");
                                _this.setRskMainnetBalance("NaN");
                            }
                        });
                    }
                    break;
                default:
                    context.window.showMsgWindow("未知网络: " + networkVersion);
                    break;
            }
        }
    };

    this.guide = new function () {
        this.guideBlock = document.getElementById("guide-block");

        this.guideApproveCurrentBalance = document.getElementById("guide-approve-current-balance");

        this.guideApproveInput = document.getElementById("guide-approve-input");

        this.guideApproveCancelButton = document.getElementById("guide-approve-cancel");
        this.guideApproveNextButton = document.getElementById("guide-approve-next");

        this.guideTransferCurrentBalance = document.getElementById("guide-transfer-current-balance");

        this.guideAddressInput = document.getElementById("guide-address-input");
        this.guideBalanceInput = document.getElementById("guide-balance-input");

        this.guideMappingPrevButton = document.getElementById("guide-mapping-prev");
        this.guideMappingEndButton = document.getElementById("guide-mapping-end");

        this.guideNextAnimate = document.getElementById("guide-next-animate");

        let _this = this;

        this.showGuide = function () {
            this.guideBlock.className = "guide-block";
        }

        this.hiddenGuide = function () {
            this.guideApproveCurrentBalance.innerHTML = "NaN";
            this.guideApproveInput.value = "";
            this.guideTransferCurrentBalance.innerHTML = "NaN";

            this.guideAddressInput.value = "";
            this.guideBalanceInput.value = "";

            this.guideNextAnimate.style.left = 0;

            this.guideBlock.className = "hidden";
        }

        this.setGuideApproveCurrentBalance = function (balance) {
            this.guideApproveCurrentBalance.innerHTML = balance;
        }
        this.setGuideTransferCurrentBalance = function (balance) {
            this.guideTransferCurrentBalance.innerHTML = balance;
        }

        this.setFinishButton = function () {
            this.guideMappingEndButton.innerHTML = "完成";
            this.guideMappingEndButton.onclick = function () {
                _this.hiddenGuide();
            }
        }

        this.guideApproveCancelButton.onclick = function () {
            _this.hiddenGuide();
        }

        this.guideApproveNextButton.onclick = function () {
            let value = _this.guideApproveInput.value;

            let balance = parseInt(value);
            if (isNaN(balance)) {
                context.window.showMsgWindow("无效的输入: " + value);
                return;
            }

            if (balance > context.runtimeData.balance) {
                context.window.showMsgWindow("持有的余额不足!");
                return;
            }

            balance = balance * 1e18;
            debuger.log("Input balance: ", balance);
            
            tx.approve(ethereum.selectedAddress, context.runtimeData.token, context.runtimeData.bridge, balance.toString(16), async function (e, v) {
                if (e) {
                    debuger.log("tx.approve error: ", e);
                    context.window.showMsgWindow("交易失败!");
                    return;
                }

                debuger.log("tx.approve: ", v);

                const txh = v.result;
                if (!txh) {
                    context.window.showMsgWindow("交易失败!");
                    return;
                }

                context.window.showMsgWindowWithoutBtn("等待交易确认...", txh);

                //(阻塞)等待交易, 实际上就是等待 Promise
                let status = await tx.waitTx(txh).catch(function (e) {
                    debuger.log(e);
                });

                //如果没有发生异常的话, status 就是 0 或 1.
                if (!status) {
                    context.window.showWindow("交易失败!");
                    return;
                }

                context.window.showMsgWindow("交易成功!", null, function () {
                    $(_this.guideNextAnimate).animate({ left: "-100%" }, function () {
                        tx.allowance(ethereum.selectedAddress, context.runtimeData.token, context.runtimeData.bridge, function (e, v) {
                            if (e) {
                                debuger.log("tx.allowance error:", e);
                                _this.setGuideTransferCurrentBalance("NaN");
                                return;
                            }
                            debuger.log(v);

                            if (v.result) {
                                let balance = (Math.floor((parseInt(v.result.toString()) / 1000000000000000000) * 1000) / 1000).toFixed(3);
                                context.runtimeData.allowance = balance;
                                _this.setGuideTransferCurrentBalance(balance);
                            } else {
                                debuger.log("Bad v.result");
                                _this.setGuideTransferCurrentBalance("NaN");
                            }
                        });
                    });
                });
            });
        }

        this.guideMappingPrevButton.onclick = function () {
            $(_this.guideNextAnimate).animate({
                left: "0"
            });
        }

        this.guideMappingEndButton.onclick = function () {
            let value = _this.guideBalanceInput.value;
            const address = _this.guideAddressInput.value;

            let balance = parseInt(value);
            if (isNaN(balance)) {
                context.window.showMsgWindow("无效的输入: " + value);
                return;
            }

            if (balance > context.runtimeData.allowance) {
                context.window.showMsgWindow("授权的余额不足!");
                return;
            }

            if (address.substring(0, 2) == "0x" && address.length != 42) {
                context.window.showMsgWindow("目标地址格式错误!");
                return;
            }
            if (address.substring(0, 2) != "0x" && address.length != 40) {
                context.window.showMsgWindow("目标地址格式错误!");
                return;
            }

            balance = balance * 1e18;

            tx.mapping(ethereum.selectedAddress, context.runtimeData.bridge, address, balance.toString(16), async function (e, v) {
                if (e) {
                    debuger.log("tx.mapping error: ", e);
                    context.window.showWindow("交易失败!")
                    return;
                }

                debuger.log("tx.mapping: ", v);

                const txh = v.result;
                if (!txh) {
                    context.window.showMsgWindow("交易失败!");
                    return;
                }

                context.window.showMsgWindowWithoutBtn("等待交易确认...", txh);

                let status = await tx.waitTx(txh).catch(function (e) {
                    debuger.log(e);
                });

                if (!status) {
                    context.window.showWindow("交易失败!");
                    return;
                }

                context.window.showMsgWindow("交易成功!", null, function () {
                    _this.setFinishButton();
                });
            });
        }
    }

    this.mapping = new function () {
        this.mappingToRskButton = document.getElementById("mapping-to");
        this.mappingFromRskButton = document.getElementById("mapping-from");

        this.mappingFromRskButton.onclick = async function () {

            const provider = window.ethereum;

            if (!provider) {
                context.window.showMsgWindow("请先安装 MetaMask 插件!");
                return;
            }

            if (!web3.eth.coinbase) {
                context.window.showMsgWindow("请先连接或解锁 MetaMask 钱包!");
                return;
            }

            if (provider.networkVersion != 42) {
                context.window.showMsgWindow("请先将MetaMask切换到RSK网络!");
                return;
            }

            context.guide.showGuide();

            tx.balanceOf(window.ethereum.selectedAddress, context.runtimeData.token, function (e, v) {
                if (e) {
                    debuger.log("tx.balanceOf error: ", e);
                    context.guide.setGuideApproveCurrentBalance("NaN");
                    return;
                }
                debuger.log("tx.balanceOf result:", v);
                if (v.result) {
                    const balance = (Math.floor((parseInt(v.result.toString()) / 1000000000000000000) * 1000) / 1000).toFixed(3);
                    context.runtimeData.balance = balance;
                    debuger.log("balance: ", balance);
                    context.guide.setGuideApproveCurrentBalance(balance + " RFOR");
                } else {
                    debuger.log("Bad v.result: ", v);
                    context.guide.setGuideApproveCurrentBalance("NaN");
                }
            });
        }
        this.mappingToRskButton.onclick = async function () {

            const provider = window.ethereum;

            if (!provider) {
                context.window.showMsgWindow("请先安装 MetaMask 插件!");
                return;
            }

            if (!web3.eth.coinbase) {
                context.window.showMsgWindow("请先连接或解锁 MetaMask 钱包!");
                return;
            }

            if (provider.networkVersion != 4) {
                context.window.showMsgWindow("请先将MetaMask切换到以太坊网络");
                return;
            }

            context.guide.showGuide();

            tx.balanceOf(window.ethereum.selectedAddress, context.runtimeData.token, function (e, v) {
                if (e) {
                    debuger.log("tx.balanceOf error: ", e);
                    context.guide.setGuideApproveCurrentBalance("NaN");
                    return;
                }
                debuger.log("tx.balanceOf result:", v);
                if (v.result) {
                    const balance = (Math.floor((parseInt(v.result.toString()) / 1000000000000000000) * 1000) / 1000).toFixed(3);
                    context.runtimeData.balance = balance;
                    debuger.log("balance: ", balance);
                    context.guide.setGuideApproveCurrentBalance(balance + " FOR");
                } else {
                    debuger.log("Bad v.result");
                    context.guide.setGuideApproveCurrentBalance("NaN");
                }
            });
        }
    }
}

window.addEventListener('load', function () {
    let domWapper = new DOMWapper();
    if (typeof window.ethereum !== 'undefined' || (typeof window.web3 !== 'undefined')) {
        if (window.ethereum.isMetaMask) {	//目前暂时仅支持MetaMask
            //const provider = window['ethereum'] || window.web3.currentProvider;

            if (!web3.eth.coinbase) {
                domWapper.mask.showEthereumMainnetMask("请先连接或解锁 MetaMask 钱包!");
                domWapper.mask.showRskMainnetMask("请先连接或解锁 MetaMask 钱包!");
            }

            window.ethereum.enable().then(function (accounts) {
                const selectedAddress = accounts[0];
                const networkId = window.ethereum.networkVersion;
                console.log("selectedAddress: ", selectedAddress);
                console.log("networkId: ", networkId);

                domWapper.runtimeData.setNetworkConf(networkId);
                domWapper.info.loadAccountBalance(selectedAddress, networkId);

                window.ethereum.on('accountsChanged', function (accounts) {
                    debuger.log("accountsChanged: ", accounts);
                    let selectedAddress = accounts[0];
                    const networkId = window.ethereum.networkVersion;
                    domWapper.info.loadAccountBalance(selectedAddress, networkId);
                });

                window.ethereum.on("networkChanged", function (networkId) {
                    debuger.log("networkChanged: ", networkId);
                    domWapper.runtimeData.setNetworkConf(networkId);
                    const selectedAddress = window.ethereum.selectedAddress;
                    domWapper.info.loadAccountBalance(selectedAddress, networkId);
                });

                domWapper.mask.hiddenEthereumMainnetMask();
                domWapper.mask.hiddenRskMainnetMask();
            }).catch(function (err) {
                debuger.log("window.ethereum.enable() catch: ", err);
            });
        } else {
            domWapper.mask.showEthereumMainnetMask("请先安装 MetaMask 插件!");
            domWapper.mask.showRskMainnetMask("请先安装 MetaMask 插件!");
            return;
        }
    } else {
        domWapper.mask.showEthereumMainnetMask("请先安装 MetaMask 插件!");
        domWapper.mask.showRskMainnetMask("请先安装 MetaMask 插件!");
        return;
    }
});