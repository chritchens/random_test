ROOTS=C.fst
EXTRACT=C
ML_EXTRACT=$(addsuffix .ml,$(EXTRACT))
INCLUDE_PATHS=

# ------------------------------------------------------------------------------------

ifndef FSTAR_HOME
   $(error "Please define the `FSTAR_HOME` variable before including this makefile.")
endif

include $(FSTAR_HOME)/ulib/gmake/z3.mk
include $(FSTAR_HOME)/ulib/gmake/fstar.mk
include $(FSTAR_HOME)/ulib/ml/Makefile.include

# ------------------------------------------------------------------------------------

%.uver: %.fst
	$(FSTAR) --use_extracted_interfaces true $^

%.fail-uver: %.fst
	(! $(FSTAR) $^ >/dev/null 2>&1) || (echo "NEGATIVE TEST FAILED ($@)!" ; false)

# ------------------------------------------------------------------------------------

all: build

.depend:
	mkdir -p .cache
	$(FSTAR) --dep full $(ROOTS) $(addprefix --include ,$(INCLUDE_PATHS)) $(addprefix --extract ,$(ROOTS)) > .depend

depend: .depend

include .depend

clean:
	rm -rf .depend *.ml *.checked *~ .cache *.o *.cmi *.cmx *.cmxs *.exe *.out
	rm -rf $(EXTRACT)

OTHERFLAGS+=--record_hints --cache_dir .cache

%.fst.checked:
	$(FSTAR) $< --cache_checked_modules

%.fsti.checked:
	$(FSTAR) $< --cache_checked_modules

%.ml:
	$(FSTAR) --debug_level Extreme --use_extracted_interfaces true $(addprefix --include ,$(INCLUDE_PATHS)) --codegen OCaml --extract_module $(basename $(notdir $(subst .checked,,$<))) $(notdir $(subst .checked,,$<))

build: $(ML_EXTRACT)
