/*  Copyright (C) 2021-2022 Stefan Strecker
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

/* --------------------------------------------- Testdaten für mitglieder */
INSERT INTO mitglied VALUES 
(DEFAULT, 'Mustermann', 'Max', '1970-01-01', 'm', 
'0211-23456767', NULL, 'max@mustermann.de', 
'Kontoinhaber', 'IBAN', 
'aktiv');

INSERT INTO mitglied VALUES 
(DEFAULT, 'Mustermann', 'Anne', '1972-10-23', 'w', 
'0211-23456767', NULL, 'anne@mustermann.de', 
'Kontoinhaber', 'IBAN', 
'aktiv');


/* --------------------------------------------- Testdaten für mitglieder_haushalte */
INSERT INTO haushalt VALUES 
  (DEFAULT, 
  'Mustermann', 'Musterstr.', '1d', '44444', 'Musterhausen' 
  );



INSERT INTO mitglied_haushalt VALUES 
( 
  (
    SELECT mitgliedsnummer FROM mitglied WHERE nachname = 'Mustermann' AND vorname = 'Max'
  ),  
  (
    SELECT haushalt_id FROM haushalt WHERE haushalt_plz = '44444'
  ),  
  DEFAULT,
  true
);

INSERT INTO mitglied_haushalt VALUES 
( 
  (
    SELECT mitgliedsnummer FROM mitglied WHERE nachname = 'Mustermann' AND vorname = 'Anne'
  ),  
  (
    SELECT haushalt_id FROM haushalt WHERE haushalt_plz = '44444'
  ),  
  DEFAULT,
  true
);

