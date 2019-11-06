#!/bin/bash

# this is here because otherwise it will trigger errexit
(( assertions = 0 ))

# exit on error
set -o errexit

pushd ()
{
  command pushd "$@" > /dev/null
}

popd ()
{
  command popd "$@" > /dev/null
}


check ()
{
  if [ "$1" != "$2" ]; then
    echo "Fail @ line: $3";
    echo "EXPECTED: $2"
    echo "ACTUAL  : $1"
    exit 1
  fi

  (( assertions += 1 ))
}

printf "Meik Test Suite\n\n"
printf "Make Location: $(which make)\n"
printf "Make Version : $(make --version | head -n 1)\n\n"

MAKEFILE=GNUmakefile

test_case ()
{
  pushd .

  cd tests/"$1" || exit 1
  ln --symbolic --force ../../$MAKEFILE $MAKEFILE

  "$1"

  popd
}

hierarchy_vars ()
{
  ACTUAL=$(make print-hvar_empty)
  EXPECTED=$'hvar_empty = ""'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-hvar_1_dir)
  EXPECTED=$'hvar_1_dir = "prefix a"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-hvar_n_dir)
  EXPECTED=$'hvar_n_dir = "prefix a prefix a b prefix a b c"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-hvar_some_file)
  EXPECTED=$'hvar_some_file = "options for some file in some dir"'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

meik_remove_1st_dir_and_obj_dir_prefix ()
{
  ACTUAL=$(make print-removed_1st_dir_and_obj_prefix)
  EXPECTED=$'removed_1st_dir_and_obj_prefix = "result/starts/here"'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

meik_rwildcard ()
{
  ACTUAL=$(make print-rwildcard-depth-0)
  EXPECTED=$'rwildcard-depth-0 = "./dir-level-01/ ./dir-level-02/ ./dir-level-03/ ./dir-level-03/dir-level11/"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-rwildcard-files)
  EXPECTED=$'rwildcard-files = "./dir-level-02/file.other-extension ./dir-level-03/dir-level11/file.other-extension"'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

defaults-single ()
{
  make clean && make
  ACTUAL=$(output/lonely-project/lonely-project)
  EXPECTED=$'this is a lonely project'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

defaults-multi ()
{
  make clean && make
  ACTUAL=$(output/multi-1/multi-1 && output/multi-2/multi-2 && output/multi-3/multi-3)
  EXPECTED=$'123'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

static-lib ()
{
  make clean && make
  ACTUAL=$(output/exe/exe)
  EXPECTED=$'call from static lib returns: 0'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

shared-lib ()
{
  make clean && make
  ACTUAL=$(echo $?)
  EXPECTED=$'0'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

shared-lib-versioning ()
{
  ACTUAL=$(make print-anything_Major)
  EXPECTED=$'anything_Major = "0"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-anything_minor)
  EXPECTED=$'anything_minor = "0"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-anything_patch)
  EXPECTED=$'anything_patch = "0"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-anything_soname)
  EXPECTED=$'anything_soname = "libanything.so.0"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-anything_name)
  EXPECTED=$'anything_name = "libanything.so.0.0.0"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-override_Major)
  EXPECTED=$'override_Major = "1"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-override_minor)
  EXPECTED=$'override_minor = "2"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-override_patch)
  EXPECTED=$'override_patch = "3"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-override_soname)
  EXPECTED=$'override_soname = "whatever"'
  check "$ACTUAL" "$EXPECTED" $LINENO

  ACTUAL=$(make print-override_name)
  EXPECTED=$'override_name = "liboverride.so.1.2.3"'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

recursive-src-find ()
{
  make clean && make
  output/deep-src/deep-src
  ACTUAL=$(echo $?)
  EXPECTED=$'0'
  check "$ACTUAL" "$EXPECTED" $LINENO
}

test_case "hierarchy_vars"
test_case "meik_remove_1st_dir_and_obj_dir_prefix"
test_case "meik_rwildcard"
test_case "defaults-single"
test_case "defaults-multi"
test_case "static-lib"
test_case "shared-lib-versioning"
test_case "shared-lib"
test_case "recursive-src-find"

printf "\nTests ran fine (%d assertions total).\n" $assertions

exit 0
