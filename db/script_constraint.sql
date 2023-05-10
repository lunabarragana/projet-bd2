use Logique;

alter table Personne
    add constraint Sexe_Personne
        check (
            Sexe in ('F', 'M') OR Sexe is null
            );

alter table Personne
    add constraint Existence_Attrib_Personne
        check (
                not Personnel or (
                    Sexe is not null
                    and Nom is not null
                    and Prenom is not null
                    and Adr_Rue is not null
                    and Adr_Localite is not null
                    and Adr_Pays is not null
                    and Adr_CP is not null
                    and Naissance is not null
                    and Mail is not null
                    and Telephone is not null)
            );

alter table Contrat
    add constraint chevauchement_dates
        check (
            Date_Debut < Date_Fin
            );

DELIMITER $$

/* Existence de personnel ou ambassadeur */

SET @trigger_enabled_existence_personnel = true;
SET @trigger_enabled_existence_ambassadeur = true;

CREATE PROCEDURE proc_existence_personnel(IN personnelId INT)
BEGIN
    IF @trigger_enabled_existence_personnel AND NOT EXISTS(SELECT * FROM Personnel P WHERE P.ID = personnelId) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
                'Une personne qui est um membre du personnel doit avoir une row Personnel';
    END IF;
END $$

CREATE PROCEDURE proc_existence_ambassadeur(IN ambassadeurId INT)
BEGIN
    IF @trigger_enabled_existence_ambassadeur AND
       NOT EXISTS(SELECT * FROM Ambassadeur A WHERE A.ID = ambassadeurId) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
                'Une personne qui est um ambassadeur doit avoir une row Ambassadeur';
    END IF;
END $$

CREATE PROCEDURE proc_existence_personne(IN PersonneId INT, IN personnel BOOL)
BEGIN
    IF (personnel IS NOT NULL) THEN
        CALL proc_existence_personnel(PersonneId);
    ELSE
        CALL proc_existence_ambassadeur(PersonneId);
    END IF;
END $$

CREATE TRIGGER trigger_personne_existence_insert
    BEFORE INSERT
    ON Personne
    FOR EACH ROW
BEGIN
    CALL proc_existence_personne(NEW.ID, NEW.Personnel);
END $$

CREATE TRIGGER trigger_personne_existence_update
    BEFORE INSERT
    ON Personne
    FOR EACH ROW
BEGIN
    CALL proc_existence_personne(NEW.ID, NEW.Personnel);
END $$

CREATE TRIGGER trigger_personnel_existence_delete
    AFTER DELETE
    ON Personnel
    FOR EACH ROW
BEGIN
    CALL proc_existence_personne(OLD.ID, true);
END $$

CREATE TRIGGER trigger_ambassadeur_existence_delete
    AFTER DELETE
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    CALL proc_existence_personne(OLD.ID, false);
END $$

/* CONTRAT */

CREATE PROCEDURE chevauchement_dates_contrats(in num_contrat integer, in id_signataire integer, in date_de_debut date,
                                              in date_de_fin date)
BEGIN
    IF exists(SELECT *
              from Contrat
              WHERE Sig_ID = id_signataire
                AND ID <> num_contrat
                AND ((date_de_debut >= Date_Debut AND date_de_debut < Date_Fin) OR
                     (date_de_fin < Date_Fin AND date_de_fin >= Date_Debut)))
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attention : les dates des contrats se chevauchent !';
    END IF;
END $$

CREATE TRIGGER update_contrat_chevauchement_date
    BEFORE update
    on Contrat
    FOR EACH ROW
BEGIN
    CALL chevauchement_dates_contrats(NEW.ID, NEW.Sig_ID, NEW.Date_Debut, NEW.Date_Fin);
END $$


CREATE TRIGGER insert_contrat_chevauchement_date
    BEFORE
        insert
    on Contrat
    FOR EACH ROW
BEGIN
    CALL chevauchement_dates_contrats(NEW.ID, NEW.Sig_ID, NEW.Date_Debut, NEW.Date_Fin);
END $$

/* EQU DETAIL TICKET */

SET @trigger_enabled_equ_detail_ticket = true;

CREATE PROCEDURE proc_equ_detail_ticket(IN Ticket_ID INT)
BEGIN
    IF @trigger_enabled_equ_detail_ticket AND NOT EXISTS(SELECT * FROM Detail WHERE Detail.Ticket_ID = Ticket_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un ticket doit obligatoirement avoir au moins un detail';
    END IF;
END $$

CREATE TRIGGER trigger_ticket_equ_insert
    BEFORE INSERT
    ON Ticket
    FOR EACH ROW
BEGIN
    CALL proc_equ_detail_ticket(NEW.ID);
END $$

CREATE TRIGGER trigger_ticket_equ_update
    BEFORE UPDATE
    ON Ticket
    FOR EACH ROW
BEGIN
    CALL proc_equ_detail_ticket(NEW.ID);
END $$

CREATE TRIGGER trigger_detail_equ_update
    AFTER UPDATE
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_equ_detail_ticket(OLD.Ticket_ID);
END $$

CREATE TRIGGER trigger_detail_equ_delete
    AFTER DELETE
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_equ_detail_ticket(OLD.Ticket_ID);
END $$

/* Prix du detail est celui du produit */
CREATE PROCEDURE proc_insert_detail_valid_prix(IN produit INT, IN prix DECIMAL(5, 2))
BEGIN
    IF NOT EXISTS(SELECT * FROM Produit P WHERE P.ID = produit AND P.Prix = prix) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le prix du détail doit être égal à celui de son produit';
    END IF;
END $$

CREATE TRIGGER trigger_detail_price_insert
    BEFORE INSERT
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_insert_detail_valid_prix(NEW.Produit_ID, NEW.Prix_Plein);
END $$

CREATE TRIGGER trigger_detail_price_update
    BEFORE UPDATE
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_insert_detail_valid_prix(NEW.Produit_ID, NEW.Prix_Plein);
END $$

/* EQU Produit_Promo Promo */

SET @trigger_enabled_equ_produit_promo_promo = true;

CREATE PROCEDURE proc_equ_produit_promo_promo(IN Promo_ID INT)
BEGIN
    IF @trigger_enabled_equ_produit_promo_promo AND
       NOT EXISTS(SELECT * FROM Produit_Promo PP WHERE PP.Promo_ID = Promo_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La promotion doit obligatoirement être liée à un produit';
    END IF;
END $$

CREATE TRIGGER trigger_promo_insert
    BEFORE INSERT
    ON Promo
    FOR EACH ROW
BEGIN
    CALL proc_equ_produit_promo_promo(NEW.ID);
END $$

CREATE TRIGGER trigger_promo_update
    BEFORE UPDATE
    ON Promo
    FOR EACH ROW
BEGIN
    CALL proc_equ_produit_promo_promo(NEW.ID);
END $$

CREATE TRIGGER trigger_produit_promo_update
    AFTER UPDATE
    ON Produit_Promo
    FOR EACH ROW
BEGIN
    CALL proc_equ_produit_promo_promo(OLD.Promo_ID);
END $$

CREATE TRIGGER trigger_produit_promo_delete
    AFTER DELETE
    ON Produit_Promo
    FOR EACH ROW
BEGIN
    CALL proc_equ_produit_promo_promo(OLD.Promo_ID);
END $$

/* LOOP Promo Palier Ambassadeur */

CREATE PROCEDURE proc_is_valid_loop_promo_palier_ambassadeur(IN ticketID INT, IN promoID INT)
BEGIN

    DECLARE ambID INT;
    DECLARE palierID INT;

    SELECT A.ID, A.Palier_ID
    INTO ambID, palierID
    FROM Ambassadeur A
             JOIN Ticket T on A.ID = T.Amb_ID
    WHERE T.ID = ticketID;

    IF promoID IS NOT NULL
        AND ambID IS NOT NULL
        AND EXISTS(SELECT * FROM Offre O WHERE O.Promo_ID = promoID)
        AND NOT EXISTS(SELECT * FROM Offre O WHERE palierID = O.Palier_ID AND promoID = O.Promo_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'ambassadeur n\'a pas accès à cette offre';
    END IF;

END $$

CREATE TRIGGER trigger_detail_insert_loop_promo_palier_ambassadeur
    BEFORE INSERT
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_is_valid_loop_promo_palier_ambassadeur(NEW.Ticket_ID, NEW.Promo_ID);
END $$

CREATE TRIGGER trigger_detail_update_loop_promo_palier_ambassadeur
    BEFORE UPDATE
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_is_valid_loop_promo_palier_ambassadeur(NEW.Ticket_ID, NEW.Promo_ID);
END $$

/* TRIGGER VERIFICATION QU'UN MENU NE PEUT PAS ETRE COMPOSE DE LUI MEME */
CREATE TRIGGER trigger_produit_not_composing_itself_insert
    BEFORE INSERT
    ON Compose
    FOR EACH ROW
BEGIN
    #VERIFICATION QUE MENU != PRODUIT
    IF (NEW.Menu_ID = NEW.Prod_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un produit ne peut entrer dans sa propre composition';
        #VERIFICATION QUE PRODUIT NE SE COMPOSE PAS LUI MEME A QUELQUE DEGRE QUE CE SOIT
    ELSEIF (fct_is_menu_self_composed(NEW.Menu_ID, NEW.Prod_ID)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un des sous produits est composé du menu';
    END IF;
END $$

CREATE TRIGGER trigger_produit_not_composing_itself_update
    AFTER UPDATE
    ON Compose
    FOR EACH ROW
BEGIN
    #VERIFICATION QUE MENU != PRODUIT
    IF (NEW.Menu_ID = NEW.Prod_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un produit ne peut entrer dans sa propre composition';
        #VERIFICATION QUE PRODUIT NE SE COMPOSE PAS LUI MEME A QUELQUE DEGRE QUE CE SOIT
    ELSEIF (fct_is_menu_self_composed(NEW.Menu_ID, NEW.Prod_ID)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un des sous produits est composé du menu';
    END IF;
END $$

/* FONCTION VERIFIANT PAR RECURENCE QU'UN PRODUIT N'ENTRE PAS DANS SA PROPRE COMPOSITION*/
CREATE FUNCTION fct_is_menu_self_composed(ID_M INT, ID_P INT) RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    DECLARE is_comp BOOLEAN;
    #VERIFICATION QUE LE MENU INSERE EXISTE DEJA COMME COMPOSANT D'UN AUTRE MENU
    IF EXISTS(SELECT * FROM Compose WHERE ID_M = Prod_ID)
    THEN
        #VERIFICATION QUE DANS LES MENU COMPOSE DE CE MENU INSERE,IL N'Y AI PAS LE PRODUIT INSERE
        #SINON IL SE COMPOSE LUI MÊME INDIRECTEMENT
        IF EXISTS(
                WITH RECURSIVE COMPOSITION(NIVEAU, COMPOSE, COMPOSANT)
                                   #INITIALISATION AVEC LES MENU COMPOSE DU MENU INSERE COMME PRODUIT
                                   AS (SELECT 1, Menu_ID, Prod_ID
                                       FROM Compose
                                       WHERE Prod_ID = ID_M
                                       UNION ALL
                                       #RECURENCE CONSTRUISANT LE CHEMIN MONTANT ENTRE LES MENU ET CE QU'ILS COMPOSENT
                                       SELECT CION.NIVEAU + 1, C.Menu_ID, C.Prod_ID
                                       FROM COMPOSITION CION,
                                            Compose C
                                       WHERE CION.COMPOSE = C.Prod_ID)
                               #SELECTION DES LIGNES OU LE PRODUIT INSERE EST COMPOSANT DE LUI MEME
                SELECT NIVEAU, COMPOSE, COMPOSANT
                FROM COMPOSITION
                WHERE ID_P = COMPOSE
            )
            #SI LE PRODUIT INSERE EST COMPOSANT DE LUI MEME CETTE VALLEUR EST VRAIE
        THEN
            SET is_comp = TRUE;

        ELSE
            #SINON FAUSSE
            SET is_comp = FALSE;
        END IF;
    ELSE
        #SI LE MENU INSERE N'EST COMPOSANT D'AUCUN MENU,ALORS LE PROD NE PEUT PAS ETRE AUTO-COMPOSE
        #ET DONC VALEUR MISE A FAUX
        SET is_comp = FALSE;
    END IF;
    RETURN is_comp;
END $$

/* EQU Palier Offre */

SET @trigger_enabled_equ_paliers_offre = true;

CREATE FUNCTION fct_offer_match_palier(PALIER_ID INT) RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    RETURN exists(select * from Offre where Offre.Palier_ID = PALIER_ID);
END $$

CREATE TRIGGER trigger_insert_palier
    BEFORE INSERT
    ON Paliers
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_paliers_offre AND NOT fct_offer_match_palier(NEW.ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Une offre doit être affectée au palier';
    END IF;
END $$

CREATE TRIGGER trigger_update_palier
    BEFORE UPDATE
    ON Paliers
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_paliers_offre AND NOT fct_offer_match_palier(New.ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Une offre doit être affectée au palier';
    END IF;
END $$

CREATE TRIGGER trigger_delete_offre
    AFTER DELETE
    ON Offre
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_paliers_offre AND NOT fct_offer_match_palier(Old.Palier_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Une offre doit être affectée à un palier';
    END IF;
END $$

CREATE TRIGGER trigger_update_offre
    AFTER UPDATE
    ON Offre
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_paliers_offre AND NOT fct_offer_match_palier(Old.Palier_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Une offre doit être affectée à un palier';
    END IF;
END $$

/* EQU Personnel Contrat */

SET @trigger_enabled_equ_personnel_contrat = true;

CREATE FUNCTION fct_personnel_has_contract(Personnel_ID INT) RETURNS BOOLEAN
    READS SQL DATA
BEGIN
    RETURN exists(select * from Contrat where Contrat.Sig_ID = Personnel_ID);
END $$

CREATE TRIGGER trigger_insert_personnel
    BEFORE INSERT
    ON Personnel
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_personnel_contrat AND NOT fct_personnel_has_contract(NEW.ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un Contrat doit être lié à un membre du personnel';
    END IF;
END $$

CREATE TRIGGER trigger_update_personnel
    BEFORE UPDATE
    ON Personnel
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_personnel_contrat AND NOT fct_personnel_has_contract(NEW.ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un Contrat doit être lié à un membre du personnel';
    END IF;
END $$

CREATE TRIGGER trigger_delete_contrat
    AFTER DELETE
    ON Contrat
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_personnel_contrat AND NOT fct_personnel_has_contract(old.Sig_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ce contrat est lié à quelqu un';
    END IF;
END $$

CREATE TRIGGER trigger_update_contrat
    AFTER UPDATE
    ON Contrat
    FOR EACH ROW
BEGIN
    IF @trigger_enabled_equ_personnel_contrat AND NOT fct_personnel_has_contract(old.Sig_ID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il faut 1 contrat par personne minimum !';
    END IF;
END $$

/* Selon le marketing d'un ambassadeur, vérifier que les informations de contact sont non nulles */

/*Trigger insert ambassadeur marketing courrier*/
CREATE PROCEDURE insert_update_marketing_courrier(in Marketing_Courrier boolean, in Ambassadeur_ID integer)
BEGIN
    IF Marketing_Courrier = True AND
       not exists(select * FROM Personne where ID = Ambassadeur_ID AND Adr_CP is not NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marketing is enabled but there is no address';
    END IF;
END $$

CREATE TRIGGER trigger_insert_ambassador_marketing_courrier
    BEFORE INSERT
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    call insert_update_marketing_courrier(NEW.Marketing_Courrier, NEW.ID);
END $$

/*Trigger update ambassadeur marketing courrier*/
CREATE TRIGGER trigger_update_ambassador_marketing_courrier
    BEFORE UPDATE
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    call insert_update_marketing_courrier(NEW.Marketing_Courrier, NEW.ID);
END $$

CREATE TRIGGER trigger_update_personne_marketing_courrier
    BEFORE UPDATE
    ON Personne
    FOR EACH ROW
BEGIN
    IF NEW.Adr_CP is NULL AND exists(select * FROM Ambassadeur where ID = NEW.ID AND Marketing_Courrier = True) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marketing is enabled but there is no address';
    END IF;
END $$

/*Procédure insert & update ambassadeur marketing mail*/
CREATE PROCEDURE insert_update_marketing_mail(in Marketing_Email boolean, in Ambassadeur_ID integer)
BEGIN
    IF Marketing_Email = True AND exists(select * FROM Personne where ID = Ambassadeur_ID AND Mail is NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marketing is enabled but there is no e-mail address';
    END IF;
END $$

/*Trigger insert ambassadeur marketing mail*/
CREATE TRIGGER trigger_insert_ambassador_marketing_mail
    BEFORE INSERT
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    call insert_update_marketing_mail(NEW.Marketing_Email, NEW.ID);
END $$

/*Trigger update ambassadeur marketing mail*/
CREATE TRIGGER trigger_update_ambassador_marketing_mail
    BEFORE UPDATE
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    call insert_update_marketing_mail(NEW.Marketing_Email, NEW.ID);
END $$

/*Trigger update personne marketing mail*/
CREATE TRIGGER trigger_update_personne_mail
    BEFORE UPDATE
    ON Personne
    FOR EACH ROW
BEGIN
    IF NEW.Mail is NULL AND exists(select * FROM Ambassadeur where ID = NEW.ID AND Marketing_Email = True) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marketing is enabled but there is no e-mail address';
    END IF;
END $$

/*Procédure insert & update ambassadeur marketing sms*/
CREATE PROCEDURE insert_update_marketing_sms(in Marketing_SMS boolean, in Ambassadeur_ID integer)
BEGIN
    IF Marketing_SMS = True AND exists(select * FROM Personne where ID = Ambassadeur_ID AND Telephone is NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marketing is enabled but there is no phone number';
    END IF;
END $$

/*Trigger insert ambassadeur marketing sms*/
CREATE TRIGGER trigger_insert_ambassador_marketing_sms
    BEFORE INSERT
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    call insert_update_marketing_sms(NEW.Marketing_SMS, NEW.ID);
END $$

/*Trigger update ambassadeur marketing sms*/
CREATE TRIGGER trigger_update_ambassador_marketing_sms
    BEFORE UPDATE
    ON Ambassadeur
    FOR EACH ROW
BEGIN
    call insert_update_marketing_sms(NEW.Marketing_SMS, NEW.ID);
END $$

/*Trigger update personne marketing sms*/
CREATE TRIGGER trigger_update_personne_marketing_sms
    BEFORE UPDATE
    ON Personne
    FOR EACH ROW
BEGIN
    IF NEW.Telephone is NULL AND exists(select * FROM Ambassadeur where ID = NEW.ID AND Marketing_SMS = True) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marketing is enabled but there is no phone number';
    END IF;
END $$

/* Loop Detail Promo Produit_Promo */
CREATE PROCEDURE proc_loop_detail_promo_produit(IN produitID INT, IN promoID INT)
BEGIN
    IF promoID IS NOT NULL AND NOT EXISTS (SELECT * FROM Produit_Promo WHERE Produit_ID = produitID AND Promo_ID = promoID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La promotion n\'est pas associée au produit';
    END IF;
END $$

CREATE TRIGGER trigger_detail_insert_loop_detail_promo_produit
    BEFORE INSERT
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_loop_detail_promo_produit(NEW.Produit_ID, NEW.Promo_ID);
END $$

CREATE TRIGGER trigger_detail_update_loop_detail_promo_produit
    AFTER UPDATE
    ON Detail
    FOR EACH ROW
BEGIN
    CALL proc_loop_detail_promo_produit(NEW.Produit_ID, NEW.Promo_ID);
END $$

DELIMITER ;