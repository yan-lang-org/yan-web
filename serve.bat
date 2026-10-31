@echo off
rem ==============================================================
rem  serve.bat - 本地预览官网（仅 Windows；Linux 建站时再补）
rem
rem    serve.bat          http://localhost:8080
rem    serve.bat 9000     http://localhost:9000
rem
rem  NOTE: ASCII-only. See the note in ..\yan-internal\yan.bat for why.
rem ==============================================================
chcp 65001 >nul
setlocal enabledelayedexpansion

set "ROOT=%~dp0"
set "PORT=%~1"
if "%PORT%"=="" set "PORT=8080"

set "PY="
if defined YAN_PYTHON (
    set "PY=%YAN_PYTHON%"
) else (
    where python >nul 2>nul && set "PY=python"
    if "!PY!"=="" where py >nul 2>nul && set "PY=py"
)
if "!PY!"=="" (
    echo ERROR: no python found in PATH.
    exit /b 1
)

echo serving %ROOT% on http://localhost:%PORT%
pushd "%ROOT%"
"!PY!" -m http.server %PORT%
popd
exit /b 0
