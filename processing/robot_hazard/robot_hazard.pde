import processing.serial.*;

Tychoscope t;
//PImage chicken;
//Image which will be displayed at the 2 extrem corners
//One pleasant to look and one very unpleasant
PImage good_image;
PImage bad_image;
PFont f;
PrintWriter output;
Rng rng;
int start_time;
int last_time;
//Total amount of ms when the robot generate number
//Should be substract to the total time
int generating_num_time;
boolean experiment_ended = false;
//in milliseconds
final int EXPERIMENT_DURATION = 20*60*1000;
final int NB_EXPERIMENTS = 30;
//the board dimensions in cm
final int BOARD_WIDTH = 88;
final int BOARD_HEIGHT = 59;
//Will be usefull to save logs and traces
int experiment_num = 0;
int current_xp_num = 0;
boolean first_setup = true;
//Size of a centimeter in pixel
int cm_px;
final boolean HIDE_ROBOT = false;
void setup(){
  //The size of the window must have the same ratio as in the poec'h experiment
  //which is 88/59
  boolean width_over_height = BOARD_WIDTH/BOARD_HEIGHT > screen.width/screen.height;
  int size_x, size_y;
  if(width_over_height){
    size_x = screen.width;
    size_y = int(float(size_x) * float(BOARD_HEIGHT)/float(BOARD_WIDTH));
    cm_px = screen.width / BOARD_WIDTH;
  }
  else{
    size_y = screen.height;
    size_x = int(float(size_y) * float(BOARD_WIDTH)/float(BOARD_HEIGHT));
    cm_px = screen.height / BOARD_HEIGHT;
  }
  size(size_x, size_y);
  f = createFont("Arial", 20, true);
  t = new Tychoscope();
  /*chicken = loadImage("baby_chicken.jpg");
  chicken.resize(30, 30);*/
  
  /*good_image = loadImage("forest.jpg");
  bad_image = loadImage("brain.jpg");*/
  
  if(first_setup){
    // Using the first available port (might be different on your computer)
    Serial port = new Serial(this, Serial.list()[0], /*115200*/19200);
    first_setup = false;
  }
  
  //rng = new Rng(50, 100);
  rng = new Rng(1000, 1);
  rng.start_homogeneity_test();
  String log_name = find_log_name("robot_hazard.csv");
  output = createWriter(log_name);
  println("log will be store at : " + log_name);
  //Write csv header
  output.println("sample,angle,clockwise?,forward?,distance");
  //Needed to stop automatically the experiment
  start_time = millis();
  last_time = start_time;
  generating_num_time = 0;
  
  experiment_ended = false;
  
  current_xp_num++;
}

//Find an available log name
//The first time, find the experiment number
//And then reuse it for all the others files
//This all the files has the same number (except if it already exists)
String find_log_name(String name){
  String filename = dataPath(experiment_num+"_"+name);
  File file = new File(filename);
  while (file.exists())
  {
    experiment_num++;
    filename = dataPath(experiment_num+"_"+name);
    file = new File(filename);
  }
  
  return filename;
}

void draw(){
  background (255);
  int current_time = millis();
  int delta = current_time - last_time;
  last_time = current_time;
  if(last_time - start_time >= EXPERIMENT_DURATION + generating_num_time){
    experiment_ended = true;
  }
  
  //Don't display anything if experiment ended
  //In order to be able to shoot the lines
  if(!experiment_ended){
    if(!rng.is_ready()){      
      textFont(f,20);
      fill(0);
      textAlign(CENTER, CENTER);
      text("Generating random numbers pool... ", width/2, height/2);
      //This time is not part of the experiment
      generating_num_time += delta;
    }
    else{
      /*
      //Test de l'affichage de noms a forte conotation
      textAlign(LEFT);
      textFont(f,20);
      fill(0);      
      text("Gandhi", 10, height - 10);
      textAlign(RIGHT);
      text("Hitler", width - 10, 20);
      */
      //image(chicken, 0, 0);
      
      //Test de l'affichage d'image à forte conotation
      /*image(good_image, 0, 0, screen.width / 2, screen.height / 2);
      image(bad_image, screen.width / 2, screen.height / 2, screen.width / 2, screen.height / 2);*/
    }
  }
  
  t.display();
  
  if(experiment_ended){
    finish_experiment();
  }
}

void finish_experiment(){
  println("Closing application...");
  String img_name = find_log_name("robot_hazard.tif");
  println("Save robot traces to : " + img_name);
  save(img_name); //Write the robot trace to a file
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  rng.write_homogeneity_test_data();
  //We can automatically launch sevral experiments
  if(current_xp_num == NB_EXPERIMENTS){
    exit(); // Stops the program
  }
  else{
    //Restart an experiment
    setup();
  }
}

void keyPressed(){
  if(key == ESC){
    experiment_ended = true;
    //overriding escape behaviour
    key = 0;
  }
}
// Called whenever there is something available to read
void serialEvent(Serial port) {
  rng.number_recieved(port.read());
}
