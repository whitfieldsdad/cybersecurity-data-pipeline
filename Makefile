DIAGRAMS := $(patsubst %.dot,%.png,$(shell find . -type f -name "*.dot" -not -path "./.git/*" -not -path "*/.venv/*" -not -path "*/node_modules/*"))

%.png: %.dot
	dot -Tpng $< -o $@

default: clean init docs

init:
	find . -type f -name "*.sh" -exec chmod +x {} \;

clean:
	find . -type f -name "._*" -delete

docs: $(DIAGRAMS)

.PHONY: default init clean docs
