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


script_args :=
rparts_args := --report

ifdef v
   rparts_args := --report --verbose
endif

ifdef d
   script_args := -a--debug
   rparts_args := --verbose
endif

.PHONY: all

all:
	@run-parts $(rparts_args) --exit-on-error --regex '^1[[:digit:]][[:digit:]]_' $(script_args) 1xx
	@run-parts $(rparts_args) --exit-on-error --regex '^2[[:digit:]][[:digit:]]_' $(script_args) 2xx
