#
#	MIT License
#
#	Copyright (c) 2018 Celestin de Villa
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#	
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.
#

#
# Qt
# http://doc.qt.io/qt-5/qtmodules.html
# http://doc.qt.io/qt-5/cmake-manual.html#imported-targets
#

if (MK_QT)
	set(CMAKE_INCLUDE_CURRENT_DIR ON)

	# Setting Qt related target properties (AUTOMOC, AUTORCC, AUTOUIC)
	# https://cmake.org/cmake/help/latest/prop_tgt/AUTOMOC.html
	# https://cmake.org/cmake/help/latest/prop_tgt/AUTORCC.html
	# https://cmake.org/cmake/help/latest/prop_tgt/AUTOUIC.html
	# These properties are automatically set if the following variables are set before adding the target
	# set(CMAKE_AUTOMOC ON)
	# set(CMAKE_AUTORCC ON)
	# set(CMAKE_AUTOUIC ON)

	set_target_properties(${PROJECT_NAME} PROPERTIES AUTOMOC ON)
	set_target_properties(${PROJECT_NAME} PROPERTIES AUTORCC ON)
	set_target_properties(${PROJECT_NAME} PROPERTIES AUTOUIC ON)

	# Find Qt5

	set(Qt5_DIR $ENV{MK_QT_DIR}/lib/cmake/Qt5)
	find_package(Qt5 COMPONENTS ${MK_QT} REQUIRED)

	if (NOT Qt5_FOUND)
		mk_message(FATAL_ERROR "Qt5 libraries cannot be found!")
		return()
	endif ()

	mk_message(STATUS "Found Qt5 version ${Qt5_VERSION}")

	# This is not required, since target_link_libraries does this automatically
	#compile_options(${PROJECT_NAME} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS})

	# Link and deploy required Qt libraries

	set(MK_QT_MODULES Bluetooth Charts Concurrent Core DataVisualization DBus Designer Gamepad Gui Help LinguistTools Location MacExtras Multimedia MultimediaWidgets Network NetworkAuth Nfc OpenGL OpenGLExtensions Positioning PositioningQuick PrintSupport Purchasing Qml Quick QuickCompiler QuickControls2 QuickTest QuickWidgets RemoteObjects RepParser Script ScriptTools Scxml Sensors SerialBus SerialPort Sql Svg Test TextToSpeech UiPlugin UiTools WebChannel WebEngine WebEngineCore WebEngineWidgets WebSockets WebView Widgets Xml XmlPatterns 3DAnimation 3DCore 3DExtras 3DInput 3DLogic 3DQuick 3DQuickAnimation 3DQuickExtras 3DQuickInput 3DQuickRender 3DQuickScene2D 3DRender)

	foreach (QT_MODULE ${MK_QT})
		if (NOT ${QT_MODULE} IN_LIST MK_QT_MODULES)
			mk_message(SEND_ERROR "Skipping invalid Qt module: ${QT_MODULE}")
			continue()
		endif ()
		
		target_link_libraries(${PROJECT_NAME} Qt5::${QT_MODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
		mk_target_deploy_libraries(${PROJECT_NAME} Qt5::${QT_MODULE})
	endforeach ()
endif ()
