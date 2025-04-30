/*
-- =========================================================================== A
Produit : CoFELI.Exemple.Universite
Variante : 2023.iter04
Artefact : Universite_IMM_base.sql
Responsable : Luc.LAVOIE@USherbrooke.ca
Version : 0.4.0.b (2021-03-21)
Statut : travail en cours
Encodage : UTF-8, sans BOM; fin de ligne simple (LF)
Plateformes : PostgreSQL 12+
-- =========================================================================== A
*/

/*
-- =========================================================================== B

=== Itération 04

Définir l’interface machine-machine (IMM) de la base de données Universite, interface
correspondant aux fonctionnalités de base recherchées suivantes :

  * Déterminer si un étudiant remplit les conditions préalables à un cours.
  * Déterminer si l’offre effective d’un trimestre est en accord avec l’offre planifiée.

  * Ajouter, retirer, modifier : un professeur, un étudiant, un cours, une offre un groupe.
  * Ajouter, retirer : une compétence, une disponibilité ou une affectation à un professeur.
  * Ajouter, retirer : une inscription d’un étudiant à un groupe.
  * Ajouter, retirer : un préalable à un cours.
  * Attribuer, modifier : la note d’un étudiant en regard d’une inscription à un groupe.

L’IMM est aussi appelée souvent appelée interface programmatique ou, en anglais,
application programming interface (API).

-- =========================================================================== B
*/

--
--  Ouvrir la portée de l’interface précédemment créée.
--
set search_path to 'IMM', 'MDD' ;

--
--  Déterminer si l’offre effective est en accord avec l’offre planifiée.
--

create or replace function Offre_plan_non_couverte ()
  returns table
    (
      sigle Sigle,
      trimestre Trimestre
    )
begin atomic
  select sigle, trimestre from Offre
  except
  select distinct sigle, trimestre from Affectation ;
end ;
comment on function Offre_plan_non_couverte () is
  'Détermine les cours de l’offre (planifiée) non couverts par l’affection (offre effective).'
;

create or replace function Offre_eff_conforme () returns boolean

return
  (select not exists(select * from Offre_plan_non_couverte())) ;

comment on function Offre_eff_conforme () is
  'Détermine si l’affection (offre effective) est conforme à l’offre (planifiée).'
;

--
--  Déterminer si un étudiant remplit les conditions préalables à un cours.
--
--  TODO 2021-03-19 (LL01) : Déterminer si un étudiant remplit les conditions préalables à un cours.

--
--  Ajouter, retirer, modifier : un professeur, un étudiant, un cours, une offre, un groupe.
--

--  Professeur
--  TODO 2021-03-19 (LL01) : Ajouter, retirer, modifier un professeur

--  Étudiant
--  TODO 2021-03-19 (LL01) : Ajouter, retirer, modifier un étudiant

--  Cours
--  TODO 2021-03-19 (LL01) : Ajouter, retirer, modifier un cours

--  Offre
--  TODO 2021-03-19 (LL01) : Ajouter, retirer, modifier une offre

--  Groupe
--  TODO 2021-03-19 (LL01) : Ajouter, retirer, modifier un groupe


--
--  Ajouter, retirer : une compétence, une disponibilité ou une affectation à un professeur.
--
--  TODO 2021-03-19 (LL01) : Ajouter, retirer : une compétence, une disponibilité ou une affectation à un professeur.

--
--  Ajouter, retirer : une inscription d’un étudiant à un groupe.
--
--  TODO 2021-03-19 (LL01) : Ajouter, retirer : une inscription d’un étudiant à un groupe.

--
--  Ajouter, retirer : un préalable à un cours.
--
--  TODO 2021-03-19 (LL01) : Ajouter, retirer : un préalable à un cours.

--
--  Attribuer, modifier : une note à un étudiant en regard d’une inscription à un groupe.
--
--  TODO 2021-03-19 (LL01) : Attribuer, modifier : une note à un étudiant en regard d’une inscription à un groupe.


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
  TODO 2021-03-19 (LL01) : Mettre en oeuvre l’IMM.

=== Tâches réalisées
  2021-03-19 (LL01) : Inventaire des composantes de l'IMM de base
    - Inventaire découlant de l’ébauche proposée à l’étape 03.

=== Références
[ddv] http://info.usherbrooke.ca/llavoie/enseignement/Exemples/Universite/
      Universite_DDV.pdf
[std] http://info.usherbrooke.ca/llavoie/enseignement/Modules/
      BD190-STD-SQL-01_NDC.pdf

-- =========================================================================== Z
*/
