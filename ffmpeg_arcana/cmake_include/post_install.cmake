cmake_minimum_required(VERSION 3.10)

function(adjust_pkgconf pkgpc)
    set(PC_PATH "${ARCANA_STAGING_DIRECTORY}/lib/pkgconfig/${pkgpc}${ARCANA_SUFFIX}.pc")
    if(EXISTS ${PC_PATH})
        file(READ ${PC_PATH} pcfiledata)
        string(REPLACE "${ARCANA_STAGING_DIRECTORY}" "${CMAKE_INSTALL_PREFIX}" MODIFIED_PC "${pcfiledata}")
        # append " -I${includedir}/libavprivate" to "Cflags:" line
        string(REPLACE "Cflags: -I\${includedir}" "Cflags: -I\${includedir} -I\${includedir}/libavprivate" FINAL "${MODIFIED_PC}")
        file(WRITE ${PC_PATH} "${FINAL}")
        message(STATUS "adjusted paths for ${PC_PATH}")
    else()
        message(STATUS "package config file ${PC_PATH} not found")
    endif()
endfunction()

adjust_pkgconf(libavcodec)
adjust_pkgconf(libavdevice)
adjust_pkgconf(libavfilter)
adjust_pkgconf(libavformat)
adjust_pkgconf(libavutil)
adjust_pkgconf(libswresample)
adjust_pkgconf(libswscale)
adjust_pkgconf(libpostproc)