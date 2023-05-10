use Logique;

DELIMITER $$

/* 
    Suppression d'un ambassadeur.
    Anonymisation d'un ambassadeur en supprimant toutes ses données privées conformément au RGPD.
    Certaines données anonymes sont conservées.
    L'ambassadeur n'est donc pas réelement supprimé de la DB.
*/
CREATE PROCEDURE delete_ambassadeur(in num_ambassadeur integer)
BEGIN
    START TRANSACTION;
    UPDATE Ambassadeur
    SET Marketing_SMS      = false,
        Marketing_Email    = false,
        Marketing_Courrier = false
    WHERE num_ambassadeur = ID;
    UPDATE Personne
    SET Sexe         = NULL,
        Nom          = NULL,
        Prenom       = NULL,
        Adr_Localite = NULL,
        Adr_Rue      = NULL,
        Adr_CP       = NULL,
        Adr_Pays     = NULL,
        Naissance    = NULL,
        Mail         = NULL,
        Telephone    = NULL
    WHERE num_ambassadeur = ID;
    COMMIT;
END $$

/*
    Insertion d'un membre du personnel.
    Puisque deux tables doivent être modifiées, l'ensemble des opérations
    est faite dans une transaction.
*/
CREATE PROCEDURE insert_into_personnel(
    IN S char(1),
    in N varchar(255),
    in P varchar(255),
    in Rue varchar(255),
    in Localite char(255),
    in CP varchar(255),
    in Pays char(2),
    in Nais date,
    in Email char(255),
    in Tel varchar(255),
    in NI int,
    in Propr_Clef int,
    in Propr_Badge int,
    in Contrat_Debut Date,
    in Contrat_Fin Date,
    in Contrat_Resto int)
BEGIN
    DECLARE idPersonne INT;

    START TRANSACTION;

    SET @trigger_enabled_existence_personnel = false;
    INSERT INTO Personne (Sexe, Nom, Prenom, Adr_Rue, Adr_Localite, Adr_CP, Adr_Pays, Naissance, Mail, Telephone,
                          Personnel, Ambassadeur)
    VALUES (S, N, P, Rue, Localite, CP, Pays, Nais, Email, Tel, true, null);
    SET @trigger_enabled_equ_personnel_contrat = true;

    SET idPersonne = LAST_INSERT_ID();

    SET @trigger_enabled_equ_personnel_contrat = false;
    INSERT INTO Personnel
    VALUES (idPersonne, NI, Propr_Clef, Propr_Badge);
    SET @trigger_enabled_existence_personnel = true;

    INSERT INTO Contrat (Date_Debut, Date_Fin, Sig_ID, Resto_ID)
    VALUES (Contrat_Debut, Contrat_Fin, idPersonne, Contrat_Resto);
    COMMIT;
END $$

/*
    Insertion d'un ambassadeur.
    Puisque deux tables doivent être modifiées, l'ensemble des opérations
    est faite dans une transaction.
*/
CREATE PROCEDURE insert_into_ambassadeur(
    IN S char(1),
    in N varchar(255),
    in P varchar(255),
    in Rue varchar(255),
    in Localite char(255),
    in CP varchar(255),
    in Pays char(2),
    in Nais date,
    in Email char(255),
    in Tel varchar(255),
    in Num int,
    in Mark_courrier bool,
    in Mark_mail bool,
    in Mark_sms bool,
    in Pal_id int)
BEGIN
    START TRANSACTION;

    SET @trigger_enabled_existence_ambassadeur = false;
    INSERT INTO Personne (Sexe, Nom, Prenom, Adr_Rue, Adr_Localite, Adr_CP, Adr_Pays, Naissance, Mail, Telephone,
                          Personnel, Ambassadeur)
    VALUES (S, N, P, Rue, Localite, CP, Pays, Nais, Email, Tel, null, true);
    SET @trigger_enabled_existence_ambassadeur = true;

    INSERT INTO Ambassadeur (ID, Numero, Marketing_Courrier, Marketing_Email, Marketing_SMS, Palier_ID)
    VALUES (LAST_INSERT_ID(), Num, Mark_courrier, Mark_mail, Mark_sms, Pal_id);
    COMMIT;
END $$

CREATE PROCEDURE insert_into_promo(IN lib VARCHAR(255), IN reduction DECIMAL(5, 2), IN pourc DECIMAL(3, 2),
                                   IN produit INT)
BEGIN
    START TRANSACTION;

    SET @trigger_enabled_equ_produit_promo_promo = false;
    INSERT INTO Promo (Libelle, Reduction_fixe, Pourcentage) VALUES (lib, reduction, pourc);
    SET @trigger_enabled_equ_produit_promo_promo = true;

    INSERT INTO Produit_Promo (Produit_ID, Promo_ID) VALUES (produit, LAST_INSERT_ID());
    COMMIT;
END $$

CREATE PROCEDURE insert_into_palier(IN lib VARCHAR(255), IN points INT, IN promo INT)
BEGIN
    START TRANSACTION;

    SET @trigger_enabled_equ_paliers_offre = false;
    INSERT INTO Paliers (Libelle, Points_requis) VALUES (lib, points);
    SET @trigger_enabled_equ_paliers_offre = true;

    INSERT INTO Offre (Palier_ID, Promo_ID) VALUES (LAST_INSERT_ID(), promo);
    COMMIT;
END $$

CREATE PROCEDURE insert_into_detail(IN produit INT, IN ticket INT, IN promo INT)
BEGIN
    DECLARE prix DECIMAL(5, 2);
    SELECT P.Prix INTO prix FROM Produit P WHERE P.ID = produit;
    INSERT INTO Detail (Prix_Plein, Produit_ID, Ticket_ID, Promo_ID) VALUES (prix, produit, ticket, promo);
END $$

CREATE PROCEDURE insert_into_ticket(IN dateAchat DATE, IN resto INT, IN ambassadeur int, IN produit INT, IN promo INT)
BEGIN
    START TRANSACTION;

    SET @trigger_enabled_equ_detail_ticket = false;
    INSERT INTO Ticket (Date, Resto_ID, Amb_ID) VALUES (dateAchat, resto, ambassadeur);
    SET @trigger_enabled_equ_detail_ticket = true;

    CALL insert_into_detail(produit, LAST_INSERT_ID(), promo);
    COMMIT;
END $$

CREATE FUNCTION insert_into_ticket_return_id(dateAchat DATE, resto INT, ambassadeur int, produit INT,
                                             promo INT)
    RETURNS INT
BEGIN

    DECLARE ticketID INT;

    SET @trigger_enabled_equ_detail_ticket = false;
    INSERT INTO Ticket (Date, Resto_ID, Amb_ID) VALUES (dateAchat, resto, ambassadeur);
    SET @trigger_enabled_equ_detail_ticket = true;

    SET ticketID = LAST_INSERT_ID();

    CALL insert_into_detail(produit, ticketID, promo);

    RETURN ticketID;
END $$

DELIMITER ;