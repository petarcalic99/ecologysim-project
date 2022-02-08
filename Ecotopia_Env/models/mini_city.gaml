/**
* Name: MiniCity
* Based on the internal empty template. 
* Author: Marius Le Chapelier
* Tags: 
*/


model mini_city

import "california_environment.gaml"
import "individual.gaml"
import "parameters.gaml"

global {
	
	// Variables calculées avec les variables du dessus
	int nb_minicity_per_city;
	int nb_cities; // nombre de villes réelles a patir desquelles on va faire nos constellations de mini-villes.
	float consomation_per_minicity <- nb_agent_per_minicity*meal_consomation_agent; // consommation de nourriture par Mini-ville
	
	// Variables pour la grille
	float mean_diameter_minicity <- 800#m; // diamètre moyen des mini-villes ;
	float mean_diameter_city <- 10000#m; // diamètre moyen des constellations de mini-villes ;
	float cellSizeMiniCityGrid <- 50#m; // taille d'une cellule dans la grille de la mini-ville
	float cellSizeBigCityGrid <- mean_diameter_minicity + 1000#m; // taille d'une cellule dans la grille de la constellation de mini-villes.
	
	init {
		
	}
	
	//returns a grid of boolean indicating if the cells are available
    list createCircularGrid( point center, float diameter, int nb_elem_to_create, float size_cell){
        
        int size_grid_for_diameter <- floor(diameter/size_cell); // number of cells in column/line for diameter of the city (10min between 2 cities);
        int size_grid_for_nb_elems <- ceil(sqrt(nb_elem_to_create)); // number of cells in column/line to create a grid big enough for nb_elem_to_create
        int N <- max(size_grid_for_diameter, size_grid_for_nb_elems)+1; // number of cells in column/line +1 because of the grid's corners unavailablity 

        // builds a two-dimensions matrix with N columns and N rows, where each cell is initialized to false
        bool engough_cell <- false;
        int g_size <- N;
        matrix mat;
        
        loop while: engough_cell = false{
        	mat <- nil as_matrix({g_size,g_size});
        	float new_diameter <- g_size*size_cell;
        	int nb_cell_available <- g_size*g_size;
        	
        	loop i from: 0 to: g_size -1{
	            loop j from: 0 to: g_size -1{
	                if (isInCircle(i, j, new_diameter, size_cell, g_size)){ // the cell is within the circle
	                    mat[i,j]<-true; //the cell is set as available
	                }
	                else {
	                	nb_cell_available <- nb_cell_available -1;
	                	if nb_cell_available < nb_elem_to_create {
	                		g_size <- g_size + 1;
	                		break;
	                	}
	                    mat[i,j]<-false; //the cell is set as not available
	                }
	            }
	        }
	        if nb_cell_available >= nb_elem_to_create {
            	engough_cell <- true;
            }
        }
        
        assert not ( mat contains_any [nil]) ; //all elements are either true or false
        assert length(mat)=g_size*g_size; //mat has the right sizes
        return [mat, g_size];
    }
    
    // check if the cell (i,j) is within the circle ( maybe we could find a better way to check this information but this will do for now)
        

    bool isInCircle (int i, int j,float diameter, float size_cell, int N){

        //relative position of all corners of the cell
//        point topLeftCorner <- {( i - (N/2) ) * size_cell, (j - (N/2) ) * size_cell } ;
//        point topRightCorner <- {( i+1 - (N/2) ) * size_cell, (j- (N/2) ) * size_cell } ;
//        point bottomLeftCorner <- {( i - (N/2) ) * size_cell, (j+1 - (N/2) ) * size_cell } ;
//        point bottomRightCorner <- {( i+1 - (N/2) ) * size_cell, (j+1 - (N/2) ) * size_cell } ;
		point centerCell <- {( i - (N/2) + 0.5) * size_cell, (j - (N/2) + 0.5) * size_cell } ;
        float radius <- diameter/2;
        
        //check if every corner is within the circle
//         if (distance_to(topLeftCorner, {0,0}) <= radius){
//            if (distance_to(topRightCorner, {0,0}) <= radius){
//                if (distance_to(bottomLeftCorner, {0,0}) <= radius){
//                    if (distance_to(topLeftCorner, {0,0}) <= radius){
//                        return true; //the cell is available
//                    }
//                }
//            }
//        }    

		// check if center of cell is within the circle
		if distance_to(centerCell, {0,0}) <= radius {
			return true;
		}
        return false;
    }
    
    point returnRealPositionCell(list<int> position_in_grid, int grid_size, point bigcity_location) {
    	float real_x <- bigcity_location.x+(position_in_grid[0]+0.5-grid_size/2)*cellSizeBigCityGrid;
    	float real_y <- bigcity_location.y+(position_in_grid[1]+0.5-grid_size/2)*cellSizeBigCityGrid;
    	return point(real_x, real_y);
    }
	
	list pickRandomLocationInMatrix(matrix ava_grid, int grid_size, list shape_object){
		list real_shape_object <- [int(shape_object[0])-1, int(shape_object[1])-1]; // on enlève un par dimension car on commence à 0 et non à 1
		list randomCell <- [rnd(grid_size-1), rnd(grid_size-1)]; // On prend une cellule aléatoire dans la matrice
		// On parcours toute la matrice à partir de cette cellule à la recherche d'un emplacement disponible
		loop i from: 0 to: grid_size{
			loop j from: 0 to: grid_size{
				// Comme on a démarré à une cellule aléatoire et non [0,0], on ajuste les coordonnées de la cellule courrante pour pas tomber en dehors de la matrice
				list currentCell <- [randomCell[0]+i, randomCell[1]+j];
				if currentCell[0] >= grid_size {
					currentCell[0] <- currentCell[0] - grid_size;
				}
				if currentCell[1] >= grid_size {
					currentCell[1] <- currentCell[1] - grid_size;
				}
				// Si la cellule est disponible et que la shape de l'objet que l'on veut placer ne dépasse pas de la matrice
				if (ava_grid[currentCell[0], currentCell[1]] = true
					and currentCell[0]+int(real_shape_object[0]) < grid_size
					and currentCell[1]+int(real_shape_object[1]) < grid_size)
				{
					// On va checker si toutes les cellules que l'objet occuperait sont disponibles
					list indexs <-[currentCell[0], currentCell[0]+int(real_shape_object[0]), currentCell[1], currentCell[1]+int(real_shape_object[1])];
					if checkIndexs(indexs, ava_grid){
						// toutes les cellules sont dispo, on va donc placer l'objet. On rend les cellules indisponible pour les futurs objets.
						do setIndexs(indexs, ava_grid);
						// attention pour les objets de plus de 1 cellule !
						return [currentCell[0], currentCell[1]];
					}
				}
			}
		}
//		write "NO PLACE AVAILABLE";
//		write ava_grid;
		return [-1,-1];
	}
	
	bool checkIndexs(list indexs, matrix mat){
		loop id_x from: indexs[0] to:indexs[1] {
			loop id_y from: indexs[2] to:indexs[3] {
				if mat[id_x, id_y] = false {
					return false;
				}
			}
		}
		return true;
	}
	
	action setIndexs(list indexs, matrix grid){
		loop id_x from: indexs[0] to:indexs[1] {
			loop id_y from: indexs[2] to:indexs[3] {
				grid[int(id_x), int(id_y)] <- false;
			}
		}
	}
	
	BigCity create_big_city(string cityname, point loc, int nb_minicities, int constellation_population){
		float dc <- mean_diameter_city; // gauss({mean_diameter_minicity,mean_diameter_minicity*0.1})
//		write "CREATE BIG CITY";
//		write "nb_minicities = "+ nb_minicities;
		list grid_city <- createCircularGrid(loc, dc, nb_minicities, cellSizeBigCityGrid);
//		write grid_city;
//		write "nb_columns = "+matrix(grid_city[0]).columns;
//		write "nb_rows = "+matrix(grid_city[0]).rows;
		
		float dmc <- mean_diameter_minicity; // gauss({mean_diameter_minicity,mean_diameter_minicity*0.1})
		int pmc <- constellation_population div nb_minicities; // calculer a partir de la population de BigCity ?
		int surplus_pop <- constellation_population mod nb_minicities;
//		write "pmc = " + pmc;
//		write "surplus_pop = " + surplus_pop;
		int nb_buildings_to_create <- 0; // to change in Dwelling
		list grid_minicity <- createCircularGrid(loc, dmc, nb_buildings_to_create, cellSizeMiniCityGrid);

		create BigCity as: MiniCity returns: list_bigcities {
			// the city
			name <- cityname;
			location <- loc;
			constellationDiameter <- mean_diameter_city;
			constellationPopulation <- constellation_population;
			availability_matrix_bigcity <- grid_city[0];
			availability_matrix_bigcity_size <- grid_city[1];
			list_minicities_constellation <- [];
	
			//the mini_city
			diameter <- dmc;
			if surplus_pop > 0 {
				population <- pmc + 1;
				surplus_pop <- surplus_pop - 1;
			} else {
				population <- pmc;
			}
			availability_matrix_minicity <- grid_minicity[0];
			availability_matrix_minicity_size <- grid_minicity[1];
		}
		// take the bigcity
		BigCity bigcity <- list_bigcities[0];
		
		// add individus
		bigcity.individus <- create_individu(bigcity.population, bigcity);
		
		// add the bigcity's minicity to the constellation's list of minicities 
		add bigcity to: bigcity.list_minicities_constellation;
		
		// create the buildings
		BigCity bigcity <- list_bigcities[0];
		do create_buildings(bigcity);
		
		// On compte avec la population de la minicity de BigCity
//		write "BIGCITY GRID BEFORE MINCITIES:";
//		write bigcity.availability_matrix_bigcity;
		int pop <- bigcity.population;
		bool can_still_build <- true;
		point minicity_location;
		list res;
		MiniCity minicity;
		if (nb_minicities-2) > 0 {
			loop i from:0 to:nb_minicities-2 {
//				write "CREATE MINICITY";
				res <- add_MiniCity_to_Constellation(bigcity, can_still_build);
				can_still_build <- res[0];
				minicity_location <- res[1];
				if can_still_build {
//					write "instanciate minicity : "+bigcity.name+" , loc = "+minicity_location;
					if surplus_pop > 0 {
						minicity <- create_mini_city(bigcity, pmc+1, minicity_location);
						surplus_pop <- surplus_pop - 1;
					} else {
						minicity <- create_mini_city(bigcity, pmc, minicity_location);
					}
					pop <- pop + minicity.population;
					// add the minicities to the constellation's list of minicities 
					add minicity to: bigcity.list_minicities_constellation;
				} else {
					write "ERROR : NE PEUT PAS CONSTRUIRE DE MINICITY, minicity num "+i; // n'est pas sensé arriver
				}
//				write "BIGCITY GRID:";
//				write bigcity.availability_matrix_bigcity;
			}
		}
//		write "BIGCITY GRID AFTER MINCITIES:";
//		write bigcity.availability_matrix_bigcity;
		return bigcity;
	}
	
	MiniCity create_mini_city(BigCity bigCity, int pop, point minicity_location){
//		point l <- bigCity.location;
		float d <- mean_diameter_minicity; // gauss({mean_diameter_minicity,mean_diameter_minicity*0.1})
		int nb_building_to_create <- 0; // a changer dans dwelling
		list grid_minicity <- createCircularGrid(minicity_location, d, nb_building_to_create, cellSizeMiniCityGrid); // matrix et sa taille
		map<string,float> Rstock <- self initial_resourceStock [];
		MiniCity minicity;
		// Minicity or forestCamps
		if (rnd(0.0, 1.0) < probaForestCamp) {
			create forestCamp returns: list_minicities {}
			minicity <- list_minicities[0]; // on récupère la minicity à partir du returns (un seul élément dans la liste)
		} else {
			create MiniCity returns: list_minicities {}
			minicity <- list_minicities[0]; // on récupère la minicity à partir du returns (un seul élément dans la liste)
		}
		minicity.location <- minicity_location;
		minicity.diameter <- d;
		minicity.population <- pop; 
		minicity.availability_matrix_minicity <- grid_minicity[0];
		minicity.availability_matrix_minicity_size <- grid_minicity[1];
		minicity.resourceStock <- Rstock;
		
		// create the buildings
		minicity.individus <- create_individu(pop, minicity);
		do create_buildings(minicity);
		return minicity;
	}
	
	action create_buildings(MiniCity minicity){
		bool can_still_build <- true;
		list building_location;
//		list buildings <- [];
		loop while: can_still_build{
			// TO CHANGE IN THE DWELING BLOCK
			int building_size <- rnd(1,int(minicity.availability_matrix_minicity_size/4)); 
			list shape_object <- [building_size, building_size];
			//
			building_location <- pickRandomLocationInMatrix(minicity.availability_matrix_minicity, minicity.availability_matrix_minicity_size, shape_object);
			if building_location[0] = -1 {
				can_still_build <- false;
			} else {
				do create_building(building_location);
//				add [building_size, res] to: buildings;
			}
		}
	}
	
	list add_MiniCity_to_Constellation(BigCity bigcity, bool can_still_build){
		list<int> building_position_in_grid;
		point building_location;
		if can_still_build {
			int city_size <- 1 ; // grid shaped to have a one-minicity cells size
			list shape_object <- [city_size, city_size];
			building_position_in_grid <- pickRandomLocationInMatrix(bigcity.availability_matrix_bigcity, bigcity.availability_matrix_bigcity_size, shape_object);
			building_location <- returnRealPositionCell(building_position_in_grid, bigcity.availability_matrix_bigcity_size, bigcity.location);
	    	if building_position_in_grid[0] = -1 {
				can_still_build <- false;
			}
		}
		return [can_still_build, building_location];
	}
	
	action create_building(list building_location){
//		write "create bulding";
	}
	
	map initial_resourceStock{
		map resourceStock <- create_map(["cotton","plastic","meat","vegetables"],[100.0,100.0,100.0,100.0]);
		return resourceStock;
	}
	
	action instanciate_MiniCities {
		
		// calling cities initialisation in california_environment file
		int nb_cities <- self create_cities [];
//		do create_cities returns: nb_cities;
//		nb_cities <- int(nb_cities);
		
		// Print simulation variable :
		write "--------------------------------\n\tSIMULATION VARIABLES\n--------------------------------";
		write "nb_cities = "+nb_cities;
		write "nb_minicity_init = " + nb_minicity_init;
		write "nb_agent_init = "+ nb_agent_init;
		
		
		write "--------------------------------\n\tDISTRIBUTION MINICITIES AND INDIVIDUS\n--------------------------------";
		
		// Distribution MiniCities over BigCities
		nb_minicity_per_city <- nb_minicity_init div int(nb_cities);
		int nb_agent_per_city <- nb_agent_init div int(nb_cities);
		list minicities_repartition_in_cities <- list_with(int(nb_cities), nb_minicity_per_city);
		list agents_repartition_in_cities <- list_with(int(nb_cities), nb_minicity_per_city*nb_agent_per_minicity);

		// Distribution extra MiniCities over BigCities
		int nb_minicities_repartition <- int(nb_cities)*nb_minicity_per_city;
		int i <- 0;
		loop while: nb_minicities_repartition < nb_minicity_init {
			minicities_repartition_in_cities[i] <- minicities_repartition_in_cities[i] + 1; // adding a minicity to the city
			agents_repartition_in_cities[i] <- agents_repartition_in_cities[i] + nb_agent_per_minicity; // adding the corresponding number of agents to the city
			nb_minicities_repartition <- nb_minicities_repartition + 1;
			i  <- i + 1;
		}
		int nb_agents_repartition <- sum(agents_repartition_in_cities);
		
		// Print simulation variable :
		write "MiniCity initialisation variables :";
		write "nb_minicity_per_city = " + nb_minicity_per_city;
		write "nb_agent_per_minicity = " + nb_agent_per_minicity;
		write "starting minicities_repartition_in_cities : \n" + minicities_repartition_in_cities;
		write "" + sum(minicities_repartition_in_cities) + " minicities distributed";
		write "" + sum(agents_repartition_in_cities) + " agents distributed";
		write "" + (nb_agent_init - nb_agents_repartition) + " agents left to distribute";
		write "starting agents_repartition_in_cities : \n" + agents_repartition_in_cities;
		
		// Distribution extra agents over BigCities
		int i <- 0;
		loop while: nb_agents_repartition < nb_agent_init {
			agents_repartition_in_cities[i] <- agents_repartition_in_cities[i] + 1;
			nb_agents_repartition <- nb_agents_repartition + 1;
			i <- (i = int(nb_cities)-1) ? 0 : i + 1;
		}
		
		// Agents Distribution after the extra agents distribution
		write "  ---- Agents distribution over BigCities.. ----";
		write "agents_repartition_in_cities : \n" + agents_repartition_in_cities; 
		write "" + sum(agents_repartition_in_cities) + "/" + nb_agent_init + " agents distributed";
		write "" + (nb_agent_init - nb_agents_repartition) + " agents left to distribute";
		write "Distribution over, let's instanciate the cities and agents";
		
		// Creating the BigCities
		write "--------------------------------\n\tINSTANCIATING MINICITIES AND INDIVIDUS\n--------------------------------";
		int nb_mc <- 0;
		BigCity bigcity;
		city c;
		loop i from:0 to:length(city)-1 {
			c <- city[i];
			write "instanciate city : "+c.name+" , loc = "+c.location;
			bigcity <- create_big_city(c.name, c.location, minicities_repartition_in_cities[i], agents_repartition_in_cities[i]);
			nb_mc <- nb_mc + minicities_repartition_in_cities[i];
		}
	}
	
}


species forestCamp parent:MiniCity {
	
	// diplay
	rgb color <- #darkgreen ;
    aspect base {
    	draw circle(1#px) color: color ;
    }
}
	
species MiniCity {
	float diameter;
	int population;
	list individus;
	matrix availability_matrix_minicity;
	int availability_matrix_minicity_size;
	
	// diplay
	rgb color <- #blue ;
    aspect base {
    	draw circle(1#px) color: color ;
    }
	
	/// gestion ressources
	map<string,float> resourceStock; /*LES RESSOURCES SONT GERES PAR UN DICTIONNAIRE. CLES = NOMS DES RESSOURCES, VALEURS = STOCK ACTUEL */
    
    bool askForResources (string resource, float quantity) { 
        if(resourceStock[resource]>=quantity){ /*A TESTER; PEUT CAUSER DES ERREURS SI resource N'EST PAS UNE CLE DU STOCK */
//            resourceStock[resource] <- resourceStock[resource] - quantity;
            return true;
        } 
        else{
            return false;
        }
    }
    bool askForResources1 (string resource, float quantity) { 
    	return resourceStock[resource]>=quantity;
    }
    
    action getResources (string resource, float quantity) { 
        resourceStock[resource] <- resourceStock[resource] - quantity;
    }
    
    int getResources1 (string resource, float quantity) { 
        resourceStock[resource] <- resourceStock[resource] - quantity;
        return 0;
    }
    
    action giveResources (string resource, float quantity) {
        resourceStock[resource] <- resourceStock[resource] + quantity;
    }
    
    
	// buildings...
}

species BigCity parent:MiniCity {
	string name;
	float constellationDiameter;
	int constellationPopulation;
	matrix availability_matrix_bigcity;
	int availability_matrix_bigcity_size;
	list list_minicities_constellation;
	// buildings...
}

//experiment MiniCity_env type: gui {    
//	parameter "nb_people_sim" var: nb_people <- 39512223; //min: 1 max: 39512223 ;
//	parameter "nb_people_per_minicity_sim" var: nb_people_per_minicity_real <- 10000 ;//min: 1 max: 10000 ;
//	parameter "nb_agent_init" var: nb_agent_init <- 5000; //min: 1 max: 100000 ; 
//	parameter "nb_minicity_init" var: nb_minicity_init <- 500; //min: 1 max: 10000 ; 
//	parameter "mean_diameter_minicity" var: mean_diameter_minicity <- 800#m; //min: 1 max: 10000 ; 
//	parameter "mean_diameter_city" var: mean_diameter_city <- 10000#m; //min: 1#m max: 10000 ; 
//	parameter "cellSizeMiniCityGrid" var: cellSizeMiniCityGrid <- 50#m; //min: 1 max: 10000 ; 
//	parameter "cellSizeBigCityGrid" var: cellSizeBigCityGrid <- mean_diameter_minicity + 1000#m;// min: 1 max: 10000 ;
//	
//    output {
//	    display city_display type: java2D { //other type available : opengl, which is more detailed
//	    	image "fronteers" gis: "../includes/california_fronteers.shp" color: rgb('white');
//	    	species mountains aspect: base;
//	    	species forest aspect: base transparency: 0.65;
//	    	species desert aspect: base transparency: 0.65;
//	    	species river aspect: base;
//	        species city aspect: base;
//	        species geothermal aspect: base;
//	        species nuclear aspect: base;
//	        species hydroelectric aspect: base;
//	    }
//    }
//}
