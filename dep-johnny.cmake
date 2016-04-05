include(CMakeParseArguments)

set(DEP_JOHNNY_DIR ${CMAKE_CURRENT_LIST_DIR})

function(johnny_get_deps_from_file)
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

function(johnny_get_dep)
	# parse arguments
	set(options "")
	set(oneValueArgs URL
		             BRANCH
		             COMMIT
		             DIR)
	set(multiValueArgs "")
	cmake_parse_arguments(ARG
		                  "${options}"
	                      "${oneValueArgs}"
	                      "${multiValueArgs}"
	                      ${ARGN})

	# enforce required arguments
	if ("${ARG_URL}" STREQUAL "")
		message(FATAL_ERROR "johnny_get_dep missing required argument: URL")
	endif()
	if ("${ARG_DIR}" STREQUAL "")
		message(FATAL_ERROR "johnny_get_dep missing required argument: DIR")
	endif()

	message("get that dep johnny...")
	execute_process(COMMAND ${CMAKE_COMMAND}
	                        -DURL=${ARG_URL}
	                        -DBRANCH=${ARG_BRANCH}
	                        -DCOMMIT=${ARG_COMMIT}
	                        -DDIR=${ARG_DIR}
	                        -P ${DEP_JOHNNY_DIR}/git.cmake)
endfunction()