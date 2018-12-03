.PHONY: all

ifeq (,$(value out))
.PHONY: doc

all: doc

doc:
	@ install -m755 $$(nix-build -A drv --no-out-link)/* -Dt $@/
else
.PHONY: clean clobber watch

LATEXMKFLAGS := -pdfxe -Werror
ifneq (,$(findstring B,${MAKEFLAGS}))
LATEXMKFLAGS += -gg
endif

%.pdf: %.tex
	@ latexmk ${LATEXMKFLAGS} $*

all: exercises.pdf

clean:
	@ latexmk -c

clobber:
	@ latexmk -C

watch:
	@ latexmk ${LATEXMKFLAGS} -pvc -new-viewer-
endif
