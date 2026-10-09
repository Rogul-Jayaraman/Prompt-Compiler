<#
  Trigger-accuracy scorer.

  Measures whether the SKILL.md `description` routes the right queries to the
  skill. This is the failure mode nothing else in evals/ covers: a skill that
  exists but never fires produces no failures, no trace, and no complaint until
  the user concludes it does not work.

  Split: 1-8 and 9-12 are TRAIN (used for tuning the description).
         13-20 are TEST (measure once, after tuning).

    powershell -File evals/triggers.ps1 -File responses.txt

  Responses are one per line:  "1 LOAD" / "2 SKIP" / ...
#>
param([Parameter(Mandatory = $true)][string]$File)

$ErrorActionPreference = "Stop"

$queries = @(
  @{ n = 1;  split = "TRAIN"; want = "LOAD"; q = "Write a prompt for Claude Code to add rate limiting to my API" },
  @{ n = 2;  split = "TRAIN"; want = "LOAD"; q = "Help me turn this into a good prompt for Cursor" },
  @{ n = 3;  split = "TRAIN"; want = "LOAD"; q = "I need a prompt that asks an AI agent to refactor this module" },
  @{ n = 4;  split = "TRAIN"; want = "LOAD"; q = "compile this request into a prompt for a coding agent" },
  @{ n = 5;  split = "TRAIN"; want = "LOAD"; q = "என் project-க்கு ஒரு prompt எழுதுங்கள்" },
  @{ n = 6;  split = "TRAIN"; want = "LOAD"; q = "I'm not sure how to word this for an AI to fix my login bug. Can you write it for me?" },
  @{ n = 7;  split = "TRAIN"; want = "LOAD"; q = "Make this vague request into something precise: add caching everywhere" },
  @{ n = 8;  split = "TRAIN"; want = "SKIP"; q = "Add rate limiting to the API" },
  @{ n = 9;  split = "TRAIN"; want = "SKIP"; q = "Write a prompt for Stable Diffusion: a watercolor mountain landscape" },
  @{ n = 10; split = "TRAIN"; want = "SKIP"; q = "Improve the system prompt in src/prompt.ts" },
  @{ n = 11; split = "TRAIN"; want = "SKIP"; q = "Rate limiting: should I use Redis or in-memory?" },
  @{ n = 12; split = "TRAIN"; want = "SKIP"; q = "What does this Python function do?" },
  @{ n = 13; split = "TEST";  want = "LOAD"; q = "Before I paste this into Claude Code, can you tighten it up?" },
  @{ n = 14; split = "TEST";  want = "LOAD"; q = "Draft a task description an AI agent can execute for this repo" },
  @{ n = 15; split = "TEST";  want = "LOAD"; q = "என் login bug-ஐ AI-கு கொடுக்க prompt வேணும்" },
  @{ n = 16; split = "TEST";  want = "SKIP"; q = "Review my auth module for security issues" },
  @{ n = 17; split = "TEST";  want = "SKIP"; q = "Refactor src/auth to use JWT instead of cookies" },
  @{ n = 18; split = "TEST";  want = "SKIP"; q = "Fix the failing test in tests/auth.test.js" },
  @{ n = 19; split = "TEST";  want = "SKIP"; q = "Help me choose between Postgres and MySQL for a small app" },
  @{ n = 20; split = "TEST";  want = "SKIP"; q = "Summarize this article for me" }
)

if (-not (Test-Path $File)) { Write-Error "No response file: $File" }
$raw = Get-Content $File -Encoding UTF8

$got = @{}
foreach ($line in $raw) {
  if ($line -match '^\s*(\d{1,2})\s+(LOAD|SKIP)\b') {
    $got[[int]$Matches[1]] = $Matches[2]
  }
}

if ($got.Count -eq 0) { Write-Error "No responses parsed. Expected lines like '1 LOAD'" }

$rows = foreach ($q in $queries) {
  $answer = $got[$q.n]
  if (-not $answer) {
    [pscustomobject]@{ N=$q.n; Split=$q.split; Want=$q.want; Got="(none)"; OK=$false; Q=$q.q }
  } else {
    [pscustomobject]@{ N=$q.n; Split=$q.split; Want=$q.want; Got=$answer; OK=($answer -eq $q.want); Q=$q.q }
  }
}

Write-Output "=== PER QUERY ==="
$rows | ForEach-Object {
  $f = if ($_.OK) { "  " } else { "XX" }
  Write-Output ("{0} {1,2} {2,-5} want={3,-4} got={4,-6} {5}" -f $f, $_.N, $_.Split, $_.Want, $_.Got, $_.Q)
}

function Rate($rows, $split, $want) {
  $s = $rows | Where-Object { $_.Split -eq $split -and $_.Want -eq $want }
  if (-not $s) { return @{ pct = 0; ok = 0; n = 0 } }
  $ok = ($s | Where-Object OK).Count
  return @{ pct = [math]::Round(100 * $ok / $s.Count, 1); ok = $ok; n = $s.Count }
}

$recallAll = Rate $rows "TRAIN" "LOAD";  $recallAllT = Rate $rows "TEST" "LOAD"
$precAll   = Rate $rows "TRAIN" "SKIP";  $precAllT   = Rate $rows "TEST" "SKIP"

Write-Output ""
Write-Output "=== SCORES ==="
Write-Output ("recall (should load)   TRAIN {0,5}%  ({1}/{2})" -f $recallAll.pct,  $recallAll.ok,  $recallAll.n)
Write-Output ("recall (should load)   TEST  {0,5}%  ({1}/{2})" -f $recallAllT.pct, $recallAllT.ok, $recallAllT.n)
Write-Output ("precision (should skip) TRAIN {0,5}%  ({1}/{2})" -f $precAll.pct,    $precAll.ok,    $precAll.n)
Write-Output ("precision (should skip) TEST  {0,5}%  ({1}/{2})" -f $precAllT.pct,   $precAllT.ok,   $precAllT.n)

Write-Output ""
Write-Output "=== GATE (TEST split, threshold 90%) ==="
$pass = $true
foreach ($m in @(
    @{ n = "recall TEST";    v = $recallAllT.pct },
    @{ n = "precision TEST"; v = $precAllT.pct })) {
  $ok = $m.v -ge 90
  if (-not $ok) { $pass = $false }
  Write-Output ("{0,-18} {1,6}%  {2}" -f $m.n, $m.v, $(if ($ok) { "PASS" } else { "FAIL" }))
}
Write-Output ""
if ($pass) { "TRIGGER GATE: PASS" } else { "TRIGGER GATE: FAIL - retune the description, then re-measure on TEST only" }