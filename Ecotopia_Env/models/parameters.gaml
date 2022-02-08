/**
* Name: parameters 
* File with all the parameters of each section
* Author: Cedric Cornède, Damien Legros, Marius Le Chapelier, Petar Calic
*/


model parameters

global{
	//-------------------------------------------------------------Mes paramètres----------------------------------------------------------------------------------
	
	//----Paramètres généraux-----------
	int time_offset <- 6 parameter: "Start Time:" category: "Simulation"; //Time offset for when to start the day
	bool stop_simulation <- true parameter: "Stop Simulation: " category: "Simulation"; //Whether or not to stop the simulation after a certain number of days
	int stop_sim_day <- 1 parameter: "The number of days to stop the simulation after: " category: "Simulation"; //The number of days to stop the simulation after
	float step <- 1 #hour min: 0.0 parameter: "Pas de la simulation" category: "Simulation"; //pas de la simulation
	
	//----Paramètres de la grille--------
	float map_size <- 1240.0 #km parameter: "Longueur de la carte: " category: "Carte";//largeur de la carte
	float grid_size <- 20.0 parameter: "Taille de la grille: " category: "Carte"; //nombre de cases sur une ligne et une colonne
	float cell_size <- map_size / grid_size #km; //taille d'une case
	
	//----Paramètres des mini-villes-----
	int nb_minicity_init <- 250 min: 21 max: 5000 parameter: "Nombre de Mini-villes: " category: "MiniCity"; // nombre de mini-villes de la simulation
	float nb_minicity_per_mini_city_sim <- nb_people*nb_minicity_init/nb_people_per_minicity_real; // le nombre de mini-city réelle auquel équivaut une mini-ville simulée.
	int nb_agent_per_minicity <- nb_agent_init div nb_minicity_init ; // le nombre d'agent par mini-ville
	float probaForestCamp <- 0.2 min: 0.0 max: 1.0 parameter: "probaForestCamp" ; // proba qu'une minicity soit un camp forestier
	
	//----Paramèters des individus-------
	float  active_rate <- 0.4453 min: 0.0 max: 1.0 parameter: "Taux d'actif: " category: "Individu"; 
	float  student_rate <- 0.0513 min: 0.0 max: 1.0 parameter: "Taux d'étudiant: " category: "Individu"; 
	float  inactive_rate <- 0.036 min: 0.0 max: 1.0 parameter: "Taux d'inactif: " category: "Individu"; 
	float  Age_0_18_rate <- 0.225 min: 0.0 max: 1.0 parameter: "Taux d'individu ayant moins de 18 ans: " category: "Individu";
	float  Age_18_64_rate <- 0.627 min: 0.0 max: 1.0 parameter: "Taux d'individu entre 18 et 64 ans: " category: "Individu";
	float  Age_65_rate <- 0.148 min: 0.0 max: 1.0 parameter: "Taux d'individu entre 18 et 64 ans: " category: "Individu";
	float  Women_rate <- 0.503 min: 0.0 max: 1.0 parameter: "Taux d'homme: " category: "Individu";
	float  Men_rate <- 0.497 min: 0.0 max: 1.0 parameter: "Taux de femme: " category: "Individu";
	int nb_people <- 39512223 parameter: "Population Californie: " category: "Individu"; //nombre d’habitants
	int nb_people_per_minicity_real <- 10000 parameter: "Habitants par Mini-ville: " category: "Individu"; // nombre d’habitants par mini-villes
	
	//----Paramètres de la consommation--
	float full_stomack_time <- 12#h parameter: "Temps après lequel un repas est consommé: " category: "Individu";// définit tous les combien de temps les doivent manger
	float meal_size <- 0.3 parameter: "Taille d'un repas en gramme: " category: "Individu"; // définit la quantité de nourriture par repas (en grammes)
	float meat_ratio <- 0.0 parameter: "Ratio de viande d'un repas: " category: "Individu";// définit la quantité de viande par repas
	float plants_ratio <- 1.0 parameter: "Ratio de légumes d'un repas: " category: "Individu"; // définit la quantité de plantes par repas
	float meat_consomation_agent <- nb_people_per_agent*meal_size*meat_ratio; // viande consommé par un agent par repas
    float plants_consomation_agent <- nb_people_per_agent*meal_size*plants_ratio; // plantes consommé par un agent par repas
	float meat_consommation_per_minicity <- meat_consomation_agent*nb_agent_per_minicity; // consommation de viande d'une mini-city par repas
	float plants_consommation_per_minicity <- plants_consomation_agent*nb_agent_per_minicity; // consommation de plantes d'une mini-city par repas
	float meal_consomation_agent <- nb_people_per_agent*meal_size; // nourriture consommé par un agent par repas
	list meal <- [["meat", meal_consomation_agent*meat_ratio], ["plants", meal_consomation_agent*plants_ratio]];
	
	//----Paramètres des agents--
	int nb_agent_init <- 2500 min: 21 max: 50000 parameter: "Nombre d'agents: " category: "Individu"; // nombre d’agents de la simulation
	float nb_people_per_agent <- nb_people / nb_agent_init; // le nombre d'individu auquel correspond un agent
	
	//----Paramètres des forêts----
	int GforestSurface <- 133000 parameter: "Surface totale de la forêt en km2: " category: "Forêts"; //Surface totale de la forêt en km2
	int Gtreeperkm2 <- 100 parameter: "Nombre d'arbres par centaine par km2: " category: "Forêts"; //Nombre d'arbres par centaine par km2
	int Gnb_Trees <- GforestSurface * Gtreeperkm2; //Nombre total d arbre dans les forets de a Californie par paquets de 100
	int Gnb_TreesInit <- GforestSurface * Gtreeperkm2; // Nombre total inital
	int GnbTreesMaxFactor <- 2 parameter: "Facteur du nombre maximum d'arbres: " category: "Forêts"; // "Maximum possible number of trees Factor"
	int GnbTreesMax <- Gnb_Trees * GnbTreesMaxFactor; //Nombre maximum d'arbre possible
	float GtreeConsoGhg <- 0.3 parameter: "kg de GES consommé par un arbre par jour: " category: "Forêts"; //kg de GES consommé par un arbre par mois
	float GcoefNaturalGrowth <- 1.0001 parameter: "Coef de reproduction des arbres: " category: "Forêts"; // "Coef of Natural forest renewal"
	float GcoefNaturalDeath <- 0.99999 parameter: "Coef de mort naturel des arbres: " category: "Forêts"; // "Coef of Natural forest death"
	float Gnb_TreesMinFactor <- 0.5 parameter: "bornne minimum d arbres permis: " category: "Forêts"; // "Minimum alowed tree proportion"
   	int Gnb_TreesMin <- round(Gnb_Trees * Gnb_TreesMinFactor); // Borne Minimum d'arbre en Californie
    float GtreeMass <- 0.5 parameter: "Masse d'un arbre en tonnes: " category:"Forêts"; //masse d'un arbre en tonnes
    float GproportionOk <- 0.75 parameter: "proportion acceptable de la foret apres deforestation: " category: "Forêts"; //"Borne inf de arbre acceptable"
    float GwaistPerTreeFactor <- 1.0 parameter: "Quantité de dechet produit par la coupure d'un arbre en kg: " category: "Forêts"; // "Quantité de dechet produit par la coupure d'un arbre en Kilograme
    float GtreeConsoWater <- 200.0 parameter: "Consommation d'eau d'un arbre par jour en litre: " category: "Forêts"; // Consomation d'eau d'un arbre par mois en litre
    
    //----Paramètres de l'écosystème----
    float biomass_waste <- 0.0 min: 0.0 parameter: "Initialisation de la quantité de biomasse/engrais: " category: "Ecosystème";
    float greenhouse_emissions <- 500000000.0 min: 0.0 parameter: "Initialisation de la quantité de gas à effet de serre: " category: "Ecosystème";
    float animal_consommation_plants <- 4 #kg parameter: "Quantité de plantes pour produire un kg de viande: " category: "Ecosystème"; //définit la quantité de plantes consommé pour la production de 1kg de viande
    float animal_consommation_water <- 6000 #l parameter: "Quantité d'eau pour produire un kg de viande: " category: "Ecosystème"; //définit la quantité d'eau consommé pour la production de 1kg de viande
    float water_consommation <- 0 #l parameter: "Initialisation de la consommation d'eau: " category: "Ecosystème"; //consommation de l'eau 
    float plants_consommation_water <-  1211 #l parameter: "Quantité d'eau pour produire un kg de plantes: " category: "Ecosystème"; //définit la quantité d'eau consommé pour la production de 1kg de plantes
    float cotton_consommation_water <-  5260 #l parameter: "Quantité d'eau pour produire un kg de coton: " category: "Ecosystème"; //définit la quantité d'eau consommé pour la production de 1kg de coton
    float animal_production_ghg <- 70 #kg parameter: "Quantité de GES pour produire un kg de viande: " category: "Ecosystème"; //définit la quantité de GHG produit pour la production de 1kg de viande
	float plants_production_ghg <- 1.6 #kg parameter: "Quantité de GES pour produire un kg de plantes: " category: "Ecosystème"; //définit la quantité de GHG produit pour la production de 1kg de plantes
	float cotton_production_ghg <- 2 #kg parameter: "Quantité de GES pour produire un kg de coton: " category: "Ecosystème"; //définit la quantité de GHG produit pour la production de 1kg de coton
	float animal_production_waste <- 10 #kg parameter: "Quantité de déchets pour produire un kg de viande: " category: "Ecosystème"; //définit la quantité de dechet produit pour la production de 1kg de viande
	float plants_conso_waste <- 5 #kg parameter: "Quantité de déchets pour produire un kg de plantes: " category: "Ecosystème"; //définit la quantité de dechet produit pour la production de 1kg de plantes
	float cotton_conso_waste <- 5 #kg parameter: "Quantité de déchets pour produire un kg de coton: " category: "Ecosystème"; //définit la quantité de dechet produit pour la production de 1kg de coton
	
    //----Paramètres de la météo----
	float wind_noise <- 1.0 min: 0.0 parameter: "Bruit dans la génération du vent" category: "Meteo";//bruit dans le choix du vent
	float temperature_noise <- 2.0 min: 0.0 parameter: "Bruit dans la génération de la temperature" category: "Meteo"; //bruit dans le choix de la temperature
	float rainwater_quantity_perkm2 <- 4000000#l min: 0.0 parameter: "Quantité d'eau tombée en 1h sur 1km2 lors d'une précipitation" category: "Meteo"; //Quantité d'eau tombé sur 1km2 et par heure lors d'une précipiation
	
	//from : https://en.wikipedia.org/wiki/Climate_of_California#cite_note-24
	float temperature_january <- 8.9 min: 0.0 parameter: "Temperature moyenne en janvier: " category: "Meteo";
	float temperature_february <- 11.3 min: 0.0 parameter: "Temperature moyenne en fevrier: " category: "Meteo";
	float temperature_march <- 14.1 min: 0.0 parameter: "Temperature moyenne en mars: " category: "Meteo";
	float temperature_april <- 16.8 min: 0.0 parameter: "Temperature moyenne en avril: " category: "Meteo";
	float temperature_may <- 21.2 min: 0.0 parameter: "Temperature moyenne en mai: " category: "Meteo";
	float temperature_june <- 25.3 min: 0.0 parameter: "Temperature moyenne en juin: " category: "Meteo";
	float temperature_july <- 28.6 min: 0.0 parameter: "Temperature moyenne en juillet: " category: "Meteo";
	float temperature_august <- 27.9 min: 0.0 parameter: "Temperature moyenne en août: " category: "Meteo";
	float temperature_september <- 25.1 min: 0.0 parameter: "Temperature moyenne en septembre: " category: "Meteo";
	float temperature_october <- 19.3 min: 0.0 parameter: "Temperature moyenne en octobre: " category: "Meteo";
	float temperature_november <- 12.8 min: 0.0 parameter: "Temperature moyenne en novembre: " category: "Meteo";
	float temperature_december <- 8.6 min: 0.0 parameter: "Temperature moyenne en decembre: " category: "Meteo";
	
	list temperature_per_month <- [
		temperature_january, 
		temperature_february, 
		temperature_march, 
		temperature_april, 
		temperature_may, 
		temperature_june, 
		temperature_july, 
		temperature_august, 
		temperature_september,
		temperature_october,
		temperature_november, 
		temperature_december]; //in celsius
	
	float rain_january <- 7.7 min: 0.0 parameter: "Jours de pluie par mois en janvier: " category: "Meteo";
	float rain_february <- 8.5 min: 0.0 parameter: "Jours de pluie par mois en fevrier: " category: "Meteo";
	float rain_march <- 7.2 min: 0.0 parameter: "Jours de pluie par mois en mars: " category: "Meteo";
	float rain_april <- 4.5 min: 0.0 parameter: "Jours de pluie par mois en avril: " category: "Meteo";
	float rain_may <- 2.7 min: 0.0 parameter: "Jours de pluie par mois en mai: " category: "Meteo";
	float rain_june <- 0.7 min: 0.0 parameter: "Jours de pluie par mois en juin: " category: "Meteo";
	float rain_july <- 0.3 min: 0.0 parameter: "Jours de pluie par mois en juillet: " category: "Meteo";
	float rain_august <- 0.1 min: 0.0 parameter: "Jours de pluie par mois en août: " category: "Meteo";
	float rain_september <- 0.6 min: 0.0 parameter: "Jours de pluie par mois en septembre: " category: "Meteo";
	float rain_october <- 2.2 min: 0.0 parameter: "Jours de pluie par mois en octobre: " category: "Meteo";
	float rain_november <- 2.2 min: 0.0 parameter: "Jours de pluie par mois en novembre: " category: "Meteo";
	float rain_december <- 7.3 min: 0.0 parameter: "Jours de pluie par mois en decembre: " category: "Meteo";
	
	list rain_per_month <- [
		rain_january, 
		rain_february, 
		rain_march, 
		rain_april, 
		rain_may, 
		rain_june, 
		rain_july, 
		rain_august, 
		rain_september,
		rain_october,
		rain_november, 
		rain_december]; //in days
	
	float sunshine_january <- 46.0 min: 0.0 parameter: "Pourcentage de soleil par mois en janvier: " category: "Meteo";
	float sunshine_february <- 65.0 min: 0.0 parameter: "Pourcentage de soleil par mois en fevrier: " category: "Meteo";
	float sunshine_march <- 77.0 min: 0.0 parameter: "Pourcentage de soleil par mois en mars: " category: "Meteo";
	float sunshine_april <- 85.0 min: 0.0 parameter: "Pourcentage de soleil par mois en avril: " category: "Meteo";
	float sunshine_may <- 91.0 min: 0.0 parameter: "Pourcentage de soleil par mois en mai: " category: "Meteo";
	float sunshine_june <- 94.0 min: 0.0 parameter: "Pourcentage de soleil par mois en juin: " category: "Meteo";
	float sunshine_july <- 96.0 min: 0.0 parameter: "Pourcentage de soleil par mois en juillet: " category: "Meteo";
	float sunshine_august <- 95.0 min: 0.0 parameter: "Pourcentage de soleil par mois en août: " category: "Meteo";
	float sunshine_september <- 93.0 min: 0.0 parameter: "Pourcentage de soleil par mois en septembre: " category: "Meteo";
	float sunshine_october <- 87.0 min: 0.0 parameter: "Pourcentage de soleil par mois en octobre: " category: "Meteo";
	float sunshine_november <- 62.0 min: 0.0 parameter: "Pourcentage de soleil par mois en novembre: " category: "Meteo";
	float sunshine_december <- 42.0 min: 0.0 parameter: "Pourcentage de soleil par mois en decembre: " category: "Meteo";

	list sunshine_per_month <- [
		sunshine_january, 
		sunshine_february, 
		sunshine_march, 
		sunshine_april,
		sunshine_may,
		sunshine_june,
		sunshine_july, 
		sunshine_august,
		sunshine_september,
		sunshine_october,
		sunshine_november,
		sunshine_december]; //in pourcentage
		
	//from :https://www.weather2visit.com/north-america/united-states/fresno-ca.htm
	
	float wind_january <- 9.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en janvier: " category: "Meteo";
	float wind_february <- 10.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en fevrier: " category: "Meteo";
	float wind_march <- 12.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en mars: " category: "Meteo";
	float wind_april <- 13.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en avril: " category: "Meteo";
	float wind_may <- 14.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en mai: " category: "Meteo";
	float wind_june <- 15.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en juin: " category: "Meteo";
	float wind_july <- 13.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en juillet: " category: "Meteo";
	float wind_august <- 12.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en août: " category: "Meteo";
	float wind_september <- 11.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en septembre: " category: "Meteo";
	float wind_october <- 10.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en octobre: " category: "Meteo";
	float wind_november <- 9.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en novembre: " category: "Meteo";
	float wind_december <- 9.0 min: 0.0 parameter: "Vitesse de vent en km/h moyenne par mois en decembre: " category: "Meteo";
	
	list wind_per_month <- [
		wind_january,
		wind_february,
		wind_march,
		wind_april,
		wind_may,
		wind_june,
		wind_july,
		wind_august,
		wind_september,
		wind_october,
		wind_november,
		wind_december]; //in km/h
	
}
