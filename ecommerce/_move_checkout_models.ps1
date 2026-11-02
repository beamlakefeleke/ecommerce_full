$base = 'lib/features/checkout'
New-Item -ItemType Directory -Force -Path "$base/data/models" | Out-Null
foreach ($f in @('distance_model','place_order_body_model','timeslote_model')) {
    if (Test-Path "$base/domain/models/$f.dart") {
        Move-Item -Force "$base/domain/models/$f.dart" "$base/data/models/$f.dart"
    }
}
$replacements = @{
    'features/checkout/domain/models/distance_model.dart' = 'features/checkout/data/models/distance_model.dart'
    'features/checkout/domain/models/place_order_body_model.dart' = 'features/checkout/data/models/place_order_body_model.dart'
    'features/checkout/domain/models/timeslote_model.dart' = 'features/checkout/data/models/timeslote_model.dart'
}
Get-ChildItem -Path lib -Recurse -Filter *.dart | ForEach-Object {
    $c = Get-Content -Raw -LiteralPath $_.FullName
    if ($c -eq $null) { return }
    $orig = $c
    foreach ($k in $replacements.Keys) { $c = $c.Replace($k, $replacements[$k]) }
    if ($c -ne $orig) {
        $c | Set-Content -NoNewline -LiteralPath $_.FullName
        Write-Output $_.FullName
    }
}
