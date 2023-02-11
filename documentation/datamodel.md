---
title: Sportyweb - Conceptual data model (ER diagram) of Sportyweb data management
language: yaml
license:
Copyright (C) 2022­–2023 Sportyweb Team 
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
	Club ||--o{ Department : organizes
	Department ||--o{ Group : organizes
	Club ||--o{ Category : _tbd_
	Category ||--o{ GroupCategory : _tbd_
	Group ||--o{ GroupCategory : _tbd_
```


```mermaid
erDiagram
	Mitglied ||--|| Verein : ist_Mitglied_in
	Mitglied ||--|{ Vereinseinheit : ist_Mitglied_in
    Vereinseinheit ||--o{ Vereinseinheit : ist_Untereinheit_von
    Mitglied ||--o{ Sportteilnahme : nimmt_teil
	Sportartangebot ||--o{ Sportteilnahme : bezieht_sich_auf
	Sportteilnahme {
		money zusatzgebuehr
	}
	Vereinseinheit ||--|{ Sportartangebot : richtet_aus
```
<!-- 

```mermaid
classDiagram
	Mitglied "1..1" -- "0..*" Sportteilnahme : nimmt_teil
	Sportartangebot "1..1" -- "0..*" Sportteilnahme : bezieht_sich_auf
``` -->
