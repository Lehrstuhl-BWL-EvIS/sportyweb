---
title: Sportyweb - Conceptual data model (ER diagram) of Sportyweb data management
language: yaml
license:
Copyright (C) 2022­–2023 Stefan Strecker, stefan.strecker@fernuni-hagen.de
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
	Mitglied ||--o{ Sportteilnahme : nimmt_teil
	Sportartangebot ||--o{ Sportteilnahme : bezieht_sich_auf
```

