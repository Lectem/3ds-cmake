cmake_minimum_required(VERSION 2.8)
project(hello_world)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${DKA_SUGGESTED_C_FLAGS}") # Use the devkitArm suggested flags. This is not mandatory.

# Note that you must copy the cmake folder and the DevkitArm3DS.cmake file in this directory
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake) # Add the cmake folder to the modules paths, so that we can use the tools and find_package for ctrulib
include(Tools3DS) # Include all the macros and tools needed for 3ds development.

find_package(CTRULIB REQUIRED) # Look for ctrulib

add_executable(hello_world source/main.c) # Create the elf file
target_link_libraries(hello_world 3ds::ctrulib) # Link ctrulib, this will also setup the include directories !

add_3dsx_target(hello_world) # Generate the .3dsx and .smdh from the hello_world target