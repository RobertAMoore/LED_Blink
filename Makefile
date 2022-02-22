######################################
# target
######################################
TARGET = LED_Blink

######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -Og

#######################################
# paths
#######################################
BUILD_DIR = build
TEST_DIR = test
UNITY = tools/unity

######################################
# source files
######################################
C_SOURCES = \
Core/Src/main.c \
Core/Src/led.c \
Core/Src/stm32f3xx_it.c \
Core/Src/system_stm32f3xx.c

ASM_SOURCES =  \
startup_stm32f303xc.s

# Unit tests and framework source files
# Makefile breaks if TEST_SOURCES is left empty
TEST_SOURCES = PlaceHolder 
#$(UNITY)/src/unity.c \
#$(UNITY)/extras/fixture/src/unity_fixture.c

TEST_INCLUDES = 
#-I$(UNITY)/src \
#-I$(UNITY)/extras/fixture/src
#-I$(TEST_DIR)

#######################################
# binaries
#######################################
#Prefix for cross compiler
CROSS = arm-none-eabi-

CC = gcc
AS = gcc -x assembler-with-cpp
CP = objcopy
SZ = size

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
AS_DEFS =

C_DEFS =  \
-DSTM32F303xC \
-DUNITY_FIXTURE_NO_EXTRAS 

AS_INCLUDES =

C_INCLUDES =  \
-ICore/Inc \
-IDrivers/CMSIS

# target board properties
CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16
FLOAT-ABI = -mfloat-abi=hard

# add before CFLAGS when cross compiling
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

ASFLAGS = $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(C_DEFS) $(C_INCLUDES) $(TEST_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
	CFLAGS += -g -gdwarf-2
endif

# generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = STM32F303VCTx_FLASH.ld

# linker flags for cross compiling
LIBS = -lc -lm -lnosys
LIBDIR =
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

#######################################
# Build Application for target board
#######################################
# Does not build tests or test framework
target_build: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

# list of source code objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# add ASM derived objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

# Compile and Assemble source files into object files
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@ echo "compiling and assembling" $<
	@ $(CROSS)$(CC) -c $(MCU) $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

# Assemble ASM files into object files
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@ echo "assembling" $<
	@ $(CROSS)$(AS) -c $(MCU) $(CFLAGS) $< -o $@

# Link object files into single .elf
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	@ echo "linking object files"
	@ $(CROSS)$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@ $(CROSS)$(SZ) $@

# Objcopy .elf's into hex files
$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(CROSS)$(HEX) $< $@

# Objcopy .elf's into bin files
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(CROSS)$(BIN) $< $@

# Create build directory
$(BUILD_DIR):
	mkdir $@

#######################################
# Build unit tests to run on target
#######################################
# Source as static library use linker script
# compile framework + tests for arm
target_test: $(BUILD_DIR)/TargetTest.elf

# list of test objects
TEST_OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(TEST_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(TEST_SOURCES)))

# turn production object files into static lib then link with tests
$(BUILD_DIR)/TargetTest.elf: $(OBJECTS) $(TEST_OBJECTS) Makefile
	@ echo "creating library"
	@ $(CROSS)ar rcs $(BUILD_DIR)/libsource.a $(OBJECTS)
	@ echo "linking object files"
	@ $(CROSS)$(CC) $(TEST_OBJECTS) $(LDFLAGS) -L$(BUILD_DIR) -lsource -o $@
	@ $(CROSS)$(SZ) $@

#######################################
# Build unit tests for dev environment
#######################################
# source as static library + test framework + unit tests
native_test: $(BUILD_DIR)/test/NativeTest.elf
	./$(BUILD_DIR)/test/NativeTest.elf

OBJECTS_NT = $(addprefix $(BUILD_DIR)/test/,$(notdir $(C_SOURCES:.c=.o)))
TEST_OBJECTS_NT = $(addprefix $(BUILD_DIR)/test/,$(notdir $(TEST_SOURCES:.c=.o)))

# compile and assemble tests + framework + production code
$(BUILD_DIR)/test/%.o: %.c Makefile | $(BUILD_DIR) $(BUILD_DIR)/test
	@ echo "compiling and assembling" $<
	@ $(CC) -c $(CFLAGS) $< -o $@

# link tests into elf and use production code library
$(BUILD_DIR)/test/NativeTest.elf: $(OBJECTS_NT) $(TEST_OBJECTS_NT) Makefile
	@ echo "creating library"
	@ ar rcs $(BUILD_DIR)/test/libsource.a $(OBJECTS_NT)
	@ echo "linking object files"
	@ $(CC) $(TEST_OBJECTS_NT) -L$(BUILD_DIR)/test -lsource -o $@

$(BUILD_DIR)/test:
	mkdir $@

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
