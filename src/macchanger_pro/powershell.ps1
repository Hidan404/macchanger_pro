param (
    [string]$Interface,
    [string]$NovoMac
)

function Gerar-MacAleatorio {
    $bytes = @(For ($i=0; $i -lt 6; $i++) {Get-Random -Minimum 0 -Maximum 256})
    $bytes[0] = ($bytes[0] -band 0xFC) -bor 0x02
    $mac = ($bytes | ForEach-Object { "{0:X2}" -f $_ }) -join ''
    return $mac
}

if (-not $NovoMac) {
    Write-Host "Nenhum MAC informado. Gerando um aleatório..."
    $NovoMac = Gerar-MacAleatorio
}

Write-Host "Interface informada: $Interface"
Write-Host "MAC a ser usado: $NovoMac"

# Obter NetCfgInstanceId correto
$adapter = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -eq $Interface }

if (-not $adapter) {
    Write-Error "❌ Interface '$Interface' não encontrada. Use o nome exato (ex: 'Wi-Fi', 'Ethernet')."
    exit 1
}

$instanceId = $adapter.GUID
Write-Host "NetCfgInstanceId identificado: $instanceId"

# Chave base do registro
$baseKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"

# Atualizar o MAC
$subKeys = Get-ChildItem $baseKey
$found = $false
foreach ($key in $subKeys) {
    $netCfgInstanceId = (Get-ItemProperty $key.PSPath).NetCfgInstanceId
    if ($netCfgInstanceId -eq $instanceId) {
        Write-Host "✅ Alterando MAC no registro da chave: $($key.PSPath)"
        Set-ItemProperty -Path $key.PSPath -Name "NetworkAddress" -Value $NovoMac
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Error "❌ Não foi possível encontrar a chave de registro correspondente para a interface."
    exit 1
}

# Reiniciar a interface
Write-Host "🔄 Reiniciando interface $Interface..."
Restart-NetAdapter -Name $Interface -Confirm:$false

Write-Host "🎉 MAC alterado com sucesso para $NovoMac na interface $Interface!"
