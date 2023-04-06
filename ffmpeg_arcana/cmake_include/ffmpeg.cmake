cmake_minimum_required(VERSION 3.14)

# path where ffmpeg private include files will be staged
set(FFMPEG_PRIVATE_INCLUDE_PATH ${ARCANA_STAGING_DIRECTORY}/include/arcana/libavprivate)

# FFMPEG FETCH SECTION: START
set(FFMPEG_SRC_PATH ${CMAKE_BINARY_DIR})

if(NOT DEFINED ARCANA_PATCH_VERSION)
    set(ARCANA_PATCH_VERSION 6.0)
endif()

if(NOT DEFINED FFMPEG_VERSION)
    set(FFMPEG_VERSION 6.0)
endif()

set(FFMPEG_NAME ffmpeg-${FFMPEG_VERSION})
set(FFMPEG_URL https://ffmpeg.org/releases/${FFMPEG_NAME}.tar.bz2)

if(NOT DEFINED NO_ARCANA_SUFFIX)
    if(NOT DEFINED ARCANA_SUFFIX)
        set(ARCANA_SUFFIX _arcana)
    endif()

    if(NOT DEFINED ARCANA_EXTRA_VERSION)
        set(ARCANA_EXTRA_VERSION _arcana)
    endif()
else()
    message(STATUS "Skipping Arcana suffix")
    set(ARCANA_SUFFIX )
    set(ARCANA_EXTRA_VERSION )
endif()

set(ARCANA_PATCH_NAME ffmpeg_arcana_patch_${ARCANA_PATCH_VERSION}.patch)
# https://github.com/richinsley/FFmpeg_Arcana/releases/download/arcana_n6.0/ffmpeg_arcana_patch_6.0.patch
set(ARCANA_PATCH_URL https://github.com/richinsley/FFmpeg_Arcana/releases/download/arcana_n6.0/${ARCANA_PATCH_NAME})

get_filename_component(FFMPEG_ARCHIVE_NAME ${FFMPEG_URL} NAME)

if (NOT EXISTS ${FFMPEG_SRC_PATH}/${FFMPEG_NAME})
    file(DOWNLOAD ${FFMPEG_URL} ${FFMPEG_SRC_PATH}/${FFMPEG_ARCHIVE_NAME})
    execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf ${FFMPEG_SRC_PATH}/${FFMPEG_ARCHIVE_NAME}
            WORKING_DIRECTORY ${FFMPEG_SRC_PATH}
    )

    file(DOWNLOAD ${ARCANA_PATCH_URL} ${FFMPEG_SRC_PATH}/${ARCANA_PATCH_NAME})
    find_package(Patch)
    if(Patch_FOUND AND EXISTS "${FFMPEG_SRC_PATH}/${ARCANA_PATCH_NAME}")
        message(STATUS "Applying Arcana patch: ${FFMPEG_SRC_PATH}/${ARCANA_PATCH_NAME} to ${FFMPEG_SRC_PATH}/${FFMPEG_NAME}")
        execute_process(COMMAND ${Patch_EXECUTABLE} -ruN -p1 --input ${FFMPEG_SRC_PATH}/${ARCANA_PATCH_NAME}
                            WORKING_DIRECTORY ${FFMPEG_SRC_PATH}/${FFMPEG_NAME}
                            RESULT_VARIABLE PATCH_APPLY_RESULT)
        if(NOT PATCH_APPLY_RESULT EQUAL "0")
                message(FATAL_ERROR "patch apply ${FFMPEG_SRC_PATH}/${ARCANA_PATCH_NAME} to folder ${FFMPEG_SRC_PATH}/${FFMPEG_ARCHIVE_NAME} failed with ${PATCH_APPLY_RESULT}")
        endif()
    else()
        message(FATAL_ERROR "patch command not found")
    endif()
endif()

file(
        COPY ${CMAKE_CURRENT_SOURCE_DIR}/cmake_include/ffmpeg_build_system.cmake
        DESTINATION ${FFMPEG_SRC_PATH}/${FFMPEG_NAME}
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

# FFMPEG FETCH SECTION: END

# ANDROID BUILD TOOLS SECTION: START

# We set custom variables for all build tools in case we want to make changes to in certain situations
# set(FFMPEG_CC ${CMAKE_C_COMPILER})
# set(FFMPEG_CXX ${CMAKE_CXX_COMPILER})
# set(FFMPEG_AR ${ANDROID_AR})
# set(FFMPEG_AS ${ANDROID_ASM_COMPILER})

# Taken from https://android.googlesource.com/platform/ndk/+/master/build/cmake/android.toolchain.cmake
# Remove when toolchain actually will include it
# set(FFMPEG_RANLIB ${ANDROID_TOOLCHAIN_PREFIX}ranlib${ANDROID_TOOLCHAIN_SUFFIX})
# set(FFMPEG_STRIP ${ANDROID_TOOLCHAIN_ROOT}/bin/llvm-strip${ANDROID_TOOLCHAIN_SUFFIX})

# Set NM manually
# set(FFMPEG_NM ${ANDROID_TOOLCHAIN_PREFIX}nm${ANDROID_TOOLCHAIN_SUFFIX})

# ANDROID BUILD TOOLS SECTION: END

# ANDROID FLAGS SECTION: START

# We remove --fatal-warnings in such blatant way because somebody at Google decided it's an excellent idea
# to put it into LD flags in toolchain without any way to turn it off.
# string(REPLACE " -Wl,--fatal-warnings" "" FFMPEG_LD_FLAGS ${CMAKE_SHARED_LINKER_FLAGS})


# set(FFMPEG_C_FLAGS "${CMAKE_C_FLAGS} --target=${ANDROID_LLVM_TRIPLE} --gcc-toolchain=${ANDROID_TOOLCHAIN_ROOT} ${FFMPEG_EXTRA_C_FLAGS}")
# set(FFMPEG_ASM_FLAGS "${CMAKE_ASM_FLAGS} --target=${ANDROID_LLVM_TRIPLE} ${FFMPEG_EXTRA_ASM_FLAGS}")
# set(FFMPEG_LD_FLAGS "${FFMPEG_C_FLAGS} ${FFMPEG_LD_FLAGS} ${FFMPEG_EXTRA_LD_FLAGS}")

# ANDROID FLAGS SECTION: END

# MISC VARIABLES SECTION: START

set(NJOBS 4)
# set(HOST_BIN ${ANDROID_NDK}/prebuilt/${ANDROID_HOST_TAG}/bin)

# MISC VARIABLES SECTION: END

# FFMPEG EXTERNAL PROJECT CONFIG SECTION: START

# https://trac.ffmpeg.org/ticket/4928 we must disable asm for x86 since it's non-PIC by design from FFmpeg side
# IF (${CMAKE_ANDROID_ARCH_ABI} STREQUAL x86)
#     list(APPEND FFMPEG_CONFIGURE_EXTRAS --disable-asm)
# ENDIF()

ExternalProject_Add(ffmpeg_target
        PREFIX ffmpeg_pref
        URL ${FFMPEG_SRC_PATH}/${FFMPEG_NAME}
        DOWNLOAD_NO_EXTRACT 1
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env
            # PATH=${ANDROID_TOOLCHAIN_ROOT}/bin:$ENV{PATH}
            AS_FLAGS=${FFMPEG_ASM_FLAGS}
            ${CMAKE_COMMAND}
            -DSTEP:STRING=configure
            # -DARCH:STRING=${CMAKE_SYSTEM_PROCESSOR}
            # -DCC:STRING=${FFMPEG_CC}
            # -DSTRIP:STRING=${FFMPEG_STRIP}
            # -DAR:STRING=${FFMPEG_AR}
            # -DAS:STRING=${FFMPEG_AS}
            # -DNM:STRING=${FFMPEG_NM}
            # -DRANLIB:STRING=${FFMPEG_RANLIB}
            # -DSYSROOT:STRING=${CMAKE_SYSROOT}
            -DC_FLAGS:STRING=${FFMPEG_C_FLAGS}
            -DLD_FLAGS:STRING=${FFMPEG_LD_FLAGS}
            -DPREFIX:STRING=${ARCANA_STAGING_DIRECTORY}
            -DCONFIGURE_EXTRAS=${FFMPEG_CONFIGURE_EXTRAS}
            -DARCANA_SUFFIX=${ARCANA_SUFFIX}
            -DARCANA_EXTRA_VERSION=${ARCANA_EXTRA_VERSION}
        -P ffmpeg_build_system.cmake
        BUILD_COMMAND ${CMAKE_COMMAND} -E env
            # PATH=${ANDROID_TOOLCHAIN_ROOT}/bin:$ENV{PATH}
            ${CMAKE_COMMAND}
            -DSTEP:STRING=build
            -NJOBS:STRING=${NJOBS}
            # -DHOST_TOOLCHAIN:STRING=${HOST_BIN}
        -P ffmpeg_build_system.cmake
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND ${CMAKE_COMMAND} -E env
            # PATH=${ANDROID_TOOLCHAIN_ROOT}/bin:$ENV{PATH}
            ${CMAKE_COMMAND}
            -DSTEP:STRING=install
            # -DHOST_TOOLCHAIN:STRING=${HOST_BIN}
        -P ffmpeg_build_system.cmake
        STEP_TARGETS copy_headers
        LOG_CONFIGURE 1
        LOG_BUILD 1
        LOG_INSTALL 1
        DEPENDS ${FFMPEG_DEPENDS}
)

ExternalProject_Get_property(ffmpeg_target SOURCE_DIR)
# add the copy_headers external project as a step to the ffmpeg_target external project
ExternalProject_Add_Step(
        ffmpeg_target
        copy_headers
        COMMAND ${CMAKE_COMMAND}
            -DBUILD_DIR:STRING=${SOURCE_DIR}
            -DSOURCE_DIR:STRING=${CMAKE_CURRENT_SOURCE_DIR}
            -DFFMPEG_NAME:STRING=${FFMPEG_NAME}
            -DOUT:STRING=${FFMPEG_PRIVATE_INCLUDE_PATH}
            -DSTAGING:STRING=${ARCANA_STAGING_DIRECTORY}
        -P  ${CMAKE_CURRENT_SOURCE_DIR}/cmake_include/copy_headers.cmake
        # DEPENDEES build
        # DEPENDERS install
        DEPENDEES install
)

# FFMPEG EXTERNAL PROJECT CONFIG SECTION: END

