---
title: Sportyweb - ER diagram of database design
example:
language: yaml

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

```mermaid
erDiagram
          MEMBER ||--|{ MEMBER-HOUSEHOLD : "belongs to"
          HOUSEHOLD ||--|{ MEMBER-HOUSEHOLD : "consists of"
          MEMBER {
            varchar(255) last_name
            varchar(255) first_name
            date date_of_birth
            char(1) gender
            text phone1
            text phone2
            varchar(319) email
            varchar(34) account_holder
            varchar(34) iban
            membershipstatus membership_status
            date entry_date 
          }
````
