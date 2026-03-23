add_library(cplamp_warnings INTERFACE)

if(MSVC)
    target_compile_options(cplamp_warnings INTERFACE 
    /W4
    /permissive-
    )
    
else()
    target_compile_options(cplamp_warnings INTERFACE
        -Wall
        -Wextra
        -Wpedantic
    )
endif()