meik_project_static_lib := mylib

# dependency of executable to library
${meik_output}/exe/exe : ${meik_output}/mylib/libmylib.a

# additional include path
CXXFLAGS_exe := -Imylib

# additional library to be linked
LDLIBS_exe := ${meik_output}/mylib/libmylib.a
