---
title: Sportyweb - ER diagram of early database design
language: yaml
license:
Copyright (C) 2022 Stefan Strecker
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
---

# ER diagram 

Note that data types are NOT properly modeled due to Mermaid.js limitations, see 
https://mermaid-js.github.io/mermaid/#/entityRelationshipDiagram


```mermaid
erDiagram

          mitglied ||--|{ mitglied-haushalt : "gehört zu"
          haushalt ||--|{ mitglied-haushalt : "besteht aus"
          mitglied ||--|{ mitgliedsvertrag : "ist Vertragspartner"
          mitgliedsvertrag ||--|| verein : "ist Vertragspartner"
          verein ||--|{ geschaeftsstelle : "betreibt"

          mitglied {
            string nachname
            string vorname
            date geburtsdatum
            geschlecht_kuerzel geschlecht
            string telefonnummer1
            string telefonnummer2
            string email
            string kontoinhaber
            string iban
            date eintrittsdatum 
          }

          haushalt {
            string haushalt_name
            string haushalt_strasse
            string haushalt_hausnummer
            string haushalt_adresszusatz
            string haushalt_plz
            string haushalt_ort
          }

          mitgliedsvertrag {
            date vertragsbeginn
            date vertragsende
          }

          verein {
            string landessportbund-vereinsnummer
            string vereinsname_vollstaendig
            string vereinsname_kurzfassung
            string verein_url
          }

          geschaeftsstelle {
            string geschaeftsstelle_bezeichner
            string geschaeftsstelle_adresse "vorerst nur Dummy-Modellierung"
            string geschaeftsstelle_telefonnummer1
            string geschaeftsstelle_telefonnumer1_typ "mobil ODER festnetz ODER ..."
          }

%%
%% Vereinseinheit : ein Verein ist in Organisationseinheiten unterteilt
%% Bsp. Vereinseinheit : Abteilung, Unterabteilung, usw.
%%
          vereinseinheit {
            string vereinseinheit_bezeichner
          }

%%
%% Sportangebot : ein Sportangebot, dass der Verein anbietet
%%
%% ein Sportangebot muss von mindestens einer Organisationseinheit ausgerichtet werden
%% ein Sportangebot kann von mehreren Organisationseinheiten ausgerichtet werden
%% ein Sportangebot muss mindestens einer Sparte zugeordnet sein
%% ein Sportangebot kann mehreren Sparten zugeordnet sein 

          sportangebot {
            string sportangebot_bezeichner
          }

          
%%
%% Sparte : eine Vereinssparte, die einer Abteilung entsprechen kann, aber nicht muss 
%% Beispiele für Sparte: Breitensport, Fitnesssport, Reha-Sport, Fussball, Handball, ...
%%
          sparte {
            string sparte_bezeichner
          }
          
```

# Erläuterungen

- Mitglied
  - ein Mitglied ist eine natürliche Person (TODO: Entitätstyp PERSON modellieren)
  - eine Person ist erst durch Abschluss eines Mitgliedsvertrags ein Mitglied

- Haushalt
  - ein Haushalt wird über eine postalische Adresse identifiziert
  - da an einer postalischen Adresse mehrere Haushalte existieren können (Mehrfamilienhäuser),
    ist es erforderlich, einem Haushalt einen eindeutigen Namen (Bezeichner) zu vergeben
  - "Haushalt" ist ein "künstlich eingefügtes" Konzept, mit dem die Zusammenfassung
    von Mitgliedern zu Gruppen ermöglicht wird, z.B. um einen Rabatt auf Mitgliedsbeiträge 
    zu erhalten. Anders als ein starres Konzept wie etwa "Familie" ermöglicht es "Haushalt",
    moderne Formen des Zusammenlebens zu repräsentieren. 
  - Idee hinter dem Konzept "Haushalt" ist, dass jedes Mitglied einem Haushalt angehört, 
    auch wenn der Haushalt nur diese eine Person umfasst, um zeitlich nachgelagert, weitere
    Mitglieder einem Haushalt hinzufügen zu können.

- Mitglied-Haushalt
  - ein Mitglied muss mindestens einem Haushalt angehören
  - für ein Neumitglied wird ein Haushalt neu angelegt, sofern ein korrespondierender Haushalt
    noch nicht existiert. Andernfalls wird das Neumitglied einem bereits vorliegenden Haushalt
    hinzugefügt.  
  - 

- Sportangebot : ein Sportangebot, dass der Verein anbietet
  - ein Sportangebot muss von mindestens einer Organisationseinheit ausgerichtet werden
  - ein Sportangebot kann von mehreren Organisationseinheiten ausgerichtet werden
  - ein Sportangebot muss mindestens einer Sparte zugeordnet sein
  - ein Sportangebot kann mehreren Sparten zugeordnet sein 