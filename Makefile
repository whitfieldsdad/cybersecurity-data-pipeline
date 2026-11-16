DIAGRAMS := $(patsubst %.dot,%.png,$(wildcard docs/*.dot))

%.png: %.dot
	dot -Tpng $< -o $@

default: clean init

init:
	find . -type f -name "*.sh" -exec chmod +x {} \;

clean:
	find . -type f -name "._*" -delete

docs: $(DIAGRAMS)

.PHONY: default init clean docs
