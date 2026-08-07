<?php
// update.php – wordt ingeladen door dossier.php OF rechtstreeks aangeroepen
// Zorg dat $conn (mysqli) beschikbaar is via dbcon.php

header('Content-Type: application/json; charset=UTF-8');

$response = [
    "status"  => 200,
    "message" => "Dossier opgeslagen"
];

// JSON body inlezen
$inputJson = file_get_contents("php://input");
$data = json_decode($inputJson, true);

if (!is_array($data)) {
    $response["status"]  = 400;
    $response["message"] = "Ongeldige JSON body";
    echo json_encode($response);
    exit;
}

// velden ophalen
$dier_id        = isset($data["dier_id"]) ? (int) $data["dier_id"] : 0;
$gewicht        = $data["gewicht"]        ?? null;
$gebit_status   = trim($data["gebit_status"]   ?? "");
$botten_status  = trim($data["botten_status"]  ?? "");
$spieren_status = trim($data["spieren_status"] ?? "");
$opmerking      = $data["opmerking"]      ?? null;

// ENKEL dier_id is echt verplicht
if ($dier_id <= 0) {
    $response["status"]  = 400;
    $response["message"] = "dier_id ontbreekt of is ongeldig";
    echo json_encode($response);
    exit;
}

// lege statussen standaard op 'onbekend'
if ($gebit_status === "")   $gebit_status   = "onbekend";
if ($botten_status === "")  $botten_status  = "onbekend";
if ($spieren_status === "") $spieren_status = "onbekend";

// lege strings naar NULL
$gewicht   = ($gewicht === "" ? null : $gewicht);
$opmerking = ($opmerking === "" ? null : $opmerking);

try {
    // bestaat er al een dossier voor dit dier?
    $checkSql  = "SELECT id FROM medisch_dossier WHERE dier_id = ? LIMIT 1";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param("i", $dier_id);
    $checkStmt->execute();
    $existing = $checkStmt->get_result()->fetch_assoc();
    $checkStmt->close();

    if ($existing) {
        // UPDATE
        $sql = "UPDATE medisch_dossier
                SET gewicht       = ?,
                    gebit_status  = ?,
                    botten_status = ?,
                    spieren_status= ?,
                    opmerking     = ?
                WHERE dier_id = ?";
        $action = "updated";
    } else {
        // INSERT
        $sql = "INSERT INTO medisch_dossier
                (gewicht, gebit_status, botten_status, spieren_status, opmerking, dier_id)
                VALUES (?, ?, ?, ?, ?, ?)";
        $action = "created";
    }

    $stmt = $conn->prepare($sql);
    // 5 strings + 1 int
    $stmt->bind_param(
        "sssssi",
        $gewicht,
        $gebit_status,
        $botten_status,
        $spieren_status,
        $opmerking,
        $dier_id
    );
    $stmt->execute();
    $stmt->close();

    $response["status"]  = 200;
    $response["message"] = "Medisch dossier $action";
} catch (mysqli_sql_exception $e) {
    $response["status"]  = 500;
    $response["message"] = "Databasefout bij opslaan medisch dossier";
    $response["error"]   = $e->getMessage();
}

echo json_encode($response);
exit;
