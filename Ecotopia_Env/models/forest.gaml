/**
* Name: forest
* Based on the internal empty template. 
* Author: Petar Calic
* Tags: 
*/


model forest

import "california_environment.gaml"
import "parameters.gaml"
import "ecosystem.gaml"

global {    
//    reflex update {
//    	ask ForestCamp {
//        	do update_color;
//    	}
//    	//write(first(ForestCamp).nb_Trees); 
//    }

	init{
		create ForestCamp;
	}
    
    reflex cutTrees when : every(5 #day){   //les 2 méthodes qui simulent la déforestation, ceci est plus un test avant le merge
        ask ForestCamp {
            do cut(5000); //5000 paquets de 100 arbres
        }
       // write(first(ForestCamp).nb_Trees); 
    }
    
    reflex replantTrees when : every(5 #day){
        ask ForestCamp {
            do replant(500); //500 paquets de 100 arbres
        } 
    }  
    
}

species ForestCamp {
	
    int forestSurface <- GforestSurface;
    int nb_Trees <- Gnb_Trees; // In packages of 100
    int nb_TreesInit <- Gnb_TreesInit;
    int nbTreesMax <- GnbTreesMax;
    float treeConsoGhg <- GtreeConsoGhg;
    float treeConsoWater <- GtreeConsoWater;
    float coefNaturalGrowth <- GcoefNaturalGrowth; 
    float coefNaturalDeath <- GcoefNaturalDeath;
    int nb_TreesMin <- Gnb_TreesMin;
    float treeMass <- GtreeMass;
    float proportionOk <- GproportionOk;
    float waistPerTreeFactor <- GwaistPerTreeFactor;
    
    
    
   // action update_color {
  //  	
 //   	loop el over: forest.population {
//		    if (self overlaps el.shape){
//			    if (nb_Trees >= nb_TreesInit * 0.75) {
//			        color <- #green;
//			    } else if ((nb_Trees  < nb_TreesInit * 0.75) and (nb_Trees >= nb_TreesInit * 0.5)) {
//			        color <- #lightgreen;
//			    } else if (nb_Trees <= nb_TreesInit * 0.5) {
//			        color <- #gray;
//			    }
//		    }
//	  	}
//	}
	  
	action replant (int n){
	 	nb_Trees <- nb_Trees + n ;
	}   
	 
	action cut (int n){ //in hundreds of trees
	 	nb_Trees <- nb_Trees - n ;
	 	biomass_waste <- biomass_waste + n * waistPerTreeFactor; //renvoie la quantité de dechet en kg.
	}   
	 
	action conversionT_NbTrees (int t){
	 	return t * treeMass;
	}
	 
	reflex consumeGHG when : every (1 #day){
	 	float conso <- 0.0;
	 	conso <- nb_Trees * treeConsoGhg;
	 	//write(conso);
	 	greenhouse_emissions <- greenhouse_emissions - conso;
	 	//write(greenhouse_emissions);
	 	
	}
	 
	reflex consumeWater when : every (1 #day){
	 	float conso <- 0.0;
	 	conso <- nb_Trees * (treeConsoWater);
	 	water_consommation <- water_consommation + conso;
	}
	 
	reflex growthTrees when : every(1 #day) {
	 	nb_Trees <- round(nb_Trees * coefNaturalGrowth);	 	
	}
	 
	reflex deathTrees when : every(1 #day){
		nb_Trees <- round(nb_Trees * coefNaturalDeath);
	}
	 
	reflex alertTreeLoss {
	 	if(nb_Trees < nb_TreesMin){
	 		write("ALERTE!");
	 	}
	}	 
}


experiment forest_env type: gui {
    output {
	    display city_display type: java2D { //other type available : opengl, which is more detailed
	    	image "fronteers" gis: "../includes/california_fronteers.shp" color: rgb('white');
	    	species mountains aspect: base;
	    	species forest aspect: base transparency: 0.55;
	    	species desert aspect: base transparency: 0.55;
	    	species river aspect: base;
	        species city aspect: base;
	        species geothermal aspect: base;
	        species nuclear aspect: base;
	        species hydroelectric aspect: base;        
	        
	    }
    }
}
