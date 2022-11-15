function Get-TimeStamp {
    $Stamp = "[{0:yyyy/MM/dd}  {0:HH:mm:ss}]" -f (Get-Date)
    return $Stamp
}