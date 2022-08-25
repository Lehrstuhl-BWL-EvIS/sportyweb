-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

-- https://app.quickdatabasediagrams.com/

CREATE TABLE "Mitglied" (
    "mitglied_id" binaryID   NOT NULL,
    "mitgliedsnummer" string   NOT NULL,
    "datum_erstellt" dateTime  DEFAULT getutcdate() NOT NULL,
    "datum_modifiziert" dateTime   NOT NULL,
    "nachname" string   NOT NULL,
    "vorname1" string   NOT NULL,
    "vorname2" string   NOT NULL,
    "geburtsdatum" date   NOT NULL,
    "geschlecht" int   NOT NULL,
    "ausweisdokumentnummer" string   NOT NULL,
    "adresse" string   NOT NULL,
    -- https://github.com/pgstuff/telephone
    "telefonnummer1" string   NOT NULL,
    "telefonnummer2" string   NOT NULL,
    "email1" string   NOT NULL,
    "email2" string   NOT NULL,
    "notfallkontakt1" string   NOT NULL,
    "notfallkontakt2" string   NOT NULL,
    "notiz" text   NOT NULL,
    "foto" blob   NOT NULL,
    "letzterKontakt" date   NOT NULL,
    "mitgliedstatus_id" int   NOT NULL,
    CONSTRAINT "pk_Mitglied" PRIMARY KEY (
        "mitglied_id"
     ),
    CONSTRAINT "uc_Mitglied_mitgliedsnummer" UNIQUE (
        "mitgliedsnummer"
    )
);

-- - letzteKommunikation | letzterKontakt : Wer im Verein hatte diesen Kontakt und worum ging es?
-- - besondereGesundheitlicheVermerke (hat Allergien? Blutgruppe? …)
-- - ärztlichesAttest | liegt vor? nicht vor?
-- - Hausarzt
CREATE TABLE "Mitgliedstatus" (
    "mitgliedstatus_id" int   NOT NULL,
    "statusbeschreibung" string   NOT NULL,
    CONSTRAINT "pk_Mitgliedstatus" PRIMARY KEY (
        "mitgliedstatus_id"
     )
);

CREATE TABLE "Haushalt" (
    "haushalt_id" int   NOT NULL,
    "mitglied_id" binaryID   NOT NULL,
    -- Siehe https://github.com/pramsey/pgsql-postal
    "postalische_adresse" string   NOT NULL,
    "haushalt_eintrittsdatum" date   NOT NULL,
    CONSTRAINT "pk_Haushalt" PRIMARY KEY (
        "haushalt_id"
     )
);

ALTER TABLE "Mitglied" ADD CONSTRAINT "fk_Mitglied_mitgliedstatus_id" FOREIGN KEY("mitgliedstatus_id")
REFERENCES "Mitgliedstatus" ("mitgliedstatus_id");

ALTER TABLE "Haushalt" ADD CONSTRAINT "fk_Haushalt_mitglied_id" FOREIGN KEY("mitglied_id")
REFERENCES "Mitglied" ("mitglied_id");

CREATE INDEX "idx_Mitglied_nachname"
ON "Mitglied" ("nachname");

