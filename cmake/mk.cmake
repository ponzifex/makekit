cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

enable_language(C)
enable_language(CXX)

if (MAKEKIT_ASM)
    enable_language(ASM)
endif ()

if (MAKEKIT_CUDA)
    enable_language(CUDA)
endif ()

#
# Output directories
#

# The CMAKE_ARCHIVE_OUTPUT_DIRECTORY variable is used to initialize the ARCHIVE_OUTPUT_DIRECTORY property on all the targets.
# ARCHIVE_OUTPUT_DIRECTORY property specifies the directory into which archive target files should be built.
# An archive output artifact of a buildsystem target may be:
# The static library file (e.g. .lib or .a) of a static library target created by the add_library() command with the STATIC option.
# On DLL platforms: the import library file (e.g. .lib) of a shared library target created by the add_library() command with the SHARED option.
# On DLL platforms: the import library file (e.g. .lib) of an executable target created by the add_executable() command when its ENABLE_EXPORTS target property is set.
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# The CMAKE_LIBRARY_OUTPUT_DIRECTORY variable is used to initialize the LIBRARY_OUTPUT_DIRECTORY property on all the targets.
# LIBRARY_OUTPUT_DIRECTORY property specifies the directory into which library target files should be built.
# A library output artifact of a buildsystem target may be:
# The loadable module file (e.g. .dll or .so) of a module library target created by the add_library() command with the MODULE option.
# On non-DLL platforms: the shared library file (e.g. .so or .dylib) of a shared shared library target created by the add_library() command with the SHARED option.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# The CMAKE_RUNTIME_OUTPUT_DIRECTORY variable is used to initialize the RUNTIME_OUTPUT_DIRECTORY property on all the targets.
# RUNTIME_OUTPUT_DIRECTORY property specifies the directory into which runtime target files should be built.
# A runtime output artifact of a buildsystem target may be:
# The executable file (e.g. .exe) of an executable target created by the add_executable() command.
# On DLL platforms: the executable file (e.g. .dll) of a shared library target created by the add_library() command with the SHARED option.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

#
# Language standard
#

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

#
# OS Platform Detection
#

if (CMAKE_HOST_WIN32) # True if the host system is running Windows, including Windows 64-bit and MSYS, but false on Cygwin.
    message(STATUS "Detected OS: Windows")
    set(MAKEKIT_OS_WINDOWS 1)
    set(MAKEKIT_RUNTIME_LIBRARY_EXTENSION .dll)
elseif (CMAKE_HOST_UNIX) # True for UNIX and UNIX like operating systems, including APPLE operation systems and Cygwin.
    set(MAKEKIT_OS_UNIX 1)
    if (CMAKE_HOST_APPLE) # True for Apple macOS operation systems.
        message(STATUS "Detected OS: macOS")
        set(MAKEKIT_OS_MACOS 1)
	set(MAKEKIT_RUNTIME_LIBRARY_EXTENSION .dylib)
    else ()
        message(STATUS "Detected OS: Unix/Linux")
        set(MAKEKIT_OS_LINUX 1)
	set(MAKEKIT_RUNTIME_LIBRARY_EXTENSION .so)
    endif ()
endif ()

#
# Include custom build types (compiler, linker and other flags)
#

#set(CMAKE_CXX_FLAGS "/DWIN64 /D_WINDOWS /Wall /GR /EHsc" CACHE INTERNAL "")
#set (CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/CompilerOptions.cmake")
include(CustomBuilds.cmake OPTIONAL)

#
# Find source
#

file(GLOB_RECURSE CXX_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.cc *.cpp *.cxx)
file(GLOB_RECURSE CXX_HEADERS RELATIVE ${MAKEKIT_SOURCE} *.h *.hh *.hpp *.hxx)
file(GLOB_RECURSE CXX_INLINES RELATIVE ${MAKEKIT_SOURCE} *.inc *.inl *.ipp *.ixx *.tcc *.tpp *.txx)
if (MAKEKIT_OS_WINDOWS)
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MAKEKIT_SOURCE} *.obj)
else ()
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MAKEKIT_SOURCE} *.o)
endif ()

if (MAKEKIT_ASM)
	file(GLOB_RECURSE ASM_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.asm *.s)
endif ()
	
if (MAKEKIT_CUDA)
	file(GLOB_RECURSE CUDA_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.cu)
endif ()

#
# Excluding CMake generated files from source for safety
#

list(FILTER CXX_SOURCES EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_HEADERS EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_INLINES EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_OBJECTS EXCLUDE REGEX ".*CMakeFiles/.*")

#
# Macros
#

set(MAKEKIT_DEPLOY_FILES "")

macro(makekit_deploy_libraries LIBRARIES)
    set(MAKEKIT_DEPLOY_FILES ${MAKEKIT_DEPLOY_FILES} ${LIBRARIES})
    #list(APPEND MAKEKIT_DEPLOY_FILES ${LIBRARIES})
endmacro()

macro(makekit_deploy_imported_libraries LIBRARIES)
    foreach (LIBRARY "${LIBRARIES}")
        get_property(LIBRARY_IMPORTED_LOCATION TARGET ${LIBRARY} PROPERTY IMPORTED_LOCATION_RELEASE)
        message(STATUS "Adding to deploy list: ${LIBRARY_IMPORTED_LOCATION}")
	    makekit_deploy_libraries(${LIBRARY_IMPORTED_LOCATION})
    endforeach ()
endmacro()

#
# Qt5
#

if (MAKEKIT_QT)
    file(GLOB_RECURSE CXX_UIFILES RELATIVE ${MAKEKIT_SOURCE} *.ui)
 
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOUIC ON)

    set(CMAKE_INCLUDE_CURRENT_DIR ON)
    #set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS}")

    if (MAKEKIT_OS_WINDOWS)
        if (MSYS)
	    # Using MSYS MinGW-w64 toolchain, CMake will automatically find the Qt5 CMake configs
            #set(Qt5_DIR "C:/msys64/mingw64/lib/cmake/Qt5/")
        else ()
	    # Using Visual C++ toolchain
            set(Qt5_DIR "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
        endif ()
    endif ()

    find_package(Qt5 COMPONENTS ${MAKEKIT_QT} REQUIRED)

    if (NOT Qt5_FOUND)
        message(FATAL_ERROR "Qt5 cannot be found!")
    endif ()

    # Not required when CMAKE_AUTOUIC is ON
    #qt5_wrap_ui(CXX_QT_GENS ${CXX_UIFILES})
endif ()

#
# Add target
#

if (CXX_SOURCES)
    if (${MAKEKIT_MODULE_MODE} STREQUAL "NONE")
            # Do nothing
	elseif (${MAKEKIT_MODULE_MODE} STREQUAL "EXECUTABLE")
            add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
    else ()
            if (${MAKEKIT_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
                    set(MAKEKIT_MODULE_VISIBILITY INTERFACE)
            elseif (${MAKEKIT_MODULE_MODE} STREQUAL "STATIC_LIBRARY")
                    set(MAKEKIT_MODULE_VISIBILITY STATIC)
            elseif (${MAKEKIT_MODULE_MODE} STREQUAL "SHARED_LIBRARY")
                    set(MAKEKIT_MODULE_VISIBILITY SHARED)
            endif()

            add_library(${PROJECT_NAME} ${MAKEKIT_MODULE_VISIBILITY} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
            
			# For header-only libraries this line is required
			if (${MAKEKIT_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
				target_include_directories(${PROJECT_NAME} INTERFACE ${CXX_HEADERS} ${CXX_INLINES})
			endif ()
    endif ()
else ()
    message(STATUS "MakeKit: No C/C++ sources found.")
endif ()

#
# Set linker language for cases when it cannot be determined
# (for example when the source consists precompiled object files only)
#

#get_target_property(MAKEKIT_LINKER_LANGUAGE ${PROJECT_NAME} LINKER_LANGUAGE)
#message(${MAKEKIT_LINKER_LANGUAGE})
#if (${MAKEKIT_LINKER_LANGUAGE} STREQUAL "NOTFOUND")
#    set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
#endif()
#set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY LINKER_LANGUAGE CXX)

#
# OpenCL
# https://cmake.org/cmake/help/v3.10/module/FindOpenCL.html
#

if (MAKEKIT_OPENCL)
    find_package(OpenCL REQUIRED)
    if (OpenCL_FOUND)
        target_link_libraries(${PROJECT_NAME} OpenCL::OpenCL)
    else ()
	message(FATAL_ERROR "OpenCL cannot be found!")
    endif ()
endif ()

#
# OpenGL
# https://cmake.org/cmake/help/v3.10/module/FindOpenGL.html
#

if (MAKEKIT_OPENGL)
    find_package(OpenGL REQUIRED)
    if (OpenGL_FOUND)
        if (OpenGL::OpenGL)
			target_link_libraries(${PROJECT_NAME} OpenGL::OpenGL)
        else ()
			target_link_libraries(${PROJECT_NAME} OpenGL::GL)
        endif ()
    else ()
	    message(FATAL_ERROR "OpenGL cannot be found!")
    endif ()
endif ()

#
# OpenMP
# https://cmake.org/cmake/help/v3.10/module/FindOpenMP.html
#

if (MAKEKIT_OPENMP)
    if (1) # Use LLVM libomp
        if (MAKEKIT_OS_WINDOWS)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Xclang -fopenmp")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xclang -fopenmp")
        elseif (MAKEKIT_OS_MACOS)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp=libomp")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp=libomp")
        else ()
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp=libomp")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp=libomp")
        endif ()

        set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "") # Append empty string to the list of library prefixes
        find_library(MAKEKIT_LIBOMP_LIB libomp PATHS $ENV{MAKEKIT_LLVM_DIR}/lib NO_DEFAULT_PATH REQUIRED)

        if (MAKEKIT_LIBOMP_LIB)
            target_link_libraries(${PROJECT_NAME} ${MAKEKIT_LIBOMP_LIB})
            makekit_deploy_libraries(${MAKEKIT_LIBOMP_LIB})
        else ()
            message(FATAL_ERROR "OpenMP (libomp) cannot be found!")
        endif ()
    else ()
        find_package(OpenMP REQUIRED)
        if (OpenMP_FOUND)
            target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
        else ()
            message(FATAL_ERROR "OpenMP cannot be found!")
        endif ()
    endif ()
endif ()

#
# Vulkan
# https://cmake.org/cmake/help/v3.10/module/FindVulkan.html
#

if (MAKEKIT_VULKAN)
    find_package(Vulkan REQUIRED)
    if (Vulkan_FOUND)
        target_link_libraries(${PROJECT_NAME} Vulkan::Vulkan)
    else ()
	    message(FATAL_ERROR "Vulkan cannot be found!")
    endif ()
endif ()

#
# Qt
#

if (MAKEKIT_QT)
    foreach (QTMODULE ${MAKEKIT_QT})
        target_link_libraries(${PROJECT_NAME} Qt5::${QTMODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
        #makekit_copy_shared_library(${PROJECT_NAME} Qt5::${QTMODULE})
	    makekit_deploy_imported_libraries(Qt5::${QTMODULE})
    endforeach ()
endif ()

#
# Custom pre-build commands
#

#
# Post-build deploy
#

if (MAKEKIT_AUTODEPLOY)
    message("Deploying files: ${MAKEKIT_DEPLOY_FILES}")

    foreach (FILE ${MAKEKIT_DEPLOY_FILES})
        if (IS_ABSOLUTE ${FILE})
            set(FILE_ABSOLUTE_PATH ${FILE})
        else ()
            find_file(FILE_ABSOLUTE_PATH ${FILE})
        endif ()

        if (FILE_ABSOLUTE_PATH)
            get_filename_component(FILE_NAME ${FILE} NAME)
            add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FILE_ABSOLUTE_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${FILE_NAME})
        else ()
            message(FATAL_ERROR "File ${FILE} cannot be found!")
        endif ()
    endforeach ()
endif ()