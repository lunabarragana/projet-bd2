use Logique;

/* PRODUITS */
INSERT INTO Produit (ID, Libelle, Prix)
VALUES (1, 'Guacamol', 1),
       (2, 'Poulet', 2),
       (3, 'Boeuf', 3.5),
       (4, 'Porc', 2.5),
       (5, 'Fallafels de légumes', 2.5),
       (6, 'Menu porc', 9.5),
       (7, 'Menu boeuf', 10.5),
       (8, 'Menu poulet', 9),
       (9, 'Menu vege', 9),
       (10, 'Duvel', 3.5),
       (11, 'Jupiler', 2.5),
       (12, 'Coca 50cl', 2.5),
       (13, 'Eau 50cl', 2.5),
       (14, 'Boisson c1', 2.5),
       (15, 'Boisson c2', 3.5),
       (16, 'Base', 5)
;

/* COMPOSE */
INSERT INTO Compose (Menu_ID, Prod_ID, Quantite)
VALUES (6, 16, 1), #Base menu porc
       (6, 4, 1),  #Porc menu porc
       (6, 14, 1), #Boisson c1 menu porc
       (7, 16, 1), #Base menu boeuf
       (8, 16, 1), #Base menu poulet
       (9, 16, 1) #Base menu Vege
;

/* PROMO */
CALL insert_into_promo('Réduction Guacamol', NULL, 0.5, 1);
CALL insert_into_promo('Boisson 25%', NULL, 0.25, 14);
CALL insert_into_promo('Réduction viande', 1, NULL, 2);
CALL insert_into_promo('Boisson offerte', NULL, 1, 14);
CALL insert_into_promo('Etudiant', 1, NULL, 6);

/* PRODUIT PROMO */
INSERT INTO Produit_Promo(Produit_ID, Promo_ID)
VALUES (7, 5),
       (8, 5),
       (9, 5), #redu étudiant sur les menus
       (3, 3),
       (4, 3),
       (5, 3),
       (6, 3),
       (7, 3),
       (8, 3),
       (9, 3), #redu -1€ viande palier 3 sur menu et viande
       (15, 2),
       (15, 4) #100% sur boisson c1 et c2 pour palier 4
;

/* PALIERS */
CALL insert_into_palier('Bronze', 20, 1);
CALL insert_into_palier('Argent', 80, 2);
CALL insert_into_palier('Or', 150, 3);
CALL insert_into_palier('Platine', 230, 4);

/* RESTAURANTS */
INSERT INTO Restaurant(ID, Adr_Rue, Adr_Localite, Adr_CP, Adr_Pays)
VALUES (1, 'Rue Basse Marcelle 15', 'Namur', '5000', 'BE'),
       (2, '52 rue du sablon', 'LLN', '1348', 'BE');

/* CLEFS */
INSERT INTO Clef(ID, Libelle)
VALUES (1, 'Namur'),
       (2, 'LLN'),
       (3, 'Namur'),
       (4, 'LLN')
;

/* BADGES */
INSERT INTO Badge(ID)
VALUES (1),
       (2),
       (3),
       (4)
;
select * from Ambassadeur;
/* PERSONNEL */
CALL insert_into_personnel('F', 'Legrand', 'Geraldine', 'Rue du Clairon', 'Bovesse', '8000', 'BE', '1998-11-24',
                           'GL@gmail.be', '0487555555', 90080, NULL, 1, '2022-10-18', '2023-10-18', 1);
CALL insert_into_personnel('M', 'Martin', 'Martin', 'Rue du Sanglier', 'Marche', '1000', 'BE', '1980-10-07',
                           '@gmail.be', '0487555555', 87121, 1, NULL, '2020-01-02', '2023-01-02', 2);

/* AMBASSADEUR */
CALL insert_into_ambassadeur('F', 'Marchand', 'Salomée', 'Rue de Bruxelles', 'Namur', '5000', 'BE', '1998-11-24',
                             'Msa@outlook.be', '0487555555', 1, true, false, false, 2);
CALL insert_into_ambassadeur('M', 'Martin', 'Eustache', 'Av. de Gembloux', 'Jambes', '5100', 'BE', '1998-11-24',
                             'Chichou@gmail.com', '0487555555', 2, false, true, true, 3);
CALL insert_into_ambassadeur('F', 'Detry', 'Alice', 'Rue d\'Allemagne', 'Bruxelles', '8000', 'BE', '1998-11-24',
                             'xX-killer_Xx@gmail.be', '0487555555', 3, true, false, true, 4);
CALL insert_into_ambassadeur('F', 'Fineas', 'Miko', 'Rue du Sénéchal', 'Florifoux', '8000', 'BE', '1998-11-24',
                             'Biloute@msn.be', '0487555555', 4, false, false, true, 1);
CALL insert_into_ambassadeur('M', 'Martin', 'Martin', 'Rue du Sanglier', 'Marche', '1000', 'BE', '1980-10-07',
                             '@gmail.be', '0487555555', 5, false, false, false, 1);

/* CONTRAT */
INSERT INTO Contrat (Date_Debut, Date_Fin, Sig_ID, Resto_ID)
VALUES ('2023-01-03', '2024-01-03', 2, 1);

/* TICKETS */
CALL insert_into_ticket('2020-10-23', 1, 6, 1, 1);
CALL insert_into_ticket('2020-10-25', 2, 3, 8, 5);
CALL insert_into_ticket('2020-11-23', 2, 4, 6, 3);
CALL insert_into_ticket('2021-10-23', 2, 5, 9, NULL);
CALL insert_into_ticket('2021-10-23', 1, 6, 7, 5);
CALL insert_into_ticket('2021-03-03', 1, NULL, 8, 5);
CALL insert_into_ticket('2021-03-03', 2, NULL, 8, 5);
CALL insert_into_ticket('2021-04-05', 1, 6, 16, NULL);
;
/* DETAIL */
INSERT INTO Detail(Prix_Plein, Produit_ID, Ticket_ID, Promo_ID)
VALUES (9, 8, 1, NULL),    #T1 Menu Poulet
       (2.5, 14, 2, 2),    #T2 BoiC1 redu 25% P2
       (3.5, 15, 3, NULL), #T3 BoiC2
       (3.5, 15, 4, 4),    #T4 BoiC2 -80% P4
       (9, 8, 7, 5),      #T7 Menu Vege Redu Etu
       (3.5, 3, 8, NULL) #T8 Boeuf
;