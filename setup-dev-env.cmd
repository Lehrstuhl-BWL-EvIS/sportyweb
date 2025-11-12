@echo off
:: This script is the windows batch version of the setup-dev-env.cmd file. 
::
:: The collaborative development of complex software like
:: Sportyweb will be much easier if each developer starts
:: on the same basis.
::
:: This script takes care of setting up a new and clean
:: development environment each time it's run. It is meant
:: to be run on a regular basis. E.g. after each DB change.
::
::
:: To run/execute the script:
:: setup-dev-env.cmd

:: For this out commented part I haven't found a solution in windows cmd
::set -o errexit
::set -o nounset
::set -o pipefail


:: Additional logic to set environment for compilation of argon
IF defined VCVARSAL_PATH (
    echo "VCVARSAL_PATH path is set %VCVARSAL_PATH%"
) ELSE (
    echo "No Path to VCVARSAL_PATH defined, searching in subfoldes of C:\Program Files (x86)\"
    for /f "delims=" %%F in ('dir "C:\Program Files (x86)\Microsoft Visual Studio\vcvarsall.bat" /s /b 2^>nul') do (
        set "VCVARSAL_PATH=%%F"
        
    )
)


IF defined VCVARSAL_PATH (
    echo "Call %VCVARSAL_PATH% to set environment for latter compilation of c dependencies"
    call "%VCVARSAL_PATH%" amd64
) ELSE (
    echo "VCVARSAL_PATH not found. Make sure Microsoft Visual Studio C++ Development tools are installed."
    exit
)

echo "- Setup Development Environment: Start"

echo "- Install dependencies"
call mix deps.get

call mix assets.setup
call mix assets.build

echo "- Drop databases (Dev & Test)"
set MIX_ENV=dev
call mix ecto.drop
set MIX_ENV=test
call mix ecto.drop

echo "- Create databases (Dev & Test)"
set MIX_ENV=dev
call mix ecto.create
set MIX_ENV=test
call mix ecto.create

echo "- Run database migrations (Dev & Test)"
set MIX_ENV=dev
call mix ecto.migrate
set MIX_ENV=test
call mix ecto.migrate

echo "- Generate a dump of the SQL structure"
set MIX_ENV=dev
call mix ecto.dump
:: ensure that MIX_ENV environment variable is unset so that execution of mix test will not fail for example
set MIX_ENV=

echo "- Run seed file"
call mix run priv/repo/seeds.exs

echo "- Generate the ExDoc project documentation"
call mix docs

echo "- Generate an ERD (Entity Relationship Diagram)"

where mmdc >nul 2>nul
if %errorlevel% equ 0 (
    :: https://hexdocs.pm/ecto_erd/Mix.Tasks.Ecto.Gen.Erd.html#module-mermaid
    call mix ecto.gen.erd --output-path=ecto_erd.mmd && mmdc -i ecto_erd.mmd -o documents/erd.pdf
    :: Remove the mermaid file
    rm ecto_erd.mmd 

) else (
    echo "  WARNING: Can't generate an ERD!"
    echo "  Please install mermaid-cli (https://github.com/mermaid-js/mermaid-cli)"
)

echo "- Setup Development Environment: Done"
