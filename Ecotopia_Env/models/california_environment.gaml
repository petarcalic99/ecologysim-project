/**
* Base environment with :
*  - california fronteers, 
*  - principal reliefs (mountains),
*  - principal rivers,
*  - limits of the desert and forests,
*  - principal cities, 
*  - major hydroelectric plants,
*  - major geothermal plants,
*  - nuclear plant.
* All data are for 2019.
* Name: california_environment
* Author: Maël Franceschetti
* Tags: california, map
*/


model california_environment

global {
    file shape_file_fronteers <- file("../includes/california_fronteers.shp");
    file shape_file_cities <- file("../includes/california_cities.shp");
    file shape_file_geothermal <- file("../includes/california_geothermal.shp");
    file shape_file_nuclear <- file("../includes/california_nuclear.shp");
    file shape_file_hydroelec <- file("../includes/california_major_hydro.shp");
    file shape_file_forests <- file("../includes/california_forests.shp");
	file shape_file_desert <- file("../includes/california_desert.shp");
	file shape_file_mountains <- file("../includes/california_2000m_mountains.shp");
	file shape_file_rivers <- file("../includes/california_rivers.shp");
	
    geometry shape <- envelope(shape_file_fronteers);
    
    init {
    	create mountains from: shape_file_mountains;
    	create forest from: shape_file_forests;
    	create desert from: shape_file_desert;
    	create geothermal from: shape_file_geothermal;
    	create nuclear from: shape_file_nuclear;
    	create hydroelectric from: shape_file_hydroelec;
    	create river from: shape_file_rivers;
    }
    
    /* 
     * Return the nearest point of geom from the given point ag
     */
    point get_nearest_intersect(point ag, geometry geom){
    	list<point> dest <- closest_points_with(ag, geom);
    	return (dest at 1);
    }
    
    // how to do a function
    int create_cities {
    	create city from: shape_file_cities with: [name:: read('NAME')] returns:cities;
    	return length(cities);
    }
}



species river{
	rgb color <- #blue;
	aspect base{
		draw shape color: color;
	}
}

species mountains{
	rgb color <- #gray ;
	aspect base {
		draw shape color: color ;
	}
}

species forest{
	string name;
	rgb color <- #green ;
	aspect base {
    	draw shape color: color ;
    }
}

species desert{
	rgb color <- #orange ;
	aspect base {
    	draw shape color: color ;
    }
}

species city  {
	string name;
    rgb color <- #black ;
    aspect base {
    	draw circle(3#px) color: color ;
    }
}

species geothermal  {
    rgb color <- #purple ;
    aspect base {
    	draw square(4#px) color: color;
    }
}

species hydroelectric {
	rgb color <- #blue;
	aspect base {
    	draw square(4#px) color: color;
    }
}

species nuclear  {
    rgb color <- #red ;
    aspect base {
    	draw square(4#px) color: color;
    }
}


experiment california_env type: gui {        
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
	    }
    }
}
