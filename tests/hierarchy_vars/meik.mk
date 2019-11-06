prefix_a := prefix a
prefix_a_b := prefix a b
prefix_a_b_c := prefix a b c
prefix_some_dir_some.file := options for some file in some dir

hvar_no_path = $(call meik_hierarchy_vars, , prefix_)
hvar_1_dir = $(call meik_hierarchy_vars, a, prefix_)
hvar_n_dir = $(call meik_hierarchy_vars, a/b/c, prefix_)
hvar_some_file = $(call meik_hierarchy_vars, some/dir/some.file, prefix_)
