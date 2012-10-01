PROG=tt

all: $(PROG)

CFLAGS=-Wall -Wextra -pedantic -O3

SRCDIR=src
OBJDIR=obj
DEPDIR=dep
TESTDIR=test
TESTRESULTFILE=test_results

SRCS:=$(wildcard $(SRCDIR)/*.c)
DEPS:=$(SRCS:$(SRCDIR)/%.c=$(DEPDIR)/%.d)

MKDIR=mkdir -p
RMDIR=rmdir

#generated makefiles listing dependencies per source file
ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

clean:
	$(RM) $(PROG) $(OBJDIR)/* $(DEPDIR)/* $(TESTRESULTFILE)
	$(RMDIR) $(OBJDIR) $(DEPDIR)

test: $(TESTRESULTFILE)

#loop through each program running any corresponding tests
#save the individual test results and fail on any component failure
$(TESTRESULTFILE): $(PROG) $(TESTDIR)/*.sh $(TESTDIR)/.
	i=0; for p in $(PROG); do if [ -x "$$p" ]; then \
for t in $(TESTDIR)/"$$p"_*.sh; do if [ -f "$$t" ]; then \
sh "$$t" ./"$$p" 2>&1 > /dev/null; j=$$?; i=$$(( i | j )); \
echo "$$t	$$p	$$j"; fi; done; fi; done > $(TESTRESULTFILE); test 0 -eq $$i;

.PHONY: test clean

#pattern rules
#make an binary from its corresponding object file
%: $(OBJDIR)/%.o
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

#make an object file from its corresponding source file
$(OBJDIR)/%.o: $(SRCDIR)/%.c $(OBJDIR)
	$(COMPILE.c) $(OUTPUT_OPTION) $<

#make dependency file by parsing the corresponding source file
#not an ideal solution:
#providing a rule to make these causes them all to be built even if not needed
#could conditionally include, but that would be even uglier
#additionally, depending on the directory causes all to be rebuilt
$(DEPDIR)/%.d: $(SRCDIR)/%.c $(DEPDIR)
	$(CC) -MG -MM $< | sed -e 's|^|$@ $(OBJDIR)/|' > $@

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

$(DEPDIR):
	$(MKDIR) $(DEPDIR)
