# Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

SETUP=setup.sh
GOHERE=$(shell which go-here)

.PHONY: all install uninstall

all: install

install:
ifeq (,$(wildcard ./$(SETUP)))
	@echo "Setup file is missing!"
else
	@echo "Prearing to install Go Here on your system..."
	@chmod +x $(SETUP) && ./$(SETUP)
	@echo "Successfully installed Go Here!"
endif

uninstall:
ifeq ($(GOHERE),)
	@echo "Go Here is not installed."
else
	@echo "For safety reasons, auto uninstall is not available."
	@echo "You can remove Go Here by deleting the following file at your own risk:"
	@echo ""
	@echo "  $(GOHERE)"
	@echo ""
	@echo "Have a nice day!"
endif
