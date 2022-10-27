/* Sportyweb Database Schema Design -- Draft version */

/* 

Copyright (C) 2022 Stefan Strecker, stefan.strecker@fernuni-hagen.de
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

-- NOTE: This document is for design and draft purposes only - NOT for implementation.
-- For implementation, we use regular database migrations 
-- For SQL expertise, see for example: https://sqlfordevs.com/ebook
-- All values based on UTF8 coding 
-- NOTE: Privacy and security measures such as hashed values NOT yet accounted for! 
-- NOTE: Database schema is non-normalized wrt various fields/attributes   
-- NOTE: Database schema ignores recording data change history aka data auditing / database versioning, 
--       see https://github.com/izelnakri/paper_trail or https://github.com/ZennerIoT/ex_audit 

/*
- Clubs/Vereine
  - es scheint ein Nummerierungsschema und -System durch den DOSB und die LSB zu geben
    hierzu sind weitere Recherchen notwendig (Vereinskennziffer)
*/
CREATE TABLE clubs (
  club_id uuid PRIMARY KEY,
  club_landessportbund_vereinskennziffer varchar(255) UNIQUE NOT NULL,
  club_fullname varchar(255) UNIQUE NOT NULL,
  club_shortname varchar(255) UNIQUE NOT NULL,
  club_website varchar(255) UNIQUE,
  club_founding_date date,
  club_logo bytea
)
/*
INSERT INTO clubs VALUES 
(gen_random_uuid (), 'ABC123', 'Musterverein', 'Muster', 'https://musterverein.de', '1900-01-01');
*/



/*
- ClubUnits / Vereinseinheit : ein Verein ist in Organisationseinheiten (z.B. Abteilungen) unterteilt
  - Vereinseinheit ist synonym mit Organisationseinheit (Begriff der Organisationstheorie)
  - ein Verein betreibt mindestens eine Vereinseinheit
  - eine Vereinseinheit ist genau einem Verein zugeordnet
  - Bsp. für eine Vereinseinheit : Abteilung, Unterabteilung, Unterunterabteilung usw.
  - eine Vereinseinheit kann einer anderen Vereinseinheit untergeordnet sein
  - eine Vereinseinheit kann einer oder keiner übergeordneten Vereinseinheit zugeordnet sein
  - Eine Vereinseinheit verantwortet die Bereitstellung mindestens eines Sportangebots
  - Hinweis: Vereinseinheiten sind in dieser Modellierung bewusst getrennt von Sportangeboten des Vereins 
    gedacht und modelliert.
    Erst durch die nachfolgend skizzierte Datenhaltung zu Sportangeboten und ihrer Systematisierung und
    Strukturierung wird die Beteiligung einer Vereinseinheit an der Ausrichtung von Sportangeboten modelliert!
  - mit anderen Worten: Die Modellierung überlässt es den Vereinsverantwortlichen, mehrere Abteilungsebenen
    anzulegen und zu pflegen _oder_ mit nur einer ("Haupt-") Ebene zu arbeiten.
  - Beispiel 1: Haupt-Abteilung: Fussball - Unterabteilungen: Kinder- und Jugendfussball, Seniorenfussball 
  - Beispiel 2: Haupt-Abteilung: Fussball, Haupt-Abteilung: Basketball, Haupt-Abteilung: Volleyball usw. 
  - (Anmerkung: Die Modellierung erlaubt es auch, zu einem späteren Zeitpunkt neue Vereinseinheiten anzulegen
    und diese anderen Vereinseinheiten unterzuordnen)
*/
CREATE TABLE clubunits (
  clubunit_id serial PRIMARY KEY,
  club_id uuid REFERENCES clubs(club_id) ON DELETE NO ACTION,            /* UNIQUE FOREIGN KEY? */
  parent_id integer REFERENCES clubunits(clubunit_id),
  clubunit_type varchar(255) NOT NULL,  -- Typ: Hauptabteilung | Abteilung
  clubunit_name varchar(255) NOT NULL,  -- Bezeichner: Fussball, Fitness-Sport
  clubunit_shortname varchar(255) NOT NULL,
  clubunit_inception date
)

/*
CREATE TABLE clubunit_types (
  clubunit_type_id serial PRIMARY KEY,
  clubunit_type_name varchar(255) UNIQUE NOT NULL 
)
*/
/*
INSERT INTO clubunits VALUES 
(DEFAULT, '438b0e41-0433-4083-8afa-e6fab0172a22', DEFAULT, 'Hauptabteilung', 'Fussball', 'Fussball-Abtlg.', '1969-12-32');
INSERT INTO clubunits VALUES 
(DEFAULT, '438b0e41-0433-4083-8afa-e6fab0172a22', DEFAULT, 'Hauptabteilung', 'Volleyball', 'Volleyball-Abtlg.');
INSERT INTO clubunits VALUES 
(DEFAULT, '438b0e41-0433-4083-8afa-e6fab0172a22', 1, 'Abteilung Jugendfussball', 'Jugendfussball-Abtlg.');
*/



/* 
- Postalische Adresse
  - eine Adresse kann Personen, Mitgliedern, Sportstätten und anderen Entitäten zugeordnet sein
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
/*
INSERT INTO postaladdresses VALUES (
  DEFAULT, 'Universitätsstr.', '41', '51087', 'Hagen', 'DE'
)
*/



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
  nickname varchar(255),              
  unique_official_id varchar(255),    /* z.B. Personalausweisnummer */
  date_of_birth date NOT NULL,
  gender gender_abbrev NOT NULL,      /* MAYBE use ENUM TYPES, see https://readyset.io/blog/enums-mysql-vs-postgres and https://twitter.com/tobias_petry/status/1579707412956983297?s=61&t=GLgAfFM-UsOWdtkpcAN68w*/
  phone1 phone_number NOT NULL,       /* Is there a data type to properly store a FQTN? See https://de.wikipedia.org/wiki/E.164 */
  phone2 phone_number,                /* dito */
  email1 email,                       /* Is there a data type to properly store an email address (addr-spec?)? See https://en.wikipedia.org/wiki/Email_address */ 
  email2 email,
  messenger1 messenger,               /* What is the best way to store the messenger apps a person uses and how to reach the person via a messenger? */ 
  messenger2 messenger,
  person_note text,                    /* Always allow for notes on a tupel */
  postaladdress_id integer REFERENCES postaladdresses(postaladdress_id) 
)
/*
INSERT INTO persons VALUES 
(get_random_uuid(), '438b0e41-0433-4083-8afa-e6fab0172a22', DEFAULT, 'Hauptabteilung', 'Fussball', 'Fussball-Abtlg.', '1969-12-32');
*/

/* 
- Mitglied
  - ein Mitglied ist eine natürliche Person (TODO: Organisationen als Mitglieder)
  - eine Person ist erst durch Abschluss eines Mitgliedsvertrags ein Mitglied
  - ein Mitglied hinterlegt Bankverbindung und Zahlungsweise und Zahlungsrhythmus 
*/
CREATE TABLE members (
  member_id uuid PRIMARY KEY,                     /* Non-public, internal identifier */
  person_id uuid REFERENCES persons(person_id) 
                  ON DELETE NO ACTION,            /* UNIQUE FOREIGN KEY? */
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
CREATE TABLE members_households (
  member_id uuid NOT NULL,
  household_id integer NOT NULL,
  FOREIGN KEY (member_id) REFERENCES members(member_id),
  FOREIGN KEY (household_id) REFERENCES households(household_id),
  UNIQUE (member_id,household_id),
  member_household_entry_date date,
  member_household_is_legal_guardian boolean
)


/* 
  memberships

- Mitgliedschaft
  - Mitgliedsvertrag : ein aktuell gültiger Mitgliedsvertrag ist Grundlage der Vereinsteilnahme, siehe
  https://www.rkpn.de/vereinsrecht/veroeffentlichungen/die-aufnahme-neuer-mitglieder-in-den-verein.html
  - ein Mitgliedsvertrag hat formal zwei Vertragspartner : Verein und Mitglied (Person)
  - ein Mitglied muss mindestens einen Mitgliedsvertrag abgeschlossen haben
  - ein Mitglied kann einen Mitgliedsvertrag ohne Vertragsende abschließen und
    lebenslang Mitglied mit diesem Mitgliedsvertrag bleiben
  - ein Mitglied kann im Laufe der Zeit mehrere Mitgliedsverträge abschließen, wenn
    das Mitglied einen früher laufenden Mitgliedsvertrag beendet hat und nach einiger Zeit
    wieder einen Mitgliedsvertrag abschließt
  - zu jedem Zeitpunkt darf ein Mitglied maximal genau einen Mitgliedsvertrag unterhalten 
  - zu jedem Zeitpunkt muss ein Mitglied genau einen Mitgliedsvertrag unterhalten
  - Ruhezeiten: ein Mitglied kann mehrmals temporär einen Mitgliedsvertrag aussetzen (diverse Gründen)
  - diverse weitere Aspekte eines Mitgliedsvertrags sind hier _noch nicht_ modelliert
*/
CREATE TABLE memberships (
  membership_id serial PRIMARY KEY,
  member_id uuid REFERENCES members(member_id),
  membership_contract_number varchar(255) UNIQUE,   /* Vertragsnummer */
  membership_contract_signing_date date NOT NULL,   /* Datum des Vertragsabschlusses */
  membership_contract_termination_date date,        /* Datum der Vertragskündigung */
  membership_start_date date NOT NULL,              /* Aufnahmedatum */
  membership_end_date date,                         /* Vertragsende, sofern im Vertrag festgelegt */ 
  membership_temphold_start_date date,              /* falls Vertrag temporär unterbrochen wird: Vertrag ruht */ 
  membership_temphold_end_date date,              
  membership_temphold_note text,
  membership_base_yearly_fee money,                 -- Part of overall fee structure
  membership_note text              
)
/*
CREATE TABLE membership_change_history (
  membership_change_history__id serial PRIMARY KEY,
  membership_id integer REFERENCES memberships(membership_id),
  membership_change_reason varchar(255)                   -- Grund für Vertragsänderung: Vertrag ruht, Vertragsunterbrechung, etc.
  membership_change_start_date date        
  membership_note text
)
*/


/*
- Mitgliedschaft_Vereinseinheit 
  - ein Mitgliedsvertrag kann Einzelposten umfassen, die sich auf die Mitgliedschaft in einer
    Vereinseinheit (z.B. einer Abteilung) umfassen
*/
CREATE TABLE membership_clubunit (
  membership_id integer NOT NULL,
  clubunit_id integer NOT NULL,
  FOREIGN KEY (membership_id) REFERENCES memberships(membership_id),
  FOREIGN KEY (clubunit_id) REFERENCES clubunits(clubunit_id),
  UNIQUE (membership_id,clubunit_id),
  membership_clubunit_start_date date,
  membership_clubunit_end_date date,
  membership_clubunit_yearly_fee money          -- Part of overall fee structure 
)


/* 
- branch_offices / Geschaeftsstelle : eine Geschaeftsstelle wird von einem Verein betrieben
  - ein Verein betreibt eine oder mehrere Geschaeftsstellen
  - eine Geschaeftsstelle hat eine Besucheradresse und eine postalische Adresse sowie
    ein oder mehrere Telefonverbindungen
*/
CREATE TABLE branch_offices (
  branch_office_id serial PRIMARY KEY,
  club_id uuid REFERENCES clubs(club_id),
  branch_office_name varchar(255) UNIQUE NOT NULL,
  postaladdress_id integer REFERENCES postaladdresses(postaladdress_id), 
  visitor_address_id integer REFERENCES postaladdresses(postaladdress_id),
  branch_office_phone1 varchar(255),
  branch_office_email1 varchar(255)
);
/*
INSERT INTO branch_offices VALUES (
  DEFAULT, 
  '438b0e41-0433-4083-8afa-e6fab0172a22',
  'branch office name',
  '3',
  '3',
  '+49 123 4574747',
  'branch@office.com'
);
*/
