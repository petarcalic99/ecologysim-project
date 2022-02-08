/**
* Name: farms
* Model of the farms for plants, meat and coton,
* Also simulate the consommation 
* Author: Damien Legros, Cedric Cornède, Petar Calic
* Tags: 
*/

model farms

import "california_environment.gaml"
import "weather.gaml"
import "ecosystem.gaml"
import "parameters.gaml"
import "mini_city.gaml"

global {
    //liste des images des fermes et forets
    list<file> images_farms <- [
		file("../images/meat.png"),
		file("../images/vegetables.png"),
		file("../images/cotton.png"),
		file("../images/eraser.png"),
		file("../images/forest.png")]; 
	
	// pour récupérer la consommation en eau de la production totale
	reflex get_water_consommation when: every(1 #day){
		loop i over: farm_cell.population{
			if i.image=0{
			    weather_cell  weather <- weather_cell grid_at {i.grid_x,i.grid_x}; // on regarde la case équivalente de la grille météo
			    if weather.rain = 1{ // on regarde si il a plu sur notre case viande
			    	water_consommation <- water_consommation + i. meat_per_day* animal_consommation_water - weather.rainwater;
			    }
			    else{ // si il n'y a pas de pluie consommation classique
					water_consommation <- water_consommation + i. meat_per_day* animal_consommation_water;
				}
			}
			if i.image=1{
				weather_cell  weather <- weather_cell grid_at {i.grid_x,i.grid_x};
				 if weather.rain = 1{
				 	water_consommation <- water_consommation + i. crop_per_day *plants_consommation_water - weather.rainwater;
				 }
				 else{
					water_consommation <- water_consommation + i. crop_per_day *plants_consommation_water;
				}
			}
			if i.image=2{
				weather_cell  weather <- weather_cell grid_at {i.grid_x,i.grid_x};
				if weather.rain = 1{
					water_consommation <- water_consommation + i. cotton_per_day *cotton_consommation_water - weather.rainwater;
				}
				else {
					water_consommation <- water_consommation + i. cotton_per_day *cotton_consommation_water;
				}
			}
		}
	}
	
	//type de bouton
	int button_type <- -1;
	
	//active le bouton selectionné
	action activate_button {
		button selected_but <- first(button overlapping (circle(1.0) at_location #user_location));
		if(selected_but != nil) {
			ask selected_but {
				ask button {bord_contour<-#black;}
				if (button_type != id) {
					button_type<-id;
					bord_contour<-#yellow;
				} else {
					button_type<- -1;
				}
				
			}
		}
	}
	
	//met a jour les cases de la grille par rapport au bouton selectionné
	action cell_management {
		farm_cell selected_cell <- first(farm_cell overlapping (circle(1.0) at_location #user_location));
		if(selected_cell != nil) {
			ask selected_cell {
				image <- button_type;
				switch button_type {
					match 0 {color <- #red;}
					match 1 {color <- #green;}
					match 2 {color <- #blue;}
					match 3 {color <- #white; image <- -1;}
				}
			}
		}
	}
}

grid farm_cell height: grid_size width: grid_size neighbors: 8 {
	
	float meat_per_1km2 <- 800000 #kg; //rendement pour 1km2
	float crop_per_1km2 <- 850000 #kg; //rendement pour 1km2
	float cotton_per_1km2 <- 151 #kg; //rendement pour 1km2
	
	float meat_capacity <- meat_per_1km2 * cell_size #kg; //rendement par case
	float crop_capacity <- crop_per_1km2 * cell_size #kg; //rendement par case
	float cotton_capacity <- cotton_per_1km2 * cell_size #kg; //rendement par case
	
	float meat_grow <- 90.0; //temps de croissance de la viande
	float crop_grow <- 120.0; //temps de croissance des legumes
	float cotton_grow <- 120.0; //temps de croissance du coton
	
	float meat_per_day <- meat_capacity / meat_grow #kg; //rendement par jour
	float crop_per_day <- crop_capacity / crop_grow #kg; //rendement par jour
	float cotton_per_day <- cotton_capacity / cotton_grow #kg; //rendement par jour
	
	float meat_consommation_per_day <- 0.0; //consommation par jour de viande
	float plants_consommation_per_day <- 0.0; //consommation par jour de plantes
	float meat_cell_consommation <- 0.0; //consommation des animaux de plantes
	
	int image <- -1; //type de fermes (0: Elevage, 1: Champ, 2: Coton 3: PAS DE FERMES->GOMME)
	
	aspect base {
		if (image >= 0) {
			draw image_file(images_farms[image]) size:{shape.width * 0.5,shape.height * 0.5};
		}
	}
	
	float meat <- meat_capacity max: meat_capacity; //quantité de viande présente sur la case
	float crop <- crop_capacity max: crop_capacity; //quantité de plantes présente sur la case
	float cotton <- cotton_capacity max: cotton_capacity; //quantité de coton présente sur la case
	
	rgb color_update <- #white;
	rgb color <- #white update: color_update;
	
	reflex update_color {
		if image=0{
			color_update <- hsb(0.0,1.0*meat/meat_capacity,1.0);
		}
		if image=1{
			color_update <- hsb(0.33,1.0*crop/crop_capacity,1.0);
		}
		if image=2{
			color_update <- hsb(0.66,1.0*cotton/cotton_capacity,1.0);
		}
	}
	
	float get_meat_consommation{ // pour récupérer la consommation en viande des mini-villes
		meat_consommation_per_day <- 0.0;
		if image=0{
			loop i over: agents of_generic_species MiniCity{
				meat_consommation_per_day <- meat_consommation_per_day + 2*(meat_consommation_per_minicity); // en kg
			}
		}
		return meat_consommation_per_day;
	}
	
	float get_plants_consommation{ // pour récupérer la consommation en plantes des mini-villes
		plants_consommation_per_day <- 0.0;
		if image=1{
			loop i over: agents of_generic_species MiniCity{
				plants_consommation_per_day <- plants_consommation_per_day + 2*(plants_consommation_per_minicity); // en kg
			}
		}
		return plants_consommation_per_day;
	}
	
    int get_meat_cell{ // pour avoir le nombre de cases ou il y a de la viande
		int meat_cell<- 0; 
		loop i over: farm_cell.population{
			if i.image=0{
				meat_cell <- meat_cell + 1;
			}
		}
		return meat_cell;
	}
	
	int get_plants_cell{ // pour avoir le nombre de cases ou il y a des plantes
		int plants_cell<- 0; 
		loop i over: farm_cell.population{
			if i.image=1{
				plants_cell <- plants_cell + 1;
			}
		}
		return plants_cell;
	}
	
	float get_animal_consommation{ // pour récupérer la consommation en plante de la production de viande 
		meat_cell_consommation <- 0.0;
		loop i over: farm_cell.population{
			if i.image=0{
				meat_cell_consommation <- meat_cell_consommation + i.meat_per_day*animal_consommation_plants;
			}
		}
		return meat_cell_consommation;
	}
	
	reflex grow when: every(1 #day) { // chaque case a une quantité de viande qui lui est propre et si la case est pas vache la quantité est à 0 
		if image=0 {
			meat <- min([meat_capacity, meat + meat_per_day]);
		}
		if image=1 {
			float animal_consommation <- get_animal_consommation(); // consommation total de plantes par les élevages
			int number_plants_cell <- get_plants_cell();
			animal_consommation <- animal_consommation/number_plants_cell;
			crop <- min([crop_capacity, max([0,crop + crop_per_day - animal_consommation])]);
		}
		if image=2 and flip(0.5) {cotton <- min([cotton_capacity, cotton + cotton_per_day]);}
	}
	
	reflex consume when: every(1 #day)  { // ce reflex s'applique sur chaque case du coup là on retire la quantité de viande consommé total à chaque case
		if meat!=0.0 {
			float meat_consommation <- get_meat_consommation(); // consommation total de viande des minivilles pour une journée
			int number_meat_cell <- get_meat_cell();
			meat_consommation <- meat_consommation/number_meat_cell; // on retire la quantité consommé de manière uniforme à chaque case viande
			meat <- max([0, meat - meat_consommation ]);
		}
		if crop!=0.0 {
			float plants_consommation <- get_plants_consommation(); // consommation total de plantes des minivilles pour une journée 
			int number_plants_cell <- get_plants_cell();
			plants_consommation <- plants_consommation/number_plants_cell; 
			crop <- max([0, crop - plants_consommation]);
		}
		if cotton!=0.0 and flip(0.5) {cotton <- max([0, cotton - cotton_per_day]);}
	}
	
	reflex biomass_waste_production when: every(1 #day) { // chaque case produit une quantité de déchets
		if image=0 {
			biomass_waste <- biomass_waste + (animal_production_waste * meat_per_day);
		}
		if image=1 {
			biomass_waste <- biomass_waste - (plants_conso_waste * crop_per_day);
		}
		if image=2 {
			biomass_waste <- biomass_waste - (cotton_conso_waste * cotton_per_day);
		}
	}
	
	reflex GHG_production when: every(1 #day) { // chaque case produit une quantité de gaz à effet de serre
		if image=0 {
			greenhouse_emissions <- greenhouse_emissions + (animal_production_ghg * meat_per_day);
		}
		if image=1 {
			greenhouse_emissions <- greenhouse_emissions + (plants_production_ghg * crop_per_day);
		}
		if image=2 {
			greenhouse_emissions <- greenhouse_emissions + (cotton_production_ghg * cotton_per_day);
		}
	}
}

//Grille des boutons pour placer les fermes
grid button width:4 height:1 {
	int id <- int(self);
	list<rgb> bord_rect<- [
		#red,
		#green,
		#blue,
		#white
	];
	rgb bord_contour<- #black;
	aspect base {
		draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_contour;
		draw rectangle(shape.width * 0.7,shape.height * 0.7) + (shape.height * 0.01) color: bord_rect[id];
		draw image_file(images_farms[id]) size:{shape.width * 0.5,shape.height * 0.5};
	}
}

experiment FarmsTest type: gui {
	
	output {
		layout horizontal([vertical([0::6721,3::3279])::5000,vertical([horizontal([1::5000,2::5000])::5000,horizontal([4::5000,5::5000])::5000])::5000]) tabs:false toolbars:false;
		
		//display map visualisation
		display farms_display type: opengl {
	    	image "fronteers" gis: "../includes/california_fronteers.shp" color: rgb('white');
	    	species mountains aspect: base;
	    	species forest aspect: base transparency: 0.65;
	    	species desert aspect: base transparency: 0.65;
	    	species river aspect: base;
	        species city aspect: base;
	        species geothermal aspect: base;
	        species nuclear aspect: base;
	        species hydroelectric aspect: base;
	        species farm_cell aspect: base transparency: 0.75;
	        grid farm_cell border: #black transparency: 0.75;
	        event mouse_up action: cell_management;
	        
	    }
	    //display the action buttons
		display farms_charts background:#white refresh: every(1 #day){
			species button aspect: base transparency: 0.65 size: {1,0.2} position: {0, 0};
			event mouse_down action:activate_button;    
			chart "Supply available in farms" size: {1,0.8} position: {0, 0.2} type:series
			{
				data "meat" value:sum(farm_cell where (each.image=0) collect(each.meat)) color:#red;
				data "crop" value:sum(farm_cell where (each.image=1) collect(each.crop)) color:#green;
				data "cotton*5500" value:sum(farm_cell where (each.image=2) collect(each.cotton*5500)) color:#blue;
			}
		}
	    display season_temperature_charts refresh: every(12 #hours){
	    	chart "Average temperature  in Celsius" size: {1,0.7} position: {0, 0} type:series
			{
				data "day" value:mean(weather_cell collect(each.day_temperature)) color:#orange;
				data "night" value:mean(weather_cell collect(each.night_temperature)) color:#blue;
			}
			species ecosystime aspect: base size: {0.29,0.27} position: {0, 0.58};
			species ecosyseason aspect: base size: {0.29,0.27} position: {0.4, 0.58};
	    }
	    display weather_charts refresh: every(12 #hours){
			chart "Number of cells with rain" size: {0.33,0.9} position: {0, 0} type:series
			{
				data "no rain" value:sum(weather_cell where (each.rain=0) collect(each.rain+1)) color:#orange;
				data "rainy" value:sum(weather_cell where (each.rain=1) collect(each.rain)) color:#blue;
			}
			chart "Number of cells with sun" size: {0.33,0.9} position: {0.33, 0} type:series
			{
				//data "no sun" value:sum(weather_cell where (each.sun=0) collect(each.sun+1)) color:#blue;
				data "cloudy" value:sum(weather_cell where (each.sun=1) collect(each.sun)) color:#grey;
				data "sunny" value:sum(weather_cell where (each.sun=2) collect(each.sun-1)) color:#orange;
			}
			chart "Average wind speed" size: {0.33,0.9} position: {0.66, 0} type:series
			{
				data "km/h" value:mean(weather_cell collect(each.wind)) color:#green;
			}
		}
		display consommation_charts refresh: every(1 #day){
			chart "Consommation of food" size: {1,0.5} position: {0, 0} type:series
			{
				data "meat for people" value:sum(farm_cell where (each.image=0) collect(each.meat_consommation_per_day)) color:#red;
				data "crop for people" value:sum(farm_cell where (each.image=1) collect(each.plants_consommation_per_day)) color:#green;
				data "crop for animals" value:sum(farm_cell where (each.image=1) collect(each.meat_cell_consommation)) color:#yellow;
			}
			chart "Water consommation" size: {1,0.5} position: {0, 0.5} type: series
			{
                data "Water" value: water_consommation color: #blue;
            }
		}
		display ghg_biomass_charts refresh: every(1 #day){
			chart "Biomass waste" size: {1,0.5} position: {0, 0} type:series
			{
				data "kg" value: biomass_waste color:#green;
			}
			chart "Greenhouse emissions" size: {1,0.5} position: {0, 0.5} type:series
			{
				data "kg" value: greenhouse_emissions color:#red;
			}
		}
	}
}
