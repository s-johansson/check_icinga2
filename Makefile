# Makefile for check_icinga2.sh automated tests.

###############################################################################

# This file is part of check_icinga2.
#
# check_icinga2, a monitoring plugin for (c) Icinga2.
#
# Copyright (C) 2017, Andreas Unterkircher <unki@netshadow.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

###############################################################################

PROGNAME := check_icinga2

.PHONY: all clean docs test
all:
	@echo "Thank you for invoking the Makefile of $(PROGNAME)"
	@echo
	@echo "The following make targets are available:"
	@echo
	@echo "make clean --- cleanup any residues that were left"
	@echo "make docs  --- generate the function-reference by using the shell-docs-generator"
	@echo "make test  --- startup the automated testing suite."
	@echo "make check --- perform syntax validation by Bash and shellcheck."

docs: clean FUNCREF.md

%.md:
	shell-docs-gen.sh -i $(PROGNAME).sh -o $@

clean:
	@rm -f FUNCREF.md

test:
	$(MAKE) -C tests v=1

check:
	@echo ">>> Performing syntax validation..."
	bash -n $(PROGNAME).sh
	@echo ">>> Now analysing and linting..."
	shellcheck -x -s bash $(PROGNAME).sh
	@echo ">>> This looks like a success!"
