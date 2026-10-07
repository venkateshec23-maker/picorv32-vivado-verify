@echo off
REM run_xsim.bat — MY one-command Vivado batch flow (no GUI, no toolchain).
REM Usage: run_xsim.bat [sum^|fact^|multrap^|all]   (default: all)
REM Verdict per program comes from tools\check_log.py parsing XSIM_RESULT markers.
setlocal EnableDelayedExpansion

set VIVADO_BIN=C:\Xilinx\Vivado\2019.2\bin
set PATH=%VIVADO_BIN%;%PATH%
cd /d %~dp0
if not exist work mkdir work
cd work

set PROG=%1
if "%PROG%"=="" set PROG=all

call xvlog.bat -log xvlog.log ..\..\..\tb\tb_picorv32_xsim.v ..\..\..\upstream\picorv32.v
if errorlevel 1 ( echo COMPILE_FAILED & exit /b 1 )
call xelab.bat -log xelab.log -debug typical tb_picorv32_xsim -s picorv32_xsim_sim
if errorlevel 1 ( echo ELAB_FAILED & exit /b 1 )

set OVERALL=0
del /q sim_sum.log sim_fact.log sim_multrap.log 2>nul
for %%P in (sum fact multrap) do (
  if "%PROG%"=="all" set RUN=1
  if "%PROG%"=="%%P" set RUN=1
  if defined RUN (
    set TCLPATH=%CD%\..\run_xsim.tcl
    call xsim.bat picorv32_xsim_sim -tclbatch !TCLPATH:\=/! --testplusarg prog_%%P -log sim_%%P.log
    ..\..\..\tools\check_log.py sim_%%P.log
    if errorlevel 1 set OVERALL=1
    set RUN=
  )
)
if %OVERALL%==0 ( echo OVERALL: PASS ) else ( echo OVERALL: FAIL )
exit /b %OVERALL%
