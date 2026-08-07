SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `petnest_home` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `petnest_home`;

-- --------------------------------------------------------

CREATE TABLE `bezoeken` (
  `id` int UNSIGNED NOT NULL,
  `dier_id` int UNSIGNED NOT NULL,
  `klant_id` int UNSIGNED NOT NULL,
  `dierenarts_id` int UNSIGNED DEFAULT NULL,
  `geplande_datumtijd` datetime NOT NULL,
  `effectieve_datumtijd` datetime DEFAULT NULL,
  `type` enum('vaccinatie','controle','operatie','overig') NOT NULL DEFAULT 'controle',
  `notities` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

CREATE TABLE `dieren` (
  `id` int UNSIGNED NOT NULL,
  `naam` varchar(100) NOT NULL,
  `klant_id` int UNSIGNED NOT NULL,
  `dierenarts_id` int UNSIGNED DEFAULT NULL,
  `foto_url` varchar(255) DEFAULT NULL,
  `geboortedatum` date DEFAULT NULL,
  `soort` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

CREATE TABLE `dierenartsen` (
  `id` int UNSIGNED NOT NULL,
  `voornaam` varchar(100) NOT NULL,
  `achternaam` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `firebase_uid` varchar(128) DEFAULT NULL,
  `status` enum('goedgekeurd','geweigerd','in afwachting') NOT NULL DEFAULT 'in afwachting',
  `certificaat_url` varchar(255) DEFAULT NULL,
  `telefoon` varchar(30) DEFAULT NULL,
  `praktijknaam` varchar(150) DEFAULT NULL,
  `gemeente_id` int UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

CREATE TABLE `gemeente` (
  `id` int UNSIGNED NOT NULL,
  `postcode` varchar(10) NOT NULL,
  `naam` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

CREATE TABLE `klanten` (
  `id` int UNSIGNED NOT NULL,
  `voornaam` varchar(100) NOT NULL,
  `achternaam` varchar(100) NOT NULL,
  `geboortedatum` date NOT NULL,
  `gemeente_id` int UNSIGNED NOT NULL,
  `email` varchar(150) NOT NULL,
  `firebase_uid` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

CREATE TABLE `medisch_dossier` (
  `id` int UNSIGNED NOT NULL,
  `dier_id` int UNSIGNED NOT NULL,
  `gewicht` decimal(5,2) DEFAULT NULL,
  `gebit_status` varchar(100) NOT NULL,
  `botten_status` varchar(100) NOT NULL,
  `spieren_status` varchar(100) NOT NULL,
  `opmerking` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------
-- Indexen
-- --------------------------------------------------------

ALTER TABLE `bezoeken`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_bezoeken_dier` (`dier_id`),
  ADD KEY `fk_bezoeken_eigenaar` (`klant_id`),
  ADD KEY `fk_bezoeken_dierenarts` (`dierenarts_id`);

ALTER TABLE `dieren`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_dieren_klant` (`klant_id`),
  ADD KEY `fk_dieren_dierenarts` (`dierenarts_id`);

ALTER TABLE `dierenartsen`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_dierenarts_gemeente` (`gemeente_id`);

ALTER TABLE `gemeente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `postcode` (`postcode`, `naam`);

ALTER TABLE `klanten`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `gemeente_id` (`gemeente_id`);

ALTER TABLE `medisch_dossier`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dier_id` (`dier_id`);

-- --------------------------------------------------------
-- AUTO_INCREMENT
-- --------------------------------------------------------

ALTER TABLE `bezoeken`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `dieren`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `dierenartsen`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `gemeente`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `klanten`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE `medisch_dossier`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------
-- Foreign keys
-- --------------------------------------------------------

ALTER TABLE `bezoeken`
  ADD CONSTRAINT `fk_bezoeken_dier` FOREIGN KEY (`dier_id`) REFERENCES `dieren` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_bezoeken_dierenarts` FOREIGN KEY (`dierenarts_id`) REFERENCES `dierenartsen` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_bezoeken_klant` FOREIGN KEY (`klant_id`) REFERENCES `klanten` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `dieren`
  ADD CONSTRAINT `dieren_ibfk_1` FOREIGN KEY (`klant_id`) REFERENCES `klanten` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dieren_dierenarts` FOREIGN KEY (`dierenarts_id`) REFERENCES `dierenartsen` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `dierenartsen`
  ADD CONSTRAINT `dierenartsen_ibfk_1` FOREIGN KEY (`gemeente_id`) REFERENCES `gemeente` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `klanten`
  ADD CONSTRAINT `klanten_ibfk_1` FOREIGN KEY (`gemeente_id`) REFERENCES `gemeente` (`id`) ON UPDATE CASCADE;

ALTER TABLE `medisch_dossier`
  ADD CONSTRAINT `medisch_dossier_ibfk_2` FOREIGN KEY (`dier_id`) REFERENCES `dieren` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;
