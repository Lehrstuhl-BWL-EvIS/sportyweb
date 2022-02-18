---
title: Sportyweb - ER diagram of early database design
language: yaml
license:
Copyright (C) 22022 Stefan Strecker
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
          MEMBER ||--|{ MEMBER-HOUSEHOLD : "belongs to"
          HOUSEHOLD ||--|{ MEMBER-HOUSEHOLD : "consists of"
          MEMBER {
            string last_name
            string first_name
            date date_of_birth
            string gender
            string phone1
            string phone2
            string email
            string account_holder
            string iban
            date entry_date 
          }

          HOUSEHOLD {
            text household_name
            text household_street
            text household_number
            text household_postalcode
            text household_city
          }
````
