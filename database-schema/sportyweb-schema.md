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
          verein ||--|| mitgliedsvertrag : "ist Vertragspartner"
          verein ||--|{ geschaeftsstelle : "betreibt"
          verein ||--|{ vereinseinheit : "ist organisiert in"
          vereinseinheit ||--o{ : vereinseinheit : "ist Untereinheit von"

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
  - ein Mitglied ist eine natürliche Person (ToDo: Entitätstyp PERSON modellieren)
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
    auch wenn der Haushalt nur diese eine Person umfasst, um zeitlich nachgelagert weitere
    Mitglieder einem Haushalt hinzufügen zu können.

- Mitglied-Haushalt
  - ein Mitglied muss mindestens einem Haushalt angehören
  - ein Haushalt muss mindestens ein Mitglied umfassen
  - ein Mitglied kann mehreren Haushalten angehören (auch wenn dies auf den ersten Blick
    ungewöhnlich ist, so ermöglicht dies, moderne Formen menschlichen Zusammenlebens wie
    Erwachsene, die in zwei Haushalten im Wechsel leben, zu repräsentieren) 
  - für ein Neumitglied wird ein Haushalt neu angelegt, sofern ein korrespondierender Haushalt
    noch nicht existiert; andernfalls wird das Neumitglied einem bereits vorliegenden Haushalt
    hinzugefügt.

- Mitgliedsvertrag : ein aktuell gültiger Mitgliedsvertrag ist Grundlage der Vereinsteilnahme
  - ein Mitgliedsvertrag hat formal zwei Vertragspartner : Verein und Mitglied (Person)
  - ein Mitglied muss mindestens einen Mitgliedsvertrag abgeschlossen haben
  - ein Mitglied kann im Laufe der Zeit mehrere Mitgliedsverträge abschließen, wenn
    das Mitglied einen früher laufenden Mitgliedsvertrag beendet hat und nach einiger Zeit
    wieder einen Mitgliedsvertrag abschließt
  - ein Mitglied kann temporär einen Mitgliedsvertrag aussetzen (diverse Gründen)
  - diverse weitere Aspekte eines Mitgliedsvertrags sind hier _noch nicht_ modelliert

- Verein : Metadaten über den repräsentierten Verein
  - Metadaten über einen Verein sind (auch) dem deutschen Vereinsrecht zu entnehmen
  -  


- Sportangebot : ein Sportangebot, dass der Verein anbietet
  - ein Sportangebot muss von mindestens einer Organisationseinheit ausgerichtet werden
  - ein Sportangebot kann von mehreren Organisationseinheiten ausgerichtet werden
  - ein Sportangebot muss mindestens einer Sparte zugeordnet sein
  - ein Sportangebot kann mehreren Sparten zugeordnet sein 