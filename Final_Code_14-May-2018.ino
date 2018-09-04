
#include <LiquidCrystal.h>
#include <Servo.h> 
#include <avr/wdt.h>
#include <avr/io.h>

 
const int rs = A0, en = A1, d4 = A2, d5 = A3, d6 = A4, d7 = A5;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

Servo myservo1;  
Servo myservo2;  
Servo myservo3;  
Servo myservo4;  
Servo myservo5;  

int pos;    // variable to store the servo position 


int buzz = 13;
const byte interruptPin = 2;
void found();

void homep()
{
  delay(1500);
  myservo1.write(90);
  delay(1500);
  myservo2.write(60);
  delay(1500);
  myservo3.write(90);
  delay(1500);
  myservo4.write(10);
  delay(1500);
  myservo5.write(90);
  delay(1500);
}

void right()
{
  delay(500);
  
  for(pos = 90; pos <= 175; pos += 1)  // Servo 4 
  {                                   
    myservo1.write(pos);              
    delay(20);                        
  }  

  delay(500);

  for(pos = 60; pos <= 110; pos += 1)  // Servo 2 
  {                                   
    myservo2.write(pos);              
    delay(30);                        
  }

  delay(500);

  for(pos = 100; pos <= 170; pos += 1)  // Servo 5   Close gripper
  {                                   
    myservo5.write(pos);              
    delay(20);                        
   }

   delay(500);

  for(pos = 110; pos >= 60; pos -= 1)  // Servo 2 
  {                                   
    myservo2.write(pos);              
    delay(30);                        
  }

  delay(500);
  homep();
  delay(2000);
}

void left()
{
  delay(500);
  
  for(pos = 90; pos >= 5; pos -= 1)  // Servo 4 
  {                                   
    myservo1.write(pos);              
    delay(20);                        
  }  

  delay(500);

  for(pos = 60; pos <= 110; pos += 1)  // Servo 2 
  {                                   
    myservo2.write(pos);              
    delay(30);                        
  }

  delay(500);

  for(pos = 100; pos <= 170; pos += 1)  // Servo 5   Close gripper
  {                                   
    myservo5.write(pos);              
    delay(20);                        
   }

   delay(500);

  for(pos = 110; pos >= 60; pos -= 1)  // Servo 2 
  {                                   
    myservo2.write(pos);              
    delay(30);                        
  }

  delay(500);
  homep();
  delay(2000);
}


void pick()
{
  delay(500);
  lcd.setCursor(0, 1);
  lcd.print("Motor 4                "); 
  for(pos = 10; pos <= 90; pos += 1)  // Servo 4 
  {                                   
    myservo4.write(pos);              
    delay(20);                        
  }    
  
  delay(500);
  lcd.setCursor(0, 1);
  lcd.print("Motor 5                ");
  for(pos = 90; pos <= 170; pos += 1)  // Servo 5 open gripper
  {                                   
    myservo5.write(pos);              
    delay(20);                        
  }

  delay(500);
  lcd.setCursor(0, 1);
  lcd.print("Motor 3                ");
  for(pos = 90; pos >= 10; pos -= 1)  // Servo 3 
  {                                   
    myservo3.write(pos);              
    delay(30);                        
  }

  delay(500);
  lcd.setCursor(0, 1);
  lcd.print("Motor 2                ");
  for(pos = 60; pos <= 110; pos += 1)  // Servo 2 
  {                                   
    myservo2.write(pos);              
    delay(30);                        
  }

  delay(500);      
  lcd.setCursor(0, 1);
  lcd.print("Motor 5                ");
  for(pos = 170; pos >= 100; pos -= 1)  // Servo 5   Close gripper
  {                                   
    myservo5.write(pos);              
    delay(20);                        
   }

  delay(500);
  lcd.setCursor(0, 1);
  lcd.print("Motor 2                ");
  for(pos = 110; pos >= 60; pos -= 1)  // Servo 2 
  {                                   
    myservo2.write(pos);              
    delay(30);                        
  }
  
}

void front()
{
  delay(500);

  for(pos = 120; pos >= 90; pos -= 1)  // Servo 2 
  {                                   
    myservo3.write(pos);              
    delay(30);                        
  }
  delay(500);

  for(pos = 90; pos <= 170; pos += 1)  // Servo 5 open gripper
  {                                   
    myservo5.write(pos);              
    delay(20);                        
  }

  delay(1000);
  
}


void setup() 
{
  lcd.begin(16, 2);
  Serial.begin(9600);
  delay(500);
  pinMode(buzz, OUTPUT);
  digitalWrite(buzz, LOW);
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), found, FALLING);

  myservo1.attach(3);  // attaches the servo on pin 9 to the servo object 
  myservo2.attach(5);
  myservo3.attach(6);
  myservo4.attach(9);
  myservo5.attach(10);
  delay(500);
  
  lcd.setCursor(0, 0);
  lcd.print("Object Sory Sys");
  lcd.setCursor(0, 1);
  lcd.print("Using DIP Tech.");
  delay(1000);
  homep();
  delay(2000);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Conveyer Moving......"); 
  delay(1000);
}

void loop() 
{
   if (Serial.available() > 0) 
  {
    char rx = Serial.read();

    if(rx == 'a' || rx == 'A')
    {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Robot Moving"); 
      lcd.setCursor(0, 1);
      lcd.print("Right Side");
      delay(500);
      pick();
      delay(1000);
      right();
      delay(500);
      homep();
      Serial.flush();
      delay(300);
    }

    if(rx == 'b' || rx == 'B')
    {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Robot Moving"); 
      lcd.setCursor(0, 1);
      lcd.print("Left Side");
      delay(500);
      pick();
      delay(1000);
      left();
      delay(500);
      homep();
      Serial.flush();
      delay(300);
    }

    if(rx == 'c' || rx == 'C')
    {
      delay(1000);
      pick();
      delay(1000);
      delay(500);
      front();
      delay(500);
      homep();
      Serial.flush();
      delay(300);
    }
  }
}

void found()
{
  Serial.println("Obstacle Found ");
  delay(500);
}

