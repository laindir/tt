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

MAKEFILE:=$(lastword $(MAKEFILE_LIST))

PROG=tt

all: $(PROG)

CFLAGS=-Wall -Wextra -pedantic -O3
MAKEDEPENDSFLAGS=-MMD -MP

SRCDIR=src
OBJDIR=obj
TESTDIR=test
TESTRESULTFILE=test_results

OBJS:=$(wildcard $(OBJDIR)/*.o)
DEPS:=$(OBJS:%.o=%.d)

MKDIR=mkdir
RMDIR=rmdir

#generated makefiles listing dependencies per source file
-include $(DEPS)

clean:
	$(RM) $(PROG) $(OBJDIR)/* $(TESTRESULTFILE)
	$(RMDIR) $(OBJDIR)

test: $(TESTRESULTFILE)

#loop through each program running any corresponding tests
#save the individual test results and fail on any component failure
$(TESTRESULTFILE): $(PROG) $(TESTDIR)/*.sh $(TESTDIR)/.
	i=0; for p in $(PROG); do if [ -x "$$p" ]; then \
for t in $(TESTDIR)/"$$p"_*.sh; do if [ -f "$$t" ]; then \
sh "$$t" ./"$$p" 2>&1 > /dev/null; j=$$?; i=$$(( i | j )); \
echo "$$t	$$p	$$j"; fi; done; fi; done > $(TESTRESULTFILE); test 0 -eq $$i;

.PHONY: $(MAKEFILE) all test clean

.SUFFIXES:

.SECONDARY:

#pattern rules
#make a binary from its corresponding object file
%: $(OBJDIR)/%.o
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

#make an object file from its corresponding source file
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(COMPILE.c) $(MAKEDEPENDSFLAGS) $(OUTPUT_OPTION) $<

$(OBJDIR):
	$(MKDIR) $(OBJDIR)

#cancel some implicit rules
%:: %,v

%:: RCS/%,v

%:: RCS/%

%:: s.%

%:: SCCS/s.%
