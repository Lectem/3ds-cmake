cmake_minimum_required(VERSION 2.8)
project(simple_tri)
enable_language(ASM) # ASM must be enabled for add_shbin_library

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${DKA_SUGGESTED_C_FLAGS}") # Use the devkitArm suggested flags. This is not mandatory.

# Note that you must copy the cmake folder and the DevkitArm3DS.cmake file in this directory
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake) # Add the cmake folder to the modules paths, so that we can use the tools and find_package for ctrulib
include(Tools3DS) # Include all the macros and tools needed for 3ds development.

find_package(CTRULIB REQUIRED) # Look for ctrulib

# List all the source files
file(GLOB_RECURSE SOURCE_FILES
	source/*
)

add_executable(simple_tri ${SOURCE_FILES}) # Create the elf file
target_link_libraries(simple_tri 3ds::ctrulib m) # Link the shaders library, ctrulib and libm. This will also add the include directories for ctrulib.

target_embed_shader(simple_tri source/vshader.pica) # creates the shbin files and embed them into the app

add_3dsx_target(simple_tri) # Generate the .3dsx and .smdh from the simple_tri target