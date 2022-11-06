unused_args = false
allow_defined_top = true

globals = {
    "renderer", "window",
    string = {fields = {"split"}},
    table = {fields = {"copy", "indexof"}},
}

read_globals = {
    "document", "flow",
    formspec_ast = {
        fields = {"apply_offset", "find", "flatten", "formspec_escape",
            "get_element_by_name", "get_elements_by_name", "interpret",
            "parse", "register_element", "safe_interpret", "safe_parse",
            "show_formspec", "unparse", "walk"}
    },
}