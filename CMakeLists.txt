cmake_minimum_required(VERSION 3.14)
project(Arcana)

# create ffmpeg options file
include(ffmpeg_arcana/cmake_include/create_ffmpeg_options_file.cmake)
set(FFMPEG_OPTIONS_FILE "${CMAKE_CURRENT_BINARY_DIR}/ffmpeg_config_options.txt")
create_ffmpeg_options_file(. "${FFMPEG_OPTIONS_FILE}")

# our build options for ffmpeg
if(NOT DEFINED FFMPEG_CONFIGURE_EXTRAS)
    set(FFMPEG_CONFIGURE_EXTRAS )
endif()

# path for staged build artifacts
if(NOT DEFINED ARCANA_STAGING_DIRECTORY)
    set(ARCANA_STAGING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/staging)
endif()

# add the ffmpeg build cmake subdirectory that will create the build in the target ARCANA_STAGING_DIRECTORY
add_subdirectory(ffmpeg_arcana)

if(NOT DEFINED NO_ARCANA_SUFFIX)
    get_directory_property(ARCANA_SUFFIX DIRECTORY ffmpeg_arcana DEFINITION ARCANA_SUFFIX)
    message(STATUS "Arcana suffix: ${ARCANA_SUFFIX}")
else()
    set(ARCANA_SUFFIX )
endif()

install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/include DESTINATION   ${CMAKE_INSTALL_PREFIX})
install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/bin DESTINATION       ${CMAKE_INSTALL_PREFIX} USE_SOURCE_PERMISSIONS)
install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/lib DESTINATION       ${CMAKE_INSTALL_PREFIX} USE_SOURCE_PERMISSIONS)
install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/share DESTINATION     ${CMAKE_INSTALL_PREFIX})


