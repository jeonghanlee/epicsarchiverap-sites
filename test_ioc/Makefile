TOP = $(CURDIR)

TEST_ONE = $(TOP)/myExample
TEST_TWO = $(TOP)/Tr3

TARGETS = $(TEST_ONE) $(TEST_TWO)

.PHONY: all clean $(TARGETS) 

all: $(TARGETS)

$(TARGETS):
	@$(MAKE) -C $@;

clean:
	$(MAKE) -C $(TEST_ONE) clean
	$(MAKE) -C $(TEST_TWO) clean

distclean: clean
