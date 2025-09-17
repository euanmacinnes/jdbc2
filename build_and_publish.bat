@echo off
setlocal enabledelayedexpansion

REM Build and publish helper for jdbc2
REM Usage:
REM   build_and_publish.bat              -> build and upload to PyPI
REM   build_and_publish.bat testpypi     -> build and upload to TestPyPI
REM   build_and_publish.bat skip-upload  -> only build (no upload)

set REPO=%1
if "%REPO%"=="" set REPO=pypi

if /I "%REPO%"=="skip-upload" goto :BUILD_ONLY

REM Ensure Python, pip, build, and twine are available
where python >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Python not found on PATH.
  exit /b 1
)

python -m pip install --upgrade pip >nul
if errorlevel 1 (
  echo [ERROR] Failed to upgrade pip.
  exit /b 1
)

python -m pip install --upgrade build twine >nul
if errorlevel 1 (
  echo [ERROR] Failed to install build/twine.
  exit /b 1
)

:BUILD_ONLY

REM Clean previous artifacts
if exist build (
  echo Cleaning build\ ...
  rmdir /s /q build
)
if exist dist (
  echo Cleaning dist\ ...
  rmdir /s /q dist
)
if exist jdbc2.egg-info (
  echo Cleaning jdbc2.egg-info\ ...
  rmdir /s /q jdbc2.egg-info
)

REM Build sdist and wheel
python -m build
if errorlevel 1 (
  echo [ERROR] Build failed.
  exit /b 1
)

REM Verify artifacts
python -m twine check dist\*
if errorlevel 1 (
  echo [ERROR] Twine check failed.
  exit /b 1
)

if /I "%REPO%"=="skip-upload" (
  echo Skipping upload per request. Artifacts in dist\
  exit /b 0
)

REM Upload to PyPI or TestPyPI. Use `testpypi` to push to TestPyPI.
if /I "%REPO%"=="testpypi" (
  echo Uploading to TestPyPI...
  python -m twine upload --repository testpypi dist\*
) else (
  echo Uploading to PyPI...
  python -m twine upload --repository pypi dist\*
)

if errorlevel 1 (
  echo [ERROR] Upload failed. Ensure your credentials are correct.
  echo You can set TWINE_USERNAME and TWINE_PASSWORD environment variables, or use keyring.
  exit /b 1
)

REM Optionally create a GitHub release and upload artifacts
where gh >nul 2>&1
if errorlevel 1 (
  echo [INFO] GitHub CLI (gh) not found. Skipping GitHub release upload.
  echo Done.
  exit /b 0
)

REM Determine version from pyproject.toml
set VERSION=
for /f %%v in ('powershell -NoProfile -Command "(Get-Content -Raw 'pyproject.toml') -split \"`n\" ^| Where-Object { $_ -match '^\s*version\s*=\s*\"([^\"]+)\"' } ^| ForEach-Object { $matches[1] }"') do set VERSION=%%v
if "%VERSION%"=="" (
  echo [WARN] Could not determine version from pyproject.toml. Skipping GitHub release.
  echo Done.
  exit /b 0
)

REM Ensure git is available and this is a git repo
where git >nul 2>&1
if errorlevel 1 (
  echo [INFO] git not found. Skipping tagging and GitHub release.
  echo Done.
  exit /b 0
)

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo [INFO] Not a git repository. Skipping GitHub release.
  echo Done.
  exit /b 0
)

set TAG=v%VERSION%

REM Create and push tag if it doesn't exist
for /f %%t in ('git tag -l %TAG%') do set TAG_EXISTS=%%t
if "%TAG_EXISTS%"=="" (
  echo Creating git tag %TAG% ...
  git tag -a %TAG% -m "Release %VERSION%"
  if errorlevel 1 (
    echo [WARN] Failed to create git tag %TAG%. Continuing.
  ) else (
    git push origin %TAG%
  )
) else (
  echo Tag %TAG% already exists.
)

REM Create or update GitHub release and upload artifacts
REM Try to create the release; if it exists, upload assets.
set GH_RELEASE_CREATED=0

echo Creating GitHub release %TAG% ...
gh release create %TAG% dist\* --title "jdbc2 %VERSION%" --notes "Release %VERSION%" >nul 2>&1
if errorlevel 1 (
  echo Release may already exist. Attempting to upload assets...
  gh release upload %TAG% dist\* --clobber
  if errorlevel 1 (
    echo [WARN] Failed to upload assets to existing release %TAG%.
  ) else (
    echo Uploaded artifacts to existing GitHub release %TAG%.
  )
) else (
  echo Created GitHub release %TAG% and uploaded artifacts.
)

echo Done.
exit /b 0
