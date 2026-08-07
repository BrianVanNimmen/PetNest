-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: petnest_db:3306
-- Gegenereerd op: 25 jun 2026 om 15:05
-- Serverversie: 10.4.34-MariaDB-1:10.4.34+maria~ubu2004
-- PHP-versie: 8.3.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `petnest_home`
--

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `bezoeken`
--

CREATE TABLE `bezoeken` (
  `id` int(10) UNSIGNED NOT NULL,
  `dier_id` int(10) UNSIGNED NOT NULL,
  `klant_id` int(10) UNSIGNED NOT NULL,
  `dierenarts_id` int(10) UNSIGNED DEFAULT NULL,
  `geplande_datumtijd` datetime NOT NULL,
  `effectieve_datumtijd` datetime DEFAULT NULL,
  `type` enum('vaccinatie','controle','operatie','overig') NOT NULL DEFAULT 'controle',
  `notities` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `dieren`
--

CREATE TABLE `dieren` (
  `id` int(10) UNSIGNED NOT NULL,
  `naam` varchar(100) NOT NULL,
  `klant_id` int(10) UNSIGNED NOT NULL,
  `dierenarts_id` int(10) UNSIGNED DEFAULT NULL,
  `foto_url` varchar(255) DEFAULT NULL,
  `geboortedatum` date DEFAULT NULL,
  `soort` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `dierenartsen`
--

CREATE TABLE `dierenartsen` (
  `id` int(10) UNSIGNED NOT NULL,
  `voornaam` varchar(100) NOT NULL,
  `achternaam` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `firebase_uid` varchar(128) DEFAULT NULL,
  `status` enum('goedgekeurd','geweigerd','in afwachting') NOT NULL DEFAULT 'in afwachting',
  `certificaat_url` varchar(255) DEFAULT NULL,
  `telefoon` varchar(30) DEFAULT NULL,
  `praktijknaam` varchar(150) DEFAULT NULL,
  `gemeente_id` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `gemeente`
--

CREATE TABLE `gemeente` (
  `id` int(10) UNSIGNED NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `naam` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `klanten`
--

CREATE TABLE `klanten` (
  `id` int(10) UNSIGNED NOT NULL,
  `voornaam` varchar(100) NOT NULL,
  `achternaam` varchar(100) NOT NULL,
  `geboortedatum` date NOT NULL,
  `gemeente_id` int(10) UNSIGNED NOT NULL,
  `email` varchar(150) NOT NULL,
  `firebase_uid` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `medisch_dossier`
--

CREATE TABLE `medisch_dossier` (
  `id` int(10) UNSIGNED NOT NULL,
  `dier_id` int(10) UNSIGNED NOT NULL,
  `gewicht` decimal(5,2) DEFAULT NULL,
  `gebit_status` varchar(100) NOT NULL,
  `botten_status` varchar(100) NOT NULL,
  `spieren_status` varchar(100) NOT NULL,
  `opmerking` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexen voor geëxporteerde tabellen
--

--
-- Indexen voor tabel `bezoeken`
--
ALTER TABLE `bezoeken`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_bezoeken_dier` (`dier_id`),
  ADD KEY `fk_bezoeken_eigenaar` (`klant_id`),
  ADD KEY `fk_bezoeken_dierenarts` (`dierenarts_id`);

--
-- Indexen voor tabel `dieren`
--
ALTER TABLE `dieren`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_dieren_klant` (`klant_id`),
  ADD KEY `fk_dieren_dierenarts` (`dierenarts_id`);

--
-- Indexen voor tabel `dierenartsen`
--
ALTER TABLE `dierenartsen`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_dierenarts_gemeente` (`gemeente_id`);

--
-- Indexen voor tabel `gemeente`
--
ALTER TABLE `gemeente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `postcode` (`postcode`,`naam`);

--
-- Indexen voor tabel `klanten`
--
ALTER TABLE `klanten`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `gemeente_id` (`gemeente_id`);

--
-- Indexen voor tabel `medisch_dossier`
--
ALTER TABLE `medisch_dossier`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dier_id` (`dier_id`);

--
-- AUTO_INCREMENT voor geëxporteerde tabellen
--

--
-- AUTO_INCREMENT voor een tabel `bezoeken`
--
ALTER TABLE `bezoeken`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `dieren`
--
ALTER TABLE `dieren`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `dierenartsen`
--
ALTER TABLE `dierenartsen`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `gemeente`
--
ALTER TABLE `gemeente`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `klanten`
--
ALTER TABLE `klanten`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `medisch_dossier`
--
ALTER TABLE `medisch_dossier`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Beperkingen voor geëxporteerde tabellen
--

--
-- Beperkingen voor tabel `bezoeken`
--
ALTER TABLE `bezoeken`
  ADD CONSTRAINT `fk_bezoeken_dier` FOREIGN KEY (`dier_id`) REFERENCES `dieren` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_bezoeken_dierenarts` FOREIGN KEY (`dierenarts_id`) REFERENCES `dierenartsen` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_bezoeken_klant` FOREIGN KEY (`klant_id`) REFERENCES `klanten` (`id`) ON UPDATE CASCADE;

--
-- Beperkingen voor tabel `dieren`
--
ALTER TABLE `dieren`
  ADD CONSTRAINT `dieren_ibfk_1` FOREIGN KEY (`klant_id`) REFERENCES `klanten` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dieren_dierenarts` FOREIGN KEY (`dierenarts_id`) REFERENCES `dierenartsen` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Beperkingen voor tabel `dierenartsen`
--
ALTER TABLE `dierenartsen`
  ADD CONSTRAINT `dierenartsen_ibfk_1` FOREIGN KEY (`gemeente_id`) REFERENCES `gemeente` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Beperkingen voor tabel `klanten`
--
ALTER TABLE `klanten`
  ADD CONSTRAINT `klanten_ibfk_1` FOREIGN KEY (`gemeente_id`) REFERENCES `gemeente` (`id`) ON UPDATE CASCADE;

--
-- Beperkingen voor tabel `medisch_dossier`
--
ALTER TABLE `medisch_dossier`
  ADD CONSTRAINT `medisch_dossier_ibfk_2` FOREIGN KEY (`dier_id`) REFERENCES `dieren` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
