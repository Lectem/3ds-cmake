############################################################################
# Various macros for 3DS homebrews tools
#
# add_shader_library(target input1 [input2 ...])
#
# /!\ Requires ASM to be enabled ( enable_language(ASM) or project(yourprojectname C CXX ASM) )
#
# Convert the shaders listed as input with the picasso assembler, and then creates a library containing the binary arrays of those shaders
# You can then link the 'target' as you would do with any other library.
# Header files containing information about the arrays of binary data are then available for the target linking this library.
# Those header use the same naming convention as devkitArm makefiles :
# A shader named vshader1.pica will generate the header vshader1_pica_shbin.h
#
############################################################################
get_filename_component(__tools3dsdir ${CMAKE_CURRENT_LIST_FILE} PATH) # Used to locate files to be used with configure_file

##############
## 3DSXTOOL ##
##############
if(NOT 3DSXTOOL)
    message(STATUS "Looking for 3dsxtool...")
    find_program(3DSXTOOL 3dsxtool ${DEVKITARM}/bin)
    if(3DSXTOOL)
        message(STATUS "3dsxtool: ${3DSXTOOL} - found")
    else()
        message(FATAL_ERROR "3dsxtool - not found")
    endif()
endif()


##############
## SMDHTOOL ##
##############
if(NOT SMDHTOOL)
    message(STATUS "Looking for smdhtool...")
    find_program(SMDHTOOL smdhtool ${DEVKITARM}/bin)
    if(SMDHTOOL)
        message(STATUS "smdhtool: ${SMDHTOOL} - found")
    else()
        message(FATAL_ERROR "smdhtool - not found")
    endif()
endif()



#############
##  BIN2S  ##
#############
if(NOT BIN2S)
    message(STATUS "Looking for bin2s...")
    find_program(BIN2S bin2s ${DEVKITARM}/bin)
    if(BIN2S)
        message(STATUS "bin2s: ${BIN2S} - found")
    else()
        message(FATAL_ERROR "bin2s - not found")
    endif()
endif()

#############
## PICASSO ##
#############
if(NOT PICASSO_EXE)
	message(STATUS "Looking for Picasso...")
	find_program(PICASSO_EXE picasso ${DEVKITARM}/bin)
	if(PICASSO_EXE)
		message(STATUS "Picasso: ${PICASSO_EXE} - found")
		set(SHADER_AS picasso CACHE STRING "The shader assembler to be used. Allowed values are 'picasso' or 'nihstro'")
	else()
		message(FATAL_ERROR "Picasso: ${PICASSO} - not found")
	endif()
endif()

###############################
###############################
########    MACROS    #########
###############################
###############################


###################
### EXECUTABLES ###
###################


function(add_3dsx_target target)
    get_filename_component(target_we ${target} NAME_WE)
    if((NOT (${ARGC} GREATER 1 AND "${ARGV1}" STREQUAL "NO_SMDH") ) OR (${ARGC} GREATER 3) )
        if(${ARGC} GREATER 3)
            set(APP_TITLE ${ARGV1})
            set(APP_DESCRIPTION ${ARGV2})
            set(APP_AUTHOR ${ARGV3})
        endif()
        if(${ARGC} EQUAL 5)
            set(APP_ICON ${ARGV4})
        endif()
        if(NOT APP_TITLE)
            set(APP_TITLE ${target})
        endif()
        if(NOT APP_DESCRIPTION)
            set(APP_DESCRIPTION "Built with devkitARM & libctru")
        endif()
        if(NOT APP_AUTHOR)
            set(APP_AUTHOR "Unspecified Author")
        endif()
        if(NOT APP_ICON)
            if(EXISTS ${target}.png)
                set(APP_ICON ${target}.png)
            elseif(EXISTS icon.png)
                set(APP_ICON icon.png)
            elseif(CTRULIB)
                set(APP_ICON ${CTRULIB}/default_icon.png)
            else()
                message(FATAL_ERROR "No icon found ! Please use NO_SMDH or provide some icon.")
            endif()
        endif()
        add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/${target_we}.3dsx ${CMAKE_BINARY_DIR}/${target_we}.smdh
                            COMMAND ${SMDHTOOL} --create ${APP_TITLE} ${APP_DESCRIPTION} ${APP_AUTHOR} ${APP_ICON} ${CMAKE_BINARY_DIR}/${target_we}.smdh
                            COMMAND ${3DSXTOOL} ${target} ${CMAKE_BINARY_DIR}/${target_we}.3dsx --smdh=${CMAKE_BINARY_DIR}/${target_we}.smdh
                            DEPENDS ${target}
        )
    else()
        message(STATUS "No smdh file will be generated")
        add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/${target_we}.3dsx
                            COMMAND ${3DSXTOOL} ${target} ${target_we}.3dsx
                            DEPENDS ${target}
                            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )
    endif()
    add_custom_target(${target}_3dsx ALL SOURCES ${CMAKE_BINARY_DIR}/${target_we}.3dsx)
endfunction()


# todo : cia ?


###################
##### SHADERS #####
###################

macro(generate_shbin OUTPUT INPUT)
    if(SHADER_AS STREQUAL "picasso")
        add_custom_command(OUTPUT ${OUTPUT}
                            COMMAND ${PICASSO_EXE} ${OUTPUT} ${INPUT}
        )
    elseif(SHADER_AS STREQUAL "nihstro")
        message(FATAL_ERROR "nihstro not supported yet")
    else()
        message(FATAL_ERROR "Please set SHADER_AS to 'picasso' or 'nihstro'.")
    endif()
endmacro()

macro(add_shader_library libtarget)
    get_cmake_property(ENABLED_LANGUAGES ENABLED_LANGUAGES)
    if(NOT ENABLED_LANGUAGES MATCHES ".*ASM.*")
        message(FATAL_ERROR "You have to enable ASM in order to use add_shader_library. Use enable_language(ASM). Currently enabled languages are ${ENABLED_LANGUAGES}")
    endif()
    foreach(__shader_file ${ARGN})
        get_filename_component(__shader_file_wd ${__shader_file} NAME)
        string(REGEX REPLACE "^([0-9])" "_\\1" __BIN_FILE_NAME ${__shader_file_wd}) # add '_' if the file name starts by a number
        string(REGEX REPLACE "[-./]" "_" __BIN_FILE_NAME ${__BIN_FILE_NAME})
        set(__BIN_FILE_NAME ${__BIN_FILE_NAME}_shbin)

        #Generate the shbin file
        list(APPEND __SHADERS_BIN_FILES ${CMAKE_BINARY_DIR}/shaders/${__shader_file_wd}.shbin)
        generate_shbin(${CMAKE_BINARY_DIR}/shaders/${__shader_file_wd}.shbin ${__shader_file})

        #Generate the header file
        configure_file(${__tools3dsdir}/bin2s_header.h.in ${CMAKE_BINARY_DIR}/shaders/${__BIN_FILE_NAME}.h)
    endforeach()

    # Generate the assembly file, and create the new target
    add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/shaders/shaders.s
                        COMMAND ${BIN2S} ${__SHADERS_BIN_FILES} > ${CMAKE_BINARY_DIR}/shaders/shaders.s
                        DEPENDS ${__SHADERS_BIN_FILES}
                        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    add_library(${libtarget} ${CMAKE_BINARY_DIR}/shaders/shaders.s)
    target_include_directories(${libtarget} INTERFACE ${CMAKE_BINARY_DIR}/shaders )
endmacro()