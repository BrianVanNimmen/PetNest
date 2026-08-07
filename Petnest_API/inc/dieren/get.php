<?php
// get.php
header("Content-Type: application/json; charset=UTF-8");

// ========== ARTS-MODUS: dieren per dierenarts ==========
// /dieren.php?dierenarts_id=13
if (isset($_GET['dierenarts_id']) && is_numeric($_GET['dierenarts_id'])) {

    $dierenarts_id = (int) $_GET['dierenarts_id'];

    if (!$stmt = $conn->prepare("
        SELECT d.id, d.naam, d.soort, d.geboortedatum, d.foto_url, d.dierenarts_id,
               CONCAT(a.voornaam, ' ', a.achternaam) AS dierenarts_naam
        FROM dieren d
        LEFT JOIN dierenartsen a ON a.id = d.dierenarts_id
        WHERE d.dierenarts_id = ?
        ORDER BY d.naam
    ")) {
        die(json_encode([
            "error" => "Prepare failed",
            "errNo" => $conn->errno,
            "mysqlError" => $conn->error,
            "status" => "fail"
        ]));
    }

    if (!$stmt->bind_param("i", $dierenarts_id)) {
        $stmt->close();
        die(json_encode([
            "error" => "Bind failed",
            "errNo" => $conn->errno,
            "mysqlError" => $conn->error,
            "status" => "fail"
        ]));
    }

    if (!$stmt->execute()) {
        $stmt->close();
        die(json_encode([
            "error" => "Execute failed",
            "errNo" => $conn->errno,
            "mysqlError" => $conn->error,
            "status" => "fail"
        ]));
    }

    $result = $stmt->get_result();
    $rows = [];
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    $stmt->close();

    die(json_encode([
        "status" => 200,
        "count"  => count($rows),
        "data"   => $rows
    ]));
}

// ========== KLANT-MODUS ==========

// hier normaal je include voor DB-verbinding, bv.
// require_once("../inc/config.php");

// klant_id vereist als query-parameter: ?klant_id=3
if (!isset($_GET['klant_id']) || !is_numeric($_GET['klant_id'])) {
    die('{"error":"Missing or invalid klant_id parameter","status":"fail"}');
}

$klant_id = intval($_GET['klant_id']);

// prepared statement
if(!$stmt = $conn->prepare("
    SELECT d.id, d.naam, d.soort, d.geboortedatum, d.foto_url, d.dierenarts_id,
           CONCAT(a.voornaam, ' ', a.achternaam) AS dierenarts_naam
    FROM dieren d
    LEFT JOIN dierenartsen a ON a.id = d.dierenarts_id
    WHERE d.klant_id = ?
")) {
    die('{"error":"Prepared Statement failed on prepare","errNo":' . json_encode($conn->errno) . ',"mysqlError":' . json_encode($conn->error) . ',"status":"fail"}');
}

// bind param (i = integer)
if(!$stmt->bind_param("i", $klant_id)) {
    die('{"error":"Prepared Statement bind failed on bind","errNo":' . json_encode($conn->errno) . ',"mysqlError":' . json_encode($conn->error) . ',"status":"fail"}');
}

if(!$stmt->execute()) {
    $stmt->close();
    die('{"error":"Prepared Statement failed on execute","errNo":' . json_encode($conn->errno) . ',"mysqlError":' . json_encode($conn->error) . ',"status":"fail"}');
}

$result = $stmt->get_result();
$rows = [];

while($row = $result->fetch_assoc()) {
    $rows[] = $row;
}

$stmt->close();

// antwoord met lijst van dieren
die(json_encode([
    "status" => 200,
    "count"  => count($rows),
    "data"   => $rows
]));

?>
