# Rebuild the four additional numeric CSV files from official UCI sources.
$ErrorActionPreference = 'Stop'
$items = @(
 @{Name='airfoil';Id=291;Slug='airfoil+self+noise';File='airfoil_self_noise.dat';Rows=1503;Columns=6;Header='frequency,attack_angle,chord_length,free_stream_velocity,displacement_thickness,sound_pressure_db'},
 @{Name='yacht';Id=243;Slug='yacht+hydrodynamics';File='yacht_hydrodynamics.data';Rows=308;Columns=7;Header='buoyancy_position,prismatic_coefficient,length_displacement,beam_draught,length_beam,froude_number,residuary_resistance'},
 @{Name='seeds';Id=236;Slug='seeds';File='seeds_dataset.txt';Rows=210;Columns=8;Header='area,perimeter,compactness,kernel_length,kernel_width,asymmetry,groove_length,class'},
 @{Name='sonar';Id=151;Slug='connectionist+bench+sonar+mines+vs+rocks';File='sonar.all-data';Rows=208;Columns=61;Header=((1..60 | ForEach-Object { 'band_{0:d2}' -f $_ }) -join ',')+',class'}
)
$sourceDir=Join-Path $PSScriptRoot 'sources_extra'
New-Item -ItemType Directory -Force -Path $sourceDir | Out-Null
$manifest=@()
foreach($item in $items) {
 $url='https://archive.ics.uci.edu/static/public/{0}/{1}.zip' -f $item.Id,$item.Slug
 $zip=Join-Path $sourceDir ($item.Name+'.zip')
 Invoke-WebRequest -Uri $url -OutFile $zip
 $extract=Join-Path $sourceDir $item.Name
 Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force
 $raw=Get-ChildItem -LiteralPath $extract -Recurse -File | Where-Object Name -eq $item.File | Select-Object -First 1
 if(!$raw){throw "Source file missing: $($item.File)"}
 $rows=@(foreach($line in Get-Content -LiteralPath $raw.FullName) {
  if(!$line.Trim()){continue}
  $fields=$line.Trim() -split '[,\s]+'
  if($fields.Count -ne $item.Columns){throw "Unexpected columns in $($item.Name)"}
  if($item.Name -eq 'sonar') {
   if($fields[60] -eq 'R'){$fields[60]='0'} elseif($fields[60] -eq 'M'){$fields[60]='1'} else {throw 'Unexpected Sonar label'}
  }
  foreach($v in $fields){$number=[double]::Parse($v,[cultureinfo]::InvariantCulture); if([double]::IsNaN($number) -or [double]::IsInfinity($number)){throw 'Nonfinite value'}}
  $fields -join ','
 })
 if($rows.Count -ne $item.Rows){throw "Unexpected row count: $($item.Name)"}
 $csv=Join-Path $PSScriptRoot ($item.Name+'.csv')
 [IO.File]::WriteAllLines($csv,@($item.Header)+$rows,[Text.UTF8Encoding]::new($false))
 $manifest+= [ordered]@{dataset=$item.Name;url=$url;source_file=$item.File;rows=$rows.Count;columns=$item.Columns;zip_sha256=(Get-FileHash $zip -Algorithm SHA256).Hash;csv_sha256=(Get-FileHash $csv -Algorithm SHA256).Hash}
 Write-Output "$($item.Name): $($rows.Count) rows"
}
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'extra_sources.json') -Encoding utf8
