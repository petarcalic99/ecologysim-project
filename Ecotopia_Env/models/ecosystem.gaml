/**
* Name: ecosystem
* Model for the ecosystem, to work with :
* - the time
* - the seasons
* Author: Damien Legros
* Tags: 
*/


model ecosystem

import "parameters.gaml"
import "farms.gaml"

global {
	//liste des images jour nuit
	list<file> images_day_night <- [
		file("../images/day.png"),
		file("../images/night.png")]; 
	//liste des images des saisons
	list<file> images_season <- [
		file("../images/winter.png"),
		file("../images/spring.png"),
		file("../images/summer.png"),
		file("../images/autumn.png")]; 
	
	//initilaisation de l'agent ecosystem
	init{
		create ecosystem;
	}
}

//Grille d'un agent pour afficher dans la visualisation le jour ou la nuit
grid ecosystime width:1 height:1 {
	
	aspect base {
		switch first(ecosystem).night {
			match 0 {draw image_file(images_day_night[0]);}
			match 1 {draw image_file(images_day_night[1]);}
		}
	}
}

//Grille d'un agent pour afficher dans la visualisation la saison
grid ecosyseason width:1 height:1 {
	aspect base {
		switch first(ecosystem).season {
			match 0 {draw image_file(images_season[0]);}
			match 1 {draw image_file(images_season[1]);}
			match 2 {draw image_file(images_season[2]);}
			match 3 {draw image_file(images_season[3]);}
		}
	}
}

//Agent ecosystem, s'occupe des variables des déchets des GHG et du temps (jour, mois et année)
species ecosystem {
	
	int day <- 0;
	int month <- 0;
	int year <- 2021;
	
	int night <- 1; //0: day, 1: night
	int season <- 3; //0: winter, 1: spring, 2: summer, 3: autumn
	
	reflex update_night when: every(12 #hours){
		if night=1 {night <- 0;} 
		else {night <- 1;}
	}
	reflex update_season when: every(3 #month){
		season <- mod((season + 1),4);
	}
	reflex update_day when: every(1 #day){
		day <- mod((day + 1), 30);
	}
	reflex update_month when: every(1 #month){
		month <- mod((month + 1), 12);
	}
	reflex update_year when: every(1 #year){
		year <- year + 1;
	}
	
}
