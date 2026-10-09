<#
  Deterministic assertion checker for Prompt Compiler.

  No LLM-as-judge on this path. Every check is a string test against the
  delimited runner output, following SkillsBench design guidance (arXiv:2602.12670):
  deterministic verification, no LLM judge, skill-dependent tasks.

  Usage:
    powershell -File evals/check.ps1 -ResultsDir evals/results
    powershell -File evals/check.ps1 -ResultsDir evals/results -Model big-pickle

  Runner output format (one file per scenario per model, named <ID>__<model>.out):
    EFFORT: light
    ASKED: yes
    <questions>
    --- COMPILED PROMPT BEGIN ---
    ...
    --- COMPILED PROMPT END ---
#>
param(
  [Parameter(Mandatory = $true)][string]$ResultsDir,
  [string]$Model = "",
  [string]$RulesPath = ""
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $RulesPath) { $RulesPath = Join-Path $here "rules.json" }
if (-not (Test-Path $ResultsDir)) { Write-Error "No results directory: $ResultsDir" }
if (-not (Test-Path $RulesPath))    { Write-Error "No rules file: $RulesPath" }

$rules = Get-Content $RulesPath -Raw | ConvertFrom-Json
$files = Get-ChildItem -Path $ResultsDir -Filter *.out -File
if (-not $files) { Write-Error "No .out files in $ResultsDir" }

$rows = @()

foreach ($f in $files) {
  $base = $f.BaseName                      # e.g. S03__big-pickle
  $parts = $base -split "__", 2
  $sid = $parts[0]
  $mdl = if ($parts.Count -gt 1) { $parts[1] } else { "unknown" }
  if ($Model -and $mdl -ne $Model) { continue }

  $scen = $rules.$sid
  if (-not $scen) {
    Write-Warning "No rules for scenario '$sid' (file $($f.Name)) - skipped"
    continue
  }

  $text = Get-Content $f.FullName -Raw

  foreach ($r in $scen.rules) {
    $pass = $true
    $why = ""

    foreach ($p in $r.must) {
      if ($text -notmatch $p) { $pass = $false; $why = "missing /$p/"; break }
    }
    if ($pass) {
      foreach ($p in $r.mustnot) {
        if ($text -match $p) { $pass = $false; $why = "forbidden /$p/"; break }
      }
    }

    $rows += [pscustomobject]@{
      Model = $mdl; Scenario = $sid; Name = $scen.name
      Rule = $r.id; Weight = $r.weight; Desc = $r.desc
      Result = $(if ($pass) { "PASS" } else { "FAIL" }); Why = $why
    }
  }
}

# ---------- detail ----------
Write-Output "=== DETAIL ==="
$rows | Sort-Object Scenario, Model, Rule | ForEach-Object {
  $flag = if ($_.Result -eq "FAIL") { "x" } else { " " }
  $w    = if ($_.Weight -eq "critical") { "*" } else { " " }
  Write-Output ("{0}{1} {2,-6} {3,-26} {4,-5} {5}  {6}" -f $flag, $w, $_.Model, $_.Scenario, $_.Rule, $_.Result, $_.Why)
}
Write-Output ""
Write-Output "  (* = critical rule, must never fail)"
Write-Output ""

# ---------- per-model ----------
Write-Output "=== PER MODEL ==="
$rows | Group-Object Model | ForEach-Object {
  $g    = $_.Group
  $tot  = $g.Count
  $ok   = ($g | Where-Object Result -eq "PASS").Count
  $crit = $g | Where-Object Weight -eq "critical"
  $cok  = ($crit | Where-Object Result -eq "PASS").Count
  $pct  = if ($tot) { [math]::Round(100 * $ok / $tot, 1) } else { 0 }
  $cpct = if ($crit.Count) { [math]::Round(100 * $cok / $crit.Count, 1) } else { 100 }
  Write-Output ("{0,-26} {1,5}%  ({2}/{3})   critical {4,6}%  ({5}/{6})" -f $_.Name, $pct, $ok, $tot, $cpct, $cok, $crit.Count)
}

# ---------- per-rule agreement ----------
Write-Output ""
Write-Output "=== PER RULE ACROSS MODELS ==="
$rows | Group-Object Rule | Sort-Object Name | ForEach-Object {
  $g   = $_.Group
  $n   = ($g | Select-Object -ExpandProperty Model -Unique).Count
  $ok  = ($g | Where-Object Result -eq "PASS").Count
  $w   = $g[0].Weight
  $desc = $g[0].Desc
  $tag = if ($w -eq "critical" -and $ok -lt $n) { "  <<< CRITICAL NOT UNIVERSAL" }
         elseif ($ok -eq $n) { "" } else { "  <- model-sensitive" }
  Write-Output ("{0,-10} {1,5}/{2}  {3}{4}" -f $_.Name, $ok, $n, $desc, $tag)
}

# ---------- gate ----------
Write-Output ""
Write-Output "=== GATE ==="
$critFail = ($rows | Where-Object { $_.Weight -eq "critical" -and $_.Result -eq "FAIL" })
$anyCrit  = ($rows | Where-Object Weight -eq "critical").Count
$okAll    = ($rows | Where-Object Result -eq "PASS").Count
$pctAll   = if ($rows.Count) { [math]::Round(100 * $okAll / $rows.Count, 1) } else { 0 }

if ($critFail) {
  Write-Output "FAIL - critical rule violations: $(($critFail | Select-Object -ExpandProperty Rule -Unique) -join ', ')"
} else {
  Write-Output "PASS - no critical rule violations ($anyCrit checked)"
}
Write-Output "Overall: $pctAll%"