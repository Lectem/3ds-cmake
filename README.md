# 3ds-cmake [![Join the chat at https://gitter.im/Lectem/3dsdev](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Lectem/3dsdev)



CMake scripts for devkitArm and 3DS homebrew development.

It aims to provide at least the same functionalities than devkitPro makefiles. It can help to build more complex projects or simply compile libraries by using the toolchain file.

## How to use it ?

Simply copy `DevkitArm3DS.cmake` and the `cmake` folder at the root of your project (where your CMakeLists.txt is).
Then start cmake with

    cmake -DCMAKE_TOOLCHAIN_FILE=DevkitArm3DS.cmake

If you are on windows, I suggest using the `Unix Makefiles` generator.

`cmake-gui` is also a good alternative, you can specify the toolchain file the first time you configure a build.
	
You can use the macros and find scripts of the `cmake` folder by adding the following line to your CMakeLists.cmake :

    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)

## The toolchain file (DevkitArm3DS.cmake)

### 3DS

This CMake variable will be set so that you can test against it for projects that can be built on other platforms.

### DKA_SUGGESTED_C_FLAGS

This CMake variable is set to `-fomit-frame-pointer -ffast-math`. Those are the recommended C flags for devkitArm projects but are non-mandatory.

### DKA_SUGGESTED_CXX_FLAGS

This CMake variable is set to `-fomit-frame-pointer -ffast-math -fno-rtti -fno-exceptions -std=gnu++11`. Those are the recommended C++ flags for devkitArm projects but are non-mandatory.

### WITH_PORTLIBS

By default the portlibs folder will be used, it can be disabled by changing the value of WITH_PORTLIBS to OFF from the cache (or forcing the value from your CMakeLists.txt).

## FindCTRULIB.cmake

You can use `find_package(CTRULIB)`.

If found, `LIBCTRU_LIBRARIES` and `LIBCTRU_INCLUDE_DIRS` will be set.
It also adds an imported target named `3ds::ctrulib`.
Linking it is the same as target_link_libraries(target ${LIBCTRU_LIBRARIES}) and target_include_directories(target ${LIBCTRU_INCLUDE_DIRS})

## FindSF2D.cmake

You can use `find_package(SF2D)`.

If found, `LIBSF2D_LIBRARIES` and `LIBSF2D_INCLUDE_DIRS` will be set.
It also adds an imported target named `3ds::sf2d`.
Linking it is the same as target_link_libraries(target ${LIBSF2D_LIBRARIES}) and target_include_directories(target ${LIBSF2D_INCLUDE_DIRS})

## Tools3DS.cmake

This file must be included with `include(Tools3DS)`. It provides several macros related to 3DS development such as `add_shader_library` which assembles your shaders into a C library.

### add_3dsx_target

This macro has two signatures :

#### add_3dsx_target(target [NO_SMDH])

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

#### add_3dsx_target(target APP_TITLE APP_DESCRIPTION APP_AUTHOR [APP_ICON])

This version will produce the SMDH with tha values passed as arguments. Tha APP_ICON is optional and follows the same rule as the other version of `add_3dsx_target`.

### add_cia_target(target RSF IMAGE SOUND [APP_TITLE APP_DESCRIPTION APP_AUTHOR [APP_ICON]])

Same as add_3dsx_target but for CIA files.

* RSF is the .rsf file to be given to makerom.
* IMAGE is either a .png or a cgfximage file.
* SOUND is either a .wav or a cwavaudio file.

### add_netload_target(target FILE)

Adds a target `name` that sends a .3dsx using the homebrew launcher netload system (3dslink).
* `target_or_file` is either the name of a target (on which you used add_3dsx_target) or a file name.

### add_binary_library(target input1 [input2 ...])

    /!\ Requires ASM to be enabled ( `enable_language(ASM)` or `project(yourprojectname C CXX ASM)`)

Converts the files given as input to arrays of their binary data. This is useful to embed resources into your project.
For example, logo.bmp will generate the array `u8 logo_bmp[]` and its size `logo_bmp_size`. By linking this library, you 
will also have access to a generated header file called `logo_bmp.h` which contains the declarations you need to use it.

    Note : All dots in the filename are converted to `_`, and if it starts with a number, `_` will be prepended. 
    For example 8x8.gas.tex would give the name _8x8_gas_tex.

### target_embed_file(target input1 [input2 ...])

Same as add_binary_library(tempbinlib input1 [input2 ...]) + target_link_libraries(target tempbinlib)

### add_shbin(output input [entrypoint] [shader_type])
 
Assembles the shader given as `input` into the file `output`. No file extension is added.
You can choose the shader assembler by setting SHADER_AS to `picasso` or `nihstro`.

If `nihstro` is set as the assembler, entrypoint and shader_type will be used.
- entrypoint is set to `main` by default
- shader_type can be either VSHADER or GSHADER. By default it is VSHADER. 

### generate_shbins(input1 [input2 ...])

Assemble all the shader files given as input into .shbin files. Those will be located in the folder `shaders` of the build directory.
The names of the output files will be <name of input without longest extension>.shbin. `vshader.pica` will output `shader.shbin` but `shader.vertex.pica` will output `shader.shbin` too.

### add_shbin_library(target input1 [input2 ...])

    /!\ Requires ASM to be enabled ( `enable_language(ASM)` or `project(yourprojectname C CXX ASM)`)

This is the same as calling generate_shbins and add_binary_library. This is the function to be used to reproduce devkitArm makefiles behaviour.
For example, add_shbin_library(shaders data/my1stshader.vsh.pica) will generate the target library `shaders` and you
will be able to use the shbin in your program by linking it, including `my1stshader_pica.h` and using `my1stshader_pica[]` and `my1stshader_pica_size`.

### target_embed_shader(target input1 [input2 ...])

Same as add_shbin_library(tempbinlib input1 [input2 ...]) + target_link_libraries(target tempbinlib)

# Example of CMakeLists.txt using ctrulib and shaders

    cmake_minimum_required(VERSION 2.8)
    project(videoPlayer C CXX ASM)
    
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
    include(Tools3DS)
    
    find_package(CTRULIB REQUIRED)
    
    file(GLOB_RECURSE SHADERS_FILES
        data/*.pica
    )
    add_shbin_library(shaders ${SHADERS_FILES})
    
    file(GLOB_RECURSE SOURCE_FILES
        source/*
    )
    add_executable(hello_cmake ${SOURCE_FILES})
    target_link_libraries(hello_cmake shaders 3ds::ctrulib)
	
	add_3dsx_target(hello_cmake)
