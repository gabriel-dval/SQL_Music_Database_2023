-- Création des tables utilisateurs

CREATE TABLE IF NOT EXISTS Utilisateurs (
    id serial primary key,
    email varchar(50), 
    UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS Individus_Associations (
    id integer primary key references Utilisateurs(id),
    nom varchar(40) not NULL,
    prenom varchar(30) not NULL,
    ddn date not NULL,
    genres_importants varchar(50)  -- chaque utilisateur peut rentrer les genres qui les intérèssent; comprend les 
);                                 -- associations, salles de concert aussi (pas de restrictions sur les playlists)

CREATE TABLE IF NOT EXISTS Groupes (
    id integer primary key references Utilisateurs(id),
    nom_groupe varchar(30) not NULL,
    date_de_creation date,
    joue_genre varchar(30),
    nb_de_membres int
);  -- Comprend des groupes de musiques

CREATE TABLE IF NOT EXISTS Administrateurs (
    id integer primary key,
    admin_role varchar(30)
);


-- Associations entre utilisateurs

CREATE TABLE IF NOT EXISTS Amitie (
    id_envoyeur integer references Utilisateurs(id),
    id_destinateur integer references Utilisateurs(id),
    accepte boolean,
    reciproque boolean,
    PRIMARY KEY (id_envoyeur, id_destinateur),
    check (id_envoyeur != id_destinateur)
);  -- Amitié directionnelle - la relation entre deux personnes est conservée dans une seule colonne


-- Création des tables concerts + lieu

CREATE TABLE IF NOT EXISTS Lieu(
    id_lieu serial primary key,
    nom varchar(30),
    adresse varchar(50),
    enfants boolean,
    espace_exterieur integer
);

CREATE TABLE IF NOT EXISTS Concert(
    id_concert serial primary key,
    organisateur varchar(30),
    groupe_primaire varchar(30),
    groupe_secondaire varchar(30),
    besoin_volontaires boolean,
    cause varchar(30),
    id_lieu integer references lieu(id_lieu)
);

CREATE TABLE IF NOT EXISTS Concert_Passe(
    id_concert integer primary key references Concert(id_concert),
    jour date,
    heure_debut time not null,
    heure_fin time not null,
    nb_personnes integer,
    photos varchar(100),
    videos varchar(100),
    CHECK (jour < NOW())
);

CREATE TABLE IF NOT EXISTS Concert_Futur(
    id_concert integer primary key references Concert(id_concert),
    jour_prevu date,
    debut_prevu time not null,
    nb_places integer,
    prix_moyen integer,
    site_web varchar(100) DEFAULT 'Aucun',
    CHECK (jour_prevu > NOW())
);


-- Table de relation entre utilisateurs et concerts

CREATE TABLE IF NOT EXISTS Interet_Concert(
    id_utilisateur integer references Utilisateurs(id),
    id_concert integer references Concert(id_concert),
    interet boolean,
    participe boolean,
    organise boolean,
    primary key (id_utilisateur, id_concert),
    check (interet != participe)
);



-- Création des tables playlists et morceaux (les associations ne peuvent pas faire de playlists)

CREATE TABLE IF NOT EXISTS Playlists(
    id_playlist serial primary key,
    id_createur integer references Utilisateurs(id),
    nom varchar(50),
    creation date,
    nb_morceaux integer not null check (nb_morceaux < 21),
    description_playlist varchar(100),
    UNIQUE (id_createur, nom)
);

CREATE TABLE IF NOT EXISTS Morceaux(
    id_morceaux serial primary key,
    nom varchar(50) not NULL,
    duree varchar(11),
    artiste varchar(50),
    album varchar(50),
    genre varchar(30)
);

CREATE TABLE IF NOT EXISTS Composition_Playlist(
    id_playlist integer references Playlists(id_playlist),
    id_son integer references Morceaux(id_morceaux),
    primary key (id_playlist, id_son)
);  -- Chaque playlist ne peut pas contenir plusieurs fois la même chanson, ni être plus longue que 20


-- Création des tables Avis

-- Avis

CREATE TABLE IF NOT EXISTS Avis(
    id_avis serial primary key,
    id_auteur integer references utilisateurs(id),
    note_sur_10 integer check (note_sur_10 < 11),
    commentaire varchar(250)
);

-- Avis Concerts

CREATE TABLE IF NOT EXISTS Avis_Concert(
    id_avis integer references Avis(id_avis),
    id_concert integer references Concert(id_concert),
    date_postee date,
    heure_postee time,
    primary key (id_avis, id_concert)
);

-- Avis Lieux

CREATE TABLE IF NOT EXISTS Avis_Lieu(
    id_avis integer references Avis(id_avis),
    id_lieu integer references Lieu(id_lieu),
    date_postee date,
    heure_postee time,
    primary key (id_avis, id_lieu)
);

-- Avis Morceaux

CREATE TABLE IF NOT EXISTS Avis_Morceau(
    id_avis integer references Avis(id_avis),
    id_morceau integer references Morceaux(id_morceaux),
    date_postee date,
    heure_postee time,
    primary key (id_avis, id_morceau)
);

-- Création des tables Tags - ceux-ci sont ajoutés en fonction des commentaires postés par les utilisateurs

CREATE TABLE IF NOT EXISTS Tags(
    nom varchar(30) primary key,
    date_creation date,
    administrateur_responsable integer references Administrateurs(id)
);

CREATE TABLE IF NOT EXISTS Tags_Concert(
    nom varchar(30) references Tags(nom),
    id_concert integer references Concert(id_concert),
    primary key (nom, id_concert)
);

CREATE TABLE IF NOT EXISTS Tags_Playlist(
    nom varchar(30) references Tags(nom),
    id_playlist integer references Playlists(id_playlist),
    primary key (nom, id_playlist)
);

CREATE TABLE IF NOT EXISTS Tags_Avis(
    nom varchar(30) references Tags(nom),
    id_avis integer references Avis(id_avis),
    primary key (nom, id_avis)
);

-- 21 tables en tout

-- ALTER TABLE Individus
-- RENAME TO Individus_Associations;


