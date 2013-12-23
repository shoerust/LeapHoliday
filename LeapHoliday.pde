//Controlling a Holiday by Moorescloud with Leap Motion
import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Hand;

import java.io.*; 
import java.net.*;
DatagramSocket clientSocket;
InetAddress ipAddress;
PImage img;
LeapMotionP5 leap;
Finger finger;
PVector fingerPos;
float xValue;
float yValue;
boolean pickup;
void setup() {
  size(800, 800);
  strokeWeight(10);
  colorMode(HSB);
  //we generate our own spectrum so we can
  //play around with it
  img = loadImage("spectrum.tif");
  if (img != null) {
    image(img, 0, 0);
  } else {
    for (int i = 0; i < 360; i++) {
      for (int j = 0; j < ((width/2)); j++) {
        stroke(i*255/360, 255, j*255/((width/2)));
        point(width/2+cos(radians(i))*j, height/2+sin(radians(i))*j);
      }
    }
    save("spectrum.tif"); //save an image because computing it is hard
    img = loadImage("spectrum.tif");
  }
  try {
    clientSocket = new DatagramSocket();       
    ipAddress = InetAddress.getByName("192.168.0.193");
  } catch (IOException e) {} 
  leap = new LeapMotionP5(this);
  xValue = 0;
  yValue = 0;
  pickup = true;
} // end setup

void draw() {
  image(img, 0, 0); 
  if (leap.getFingerList().size() > 0 && pickup) {
    finger = leap.getFingerList().get(0);
    fingerPos = leap.getTip(finger);
    xValue = fingerPos.x;
    yValue = fingerPos.y;
  }
  sendPacket();
  stroke(255);
  ellipse(xValue, yValue, 10, 10);
}

public void sendPacket() {
  byte[] sendData = new byte[160];   
  for (int i = 10; i < 158; i += 3) {               
    sendData[i] = (byte) ((Float) red(get((int) abs(xValue), (int) abs(yValue)))).byteValue();
    sendData[i + 1] = (byte) ((Float) green(get((int) abs(xValue), (int) abs(yValue)))).byteValue();
    sendData[i + 2] = (byte) ((Float) blue(get((int) abs(xValue), (int) abs(yValue)))).byteValue();
  }
  DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, ipAddress, 9988);       
  try { 
    clientSocket.send(sendPacket);
    System.out.println("sent");
  } catch (IOException e) {}
}

