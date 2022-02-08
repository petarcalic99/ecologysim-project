/**
* Name: weather
* Model of the weather :
* - wind
* - temperature
* - rain
* - sun
* Author: Damien Legros
* Tags: 
*/


model weather

import "california_environment.gaml"
import "ecosystem.gaml"
import "parameters.gaml"

//grille des agents pour la météo (vent, temperature, soleil et pluie)
grid weather_cell height: grid_size width: grid_size neighbors: 8 {
	
	int rain_capacity <- 2; //0: no rain, 1: rainy
	int sun_capacity <- 3; //0: no sun, 1: cloudy, 2: sunny
	
	int rain_update <- 0;
	float rainwater_update<- 0.0; 
	int sun_update <- 1;
	int night_sun_update <- 1;
	int day_sun_update <- 1;
	float wind_update <- 9.0;
	float temperature_update <- 8.9;
	float night_temperature_update <- 8.9;
	float day_temperature_update <- 8.9;
	float rainwater_quantity_cell <- rainwater_quantity_perkm2 * cell_size; // Quantité d'eau en 1h sur une case quand il pleut
	
	float temperature <- temperature_update update: temperature_update;
	float night_temperature <- night_temperature_update update: night_temperature_update;
	float day_temperature <- day_temperature_update update: day_temperature_update;
	int rain <- rain_update max: rain_capacity update: rain_update;
	int sun <- sun_update max: sun_capacity update: sun_update; 
	int night_sun <- night_sun_update max: sun_capacity update: night_sun_update; 
	int day_sun <- day_sun_update max: sun_capacity update: day_sun_update; 
	float wind <- wind_update update: wind_update;
	float rainwater <- rainwater_update update: rainwater_update  ; //quantité d'eau de pluie présente sur la case

	float temperature_of_the_month;
	float rain_of_the_month;
	float sunshine_of_the_month;
	float wind_of_the_month;
	
	reflex update when: every(12 #hour) {
		
		//write first(ecosystem).month-1;
		temperature_of_the_month <- temperature_per_month[first(ecosystem).month-1];
		rain_of_the_month <- rain_per_month[first(ecosystem).month-1];
		sunshine_of_the_month <- sunshine_per_month[first(ecosystem).month-1];
		wind_of_the_month <- wind_per_month[first(ecosystem).month-1];
		
		//rain
		if flip(rain_of_the_month/30.0) {
			rain_update <- 1;
			rainwater_update <- rainwater_update + 12*rainwater_quantity_cell;
		}
		else {rain_update <- 0;}
		loop el over: desert.population {
			if self overlaps el.shape {rain_update <- 0;} 
		}
		//sun
		if flip(sunshine_of_the_month/100.0) {sun_update <- 2; day_sun_update <- 2;}
		else {sun_update <- 1; day_sun_update <- 1;}
		loop el over: desert.population {
			if self overlaps el.shape {sun_update <- 2; day_sun_update <- 2;} 
		}
		if first(ecosystem).night=1 {sun_update <- 0; night_sun_update <- 0;}
		//wind
		wind_update <- rnd(wind_of_the_month - wind_noise, wind_of_the_month + wind_noise);
		//temperature
		if first(ecosystem).night=1 {
			temperature_update <- rnd(temperature_of_the_month - temperature_noise, temperature_of_the_month);
			night_temperature_update <- temperature_update;
		}
		else {
			temperature_update <- rnd(temperature_of_the_month, temperature_of_the_month + temperature_noise);
			day_temperature_update <- temperature_update;
		}
		
	}
	
}
