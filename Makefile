ROOTS=Main.fst Main2.fst
EXTRACT=Main Main2 Lib A B
ML_EXTRACT=$(addsuffix .ml,$(EXTRACT))
INCLUDE_PATHS=others
INCLUDE_PATHS_FILES=$(foreach dir,$(INCLUDE_PATHS),$(wildcard $(dir)/*.fst $(dir)/*.fsti))
SUBDIR_PATHS=others
SUBDIR_PATHS_FILES=$(foreach dir,$(SUBDIR_PATHS),$(wildcard $(dir)/*.ml))

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

clean-subdirs:
	@for dir in $(SUBDIR_PATHS); \
	do \
		$(MAKE) -C $$dir clean; \
	done

clean: clean-subdirs
	rm -rf .depend *.ml *.checked *~ .cache *.o *.cmi *.cmx *.exe *.out
	rm -rf $(EXTRACT)

OTHERFLAGS+=--record_hints --cache_dir .cache $(addprefix --include ,$(INCLUDE_PATHS))

%.fst.checked:
	$(FSTAR) $< --cache_checked_modules

%.fsti.checked:
	$(FSTAR) $< --cache_checked_modules

%.ml:
	$(FSTAR) --use_extracted_interfaces true --codegen OCaml --extract_module $(basename $(notdir $(subst .checked,,$<))) $(notdir $(subst .checked,,$<))

build-subdirs:
	@for dir in $(SUBDIR_PATHS); \
	do \
		$(MAKE) -C $$dir; \
	done

build: build-subdirs $(ML_EXTRACT)
	@for root in $(EXTRACT); \
	do \
		$(OCAMLOPT) $(addsuffix .ml,$$root) $(addprefix -I ,$(SUBDIR_PATHS)) -o $$root; \
	done

rebuild:
	make clean
	make build
