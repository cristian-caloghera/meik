meik_project_dynamic_lib := myso

CXXFLAGS_app := -Imyso/
LDFLAGS_app := -L${meik_output}/myso/
LDLIBS_app := -l:libmyso.so.0.0.0

app : install_myso

install_myso : myso
	ln -fs libmyso.so.0.0.0 ${meik_output}/myso/libmyso.so.0

# run app with:
# LD_LIBRARY_PATH=output/myso/ output/app/app
