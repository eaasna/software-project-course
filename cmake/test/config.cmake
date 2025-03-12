# SPDX-FileCopyrightText: 2006-2025 Knut Reinert & Freie Universität Berlin
# SPDX-FileCopyrightText: 2016-2025 Knut Reinert & MPI für molekulare Genetik
# SPDX-License-Identifier: CC0-1.0

list (APPEND CMAKE_CTEST_ARGUMENTS "--output-on-failure") # Must be before `enable_testing ()`.
list (APPEND CMAKE_CTEST_ARGUMENTS "--no-tests=error") # Must be before `enable_testing ()`.
CPMGetPackage (googletest)

enable_testing ()

# Set directories for test output files, input data and binaries.
file (MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/output)
add_definitions (-DOUTPUTDIR=\"${CMAKE_CURRENT_BINARY_DIR}/output/\")
add_definitions (-DDATADIR=\"${CMAKE_CURRENT_BINARY_DIR}/data/\")
add_definitions (-DBINDIR=\"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/\")

# Add the test interface library.
if (NOT TARGET software-project-course_test)
    add_library (software-project-course_test INTERFACE)
    target_link_libraries (software-project-course_test INTERFACE GTest::gtest_main software-project-course_lib)
    add_library (software-project-course::test ALIAS software-project-course_test)
endif ()

# Add the check target that builds and runs tests.
add_custom_target (check COMMAND ${CMAKE_CTEST_COMMAND} ${CMAKE_CTEST_ARGUMENTS})

get_directory_property (software-project-course_targets DIRECTORY "${software-project-course_SOURCE_DIR}/src" BUILDSYSTEM_TARGETS)
foreach (target IN LISTS software-project-course_targets)
    get_target_property (type ${target} TYPE)
    if (type STREQUAL "EXECUTABLE")
        list (APPEND software-project-course_EXECUTABLE_LIST ${target})
    endif ()
endforeach ()
unset (software-project-course_targets)

macro (add_app_test test_filename)
    file (RELATIVE_PATH source_file "${software-project-course_SOURCE_DIR}" "${CMAKE_CURRENT_LIST_DIR}/${test_filename}")
    get_filename_component (target "${source_file}" NAME_WE)

    add_executable (${target} ${test_filename})
    target_link_libraries (${target} software-project-course::test)

    add_dependencies (${target} ${software-project-course_EXECUTABLE_LIST})
    add_dependencies (check ${target})

    add_test (NAME ${target} COMMAND ${target})

    unset (source_file)
    unset (target)
endmacro ()
