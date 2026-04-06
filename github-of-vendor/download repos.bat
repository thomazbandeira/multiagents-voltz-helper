@echo off
setlocal enabledelayedexpansion

set ORG=voltzmotors

echo Listando repos da organizacao %ORG%...
for /f "tokens=*" %%r in ('gh repo list %ORG% --limit 1000 --json name --jq ".[] | .name"') do (
    if not exist "%%r" (
        echo Clonando %%r...
        git clone https://github.com/%ORG%/%%r.git
    ) else (
        echo Repositorio %%r ja existe, atualizando...
        cd %%r
        git fetch --all

        REM Itera sobre todas as branches remotas, ignorando HEAD ->
        for /f "tokens=*" %%b in ('git branch -r ^| findstr /v "HEAD"') do (
            set branch=%%b
            set branch=!branch:origin/=!
            echo Sincronizando branch !branch!...

            REM Cria branch local se não existir
            git show-ref --verify --quiet refs/heads/!branch!
            if errorlevel 1 (
                git checkout -b !branch! origin/!branch!
            ) else (
                git checkout !branch!
            )

            REM Dá pull na branch
            git pull origin !branch!
        )
        cd ..
    )
)

echo Finalizado!
pause
