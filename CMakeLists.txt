cmake_minimum_required(VERSION 3.14)
project(Arcana)

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
install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/bin DESTINATION       ${CMAKE_INSTALL_PREFIX})
install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/lib DESTINATION       ${CMAKE_INSTALL_PREFIX})
install(DIRECTORY ${ARCANA_STAGING_DIRECTORY}/share DESTINATION     ${CMAKE_INSTALL_PREFIX})

# export variables we need into the post-install cmake file
install(CODE "set(ARCANA_SUFFIX ${ARCANA_SUFFIX})")
install(CODE "set(ARCANA_STAGING_DIRECTORY ${ARCANA_STAGING_DIRECTORY})")

# set the cmake file to be run as a script for post-installation
install(SCRIPT "${CMAKE_SOURCE_DIR}/ffmpeg_arcana/cmake_include/post_install.cmake")
