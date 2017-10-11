# deps.cmake

macro(build_deps deps)
  foreach(_pkg ${deps})
    string(REPLACE ":" ";" _pkg_name ${_pkg})
    list(GET _pkg_name 0 _pkg_name)
    msg("Finding package ${_pkg_name}")
    hunter_add_package(${_pkg_name})
    find_package(${_pkg_name} CONFIG)
    if (WIN32 OR APPLE)
      if (BUILD_SHARED_LIBS)
        set(_dll_dir ${CMAKE_BINARY_DIR}/${CMAKE_CFG_INTDIR})
        # copy DLLs to build directory to allow tests to run
        get_target_property(_loc ${_pkg} LOCATION)
        file(COPY ${_loc} DESTINATION ${_dll_dir})
      endif()
    endif()
  endforeach()
endmacro()

macro(install_deps deps inc_hdr)
  foreach(_pkg ${deps})
    string(REPLACE ":" ";" _pkg_name ${_pkg})
    list(GET _pkg_name 0 _pkg_name)
    set(_lic "${${_pkg_name}_LICENSES}")
    string(COMPARE EQUAL "${_lic}" "" _has_no_lic)
    string(TOUPPER "${_pkg_name}" _pkg_upper)
    msg("  Installing files for ${_pkg_name} -> ${${_pkg_upper}_ROOT}/; ${inc_hdr}")
    string(COMPARE EQUAL "${inc_hdr}" "INCLUDE_HEADERS" _inc_hdr)
    if (_inc_hdr)
      install(DIRECTORY "${${_pkg_upper}_ROOT}/" DESTINATION . PATTERN licenses* EXCLUDE)
    else()
      install(DIRECTORY "${${_pkg_upper}_ROOT}/" DESTINATION . PATTERN licenses* EXCLUDE PATTERN include* EXCLUDE)
    endif()
    if (NOT _has_no_lic)
      msg("  Installing license for ${_pkg_name} -> ${_lic}")
      install(FILES "${_lic}" DESTINATION share/<PKG> RENAME "LICENSE.${_pkg_name}")
    endif()
  endforeach()
endmacro()
