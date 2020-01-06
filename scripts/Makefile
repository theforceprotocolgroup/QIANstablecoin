#command arguments:
	# SCRIPT_DIR 部署脚本目录
	# SOURCE_DIR 源代码目录
	# BUILD_DIR 编译输出目录
	# EXPORTS 导出环境变量, 用于传递给部署脚本使用.
	# SOLC solidity 编译器
	# OUTPUT_DIR 部署输出文件
	# OPTSIONS 调用参数

CC := $(SOLC)

modules = Index Stablecoin Govtoken Wallet Feeder Debtor Collateral Forward

SOLCBUILD = $(CC) -o $(BUILD_DIR) $< || exit 1

vpath %.abi $(BUILD_DIR)
vpath %.bin $(BUILD_DIR)
vpath %.sol $(SOURCE_DIR)

.PHONY: all
all: $(modules)
	$(SCRIPT_DIR)/export

$(OUTPUT_DIR)/Index : Index.bin Index.abi
	$(SCRIPT_DIR)/deployindex || exit 1
Index.bin Index.abi: Index.sol Authority.sol
	$(SOLCBUILD)

$(OUTPUT_DIR)/Govtoken : Govtoken.bin Govtoken.abi
	$(SCRIPT_DIR)/deploygovtoken || exit 1
Govtoken.bin Govtoken.abi: Govtoken.sol Authority.sol
	$(SOLCBUILD)

$(OUTPUT_DIR)/Stablecoin : Stablecoin.bin Stablecoin.abi

Stablecoin.bin Stablecoin.abi: Stablecoin.sol Stderc20.sol Authority.sol
	$(SOLCBUILD)

$(OUTPUT_DIR)/Wallet: Wallet.bin Wallet.abi
	$(SCRIPT_DIR)/deploywallet || exit 1
Wallet.bin Wallet.abi: Wallet.sol Asset.sol Authority.sol
	$(SOLCBUILD)

$(OUTPUT_DIR)/Feeder : Feeder.bin Feeder.abi
	$(SCRIPT_DIR)/deployfeeder $(OPTSIONS) || exit 1
	# $(SCRIPT_DIR)/feeder_set || exit 1
Feeder.bin Feeder.abi: Feeder.sol Authority.sol
	$(SOLCBUILD)

$(OUTPUT_DIR)/Debtor : Debtor.bin Debtor.abi
	$(SCRIPT_DIR)/deploydebtor || exit 1
	$(SCRIPT_DIR)/debtor_tdc || exit 1
	# 仅为测试部署时授权
	# $(SCRIPT_DIR)/stablecoin_approve_debtor || exit 1
Debtor.bin Debtor.abi: Debtor.sol Authority.sol
	$(SOLCBUILD)

$(OUTPUT_DIR)/Collateral: Collateral.bin Collateral.abi Debtor Wallet Index
	$(SCRIPT_DIR)/deploycollateral $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setfer $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setupp $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setlow $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setove $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setseg $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setgth $(OPTSIONS) || exit 1
	$(SCRIPT_DIR)/collateral_setfin $(OPTSIONS) || exit 1
	# $(SCRIPT_DIR)/collateral_feed $(OPTSIONS) || exit 1
Collateral.bin Collateral.abi: Collateral.sol Authority.sol
	$(SOLCBUILD)

# 需要通过 token.approve 对新部署的forward授权

$(OUTPUT_DIR)/Forward: Forward.bin Forward.abi Collateral
	$(SCRIPT_DIR)/deployforward || exit 1
	# 仅为测试部署时授权.
	# $(SCRIPT_DIR)/testoken_approve_forward || exit 1 
Forward.bin Forward.abi: Forward.sol
	$(SOLCBUILD)

.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.abi
	rm -f $(addprefix $(OUTPUT_DIR)/, $(modules))