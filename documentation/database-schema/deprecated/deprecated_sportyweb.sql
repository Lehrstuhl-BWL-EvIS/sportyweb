/* Copyright (c) 2021-2022 Stefan Strecker

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

/* Frühe Fassung eines Datenbankschemas für Sportweb 
  für PostgreSQL 14
  Execute: psql postgres -d <your_db_name> -f sportyweb.sql -a
*/

DROP TABLE mitglieder;
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
  'inaktiv',
  'aktiv',
  'sonderstatus',
  'ehrenmitglied'
);
/* COMMENT ON Type "mitglied_status" IS 'Status 0 = Inaktiv, Status 1 = Aktiv, 
Status 2 = Sonderstatus, Status 4 = Ehrenmitglied'; */


/* --------------------------------------------- Mitglieder */

CREATE TABLE "mitglieder" (
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
  "wohnadresse_strasse" text,
  "wohnadresse_hausnummer" text,
  "wohnadresse_plz" text,
  "wohnadresse_ort" text,
/* Schritt 3 : Kontaktdaten */
  "telefonnummer1" text NOT NULL, /* Vor INSERT prüfen, ob Telefonnummer bereits in DB */
  "telefonnummer2" text,
  "email" varchar(319),
/* Schritt 4 : Bankverbindung / Zahlung */
  "iban" varchar(34),
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


/* --------------------------------------------- Haushalt / Familie */

Haushalt
--------
haushalt_id PK int 
mitglied_id binaryID FK -< Mitglied.mitglied_id
# Siehe https://github.com/pramsey/pgsql-postal
postalische_adresse string 
haushalt_eintrittsdatum date

/* --------------------------------------------- Testdaten */

INSERT INTO mitglieder VALUES 
(DEFAULT, 'Mustermann', 'Max', '1970-01-01', 'm', 
'Musterstr.', '1d', '44444', 'Musterhausen', 
'0211-23456767', NULL, 'max@mustermann.de', 
'IBAN', 
'aktiv');

INSERT INTO mitglieder VALUES 
(DEFAULT, 'Mustermann', 'Max', '1970-01-01', 'm', 
'Musterstr.', '1d', '44444', 'Musterhausen', 
'0211-23456767', NULL, 'max@mustermann.de', 
'IBAN', 
'inaktiv');
