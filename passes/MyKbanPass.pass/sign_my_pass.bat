@echo off
REM Batch script for OpenSSL operations:
REM 1. Generate a new RSA Private Key.
REM 2. (Optional) Generate a Certificate Signing Request (CSR) for the new key.
REM 3. Example of signing a manifest.json using an EXISTING key and certificate.

REM Ensure OpenSSL is installed and its 'bin' directory is in your system's PATH.

REM --- Section 1: Generate a New RSA Private Key ---
echo.
echo --- Section 1: Generate New RSA Private Key ---
set /p NEW_KEY_FILENAME="Enter filename for the new private key (e.g., MyNewPassKey.pem): "
IF "%NEW_KEY_FILENAME%"=="" (
    echo No filename entered. Exiting key generation.
    goto Section2Header
)

set KEY_PATH="C:\Users\Visio\Documents\MyKbanPassProject\MyKbanPass.pass\Certificates\%NEW_KEY_FILENAME%"

echo Generating new 2048-bit RSA private key at %KEY_PATH% ...
openssl genpkey -algorithm RSA -out %KEY_PATH% -pkeyopt rsa_keygen_bits:2048

IF EXIST %KEY_PATH% (
    echo SUCCESS: New private key generated at %KEY_PATH%
) ELSE (
    echo FAILURE: Could not generate new private key. Check OpenSSL installation and permissions.
    goto Section2Header
)
echo.

REM --- Section 2: (Optional) Generate CSR for the New Key ---
:Section2Header
echo --- Section 2: Generate Certificate Signing Request (CSR) for New Key (Optional) ---
set /p GENERATE_CSR="Do you want to generate a CSR for the new key %NEW_KEY_FILENAME%? (Y/N): "
IF /I NOT "%GENERATE_CSR%"=="Y" (
    echo Skipping CSR generation.
    goto Section3Header
)

IF "%NEW_KEY_FILENAME%"=="" (
    echo Cannot generate CSR without a new key filename from Section 1. Skipping.
    goto Section3Header
)

set CSR_FILENAME_BASE=%NEW_KEY_FILENAME:.pem=%
set CSR_PATH="C:\Users\Visio\Documents\MyKbanPassProject\MyKbanPass.pass\Certificates\%CSR_FILENAME_BASE%.csr"

echo.
echo Generating CSR for %KEY_PATH%...
echo You will be prompted for CSR details (Country, State, Org, Common Name, etc.).
echo For 'Common Name', use a descriptive name, or it might be your Pass Type ID for Apple.

openssl req -new -key %KEY_PATH% -out %CSR_PATH% -sha256

IF EXIST %CSR_PATH% (
    echo SUCCESS: CSR generated at %CSR_PATH%
    echo You can now submit this CSR to Apple (or another CA) to get a certificate.
) ELSE (
    echo FAILURE: Could not generate CSR.
)
echo.

REM --- Section 3: Example - Sign manifest.json using an EXISTING Key and Certificate ---
REM This section is for signing a manifest.json for an Apple Wallet pass.
REM It uses PRE-EXISTING certificates and keys that you have already obtained and prepared.
REM A newly generated key (from Section 1) CANNOT be used here until you get a
REM corresponding Pass Type ID certificate from Apple using its CSR (from Section 2).
:Section3Header
echo --- Section 3: Example - Sign manifest.json for .pkpass (using EXISTING key/cert) ---
echo This section demonstrates signing a manifest.json.
echo It requires you to have:
echo   1. Your Apple Pass Type ID Signing Certificate (PEM format).
echo   2. The Private Key corresponding to that certificate (PEM format).
echo   3. The Apple WWDR Intermediate Certificate (PEM format).
echo   4. A manifest.json file in the current directory.
echo.
set /p SIGN_MANIFEST="Do you want to proceed with an example of signing a manifest.json? (Y/N): "
IF /I NOT "%SIGN_MANIFEST%"=="Y" (
    echo Skipping manifest signing example.
    goto End
)

echo.
echo IMPORTANT: The following paths are examples.
echo Ensure they point to your ACTUAL, CORRECT, and PAIRED Pass Type ID certificate and its private key.
echo The private key used here should NOT be the one just generated unless you have already obtained a certificate for it.

REM --- Configuration for Signing: Verify these paths are correct and files are in PEM format ---
REM Your Apple Pass Type ID Signing Certificate (PEM format) - This must match your private key
set SIGNER_CERT_PATH_SIGN="C:\Users\Visio\Documents\MyKbanPassProject\MyKbanPass.pass\Certificates\pass.envirobuildsolutions.pem"

REM Your Private Key corresponding to the Signer Certificate (PEM format)
set PRIVATE_KEY_PATH_SIGN="C:\Users\Visio\Documents\MyKbanPassProject\MyKbanPass.pass\Certificates\ALDsigning.pem"

REM Apple Worldwide Developer Relations Intermediate Certificate (PEM format)
REM Using AppleWWDRCAG3.pem as an example.
set WWDR_CERT_PATH_SIGN="C:\Users\Visio\Documents\MyKbanPassProject\MyKbanPass.pass\Certificates\AppleWWDRCAG3.pem"

REM Input manifest file (this script assumes manifest.json is in the directory where the script is run)
set MANIFEST_FILE_SIGN="manifest.json"

REM Output signature file (will be created in the directory where this script is run)
set SIGNATURE_FILE_SIGN="signature"
REM --- End Configuration for Signing ---

echo.
echo Attempting to sign %MANIFEST_FILE_SIGN%...
echo Using Signer Certificate: %SIGNER_CERT_PATH_SIGN%
echo Using Private Key: %PRIVATE_KEY_PATH_SIGN%
echo Using WWDR Certificate: %WWDR_CERT_PATH_SIGN%
echo.

REM Check if manifest.json exists in the current directory
IF NOT EXIST %MANIFEST_FILE_SIGN% (
    echo ERROR: %MANIFEST_FILE_SIGN% not found in the current directory!
    echo Please run this script from the directory containing %MANIFEST_FILE_SIGN%
    echo (e.g., C:\Users\Visio\Documents\MyKbanPassProject\MyKbanPass.pass).
    goto End
)

REM Check if certificate and key files exist at the specified paths
IF NOT EXIST %SIGNER_CERT_PATH_SIGN% (
    echo ERROR: Signer Certificate not found at %SIGNER_CERT_PATH_SIGN%
    goto End
)
IF NOT EXIST %PRIVATE_KEY_PATH_SIGN% (
    echo ERROR: Private Key not found at %PRIVATE_KEY_PATH_SIGN%
    goto End
)
IF NOT EXIST %WWDR_CERT_PATH_SIGN% (
    echo ERROR: WWDR Certificate not found at %WWDR_CERT_PATH_SIGN%
    goto End
)

REM Run the OpenSSL command for signing
openssl smime -binary -sign ^
    -signer %SIGNER_CERT_PATH_SIGN% ^
    -inkey %PRIVATE_KEY_PATH_SIGN% ^
    -certfile %WWDR_CERT_PATH_SIGN% ^
    -in %MANIFEST_FILE_SIGN% ^
    -out %SIGNATURE_FILE_SIGN% ^
    -outform DER

IF EXIST %SIGNATURE_FILE_SIGN% (
    echo.
    echo SUCCESS: '%SIGNATURE_FILE_SIGN%' file has been created successfully.
) ELSE (
    echo.
    echo FAILURE: '%SIGNATURE_FILE_SIGN%' file was NOT created. Check OpenSSL errors.
)

:End
echo.
echo Script finished.
pause
