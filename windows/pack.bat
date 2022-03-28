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
:: Add 7-Zip's directory to the PATH environment variable.
call "%~dp0path.bat"
set __repo_root_dir=%~dp0..
set __repo_install_dir=%__repo_root_dir%\build\windows
set __artifact_dir_name=%__compiler%_%__arch%_%__lib_type%_%__build_type%
set __archive_file_name=%__artifact_dir_name%.7z
set __archive_file_path=%__repo_install_dir%\%__archive_file_name%
:: This parameter combination means the ultra compression in most situtaions.
set __7zip_compress_params=-mx -myx -ms=on -mqs=on -mmt=on -m0=LZMA2:d=1g:fb=273
where 7z
if %errorlevel% neq 0 goto fin
title Packaging Qt ...
cd /d "%__repo_install_dir%"
if exist "%__archive_file_path%" del /f "%__archive_file_path%"
7z a %__archive_file_name% %__artifact_dir_name%\ %__7zip_compress_params%
goto fin

:fin
cd /d "%__repo_root_dir%"
endlocal
exit /b
