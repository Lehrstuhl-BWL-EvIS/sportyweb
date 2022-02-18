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

