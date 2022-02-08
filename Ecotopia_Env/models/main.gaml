/**
* Name: main
* Main experiment, launch all files :
* - The mini-cities
* - All the population
* - The ecosystem
* - The farms, forests and weather
* Author: Damien Legros
*/


model main
import "california_environment.gaml"
import "farms.gaml"
import "individual.gaml"
import "mini_city.gaml"
import "parameters.gaml"
import "forest.gaml"

global {
	
	init {
		
		do instanciate_MiniCities;
		
		write "--------------------------------\n\tTEST INITIALISATION\n--------------------------------";
		
		do test_initialisation_MiniCities;
		
		do test_initialisation_inidividus_of_MiniCities;
				
//		// TEST create_grid et pick_random_location
//		list l <- createCircularGrid( point(500,500), 10, 1);
//		matrix mat <- l[0];
//		int mat_size <- l[1];
//		list shape_object <- [5,5];
//		list res <- pickRandomLocationInMatrix(mat, mat_size, shape_object);
//		
//		// TEST create_grid et pick_random_location
//		MiniCity mc <- MiniCity[0];
//		list l <- createCircularGrid( mc.location, mc.diameter, cellSizeMiniCityGrid);
//		matrix mat <- l[0];
//		int mat_size <- l[1];
//		bool ava <- true;
//		list buildings <- [];
//		loop while: ava{
//			int building_size <- rnd(1,int(mat_size/4));
//			list shape_object <- [building_size,building_size];
//			list res <- pickRandomLocationInMatrix(mat, mat_size, shape_object);
//			if res[0] = -1 {
//				ava <- false;
//			} else {
//				add [building_size, res] to: buildings;
//			}
//		}
//		write mat;
//		write buildings;
	}
	
	action test_initialisation_MiniCities {
		// Calculating the "constellationPopulation" and the length of the "list_minicities_constellation" attributes for every BigCity
		// the first one is supposed to be equals to nb_agent_init, the second one to nb_minicity_init.
		int poptotBC <- 0;
		int nb_mc_BC <- 0;
		loop bigcity over: BigCity {
			poptotBC <- poptotBC + bigcity.constellationPopulation;
			nb_mc_BC <- nb_mc_BC + length(bigcity.list_minicities_constellation);
		}
		
		// Calculating the "population" attribute for every BigCity
		// the first one is supposed to be equals to nb_agent_init, the second one to nb_minicity_init. 
		int poptotMC <- 0;
		loop minicity over: agents of_generic_species MiniCity {
			poptotMC <- poptotMC + minicity.population;
		}

		// Prints to see the initialisation's stats
		write "nb_minicity_init = " + nb_minicity_init;
		write "nb MiniCity instanciées = " + length(agents of_generic_species MiniCity);
		write "sum list(MiniCity) des cities = " + nb_mc_BC;
		write "nb_agent_init = " + nb_agent_init;
		write "sum BigCity.pop  = " + poptotBC; // doesn't work
		write "sum MiniCity.pop = " + poptotMC;
		write "nb individus instanciées = " + length(agents of_generic_species individu); // doesn't work
		
		// Tests initialisation mini-villes
		assert length(agents of_generic_species MiniCity) = nb_minicity_init;
		assert nb_mc_BC = nb_minicity_init;
		assert poptotBC = nb_agent_init;
		assert poptotMC = nb_agent_init;
	}
	
	action test_initialisation_inidividus_of_MiniCities {
		// Tests initialisation individus
		assert length(agents of_generic_species individu) = nb_agent_init;
	}
}

experiment main type: gui {
    output {
		layout horizontal([vertical([0::6721,3::3279])::5000,vertical([horizontal([1::5000,2::5000])::5000,horizontal([4::5000,5::5000])::5000])::5000]) tabs:false toolbars:false;
		
		//display map visualisation
		display farms_display type: opengl {
	    	image "fronteers" gis: "../includes/california_fronteers.shp" color: rgb('white');
	    	species mountains aspect: base;
	    	species forest aspect: base transparency: 0.65;
	    	species desert aspect: base transparency: 0.65;
	    	species river aspect: base;
	        //species city aspect: base;
	        species geothermal aspect: base;
	        species nuclear aspect: base;
	        species hydroelectric aspect: base;
	        species MiniCity aspect: base;
	        //species weather_cell transparency: 0.65;
	        //grid weather_cell border: #black transparency: 0.65;
	        species farm_cell aspect: base transparency: 0.85;
	        grid farm_cell border: #black transparency: 0.65;
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
				data "cloudy" value:sum(weather_cell where (each.day_sun=1) collect(each.day_sun)) color:#gray;
				data "sunny" value:sum(weather_cell where (each.day_sun=2) collect(each.day_sun-1)) color:#orange;
				//data "no sun" value:sum(weather_cell collect(each.night_sun+1)) color:#blue;
			}
			chart "Average wind speed" size: {0.33,0.9} position: {0.66, 0} type:series
			{
				data "km/h" value:mean(weather_cell collect(each.wind)) color:#green;
			}
		}
		display consommation_charts refresh: every(1 #day){
			/*chart "Consommation of food" size: {1,0.5} position: {0, 0} type:series
			*{
			*	data "meat for people" value:sum(farm_cell where (each.image=0) collect(each.meat_consommation_per_day)) color:#red;
			*	data "crop for people" value:sum(farm_cell where (each.image=1) collect(each.plants_consommation_per_day)) color:#green;
			*	data "crop for animals" value:sum(farm_cell where (each.image=1) collect(each.meat_cell_consommation)) color:#yellow;
			*}
			*/
			chart "Water consommation" size: {1,0.5} position: {0, 0} type: series
			{
                data "Water" value: water_consommation color: #blue;
            }
            
            chart "Tree quantity" size: {1,0.5} position: {0, 0.5} type: series
            {
                data "Thousands of Trees" value: first(ForestCamp).nb_Trees /10 color: #green;
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
