[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

#  CORE LOGIC

function Get-WifiProfiles {
    $raw = netsh wlan show profiles 2>&1
    return $raw |
    Select-String ":\s+(.+)$" |
    ForEach-Object { $_.Matches.Groups[1].Value.Trim() } |
    Where-Object { $_ -ne "" }
}

function Get-WifiPassword {
    param([string]$ProfileName)
    $raw = netsh wlan show profile name=`"$ProfileName`" key=clear 2>&1

    # Match English "Key Content" and Turkish "Anahtar Icerigi"
    $keyLine = $raw | Select-String "(?i)(Key Content|Anahtar\s+[Ii][a-z]+)\s*:\s*(.+)"
    if ($keyLine) {
        return $keyLine.Matches.Groups[2].Value.Trim()
    }

    $statusLine = $raw | Select-String "(?i)(Security key|[Gg][a-z]+\s+[Aa]nahtar[a-z]*)\s*:\s*(.+)"
    if ($statusLine) {
        $val = $statusLine.Matches.Groups[2].Value.Trim()
        if ($val -match "(?i)Present|Var") {
            return "! RUN AS ADMINISTRATOR !"
        }
    }

    return "(open / no password)"
}

#  TABLE RENDERER 
function Show-Table {
    param([object[]]$Rows)

    if (-not $Rows -or $Rows.Count -eq 0) { return }

    $H1 = "WiFi Name"
    $H2 = "Password"

    $w1 = $H1.Length
    $w2 = $H2.Length
    foreach ($r in $Rows) {
        if ($r.Name.Length -gt $w1) { $w1 = $r.Name.Length }
        if ($r.Pass.Length -gt $w2) { $w2 = $r.Pass.Length }
    }
    $w1 += 2
    $w2 += 2

    # Build border strings using only ASCII
    $dash = "-"
    $pipe = "|"
    $plus = "+"

    $top = "   " + $plus + ($dash * $w1) + $plus + ($dash * $w2) + $plus
    $mid = "   " + $plus + ($dash * $w1) + $plus + ($dash * $w2) + $plus
    $bot = "   " + $plus + ($dash * $w1) + $plus + ($dash * $w2) + $plus

    function Pad([string]$s, [int]$w) {
        return " " + $s + (" " * ($w - $s.Length - 1))
    }

    Write-Host $top -ForegroundColor Cyan

    # Header
    $h1p = Pad $H1 $w1
    $h2p = Pad $H2 $w2
    Write-Host "   $pipe" -NoNewline -ForegroundColor Cyan
    Write-Host $h1p       -NoNewline -ForegroundColor Yellow
    Write-Host "$pipe"    -NoNewline -ForegroundColor Cyan
    Write-Host $h2p       -NoNewline -ForegroundColor Yellow
    Write-Host "$pipe"               -ForegroundColor Cyan

    Write-Host $mid -ForegroundColor Cyan

    # Rows
    foreach ($r in $Rows) {
        $c1 = Pad $r.Name $w1
        $c2 = Pad $r.Pass $w2

        $col = "Green"
        if ($r.Pass -match "ADMINISTRATOR|open") { $col = "Magenta" }

        Write-Host "   $pipe" -NoNewline -ForegroundColor Cyan
        Write-Host $c1        -NoNewline -ForegroundColor White
        Write-Host "$pipe"    -NoNewline -ForegroundColor Cyan
        Write-Host $c2        -NoNewline -ForegroundColor $col
        Write-Host "$pipe"               -ForegroundColor Cyan
    }

    Write-Host $bot -ForegroundColor Cyan
}

#  MAIN UI

function Show-Interface {
    Clear-Host

    $LINE = "" * 66

    Write-Host $LINE -ForegroundColor Cyan
    Write-Host "  __      __.__  _____.__ __________" -ForegroundColor Cyan
    Write-Host " /  \    /  \__|/ ____\__| \______   \_____    ______ ______" -ForegroundColor Cyan
    Write-Host " \   \/\/   /  \   __\|  |  |     ___/\__  \  /  ___//  ___/" -ForegroundColor Cyan
    Write-Host "  \        /|  ||  |  |  |  |    |     / __ \_\___ \ \___ \ " -ForegroundColor Cyan
    Write-Host "   \__/\  / |__||__|  |__|  |____|    (____  /____  >____  >" -ForegroundColor Cyan
    Write-Host "        \/                                  \/     \/     \/ " -ForegroundColor Cyan
    Write-Host $LINE -ForegroundColor Cyan
    Write-Host "Saved Wi-Fi Passwords on This Machine" -ForegroundColor White
    Write-Host $LINE -ForegroundColor Cyan

    try {
        Write-Host "`n  [~] Scanning saved profiles..." -ForegroundColor DarkCyan
        Start-Sleep -Milliseconds 400

        $profiles = Get-WifiProfiles

        if (-not $profiles -or @($profiles).Count -eq 0) {
            Write-Host "`n  [!] No saved WiFi profiles found." -ForegroundColor Magenta
        }
        else {
            $rows = @(foreach ($p in $profiles) {
                    [PSCustomObject]@{ Name = $p; Pass = (Get-WifiPassword -ProfileName $p) }
                })

            Write-Host ""
            Show-Table -Rows $rows
            Write-Host ""
            Write-Host "  [i] Total: $($rows.Count) profile(s) found." -ForegroundColor DarkCyan
        }
    }
    catch {
        Write-Host "`n  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  [!] Try running as Administrator." -ForegroundColor Red
    }

    Write-Host ""
    Write-Host $LINE -ForegroundColor Cyan
    Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
    Write-Host $LINE -ForegroundColor Cyan

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Show-Interface
