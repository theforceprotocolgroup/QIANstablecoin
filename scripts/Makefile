#command arguments:
	# SCRIPT_DIR 部署脚本目录
	# SOURCE_DIR 源代码目录
	# BUILD_DIR 编译输出目录
	# EXPORTS 导出环境变量, 用于传递给部署脚本使用.
	# SOLC solidity 编译器
	# OUTPUT_DIR 部署输出文件

CC := $(SOLC)

modules = feeder stablecoin govtoken debtor ceth ctoken

SOLCBUILD = $(CC) -o $(BUILD_DIR) $< || exit 1

VPATH = $(OUTPUT_DIR)

vpath %.abi $(BUILD_DIR)
vpath %.bin $(BUILD_DIR)
vpath %.sol $(SOURCE_DIR)

.PHONY: all
all: $(modules)
	$(SCRIPT_DIR)/export

feeder : feeder.bin feeder.abi
	$(SCRIPT_DIR)/deployfeeder || exit 1
	$(SCRIPT_DIR)/feeder_set -t TES || exit 1
feeder.bin feeder.abi: feeder.sol authority.sol
	$(SOLCBUILD)

stablecoin : stablecoin.bin stablecoin.abi
	$(SCRIPT_DIR)/deploystablecoin || exit 1
stablecoin.bin stablecoin.abi: stablecoin.sol stderc20.sol authority.sol
	$(SOLCBUILD)

govtoken : govtoken.bin govtoken.abi
	$(SCRIPT_DIR)/deploygovtoken || exit 1
govtoken.bin govtoken.abi: govtoken.sol authority.sol arith.sol
	$(SOLCBUILD)

debtor : debtor.bin debtor.abi stablecoin govtoken
	$(SCRIPT_DIR)/deploydebtor || exit 1
	$(SCRIPT_DIR)/debtor_tdc || exit 1

debtor.bin debtor.abi: debtor.sol authority.sol arith.sol
	$(SOLCBUILD)

ceth : ceth.bin ceth.abi debtor
	$(SCRIPT_DIR)/deployceth || exit 1
ceth.bin ceth.abi: ceth.sol collateral.sol authority.sol arith.sol
	$(SOLCBUILD)

ctoken : ctoken.bin ctoken.abi debtor
	$(SCRIPT_DIR)/deployctoken || exit 1
	$(SCRIPT_DIR)/ctoken_setfer -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_setupp -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_setlow -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_setove -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_setseg -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_setgth -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_setfin -t TES || exit 1
	$(SCRIPT_DIR)/ctoken_feed -t TES || exit 1
	$(SCRIPT_DIR)/testoken_approve -t TES || exit 1

ctoken.bin ctoken.abi: ctoken.sol collateral.sol authority.sol arith.sol
	$(SOLCBUILD)

.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/*.bin $(BUILD_DIR)/*.abi
	rm -f $(addprefix $(OUTPUT_DIR)/, $(modules))
