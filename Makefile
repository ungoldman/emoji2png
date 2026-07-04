TOOL = emoji2png
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
BUILDFLAGS = --disable-sandbox -c release --arch arm64 --arch x86_64
BINPATH = $(shell swift build $(BUILDFLAGS) --show-bin-path)/$(TOOL)

.PHONY: build install uninstall test clean

build:
	swift build $(BUILDFLAGS)

install: build
	mkdir -p "$(BINDIR)"
	install "$(BINPATH)" "$(BINDIR)/$(TOOL)"

uninstall:
	rm -f "$(BINDIR)/$(TOOL)"

test:
	swift test

clean:
	rm -rf .build
