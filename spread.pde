import java.util.*;
final int fps = 60;//fps the game runs at
final int wWidth = 500, wHeight = 500; //change size here too

//time before mouse down is a hold
//if released before this time is up, it counts as a click
final float mouseClickTime = 0.1;
final float keyPressTime = 0.2;

//vars for FOR loops
int i,j,x,y;

//chars to detect when pressed
final char startchar = 32; //spacebar
final char endchar = 126; //tilde

final color defaultcolor = color(255, 255, 255);
void setup() {
  size(500, 500);//500(width)x500(height) grid
  frameRate(fps);
  background(allStates[0].c);
  for (char k=startchar; k<=endchar; k++) {
    allKeys[c2i(k)] = new Key(k+"", 'k'); //+"" to make k into a string
  }
  color c = color(255, 255, 255);
  System.out.println(c);
}

//grid of pixels before putting in system array, pixels[]
color[][] pixelGrid = new color[wWidth][wHeight];


// state a cell can be in
public class State {
  public String name;
  public color c;
  public State(int col, String n) {
    c = col;
    name = n;
  }
  public State(int col) {
    this(col, "");
  }
  public State() {
    this(color(255, 255, 255));
  }
};

//all states a Cell can be in
final State[] allStates= {
  new State(color(255, 255, 255), "clean"), //clean
  new State(color(255, 0, 0), "1st time infected"), //infected last frame
  new State(color(255, 0, 0), "infected"), //infected before last frame
};


//class to represent a living Cell
public class Cell {
  public int value;
  public int influence; //circle of influence around a cell, namely infective power
  public Cell(int v) {
    value = v;
  }
  public Cell() {
    this(0);
  }
  public void update(){
    if(value==1){
      value=2;
    }
  }
  public boolean isInfected(){
    return value==2;
  }
  public void infect(){
    value=1;
  }
  public void disInfect(){
    value=0;
  }
  public State getState() {
    return allStates[value];
  }
  public String getName() {
    return allStates[value].name;
  }
  public color getColor() {
    return allStates[value].c;
  }
};



//class to contain many Cell objects
final int numAdj=4;
public class Culture{
  public Cell[][] grid;
  public int w, h;
  Culture(int w, int h){
     this.w = w;
     this.h = h;
     grid = new Cell[w][h];
     int a = 0;
     for(j=0;j<w;j++){
       for(i=0;i<h;i++){
         //print("Cell ", j*w+i, '\n');
         grid[i][j] = new Cell();
         a++;
       }
     }
     print("Cells: ", j*w+i, '\n');
  }
  Culture(){
     this(wWidth,wHeight);
  }
  public ArrayList<Integer> getAdj(int i, int j){
    ArrayList<Integer> adj = new ArrayList<Integer>();
    int filled=0;
    int[] selfcoord = {i,j};
    if(j-1>=0){
      adj.add(i);//todo finish esto
      adj.add(j-1);
    }
    if(j+1<500){
      adj.add(i);
      adj.add(j+1);
    }
    if(i-1>=0){
      adj.add(i-1);
      adj.add(j);
    }
    if(i+1<500){
      adj.add(i+1);
      adj.add(j);
    }
    return adj;
  }
  void infectAll(List<Integer> cellCoords){
    int[] selfcoord = {i,j};
    //print("infecting [",i,"][",j,"]\n");
    int coordlen = cellCoords.size();
    for(i=0, j=1;j<coordlen;i+=2, j+=2){//2 ints per coord
      x = cellCoords.get(i);
      y = cellCoords.get(j);
      grid[x][y].infect();
    } 
  }
      
    //if(j-1>=0){
    //  grid[i][j-1].infect();
    //}
    //if(j+1<500){
    //  grid[i][j+1].infect();
    //}
    //if(i-1>=0){
    //  grid[i-1][j].infect();
    //}
    //if(i+1<500){
    //  grid[i+1][j].infect();
    //}   
    
    
  //for every infected cell, it spreads the infection to the adjacent cells
  void spread(){
    List<Integer> adj=new ArrayList<Integer>();
    List<Integer> tmpadj=new ArrayList<Integer>();
    for(j=0;j<h;j++){
      for(i=0;i<w;i++){
        if(grid[i][j].isInfected()){
            adj.addAll(getAdj(i,j));
        }
      }
    }
    //print("spreading\n");
    //for(i=0, j=1;j<adj.size();i+=2, j+=2){
    //  print("[",adj.get(i),"][",adj.get(j),"]\n");
    //}
    infectAll(adj);
  }
  void update(){
    for(j=0;j<h;j++){
      for(i=0;i<w;i++){
        grid[i][j].update();
      }
    }
    //print("updated to ", grid[mouseX][mouseY].value, "\n");
  }
  void clear(){
     for(j=0;j<w;j++){
       for(i=0;i<h;i++){
         grid[i][j].disInfect();
       }
     }
  }
  public void display(){
    loadPixels();
    for(j=0;j<h;j++){
      for(i=0;i<w;i++){
        pixelGrid[i][j] = allStates[grid[i][j].value].c;
        pixels[coordTo1d(i, j)] = pixelGrid[i][j];
      }
    }
    updatePixels();
  }
  
  
};

//class used to store keystrokes, for up to 1 second
public class Key {
  public LinkedList<Boolean> pressed; //record 1 second of data per key
  public String key;
  public int time; //in seconds, max 1 second
  public float holdThreshold;
  public Key(String assoc, char MorKB){ //m for mouse button, k for key
    if(MorKB=='m')
      holdThreshold = mouseClickTime;
    else if(MorKB=='k')
      holdThreshold = keyPressTime;
    key = assoc;
    pressed = new LinkedList<Boolean>();
    for(int i=0;i<fps;i++){
      pressed.offerFirst(false);
    }
    
  }
  public Key(String assoc) {
    this(assoc, 'k'); 
  }
  public Key() {
    this("");
  }
  public double pressedFor() {
    return pressedFor(0);
  }
  public double pressedFor(int start) {
    int i=start;
    for(;i<fps&&pressed.get(i);i++);
    double a = i-start;
    return a/fps;
  }
  public boolean holding() {
    return this.pressedFor()>holdThreshold;
  }
  public boolean clicking() {
    double timePressed = this.pressedFor(1);
    //System.out.println(timepressed);
    //System.out.println(timepressed>0);
    return timePressed<=holdThreshold && timePressed>0.0 && !this.pressed.getFirst();
  }
  public void update(boolean p) {
    pressed.offerFirst(p);
    pressed.removeLast();
  }
}



//instance of culture, used in game
Culture culture = new Culture(wWidth, wHeight);


//convert 2d coordinates to 1d system pixels[] array
int coordTo1d(int x, int y) {
  return y*width+x; //y rows down + x columns in
}

Key[] allKeys = new Key[endchar-startchar+1];
Key mouseLeft = new Key("mouseLeft", 'm');
Key mouseRight = new Key("mouseRight", 'm');
Key mouseMiddle = new Key("mouseMiddle", 'm');

//converts ascii char TO a usable Index
int c2i(char c) {
  return c-32;
}

//converts ascii char TO a Key in allKeys
Key c2k(char c) {
  return allKeys[c2i(c)];
}
void updateMouseKbState(){
  if(mousePressed){
    mouseLeft.update(mouseButton==LEFT);
    mouseRight.update(mouseButton==RIGHT);
  }else{
    mouseLeft.update(false);
    mouseRight.update(false);
  }
  for (char c=startchar; c<=endchar; c++) {
    allKeys[c2i(c)].update(c2k(c).pressed.get(0)); //continue whether it was last detected as pressed or released
  }
}
void spamState(char c){
  String b="";
  int t = 0;
  for(i=fps-1;i>=0;i--){
    int x = int(c2k(c).pressed.get(i));
    b+=x;
    t+=x;
  }
  print("clicking: ", b, t, mouseLeft.clicking(), "\n");
  
}
boolean inBounds(int n, char type){ //type is 'x' or 'y' depending on if it is an x or y coord
  boolean isIn = false;
  if(type=='x')
    isIn = n>=0 && n<wWidth;
  else if(type=='y')
    isIn = n>=0 && n<wHeight;
  return isIn;
}
void draw() {
  color[] rgb = new color[3];
  rgb[0] = color(255,0,0);
  rgb[1] = color(0,255,0);
  rgb[2] = color(0,0,255);
  if(mouseLeft.clicking()){
    if(inBounds(mouseX, 'x') && inBounds(mouseY, 'y')){
      if(!culture.grid[mouseX][mouseY].isInfected()){
        culture.grid[mouseX][mouseY].infect();
      }
    }
  }
  
  //spamState('e');
  //press 'e' to infect cells adjacent to current infected cells
  if(c2k('e').clicking()){
    //print("clicking e\n");
    culture.spread();
  }
  //spamState('r')
  //press 'r' to 'r'eset the culture of cells
  if(c2k('r').clicking()){
    //print("clicking r\n");
    culture.clear();
  }  
  
  culture.display();
  culture.update();
  updateMouseKbState();
  
  //if(mouseLeft.clicking()){
  //   saveFrame("C:\\Users\\Dino\\Documents\\Processing\\spread\\frames\\frame###.png"); 
  //   background(0);
  //}
  
  //TEST DEBUG COMMENTS
  
  
  //Cell bob = new Cell();
  //print(bob.value);
  //print('\n');
  
  //print(mouseX, mouseY);
  //print('\n');
  //print("Value:");
  //print(culture.grid[mouseX][mouseY].value);
  //print('\n');
  
  
  //print(a*60, '\n');
  //if(mouseLeft.clicking()){
  //  background(0); 
  //}else if(mouseLeft.holding()){
  //  background(255);
  //}
  
  
  //if (mouseLeft.holding()) {
  //  background(allStates[1].c);
  //}else{
  //  background(allStates[0].c);
  //}
  
  
  //loadPixels();
  //for(int i=0;i<width*height;i++){
  //  pixels[i] = rgb[i%3];
  //}
  //updatePixels();
  
  
  //double a = mouseLeft.pressedFor();
}



void keyPressed() {
  //print(" pressed ", key, "");
  i = c2i(key);
  if(i>=startchar && i<=endchar){
    allKeys[i].update(true);
  }
  //the key(stored in key) is currently pressed
}

void keyReleased() {
  //print(" released ", key, "");
  i = c2i(key);
  if(i>=startchar && i<=endchar){
    allKeys[i].update(false);
  }
  //the key(stored in key) is currently pressed
}
