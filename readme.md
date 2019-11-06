# Meik

## What? Why?
Meik is a [GNU Make](http://www.gnu.org/software/make/) file implementation. It will attempt to translate a source tree of C/C++ files into their compiled and linked counterparts.

By default it will attempt to create out of each directory that contains source code an executable:

```
.                                             output
├── dir1                                      ├── dir1
│   ├── main.cpp                              │   ├── main.cpp.o
│   └── code.cpp                              │   ├── code.cpp.o
│                                             │   └── dir1 (exe)
├── dir2                 ---translate-->      └── dir2
│   ├── morecode.cpp                              ├── morecode.cpp.o
│   └── evenmorecode.cpp                          ├── evenmorecode.cpp.o
│                                                 └── dir2 (exe)
└── GNUmakefile
```


## Features

 * No dependencies, except GNU Make itself.
 * Supports creation of executables, static and dynamic libraries (currently for GNU/Linux)
 * Configurable as it supports hierarchical per file/directory build options.
 * Parallel make invocation support.
 * Incremental rebuils.

## Quickstart

 1. Organize your projects source code each in one directory with a common parent directory
 1. Copy meik's `GNUmakefile` at the same level as your project directories
 1. Run ```$ make```

## Output

If the build was successful look for the output folder (by default it is called `output`). Here you will find the a similar structure of directories as you defined for your source files. Instead of source files you will find object files, dependency files and the final targets like executables and libraries.

By default the name of the  binary built is the same as the name of the directory where its source files reside.

## Configuration

Meik will look for a file called `meik.mk` at the same location as the `Makefile`. This is meik's configuration file. It is a plain GNU Make file that is going to be included in the `GNUmakefile`.

You can use the `meik.mk` file to overwrite certain default values that meik uses as described below.

### Build variables

The traditonal GNU Make variables are taken into account. That means that you change here settings such as `CXX` or `CXXFLAGS` to change the build process.

#### Dynamic build variables

All such variables are dynamic in nature, that means you can define them for only a part of your source tree. This works like this:

```
CXXFLAGS_some_dir := -Wall
CXXFLAGS_another_dir_code.cpp := -Wall
```
The 1st line above would enable the `-Wall` setting for all files that are hanging below the `./some/dir` directory.
The 2nd line above would enable the `-Wall` setting for the `./another/dir/code.cpp`. Since a file is a leaf in the directory structure, the setting would apply only to this file.

The following dynamic variables are supported:

 * ```CFLAGS_...``` for C compiler flags at any level
 * ```CXXFLAGS_...``` for C++ compiler flags at any level
 * ```LDFLAGS_...``` for linker flags at the project level
 * ```LDLIBS_...``` for linker additional libraries at project level

### Dependencies

Dependencies are described inside the `meik.mk` file with GNU Make syntax. Depenendencies between files will obviously work, but also dependencies between project ids is possible.

Here is an example that build an executable that links to a static library. The dependencies are expressed by using the actual binary files.

```
meik_project_executable := exe
meik_project_static_lib := mylib

# dependency of executable to library
${meik_output}/exe/exe : ${meik_output}/mylib/libmylib.a

# additional include path
CXXFLAGS_exe := -Imylib

# additional library to be linked
LDLIBS_exe := ${meik_output}/mylib/libmylib.a
```

Here is another example that builds an executable that links to a shared object. Here the dependencies are expressed by project ids:

```
meik_project_dynamic_lib := myso

CXXFLAGS_app := -Imyso/
LDFLAGS_app := -L${meik_output}/myso/
LDLIBS_app := -l:libmyso.so.0.0.0

app : install_myso

install_myso : myso
	ln -fs libmyso.so.0.0.0 ${meik_output}/myso/libmyso.so.0

# run app with:
# LD_LIBRARY_PATH=output/myso/ output/app/app
```


### Project variables

There three so-called project variables that you can use to guide Meik to look for source code of your projects. They are:

```
meik_project_executable
meik_project_static_lib
meik_project_dynamic_lib
```

By appending directories to each of these variables Meik will attempt to build the variable specific binary type out. To overrule this default behavior you have to know that each directory specified here gets assigned a so-called project identifier. This is the same as directory name with `/` replaced by `_`.

| variable value  | project identifier |
| --------------- | ------------------ |
| app             | app                | 
| my_app          | my_app             |
| some/folder/app | some_folder_app    |

The generated project identifier can be used to customize certain aspects of build process. For each variable the following suffixes are valid:

 * `_path`: the path of the project
 * `_name`: the name of the generated binary
 * `_src_dirs`: the list of directories containing source code
 * `compiler`: the compiler used for this project id
 * `linker`: the linker used for this project id

The variables created out of <project-id><suffix> can be overriden to suit your needs.

#### Shared objects

For shared objects there are some additional suffixes that can be used:

 * `_Major`: Major version of the shared object according to https://semver.org/. Default is 0.
 * `_minor`: minor version of the shared object according to https://semver.org/. Default is 0.
 * `_patch`: patch level of the shared object according to https://semver.org/. Default is 0.
 * `_soname`: the SONAME to be set for the shared object. Defaults is lib<project-id>.so.<Major>.

## Multiple configurations

Because you can choose what configuration file to use when issuing the ```make``` command:
```
$ make meik_file=some-other-file
```
you can have different profiles for your build. Each can have different output directories (a good idea!) and different sets of compiler/linker flags (e.g.: debug-config, release-config, my-special-config).

---
Copyright (c) 2013 Cristian Caloghera.
