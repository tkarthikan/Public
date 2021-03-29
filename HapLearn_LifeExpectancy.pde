/**
 * This example was motivated by the following posts:
 * 
 * http://lisacharlotterost.github.io/2016/05/17/one-chart-tools/
 * http://lisacharlotterost.github.io/2016/05/17/one-chart-code/
 */

import grafica.*;

GPlot plot;

import processing.serial.*;
  Serial port;
  
String [] countries = {};
float [] literacyrate = {};
float persinc = 0;
String selcon = "";

String vib_cmd="";
int onoff = 0;    // Keep vibrator OFF (0) or ON (1)
int inten1 = 0;   // Starting intensity for a sweep (0-255)
int inten2 = 0;   // Ending intensity for a sweep (0-255)
int sweeptime_ms = 0;   //Time for each step in ms
int repeatsweep = 0;    // no of times you want to repeat sweep within one cycle
int pulse_time_ms = 0;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
int rest_ms = 0;     // The No actuating time or resting in ms before starting next cycle
float barH = 0;

void setup() {
  // Define the window size
  size(750, 410);
  
  println("Available serial ports:");
  println(Serial.list());
  port = new Serial(this, Serial.list()[1], 9600);
  port.bufferUntil ( '\n' ); 

  // Load the cvs dataset. 
  // The file has the following format: 
  // country,income,health,population
  // Central African Republic,599,53.8,4900274
  // ...
  Table table = loadTable("data.csv", "header");

  // Save the data in one GPointsArray and calculate the point sizes
  GPointsArray points = new GPointsArray();
  float[] pointSizes = new float[table.getRowCount()];
  countries = new String[table.getRowCount()];
  literacyrate = new float[table.getRowCount()];
  //persinc = new float[table.getRowCount()];
  float inctotal = 0;
  
  for (int row = 0; row < table.getRowCount(); row++) {
    String country = table.getString(row, "country");
    float income = table.getFloat(row, "income");
    float health = table.getFloat(row, "health");
    int population = table.getInt(row, "population");
    float lr = table.getFloat(row, "literacyrate");
    points.add(income, health, country);
    countries[row] = country;
    literacyrate[row] = lr; 
    inctotal = inctotal + income;
    
    // The point area should be proportional to the country population
    // population = pi * sq(diameter/2) 
    pointSizes[row] = 2 * sqrt(population/(200000 * PI));
  }
  
  persinc = inctotal / table.getFloat(row, "income");

  // Create the plot
  plot = new GPlot(this);
  plot.setDim(650, 300);
  plot.setTitleText("Life expectancy connection to average income");
  plot.getXAxis().setAxisLabelText("Personal income ($/year)");
  plot.getYAxis().setAxisLabelText("Life expectancy (years)");
  plot.setLogScale("x");
  plot.setPoints(points);
  plot.setPointSizes(pointSizes);
  plot.activatePointLabels();
  plot.activatePanning();
  plot.activateZooming(1.1, CENTER, CENTER);
}

void draw() {
  // Clean the screen
  background(255);
  if (plot.isOverBox(mouseX, mouseY)) {
    // Get the cursor relative position inside the inner plot area
    float[] relativePos = plot.getRelativePlotPosAt(mouseX, mouseY);
    
    //println(relativePos);
    //plot.getPointAt(mouseX, mouseY)
    if (plot.getPointAt(mouseX, mouseY)!=null)
      {
      selcon = plot.getPointAt(mouseX, mouseY).getLabel();
      println(selcon);
      
      for(int i = 0; i < countries.length; i++)
        {
          if(countries[i].equals(selcon))
          {
            println(literacyrate[i]);
            // barH =literacyrate[i];
            //barH = barHeight*355;
            barH = map(literacyrate[i], 0, 100, 0, 255);
            println(barH);
            onoff = 1;    // Keep vibrator OFF (0) or ON (1)
            inten1 = (int)barH;   //0 - 255
            inten2 = (int)barH;;   //0 - 255
            sweeptime_ms = 2;   //in ms
            repeatsweep = 1;    // no of times you want to repeat sweep within one cycle
            pulse_time_ms = 2000;  // The vibration time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
            rest_ms = 1000;     // The NO vibration time or resting in ms before starting next cycle
            vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";  //This concatenates the vibration pattern's parameters as a strings.
            port.write(vib_cmd); //This sends it to Arduino via serial port
            break;
          }
         }
      }
      else {
          //barH =literacyrate[i];
          //barH = barHeight*355;
          onoff = 0;    // Keep vibrator OFF (0) or ON (1)
          inten1 = 0;   //0 - 255
          inten2 = 0;;   //0 - 255
          sweeptime_ms = 2;   //in ms
          repeatsweep = 1;    // no of times you want to repeat sweep within one cycle
          pulse_time_ms = 1000;  // The vibration time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
          rest_ms = 1000;     // The NO vibration time or resting in ms before starting next cycle
          vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";  //This concatenates the vibration pattern's parameters as a strings.
          port.write(vib_cmd); //This sends it to Arduino via serial port
        }
    }
  // Draw the plot  
  plot.beginDraw();
  plot.drawBox();
  plot.drawXAxis();
  plot.drawYAxis();
  plot.drawTitle();
  plot.drawGridLines(GPlot.BOTH);
  plot.drawPoints();
  plot.drawLabels();
  plot.endDraw();
}
