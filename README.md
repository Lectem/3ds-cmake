# 3ds-cmake

CMake scripts for devkitArm and 3DS homebrew development.

It aims to provide at least the same functionalities than devkitPro makefiles. It can help to build more complex projects or simply compile libraries by using the toolchain file.

## How to use it ?

Simply copy `DevkitArm3DS.cmake` and the `cmake` folder at the root of your project (where your CMakeLists.txt is).
Then start cmake with

    cmake -DCMAKE_TOOLCHAIN_FILE=DevkitArm3DS.cmake
	
You can use the macros and find scripts of the `cmake` folder by adding the following line to your CMakeLists.cmake :

    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

## FindCTRULIB.cmake

You can use `find_package(CTRULIB)`. If found, `LIBCTRU_LIBRARIES` and `LIBCTRU_INCLUDE_DIRS` will be set.

## Tools3DS.cmake

This file must be include with `include(Tools3DS)`. It provides several macros related to 3DS development such as `add_shader_library` which assembles your shaders into a C library.

### add_3dsx_target

This macro has two signatures :

####add_3dsx_target(target [NO_SMDH])

Adds a target that generates a .3dsx file from `target`. If NO_SMDH is specified, no .smdh file will be generated.

You can set the following variables to change the SMDH file :

* APP_TITLE is the name of the app stored in the SMDH file (Optional)
* APP_DESCRIPTION is the description of the app stored in the SMDH file (Optional)
* APP_AUTHOR is the author of the app stored in the SMDH file (Optional)
* APP_ICON is the filename of the icon (.png), relative to the project folder.
  If not set, it attempts to use one of the following (in this order):
    - $(target).png
    - icon.png
    - $(libctru folder)/default_icon.png

####add_3dsx_target(target APP_TITLE APP_DESCRIPTION APP_AUTHOR [APP_ICON])

This version will produce the SMDH with tha values passed as arguments. Tha APP_ICON is optional and follows the same rule as the other version of `add_3dsx_target`.

### add_shader_library(target input1 [input2 ...])

    /!\ Requires ASM to be enabled ( `enable_language(ASM)` or `project(yourprojectname C CXX ASM)`)

Convert the shaders listed as input with the picasso assembler, and then creates a library containing the binary arrays of those shaders. This provides the same behaviour as the ctrulib makefiles.
You can then link the `target` library as you would do with any other library.

Header files containing information about the arrays of binary data are then available for the target linking this library.
Those header use the same naming convention as devkitArm makefiles :
A shader named vshader1.pica will generate the header vshader1_pica_shbin.h

# Example of CMakeLists.txt using ctrulib and shaders

    cmake_minimum_required(VERSION 2.8)
    project(videoPlayer C CXX ASM)
    
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
    include(Tools3DS)
    
    find_package(CTRULIB REQUIRED)
    
    file(GLOB_RECURSE SHADERS_FILES
        data/*.pica
    )
    add_shader_library(shaders ${SHADERS_FILES})
    
    file(GLOB_RECURSE SOURCE_FILES
        source/*
    )
    add_executable(hello_cmake ${SOURCE_FILES})
    target_link_libraries(hello_cmake shaders m ${LIBCTRU_LIBRARIES})
    target_include_directories(hello_cmake PUBLIC include ${LIBCTRU_INCLUDE_DIRS})
	
	add_3dsx_target(hello_cmake)
