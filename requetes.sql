-- Script pour écrire et tester les requêtes SQL que notre base doit implémenter

-- Quels individus/associations aiment le rock 
SELECT nom 
FROM individus_associations 
WHERE (genres_importants like '%Rock%');

-- Tout les utilisateurs et leurs amitiés
SELECT U1.id AS User1, U2.id AS User2, Amitie.accepte
FROM Utilisateurs U1
FULL OUTER JOIN Amitie ON U1.id = Amitie.id_envoyeur
FULL OUTER JOIN Utilisateurs U2 ON Amitie.id_destinateur = U2.id;

-- Tout les avis sur les concerts, avec l'email de l'utilisateur qui le poste, l'organisateur et la note
SELECT Concert.organisateur, Avis.note_sur_10, Utilisateurs.email
FROM Concert
JOIN Avis_Concert ON Concert.id_concert = Avis_Concert.id_concert
JOIN Avis ON Avis_Concert.id_avis = Avis.id_avis
JOIN Utilisateurs ON Avis.id_auteur = Utilisateurs.id;

-- Trouver utilisateurs qui sont amis et leurs genres importants
SELECT U1.email AS user_email, U2.email AS friend_email, I1.genres_importants AS user_interests, 
I2.genres_importants AS friend_interests
FROM Amitie A
JOIN Utilisateurs U1 ON A.id_envoyeur = U1.id
JOIN Utilisateurs U2 ON A.id_destinateur = U2.id
JOIN Individus_Associations I1 ON U1.id = I1.id
JOIN Individus_Associations I2 ON U2.id = I2.id
WHERE A.accepte = true AND A.reciproque = true;

-- Trouver les utilisateurs qui ont envoyé le plus de friend requests 
SELECT U.email, (
    SELECT COUNT(*)
    FROM Amitie A
    WHERE A.id_envoyeur = U.id OR A.id_destinateur = U.id
) AS friend_count
FROM Utilisateurs U
ORDER BY friend_count DESC
LIMIT 10;

-- Trouver le nombre moyen de playlists créées par chaque utilisateur
SELECT AVG(subquery.playlist_size) AS avg_playlist_size
FROM (
    SELECT P.id_createur, COUNT(*) AS playlist_size
    FROM Playlists P
    GROUP BY P.id_createur
) AS subquery; 

-- Trouver des concerts de genres populaires
SELECT *
FROM Concert
WHERE groupe_primaire IN (
    SELECT genre
    FROM Morceaux
    GROUP BY genre
    ORDER BY COUNT(*) DESC
    LIMIT 3
); -- Ne retourne rien car groupe_primaire ne sont pas les mêmes que dans morceaux; il aurait fallu mettre un attribut
-- genre dans la table de concert.

-- Trouver des genres avec des bonnes notes
SELECT Morceaux.genre, AVG(Avis.note_sur_10) AS average_rating
FROM Morceaux
JOIN Avis_Morceau ON Morceaux.id_morceaux = Avis_Morceau.id_morceau
JOIN Avis ON Avis_Morceau.id_avis = Avis.id_avis
GROUP BY Morceaux.genre
HAVING AVG(Avis.note_sur_10) > 6;

-- Utilisateurs intéressés par TOUT les concerts

SELECT U.id, U.email
FROM Utilisateurs AS U
WHERE NOT EXISTS (
    SELECT C.id_concert
    FROM Concert AS C
    WHERE NOT EXISTS (
        SELECT IC.id_utilisateur
        FROM Interet_Concert AS IC
        WHERE IC.id_utilisateur = U.id AND IC.id_concert = C.id_concert
    )
); -- Avec sous-requêtes

SELECT U.id, U.email
FROM Utilisateurs AS U
LEFT JOIN Interet_Concert AS IC ON U.id = IC.id_utilisateur
LEFT JOIN Concert AS C ON IC.id_concert = C.id_concert
GROUP BY U.id, U.email
HAVING COUNT(DISTINCT C.id_concert) = (SELECT COUNT(*) FROM Concert); -- Avec agrégats et left join

-- Trouver le nombre de playlists et le nombre de chansons pour tout les utilisateurs
SELECT
  ia.id,
  ia.nom,
  COUNT(p.id_playlist) AS playlist_count,
  SUM(p.nb_morceaux) AS total_songs
FROM Individus_Associations ia
LEFT JOIN Playlists p ON ia.id = p.id_createur
GROUP BY ia.id, ia.nom
ORDER BY ia.id; -- Deux fonctions d'aggrégation COUNT et SUM.


-- Trouver les lieux de tout les concerts
SELECT
    c.id_concert,
    c.organisateur,
    l.nom AS nom_lieu
FROM
    Concert c
JOIN
    Lieu l ON c.id_lieu = l.id_lieu
WHERE
    c.organisateur IS NOT NULL
    AND l.nom IS NOT NULL;   -- Si le lieu ou l'organisateur est NULL, le concert n'apparait pas


SELECT
    c.id_concert,
    c.organisateur,
    l.nom AS lieu_nom
FROM
    Concert c,
    Lieu l
WHERE
    c.id_lieu = l.id_lieu -- Tout les concerts apparaissent, même si le lieu est NULL.
-- Si il n'y avait pas de valeurs NULL, ces requêtes renverraient la même chose.

-- Requête récursive
-- Arbre récursif qui retrouve les amis en partant d'un utilisateur et concerts qui les intéressent
WITH RECURSIVE FriendTree AS (
  SELECT id_destinateur AS friend_id, 0 AS level
  FROM Amitie
  WHERE id_envoyeur = 1 AND accepte = true
  UNION ALL
  SELECT A.id_destinateur, F.level + 1
  FROM Amitie A
  JOIN FriendTree F ON A.id_envoyeur = F.friend_id AND A.accepte = true
)
SELECT F.friend_id, U.email AS friend_email, IC.id_concert
FROM FriendTree F
JOIN Utilisateurs U ON F.friend_id = U.id
LEFT JOIN Interet_Concert IC ON F.friend_id = IC.id_utilisateur
ORDER BY F.level, F.friend_id, IC.id_concert;

-- Trouver les 3 playlists avec le plus de chansons
SELECT
  id_playlist,
  COUNT(id_son) AS song_count,
  RANK() OVER (ORDER BY COUNT(id_son) DESC) AS playlist_rank
FROM Composition_Playlist
GROUP BY id_playlist
ORDER BY song_count DESC
LIMIT 3;

-- Plus de requêtes - Pour un utilisateur donné, sort les concerts à venir qui intéressent l'utilisateur.
SELECT
  c.id_concert,
  c.organisateur,
  c.groupe_primaire,
  c.groupe_secondaire,
  cf.jour_prevu,
  cf.debut_prevu
FROM Concert c
JOIN Concert_Futur cf ON c.id_concert = cf.id_concert
JOIN Interet_Concert ic ON c.id_concert = ic.id_concert
JOIN Utilisateurs u ON ic.id_utilisateur = u.id
WHERE u.id = 1
  AND ic.interet = true
ORDER BY cf.jour_prevu DESC;

-- Liste des concerts passés avec le nombre de personnes
SELECT
  cp.id_concert,
  c.organisateur,
  cp.nb_personnes
FROM Concert_Passe cp
JOIN Concert c ON cp.id_concert = c.id_concert
LEFT JOIN Interet_Concert ic ON cp.id_concert = ic.id_concert
WHERE cp.jour < CURRENT_DATE
GROUP BY cp.id_concert, c.organisateur
ORDER BY cp.id_concert;

-- Trouver les tags associés à un concert donné
SELECT
  c.id_concert,
  c.organisateur,
  tc.nom AS tag_name
FROM Concert c
JOIN Tags_Concert tc ON c.id_concert = tc.id_concert
WHERE c.id_concert = 2;

-- Trouver les avis avec des mots particuliers (util pour sécurité, contrôle des commentaires etc)
SELECT
  Avis.id_avis,
  Avis.id_auteur,
  Avis.note_sur_10,
  Avis.commentaire
FROM Avis
WHERE Avis.commentaire ILIKE '%Good%' OR Avis.commentaire ILIKE '%Excellent%';

-- Selectionner le Tag le plus utilisé à travers tout les avis, concert et playlists.
WITH AllTags AS (
  SELECT nom AS tag_name FROM Tags_Concert
  UNION ALL
  SELECT nom FROM Tags_Playlist
  UNION ALL
  SELECT nom FROM Tags_Avis
)
SELECT
  tag_name,
  COUNT(*) AS tag_count
FROM
  AllTags
GROUP BY
  tag_name
ORDER BY
  tag_count DESC
LIMIT 1;

-- Exécuter des requetes prédefinies

-- Quels individus/associations aiment un genre prédefinie
PREPARE recherche_genre(VARCHAR) as
SELECT nom 
FROM individus_associations 
WHERE (genres_importants like $1);

-- Trouver les avis avec des mots particuliers (util pour sécurité, contrôle des commentaires etc)
PREPARE recherche_avis(VARCHAR) as
SELECT
  Avis.id_avis,
  Avis.id_auteur,
  Avis.note_sur_10,
  Avis.commentaire
FROM Avis
WHERE Avis.commentaire ILIKE $1;

-- Arbre récursif
PREPARE arbre_recursif(integer) as
WITH RECURSIVE FriendTree AS (
  SELECT id_destinateur AS friend_id, 0 AS level
  FROM Amitie
  WHERE id_envoyeur = $1 AND accepte = true
  UNION ALL
  SELECT A.id_destinateur, F.level + 1
  FROM Amitie A
  JOIN FriendTree F ON A.id_envoyeur = F.friend_id AND A.accepte = true
)
SELECT F.friend_id, U.email AS friend_email, IC.id_concert
FROM FriendTree F
JOIN Utilisateurs U ON F.friend_id = U.id
LEFT JOIN Interet_Concert IC ON F.friend_id = IC.id_utilisateur
ORDER BY F.level, F.friend_id, IC.id_concert;