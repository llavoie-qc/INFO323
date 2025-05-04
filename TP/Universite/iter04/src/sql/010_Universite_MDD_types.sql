/*
-- =========================================================================== A
Produit : CoFELI.Exemple.Universite
Variante : 2023.iter04
Artefact : Universite_MDD_types.sql
Responsable : Luc.LAVOIE@USherbrooke.ca
Version : 0.4.0c (2024-04-16)
Statut : travail en cours
Encodage : UTF-8, sans BOM; fin de ligne simple (LF)
Plateformes : PostgreSQL 12+
-- =========================================================================== A
*/

--
--  Définir la portée.
--
set schema 'MDD' ; -- alternativement en PostgreSQL : set search_path to 'MDD' ;

--
-- Définir les types
--
create domain Bureau
  Text
  check (value similar to '[A-Z][0-9]{1,2}-[0-9]{4}(-[0-9]{2})?') ;
create domain Cause
  Text ;
create domain CDC
  SmallInt
  check (value between 1 and 90) ;
create domain MatriculeE
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain MatriculeP
  Text
  check (value similar to '[a-z]{4}[0-9]{4}') ;
create domain NoGroupe
  Text
  check (value similar to '[0-9]{2}') ;
create domain Nom
  Text
  check (length(value) <= 120 and value similar to '[[:alpha:]]+([-’ [:alpha:]])*[[:alpha:]]+') ;
create domain Note
  SmallInt
  check (value between 1 and 90) ;
create domain Sigle
  Text check (value similar to '[A-Z]{3}[0-9]{3}') ;
create domain Titre
  Text ;
create domain Trimestre
  Text
  check (value similar to '[0-9]{4}-[1-3]') ;

/*
-- =========================================================================== Z

=== Contributeurs
  (CK01) Christina.KHNAISSER@USherbrooke.ca,
  (LL01) Luc.LAVOIE@USherbrooke.ca

=== Adresse, droits d’auteur et copyright
  Groupe Μῆτις (Métis)
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

=== Tâches projetées
  S. O.

=== Tâches réalisées
  2024-04-16 (LL01) : Correction de la contrainte du type Nom.
  2021-03-19 (LL01) : Première factorisation.

=== Références
[ddv] http://info.usherbrooke.ca/llavoie/enseignement/Exemples/Universite/
      Universite_DDV.pdf
[std] http://info.usherbrooke.ca/llavoie/enseignement/Modules/
      BD190-STD-SQL-01_NDC.pdf

-- =========================================================================== Z
*/
