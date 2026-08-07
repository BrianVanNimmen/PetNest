<?php
// get.php – ophalen medisch dossier + dier gegevens
header("Content-Type: application/json");

$response = [
    "status" => 200,
    "message" => "",
    "data" => []
];

$dierId = isset($_GET['dier_id']) ? (int) $_GET['dier_id'] : 0;

if ($dierId <= 0) {
    $response["status"] = 400;
    $response["message"] = "dier_id ontbreekt of ongeldig";
    echo json_encode($response);
    return;
}

try {
    $sql = "
        SELECT 
            md.id AS dossier_id,
            md.dier_id,
            md.gewicht,
            md.gebit_status,
            md.botten_status,
            md.spieren_status,
            md.opmerking,

            d.id AS dier_id_ref,
            d.naam AS dier_naam,
            d.soort AS dier_soort,
            d.geboortedatum AS dier_geboortedatum,
            d.foto_url AS dier_foto

        FROM medisch_dossier md
        JOIN dieren d ON md.dier_id = d.id
        WHERE md.dier_id = ?
        LIMIT 1
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $dierId);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();

    if ($row) {

        $response["data"] = [
            "id"              => $row["dossier_id"],
            "dier_id"         => $row["dier_id"],
            "gewicht"         => $row["gewicht"],
            "gebit_status"    => $row["gebit_status"],
            "botten_status"   => $row["botten_status"],
            "spieren_status"  => $row["spieren_status"],
            "opmerking"       => $row["opmerking"],

            "pet" => [
                "id"            => $row["dier_id_ref"],
                "naam"          => $row["dier_naam"],
                "soort"         => $row["dier_soort"],
                "geboortedatum" => $row["dier_geboortedatum"],
                "foto_url"      => $row["dier_foto"]
            ]
        ];

        $response["message"] = "Medisch dossier gevonden";

    } else {
        $response["data"] = [];
        $response["message"] = "Geen medisch dossier gevonden";
    }

    $stmt->close();

} catch (Exception $e) {
    $response["status"] = 500;
    $response["message"] = "Databasefout";
    $response["error"] = $e->getMessage();
}

echo json_encode($response);
