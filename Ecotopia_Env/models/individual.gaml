/**
* Name: individual
* Based on the internal empty template. 
* Author: Cedric Cornede
* Tags: 
*/


model individual

import "california_environment.gaml"
import "individual.gaml"
import "mini_city.gaml"
import "parameters.gaml"

global {
	
    int pop_mc <- nb_agent_per_minicity;
    
    int current_hour update: time_offset + (time / #hour) mod 24  ;
    
    int nb_people_worked_init <- pop_mc*active_rate;
    int nb_student_init <- pop_mc*student_rate;
    int nb_inactive_init <- pop_mc*inactive_rate;
//    int  nb_Age_0_18_init <- nb_people*Age_0_18_rate;
//    int  nb_Age_18_64_init <- nb_people*Age_18_64_rate;
//    int  nb_Age_65_init <- nb_people*Age_65_rate;
    int  nb_Men_init <- pop_mc*Men_rate;
    int  nb_Women_init <- pop_mc*Women_rate;
   
    // On initalise un maximum et un minimum pour le début et la fin du travail 
    int min_work_start <- 4;
	int max_work_start <- 10;
	int min_work_end <- 21; 
	int max_work_end <- 22; 
	
	float min_speed <- 4 #km / #h;
	float max_speed <- 6 #km / #h; 
	
    init {
//    	create MiniCity returns:mc;
//    	do create_individu(nb_people, mc[0]);
    	
//    	// On crée les individus entre 0 et 18 ans
//    	create individu number: nb_Age_0_18_init {
//        	Age <- rnd (0,18);
//        	Activity <- "Scolarise"; 
//        	House <- one_of(company) ;
//        	WorkPlace <- one_of(company);
//        	FunZone <- one_of(company);
//            location <- any_location_in (House);
//            objective <- "resting";    
//            speed <- min_speed + rnd (max_speed - min_speed) ;     
//        }
//        // On crée les individus de plus de 65 ans
//        create individu number: nb_Age_65_init {
//        	Age <- rnd (65,100);
//        	Activity <- "Inactif"; 
//        	House <- one_of(company) ;
//        	WorkPlace <- one_of(company);
//        	FunZone <- one_of(company);
//            location <- any_location_in (House);
//            objective <- "resting";   
//            speed <- min_speed + rnd (max_speed - min_speed) ;         
//        }
// 		 // On crée les individus entre 18 et 64 ans
//        create individu number: nb_Age_18_64_init  {
//        	Age <- rnd (18,64);
//        	House <- one_of(company) ;
//        	WorkPlace <- one_of(company);
//        	FunZone <- one_of(company);
//            location <- any_location_in (House);
//            objective <- "resting";  
//            speed <- min_speed + rnd (max_speed - min_speed) ;          
//        }
//        
//        // On met des caractéristiques aux individus parmis ceux déjà crée
//        ask nb_Men_init among individu {
//            Gender <- "Homme";
//        }
//        ask nb_Women_init among individu where (each.Gender != "Homme") {
//            Gender <- "Femme";
//        }
//        ask nb_people_worked_init among individu where (each.Age<65 and 18<each.Age){
//            Activity <- "Actif"; 
//        }
//        ask nb_inactive_init among individu where (each.Age<65 and 18<each.Age){
//            Activity <- "Inactif";
//        }
//        ask nb_student_init among individu where (each.Age<65 and 18<each.Age){
//            Activity <- "Etudiant";
//        }
    }
    
    list create_individu(int nb_people_to_create, MiniCity minicity){
    	list<individu> pop_created <- [];
    	list pop_per_ages <- [Age_0_18_rate,Age_18_64_rate,Age_65_rate] collect (each*nb_people_to_create);
//    	write "pop_per_ages = "+ pop_per_ages;
//		list pop_per_ages <- [Age_0_18_rate*nb_people_to_create, Age_18_64_rate*nb_people_to_create, Age_65_rate*nb_people_to_create];
		list activity_per_ages <- ["Scolarise", "Inactif", "Inactif"];
		list age_per_ages <- [[0,18], [18, 64], [65, 100]];
//		write "nb_people = "+nb_people_to_create;
//		write "nb_agent_per_minicity = "+nb_agent_per_minicity;
//		write "active_rate = " +active_rate;
//		write "nb_people_worked_init = " +int(nb_people_to_create*active_rate);
		

		loop ages_id from:0 to:length(pop_per_ages)-1 {
			create individu number: pop_per_ages[ages_id] returns:pop{
				Age <- rnd (int(age_per_ages[ages_id, 0]),int(age_per_ages[ages_id, 1]));
	        	Activity <- activity_per_ages[ages_id]; 
	        	House <- one_of(company) ;
	        	WorkPlace <- one_of(company);
	        	FunZone <- one_of(company);
	            location <- any_location_in (House);
	            objective <- "resting";    
	            speed <- min_speed + rnd (max_speed - min_speed) ;  
	            minicity <- minicity; 
			}
			
			if ages_id = 1 and pop != nil { // 18-64
				// set actif, inactif ou etudiant
				list indexs <- shuffle(range(length(pop)-1)); // supposed to be len(pop_created)
//				write "length(pop) = " + length(pop);
//				write "nb_people_worked_init = " + nb_people_worked_init;
				loop ind_id from:0 to:nb_people_worked_init {
//					write "ind_id="+ind_id;
//					write indexs[ind_id];
					pop[indexs[ind_id]].Activity <- "Actif";
				}
				loop ind_id from:nb_people_worked_init to:nb_people_worked_init+nb_student_init {
					pop[indexs[ind_id]].Activity <- "Etudiant";
				}
			}
			
			add all: pop to: pop_created; // to be tested;
		}
		// add agent if their is less agent generate
		int i <- 0;
		int ages_id;
//		write "length(pop_created) = " + length(pop_created);
//		write "nb_people_to_create = " + nb_people_to_create;
		list diff <- (pop_per_ages collect [pop_per_ages index_of each, each-int(each)] sort -each[1]);
//		write "diff = "+ diff;
		loop while: (length(pop_created) < nb_people_to_create){ // ? -1
//			write "i = "+i;
			ages_id <- diff[i][0];
			create individu returns:pop {
				Age <- rnd (int(age_per_ages[ages_id, 0]),int(age_per_ages[ages_id, 1]));
	        	Activity <- activity_per_ages[ages_id]; 
	        	House <- one_of(company) ;
	        	WorkPlace <- one_of(company);
	        	FunZone <- one_of(company);
	            location <- any_location_in (House);
	            objective <- "resting";    
	            speed <- min_speed + rnd (max_speed - min_speed) ;  
	            minicity <- minicity;
	    	}
	    	add pop[0] to: pop_created; 
	    	i <- (i = 2) ? 0 : i+1;
		}
		
		
		// On met des caractéristiques aux individus parmis ceux déjà crée
		list indexs <- shuffle(range(length(pop_created)-1)); // supposed to be len(pop_created)
//		write "nb_people_to_create = " + (nb_people_to_create-1);
//		write "pop_created = " + pop_created;
//		write "nb_Men_init = " + nb_Men_init;
		loop ind_id from:0 to:nb_Men_init { // setting men
//			write "ind_id="+ind_id;
//			write indexs[ind_id];
			pop_created[indexs[ind_id]].Gender <- "Homme";
		}
		loop ind_id from:nb_Men_init to:length(pop_created)-1 { // rest are women
			pop_created[ind_id].Gender <- "Femme";
		}
		
//		write "length(pop_created) = "+length(pop_created);
		return pop_created;
	}
}

species individu skills:[moving] control: fsm {
	
	float speed ;
    point target;
    int Age;
    string Gender;
    string Activity;
    
    company FunZone <- nil;
    company WorkPlace <- nil;
    company House <- nil;
    
    int proba_become_student;
    int proba_become_active;
    int proba_become_inactive;
    
    int time_to_work ;
	int time_to_sleep;
	int time_to_fun;
	string objective;
    
    float working_time <- 0.0;
    
    MiniCity minicity;
    
	reflex eat when: every(12 #hours){
		// On check si son repas est dispo dans le stock de la ville
		bool meal_available <- true;
		loop plate over: meal {
			if not minicity.askForResources1(string(plate[0]), float(plate[1])){ // name and quantity
				meal_available <- false;
				break;
			}
		}
		// On retire le repas du stock de la ville
		loop plate over: meal {
//			do minicity.getResources with:[resource::string(plate[0]), quantity::float(plate[1])];
			int a <- minicity.getResources1(string(plate[0]), float(plate[1]));
		}
   }
    
    
    reflex move when: target != nil{
	        if (location = target) {
	            target <- nil;
	        } 
	 }
    
    state state1 initial: true { // état d'initialisation
    	//transition to: state_actif when: Activity = "Actif";
    	//transition to: state_inactif when: Activity = "Inactif";
    	//transition to: state_scolarise when: Activity = "Scolarise";
    	//transition to: state_etudiant when: Activity = "Etudiant";
    }
    
    state state_actif { // état actif
    
    	transition to: state_inactif when: Age>=65; // on regarde si l'individu devient retraité
    	transition to: state_inactif when: flip(proba_become_inactive); // on regarde si l'individu perd son emploi
  
    	
	   	if(current_hour > time_to_work and objective = "resting") {
	    	objective <- "working" ;
	    	target <- any_location_in (WorkPlace);
	    }
    
	    if(objective = "working" and target = nil) {
	   		working_time <- working_time + 1;
	   }
	    
	    if(working_time > WorkPlace.time_work and objective = "working"){
	    	if flip(0.5) { // chance d'aller à la Funzone après le travail
	    			   objective <- "fun" ;
			           target <- any_location_in (FunZone);
			     }
			     else{ // l'individu rentre chez soi sinon
			     	objective <- "resting";
			     	target <- any_location_in (House);
			   	}
	    }
	    
	    if(current_hour > time_to_sleep and current_hour < 24){
			objective <- "resting" ;
			target <- any_location_in (House);
	}

}
   
   
	state state_inactif { // état inactif 
    
    	transition to: state_actif when: flip(proba_become_active) and Age<65; // on regarde si l'individu retrouve un travail
    	
    	if(current_hour > time_to_fun and objective = "resting" and flip(0.6)){// l'individu peut soit rester chez lui ou aller à la funzone
	    	objective <- "fun" ;
	    	target <- any_location_in (FunZone);
	    }
	   
	   if(current_hour > time_to_sleep and current_hour < 24) {
			objective <- "resting" ;
			target <- any_location_in (House);
		}
	}
	
    
    state state_scolarise { // état scolarise
    
    	
    	transition to: state_etudiant when: Age>=18 and flip(proba_become_student); // on regarde si l'individu devient étudiant à sa majorité
    	transition to: state_actif when: Age>=18; // si l'individu ne devient pas étudiant alors il devient actif
    	
    	if(current_hour > time_to_work and objective = "resting") {
	    	objective <- "working" ;
	    	target <- any_location_in (WorkPlace);
	    }
    
	    if(objective = "working" and target = nil) {
	   		working_time <- working_time + 1;
	   }
	    
	    if(working_time > WorkPlace.time_work and objective = "working"){
	    	if flip(0.5) { // chance d'aller à la Funzone après le travail
	    			   objective <- "fun" ;
			           target <- any_location_in (FunZone);
			     }
			     else{ // l'individu rentre chez soi sinon
			     	objective <- "resting";
			     	target <- any_location_in (House);
			   	}
	    }
	    
	    if(current_hour > time_to_sleep and current_hour < 24){
			objective <- "resting" ;
			target <- any_location_in (House);
	}
    
}
    
    state state_etudiant { // état étudiant
    
    	transition to: state_actif when: flip(proba_become_active); // on regarde si l'étudiant devient actif
    	transition to: state_inactif when: flip(proba_become_inactive); // on regarde si l'étudiant devient inactif
    	
    	if(current_hour > time_to_work and objective = "resting") {
	    	objective <- "working" ;
	    	target <- any_location_in (WorkPlace);
	    }
    
	    if(objective = "working" and target = nil) {
	   		working_time <- working_time + 1;
	   }
	    
	    if(working_time > WorkPlace.time_work and objective = "working"){
	    	if flip(0.5) { // chance d'aller à la Funzone après le travail
	    			   objective <- "fun" ;
			           target <- any_location_in (FunZone);
			     }
			     else{ // l'individu rentre chez soi sinon
			     	objective <- "resting";
			     	target <- any_location_in (House);
			   	}
	    }
	    
	    if(current_hour > time_to_sleep and current_hour < 24){
			objective <- "resting" ;
			target <- any_location_in (House);
		}
    }       
}

species company {
	
	int start_work <- rnd (min_work_start, max_work_start);
    int end_work <- rnd(min_work_end, max_work_end);
	int time_work <- end_work - start_work ;
	
   
}