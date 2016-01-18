cmake_minimum_required(VERSION 2.8)
project(textured_cube)
enable_language(ASM) # ASM must be enabled for add_shbin_library

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${DKA_SUGGESTED_C_FLAGS}") # Use the devkitArm suggested flags. This is not mandatory.

# Note that you must copy the cmake folder and the DevkitArm3DS.cmake file in this directory
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake) # Add the cmake folder to the modules paths, so that we can use the tools and find_package for ctrulib
include(Tools3DS) # Include all the macros and tools needed for 3ds development.

find_package(CTRULIB REQUIRED) # Look for ctrulib

# List all the shader files
file(GLOB_RECURSE SHADERS_FILES
	source/*.pica
)
add_shbin_library(shaders ${SHADERS_FILES})# create a library that assembles and embeds the shaders shbin.

# List all the source files
file(GLOB_RECURSE SOURCE_FILES
	source/*
)

add_executable(textured_cube ${SOURCE_FILES}) # Create the elf file
target_link_libraries(textured_cube shaders 3ds::ctrulib m) # Link the texture, shaders, ctrulib and libm. This will also add the include directories needed for ctrulib and the embedded files.

target_embed_file(textured_cube data/kitten.bin)# Embeds a file as a binary data array the same way devkitArm makefiles do.

add_3dsx_target(textured_cube) # Generate the .3dsx and .smdh from the textured_cube target