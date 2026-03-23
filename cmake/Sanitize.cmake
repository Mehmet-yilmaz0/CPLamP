option(CPLAMP_ENABLE_SANITIZERS "Enable sanitizer flags" OFF)

if(CPLAMP_ENABLE_SANITIZERS)
    add_library(cplamp_sanitize INTERFACE)

    if(MSVC)
        message(WARNING "Sanitizers are limited on MSVC; enabling only supported options is recommended.")
        target_compile_options(cplamp_sanitize INTERFACE /fsanitize=address)
        target_link_options(cplamp_sanitize INTERFACE /fsanitize=address)
    else()
        target_compile_options(cplamp_sanitize INTERFACE
            -fsanitize=address
            -fsanitize=undefined
            -fno-omit-frame-pointer
            -g
        )
        target_link_options(cplamp_sanitize INTERFACE
            -fsanitize=address
            -fsanitize=undefined
        )
    endif()
endif()