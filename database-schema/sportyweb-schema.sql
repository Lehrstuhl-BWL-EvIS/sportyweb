/*  Copyright (C) 2021-2022 Stefan Strecker
    https://gitlab.com/fuhevis/sportyweb

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/*  Frühe Fassung eines Datenbankschemas (mit Dummy-Daten) für Sportyweb

    für PostgreSQL 14
    
    Execute: psql postgres -d <your_db_name> -f sportyweb.sql -a
*/

DROP TABLE mitglied_haushalt;
DROP TABLE haushalt;
DROP TABLE mitglied;
DROP TYPE geschlecht_kuerzel;
DROP TYPE mitglied_status;

/* --------------------------------------------- Wiederverwendbare Kürzel */

CREATE TYPE "geschlecht_kuerzel" AS ENUM (
  'm',
  'w',
  'd'
);
COMMENT ON Type "geschlecht_kuerzel" IS 'm = maennlich, w = weiblich, d = divers';

CREATE TYPE "mitglied_status" AS ENUM (
  'aktiv',
  'temporaer',
  'ruhend',
  'inaktiv',
  'sonderstatus',
  'ehrenmitglied'
); /* Noch nicht final */

/* --------------------------------------------- Mitglieder */

CREATE TABLE "mitglied" (
/*  "mitglied_id" UUID PRIMARY KEY, */
  "mitgliedsnummer" serial PRIMARY KEY,
/* Schritt 1 bei der Neueingabe */  
  "nachname" varchar(255) NOT NULL,
  "vorname" varchar(255) NOT NULL,
  "geburtsdatum" date NOT NULL,
  "geschlecht" geschlecht_kuerzel,
/* Schritt 2 : Adresse 
-- adresse(id, strasse_id, nummer, plz)
-- strasse(strasse_id, strasse)
-- plz_ort(plz, ort)
*/
/*
  Adressdaten in Haushalt erfassen statt hier!
*/ 
/*
  "mitglied_strasse" text,
  "mitglied_hausnummer" text,
  "mitglied_hausnummer_zusatz" text,
  "mitglied_plz" text,
  "mitglied_ort" text,  
*/
/* Schritt 3 : Kontaktdaten */
  "telefonnummer1" text NOT NULL, /* Vor INSERT prüfen, ob Telefonnummer bereits in DB */
  "telefonnummer2" text,
  "email" varchar(319),
/* Schritt 4 : Bankverbindung / Zahlung :  */
  "kontoinhaber" varchar(34) NOT NULL,
  "iban" varchar(34) NOT NULL,
/* Schritt 5 : Status */
  "mitgliedstatus" mitglied_status NOT NULL,
/* Autowerte */
  "eintrittsdatum" date NOT NULL DEFAULT CURRENT_DATE,
/*  "datum_erstellt" dateTime NOT NULL DEFAULT 'GETUTCDATE()', */
  "datum_letzte_aenderung" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
/* COMMENT ON COLUMN "mitglieder"."mitgliedsnummer" IS 
'existierende mitgliedsnummer importieren oder neue generieren'; */
/* CONSTRAINT : Kombination aus Vorname, Nachname, Geburtsdatum und Adresse muss eindeutig sein */

-------------------------------------------- Haushalt / Familie 
/* 

Ein Mitglied ist *immer* Teil mindestens eines Haushalts.

Ein Haushalt umfasst *immer* mindestens ein Mitglied.

Ein Haushalt ist konstituiert durch eine Wohnadresse.

*/

CREATE TABLE "haushalt" (
  haushalt_id serial PRIMARY KEY,
  "haushalt_bezeichner" text NOT NULL, /* Bezeichner kann Familiennamen o.ä. entsprechen */ 
  "haushalt_strasse" text NOT NULL,
  "haushalt_hausnummer" text NOT NULL,
  "haushalt_plz" text NOT NULL, /* char(5)? varchar(5)? */ 
  "haushalt_ort" text NOT NULL,
  UNIQUE (haushalt_bezeichner, haushalt_strasse, haushalt_hausnummer, haushalt_plz, haushalt_ort)
);
--Siehe https://github.com/pramsey/pgsql-postal  

--------------------------------------------- m:n Mitglieder_Haushalte 

/*

Ein Mitglied muss mindestens einem Haushalt angehören und kann mehreren Haushalten angehören 

Ein Haushalt umfasst mindestens ein Mitglied und kann beliebig viele Mitglieder umfassen

*/

CREATE TABLE "mitglied_haushalt" (
  mitgliedsnummer integer REFERENCES mitglied,
  haushalt_id integer REFERENCES haushalt,
  "eintrittsdatum" date NOT NULL DEFAULT CURRENT_DATE,
  "ist_erziehungsberechtigter" boolean NOT NULL,
  PRIMARY KEY (mitgliedsnummer, haushalt_id) 
);
