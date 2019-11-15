#command arguments:
	# SCRIPT_DIR 部署脚本目录
	# SOURCE_DIR 源代码目录
	# BUILD_DIR 编译输出目录
	# EXPORTS 导出环境变量, 用于传递给部署脚本使用.
	# SOLC solidity 编译器
	# OUTPUT_DIR 部署输出文件

CC := $(SOLC)

modules = Join Stablecoin Govtoken Wallet Liquidauction Debtauction Govauction Feeder Debtor Collateral Forward

SOLCBUILD = $(CC) -o $(BUILD_DIR) $< || exit 1

VPATH = $(OUTPUT_DIR)

vpath %.abi $(BUILD_DIR)
vpath %.bin $(BUILD_DIR)
vpath %.sol $(SOURCE_DIR)

.PHONY: all
all: $(modules)
	$(SCRIPT_DIR)/export

Join : Join.bin Join.abi
	$(SCRIPT_DIR)/deployjoin || exit 1
Join.bin Join.abi: Join.sol Authority.sol
	$(SOLCBUILD)

Govtoken : Govtoken.bin Govtoken.abi
	$(SCRIPT_DIR)/deploygovtoken || exit 1
Govtoken.bin Govtoken.abi: Govtoken.sol Authority.sol
	$(SOLCBUILD)

Stablecoin : Stablecoin.bin Stablecoin.abi
	$(SCRIPT_DIR)/deploystablecoin || exit 1
Stablecoin.bin Stablecoin.abi: Stablecoin.sol Stderc20.sol Authority.sol
	$(SOLCBUILD)

Wallet: Wallet.bin Wallet.abi
	$(SCRIPT_DIR)/deploywallet || exit 1
Wallet.bin Wallet.abi: Wallet.sol Asset.sol Authority.sol
	$(SOLCBUILD)

Debtauction: Debtauction.bin Debtauction.abi Wallet
	$(SCRIPT_DIR)/deploydebtauction || exit 1
Debtauction.bin Debtauction.abi: Debtauction.sol
	$(SOLCBUILD)

Liquidauction: Liquidauction.bin Liquidauction.abi Wallet
	$(SCRIPT_DIR)/deployliquidauction || exit 1
Liquidauction.bin Liquidauction.abi: Liquidauction.sol
	$(SOLCBUILD)

Govauction: Govauction.bin Govauction.abi Wallet
	$(SCRIPT_DIR)/deploygovauction || exit 1
Govauction.bin Govauction.abi: Govauction.sol
	$(SOLCBUILD)

Feeder : Feeder.bin Feeder.abi
	$(SCRIPT_DIR)/deployfeeder || exit 1
	$(SCRIPT_DIR)/feeder_set || exit 1
Feeder.bin Feeder.abi: Feeder.sol Authority.sol
	$(SOLCBUILD)

Debtor : Debtor.bin Debtor.abi Stablecoin
	$(SCRIPT_DIR)/deploydebtor || exit 1
	$(SCRIPT_DIR)/debtor_tdc || exit 1
	# 仅为测试部署时授权
	$(SCRIPT_DIR)/stablecoin_approve_debtor || exit 1
Debtor.bin Debtor.abi: Debtor.sol Authority.sol
	$(SOLCBUILD)

Collateral: Collateral.bin Collateral.abi Debtor Wallet Liquidauction Join
	$(SCRIPT_DIR)/deploycollateral || exit 1
	$(SCRIPT_DIR)/collateral_setfer || exit 1
	$(SCRIPT_DIR)/collateral_setupp || exit 1
	$(SCRIPT_DIR)/collateral_setlow || exit 1
	$(SCRIPT_DIR)/collateral_setove || exit 1
	$(SCRIPT_DIR)/collateral_setseg || exit 1
	$(SCRIPT_DIR)/collateral_setgth || exit 1
	$(SCRIPT_DIR)/collateral_setfin || exit 1
	$(SCRIPT_DIR)/collateral_feed || exit 1
Collateral.bin Collateral.abi: Collateral.sol Authority.sol
	$(SOLCBUILD)

# 需要通过 token.approve 对新部署的forward授权

Forward: Forward.bin Forward.abi Collateral
	$(SCRIPT_DIR)/deployforward || exit 1
	# 仅为测试部署时授权.
	$(SCRIPT_DIR)/testoken_approve_forward || exit 1 
Forward.bin Forward.abi: Forward.sol
	$(SOLCBUILD)

.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.abi
	rm -f $(addprefix $(OUTPUT_DIR)/, $(modules))