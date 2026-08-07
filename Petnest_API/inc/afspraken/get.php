<?php
// inc/afspraken/get.php
// Wordt ingeladen via afspraken.php (headers + $conn + $postvars aanwezig)

// Opties (via GET):
// - /afspraken.php?action=get&eigenaar_id=1          -> afspraken voor klant
// - /afspraken.php?action=get&dierenarts_id=2        -> afspraken voor arts
// - /afspraken.php?action=get&all=true               -> alle afspraken (admin/dev)
// - /afspraken.php?action=get&eigenaar_id=1&from=2025-12-01&to=2025-12-31 -> filter op datum

// ===== params =====
$all = isset($_GET["all"]) && ($_GET["all"] === "true" || $_GET["all"] === "1");
$klant_id  = isset($_GET["klant_id"]) ? (int)$_GET["klant_id"] : 0;
$dierenarts_id= isset($_GET["dierenarts_id"]) ? (int)$_GET["dierenarts_id"] : 0;

$isArtsRequest = ($dierenarts_id > 0);

$show_past = $isArtsRequest || (isset($_GET["show_past"]) && ($_GET["show_past"] === "true" || $_GET["show_past"] === "1"));

$from = isset($_GET["from"]) ? substr(trim($_GET["from"]), 0, 10) : "";
$to   = isset($_GET["to"])   ? substr(trim($_GET["to"]),   0, 10) : "";

$limit = isset($_GET["limit"]) ? (int)$_GET["limit"] : 0;
// basic clamp (optioneel)
if ($limit < 0) $limit = 0;
if ($limit > 50) $limit = 50;

// ===== basisvalidatie =====
if (!$all && $klant_id <= 0 && $dierenarts_id <= 0) {
    die(json_encode([
        "status" => 400,
        "error"  => "Geef klant_id of dierenarts_id mee, of all=true"
    ]));
}

// ===== query opbouwen =====
// We halen de naam van het dier op via JOIN, en tonen tijd uit geplande_datumtijd.
// Frontend verwacht: id, dier (naam), tijd, type
$sql = "
    SELECT
        b.id,
        d.naam AS dier,
        DATE_FORMAT(b.geplande_datumtijd, '%d/%m/%Y %H:%i') AS tijd,
        b.type,
        b.geplande_datumtijd,
        b.effectieve_datumtijd,
        b.dier_id,
        b.klant_id,
        CONCAT(k.voornaam, ' ', k.achternaam) AS eigenaar,
        b.dierenarts_id
    FROM bezoeken b
    JOIN dieren d ON d.id = b.dier_id
    JOIN klanten k ON k.id = b.klant_id
";

// where clauses dynamisch
$where = [];
$params = [];
$types  = "";

if (!$all) {
    if ($klant_id > 0) {
        $where[] = "b.klant_id = ?";
        $params[] = $klant_id;
        $types .= "i";
    }
    if ($dierenarts_id > 0) {
        $where[] = "b.dierenarts_id = ?";
        $params[] = $dierenarts_id;
        $types .= "i";
    }
}

if (!$all && !$show_past && !$isArtsRequest && $klant_id > 0) {
    $where[] = "b.geplande_datumtijd >= NOW()";
}

if ($from === "today") {
    // Enkel afspraken VANDAAG (voor klant of arts, als je het ooit gebruikt bij arts)
    $where[] = "DATE(b.geplande_datumtijd) = CURDATE()";
} elseif ($from !== "" && preg_match('/^\d{4}-\d{2}-\d{2}$/', $from)) {
    $where[] = "DATE(b.geplande_datumtijd) >= ?";
    $params[] = $from;
    $types .= "s";
}

if ($to !== "" && preg_match('/^\d{4}-\d{2}-\d{2}$/', $to)) {
    $where[] = "DATE(b.geplande_datumtijd) <= ?";
    $params[] = $to;
    $types .= "s";
}

if (count($where) > 0) {
    $sql .= " WHERE " . implode(" AND ", $where);
}

// Sorteer: eerst komende afspraken bovenaan
$sql .= " ORDER BY b.geplande_datumtijd ASC";

if ($limit > 0) {
    $sql .= " LIMIT " . $limit;
}

// ===== uitvoeren =====
if (!$stmt = $conn->prepare($sql)) {
    die(json_encode([
        "status" => "fail",
        "error" => "Prepare failed",
        "errNo" => $conn->errno,
        "mysqlError" => $conn->error
    ]));
}

if (count($params) > 0) {
    // bind_param met variabel aantal params
    $bind = [];
    $bind[] = $types;
    for ($i = 0; $i < count($params); $i++) {
        $bind[] = &$params[$i];
    }
    call_user_func_array([$stmt, "bind_param"], $bind);
}

if (!$stmt->execute()) {
    $stmt->close();
    die(json_encode([
        "status" => "fail",
        "error" => "Execute failed",
        "errNo" => $conn->errno,
        "mysqlError" => $conn->error
    ]));
}

$res = $stmt->get_result();
$rows = [];
if ($res) {
    while ($row = $res->fetch_assoc()) {
        $rows[] = $row;
    }
}

$stmt->close();

die(json_encode([
    "status" => 200,
    "data" => $rows
]));
