-- *********************************************
-- * SQL MySQL generation                      
-- *--------------------------------------------
-- * DB-MAIN version: 11.0.2              
-- * Generator date: Sep 14 2021              
-- * Generation date: Fri Apr  8 14:59:41 2022 
-- * LUN file: ..\analyse\Schemas.lun 
-- * Schema: Logique/1 
-- ********************************************* 


-- Database Section
-- ________________ 

create database Logique;
use Logique;


-- Tables Section
-- _____________ 

create table Ambassadeur (
     ID int not null,
     Numero int not null auto_increment,
     Marketing_Courrier char not null,
     Marketing_Email char not null,
     Marketing_SMS char not null,
     Palier_ID int not null,
     constraint SID_Ambassadeur_Numero_ID unique (Numero),
     constraint FK_Personne_Ambassadeur_ID primary key (ID));

create table Badge (
     ID int not null auto_increment,
     constraint ID_Badge_ID primary key (ID));

create table Clef (
     ID int not null auto_increment,
     Libelle varchar(255) not null,
     constraint ID_Clef_ID primary key (ID));

create table Compose (
     Menu_ID int not null,
     Prod_ID int not null,
     Quantite int not null,
     constraint ID_Compose_ID primary key (Menu_ID, Prod_ID));

create table Contrat (
     ID int not null auto_increment,
     Date_Debut date not null,
     Date_Fin date not null,
     Sig_ID int not null,
     Resto_ID int not null,
     constraint ID_Contrat_ID primary key (ID));

create table Detail (
     ID int not null auto_increment,
     Prix_Plein decimal(5,2) not null,
     Produit_ID int not null,
     Ticket_ID int not null,
     Promo_ID int,
     constraint ID_Detail_ID primary key (ID));

create table Offre (
     Palier_ID int not null,
     Promo_ID int not null,
     constraint ID_Offre_ID primary key (Promo_ID, Palier_ID));

create table Paliers (
     ID int not null auto_increment,
     Libelle varchar(255) not null,
     Points_requis int not null,
     constraint ID_Paliers_ID primary key (ID));

create table Personne (
     ID int not null auto_increment,
     Sexe char(1),
     Nom varchar(255),
     Prenom varchar(255),
     Adr_Rue varchar(255),
     Adr_Localite char(255),
     Adr_CP varchar(255),
     Adr_Pays char(2),
     Naissance date,
     Mail char(255),
     Telephone varchar(255),
     Personnel char,
     Ambassadeur char,
     constraint ID_Personne_ID primary key (ID));

create table Personnel (
     ID int not null,
     NISS int not null,
     Prop_Clef int,
     Prop_Badge int,
     constraint SID_Personnel_NISS_ID unique (NISS),
     constraint FK_Personnel_Clef_ID unique (Prop_Clef),
     constraint FK_Personnel_Badge_ID unique (Prop_Badge),
     constraint FK_Personne_Personnel_ID primary key (ID));

create table Produit (
     ID int not null auto_increment,
     Libelle char(255) not null,
     Prix decimal(5,2) not null,
     constraint ID_Produit_ID primary key (ID));

create table Produit_Promo (
     Produit_ID int not null,
     Promo_ID int not null,
     constraint ID_Produit_Promo_ID primary key (Promo_ID, Produit_ID));

create table Promo (
     ID int not null auto_increment,
     Libelle varchar(255) not null,
     Reduction_fixe decimal(5,2),
     Pourcentage decimal(3,2),
     constraint ID_Promo_ID primary key (ID));

create table Restaurant (
     ID int not null auto_increment,
     Adr_Rue varchar(255) not null,
     Adr_Localite varchar(255) not null,
     Adr_CP varchar(255) not null,
     Adr_Pays varchar(255) not null,
     constraint ID_Restaurant_ID primary key (ID));

create table Ticket (
     ID int not null auto_increment,
     Date date not null,
     Resto_ID int not null,
     Amb_ID int,
     constraint ID_Ticket_ID primary key (ID));


-- Constraints Section
-- ___________________ 

alter table Ambassadeur add constraint FK_Personne_Ambassadeur_FK
     foreign key (ID)
     references Personne (ID);

alter table Ambassadeur add constraint FK_Ambassadeur_Palier_FK
     foreign key (Palier_ID)
     references Paliers (ID);

alter table Compose add constraint FK_Compose_Sous_produit_FK
     foreign key (Prod_ID)
     references Produit (ID);

alter table Compose add constraint FK_Compose_Menu_FK
     foreign key (Menu_ID)
     references Produit (ID)
     on delete cascade;

alter table Contrat add constraint FK_Contrat_Signataire_FK
     foreign key (Sig_ID)
     references Personnel (ID);

alter table Contrat add constraint FK_Contrat_Resto_FK
     foreign key (Resto_ID)
     references Restaurant (ID);

alter table Detail add constraint FK_Detail_Produit_FK
     foreign key (Produit_ID)
     references Produit (ID);

alter table Detail add constraint FK_Detail_Ticket_FK
     foreign key (Ticket_ID)
     references Ticket (ID)
     on delete cascade;

alter table Detail add constraint FK_Detail_Promo_FK
     foreign key (Promo_ID)
     references Promo (ID);

alter table Offre add constraint FK_Offre_Promo_FK
     foreign key (Promo_ID)
     references Promo (ID)
     on delete cascade;

alter table Offre add constraint FK_Offre_Palier_FK
     foreign key (Palier_ID)
     references Paliers (ID)
     on delete cascade;

-- Not implemented
-- alter table Paliers add constraint ID_Paliers_CHK
--     check(exists(select * from Offre
--                  where Offre.Palier_ID = ID)); 

alter table Personne add constraint COEX_Personne_Nom_Prenom
     check((Nom is not null and Prenom is not null)
           or (Nom is null and Prenom is null));

alter table Personne add constraint EXTONE_Personne_Ambassadeur_Personnel
     check((Ambassadeur is not null and Personnel is null)
           or (Ambassadeur is null and Personnel is not null));

alter table Personne add constraint COEX_Personne_Adresse
     check((Adr_Rue is not null and Adr_Localite is not null and Adr_CP is not null and Adr_Pays is not null)
           or (Adr_Rue is null and Adr_Localite is null and Adr_CP is null and Adr_Pays is null));

alter table Personnel add constraint EXTONE_Personnel_Clef_Badge
     check((Prop_Badge is not null and Prop_Clef is null)
           or (Prop_Badge is null and Prop_Clef is not null));

alter table Personnel add constraint FK_Personnel_Clef_FK
     foreign key (Prop_Clef)
     references Clef (ID);

alter table Personnel add constraint FK_Personnel_Badge_FK
     foreign key (Prop_Badge)
     references Badge (ID);

-- Not implemented
-- alter table Personnel add constraint FK_Personne_Personnel_CHK
--     check(exists(select * from Contrat
--                  where Contrat.Sig_ID = ID)); 

alter table Personnel add constraint FK_Personne_Personnel_FK
     foreign key (ID)
     references Personne (ID);

alter table Produit_Promo add constraint FK_Produit_Promo_Produit_FK
     foreign key (Produit_ID)
     references Produit (ID)
     on delete cascade;

alter table Produit_Promo add constraint FK_Produit_Promo_Promo_FK
     foreign key (Promo_ID)
     references Promo (ID);

alter table Promo add constraint EXTONE_Promo_Fixe_Pourcentage
     check((Reduction_fixe is not null and Pourcentage is null)
           or (Reduction_fixe is null and Pourcentage is not null));

-- Not implemented
-- alter table Promo add constraint ID_Promo_CHK
--     check(exists(select * from Produit_Promo
--                  where Produit_Promo.Promo_ID = ID)); 

-- Not implemented
-- alter table Ticket add constraint ID_Ticket_CHK
--     check(exists(select * from Detail
--                  where Detail.Ticket_ID = ID)); 

alter table Ticket add constraint FK_Ticket_Resto_FK
     foreign key (Resto_ID)
     references Restaurant (ID);

alter table Ticket add constraint FK_Ticket_Ambassadeur_FK
     foreign key (Amb_ID)
     references Ambassadeur (ID);


-- Index Section
-- _____________ 

create unique index SID_Ambassadeur_Numero_IND
     on Ambassadeur (Numero);

create unique index FK_Personne_Ambassadeur_IND
     on Ambassadeur (ID);

create index FK_Ambassadeur_Palier_IND
     on Ambassadeur (Palier_ID);

create unique index ID_Badge_IND
     on Badge (ID);

create unique index ID_Clef_IND
     on Clef (ID);

create unique index ID_Compose_IND
     on Compose (Menu_ID, Prod_ID);

create index FK_Compose_Sous_produit_IND
     on Compose (Prod_ID);

create index FK_Compose_Menu_IND
     on Compose (Menu_ID);

create unique index ID_Contrat_IND
     on Contrat (ID);

create index FK_Contrat_Signataire_IND
     on Contrat (Sig_ID);

create index FK_Contrat_Resto_IND
     on Contrat (Resto_ID);

create unique index ID_Detail_IND
     on Detail (ID);

create index FK_Detail_Produit_IND
     on Detail (Produit_ID);

create index FK_Detail_Ticket_IND
     on Detail (Ticket_ID);

create index FK_Detail_Promo_IND
     on Detail (Promo_ID);

create unique index ID_Offre_IND
     on Offre (Promo_ID, Palier_ID);

create index FK_Offre_Promo_IND
     on Offre (Promo_ID);

create index FK_Offre_Palier_IND
     on Offre (Palier_ID);

create unique index ID_Paliers_IND
     on Paliers (ID);

create unique index ID_Personne_IND
     on Personne (ID);

create unique index SID_Personnel_NISS_IND
     on Personnel (NISS);

create unique index FK_Personnel_Clef_IND
     on Personnel (Prop_Clef);

create unique index FK_Personnel_Badge_IND
     on Personnel (Prop_Badge);

create unique index FK_Personne_Personnel_IND
     on Personnel (ID);

create unique index ID_Produit_IND
     on Produit (ID);

create unique index ID_Produit_Promo_IND
     on Produit_Promo (Promo_ID, Produit_ID);

create index FK_Produit_Promo_Produit_IND
     on Produit_Promo (Produit_ID);

create index FK_Produit_Promo_Promo_IND
     on Produit_Promo (Promo_ID);

create unique index ID_Promo_IND
     on Promo (ID);

create unique index ID_Restaurant_IND
     on Restaurant (ID);

create unique index ID_Ticket_IND
     on Ticket (ID);

create index FK_Ticket_Resto_IND
     on Ticket (Resto_ID);

create index FK_Ticket_Ambassadeur_IND
     on Ticket (Amb_ID);

