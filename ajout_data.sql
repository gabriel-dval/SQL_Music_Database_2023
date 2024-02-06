--  Code pour ajouter des données à la base

-- Utilisateurs
\COPY Utilisateurs FROM 'Tableaux_CSV/Utilisateurs.csv' DELIMITER ',';

-- Individus
\COPY Individus_Associations FROM 'Tableaux_CSV/Individus_Associations.csv' DELIMITER ',';

--  Groupes
\COPY Groupes FROM 'Tableaux_CSV/Groupes.csv' DELIMITER ',';

--  Administrateurs
\COPY Administrateurs FROM 'Tableaux_CSV/Administrateurs.csv' DELIMITER ',';

-- Amitie
\COPY Amitie FROM 'Tableaux_CSV/Amitie.csv' DELIMITER ',';

-- Lieu
\COPY Lieu FROM 'Tableaux_CSV/Lieu.csv' DELIMITER ',';

-- Concert
\COPY Concert FROM 'Tableaux_CSV/Concert.csv' DELIMITER ',';

-- Concert Futur
\COPY Concert_Futur FROM 'Tableaux_CSV/Concert_Futur.csv' DELIMITER ',';

-- Concert Passés
\COPY Concert_Passe FROM 'Tableaux_CSV/Concert_Passe.csv' DELIMITER ',';

-- Relation Interet_Concert
\COPY Interet_Concert FROM 'Tableaux_CSV/Interet_Concert.csv' DELIMITER ',';

-- Playlist 
\COPY Playlists FROM 'Tableaux_CSV/Playlists.csv' DELIMITER ',';

-- Morceaux
\COPY Morceaux FROM 'Tableaux_CSV/Morceaux.csv' DELIMITER ',';

-- Composition Playlist
\COPY Composition_Playlist FROM 'Tableaux_CSV/Composition_Playlist.csv' DELIMITER ',';

-- Avis
\COPY Avis FROM 'Tableaux_CSV/Avis.csv' DELIMITER ',';

-- Avis_Concert
\COPY Avis_Concert FROM 'Tableaux_CSV/Avis_Concert.csv' DELIMITER ',';

-- Avis_Lieu
\COPY Avis_Lieu FROM 'Tableaux_CSV/Avis_Lieu.csv' DELIMITER ',';

-- Avis_Morceau
\COPY Avis_Morceau FROM 'Tableaux_CSV/Avis_Morceau.csv' DELIMITER ',';

-- Tags
\COPY Tags FROM 'Tableaux_CSV/Tags.csv' DELIMITER ',';

-- Tags_Avis
\COPY Tags_Avis FROM 'Tableaux_CSV/Tags_Avis.csv' DELIMITER ',';

-- Tags_Concert
\COPY Tags_Concert FROM 'Tableaux_CSV/Tags_Concert.csv' DELIMITER ',';

-- Tags_Playlist
\COPY Tags_Playlist FROM 'Tableaux_CSV/Tags_Playlist.csv' DELIMITER ',';


-- -- Commande pour insérer des lignes seules:
-- -- INSERT INTO Table VALUES (...);



