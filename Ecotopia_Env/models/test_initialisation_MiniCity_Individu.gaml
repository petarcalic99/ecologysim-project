/**
* Name: MiniCity
* Based on the internal empty template. 
* Author: Marius Le Chapelier
* Tags: 
*/


model test_initialisation_MiniCity_Individu
import "california_environment.gaml"
import "individual.gaml"
import "mini_city.gaml"
import "parameters.gaml"

/* Insert your model definition here */

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

experiment test_env type: gui {    
//	parameter "nb_people_sim" var: nb_people <- 39512223; //min: 1 max: 39512223 ;
//	parameter "nb_people_per_minicity_sim" var: nb_people_per_minicity_real <- 10000 ;//min: 1 max: 10000 ;
//	parameter "nb_agent_init" var: nb_agent_init <- 5000; //min: 1 max: 100000 ; 
//	parameter "nb_minicity_init" var: nb_minicity_init <- 500; //min: 1 max: 10000 ; 
//	parameter "mean_diameter_minicity" var: mean_diameter_minicity <- 800#m; //min: 1 max: 10000 ; 
//	parameter "mean_diameter_city" var: mean_diameter_city <- 10000#m; //min: 1#m max: 10000 ; 
//	parameter "cellSizeMiniCityGrid" var: cellSizeMiniCityGrid <- 50#m; //min: 1 max: 10000 ; 
//	parameter "cellSizeBigCityGrid" var: cellSizeBigCityGrid <- mean_diameter_minicity + 1000#m;// min: 1 max: 10000 ;
	
    output {
	    display city_display type: java2D { //other type available : opengl, which is more detailed
	    	image "fronteers" gis: "../includes/california_fronteers.shp" color: rgb('white');
	    	species mountains aspect: base;
	    	species forest aspect: base transparency: 0.65;
	    	species desert aspect: base transparency: 0.65;
	    	species river aspect: base;
	        species city aspect: base;
	        species geothermal aspect: base;
	        species nuclear aspect: base;
	        species hydroelectric aspect: base;
	        species MiniCity aspect: base;
	        species forestCamp aspect: base;
	    }
    }
}
