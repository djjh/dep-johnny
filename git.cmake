# CMake script for ensuring a list of git repos exist
# at a location and on a specific branch/commit if
# required.
#
# Example Usage:
# execute_process(COMMAND ${CMAKE_COMMAND}
# 	                      -DDEP_OUTPUT_DIR=<directory to output repos to>
# 	                      -DDEP_INPUT_FILE=<file with repo information>
# 	                      -P <this file>)
#
# where DEP_INPUT_FILE is a cmake file, for example:
# deps.cmake:
# - - - - - - - - - - - - - - - - - - - - - - - - -
# # glfw
# set(GLFW_URL https://github.com/glfw/glfw.git)
# set(GLFW_BRANCH master)
# set(GLFW_DIRNAME glfw)

# # glad
# set(GLAD_URL https://github.com/Dav1dde/glad.git)
# set(GLAD_BRANCH master)
# set(GLAD_DIRNAME glad)

# set(REPOS GLFW GLAD)
# - - - - - - - - - - - - - - - - - - - - - - - - -

# # enforce required arguments
# if ("${DEP_OUTPUT_DIR}" STREQUAL "")
# 	message(FATAL_ERROR "must pass OUTPUT_DIR using -D")
# endif()
# if ("${DEP_INPUT_FILE}" STREQUAL "")
# 	message(FATAL_ERROR "must pass DEP_INPUT_FILE using -D")
# endif()

# # include git utilities
# include(${CMAKE_CURRENT_LIST_DIR}/git_utils.cmake)

# # include git dependency information defined in input file
# include(${DEP_INPUT_FILE})

# # get all the dependencies
# foreach(REPO ${REPOS})
# 	if (NOT "${${REPO}_DIRNAME}" STREQUAL "")
# 		set(${REPO}_DIR "${DEP_OUTPUT_DIR}/${${REPO}_DIRNAME}")
# 	endif()
# 	ensure_git_dep(URL "${${REPO}_URL}"
# 		           BRANCH "${${REPO}_BRANCH}"
# 		           COMMIT "${${REPO}_COMMIT}"
# 		           DIR "${${REPO}_DIR}"
# 		           SUCCESS_VARIABLE "${REPO}_SUCCESS"
# 		           OUTPUT_VARIABLE "${REPO}_OUPUT"
# 		           ERROR_VARIABLE "${REPO}_ERROR")
# 	if (NOT ${${REPO}_SUCCESS})
# 		message("${REPO}_OUTPUT: ${${REPO}_OUTPUT}")
# 		message("${REPO}_ERROR: ${${REPO}_ERROR}")
# 	endif()
# endforeach()

# include git utilities
include(${CMAKE_CURRENT_LIST_DIR}/git_utils.cmake)

# enforce required arguments
if ("${URL}" STREQUAL "")
	message(FATAL_ERROR "must pass URL using -D")
endif()
if ("${DIR}" STREQUAL "")
	message(FATAL_ERROR "must pass DIR using -D")
endif()

# get all the dependencies
ensure_git_dep(URL "${URL}"
	           BRANCH "${BRANCH}"
	           COMMIT "${COMMIT}"
	           DIR "${DIR}"
	           SUCCESS_VARIABLE "SUCCESS"
	           OUTPUT_VARIABLE "OUPUT"
	           ERROR_VARIABLE "ERROR")
if (NOT ${SUCCESS})
	message("OUTPUT: ${OUTPUT}")
	message("ERROR: ${ERROR}")
endif()
