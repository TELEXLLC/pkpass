<?php   
$pkpass_file = '\passes\MyKbanPass.pass\pass.json';

header("Pragma: no-cache");
header("Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
header("Content-Type: application/vnd.apple.pkpass");
header('Content-Disposition: attachment; filename=($pkpass_file);
clearstatcache();
$filesize = filesize($pkpass_file);
if ($filesize)
    header("Content-Length: ". $filesize);
header('Content-Transfer-Encoding: binary');
if (filemtime($pkpass_file)) {
    date_default_timezone_set("UTC");
    header('Last-Modified: ' . date("D, d M Y H:i:s", filemtime($pkpass_file)) . ' GMT');
}
flush();
readfile($pkpass_file);