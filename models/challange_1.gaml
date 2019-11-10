/***
* Name: challange1
* Author: Md Rezaul Hasan
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model challange1

/* Insert your model definition here */

global{
	init{
	// Make sure we get consistent behaviour
		seed<-10.0;		
		time<-0.0;
		create Guests number: 10
		{
			location <- {rnd(90),rnd(90)};
		}
		
		bool drinkStores <- true;

		create Stores number: 2
		{
			
			if (drinkStores){
				location <- {90, 10};
				hasDrinks <- true;
				hasFood <- false;
				myColor <- #purple;				
			}else{
				location <- {10, 90};
				hasDrinks <- false;
				hasFood <- true;
				myColor <- #green;
				
			}			
			drinkStores <- not drinkStores;
			
		}
		create Stores number: 2
		{
			
			if (drinkStores){
				location <- {10,10};
				hasDrinks <- true;
				hasFood <- false;
				myColor <- #purple;				
			}else{
				location <- {90, 90};
				hasDrinks <- false;
				hasFood <- true;
				myColor <- #green;
				
			}			
			drinkStores <- not drinkStores;
			
		}
		
		
		create InformationCenter number: 1
		{
			location <- {50,50};
		}
	}
}

species Guests skills: [moving] {
	rgb myColor <- #red;
	int hungerAndThirst <- 400;
	
	float totalDistance <- 0.0;
	
	Stores targetStores;
	point targetPoint;
	bool memory <- false;
	int waterLevel <- rnd(hungerAndThirst);
	int foodLevel <- rnd(hungerAndThirst);
	list<Stores> memoryForDrink;
	list<Stores> memoryForfood;
	
	reflex beIdle when:  waterLevel > 0 and foodLevel > 0 and targetStores = nil and targetPoint = nil
	{
		myColor <- #red;
		do wander;
	}
	
	reflex movingTarget when: targetStores != nil
	{
		do goto target:targetStores;
		ask Stores at_distance 2 {
			if (self.hasDrinks) {
				myself.waterLevel <- myself.hungerAndThirst;
			}
			if (self.hasFood) {
				myself.foodLevel <- myself.hungerAndThirst;
			}
			myself.memory <- flip(0.5);
		}
		
		if (waterLevel > 0 and foodLevel > 0) {
			targetStores <- nil;
			targetPoint <- {rnd(100), rnd(100)};
		}
		
		totalDistance <- totalDistance + location distance_to destination;
	}
	
	reflex movingFordance when: waterLevel > 0 and foodLevel > 0 and targetStores = nil and targetPoint != nil
	{
		myColor <- #red;
		do goto target:targetPoint; 
	}
	
	reflex enterDanceMode when: waterLevel > 0 and foodLevel > 0 and targetStores = nil and targetPoint != nil
	{
		if (location distance_to (targetPoint) < 2)
		{
			targetPoint <- nil;
		}	
	}
	
	reflex inquire_resource_location_mem when: (waterLevel <= 0 or foodLevel <= 0) and (targetStores = nil) and memory
	{
		// Do an internal lookup operation. Abort if it is not possible.
		if (waterLevel <= 0)
		{
			if length(memoryForDrink) > 0 {
				targetStores <- first(1 among memoryForDrink);
				myColor <- #blue;	
				write "" + self + " is going to drink.";
			} else {
				memory <- false;
				write "" + self + " could have gone directly to drink.";
			}
			
		} else if (foodLevel <= 0)
		{
			if length(memoryForfood) > 0 {
				targetStores <- first(1 among memoryForfood);	
				myColor <- #blue;
				write "" + self + " is going to eat.";
			} else {
				memory <- false;
				write "" + self + " could have gone directly to food.";
			}
		}
		
	}
	
	// Make sure the agent will do something when it gets thirsty
	reflex goingToInformationcenter when: (waterLevel <= 0 or foodLevel <= 0) and (targetStores = nil) and not memory
	{		
		myColor <- #yellow;
		
		do goto target:{50,50};
		ask InformationCenter at_distance 2 {
			if(myself.waterLevel <= 0) {
				int count <- length(self.waterStores);
				int index <- rnd(count - 1);
				
				myself.targetStores <- self.waterStores[index];
				myself.myColor <- #purple;
				
				remove all: myself.targetStores from: myself.memoryForDrink;
				add myself.targetStores to: myself.memoryForDrink;
			} else if (myself.foodLevel <= 0) {
				int count <- length(self.foodStores);
				int index <- rnd(count - 1);
				
				myself.targetStores <- self.foodStores[index];
				myself.myColor <- #green;
				
				remove all: myself.targetStores from: myself.memoryForfood;
				add myself.targetStores to: myself.memoryForfood;
			}

			//write self.foodStores;
			//write self.waterStores;
		}
		
		totalDistance <- totalDistance + location distance_to destination;
	}
	
	// make more thirsty or hungry
	reflex reserveEnergy when: waterLevel > 0 and foodLevel > 0
	{
		// More hunger
		if (flip(0.5)) {
			foodLevel <- foodLevel - 1;
		// More thirst
		} else {
			waterLevel <- waterLevel - 1;
		}
	}
		
	aspect default{
		draw pyramid(3) at: {location.x, location.y, 0} color: myColor;
    	draw sphere(1.5) at: {location.x, location.y, 3} color: myColor;
    }
}

species Stores{
	rgb myColor <- #blue;
	bool hasDrinks <- false;
	bool hasFood <- false;
	
	aspect default{
		draw cube(8) at:location color: myColor ;
    }
	
}
species InformationCenter{
	rgb myColor <- #yellow;
	
	list<Stores> waterStores;
	list<Stores> foodStores;
	
	init {
		ask Stores {
			if (self.hasDrinks) {
				myself.waterStores << self;
			}
			if (self.hasFood) {
				myself.foodStores << self;
			}
		}
	}
	
	aspect default{
		draw pyramid(15) at: location color: myColor ;
    }
}


experiment main type: gui {
	output {
		display map type: opengl 
		{
			species Guests;
			species Stores;
			species InformationCenter;
		}
	}
}
