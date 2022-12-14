open Unix
open Libcsv


let current_year () =
  let tm = localtime (time ()) in
  tm.tm_year + 1900;;

let current_month () =
  let tm = localtime (time ()) in
  tm.tm_mon;;

let current_day () =
  let tm = localtime (time ()) in
  tm.tm_mday;;

let jour_est_inferieur annee mois jour =
  annee < current_year () ||
  annee = current_year () && mois < current_month () ||
  annee = current_year () && mois = current_month () && jour < current_day ();;

let rec recuperer_element l index = match l with
  |[] -> failwith "liste vide"
  |e :: rl -> if index = 0 then e else recuperer_element rl (index-1);;

let plan_est_correct plan =
  let annee = int_of_string (recuperer_element plan 0) in
  let mois =  int_of_string (recuperer_element plan 1) in
  let jour =  int_of_string (recuperer_element plan 2) in
   not(jour_est_inferieur annee mois jour);;

let rec enlever_lignes liste_liste_csv = match liste_liste_csv with
  |[] -> []
  |plan :: rl -> if plan_est_correct plan then plan :: enlever_lignes rl else
                enlever_lignes rl ;;


    (* prend une liste de liste de plan , le nom d'une categorie et la valeur a soustraire, recherche dans la liste la donnee avec la bonne categorie et soustrait la valeur dnnee
au nombre associé a la categorie, renvoie une nouvelle double liste avec la valeure bien soustraite a la bonne categorie*)
let rec enlever_une_valeur liste_liste_plan nom_de_la_categorie valeur_a_soustraire =
  match liste_liste_plan with
  | [] -> failwith "mauvais nom de categorie, celle-ci est introuvable";
  | donnee :: rl -> let categorie, valeur = recuperer_element donnee 0, int_of_string (recuperer_element donnee 1) in
                    if categorie = nom_de_la_categorie then let nouvelle_valeur = valeur - valeur_a_soustraire in
                      [categorie; string_of_int nouvelle_valeur ] :: rl
                    else donnee :: enlever_une_valeur rl nom_de_la_categorie valeur_a_soustraire


let rec est_un_evenement plan = recuperer_element plan 5 = "null"


     (* prend une double liste de donnees et un plan qui sera incorrect, retourne la nouvelle double liste avec les valeurs correctes retirées  *) 
let rec donnee_changee liste_liste_donnees plan =
  let liste_un_plan_en_moins = enlever_une_valeur liste_liste_donnees "nbPlans" 1  in 
  if est_un_evenement plan then
    enlever_une_valeur liste_un_plan_en_moins "nbEvenements" 1 else
    let nbSousTache = int_of_string (recuperer_element plan 6) in
    enlever_une_valeur (enlever_une_valeur liste_un_plan_en_moins "nbTachesAFaire" 1) "nbTotalSousTachesAFaire" nbSousTache;;


     (* prend la double liste des donnees, la double liste des plans et parcours la double liste des plans, si le plan est incorrect, modifier la double liste des donnees,
renvoie une nouvelle double liste de donnée qui correspondra au fichier 'csv *)
let rec modifier_les_donnees liste_liste_donnees liste_liste_plan = match liste_liste_plan with
  |[] -> liste_liste_donnees;
  |plan :: rl ->  if plan_est_correct plan then modifier_les_donnees liste_liste_donnees rl   else
                   modifier_les_donnees (donnee_changee liste_liste_donnees plan) rl  ;;






let donnees_csv () =
  let chemin_plan =  Libunix.get_example_file "listeDesPlanPrevu.csv" in
  let  plan_csv = Libcsv.load_csv chemin_plan in
  let chemin = Libunix.get_example_file "donnees.csv" in
  let output = Libunix.get_example_file "nouvellesDonnees.csv" in
  let csv = Libcsv.load_csv chemin in
  let csv' = modifier_les_donnees csv plan_csv in
  let nl, nc = Libcsv.lines_columns csv' in
  let () = Format.printf "Ecriture d'un CSV de taille (%d x %d) dans: %s\n" nl nc output in
  Libcsv.save_csv output csv'

let main_csv () =
  let chemin = Libunix.get_example_file "listeDesPlanPrevu.csv" in
  let output = Libunix.get_example_file "nouvelleListeDesPlan.csv" in
  let csv = Libcsv.load_csv chemin in
  let csv' = enlever_lignes csv in
  let nl, nc = Libcsv.lines_columns csv' in
  let () = Format.printf "Ecriture d'un CSV de taille (%d x %d) dans: %s\n" nl nc output in
  Libcsv.save_csv output csv'


(* Exécute les procédures précédentes *)

let () = donnees_csv ();;
let () = main_csv ();;
