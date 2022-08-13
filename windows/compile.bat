:: MIT License
::
:: Copyright (C) 2022 by wangwenx190 (Yuhang Zhao)
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.

@echo off
setlocal enabledelayedexpansion
set __compiler=%1
set __lib_type=%2
set __build_type=%3
set __arch=%4
set __module=%5
if /i "%__compiler%" == "/clang-cl" (
    set __compiler=clangcl
) else if /i "%__compiler%" == "/clangcl" (
    set __compiler=clangcl
) else if /i "%__compiler%" == "/clang" (
    set __compiler=clangcl
) else if /i "%__compiler%" == "/mingw-w64" (
    set __compiler=mingw
) else if /i "%__compiler%" == "/mingw64" (
    set __compiler=mingw
) else if /i "%__compiler%" == "/mingw" (
    set __compiler=mingw
) else if /i "%__compiler%" == "/gcc" (
    set __compiler=mingw
) else if /i "%__compiler%" == "/g++" (
    set __compiler=mingw
) else (
    set __compiler=msvc
)
if /i "%__lib_type%" == "/static" (
    set __lib_type=static
) else (
    set __lib_type=shared
)
if /i "%__build_type%" == "/debug" (
    set __build_type=debug
) else if /i "%__build_type%" == "/release" (
    set __build_type=release
) else if /i "%__build_type%" == "/minsizerel" (
    set __build_type=minsizerel
) else if /i "%__build_type%" == "/relwithdebinfo" (
    set __build_type=relwithdebinfo
) else (
    set __build_type=debugandrelease
)
if /i "%__arch%" == "/x86" (
    set __arch=x86
) else if /i "%__arch%" == "/x32" (
    set __arch=x86
) else if /i "%__arch%" == "/i386" (
    set __arch=x86
) else if /i "%__arch%" == "/arm64" (
    set __arch=arm64
) else if /i "%__arch%" == "/arm" (
    set __arch=arm64
) else (
    set __arch=x64
)
if /i "%__module%" == "" (
    set __module=qtbase
)
title Building %__module% ...
set __is_building_qtbase=false
set __is_building_qtwebengine=false
if /i "%__module%" == "qtbase" set __is_building_qtbase=true
if /i "%__module%" == "qtwebengine" set __is_building_qtwebengine=true
:: Or use the official read-only repo: https://code.qt.io/qt/%__module%.git
set __git_clone_url=https://github.com/qt/%__module%.git
:: You can change the branch here, such as 6.3.0, 5.15.3 and etc...
:: However, please make sure you are using a branch name, not a tag name.
set __git_clone_branch=dev
:: Use shallow clone to reduce the download size and time, because we don't need
:: all the git commit history after all, we only need the source code itself.
:: But we don't download the source package directly because the line endings may
:: be incorrect (such as packages packed by GitHub, which will lead to compilation
:: failures) and most importantly, we can still update the local source code through
:: the git tool conveniently.
set __git_clone_params=clone --recurse-submodules --depth 1 --shallow-submodules --branch %__git_clone_branch% --single-branch --no-tags %__git_clone_url%
:: We still need to limit the depth to 1 while fetching, otherwise git will
:: fetch all the commit history again and that's obviously not what we would
:: want to see.
set __git_fetch_params=fetch --depth=1 --no-tags --recurse-submodules=on-demand
:: To be able to update a shallow clone, we need to reset once after fetching from remote.
:: For more details, please refer to: https://stackoverflow.com/questions/41075972/how-to-update-a-git-shallow-clone
set __git_reset_params=reset --hard origin/%__git_clone_branch%
:: Cleanup untracked files, not necessary but recommended.
set __git_clean_params=clean -fdx
set __git_apply_params=apply -v
set __repo_root_dir=%~dp0..
set __repo_contrib_dir=%__repo_root_dir%\contrib\win
set __contrib_bin_dir=%__repo_contrib_dir%\bin
set __repo_build_dir=%__repo_root_dir%\build
set __repo_source_dir=%__repo_build_dir%\source
set __repo_install_dir=%__repo_build_dir%\windows
set __repo_cache_dir=%__repo_build_dir%\cache\windows
set __module_source_dir=%__repo_source_dir%\%__module%
set __module_install_dir=%__repo_install_dir%\%__compiler%_%__arch%_%__lib_type%_%__build_type%
set __module_cache_dir=%__repo_cache_dir%\%__module%
set __vcpkg_dir=%__repo_root_dir%\vcpkg
:: For GitHub Actions, it will always be "C:\vcpkg", normally.
if /i "%GITHUB_ACTIONS%" == "true" set __vcpkg_dir=%VCPKG_INSTALLATION_ROOT%
set __vcpkg_toolchain_file=%__vcpkg_dir%\scripts\buildsystems\vcpkg.cmake
set __vcpkg_triplet=%__arch%
if /i "%__compiler%" == "mingw" (
    set __vcpkg_triplet=%__vcpkg_triplet%-mingw
) else (
    set __vcpkg_triplet=%__vcpkg_triplet%-windows
)
set __vcpkg_triplet=%__vcpkg_triplet%-static
if /i "%__lib_type%" == "shared" set __vcpkg_triplet=%__vcpkg_triplet%-md
set __should_enable_ltcg=true
set __ninja_multi_config=false
:: Increase CMake's message verbosity, it can help us debug configuration errors.
:: But suppress the developer warnings from CMake, it's not useful for us.
:: We must set "VCPKG_TARGET_TRIPLET" otherwise VCPKG will always use the default triplet "x64-windows".
:: Enable VCPKG by setting the "CMAKE_TOOLCHAIN_FILE" variable. We use VCPKG to provide the 3rd party dependencies.
set __cmake_extra_params=--log-level=STATUS -Wno-dev -DVCPKG_TARGET_TRIPLET=%__vcpkg_triplet% -DCMAKE_TOOLCHAIN_FILE="%__vcpkg_toolchain_file%"
:: Set the "CMAKE_PREFIX_PATH" variable so that modules other than QtBase can still find the host Qt SDK we just built.
if /i "%__is_building_qtbase%" == "false" set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_PREFIX_PATH="%__contrib_bin_dir%;%__repo_install_dir%"
set __install_cmdline=
if /i "%__compiler%" == "clangcl" (
    :: Some make tools will not be able to find the compiler if we don't
    :: add the ".exe" extension name to the file name.
    :: No need to set the linker explicitly because CMake will find and
    :: use the proper linker for us, for example, the linker will be set
    :: to "ld.lld.exe" if we are using llvm-mingw.
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_C_COMPILER=clang-cl.exe -DCMAKE_CXX_COMPILER=clang-cl.exe
) else if /i "%__compiler%" == "mingw" (
    :: Don't worry about llvm-mingw, it also has the gcc/g++ wrapper.
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_C_COMPILER=gcc.exe -DCMAKE_CXX_COMPILER=g++.exe
) else (
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_C_COMPILER=cl.exe -DCMAKE_CXX_COMPILER=cl.exe
)
if /i "%__lib_type%" == "static" (
    set __should_enable_ltcg=false
    set __static_lib_flags=-DBUILD_SHARED_LIBS=OFF
    :: "FEATURE_static_runtime" is a QtBase only option.
    :: Other modules will inherit the corresponding parameters from QtBase.
    if /i "%__is_building_qtbase%" == "true" set __static_lib_flags=!__static_lib_flags! -DFEATURE_static_runtime=ON
    set __cmake_extra_params=%__cmake_extra_params% !__static_lib_flags!
) else (
    set __cmake_extra_params=%__cmake_extra_params% -DBUILD_SHARED_LIBS=ON
)
if /i "%__build_type%" == "debug" (
    set __should_enable_ltcg=false
    set __ninja_multi_config=false
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_BUILD_TYPE=Debug -DFEATURE_separate_debug_info=ON -GNinja
) else if /i "%__build_type%" == "minsizerel" (
    set __ninja_multi_config=false
    :: We still set the configuration type to "Release", Qt's own scripts will
    :: modify the compiler flags to match the MinSizeRel mode.
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_BUILD_TYPE=Release -DFEATURE_optimize_size=ON -GNinja
) else if /i "%__build_type%" == "release" (
    set __ninja_multi_config=false
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_BUILD_TYPE=Release -GNinja
) else if /i "%__build_type%" == "relwithdebinfo" (
    set __ninja_multi_config=false
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_BUILD_TYPE=RelWithDebInfo -DFEATURE_separate_debug_info=ON -GNinja
) else (
    set __ninja_multi_config=true
    :: The first one among the configuration types will be the main configuration,
    :: so we put "Release" in the front to get optimized host tools.
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_CONFIGURATION_TYPES=Release;Debug -DFEATURE_separate_debug_info=ON -G"Ninja Multi-Config"
)
if /i "%__should_enable_ltcg%" == "false" (
    :: Disable LTCG for debug and static builds
    :: - We don't need such optimization for debug builds apparently.
    :: - Enabling LTCG for static builds will make the generated binary files way too large
    ::   and it will also break the binary compatibility between different compilers and
    ::   and compiler versions.
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE=OFF -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
) else (
    :: For shared release builds it's totally OK to enable LTCG.
    set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE=ON
)
if /i "%__ninja_multi_config%" == "false" (
    :: Use "--target <TARGET>" to choose target explicitly.
    :: Normally you should use "all" as the default target.
    :: Use "--config <CONFIG>" to choose configuration explicitly.
    :: Don't forget to strip the debug symbols, otherwise the file size will
    :: be kind of large. For binaries that don't need stripping, CMake will skip
    :: the strip operation automatically.
    set __install_cmdline=cmake --install "%__module_cache_dir%" --strip
) else (
    :: CMake's own install command only supports single configuration.
    :: So here we use ninja's install command instead.
    :: https://gitlab.kitware.com/cmake/cmake/-/issues/20713
    :: https://gitlab.kitware.com/cmake/cmake/-/issues/21475
    :: Use "install/strip" instead of plain "install" to enable debug symbol stripping.
    :: Ninja will also automatically skip binaries that don't need stripping.
    set __install_cmdline=ninja install/strip
)
:: The "relocatable" feature will be disabled for static builds automatically, so here
:: we explicitly enable it unconditionally.
:: The official Qt packages always use the bundled ZLIB library, so we mirrored the behavior here.
:: And we also enable the ICU feature here, without it Qt's codec handling will be quite
:: limited, and QtWebEngine can make use of it as well.
:: "INPUT_openssl" controls how Qt links against the OpenSSL libraries. By default Qt will
:: try to load OpenSSL libraries dynamically at runtime, if they can't be found or loaded,
:: Qt will then try to use the fallback implementation. Since we always build the OpenSSL libraries
:: in VCPKG, we can let Qt link against them directly. QtNetwork will have some limitations if
:: the OpenSSL libraries are not available.
:: We also enable the mitigation for the Spectre security vulnerabilities and the Control-flow
:: Enforcement Technology (CET) to make our applications and libraries extra safe.
:: All the above CMake switches are only available for the QtBase module, passing them to other
:: modules will have no effect and will also cause some CMake warnings.
if /i "%__is_building_qtbase%" == "true" set __cmake_extra_params=%__cmake_extra_params% -DCMAKE_PREFIX_PATH="%__contrib_bin_dir%" -DFEATURE_relocatable=ON -DFEATURE_system_zlib=OFF -DFEATURE_icu=ON -DINPUT_openssl=linked -DINPUT_intelcet=yes -DINPUT_spectre=yes
:: For the QtWebEngine module, we only build the QtPDF component. Building QtWebEngine itself
:: is too time consuming and GitHub Actions's machine is not powerful enough to build it either.
:: QtPDF will be built by default, no need to enable it explicitly. The CMake parameter to control
:: it is "-DFEATURE_qtpdf_build=ON/OFF".
:: If you are building QtWebEngine itself, remember to pass "-DFEATURE_webengine_proprietary_codecs=ON"
:: otherwise you will not be able to play most media formats in your browser. It's disabled by default
:: and won't be enabled unless you enable it manually and explicitly.
if /i "%__is_building_qtwebengine%" == "true" set __cmake_extra_params=%__cmake_extra_params% -DFEATURE_qtwebengine_build=OFF
:: "QT_BUILD_TESTS" controls whether to build Qt's auto tests by default.
:: "QT_BUILD_EXAMPLES" controls whether to build Qt's example projects by default.
set __cmake_config_params=%__cmake_extra_params% -DCMAKE_INSTALL_PREFIX="%__module_install_dir%" -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF "%__module_source_dir%"
:: Use "--target <TARGET>" to choose target explicitly.
:: Normally you should use "all" as the default target.
:: Use "--config <CONFIG>" to choose configuration explicitly.
set __cmake_build_params=--build "%__module_cache_dir%" --parallel
:: It's recommended to use the vswhere tool to find the Visual Studio installation path,
:: it will be installed automatically while installing Visual Studio, but you can also
:: download it manually from GitHub: https://github.com/microsoft/vswhere/releases/latest
set __vswhere_path=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
set __vs_install_dir=
set __vs_dev_cmd=
set PATH=%__contrib_bin_dir%;%PATH%
if /i "%__compiler%" == "mingw" (
    where g++
    if %errorlevel% equ 0 (
        g++ --version
    ) else (
        echo g++.exe is not in your PATH environment variable.
        goto fail
    )
) else (
    if exist "%__vswhere_path%" (
        for /f "delims=" %%a in ('"%__vswhere_path%" -property installationPath -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64') do set __vs_install_dir=%%a
    ) else (
        echo Cannot locate vswhere.exe, please install Visual Studio Installer first.
        goto fail
    )
    set __vs_dev_cmd=!__vs_install_dir!\VC\Auxiliary\Build\vcvarsall.bat
    if exist "!__vs_dev_cmd!" (
        call "!__vs_dev_cmd!" %__arch%
        where cl
        if %errorlevel% equ 0 (
            if /i "%__compiler%" == "clangcl" (
                where clang-cl
                if %errorlevel% equ 0 (
                    clang-cl --version
                ) else (
                    echo clang-cl.exe is not in your PATH environment variable.
                    goto fail
                )
            )
        ) else (
            echo cl.exe is not in your PATH environment variable.
            goto fail
        )
    ) else (
        echo Failed to retrieve Microsoft Visual Studio's installation path.
        goto fail
    )
)
where git
if %errorlevel% equ 0 (
    git --version
) else (
    echo git.exe is not in your PATH environment variable.
    goto fail
)
where cmake
if %errorlevel% equ 0 (
    cmake --version
) else (
    echo cmake.exe is not in your PATH environment variable.
    goto fail
)
where ninja
if %errorlevel% equ 0 (
    echo Ninja version:
    ninja --version
) else (
    echo ninja.exe is not in your PATH environment variable.
    goto fail
)
echo Building Qt module: %__module%
echo Clone command-line: git %__git_clone_params%
echo Fetch command-line: git %__git_fetch_params%
echo Reset command-line: git %__git_reset_params%
echo Clean command-line: git %__git_clean_params%
echo Configure command-line: cmake %__cmake_config_params%
echo Build command-line: cmake %__cmake_build_params%
echo Install command-line: %__install_cmdline%
cd /d "%__repo_root_dir%"
if not exist "%__repo_build_dir%" md "%__repo_build_dir%"
cd /d "%__repo_build_dir%"
if not exist "%__repo_source_dir%" md "%__repo_source_dir%"
cd /d "%__repo_source_dir%"
if exist "%__module_source_dir%" rd /s /q "%__module_source_dir%"
git %__git_clone_params%
if %errorlevel% neq 0 goto fail
set __module_patch_file=%__repo_root_dir%\patches\%__module%.diff
if exist "%__module_patch_file%" (
    cd /d "%__module_source_dir%"
    git %__git_apply_params% "%__module_patch_file%"
    if %errorlevel% neq 0 goto fail
)
cd /d "%__repo_build_dir%"
if not exist "%__repo_cache_dir%" md "%__repo_cache_dir%"
cd /d "%__repo_cache_dir%"
if exist "%__module_cache_dir%" rd /s /q "%__module_cache_dir%"
md "%__module_cache_dir%"
cd /d "%__module_cache_dir%"
cmake %__cmake_config_params%
if %errorlevel% neq 0 goto fail
cmake %__cmake_build_params%
if %errorlevel% neq 0 goto fail
%__install_cmdline%
if %errorlevel% neq 0 goto fail
:: Copy 3rd party binary files and import libraries from VCPKG.
copy /y "%__vcpkg_dir%\installed\%__vcpkg_triplet%\bin\*.dll" "%__module_install_dir%\bin"
copy /y "%__vcpkg_dir%\installed\%__vcpkg_triplet%\lib\*.lib" "%__module_install_dir%\lib"
cd /d "%__repo_root_dir%"
:: Cleanup. GitHub Actions's machine complains about no enough disk space.
rd /s /q "%__module_source_dir%"
rd /s /q "%__module_cache_dir%"
goto success

:success
cd /d "%__repo_root_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b 0

:fail
cd /d "%__repo_root_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b -1
