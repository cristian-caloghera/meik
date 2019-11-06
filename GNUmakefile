# Copyright (c) 2013 Cristian Caloghera
#
# This software is released under the MIT license:
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Except as contained in this notice, the name(s) of the above
# copyright holders shall not be used in advertising or otherwise to
# promote the sale, use or other dealings in this Software without
# prior written authorization.

# Version: 2.0.3

# do not use make's built-in rules
# this increases performance and makes debugging easier
MAKEFLAGS += -r

# defaults for popular variables
# for a complete list of variables see:
# http://www.gnu.org/software/make/manual/make.html#Implicit-Variables

# flags for archive maintaining program
ARFLAGS ?= -cr

# flags for the C compiler
CFLAGS ?= -Wall -Wextra

# flags for the C++ compiler
CXXFLAGS ?= -Wall -Wextra

# flags for the C/C++ pre-processor
CPPFLAGS ?=

# default to the C++ compiler as defined by the CXX variable
meik_compiler ?= ${CXX}

# default to the C++ linker as defined by the CXX variable
meik_linker ?= ${CXX}

# a recursive variant of wildcard
# multiple search locations are supported, also multiple patterns
# $(call meik_rwildcard, d1 d2, *.txt *.zip)
# will find all txt and zip files in the d1 and d2 directories
meik_rwildcard = $(strip $(foreach d,$(filter %/,$(wildcard $(addsuffix /,$1))),$(wildcard $(addprefix $d,$2)) $(call meik_rwildcard,$d*/,$2)))

# output directory
meik_output ?= output

# override stuff by writing make rules or setting variables in this file
meik_file := meik.mk
-include ${meik_file}


# prefix of the directories storing the object files
# this is needed to solve name clashes between an executable that has
# the same name as one of the source directories
meik_obj_dir_prefix ?= obj-

# one directory per project, one executable per project
# the default is to try to create out of each 'top' directory an executable
# the wildcard below should not recurse further into sub-directories
meik_project_executable  ?= $(filter-out ${meik_output}/, $(wildcard */))
meik_project_static_lib  ?=
meik_project_dynamic_lib ?=

# remove trailing slashes if any
meik_project_executable := $(patsubst %/,%,${meik_project_executable})
meik_project_static_lib := $(patsubst %/,%,${meik_project_static_lib})
meik_project_dynamic_lib := $(patsubst %/,%,${meik_project_dynamic_lib})

# also remove any libraries if defined
meik_project_executable := $(filter-out ${meik_project_static_lib} ${meik_project_dynamic_lib}, ${meik_project_executable})

# source extensions to look for
meik_src_ext ?=.c .cpp

.DEFAULT_GOAL := all

clean ::
	rm -rf $(firstword $(subst /, ,${meik_output}))

# meik owned files
meik_owned_files := $(strip GNUmakefile $(wildcard ${meik_file}))

# exes structure
$(foreach T,${meik_project_executable},                        \
  $(eval prj_id             := $(subst /,_,$T))                \
  $(eval ${prj_id}_compiler ?= ${meik_compiler})          \
  $(eval ${prj_id}_linker   ?= ${meik_linker})              \
  $(eval ${prj_id}_path     ?= $T)                             \
  $(eval ${prj_id}_name     ?= ${prj_id})                      \
  $(eval ${prj_id}_src_dirs ?= $(patsubst %/,%,$(call meik_rwildcard,${${prj_id}_path},/)))              \
  $(eval meik_exes   += ${meik_output}/${prj_id}/${${prj_id}_name})                  \
  $(eval meik_output_dirs += ${meik_output}/${prj_id} $(addprefix ${meik_output}/${prj_id}/${meik_obj_dir_prefix}, ${${prj_id}_src_dirs})) \
)

# static libraries structure
$(foreach T,${meik_project_static_lib},                        \
  $(eval prj_id             := $(subst /,_,$T))                \
  $(eval ${prj_id}_compiler ?= ${meik_compiler})          \
  $(eval ${prj_id}_linker   ?= ${meik_linker})              \
  $(eval ${prj_id}_path     ?= $T)                             \
  $(eval ${prj_id}_name     ?= lib${prj_id}.a)                 \
  $(eval ${prj_id}_src_dirs ?= $(patsubst %/,%,$(call meik_rwildcard,${${prj_id}_path},/)))              \
  $(eval meik_static_lib   += ${meik_output}/${prj_id}/${${prj_id}_name})                \
  $(eval meik_output_dirs += ${meik_output}/${prj_id} $(addprefix ${meik_output}/${prj_id}/${meik_obj_dir_prefix}, ${${prj_id}_src_dirs})) \
)

# dynamic libraries structure
$(foreach T,${meik_project_dynamic_lib},                       \
  $(eval prj_id             := $(subst /,_,$T))                \
  $(eval ${prj_id}_compiler ?= ${meik_compiler})          \
  $(eval ${prj_id}_linker   ?= ${meik_linker})              \
  $(eval CXXFLAGS_${prj_id} += -fPIC)                          \
  $(eval ${prj_id}_path     ?= $T)                             \
  $(eval ${prj_id}_Major    ?= 0)                              \
  $(eval ${prj_id}_minor    ?= 0)                              \
  $(eval ${prj_id}_patch    ?= 0)                              \
  $(eval ${prj_id}_name     ?= lib${prj_id}.so.${${prj_id}_Major}.${${prj_id}_minor}.${${prj_id}_patch}) \
  $(eval ${prj_id}_soname   ?= lib${prj_id}.so.${${prj_id}_Major})                         \
  $(eval ${prj_id}_src_dirs ?= $(patsubst %/,%,$(call meik_rwildcard,${${prj_id}_path},/)))                                         \
  $(eval meik_dynamic_lib   += ${meik_output}/${prj_id}/${${prj_id}_name})                \
  $(eval meik_output_dirs += ${meik_output}/${prj_id} $(addprefix ${meik_output}/${prj_id}/${meik_obj_dir_prefix}, ${${prj_id}_src_dirs})) \
)

undefine prj_id

.PHONY: all clean ${meik_project_executable} ${meik_project_static_lib} ${meik_project_dynamic_lib}

# the rules

all: ${meik_project_dynamic_lib} ${meik_project_static_lib} ${meik_project_executable}

${meik_output_dirs}:
	mkdir -p $@

.SECONDEXPANSION:

# because patsubst % behaves weirdly within a second expansion expression
# pc := %

# make the project names depend on the binary output files
${meik_project_executable} ${meik_project_static_lib} ${meik_project_dynamic_lib}: ${meik_output}/$$(subst /,_,$$@)/$${$$(subst /,_,$$@)_name}

# find all (*.[c|cpp]) in the given target path
# replace extension with .o
# prepend output-path
meik_find_objs = $(patsubst %,%.o,$(wildcard ${1}/*${2}))
meik_gen_objs  = $(foreach srcdir, ${${1}_src_dirs}, \
                    $(addprefix ${meik_output}/${1}/${meik_obj_dir_prefix}, \
                                $(foreach srcext, ${meik_src_ext}, \
                                          $(call meik_find_objs,${srcdir},${srcext}))))

# recursively create (prefixa prefixa_b prefixa_b_c) from (a/b/c) and (prefix)
# 0. check if there's at least one word in input list
# 1. recurse with the last word removed (corner case of input with one word: it does not contain a '/')
# 2. construct one of the output values
# 3. when no more words return empty list
meik_hierarchy_vars = $(strip $(if $(word 1,$(subst /, ,${1})), \
                                   $(call meik_hierarchy_vars, \
                                          $(patsubst %$(findstring /,${1})$(lastword $(subst /, ,${1})),%,${1}),${2}) ${$(strip ${2}$(strip $(subst /,_,${1})))},))


# remove the first directory from a path and object directory prefix
# "id/obj-path/file" becomes "path/file"
# spaces are used as a delimiter because make can not handle them anyway
meik_remove_1st_dir_and_obj_dir_prefix = $(patsubst ${meik_obj_dir_prefix}%,%,$(subst $() $(),/,$(wordlist 2,\
                                                                                 $(words $(subst /, ,${1})), \
                                                                                 $(subst /, ,${1}))))

# extract project id from executable path
meik_getprjid = $(subst /,_,$(patsubst %/,%,$(dir ${1})))

# link executables
${meik_exes} : ${meik_output}/% : $$(call meik_gen_objs,$$(call meik_getprjid,$$*)) | $$(@D)
	${$(call meik_getprjid,$*)_linker} -o $@ $^ ${LDFLAGS} ${LDFLAGS_$(call meik_getprjid,$*)} ${LDLIBS_$(call meik_getprjid,$*)} ${LDLIBS}

# archive static libraries
${meik_static_lib}: ${meik_output}/% : $$(call meik_gen_objs,$$(call meik_getprjid,$$*)) | $$(@D)
	${AR} ${ARFLAGS} ${ARFLAGS_$(call meik_getprjid,$*)} $@ $^

# link dynamic libraries
meik_comma := ,
${meik_dynamic_lib}: ${meik_output}/% : $$(call meik_gen_objs,$$(call meik_getprjid,$$*)) | $$(@D)
	${$(call meik_getprjid,$*)_linker} -shared $(if ${$(call meik_getprjid,$*)_soname},-Wl${meik_comma}-soname${meik_comma}${$(call meik_getprjid,$*)_soname},) -o $@ $^ ${LDFLAGS} ${LDFLAGS_$(call meik_getprjid,$*)} ${LDLIBS_$(call meik_getprjid,$*)} ${LDLIBS}

# compile rule for C++ files
${meik_output}/%.o : $$(call meik_remove_1st_dir_and_obj_dir_prefix,%) ${meik_owned_files} | $$(@D)
	${$(firstword $(subst /, ,$*))_compiler} -c $< -o $@ -MMD -MP ${CPPFLAGS} ${CXXFLAGS} $(call meik_hierarchy_vars, $<, CXXFLAGS_)

# silently (-) include auto-generated dependency files
-include $(foreach dir, ${meik_output_dirs}, $(wildcard ${dir}/*.d))

# debug rules
# run make print-var to print value of ${var}
print-%:
	@echo $* = '"${$*}"'

# run to make print prj id value
print-prj-%:
	@echo $*_path = '"${$*_path}"'
	@echo $*_name = '"${$*_name}"'
	@echo $*_src_dirs = '"${$*_src_dirs}"'
