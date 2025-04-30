/*
-- =========================================================================== A
Produit : CoFELI.Exemple.Universite
Variante : 2023.iter04
Artefact : Universite_ini.sql
Responsable : Luc.LAVOIE@USherbrooke.ca
Version : 0.1.0a (2024-04-16)
Statut : travail en cours
Encodage : UTF-8, sans BOM; fin de ligne simple (LF)
Plateformes : PostgreSQL 12+
-- =========================================================================== A
*/

/*
-- =========================================================================== B

=== But

Illustrer la construction d’un schéma relationnel simple selon les règles de l’art.

=== Problème

Modéliser les types réputés utiles à la gestion des inscriptions étudiantes universitaires.

== Conception

Voir

  * Universite_DDV.adoc
  * Universite_DDB.adoc
  * Universite_MDD.adoc

=== Itération 04

Factoriser les définitions de types.
Répartir les définitions en deux schémas : le modèle (MDD) et l’interface (IMM).

=== Notes de mise en oeuvre

Il n’est pas possible de reproduire la structure de découpage de notre modélisation
« abstraite» (fichiers *.dlus.txt). En effet, la définition de l’IMM ne peut être
commodément divisée en deux (définition et mise en oeuvre) en SQL [1]. En conséquence,
puisque la partie mise en oeuvre doit faire référence aux tables du MDD, le script
complet de l’interface dépend du MDD et celui du MDD des types.
Pour cette raison, les définitions de types (et les éventuelles fonctions qui
leur sont associées) sont regroupées dans un autre fichier. La séquence de
compilation qui en découle est donc :

  000_Universite_ini.sql
  010_Universite_MDD_types.sql
  020_Universite_MDD_tables.sql
  030_Universite_IMM_base.sql

La définition des schémas est séparée pour des raisons dialectales (elle varie
très considérablement d’un dialecte à un autre). La définition des types est
séparée de celle des tables pour des raisons qui relève de règles de pratique
(couramment admises, mais discutables).

[1] Il serait possible de le faire en utilisant la commande « create or replace »
    (non standard, ni disponible dans tous les dialectes) au prix d'une redondance
    importante.

-- =========================================================================== B
*/

--
--  Définir le schéma principal de la base de données Universite (MDD).
--  Les autorisations d’accès sont faites par ailleurs
--  (voir fichier Universite_MDD_base.acc.sql dans une version subséquente).
--
drop schema if exists  "MDD" cascade ;
create schema "MDD" ;

--
--  Définir l’interface machine-machine IMM_base pour la base de données Universite
--  Les autorisations d’accès seront faites par ailleurs
--  (voir fichier Universite_IMM_base.acc.sql dans une version subséquente).
--
drop schema if exists  "IMM_base" cascade ;
create schema "IMM_base" ;

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
  2021-03-19 (LL01) : Première factorisation.

=== Références
[ddv] http://info.usherbrooke.ca/llavoie/enseignement/Exemples/Universite/
      Universite_DDV.pdf
[std] http://info.usherbrooke.ca/llavoie/enseignement/Modules/
      BD190-STD-SQL-01_NDC.pdf

-- =========================================================================== Z
*/
