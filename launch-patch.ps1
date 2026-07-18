# Launch-day patch: inject contract address and swap URL, then push (Vercel auto-deploys from main).
# Usage: .\launch-patch.ps1 <contract-address> <swap-url>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ContractAddress,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$SwapUrl
)

$ErrorActionPreference = 'Stop'

$indexPath = Join-Path $PSScriptRoot 'index.html'
$html = [System.IO.File]::ReadAllText($indexPath)

$replacements = @(
    @{ Old = 'posted at launch, verify before you buy'
       New = $ContractAddress },
    @{ Old = '<a class="buy" href="#">buy $SKYKING</a>'
       New = '<a class="buy" href="' + $SwapUrl + '">buy $SKYKING</a>' },
    @{ Old = '<a href="#" class="btn btn-primary">BUY $SKYKING</a>'
       New = '<a href="' + $SwapUrl + '" class="btn btn-primary">BUY $SKYKING</a>' },
    @{ Old = '<a href="#">DEXSCREENER</a>'
       New = '<a href="https://dexscreener.com/robinhood/' + $ContractAddress + '">DEXSCREENER</a>' }
)

foreach ($r in $replacements) {
    if (-not $html.Contains($r.Old)) {
        throw "Expected text not found in index.html: $($r.Old) - already patched or file changed. Aborting, nothing written."
    }
    $html = $html.Replace($r.Old, $r.New)
}

[System.IO.File]::WriteAllText($indexPath, $html)
Write-Host "index.html patched: CA=$ContractAddress, swap=$SwapUrl"

git -C $PSScriptRoot add index.html
git -C $PSScriptRoot commit -m 'launch: CA live'
git -C $PSScriptRoot push origin main
Write-Host 'Pushed. Vercel will auto-deploy from main.'
