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

all: cert
	@run-parts $(rparts_args) --exit-on-error --regex '^1[[:digit:]][[:digit:]]_' $(script_args) 1xx
	@run-parts $(rparts_args) --exit-on-error --regex '^2[[:digit:]][[:digit:]]_' $(script_args) 2xx

cert: OPENSSL_BIN := openssl
cert:	OPENSSL_CONF := $(CURDIR)/openssl.cnf
cert: clean
	@# prepare the OpenSSL CA directory structure
	echo ${OPENSSL_CONF}
	mkdir $(CURDIR)/testCA
	mkdir $(CURDIR)/testCA/private
	mkdir $(CURDIR)/testCA/newcerts
	mkdir $(CURDIR)/testCA/certs
	touch $(CURDIR)/testCA/index.txt
	touch $(CURDIR)/testCA/index.txt.attr
	echo "!!! CA IS FOR TESTING PURPOSE ONLY (INSECURE) !!!" | tee $(CURDIR)/testCA/__WARNING__
	echo 0000 | tee $(CURDIR)/testCA/serial
	@# create the CA private key.
	$(OPENSSL_BIN) genrsa -out $(CURDIR)/testCA/private/cakey.pem 1024
	@# create the self-signed CA certificate.
	$(OPENSSL_BIN) req -config $(OPENSSL_CONF) -new -x509 -extensions v3_ca -key $(CURDIR)/testCA/private/cakey.pem -out $(CURDIR)/testCA/cacert.pem -batch
	@# create the host cert request.
	$(OPENSSL_BIN) req -config $(OPENSSL_CONF) -new -newkey rsa:1024 -keyout $(CURDIR)/testCA/private/host_key.pem -out $(CURDIR)/testCA/certs/host_req.pem -batch
	@# sign the host cert request by the CA.
	$(OPENSSL_BIN) ca -config $(OPENSSL_CONF) -in $(CURDIR)/testCA/certs/host_req.pem -out $(CURDIR)/testCA/certs/host_crt.pem -batch

clean:
	[ ! -d $(CURDIR)/testCA ] || rm -rf $(CURDIR)/testCA
