$fn=20;
//electronics();
//translate([0,0,-25.5])rotate([-11.31,0,0])goggles();
fullcase();

module goggles(){
  color("white")translate([-50,-19,0])hull(){
    cube([100,0.1,20]);
    translate([0,25,5])cube([100,0.1,20]);
    translate([0,30,-1])cube([100,0.1,20]);
  }
}

module fullcase(){
  difference(){
  translate([0,0,1])difference(){
    union(){
      difference(){
        case(0);
        translate([0,0,-0.1])case(0.8); // make a bit thicker top wall
      }
      intersection(){
        case(0);
        union(){
          hull(){
            translate([26,12,0])cylinder(d=5,h=14,center=true);
            translate([26,-14,0])cylinder(d=5,h=14,center=true);
          }
          hull(){
            translate([-22,12,0])cylinder(d=5,h=14,center=true);
            translate([-22,-14,0])cylinder(d=5,h=14,center=true);
          }
        }
      }
      support();
    }
    // mounting holes
    hull(){
      translate([26,7,-2.2])cylinder(d1=3.5,d2=4,h=10);
      translate([26,-10,-2.2])cylinder(d1=3.5,d2=4,h=10);
      translate([30,7,-2.2])cylinder(d1=3.5,d2=4,h=10);
      translate([30,-10,-2.2])cylinder(d1=3.5,d2=4,h=10);
    }
      translate([26,7,0])cylinder(d=1.5,h=10,center=true);
      translate([26,-10,0])cylinder(d=1.5,h=10,center=true);
    hull(){
      translate([-22,9,-2.2])cylinder(d1=3.5,d2=4,h=10);
      translate([-22,-10,-2.2])cylinder(d1=3.5,d2=4,h=10);
      translate([-25,9,-2.2])cylinder(d1=3.5,d2=4,h=10);
      translate([-25,-10,-2.2])cylinder(d1=3.5,d2=4,h=10);
    }
      translate([-22,7,0])cylinder(d=1.5,h=10,center=true);
      translate([-22,-10,0])cylinder(d=1.5,h=10,center=true);

    // sdcard slot
    translate([-20,4.5,0.8])cube([10,12,2.2],center=true);
    
    //translate([0,0,-8.5])cube([100,100,10],center=true);
    //translate([-5,-20,-10])cube([100,100,20]);
  }
    //electronics();
    translate([-38/2+4/2+3,-25/2+4/2+0.9,0]){
      hull(){
        cylinder(d=4.1,h=10); //button
        translate([-4.1/2,5,0])cube([4.1,4,10]);
      }
      translate([7.5,0,0])hull(){
        cylinder(d=4.1,h=10); //button
        translate([-4.1/2,5,0])cube([4.1,4,10]);
      }
      translate([7.5*2,0,0])hull(){
        cylinder(d=4.1,h=10); //button
        translate([-4.1/2,5,0])cube([4.1,4,10]);
      }
    }
    translate([0,0,-25.5])rotate([-11.31,0,0])goggles();
    
    //***** ventilation
    for (i = [0 : 7 : 30] ){
      translate([i-13,8,5])cube([1.5,9,2], center=true);
    }
    /*
    // screw holes
    translate([38/2-7,-25/2+2,0])cylinder(d=1.5,h=5,$fn=20);
    translate([38/2-15.5,25/2-2,0])cylinder(d=1.5,h=5,$fn=20);
    */
    translate([-(20/2+24),0,0])cube([20,100,50],center=true);
    translate([(20/2+28),0,0])cube([20,100,50],center=true);
  }
  // PCB tabs
  //down
  translate([16,12.3,1.2+0.3])cube([3,1,2],center=true);
  translate([-14,12.3,1.2+0.3])cube([3,1,2],center=true);
  translate([19.7+0.5,12.3,-0.6])cube([2,1,2],center=true);
  //side
  hull(){
    translate([-19.1,-9,1.2+0.3])cube([1,3,2],center=true);
    translate([-19.6,-8,1.2+0.3])cube([0.1,3,2],center=true);
  }
  //***** buttons
  translate([-38/2+4/2+3,-25/2+4/2+1,5]){
    button();
    translate([7.5,0,0])button();
    translate([7.5*2,0,0])button();
  }
}


module support(){
  translate([2,-13.2,-2.5])cube([50,0.7,2],center=true);
  
  translate([2,-13.04,-0.1])cube([9,0.8,10],center=true);
/*
  hull(){
  translate([2+9/2,-13.04,-0.1])cube([0.3,0.8,7.8],center=true);
  translate([2+9/2,13,-1+1])cube([0.3,0.8,7],center=true);
  }
  hull(){
  translate([2-9/2,-13.04,-0.1])cube([0.3,0.8,7.8],center=true);
  translate([2-9/2,13,-1+1])cube([0.3,0.8,7],center=true);
  }
  
  hull(){
  translate([-6.6-3.85,-13.04,1.8])cube([0.3,0.8,4.1],center=true);
  translate([-6.6-4,13,0])cube([0.3,0.8,7],center=true);
  }
 */
  translate([-6.6,-12.6,2])cube([8,1.5,4.9],center=true);
}


module button(){
  hull(){
    cylinder(d=3.1,h=1.7); //button
    translate([-3.1/2,5.5,0])cube([3.1,4,1]);
  }
  translate([0,-0.5,-2.7])cylinder(d=2,h=2.7);
  
/*  hull(){
  translate([0,0,-2.7])cylinder(d=2.5,h=2.7);
  translate([0,4,0])cylinder(d=2,h=0.1);
  }*/
}

module case(wall){
  hull(){
    rotate([90,0,0]){
      translate([-16,0,3/2])cylinder(d=10-wall*2, h=27-3-wall*2,center=true,$fn=50);
      translate([19,0,3/2])cylinder(d=10-wall*2, h=27-3-wall*2,center=true,$fn=50);
      
      translate([-16,0,-(27-3-wall)/2])cylinder(d2=10-wall*2,d1=7-wall, h=3-wall,center=true,$fn=50);
      translate([19,0,-(27-3-wall)/2])cylinder(d2=10-wall*2,d1=7-wall, h=3-wall,center=true,$fn=50);
    }
    translate([2.5,-0.5,-7])cube([60-wall*2,28-wall*2,0.5],center=true);
  }
}

module electronics(){
  difference(){
    union(){
      DVRpcb();
      translate([13.5,-1,0])MYpcb();
    }
    translate([38/2-7,-25/2+2,0])cylinder(d=2,h=10,$fn=20,center=true);
    translate([38/2-7,-25/2+2,-3-0.5])cylinder(d=4,h=3,$fn=20);
    translate([38/2-15.5,25/2-2,0])cylinder(d=2,h=10,$fn=20,center=true);
    translate([38/2-15.5,25/2-2,-3-0.5])cylinder(d=4,h=3,$fn=20);
  }
}

module DVRpcb(){
  color("blue")cube([38,25,1], center=true); // pcb
  color("black")translate([0,0,-(0.5+1.5/2)])cube([36,23,1.5], center=true); // components
  color("lightgray")translate([38/2-1.5,0,(0.5+3/2)])cube([7,24,3], center=true); // connectors
  color("gray")translate([-38/2+15/2+1,25/2-15/2-2,(0.5+2/2)])cube([15,15,2], center=true); // cardreader
  color("black")translate([-38/2+10/2-2,25/2-10/2-3,(0.5+2/2)+0.4])cube([10,10,1], center=true); // sdcard
  
  translate([-38/2+4/2+3,-25/2+2.5/2+1,(0.5+1.5/2)]){
    color("gray")cube([4,2.5,1.5],center=true); //button
    color("black")cylinder(d=1.5,h=1,$fn=10);
  }
  translate([-38/2+4/2+3+7.5,-25/2+2.5/2+1,(0.5+1.5/2)]){
    color("gray")cube([4,2.5,1.5],center=true); //button
    color("black")cylinder(d=1.5,h=1,$fn=10);
  }
  translate([-38/2+4/2+3+7.5+7.5,-25/2+2.5/2+1,(0.5+1.5/2)]){
    color("gray")cube([4,2.5,1.5],center=true); //button
    color("black")cylinder(d=1.5,h=1,$fn=10);
  }
}

module MYpcb(){
  color("purple")translate([-38/2+15/2+1,25/2-15/2-2,(0.5+0.8/2)+2])cube([14,21,0.8], center=true); // cardreader
  color("purple")translate([-38/2+15/2+3.25+4,25/2-15/2-2.25-3.5,(0.5+0.8/2)+2])cube([9.5,21.5,0.8], center=true); // cardreader
  color("black")translate([-10,0,(0.5+1.8/2)+2.8])cube([6,6,1.8], center=true); // cardreader
  
}
