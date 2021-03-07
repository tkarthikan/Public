//Karthik


import org.gicentre.utils.stat.*;

private PVector dataPoint;
private int barIndex;
private float yValue;

private float barHeight;
private float[] barValues = {0.76, 0.4, 0.76, 0.5, 0.3}; // barchart values

String test="";
// These variables define the waveform.
String vib_cmd="";
int onoff = 0;    // Keep vibrator OFF (0) or ON (1)
int inten1 = 0;   // Starting intensity for a sweep (0-255)
int inten2 = 0;   // Ending intensity for a sweep (0-255)
int sweeptime_ms = 0;   //Time for each step in ms
int repeatsweep = 0;    // no of times you want to repeat sweep within one cycle
int pulse_time_ms = 0;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
int rest_ms = 0;     // The No actuating time or resting in ms before starting next cycle
float barH = 0;

import processing.serial.*;
  Serial port;
  
BarChart barChart;
 
void setup()
{
  size(600,600);
  
  println("Available serial ports:");
  println(Serial.list());
  port = new Serial(this, Serial.list()[1], 9600);
  port.bufferUntil ( '\n' ); 
  
  barChart = new BarChart(this);
  barChart.setData(barValues);
  
  barChart.setMinValue(0);
  barChart.setMaxValue(1);
  
  barChart.showValueAxis(true);
  barChart.showCategoryAxis(true); 
}

void serialEvent (Serial port) 
{
  test = port.readStringUntil ( '\n' );
  println(test);
}
 
void draw()
{
  background(255, 255, 255);
  barChart.draw(15, 15, width - 30, height - 30);
  
  dataPoint = barChart.getScreenToData(new PVector(mouseX, mouseY));
  if (dataPoint != null)
  {
    barIndex = (int)dataPoint.x;
    yValue = dataPoint.y;
    if ( yValue > barValues[barIndex]) //This is detect if cursor is outside the bar
    {
      println("Pointer outside bars");
      onoff = 0;    // Keep vibrator OFF (0) or ON (1)
      inten1 = 0;   //0 - 255
      inten2 = 0;   //0 - 255
      sweeptime_ms = 2;   //in ms
      repeatsweep = barIndex+1;    // no of times you want to repeat sweep within one cycle
      pulse_time_ms = 6000;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
      rest_ms = 2000;     // The No actuating time or resting in ms before starting next cycle
      vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";
      port.write(vib_cmd); 
      //barHeight=-1;
    }
    else if (barValues[barIndex] != barHeight)  //This is detect if cursor is within the barz
    {   
      //println(barIndex);
      barHeight = barValues[barIndex];
      //barH = barHeight*355;
      barH = map(barHeight, 0, 1, 0, 255);
      onoff = 1;    // Keep vibrator OFF (0) or ON (1)
      inten1 = (int)barH;   //0 - 255
      inten2 = (int)barH;;   //0 - 255
      sweeptime_ms = 2;   //in ms
      repeatsweep = 1;    // no of times you want to repeat sweep within one cycle
      pulse_time_ms = 1000;  // The vibration time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
      rest_ms = 1000;     // The NO vibration time or resting in ms before starting next cycle
      vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";  //This concatenates the vibration pattern's parameters as a strings.
      port.write(vib_cmd); //This sends it to Arduino via serial port
    }  
  }
  else {            //This is detect if cursor is outside barchart canvas
      println(" OFF ");
      onoff = 0;    // Keep vibrator OFF (0) or ON (1)
      inten1 = (int)barH;   //0 - 255
      inten2 = 0;   //0 - 255
      sweeptime_ms = 2;   //in ms
      repeatsweep = barIndex+1;    // no of times you want to repeat sweep within one cycle
      pulse_time_ms = 6000;  // The actuating time in a cycle. This period includes any sweeps or multiple sweeps or just flat vibrations
      rest_ms = 2000;     // The No actuating time or resting in ms before starting next cycle
      vib_cmd = onoff+","+inten1+","+inten2+","+sweeptime_ms+","+repeatsweep+","+pulse_time_ms+","+rest_ms+"\n";
      port.write(vib_cmd); 
    }   
}
