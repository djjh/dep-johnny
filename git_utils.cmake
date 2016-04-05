include(CMakeParseArguments)

find_package(Git REQUIRED)

function(git_is_repo)
	# parse arguments
	set(options "")
	set(oneValueArgs DIR
		             IS_REPO_VARIABLE)
	set(multiValueArgs "")
	cmake_parse_arguments(ARG
		                  "${options}"
	                      "${oneValueArgs}"
	                      "${multiValueArgs}"
	                      ${ARGN})

	# execute git command
	set(GIT_COMMAND ${GIT_EXECUTABLE}
		            --git-dir=${ARG_DIR}/.git
		            --work-tree=${ARG_DIR}
		            status)
	execute_process(COMMAND ${GIT_COMMAND}
	                RESULT_VARIABLE RESULT
	                OUTPUT_VARIABLE OUTPUT
	                ERROR_VARIABLE ERROR)

	# return result
	if ("${RESULT}" EQUAL 0)
		set(${ARG_IS_REPO_VARIABLE} 1 PARENT_SCOPE)
	else()
		set(${ARG_IS_REPO_VARIABLE} 0 PARENT_SCOPE)
	endif()
endfunction()

#function(git_is_clean) git diff-index --quiet HEAD --> 0 if no differences...

function(git_repo_url GIT_REPO_DIR GIT_URL_VARIABLE)
	# get repo branch
	set(GIT_COMMAND ${GIT_EXECUTABLE}
		            --git-dir=${GIT_REPO_DIR}/.git
		            --work-tree=${GIT_REPO_DIR}
		            config --get remote.origin.url)
	execute_process(COMMAND ${GIT_COMMAND}
	                RESULT_VARIABLE EP_RESULT
	                OUTPUT_VARIABLE EP_OUTPUT
	                ERROR_VARIABLE EP_ERROR
	                OUTPUT_STRIP_TRAILING_WHITESPACE)
	if (NOT "${EP_RESULT}" EQUAL 0)
		return()
	endif()
	set(${GIT_URL_VARIABLE} "${EP_OUTPUT}" PARENT_SCOPE)
endfunction()

function(git_branch_name GIT_REPO_DIR GIT_BRANCH_VARIABLE)
	# get repo branch
	set(GIT_COMMAND ${GIT_EXECUTABLE}
		            --git-dir=${GIT_REPO_DIR}/.git
		            --work-tree=${GIT_REPO_DIR}
		            rev-parse --abbrev-ref HEAD)
	execute_process(COMMAND ${GIT_COMMAND}
	                RESULT_VARIABLE EP_RESULT
	                OUTPUT_VARIABLE EP_OUTPUT
	                ERROR_VARIABLE EP_ERROR
	                OUTPUT_STRIP_TRAILING_WHITESPACE)
	if (NOT "${EP_RESULT}" EQUAL 0)
		return()
	endif()
	# string(STRIP "${EP_OUTPUT}" EP_OUTPUT)  # added OUTPUT_STRIP_TRAILING_WHITESPACE above
	set(${GIT_BRANCH_VARIABLE} "${EP_OUTPUT}" PARENT_SCOPE)
endfunction()

function(git_commit_hash GIT_REPO_DIR GIT_COMMIT_VARIABLE GIT_SHORT_COMMIT_VARIABLE)
	# get repo commit
	set(GIT_COMMAND ${GIT_EXECUTABLE} --git-dir=${GIT_REPO_DIR}/.git --work-tree=${GIT_REPO_DIR} rev-parse HEAD)
	execute_process(COMMAND ${GIT_COMMAND}
	                RESULT_VARIABLE EP_RESULT
	                OUTPUT_VARIABLE EP_OUTPUT
	                ERROR_VARIABLE EP_ERROR
	                OUTPUT_STRIP_TRAILING_WHITESPACE)
	set(${GIT_COMMIT_VARIABLE} "${EP_OUTPUT}" PARENT_SCOPE)

	# get repo commit
	set(GIT_COMMAND ${GIT_EXECUTABLE} --git-dir=${GIT_REPO_DIR}/.git --work-tree=${GIT_REPO_DIR} rev-parse --short HEAD)
	execute_process(COMMAND ${GIT_COMMAND}
	                RESULT_VARIABLE EP_RESULT
	                OUTPUT_VARIABLE EP_OUTPUT
	                ERROR_VARIABLE EP_ERROR
	                OUTPUT_STRIP_TRAILING_WHITESPACE)
	set(${GIT_SHORT_COMMIT_VARIABLE} "${EP_OUTPUT}" PARENT_SCOPE)
endfunction()

function(git_clone)
	set(options "")
	set(oneValueArgs URL
		             BRANCH
		             COMMIT
		             DIR
		             SUCCESS_VARIABLE
		             OUTPUT_VARIABLE
		             ERROR_VARIABLE)
	# parse arguments
	set(multiValueArgs "")
	cmake_parse_arguments(ARG
		                  "${options}"
		                  "${oneValueArgs}"
		                  "${multiValueArgs}"
		                  ${ARGN})

	# enforce required arguments
	if ("${ARG_URL}" STREQUAL "")
		message(FATAL_ERROR "git_clone missing required argument: URL")
	endif()
	if ("${ARG_DIR}" STREQUAL "")
		message(FATAL_ERROR "git_clone missing required argument: DIR")
	endif()

	# attempt to clone repo, with branch if provided
	if (NOT "${ARG_BRANCH}" STREQUAL "")
		set(GIT_COMMAND ${GIT_EXECUTABLE}
			            clone
			            -b ${ARG_BRANCH}
			            ${ARG_URL}
			            ${ARG_DIR})
	else()
		set(GIT_COMMAND ${GIT_EXECUTABLE}
			            clone
			            ${ARG_URL}
			            ${ARG_DIR})
	endif()
	execute_process(COMMAND ${GIT_COMMAND}
	                RESULT_VARIABLE RESULT
	                OUTPUT_VARIABLE OUTPUT
	                ERROR_VARIABLE ERROR)
	if (NOT "${RESULT}" EQUAL 0)
		set(${ARG_SUCCESS_VARIABLE} 0 PARENT_SCOPE)
		set(${ARG_OUTPUT_VARIABLE} "${OUTPUT}" PARENT_SCOPE)
		set(${ARG_ERROR_VARIABLE} "${ERROR}" PARENT_SCOPE)
		return()
	endif()

	if (NOT "${ARG_COMMIT}" STREQUAL "")
		set(GIT_COMMAND ${GIT_EXECUTABLE} 
			             --git-dir=${ARG_DIR}/.git
			             --work-tree=${ARG_DIR}
			             reset --hard ${ARG_COMMIT})
		execute_process(COMMAND ${GIT_COMMAND}
		                RESULT_VARIABLE RESULT
		                OUTPUT_VARIABLE OUTPUT
		                ERROR_VARIABLE ERROR)
		if (NOT "${RESULT}" EQUAL 0)
			file(REMOVE_RECURSE ${ARG_DIR})
			set(${ARG_SUCCESS_VARIABLE} 0 PARENT_SCOPE)
			set(${ARG_OUTPUT_VARIABLE} "${OUTPUT}" PARENT_SCOPE)
			set(${ARG_ERROR_VARIABLE} "${ERROR}" PARENT_SCOPE)
			return()
		endif()
		set(GIT_COMMAND ${GIT_EXECUTABLE} 
			             --git-dir=${ARG_DIR}/.git
			             --work-tree=${ARG_DIR}
			             pull)
		execute_process(COMMAND ${GIT_COMMAND}
		                RESULT_VARIABLE RESULT
		                OUTPUT_VARIABLE OUTPUT
		                ERROR_VARIABLE ERROR)
		if (NOT "${RESULT}" EQUAL 0)
			file(REMOVE_RECURSE ${ARG_DIR})
			set(${ARG_SUCCESS_VARIABLE} 0 PARENT_SCOPE)
			set(${ARG_OUTPUT_VARIABLE} "${OUTPUT}" PARENT_SCOPE)
			set(${ARG_ERROR_VARIABLE} "${ERROR}" PARENT_SCOPE)
			return()
		endif()
	endif()

	set(${ARG_SUCCESS_VARIABLE} 1 PARENT_SCOPE)
endfunction()

function(ensure_git_dep)
	# parse arguments
	set(options "")
	set(oneValueArgs URL
		             BRANCH
		             COMMIT
		             DIR
		             SUCCESS_VARIABLE
		             OUTPUT_VARIABLE
		             ERROR_VARIABLE)
	set(multiValueArgs "")
	cmake_parse_arguments(ARG
		                  "${options}"
		                  "${oneValueArgs}"
		                  "${multiValueArgs}"
		                  ${ARGN})

	# enforce required arguments
	if ("${ARG_URL}" STREQUAL "")
		message(FATAL_ERROR "ensure_git_dep missing required argument: URL")
	endif()
	if ("${ARG_DIR}" STREQUAL "")
		message(FATAL_ERROR "ensure_git_dep missing required argument: DIR")
	endif()

	# attempt to clone or update repo branch and commit if needed
	git_is_repo(DIR ${ARG_DIR}
		        IS_REPO_VARIABLE IS_REPO)
	if (NOT ${IS_REPO})
		# repo doesn't exist, clone it
		git_clone(URL ${ARG_URL}
				  BRANCH ${ARG_BRANCH}
				  COMMIT "${ARG_COMMIT}"
				  DIR ${ARG_DIR}
				  SUCCESS_VARIABLE SUCCESS
				  OUTPUT_VARIABLE OUTPUT
				  ERROR_VARIABLE ERROR)
		if (NOT ${SUCCESS})
			set(${ARG_SUCCESS_VARIABLE} 0 PARENT_SCOPE)
			set(${ARG_OUTPUT_VARIABLE} "${OUTPUT}" PARENT_SCOPE)
			set(${ARG_ERROR_VARIABLE} "${ERROR}" PARENT_SCOPE)
			return()
		endif()
	else()
		# repo exists, update branch and commit if needed
		if (NOT "${ARG_BRANCH}" STREQUAL "")
			git_branch_name(${ARG_DIR} BRANCH)
			if (NOT "${BRANCH}" STREQUAL "${ARG_BRANCH}")
				set(${ARG_SUCCESS_VARIABLE} 0 PARENT_SCOPE)
				set(${ARG_OUTPUT_VARIABLE} "On banch ${BRANCH}, not ${ARG_BRANCH}." PARENT_SCOPE)
				set(${ARG_ERROR_VARIABLE} "On banch ${BRANCH}, not ${ARG_BRANCH}." PARENT_SCOPE)
				return()
			endif()
		endif()

		# repo exists, update commmit if needed
		if (NOT "${ARG_COMMIT}" STREQUAL "")
			git_commit_hash(${ARG_DIR} COMMIT SHORT_COMMIT)
			if (NOT "${COMMIT}" STREQUAL "${ARG_COMMIT}" AND
				NOT "${SHORT_COMMIT}" STREQUAL "${ARG_COMMIT}")
				set(${ARG_OUTPUT_VARIABLE} "On commit ${COMMIT}, which not equivalent to ${ARG_COMMIT}." PARENT_SCOPE)
				set(${ARG_ERROR_VARIABLE} "On commit ${COMMIT}, which not equivalent to ${ARG_COMMIT}." PARENT_SCOPE)
				set(${ARG_SUCCESS_VARIABLE} 0 PARENT_SCOPE)
				return()
			endif()
		endif()
	endif()

	set(${ARG_SUCCESS_VARIABLE} 1 PARENT_SCOPE)
endfunction()
