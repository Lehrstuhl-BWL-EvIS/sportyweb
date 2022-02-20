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
          mitglied ||--|{ mitgliedsvertrag : "schließt ab"
          mitgliedsvertrag ||--|| verein : "ist Vertragspartner"
          verein ||--|{ geschaeftsstelle : "gehört zu"

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



```
