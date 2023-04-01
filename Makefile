.PHONY: all install

all: install

install:
	@{ command -v pip >/dev/null && echo "Installing deps using pip" && PIP=pip; } \
	|| { command -v pip3 >/dev/null && echo "Installing deps using pip3" && PIP=pip3; } \
	|| { echo "Error: pip/pip3 not found" && exit 1; }; \
	$$PIP install "openai>=0.27"
