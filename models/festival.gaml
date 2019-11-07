/***
* Name: festival
* Author: Md Rezaul Hasan
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model festival

/* Insert your model definition here */
global{
	int nb_Guests_init <- 20;
	int nb_Stores_init <- 5;
	int nb_InformationCenter_init <- 1;
	float Guests_max_energy <- 1.0;
	float Guests_max_transfer <- 0.1;
	float Guests_energy_consum <- 0.05;
	
	init {
		create Guests number: nb_Guests_init ;
		create Stores number: nb_Stores_init ;
		create InformationCenter number: nb_InformationCenter_init ;
	}
}

species Guests{
	float size <-1.0;
	rgb color <- #orange;
	float max_energy <- Guests_max_energy ;
   	float max_transfer <- Guests_max_transfer ;
   	float energy_consum <- Guests_energy_consum ;
	field myCell <- one_of (field) ;
	food foodCell <- one_of (food) ;
	float energy <- rnd(max_energy) update: energy - energy_consum max: max_energy ;
	init {
		location <- myCell.location;
	}
		
	reflex basic_move{
		myCell <- one_of (myCell.neighbours) ;
		location <- myCell.location ;
	}
	reflex eat when: foodCell.food_eat >= 0 { 
	    float energy_transfer <- min([max_transfer, foodCell.food_eat]) ;
	    foodCell.food_eat <- foodCell.food_eat - energy_transfer ;
	    energy <- energy + energy_transfer ;
    }
    aspect Guests_base {
		draw circle(size) color: color ;
	}
} 
species Stores{
	float size <-10.0;
	rgb color <- #yellow;
	aspect Stores_base {
		draw triangle(size) color: color ;
	}
	
}
species InformationCenter{
	float size <-20.0;
	rgb color <- #red;
	aspect InformationCenter_base {
		draw square(size) color: color ;
	}
	
}
grid field width: 50 height: 50 neighbors: 4 {
	list<field> neighbours  <- (self neighbors_at 2); 
}

grid food width: 50 height: 50 neighbors: 4 {
	 float max_food <- 1.0 ;
	float food_prod <- rnd(0.01) ;
	float food_eat <- rnd(1.0) max: max_food update: food_eat + food_prod ;
	list<food> neighbours  <- (self neighbors_at 2); 
}

experiment prey_predator type: gui {
	parameter "Initial number of preys: " var: nb_Guests_init min: 1 max: 1000 category: "Prey" ;
	output {
		display main_display {
			grid field lines: #black ;
			species Guests aspect: Guests_base;
			species Stores aspect: Stores_base;
			species InformationCenter aspect: InformationCenter_base;
		}
	}
}
