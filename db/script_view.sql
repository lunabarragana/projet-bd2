use Logique;

CREATE VIEW AmbassadeurPersonne AS
SELECT A.ID AS 'ID',
       Sexe,
       Nom,
       Prenom,
       Adr_Rue,
       Adr_Localite,
       Adr_CP,
       Adr_Pays,
       Naissance,
       Mail,
       Telephone,
       Numero,
       Marketing_Courrier,
       Marketing_Email,
       Marketing_SMS,
       Palier_ID
FROM Ambassadeur A
         JOIN Personne P on A.ID = P.ID;

CREATE VIEW Detail_Prix_Reel AS
SELECT D.ID                                                                  AS 'Detail_ID',
       P.ID                                                                  AS 'Produit_ID',
       P.Libelle                                                             AS 'Produit_Libelle',
       D.Ticket_ID,
       P.Prix * COALESCE(P2.Pourcentage, 1) - COALESCE(P2.Reduction_fixe, 0) AS 'Prix_Reel',
       D.Prix_Plein,
       P2.Reduction_fixe,
       P2.Pourcentage
FROM Detail D
         JOIN Produit P on P.ID = D.Produit_ID
         LEFT JOIN Promo P2 on D.Promo_ID = P2.ID;

# Par ambassadeur, montrer le montant moyen dépensé par mois depuis son inscription/depuis 1 mois
CREATE VIEW Ambassadeur_Depense_mensuelle_moyenne AS
SELECT A.ID,
       A.Numero,
       YEAR(T.Date)      AS 'Annee',
       MONTH(T.Date)     AS 'Mois',
       AVG(D.Prix_Reel)  AS 'Prix_Reel',
       AVG(D.Prix_Plein) AS 'Prix_Plein'
FROM Ambassadeur A
         JOIN Ticket T on A.ID = T.Amb_ID
         JOIN Detail_Prix_Reel D on T.ID = D.Ticket_ID
GROUP BY A.ID, A.Numero, YEAR(T.Date), MONTH(T.Date);

/*COUT DES REDUCTIONS TRIEES PAR ANNEES,RESTAURANT ET REDUCTION*/
CREATE VIEW Cout_Promo_Annee AS
SELECT year(T.Date)             AS Annee,
       T.Resto_ID,
       D.Produit_ID,
       P.Libelle                AS Poduit_libelle,
       (Prix_Plein - Prix_Reel) AS COUT_TOT
FROM Detail_Prix_Reel D
         JOIN Ticket T on D.Ticket_ID = T.ID
         JOIN Produit P on P.ID = D.Produit_ID
WHERE Reduction_fixe is not null
   or Pourcentage is not null
GROUP BY year(T.Date), T.Resto_ID, D.Produit_ID, P.Libelle, (Prix_Plein - Prix_Reel)
;

/* CONSOMMATION DES PRODUITS PAR ANNEE ET PAR RESTAURANT */
CREATE VIEW Consommation_Annuelle_Produit
AS
SELECT YEAR(T.Date)   AS Annee,
       R.Adr_Localite AS Localite,
       PR.Libelle     AS Produit,
       count(D.ID)    AS QTT
FROM Detail D
         JOIN Ticket T on T.ID = D.Ticket_ID
         JOIN Restaurant R on T.Resto_ID = R.ID
         JOIN Produit PR on D.Produit_ID = PR.ID
GROUP BY YEAR(T.Date), R.Adr_Localite, PR.Libelle, D.ID
;

CREATE VIEW Chiffre_Affaire_Mensuel AS
SELECT YEAR(T.Date)                                                                            AS 'Annee',
       MONTH(T.Date)                                                                           AS 'Mois',
       SUM(D.Prix_Reel)                                                                        AS 'Chiffre_Affaire',
       SUM(D.Prix_Reel) - LAG(SUM(D.Prix_Reel), 1) OVER (ORDER BY YEAR(T.Date), MONTH(T.Date)) AS 'Difference'
FROM Detail_Prix_Reel D
         JOIN Ticket T ON D.Ticket_ID = T.ID
GROUP BY YEAR(T.Date), MONTH(T.Date)
ORDER BY YEAR(T.Date), MONTH(T.Date)
;

CREATE VIEW Chiffre_Affaire_Annuel AS
SELECT YEAR(T.Date)                                                             AS 'Annee',
       SUM(D.Prix_Reel)                                                         AS 'Chiffre_Affaire',
       SUM(D.Prix_Reel) - LAG(SUM(D.Prix_Reel), 1) OVER (ORDER BY YEAR(T.Date)) AS 'Difference'
FROM Detail_Prix_Reel D
         JOIN Ticket T ON D.Ticket_ID = T.ID
GROUP BY YEAR(T.Date)
ORDER BY YEAR(T.Date)
;