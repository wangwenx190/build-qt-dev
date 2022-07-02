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
:: Must be outside of the scope of "setlocal" and "endlocal".
set __error_code_build=-1
setlocal
:: Needed by QtWebEngine module. Some files have really long filename.
:: Modifying the registry requires the administrator privilege.
regedit /s "%~dp0enable-long-path.reg"
call "%~dp0build-config.bat"
set __build_script_path=%~dp0compile.bat
set __build_params=/%__compiler% /%__lib_type% /%__build_type% /%__arch%
set __repo_root_dir=%~dp0..
for %%i in (%__qt_modules%) do (
    call "%__build_script_path%" %__build_params% %%i
    :: Something wrong has happened, error out early because the following
    :: repositories won't be able to build due to lack of dependencies.
    if %errorlevel% neq 0 goto fin
)
set __error_code_build=0
goto fin

:fin
cd /d "%__repo_root_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b %__error_code_build%
