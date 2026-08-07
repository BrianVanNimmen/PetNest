<?php
// --- "add" een afspraak

// verplicht: dier_id, eigenaar_id, dierenarts_id, datum, tijd, soort
check_required_fields(["dier_id", "klant_id", "dierenarts_id", "geplande_datumtijd", "type"]);

// waarden veilig ophalen
$dier_id       = (int) $postvars["dier_id"];
$klant_id   = (int) $postvars["klant_id"];
$dierenarts_id = (int) $postvars["dierenarts_id"];
$geplande_datumtijd = trim($postvars["geplande_datumtijd"]);
$type        = trim($postvars["type"]);

// (optioneel) basisvalidatie
if ($dier_id <= 0 || $klant_id <= 0 || $dierenarts_id <= 0) {
    die('{"error":"Ongeldige id-waarden","status":"fail"}');
}

if(!$stmt = $conn->prepare("
    INSERT INTO bezoeken (dier_id, klant_id, dierenarts_id, geplande_datumtijd, type)
    VALUES (?,?,?,?,?)
")){
    die('{"error":"Prepared Statement failed on prepare","errNo":' . json_encode($conn->errno) .',"mysqlError":' . json_encode($conn->error) .',"status":"fail"}');
}

// types: i i i s s s
if(!$stmt->bind_param(
    "iiiss",
    $dier_id,
    $klant_id,
    $dierenarts_id,
    $geplande_datumtijd,
    $type
)){
    die('{"error":"Prepared Statement bind failed on bind","errNo":' . json_encode($conn->errno) .',"mysqlError":' . json_encode($conn->error) .',"status":"fail"}');
}

if(!$stmt->execute()){
    $stmt->close();
    die('{"error":"Prepared Statement failed on execute","errNo":' . json_encode($conn->errno) .',"mysqlError":' . json_encode($conn->error) .',"status":"fail"}');
}

if($conn->affected_rows == 0) {
    $stmt->close();
    die('{"error":"Prepared Statement execute: no rows affected","status":"fail"}');
}

$PR_ID = $conn->insert_id;
$stmt->close();

die('{"data":"ok","message":"Record added successfully","status":200,"PR_ID":' . (int)$PR_ID . '}');
?>
