﻿cmake_minimum_required(VERSION 3.5.2)

#VC-LTL核心版本号，由于4.X并不兼容3.X。此值可以用于兼容性判断。
set(LTL_CoreVersion 5)

if(NOT SupportWinXP)
	set(SupportWinXP "false")
endif()


if(NOT SupportLTL)
	set(SupportLTL "true")
endif()

if(NOT CleanImport)
	set(CleanImport "false")
endif()

if(${SupportLTL} STREQUAL "true")
	if(NOT CMAKE_SYSTEM_NAME)
		message(WARNING "VC-LTL not load, because CMAKE_SYSTEM_NAME is not defined!!!")
		set(SupportLTL "false")
	elseif(NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
		message(WARNING "VC-LTL not load, because ${CMAKE_SYSTEM_NAME} is not supported!!!")
		set(SupportLTL "false")
	endif()
endif()


if(${SupportLTL} STREQUAL "true")
	if(LTLPlatform)
		#外部已经定义
	elseif(CMAKE_GENERATOR_PLATFORM)
		# -A 参数已经传递，仅在 CMake 3.1更高版本中支持
		message("CMAKE_GENERATOR_PLATFORM = " ${CMAKE_GENERATOR_PLATFORM})
		if(${CMAKE_GENERATOR_PLATFORM} STREQUAL "Win32")
			set(LTLPlatform "Win32")
		elseif(${CMAKE_GENERATOR_PLATFORM} STREQUAL "x64")
			set(LTLPlatform "x64")
		elseif(${CMAKE_GENERATOR_PLATFORM} STREQUAL "arm")
			set(LTLPlatform "arm")
		elseif(${CMAKE_GENERATOR_PLATFORM} STREQUAL "arm64")
			set(LTLPlatform "arm64")
		else()
			message(WARNING "VC-LTL not load, Unknown Platform!!!")
			set(SupportLTL "false")
		endif()
	elseif(CMAKE_VS_PLATFORM_NAME)
		# CMake 3.1以及更早版本不支持 -A 参数，因此通过 CMAKE_VS_PLATFORM_NAME解决
		message("CMAKE_VS_PLATFORM_NAME = " ${CMAKE_VS_PLATFORM_NAME})
		if(${CMAKE_VS_PLATFORM_NAME} STREQUAL "Win32")
			set(LTLPlatform "Win32")
		elseif(${CMAKE_VS_PLATFORM_NAME} STREQUAL "x64")
			set(LTLPlatform "x64")
		elseif(${CMAKE_VS_PLATFORM_NAME} STREQUAL "arm")
			set(LTLPlatform "arm")
		elseif(${CMAKE_VS_PLATFORM_NAME} STREQUAL "arm64")
			set(LTLPlatform "arm64")
		else()
			message(WARNING "VC-LTL not load, Unknown Platform!!!")
			set(SupportLTL "false")
		endif()
	elseif(MSVC_VERSION)
		message("load CheckSymbolExists......")

		include(CheckSymbolExists)

		check_symbol_exists("_M_IX86" "" _M_IX86)
		check_symbol_exists("_M_AMD64" "" _M_AMD64)
		check_symbol_exists("_M_ARM" "" _M_ARM)
		check_symbol_exists("_M_ARM64" "" _M_ARM64)

		if(_M_AMD64)
			set(LTLPlatform "x64")
		elseif(_M_IX86)
			set(LTLPlatform "Win32")
		elseif(_M_ARM)
			set(LTLPlatform "arm")
		elseif(_M_ARM64)
			set(LTLPlatform "arm64")
		else()
			message(WARNING "VC-LTL not load, Unknown Platform!!!")
			set(SupportLTL "false")
		endif()
	elseif(DEFINED ENV{VSCMD_ARG_TGT_ARCH})
		#VSCMD_ARG_TGT_ARCH参数只有2017才有，因此兼容性更差
		message("VSCMD_ARG_TGT_ARCH = " $ENV{VSCMD_ARG_TGT_ARCH})
		set(PlatformShortName $ENV{VSCMD_ARG_TGT_ARCH})
	elseif(DEFINED ENV{LIB})
		#采用更加奇葩发方式，检测lib目录是否包含特定后缀
		message("LIB = $ENV{LIB}")

		string(TOLOWER "$ENV{LIB}" LTL_LIB_TMP)

		if("${LTL_LIB_TMP}" MATCHES "\\x64;")
			set(LTLPlatform "x64")
		elseif("${LTL_LIB_TMP}" MATCHES "\\x86;")
			set(LTLPlatform "Win32")
		elseif("${LTL_LIB_TMP}" MATCHES "\\arm;")
			set(LTLPlatform "arm")
		elseif("${LTL_LIB_TMP}" MATCHES "\\arm64;")
			set(LTLPlatform "arm64")
		elseif("${LTL_LIB_TMP}" MATCHES "\\lib;")
			#为了兼容VS 2015
			set(LTLPlatform "Win32")
		else()
			message(WARNING "VC-LTL not load, Unknown Platform!!!")
			set(SupportLTL "false")
		endif()
	else()
		message(WARNING "VC-LTL not load, Unknown Platform!!!")
		set(SupportLTL "false")
	endif()
endif()


if(${SupportLTL} STREQUAL "true")

	#获取最佳TargetPlatform，一般默认值是 6.0.6000.0
	if(WindowsTargetPlatformMinVersion)
		# 故意不用 VERSION_GREATER_EQUAL，因为它在 3.7 才得到支持
		if(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 10.0.19041.0)
			set(LTLWindowsTargetPlatformMinVersion "10.0.19041.0")
		elseif(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 10.0.10240.0)
			set(LTLWindowsTargetPlatformMinVersion "10.0.10240.0")
		elseif(${LTLPlatform} STREQUAL "arm64")
			set(LTLWindowsTargetPlatformMinVersion "10.0.10240.0")
		elseif(NOT ${WindowsTargetPlatformMinVersion} VERSION_LESS 6.2.9200.0)
			set(LTLWindowsTargetPlatformMinVersion "6.2.9200.0")
		elseif(${LTLPlatform} STREQUAL "arm")
			set(LTLWindowsTargetPlatformMinVersion "6.2.9200.0")
		elseif(NOT ${SupportWinXP} STREQUAL "true")
			set(LTLWindowsTargetPlatformMinVersion "6.0.6000.0")
		elseif(${LTLPlatform} STREQUAL "x64")
			set(LTLWindowsTargetPlatformMinVersion "5.2.3790.0")
		else()
			set(LTLWindowsTargetPlatformMinVersion "5.1.2600.0")
		endif()
	else()
		#默认值
		if(${LTLPlatform} STREQUAL "arm64")
			set(LTLWindowsTargetPlatformMinVersion "10.0.10240.0")
		elseif(${LTLPlatform} STREQUAL "arm")
			set(LTLWindowsTargetPlatformMinVersion "6.2.9200.0")
		elseif(NOT ${SupportWinXP} STREQUAL "true")
			set(LTLWindowsTargetPlatformMinVersion "6.0.6000.0")
		elseif(${LTLPlatform} STREQUAL "x64")
			set(LTLWindowsTargetPlatformMinVersion "5.2.3790.0")
		else()
			set(LTLWindowsTargetPlatformMinVersion "5.1.2600.0")
		endif()
	endif()

	if (NOT EXISTS ${VC_LTL_Root}/TargetPlatform/${LTLWindowsTargetPlatformMinVersion}/lib/${LTLPlatform})
		message(FATAL_ERROR "VC-LTL can't find lib files, please download the binary files from https://github.com/Chuyu-Team/VC-LTL/releases/latest then continue.")
	endif()

	#打印VC-LTL图标
	message("###################################################################################################")
	message("#                                                                                                 #")
	message("#                 *         *      * *             *        * * * * *  *                          #")
	message("#                  *       *     *                 *            *      *                          #")
	message("#                   *     *     *       * * * * *  *            *      *                          #")
	message("#                    *   *       *                 *            *      *                          #")
	message("#                      *           * *             * * * *      *      * * * *                    #")
	message("#                                                                                                 #")
	message("###################################################################################################")

	message("")

	#打印VC-LTL基本信息
	message(" VC-LTL Path          :" ${VC_LTL_Root})
	message(" VC-LTL Tools Version :" $ENV{VCToolsVersion})
	message(" WindowsTargetPlatformMinVersion  :" ${LTLWindowsTargetPlatformMinVersion})
	message(" Platform             :" ${LTLPlatform})
	message("")

    set(VC_LTL_Include ${VC_LTL_Root}/TargetPlatform/header;${VC_LTL_Root}/TargetPlatform/${LTLWindowsTargetPlatformMinVersion}/header)
    set(VC_LTL_Library ${VC_LTL_Root}/TargetPlatform/${LTLWindowsTargetPlatformMinVersion}/lib/${LTLPlatform})

	# 如果开启了 CleanImport 那么优先使用 CleanImport
	if(${CleanImport} STREQUAL "true")
		if(EXISTS ${VC_LTL_Root}/TargetPlatform/${LTLWindowsTargetPlatformMinVersion}/lib/${LTLPlatform}/CleanImport)
			set(VC_LTL_Library ${VC_LTL_Root}/TargetPlatform/${LTLWindowsTargetPlatformMinVersion}/lib/${LTLPlatform}/CleanImport;${VC_LTL_Library})
		endif()
	endif()
	#message("INCLUDE " $ENV{INCLUDE})
	#message("LIB " $ENV{LIB})

	#set( ENV{INCLUDE} ${VC_LTL_Include};$ENV{INCLUDE})
	#set( ENV{LIB} ${VC_LTL_Library};$ENV{LIB})


	#message("INCLUDE " $ENV{INCLUDE})
	#message("LIB " $ENV{LIB})

    include_directories(BEFORE SYSTEM ${VC_LTL_Include})
    link_directories(${VC_LTL_Library})

	#message("INCLUDE " $ENV{INCLUDE})
	#message("LIB " $ENV{LIB})

    if(${SupportWinXP} STREQUAL "true")
       if(${LTLPlatform} STREQUAL "Win32")
			set(LTL_CMAKE_CREATE_WIN32_EXE "/subsystem:windows,5.01")
			set(LTL_CMAKE_CREATE_CONSOLE_EXE "/subsystem:console,5.01")

			set(CMAKE_CREATE_WIN32_EXE "${CMAKE_CREATE_WIN32_EXE} ${LTL_CMAKE_CREATE_WIN32_EXE}")
			set(CMAKE_CREATE_CONSOLE_EXE "${CMAKE_CREATE_CONSOLE_EXE} ${LTL_CMAKE_CREATE_CONSOLE_EXE}")
		elseif(${LTLPlatform} STREQUAL "x64")
			set(LTL_CMAKE_CREATE_WIN32_EXE "/subsystem:windows,5.02")
			set(LTL_CMAKE_CREATE_CONSOLE_EXE "/subsystem:console,5.02")

			set(CMAKE_CREATE_WIN32_EXE "${CMAKE_CREATE_WIN32_EXE} ${LTL_CMAKE_CREATE_WIN32_EXE}")
			set(CMAKE_CREATE_CONSOLE_EXE "${CMAKE_CREATE_CONSOLE_EXE} ${LTL_CMAKE_CREATE_CONSOLE_EXE}")
		endif()
    endif()
endif()
