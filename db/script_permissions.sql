USE Logique;

/* Create roles */

CREATE ROLE 'role_compta';
GRANT SELECT ON TABLE Ambassadeur_Depense_mensuelle_moyenne TO 'role_compta';
GRANT SELECT ON TABLE Cout_Promo_Annee TO 'role_compta';
GRANT SELECT ON TABLE Consommation_Annuelle_Produit TO 'role_compta';
GRANT SELECT ON TABLE Chiffre_Affaire_Mensuel TO 'role_compta';
GRANT SELECT ON TABLE Chiffre_Affaire_Annuel TO 'role_compta';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE Produit TO 'role_compta';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE Compose TO 'role_compta';

CREATE ROLE 'role_ouvrier';
GRANT SELECT, UPDATE ON TABLE AmbassadeurPersonne TO 'role_ouvrier';
GRANT EXECUTE ON PROCEDURE insert_into_ambassadeur TO 'role_ouvrier';
GRANT EXECUTE ON PROCEDURE delete_ambassadeur TO 'role_ouvrier';
GRANT EXECUTE ON FUNCTION insert_into_ticket_return_id TO 'role_ouvrier';
GRANT EXECUTE ON PROCEDURE insert_into_detail TO 'role_ouvrier';

CREATE ROLE 'role_marketing';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE Produit TO 'role_compta';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE Compose TO 'role_compta';
GRANT EXECUTE ON PROCEDURE insert_into_promo TO 'role_compta';
GRANT EXECUTE ON PROCEDURE insert_into_palier TO 'role_compta';
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Offre TO 'role_compta';
GRANT SELECT, UPDATE, DELETE ON TABLE Paliers TO 'role_compta';
GRANT SELECT, DELETE ON TABLE Promo TO 'role_compta';

CREATE ROLE 'role_grh';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE Clef TO 'role_grh';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE Badge TO 'role_grh';
GRANT EXECUTE ON PROCEDURE insert_into_personnel TO 'role_grh';
GRANT SELECT, UPDATE, INSERT ON TABLE Contrat TO 'role_grh';
GRANT SELECT, UPDATE ON TABLE Personnel TO 'role_grh';
GRANT SELECT, UPDATE ON TABLE Personne TO 'role_grh';

CREATE ROLE 'role_gerant';
GRANT SELECT, UPDATE, DELETE, INSERT ON TABLE * TO 'role_gerant';
GRANT EXECUTE ON * TO 'role_gerant';

/* Create users */

CREATE USER 'Gerant' IDENTIFIED BY 'gerantpass' DEFAULT ROLE 'role_gerant';
CREATE USER 'GRH' IDENTIFIED BY 'GRHpass' DEFAULT ROLE 'role_grh';
CREATE USER 'MKT' IDENTIFIED BY 'MKTpass' DEFAULT ROLE 'role_marketing';
CREATE USER 'WORKER' IDENTIFIED BY 'workerpass' DEFAULT ROLE 'role_ouvrier';
CREATE USER 'COMPTA' IDENTIFIED BY 'comptapass' DEFAULT ROLE 'role_compta';