# Makefile – build riscv-tests ISA tests for the kyson RV32I core.
#
# Outputs land in tests/build/ as <test>.elf and <test>.hex.
# Run from the repository root:
#   make -f tests/Makefile          # build all tests
#   make -f tests/Makefile clean    # remove build artefacts
#
# Prerequisites:
#   riscv64-unknown-elf-as / ld / objcopy  (binutils; no gcc needed)
#   cpp                                    (system C pre-processor)
#   python3

RISCV_PREFIX  ?= riscv64-unknown-elf-
AS             = $(RISCV_PREFIX)as
LD             = $(RISCV_PREFIX)ld
PYTHON         = python3
CPP            = cpp

REPO_ROOT     := $(patsubst %/tests/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TESTS_DIR     := $(REPO_ROOT)/tests
BUILD_DIR     := $(TESTS_DIR)/build
ENV_DIR       := $(TESTS_DIR)/env/p
RISCV_TESTS   := $(TESTS_DIR)/riscv-tests
MACROS_DIR    := $(RISCV_TESTS)/isa/macros/scalar
RV32UI_DIR    := $(RISCV_TESTS)/isa/rv32ui

# Pre-processor flags
CPPFLAGS = -E -x assembler-with-cpp \
           -I$(ENV_DIR) \
           -I$(MACROS_DIR) \
           -D__riscv_xlen=32

# Assembler flags
ASFLAGS  = -march=rv32i -mabi=ilp32

# Linker flags
LDFLAGS  = -m elf32lriscv -T$(ENV_DIR)/link.ld

# All rv32ui test sources; skip tests that need features the core lacks:
#   fence_i  – requires FENCE.I
#   ld_st / ma_data / st_ld – rv64 or misalignment tests
SKIP    := fence_i ld_st ma_data st_ld
ALL_SRC := $(wildcard $(RV32UI_DIR)/*.S)
SRCS    := $(filter-out $(addprefix $(RV32UI_DIR)/,$(addsuffix .S,$(SKIP))),$(ALL_SRC))
TESTS   := $(patsubst $(RV32UI_DIR)/%.S,%,$(SRCS))
ELFS    := $(addprefix $(BUILD_DIR)/rv32ui-p-,$(addsuffix .elf,$(TESTS)))
HEXS    := $(ELFS:.elf=.hex)

.PRECIOUS: $(BUILD_DIR)/rv32ui-p-%.pp.s $(BUILD_DIR)/rv32ui-p-%.o $(BUILD_DIR)/rv32ui-p-%.elf

.PHONY: all clean list

all: $(HEXS)
	@echo ""
	@echo "Built $(words $(HEXS)) test(s) in $(BUILD_DIR)/"

# -----------------------------------------------------------------------
# 1. Pre-process  (.S → .pp.s)
# -----------------------------------------------------------------------
$(BUILD_DIR)/rv32ui-p-%.pp.s: $(RV32UI_DIR)/%.S | $(BUILD_DIR)
	@$(CPP) $(CPPFLAGS) $< -o $@

# -----------------------------------------------------------------------
# 2. Assemble  (.pp.s → .o)
# -----------------------------------------------------------------------
$(BUILD_DIR)/rv32ui-p-%.o: $(BUILD_DIR)/rv32ui-p-%.pp.s
	@$(AS) $(ASFLAGS) $< -o $@

# -----------------------------------------------------------------------
# 3. Link  (.o → .elf)
# -----------------------------------------------------------------------
$(BUILD_DIR)/rv32ui-p-%.elf: $(BUILD_DIR)/rv32ui-p-%.o
	@$(LD) $(LDFLAGS) $< -o $@

# -----------------------------------------------------------------------
# 4. Hex  (.elf → .hex)
# -----------------------------------------------------------------------
$(BUILD_DIR)/rv32ui-p-%.hex: $(BUILD_DIR)/rv32ui-p-%.elf
	@$(PYTHON) $(TESTS_DIR)/elf2hex.py $< $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# -----------------------------------------------------------------------
# Handy targets
# -----------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR)

list:
	@echo $(TESTS) | tr ' ' '\n'
