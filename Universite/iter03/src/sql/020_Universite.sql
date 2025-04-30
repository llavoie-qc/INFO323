/*
-- =========================================================================== A
Produit : CoFELI.Exemple.Universite/v2021
Composant : 020_Universite.sql
Responsable : Luc.LAVOIE@USherbrooke.ca
Version : 0.4.c (2021-03-12)
Statut : travail en cours
Encodage : UTF-8, sans BOM; fin de ligne simple (LF)
Plateformes : PostgreSQl v11+
-- =========================================================================== A
*/

/*
-- =========================================================================== B
== But

Illustrer la construction d’un schéma relationnel simple selon les règles de l’art.

== Problème

Modélisation des entités utiles à la gestion des inscriptions étudiantes universitaires.

== Conception

Voir
  * Universite_analyse.adoc
  * Universite_schema_rel_e03-types.txt

-- =========================================================================== B
*/

--
-- TYPES
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

--
-- RELATIONS
--
create table Etudiant
(
  matriculeE MatriculeE not null,
  nom Nom not null,
  ddn Date not null,
  --  df matriculeE -> nom
  --  df matriculeE -> ddn
  constraint Etudiant_cc0 primary key (matriculeE)
) ;
comment on table Etudiant is
  'La personne étudiante identifiée par le matricule "matriculeE" possède un dossier à l’Université. '
  'Son nom est "nom". '
  'Sa date de naissance est "ddn". '
;

create table Professeur
(
  matriculeP MatriculeP not null,
  nom Nom not null,
  --  df matriculeP -> nom
  constraint Professeur_cc0 primary key (matriculeP)
) ;
comment on table Professeur is
  'La personne enseignante identifiée par le matricule "matriculeP" possèdes un dossier à l’Université. '
  'Une personne enseignante est une professeure, un professeur, une chargée de cours ou un chargé de cours. '
  'Son nom est "nom". '
;

create table Professeur_Bureau_PRE
(
  matriculeP MatriculeP not null,
  bureau Bureau not null,
  --  df matriculeP -> bureau
  constraint Professeur_Bureau_PRE_cc0 primary key (matriculeP),
  constraint Professeur_Bureau_PRE_cr0 foreign key (matriculeP) references Professeur
);
comment on table Professeur_Bureau_PRE is
  'La personne enseignante identifiée par le matricule "matriculeP" a un bureau '
  'et ce bureau est le "bureau". '
;

create table Professeur_Bureau_ABS
(
  matriculeP MatriculeP not null,
  cause Cause not null,
  --  df matriculeP -> cause
  constraint Professeur_Bureau_ABS_cc0 primary key (matriculeP),
  constraint Professeur_Bureau_ABS_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Professeur_Bureau_ABS is
  'La personne enseignante identifiée par le matricule "matriculeP" n’a pas de bureau '
  'pour la raison "cause". '
;

/*
Cet invariant

  inv Professeur_Bureau_INV
    pred « Tout professeur a soit un bureau soit une raison (cause) pour laquelle il n’en a pas. »
    Professeur 𝞹 {matriculeP} =
      (Professeur_Bureau_ABS 𝞹 {matriculeP}) UnionD (Professeur_Bureau_PRE 𝞹 {matriculeP})

devrait pouvoir être traduit en SQL ISO comme suit, sachant que l’égalité entre
relations n’est pas définie en SQL (sic) :

  create assertion Professeur_Bureau_INV check
  (
  with
    PROF as (select matriculeP from Professeur),
    PRE as (select matriculeP from Professeur_Bureau_PRE),
    ABS as (select matriculeP from Professeur_Bureau_ABS)
  select
    not exists (select * from PRE natural join ABS)
    and
    (select count(*) from PROF) = (select count(*) from PRE) + (select count(*) from ABS)
  );
  comment on assertion Professeur_Bureau_INV is
    'Toute personne enseignante a soit un bureau soit une raison (cause) pour laquelle elle n’en a pas. '
  ;

En effet, grâce aux clés candidates de Professeur_Bureau_PRE et Professeur_Bureau_ABS,
les deux relations PRE et ABS sont des sous-ensembles de PROF, il suffit donc de
tester que PRE et ABS sont disjoints et que

  #PROF = #PRE + #ABS

où # est l'opérateur de cardinalité (select count(*) from... en SQL).

Malheureusement, PostgreSQL (pas plus qu'Oracle, DB2 ou MS-SQL) ne permet le
CREATE ASSERTION. Il faut donc définir l'automatisme et les déclencheurs comme
ci-après.

  create or replace function Professeur_Bureau_INV () returns boolean
    language sql as
  $$
  with
    PROF as (select matriculeP from Professeur),
    PRE as (select matriculeP from Professeur_Bureau_PRE),
    ABS as (select matriculeP from Professeur_Bureau_ABS)
  select
    not exists (select * from PRE natural join ABS)
    and
    (select count(*) from PROF) = (select count(*) from PRE) + (select count(*) from ABS)
  $$;
  comment on function Professeur_Bureau_INV () is
    'Toute personne enseignante a soit un bureau soit une raison (cause) pour laquelle elle n’en a pas. '
  ;

  create or replace function Professeur_Bureau_DECL()
    returns trigger
    language 'plpgsql'
  as
  $$
  begin
    if not Professeur_Bureau_INV() then
      raise exception
        'Professeur_Bureau_INV : '
        'Toute personne enseignante a soit un bureau soit une raison (cause) pour laquelle elle n’en a pas. ' ;
    end if;
    return new;
  end;
  $$;

  create constraint trigger Professeur_Bureau_PRE_AUTO
    after insert
       or delete
       or update of matriculeP
    on Professeur_Bureau_PRE
    from Professeur
    deferrable
    for each statement
    execute function Professeur_Bureau_DECL();

  create constraint trigger Professeur_bureau_ABS_AUTO
    after insert
       or delete
       or update of matriculeP
    on Professeur_Bureau_ABS
    from Professeur
    deferrable
    for each statement
    execute function Professeur_Bureau_DECL();

Malheureusement, ce n’est pas tout.
Il faut vraisemblablement suspendre les déclencheurs durant les transactions
traitant des lots de modifications afin de ne pas engendrer des cascades d’automatismes.
La vérification n’aura donc lieu qu’en fin de transaction avec les risques que cela comporte.
Le traitement des tuples sur une base individuelle (for each row) n’améliorerait
que marginalement cet état de fait. Pour terminer, dans certains cas, il ne
faudra pas être surpris que les automatismes soit évalués de multiples
fois inutilement, puisque la plupart des SGBD ne font par la compression des
déclenchements!

Superfétatoire le CREATE ASSERTION ? Vraiment ?

En fait, pour ce type de situation, il convient généralement mieux de fournir
un jeu complet (mais exclusif) de procédures spécialisées encapsulant
complètement la gestion des entités comportant des attributs dont la valeur
peut ne pas être connue. Par exemple, pour les entités Professeur :

  procedure Engager_prof (nom, bureau, cause -> matricule) ;
  procédure Modifier_nom_prof (matricule, nom) ;
  procedure Attribuer_bureau_prof (matricule, bureau) ;
  procedure Retirer_bureau_prof (matricule, cause) ;
  procedure Desengager_prof (matricule) ;

Finalement, des fonctions sont en général ajoutées selon le domaine d’application.
*/

create table Cours
(
  sigle Sigle not null,
  titre Titre not null,
  credit CDC not null,
  --  df sigle -> titre
  --  df sigle -> crédit
  constraint Cours_cc0 primary key (sigle)
) ;
comment on table Cours is
  'Le cours identifié par le sigle "sigle" est défini dans le répertoire des cours offerts par l’Université. '
  'Il a pour titre "titre". '
  'Il comporte "credit" crédit(s). '
;

create table Groupe
(
  sigle Sigle not null,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  constraint Groupe_cc0 primary key (sigle, trimestre, noGroupe),
  constraint Groupe_cr0 foreign key (sigle) references Cours
) ;
comment on table Groupe is
  'Le groupe identifié par le sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre" est constitué. '
;

create table Affectation
  -- Correspond à l’offre effective.
(
  sigle Sigle,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  matriculeP MatriculeP not null,
  -- Pour permettre à un groupe de professeur d’assurer la formation, il faudrait
  -- ajouter matriculeP à la clé candidate.
  constraint Affectation_cc0 primary key (sigle, trimestre, noGroupe),
  constraint Affectation_cr0 foreign key (sigle, trimestre, noGroupe) references Groupe,
  constraint Affectation_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Affectation is
  'La personne enseignante identifiée par "matriculeP" assure la formation du '
  'groupe identifié par les  sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre". '
;

create table Inscription
(
  matriculeE MatriculeE not null,
  sigle Sigle not null,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  constraint Inscription_cc0 primary key (matriculeE, sigle, trimestre, noGroupe),
  constraint Inscription_cr0 foreign key (sigle, trimestre, noGroupe) references Groupe
) ;
comment on table Inscription is
  'La personne étudiante identifiée par "matriculeE" est inscrite au '
  'groupe identifié par le sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre". '
;

create table Evaluation
(
  matriculeE MatriculeE not null,
  sigle Sigle not null,
  trimestre Trimestre not null,
  noGroupe NoGroupe not null,
  note Note not null,
  --  df sigle, trimestre, noGroupe, matriculeE -> note
  constraint Evaluation_cc0 primary key (matriculeE, sigle, trimestre, noGroupe),
  constraint Evaluation_cr0 foreign key (sigle, trimestre, noGroupe, matriculeE) references Inscription
) ;
comment on table Evaluation is
  'La personne étudiante identifiée par "matriculeE" inscrite au '
  'groupe identifié par sigle "sigle", le numéro "noGroupe" et le trimestre "trimestre" '
  'a obtenu la note "note". '
;

create table Prealable
(
  sigle Sigle not null,
  siglePrealable Sigle not null,
  constraint Prealable_cc0 primary key (sigle, siglePrealable),
  constraint Prealable_cr0 foreign key (sigle) references Cours,
  constraint Prealable_cr1 foreign key (siglePrealable) references Cours (sigle)
) ;
comment on table Prealable is
  'L’inscription au cours "sigle" n’est autorisée qu’aux personnes '
  'qui auront réussi le cours "siglePréalable" avant le début du cours "sigle". '
;

create table Offre
  -- Correspond à l’offre planifiée.
(
  sigle Sigle not null,
  trimestre Trimestre not null,
  constraint Offre_cc0 primary key (sigle, trimestre),
  constraint Offre_cr0 foreign key (sigle) references Cours
) ;
comment on table Offre is
  'l’Université s’engage à offrir le cours "sigle" au trimestre "trimestre". '
;

create table Competence
(
  sigle Sigle not null,
  matriculeP MatriculeP not null,
  constraint Competence_cc0 primary key (sigle, matriculeP),
  constraint Competence_cr0 foreign key (sigle) references Cours,
  constraint Competence_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Competence is
  'La personne enseignante identifiée par "matriculeP" a la compétence requise '
  'pour assure le cours identifié par le sigle "sigle". '
;

create table Disponibilite
(
  trimestre Trimestre,
  matriculeP MatriculeP,
  constraint Disponibilite_cc0 primary key (trimestre, matriculeP),
  constraint Disponibilite_cr0 foreign key (trimestre) references Cours,
  constraint Disponibilite_cr1 foreign key (matriculeP) references Professeur
) ;
comment on table Disponibilite is
  'La personne enseignante identifiée par "matriculeP" est disponible '
  'pour enseigner au cours du trimestre "trimestre". '
;

/*
inv Affectation_comp
  pred « Affectation est conforme à Compétence. »
  Affectation 𝞹 {sigle, matriculeP} ⊆ Compétence

TODO 2021-03-19 : À rendre plus efficient.
  La mise en oeuvre qui suit, bien qu’exacte, n’est généralement pas très performante
  faute d’optimisation adéquate du compilateur. L’élaboration d’une version plus
  performante est laissée en exercice.
*/
create or replace function Affectation_comp_DECL()
  returns trigger
  language 'plpgsql' as
$$
begin
  if
    exists (select sigle, matriculeP from Affectation except select sigle, matriculeP from Competence)
  then
    raise exception
      'Affectation_comp_DECL : '
      'Affectation non conforme à la compétence. ' ;
  end if;
  return new;
end;
$$;

create /* constraint */ trigger Affectation_comp_AUTO
  after insert
     or delete
     or update
  on Affectation
  for each statement
  execute function Affectation_comp_DECL();

create /* constraint */ trigger Competence_aff_AUTO
  after insert
     or delete
     or update
  on Competence
  for each statement
  execute function Affectation_comp_DECL();

/*
inv Affectation_disp
  pred « Affectation est conforme à Disponibilité. »
  Affectation 𝞹 {trimestre, matriculeP} ⊆ Disponibilité

À faire sur le modèle précédent.
*/

create or replace function Offre_plan_non_couverte ()
  returns table
    (
      sigle Sigle,
      trimestre Trimestre
    )
  language sql as
$$
  select sigle, trimestre from Offre
  except
  select distinct sigle, trimestre from Affectation
$$;
comment on function Offre_plan_non_couverte () is
  'Détermine les cours de l’offre (planifiée) non couverts par l’affection (offre effective).'
;

create or replace function Offre_eff_conforme () returns boolean
  language sql as
$$
  select not exists(select * from Offre_plan_non_couverte())
$$;
comment on function Offre_eff_conforme () is
  'Détermine si l’affection (offre effective) est conforme à l’offre (planifiée).'
;

/*
-- =========================================================================== Y
== Question

1. Que penser de l’ouverture de la cause d’absence ? Un inventaire fermé des
   causes ne serait-il pas préférable ?
2. Que penser de la définition de Sigle en regard de la dépendance fonctionnelle
   entre la discipline et le département introduite en cours pour l’exemple de
   FNBC ?
3. Le trimestre n’est-il pas un exemple d’entorse à la 1FN ?
-- =========================================================================== Y
*/

/*
-- =========================================================================== Z
== Contributeurs
  (CK01) Christina.KHNAISSER@USherbrooke.ca,
  (LL01) Luc.LAVOIE@USherbrooke.ca

== Adresse, droits d’auteur et copyright
  Groupe Μῆτις (Métis)
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada
  http://info.usherbrooke.ca/llavoie/
  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

== Tâches projetées
TODO 2021-03-02 (LL01) : Réaliser les étapes subséquentes
  * e04 : affinement des types Cause (d’absence), Sigle (de cours)  et Trimestre
    ** Illustration des tables de code.
    ** Illustration des dangers des attributs composites, en particulier en regard des clés.
  * e05 : affinement du concept de trimestre.
    ** Illustration de l’explicitation des attributs afin d’éviter les « constantes cachées ».
  * e06 : division en schémas.
    ** Gestion de la complexité et du couplage par la visibilité.
    ** Gestion de l’intégrité et de la sécurité par le contrôle d’accès.

== Tâches réalisées
2021-03-02 (LL01) : Réalisation de l’étape 03
  * Définition des types à partir du dictionnaire de données.
    ** Illustration du bon usage des contraintes de type.
2021-02-25 (LL01) : Réalisation de l’étape 02
  * Traitement explicite de l’offre de cours (programmée et effective).
    ** Illustration du traitement de la 5FN.
2021-02-23 (LL01) : Réalisation de l’étape e01.
  * Prise en compte de l’absence potentielle de certaines valeurs.
    ** Illustration du traitement de l’annulabilité :
       *** cas non applicable (note lors de l’inscription) ;
       *** cas non disponible (bureau du professeur) ;
       *** par DPJ ;
       *** par DRU.
2021-02-18 (LL01) : Réalisation de l’étape e00.
  * Prise en compte des entités de base Étudiant, Professeur, Cours, Groupe...
    ** Illustration de la construction par entité et dépendances fonctionnelles.
2021-02-15 (LL01) : Création initiale inspirée de l’exemple développé en 2014.

== Références
[ddv] http://info.usherbrooke.ca/llavoie/enseignement/Exemples/Universite/
      Universite_DDV.pdf
[std] http://info.usherbrooke.ca/llavoie/enseignement/Modules/
      BD190-STD-SQL-01_NDC.pdf
-- =========================================================================== Z
*/
