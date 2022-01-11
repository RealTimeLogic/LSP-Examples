


#General macros
EMPTY :=
SPACE := $(EMPTY) $(EMPTY)
#export AR
ifndef RANLIB
export RANLIB := ranlib
#export ARFLAGS
export AROFT := $(SPACE)
export CC := gcc
export CXX := g++
endif
export O := .o
export OFT := -o$(SPACE)
export LNKOFT := -o$(SPACE)
CFLAGS+=$(XCFLAGS)
CFLAGS+=-DB_LITTLE_ENDIAN
CFLAGS+=-Wall -c
ifeq (debug,$(build))
CFLAGS += -g
else
CFLAGS += -Os -O3
endif

ROOTD:=../../../..

ifndef PLAT
PLAT=Posix
CFLAGS+=-I$(ROOTD)/SMQ/src -I$(ROOTD)/SMQ/src/arch/Posix
EXTRALIBS += -lrt
endif

ifndef ODIR
ODIR = obj
endif

VPATH=.:$(ROOTD)/SMQ/src

# Implicit rules for making .o files from .c files
$(ODIR)/%$(O) : %.c
	$(CC) $(CFLAGS) $(OFT)$@ $<

SOURCE = bulb.c selib.c SMQClient.c
OBJS = $(SOURCE:%.c=$(ODIR)/%$(O))

ifeq ($(wildcard $(ROOTD)/SMQ/.*),)
$(error Directory $(ROOTD)/SMQ not found! See readme file)
endif

ifneq ($(wildcard $(ROOTD)/JSON/.*),)
VPATH += $(ROOTD)/JSON/src
SOURCE += AllocatorIntf.c\
	  BaAtoi.c\
	  BufPrint.c\
	  JDecoder.c\
	  JEncoder.c\
	  JParser.c\
	  JVal.c
CFLAGS += -I$(ROOTD)/JSON/inc -DUSE_JSON=1
$(info JSON directory found. Compiling with USE_JSON=1.)
else
$(info No JSON directory. Building without using JSON library.)
endif


.PHONY : example clean
example: $(ODIR) bulb$(EXT)

clean:
	rm -rf  $(ODIR) bulb$(EXT)

$(ODIR):
	mkdir $(ODIR)

bulb$(EXT): $(OBJS)
	$(CC) $(LNKOFT)$@ $(OBJS) $(EXTRALIBS)
