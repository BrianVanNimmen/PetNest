<?php
// -- update een dier-item

if (!defined('INDEX')) {
    http_response_code(403);
    exit;
}

header("Content-Type: application/json; charset=UTF-8");

/*
  zelfde structuur als update concerten:
  - check_required_fields()
  - $postvars uit base.php
  - prepare
  - bind_param
  - execute
  - no rows affected → fout
  - succes → json terug
*/

// Verplichte velden
check_required_fields(["id", "naam", "soort", "klant_id"]);

// eventuele optionele datum
$geboorte = null;
if (isset($postvars["geboortedatum"]) && $postvars["geboortedatum"] !== "") {
    $geboorte = $postvars["geboortedatum"]; // bv. '2024-01-15'
}

$dierenarts_id = isset($postvars['dierenarts_id']) && $postvars['dierenarts_id'] !== ''
    ? (int)$postvars['dierenarts_id']
    : null;

// SQL opbouwen afhankelijk van NULL of niet
if ($geboorte === null) {
    $sql = "UPDATE dieren
            SET naam = ?, soort = ?, geboortedatum = NULL, klant_id = ?, dierenarts_id = ?
            WHERE id = ?";
    $types = "ssiii";
    $binds = [$postvars["naam"], $postvars["soort"], (int)$postvars["klant_id"], $dierenarts_id, (int)$postvars["id"]];
} else {
    $sql = "UPDATE dieren
            SET naam = ?, soort = ?, geboortedatum = ?, klant_id = ?, dierenarts_id = ?
            WHERE id = ?";
    $types = "sssiii";
    $binds = [$postvars["naam"], $postvars["soort"], $geboorte, (int)$postvars["klant_id"], $dierenarts_id, (int)$postvars["id"]];
}

// prepared statement
if (!$stmt = $conn->prepare($sql)) {
    die(json_encode([
        "error"      => "Prepared Statement failed on prepare",
        "errNo"      => $conn->errno,
        "mysqlError" => $conn->error,
        "status"     => "fail"
    ]));
}

// bind
if (!$stmt->bind_param($types, ...$binds)) {
    die(json_encode([
        "error"      => "Prepared Statement bind failed on bind",
        "errNo"      => $conn->errno,
        "mysqlError" => $conn->error,
        "status"     => "fail"
    ]));
}

// execute
if (!$stmt->execute()) {
    $stmt->close();
    die(json_encode([
        "error"      => "Execute failed",
        "errNo"      => $conn->errno,
        "mysqlError" => $conn->error,
        "status"     => "fail"
    ]));
}
// affected_rows == 0 betekent data was ongewijzigd, dat is geen fout

$stmt->close();

// antwoord zoals concerten-update.php
die(json_encode([
    "data"    => "ok",
    "message" => "Dier succesvol bijgewerkt",
    "status"  => 200,
    "id"      => $postvars["id"]
]));
?>
