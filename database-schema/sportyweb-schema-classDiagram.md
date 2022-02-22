---
title: Sportyweb - UML Class Diagram of Sportyweb database design (as a workaround)
language: yaml
license:
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
---

# Database design as class diagram (for using multiplicity constraints) 

Note that data types are NOT properly modeled due to Mermaid.js limitations, see 
https://mermaid-js.github.io/mermaid/#/classDiagram

```mermaid
classDiagram
    class Haushalt
    class Mitglied
    class Mitglied-Haushalt
    Haushalt "1" --> "1..*" Mitglied-Haushalt
    Mitglied "1" --> "1..*" Mitglied-Haushalt
```
