include(CMakeParseArguments)

set(DEP_JOHNNY_DIR ${CMAKE_CURRENT_LIST_DIR})

function(johnny_get_dep)
	# parse arguments
	set(options "")
	set(oneValueArgs DEP_DIR
		             GIT_DEP_FILE)
	set(multiValueArgs "")
	cmake_parse_arguments(ARG
		                  "${options}"
	                      "${oneValueArgs}"
	                      "${multiValueArgs}"
	                      ${ARGN})

	# enforce required arguments
	if ("${ARG_DEP_DIR}" STREQUAL "")
		message(FATAL_ERROR "johnny_get_dep missing required argument: DEP_DIR")
	endif()
	if ("${ARG_GIT_DEP_FILE}" STREQUAL "")
		message(FATAL_ERROR "johnny_get_dep missing required argument: GIT_DEP_FILE")
	endif()

	# validate arguments
	if (NOT EXISTS ${ARG_GIT_DEP_FILE})
		message(FATAL_ERROR "GIT_DEP_FILE ${ARG_GIT_DEP_FILE} doesn't exist")
	endif()

	message("get those deps johnny...")
	execute_process(COMMAND ${CMAKE_COMMAND}
	                        -DDEP_OUTPUT_DIR=${ARG_DEP_DIR}
	                        -DDEP_INPUT_FILE=${ARG_GIT_DEP_FILE}
	                        -P ${DEP_JOHNNY_DIR}/git.cmake
	                        VERBATIM "dfds")
endfunction()