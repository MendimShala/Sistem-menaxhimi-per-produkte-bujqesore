-- Sistemi për Menaxhimin e Fermerëve dhe Produkteve Bujqësore
-- Model fillestar relacional (MySQL 8+)

CREATE DATABASE IF NOT EXISTS sistem_fermeret_produkte
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistem_fermeret_produkte;

-- -------------------------------------------------
-- 1. Llogaritë e sistemit
-- Fjalëkalimi ruhet vetëm si hash.
-- -------------------------------------------------
CREATE TABLE perdorues (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  emri             VARCHAR(80)  NOT NULL,
  mbiemri          VARCHAR(80)  NOT NULL,
  email            VARCHAR(120) NOT NULL,
  fjalekalimi_hash VARCHAR(255) NOT NULL,
  roli             ENUM('ADMIN', 'FERMER', 'BLERES') NOT NULL,
  telefoni         VARCHAR(30) NULL,
  aktiv            TINYINT(1) NOT NULL DEFAULT 1,
  krijuar_me       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_perdorues_email (email)
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 2. Profili i fermerit
-- Relacion 1:1  perdorues -> fermer
-- Të dhënat bujqësore nuk futen te tabela e llogarisë, sepse
-- administratori dhe blerësi nuk i kanë këto fusha.
-- -------------------------------------------------
CREATE TABLE fermer (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  perdorues_id     BIGINT UNSIGNED NOT NULL,
  komuna           VARCHAR(80)  NOT NULL,
  fshati           VARCHAR(80)  NOT NULL,
  adresa           VARCHAR(200) NULL,
  siperfaqja_ha    DECIMAL(10,2) NOT NULL,
  pershkrimi       TEXT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_fermer_perdorues (perdorues_id),
  CONSTRAINT fk_fermer_perdorues
    FOREIGN KEY (perdorues_id) REFERENCES perdorues(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_fermer_siperfaqja CHECK (siperfaqja_ha > 0)
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 3. Ngastrat / toka e fermerit
-- Relacion 1:N  fermer -> ngastre
-- Një ngastër i takon një fermeri, jo disa fermerëve njëkohësisht.
-- -------------------------------------------------
CREATE TABLE ngastre (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  fermer_id        BIGINT UNSIGNED NOT NULL,
  emri             VARCHAR(80) NOT NULL,
  siperfaqja_ha    DECIMAL(10,2) NOT NULL,
  lloji_tokes      VARCHAR(60) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_ngastre_fermer
    FOREIGN KEY (fermer_id) REFERENCES fermer(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_ngastre_siperfaqja CHECK (siperfaqja_ha > 0)
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 4. Kategoritë e produkteve bujqësore
-- -------------------------------------------------
CREATE TABLE kategori_produkti (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  emri             VARCHAR(80) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_kategori_emri (emri)
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 5. Katalogu i produkteve (p.sh. grurë, domate, mjaltë)
-- Relacion 1:N  kategori -> produkt
-- Katalogun e mban administratori; fermeri nuk krijon emra të lirë
-- që të mos ketë “domate”, “Domate ” dhe “domat” si tre produkte.
-- -------------------------------------------------
CREATE TABLE produkt_bujqesor (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  kategori_id      BIGINT UNSIGNED NOT NULL,
  emri             VARCHAR(120) NOT NULL,
  njesia           ENUM('KG', 'TONE', 'COPE', 'LITRA') NOT NULL DEFAULT 'KG',
  pershkrimi       VARCHAR(255) NULL,
  aktiv            TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_produkt_emri (emri),
  CONSTRAINT fk_produkt_kategori
    FOREIGN KEY (kategori_id) REFERENCES kategori_produkti(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 6. Prodhimi (fermër × produkt)
-- Relacion N:N  fermer <-> produkt_bujqesor  përmes kësaj tabele
-- Një fermer prodhon shumë produkte; një produkt e prodhojnë shumë fermerë.
-- Nuk vendoset produkt_id te fermer, sepse atëherë fermeri do të kishte
-- vetëm një produkt. Nuk vendoset fermer_id te produkt, sepse produkti
-- është katalog i përbashkët.
-- -------------------------------------------------
CREATE TABLE prodhim (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  fermer_id        BIGINT UNSIGNED NOT NULL,
  produkt_id       BIGINT UNSIGNED NOT NULL,
  ngastre_id       BIGINT UNSIGNED NULL,
  data_vjeljes     DATE NOT NULL,
  sasia            DECIMAL(12,2) NOT NULL,
  cilesia          ENUM('E_PARE', 'E_DYTE', 'E_TRETE') NOT NULL DEFAULT 'E_PARE',
  shenime          VARCHAR(255) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_prodhim_fermer
    FOREIGN KEY (fermer_id) REFERENCES fermer(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_prodhim_produkt
    FOREIGN KEY (produkt_id) REFERENCES produkt_bujqesor(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_prodhim_ngastre
    FOREIGN KEY (ngastre_id) REFERENCES ngastre(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_prodhim_sasia CHECK (sasia > 0)
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 7. Oferta e produktit në shitje
-- Relacion 1:N  fermer -> oferta
-- Relacion 1:N  produkt -> oferta
-- Fermeri publikon sa ka për shitje dhe me çfarë çmimi.
-- -------------------------------------------------
CREATE TABLE oferta (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  fermer_id        BIGINT UNSIGNED NOT NULL,
  produkt_id       BIGINT UNSIGNED NOT NULL,
  sasia_disponueshme DECIMAL(12,2) NOT NULL,
  cmimi_njesi      DECIMAL(10,2) NOT NULL,
  data_publikimit  DATE NOT NULL,
  statusi          ENUM('AKTIVE', 'PAUZUAR', 'SHITUR', 'ANULUAR') NOT NULL DEFAULT 'AKTIVE',
  PRIMARY KEY (id),
  CONSTRAINT fk_oferta_fermer
    FOREIGN KEY (fermer_id) REFERENCES fermer(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_oferta_produkt
    FOREIGN KEY (produkt_id) REFERENCES produkt_bujqesor(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_oferta_sasia CHECK (sasia_disponueshme >= 0),
  CONSTRAINT chk_oferta_cmimi CHECK (cmimi_njesi >= 0)
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 8. Blerësi (profil shtesë, 1:1 me perdorues rolin BLERES)
-- -------------------------------------------------
CREATE TABLE bleres (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  perdorues_id     BIGINT UNSIGNED NOT NULL,
  emri_biznesit    VARCHAR(120) NOT NULL,
  komuna           VARCHAR(80) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_bleres_perdorues (perdorues_id),
  CONSTRAINT fk_bleres_perdorues
    FOREIGN KEY (perdorues_id) REFERENCES perdorues(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -------------------------------------------------
-- 9. Porosia e produktit
-- Relacion 1:N  oferta -> porosi
-- Relacion 1:N  bleres -> porosi
-- Një porosi i takon një oferte (një produkt i një fermeri).
-- Nëse blerësi do dy produkte, bën dy porosi — e thjeshtë për këtë semestër.
-- -------------------------------------------------
CREATE TABLE porosi (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  oferta_id        BIGINT UNSIGNED NOT NULL,
  bleres_id        BIGINT UNSIGNED NOT NULL,
  sasia            DECIMAL(12,2) NOT NULL,
  shuma_totale     DECIMAL(12,2) NOT NULL,
  data_porosise    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  statusi          ENUM('PRITJE', 'PRANUAR', 'DORAZUAR', 'ANULUAR') NOT NULL DEFAULT 'PRITJE',
  PRIMARY KEY (id),
  CONSTRAINT fk_porosi_oferta
    FOREIGN KEY (oferta_id) REFERENCES oferta(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_porosi_bleres
    FOREIGN KEY (bleres_id) REFERENCES bleres(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_porosi_sasia CHECK (sasia > 0)
) ENGINE=InnoDB;

-- Të dhëna fillestare të katalogut (për demo / prezantim)
INSERT INTO kategori_produkti (emri) VALUES
  ('Drithëra'),
  ('Perime'),
  ('Pemë'),
  ('Produkte blegtorale'),
  ('Mjaltë dhe bletari');

INSERT INTO produkt_bujqesor (kategori_id, emri, njesia) VALUES
  (1, 'Grurë', 'KG'),
  (1, 'Misër', 'KG'),
  (2, 'Domate', 'KG'),
  (2, 'Speci', 'KG'),
  (2, 'Patate', 'KG'),
  (3, 'Mollë', 'KG'),
  (3, 'Rrush', 'KG'),
  (4, 'Qumësht', 'LITRA'),
  (4, 'Djathë', 'KG'),
  (5, 'Mjaltë', 'KG');
