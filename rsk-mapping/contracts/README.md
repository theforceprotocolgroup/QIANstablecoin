## FOR映射到RSK网络的合约部分

### 文件和目录:

+ build 通过truffle编译产生的ABI文件
+ migrations truffle部署文件 暂未使用.
+ output 导出的部署信息
+ src 合约源码
+ script 部署脚本
+ deploy-config.json 部署配置
+ truffle-config.js truffle配置
+ deploy.sh 总部署脚本.


### 部署流程

1. 确保truffle已经安装.

如果没有安装需要先执行

`npm install -g truffle`

2. 下载node modules

在 `contracts` 目录下执行

`npm install`

3. 导出环境变量

`
export MAIN_OWNER_PRIVATE_KEY="0x..."
export SIDE_OWNER_PRIVATE_KEY="0x..."
export MAIN_NETWORK_HOST="https://rinkeby.infura.io/v3/1eea4d6e882747cdbc5c8fee6a407467"
export SIDE_NETWORK_HOST="https://kovan.infura.io/v3/1eea4d6e882747cdbc5c8fee6a407467"
`

其中`MAIN_OWNER_PRIVATE_KEY`将作为部署主网合约的msg.sender, `SIDE_OWNER_PRIVATE_KEY`将被作为部署侧网合约的msg.sender. 这两个账户可以是一个. 这个账户非常重要, 可以影响整个系统的运行, 最好在部署完成后执行 `unset MAIN_OWNER_PRIVATE_KEY` 和 `unset SIDE_OWNER_PRIVATE_KEY`;

4. 修改部署配置文件 deploy-config.json

`
{
    "main": {
        "token": "0x...",
        "outfile": "output-for-deploy-main.json"
    },
    "side": {
        "outfile": "output-for-deploy-side.json"
    },
    "federators": ["0x..."],
    "outdir": "output"
}
`

主要字段包括:

+ `main.token`, 因为目前系统的目的是对已存在的代币进行网络映射, 所以必须是存在一个待映射的代币合约。
+ `main.outfile`, 主网部署完成后的导出文件名
+ `side.outfile`, 侧网部署完成后的导出文件名
+ `federators`, federator的地址.
+ `outdir`, 部署导出文件路径

5. 修改truffle-config.js

配置部署网络信息

6. 执行 deploy.sh 

如果执行成功, 会在`outdir`指定的目录中生成相应的文件:

+ output-for-client.json         生成为前端使用的配置文件
+ output-for-server.json         生成为后端事件监听服务使用的配置文件.
+ output-for-deploy-side.json    中间文件, 部署侧网生成的配置文件
+ output-for-deploy-main.json    中间文件, 部署主网生成的配置文件

