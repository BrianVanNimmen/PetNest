<?php
// CORS headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Max-Age: 1000');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json');

define('INDEX', true);

// Preflight request afhandelen
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// DB connectie
require 'inc/dbcon.php';
require 'inc/base.php';

// firebase_uid uitlezen uit GET of POST
$uid = $_GET['firebase_uid'] ?? $_POST['firebase_uid'] ?? null;

if (!$uid) {
    echo json_encode(["error" => "Firebase UID ontbreekt"]);
    exit;
}

// Functie om gebruiker te zoeken in een tabel
function checkUser($conn, $table, $uid, $withStatus = false) {
    // minimale wijziging: optioneel veld status
    $fields = "id, voornaam, achternaam, email, firebase_uid";
    if ($withStatus) {
        $fields .= ", status";
    }

    $stmt = $conn->prepare("SELECT $fields FROM $table WHERE firebase_uid = ?");
    $stmt->bind_param("s", $uid);
    $stmt->execute();
    $res = $stmt->get_result();
    return $res->fetch_assoc();
}

// Eerst klant
$klant = checkUser($conn, 'klanten', $uid);
if ($klant) {
    echo json_encode([
        "type" => "klant",
        "data" => $klant
    ]);
    exit;
}

// Daarna dierenarts (met status)
$arts = checkUser($conn, 'dierenartsen', $uid, true);
if ($arts) {
    if ($arts["status"] !== "goedgekeurd") {
        echo json_encode([
            "error"  => "Account nog niet goedgekeurd",
            "status" => $arts["status"]
        ]);
        exit;
    }
    echo json_encode([
        "type" => "arts",
        "dierenarts_id" => (int)$arts["id"],
        "data" => $arts
    ]);
    exit;
}

// Geen match
echo json_encode(["error" => "Geen gebruiker gevonden"]);
