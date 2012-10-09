# Copyright 2012 Carl D Hamann
#
# This file is part of tt.
#
# tt is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# tt is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with tt.  If not, see <http://www.gnu.org/licenses/>.

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

MAKEDEPEND=cc
MKDIR=mkdir
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

.SUFFIXES:

.SECONDARY:

#pattern rules
#make a binary from its corresponding object file
%: $(OBJDIR)/%.o
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

#make an object file from its corresponding source file
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR) $(DEPDIR)
	$(MAKEDEPEND) -MG -MM $< | sed -e 's|^|$(OBJDIR)/|' > $(DEPDIR)/$*.d
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

$(DEPDIR):
	$(MKDIR) $(DEPDIR)
