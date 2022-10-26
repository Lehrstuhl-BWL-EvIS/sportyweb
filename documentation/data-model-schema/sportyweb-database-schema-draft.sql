/* Sportyweb Database Schema Design -- Draft version */

/* Copyright (C) 2022 Stefan Strecker, stefan.strecker@fernuni-hagen.de
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
along with this program.  If not, see <https://www.gnu.org/licenses/>. */


/* NOTE: This document is for design and draft purposes only - NOT for implementation.
   For implementation, we use regular database migrations */

/* All values based on UTF8 coding */

/* For SQL expertise, see for example:

https://sqlfordevs.com/ebook

*/


/* NOTE: Privacy and security measures such as hashed values NOT yet accounted for! */



/*
- Person : eine natürliche Person
  - die Normalisierung der Datenhaltung legt das Modellieren organisationaler Rollen wie Mitglied, Mitarbeiter, Trainer 
    Funktionär, Sponsor usw. mittels einer Relation PERSON nahe
  - eine Person kann gleichzeitig mehrere organisationale Rollen ausfüllen   
    - Beispiel : eine Person kann gleichzeitig Mitglied, Mitarbeiter, Trainer und Funktionär sein
  - eine Person kann auch *keine* organisationale Rolle im Verein ausfüllen
    - Beispiel : eine Person kann eine Vereinskontaktperson sein, deren Kontaktdaten erfasst werden sollen,
      z.B. eine Kontaktperson in einem Verband oder im Stadtsportbund usw. 
*/
CREATE TABLE persons (
  person_id uuid PRIMARY KEY,         /* UUID v4 in Postgres; UUID ideally as sortable UUID v6 or v7, see https://github.com/uuid6/uuid6-ietf-draft and https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format, see also https://sqlfordevs.com/uuid-prevent-enumeration-attack */
  last_name varchar(255) NOT NULL,    /* needs UTF8 coding! */
  first_name1 varchar(255) NOT NULL,
  first_name2 varchar(255) NOT NULL,
  first_name3 varchar(255) NOT NULL,
  nickname varchar(255),              /* just in case: If Josef Mustermann is only known as 'Jupp' etc */
  unique_official_id varchar(255),    /* z.B. Personalausweisnummer */
  date_of_birth date NOT NULL,
  gender gender_abbrev NOT NULL,      /* Do not use ENUM TYPES, see https://readyset.io/blog/enums-mysql-vs-postgres and https://twitter.com/tobias_petry/status/1579707412956983297?s=61&t=GLgAfFM-UsOWdtkpcAN68w*/
  phone1 phone_number NOT NULL,       /* Is there a data type to properly store a FQTN? See https://de.wikipedia.org/wiki/E.164 */
  phone2 phone_number,                /* dito */
  email1 email,                       /* Is there a data type to properly store an email address (addr-spec?)? See https://en.wikipedia.org/wiki/Email_address */ 
  email2 email,
  messenger1 messenger,               /* What is the best way to store the messenger apps a person uses and how to reach the person via a messenger? */ 
  messenger2 messenger,
  club_entry_date date NOT NULL,
  person_note text,                    /* Always allow for notes on a tupel */
  postaladdress_id integer REFERENCES postaladdresses(postaladdress_id) 
)

/* 
- Mitglied
  - ein Mitglied ist eine natürliche Person (TODO: Organisationen als Mitglieder)
  - eine Person ist erst durch Abschluss eines Mitgliedsvertrags ein Mitglied
  - ein Mitglied hinterlegt Bankverbindung und Zahlungsweise und Zahlungsrhythmus 
*/
CREATE TABLE members (
  member_id uuid PRIMARY KEY,                     /* Non-public, internal identifier */
  person_id uuid REFERENCES persons(person_id) 
                  ON DELETE NO ACTION;            /* UNIQUE FOREIGN KEY? */
  member_membership_number varchar(255) UNIQUE,   /* Public identifier: Allow for alphanumeric membership numbers; unique membership identifiers usually imported during system configuration and setup */
  member_initial_entry_date date NOT NULL,
  member_membership_state text,                   /* TODO : Describe states and use CHECK constraint to test for valid values, "regular", "temporary_on_hold", "honorary", ...  */
  member_payment_mode text,                       /* TODO : Describe states and use CHECK constraint  to test for valid values, e.g., "cash", "withdrawal" */
  member_bankaccount_iban varchar(34),
  member_bankaccount_holder varchar(34),
  member_note text
  /* member_payment_last_date date, */
  /* member_payment_next_date date, */
  /* member_payment_rhythm : {monthly, quaterly, …} */
  /* member_last_contact date,
  member_last_contact_note text,
  member_last_contact_mode :{email,phone, inperson} */
)


/* 
- Haushalt
  - "Haushalt" ist ein "künstlich eingefügtes" Konzept, mit dem die Zusammenfassung
    von Mitgliedern zu Gruppen ermöglicht wird, z.B. um einen Rabatt auf Mitgliedsbeiträge 
    zu erhalten. Anders als ein starres Konzept wie etwa "Familie" ermöglicht es "Haushalt",
    moderne Formen des Zusammenlebens zu repräsentieren. 
  - Idee hinter dem Konzept "Haushalt" ist, dass jedes Mitglied einem Haushalt angehört, 
    auch wenn der Haushalt nur dieses eine Mitglied umfasst, um zeitlich nachgelagert weitere
    Mitglieder einem Haushalt hinzufügen zu können.
  - Um Patch-Work-Situationen abdecken zu können, kann ein Mitglied auch mehreren Haushalten
    angehören (deshalb die Relation members-households). 
  - ein Haushalt wird über eine postalische Adresse und einen Bezeichner identifiziert
  - da an einer postalischen Adresse mehrere Haushalte existieren können (Mehrfamilienhäuser),
    ist es erforderlich, einem Haushalt einen eindeutigen Namen (Bezeichner) zu vergeben
  - auf eine separate Relation der Adresse eines Haushalts wird bewusst verzichtet,
    um den UNIQUE-Constraint auf die Attribute anlegen zu können.
*/
CREATE TABLE households (
  household_id serial PRIMARY KEY,
  household_identifier varchar(255) UNIQUE,           /* Ex. "Müller-Musterstraße-1"; Vorschlag für eindeutigen Bezeichner sollte in der App autogeneriert werden */
  household_address_street varchar(255) NOT NULL,
  household_address_number varchar(255) NOT NULL,
  household_address_zipcode varchar(255) NOT NULL,
  household_address_city varchar(255) NOT NULL,
  household_note text,
  UNIQUE (household_identifier,household_address_street,household_address_number,household_address_zipcode,household_address_city)
)

/*
- Mitglied-Haushalt (members-households)
  - ein Mitglied muss mindestens einem Haushalt angehören
  - ein Haushalt muss mindestens ein Mitglied umfassen
  - ein Mitglied kann mehreren Haushalten angehören (auch wenn dies auf den ersten Blick
    ungewöhnlich ist, so ermöglicht dies, moderne Formen menschlichen Zusammenlebens wie
    Erwachsene, die in zwei Haushalten im Wechsel leben, zu repräsentieren) 
  - für ein Neumitglied wird ein Haushalt neu angelegt, sofern ein korrespondierender Haushalt
    noch nicht existiert; andernfalls wird das Neumitglied einem bereits vorliegenden Haushalt
    hinzugefügt.
*/
CREATE TABLE members-households (
  member_id uuid NOT NULL,
  household_id integer NOT NULL,
  FOREIGN KEY (member_id) REFERENCES members(member_id),
  FOREIGN KEY (household_id) REFERENCES households(household_id),
  UNIQUE (member_id,household_id),
  member_household_entry_date date,
  member_household_is_legal_guardian boolean
)

/* 
- Postalische Adresse
  - eine Adresse kann Personen, Mitgliedern, Sportstätten zugeordnet sein
  - notwendige Attribute einer Adresse sind in verschiedenen Standards dargestellt
  - hier wird eine stark vereinfachte Representation einer Adresse für Postadressen in Deutschland vorgeschlagen
  - aus Gründen der Vereinfachung könnten die Attribute einer Postadresse auch in die Relation PERSONS integriert werden
  
Professionally representing (int'l) postal addresses in a database schema is a challenge but potential solutions are plenty, see e.g. 

https://de.wikipedia.org/wiki/Postanschrift

https://www.iso.org/obp/ui/#iso:std:iso:19160:-4:ed-1:v1:en

http://xml.coverpages.org/xnal.html 

https://softwareengineering.stackexchange.com/questions/357900/whats-a-universal-way-to-store-a-geographical-address-location-in-a-database
*/
CREATE TABLE postaladdresses (
  postaladdress_id serial PRIMARY KEY,
  postaladdress_street varchar(255),
  postaladdress_number varchar(20),
  postaladdress_zipcode varchar(20),
  postaladdress_city varchar(20),
  postaladdress_country varchar(2),         /* ISO-Code */
  UNIQUE(postaladdress_street,postaladdress_number,postaladdress_zipcode,postaladdress_city,postaladdress_country)
)