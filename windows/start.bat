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
setlocal
set __git_dir=%ProgramFiles%\Git\bin
set __cmake_dir=%ProgramFiles%\CMake\bin
set __ninja_dir=C:\Develop\Tools\ninja-win
set __7z_dir=%ProgramFiles%\7-Zip
set __clangcl_dir=C:\Develop\Environments\LLVM-14.0.0-win64\bin
set __mingw_dir=C:\Develop\Environments\llvm-mingw-20220323-ucrt-x86_64\bin
set __qt_modules=qtbase,qtshadertools,qtimageformats,qtlanguageserver,qtsvg,qtdeclarative,qt5compat,qtremoteobjects,qtmultimedia,qttools
set __compiler=clang-cl
set __arch=x64
set __build_type=release
set __lib_type=shared
set __build_script_file=%~dp0build.bat
set __build_script_params=/%__compiler% /%__lib_type% /%__build_type% /%__arch%
set __repo_root_dir=%~dp0..
set __repo_install_dir=%__repo_root_dir%\build\windows
set __artifact_dir_name=%__compiler%_%__arch%_%__lib_type%_%__build_type%
set __archive_file_name=%__artifact_dir_name%.7z
set __archive_file_path=%__repo_install_dir%\%__archive_file_name%
call "%~dp0vcpkg.bat"
for %%i in (%__qt_modules%) do (
    call "%__build_script_file%" %__build_script_params% %%i
    if %errorlevel% neq 0 goto fin
)
where 7z
if %errorlevel% equ 0 (
    title Packaging Qt ...
    cd /d "%__repo_install_dir%"
    if exist "%__archive_file_path%" del /f "%__archive_file_path%"
    7z a %__archive_file_name% %__artifact_dir_name%\ -mx -myx -ms=on -mqs=on -mmt=on -m0=LZMA2:d=1g:fb=273
)
goto fin

:fin
cd /d "%__repo_root_dir%"
endlocal
pause
exit /b
