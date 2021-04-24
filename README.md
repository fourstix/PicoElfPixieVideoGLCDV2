# PicoElfPixieVideoGLCDV2
This is the second version of a Teensy 3.2 based Pixie Video simulator for the 1802 Pico/Elf v2 microcomputer using a GLCD with SPI.  The first version is located in the [PicoElfPixieVideoGLCD](https://github.com/fourstix/PicoElfPixieVideoGLCD) repository.

This code simulates a cdp1861 Pixie Video chip, using a [Teensy 3.2.](https://www.pjrc.com/store/teensy32.html)
This [simulator](https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/docs/PicoElfPixieVideoGLCDV2.pdf)
uses a video ram buffer with a 128 x 64 graphics display supported by the
[U8G2 graphics library](https://github.com/olikraus/u8g2) as a video display.  The code will simulate
the interrupts, external flag 1 signal, and DMA Output requests from the original pixie video.  This
allows programs written for the original Cosmac Elf hardware to run directly PicoElf v2 with the simulator.
This simulator supports 32 x 64 and 64 x 64 video resolutions.

The Teensy 3.2 is available from [PJRC.](https://www.pjrc.com/store/teensy32.html) and is also sold by
[Sparkfun](https://www.sparkfun.com/products/13736) and [Adafruit.](https://www.adafruit.com/product/2756)

This hardware design uses a 128 x 64 ST7920 GLCD display with SPI. U8G2 supports this display as well as
many other kinds of 128 x 64 displays.  A list of supported displays is available
[here.](https://github.com/olikraus/u8g2/wiki/u8g2setupcpp)

Based on the Pico/Elf v2 hardware by Mike Riley. Information about the Pico/Elf v2 is available at
[Elf-Emulation.com](http://www.elf-emulation.com/).

Version Two Improvements
------------------------
The second version of the Teensy 3.2 based Pixie Video simulator adds support for turning video on and off without 
blanking the display.  When the video is off, the Pixie Video simulator will display any values output to Port 4 
by the Pico/Elf v2 1802 Microprocessor.  In addition, the hardware now includes an LED to indicate the status of the 1802 Q-bit on the Pico/Elf data bus.  Credit goes to Wayne Hortensius for his brilliant upgrade to the original hardware and software design that adds the display of Port 4 data when the video is off.


Examples
---------------------
Here are some examples running actual CDP1802 programs modified for the Elf/OS on the Pico/Elf v2 Hardware
with the PicoElfVideoGLCD v2 simulator.  These examples were compiled with the [RcAsm 1802 Assmbler](https://github.com/rileym65/RcAsm).  Documentation for RcAsm can be found at [Elf-Emulation.com/RcAsm](http://www.elf-emulation.com/rcasm.html).

<table class="table table-hover table-striped table-bordered">
  <tr align="center">
   <td><img style="display:block;" src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/spaceship.jpg"></td>
   <td><img style="display:block;" src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/dma_test.jpg"></td>
  </tr>
  <tr align="center">
    <td>Close up of 128x64 ST7920 GLCD display with 1802 Pico/Elf v2 running Cosmac Elf Spaceship program.</td>
    <td>Close up of 128x64 ST7920 GLCD display with 1802 Pico/Elf v2 running Tom Pittman's DMA Test program.<td>    
  </tr>
  <tr align="center">
   <td><img style="display:block;" src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/tvclock.jpg"></td>
   <td><img style="display:block;" src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/port4out.jpg"></td>
  </tr>
  <tr align="center">
    <td>Close up of 128x64 ST7920 GLCD display with 1802 Pico/Elf v2 running Tom Pittman's TV Clock program.</td>
    <td>Close up of 128x64 ST7920 GLCD display displaying the hex value '0E' output to Port 4 by the 1802 Pico/Elf v2. Note that the LED is on indicating the Q-bit is true.</td>
  </tr>  
  <tr align="center">
     <td colspan="2"><img src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/schematic.jpg"></td>
  </tr>
  <tr align="center">
     <td colspan="2">Pico/Elf Pixie Video GLCD version 2 Hardware Schematic</td>
  </tr>
  <tr align="center">
     <td colspan="2"><img src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/all_three.jpg"></td>
  </tr>
  <tr align="center">
     <td colspan="2">Pico/Elf v2 running with an STG RTC/NVR card and a Pixie Video GLCD Card connected by an IDE cable.</td>
  </tr>
</table>

Notes
---------------------
* **Video resolution**  
  * Resolutions of 64 x 64 and 32 x 64 are directly supported.
  * For 128 x 64 and other resolutions, video data will be captured on every other DMA request (as per a 64 x 64 resolution).
* **Data Lines**  
  * Data lines from the Pico/Elf Expansion Connector are latched by a 74LS374 Octal D Flip-flip triggered by TPB.
  * The latched Data lines are connected to the Teensy 3.2 Port D pins (pins 2, 14, 7, 8, 6, 20, 21, 5)
  * The Teensy 3.2 reads data as a byte in a single instruction from Port D during an 1802 DMA Output cycle.
  * Full details about Teensy 3.2 pin connections are in the code comments.
* **Video Control**    
  * The 1802 Instruction INP 1 (Input from Port 1,1802 Opcode 69) will turn video processing ON.
  * The 1802 Instruction OUT 1 (Output to Port 1, 1802 Opcode 61) will turn video processing OFF. When Video is OFF Interrupts and DMA Requests are halted, but the display is not cleared.  An INP 1 will restart the video and another OUT 1 instruction when Video is OFF, will clear the display.  This allows one to pause and resume video.
  * The /EF1 line will go LOW four lines before a frame's DMA requests begin, and during the last four DMA request lines of a frame.
  * An Interrupt Request will be asserted (/INT = LOW) exactly 29 instruction cycles before the first DMA request
  * 128 lines of 8 DMA_OUT requests will be asserted per frame. Each DMA_OUT request takes one instruction cycle.
  * Exactly 6 instruction cycles will occur between each line of DMA requests.
  * There are a minimum of 6350 instruction cycles (given a 4MHz clock) between frames to simulate the blanking period.
  * Software for the 1802 that rely on these control timings will work with this simulator. (If not, please open an issue.)
  * Timing details are documented in the code comments.
* **Teensy Port 1 Interrupts**
  * The Port 1, /INP and /Out signals on the Pico/Elf Expansion connector trigger interrupts on the Teensy 3.2 to turn video on or off.
  * Input and Output to Port 1 is used to turn video on or off.
  * INP 1, 1802 opcode 69 (PORT1 = LOW, /INP = LOW) turns video on.
  * OUT 1, 1802 opcode 61 (PORT1 = LOW, /OUT = LOW) turns video off if video is on, clears display if video is off.
* **Teensy TPB Interrupt**  
  * A rising signal on TPB triggers an interrupt on the Teensy 3.2.
  * The Teensy interrupt handler will process one cycle in the video state machine
  * During DMA the interrupt handler will read the video data byte from Port D (pins 2, 14, 7, 8, 6, 20, 21, 5)
  * There are 8 bytes of video data read per frame line.
  * Video data is captured every other DMA line and stored in a Video Buffer
* **Frame rate and GLCD updates**
  * After one complete frame of data is captured, the GLCD display will be updated.
  * Any SPI 64 x 128 GLCD supported by U8G2 should work as a display.
  * If the captured video data does not change, the display will not be updated for that frame.
  * The GLCD with SPI is usually fast enough to update within a single frame, but if not, then during display update, interrupts  and control signals will continue, but data will not be captured for the frame. Programs will run correctly, even when data is not captured.
  * The 1802 will see frames requests at rate of about 61/second when running on the Pico/Elf v2 hardware with a 4MHz clock speed.  Different clock speeds may need to adjust the END_BUFFER_CYCLES constant in the Teensy 3.2 PicoElfVideoGLCDV2.ino file to maintain the expected 61 interrupts per second rate of the original Pixie Video hardware.
  * Further details are in the comments in the Teensy 3.2 PicoElfVideoGLCDV2.ino source code file.
* **Port 4 Output**  
  * When video is off, data output to Port 4 will be displayed on the GLCD display.
  * OUT 4, 1802 opcode 64 (PORT4 = LOW, /OUT = LOW) will send data on the data bus to be displayed
  * The data is displayed on the GLCD as a two digit hexadecimal value.
  * When video is on, data output to port 4 will *not* affect the Pixie Video display.  
* **Q LED**
  * Version 2 of the hardware provides an LED to show the value of the Q-bit.
  * SEQ, 1802 opcode 7B, will Set Q to true and turn the LED on.
  * REQ, 1802 opcode 7A, will Reset Q to false and turn the LED off. 
  
Repository Contents
-------------------
* **/src/PicoElfPixieVideoGLCDV2/**  
  * PicoElfPixieVideoGLCDV2.ino -- Teensy 3.2 based Pixie Video simulator for 1802 Pico/Elf v2 and
  a 128x64 ST7920 SPI graphic LCD display.
* **/src/examples/asm/** -- example programs source files and RcAsm batch files.
  * spaceship.asm -- Joseph Weisbecker's original Elf graphics program modified for the Elf/OS
  * dma_test.asm -- Tom Pittman's DMA Test program modified for the Elf/OS
  * tvclock.asm -- Tom Pittman's DMA Test program modified for the Elf/OS
  * output.asm -- The command *output hh* will send the hexadecimal value 'hh' to Port 4 as data output.
* **/src/examples/bin/** -- binaries, list files and hex files for example programs  
* **/docs** -- documentation files
  * PicoElfPixieVideoGLCDV2.pdf -- schematic for Pixie Video simulation logic using a Teensy 3.2
* **/pics/** -- example pictures for readme
* **/brd/** -- Printed Circuit Board layout for PicoElfPixieVideoGLCDV2
  * PicoElfPixieVideoGLCDV2-KiCad4.zip -- KiCad4 project files for Pico/Elf Pixie Video GLCD PCB.
  * PicoElfPixieVideoGLCDV2-gerbers.zip -- Gerber files for Pico/Elf Pixie Video GLCD PCB.

GLCD Display Connections
------------------------
<table>
<tr><th>GLCD</th><th>Pin</th><th>Teensy</th><th>Pin</th></tr>
<tr><td>GND</td><td>1</td><td>GND</td><td>&nbsp;</td></tr>
<tr><td>VCC</td><td>2</td><td>+5v</td><td>&nbsp;</td></tr>
<tr><td>RS</td><td>4</td><td>CS</td><td>D10</td></tr>
<tr><td>R/W</td><td>5</td><td>MOSI</td><td>D11</td></tr>
<tr><td>E</td><td>6</td><td>SCK</td><td>D13</td></tr>
<tr><td>RST</td><td>17</td><td>RST</td><td>D23</td></tr>
<tr><td>PSD</td><td>15</td><td>GND</td><td>&nbsp;</td></tr>
<tr><td>BLA</td><td>19</td><td>+5v</td><td>&nbsp;</td></tr>
<tr><td>BLK</td><td>20</td><td>GND</td><td>&nbsp;</td></tr>
</table>

Pico/Elf v2 Expansion Connector
-------------------------------
<table>
<tr><td>A0</td><td>1</td><td>2</td><td>D0</td></tr>
<tr><td>A1</td><td>3</td><td>4</td><td>D1</td></tr>
<tr><td>A2</td><td>5</td><td>6</td><td>D2</td></tr>
<tr><td>A3</td><td>7</td><td>8</td><td>D3</td></tr>
<tr><td>A4</td><td>9</td><td>10</td><td>D4</td></tr>
<tr><td>A5</td><td>11</td><td>12</td><td>D5</td></tr>
<tr><td>A6</td><td>13</td><td>14</td><td>D6</td></tr>
<tr><td>A7</td><td>15</td><td>16</td><td>D7</td></tr>
<tr><td>TPA</td><td>17</td><td>18</td><td>TPB</td></tr>
<tr><td>/INP</td><td>19</td><td>20</td><td>EF1</td></tr>
<tr><td>/OUT</td><td>21</td><td>22</td><td>EF2</td></tr>
<tr><td>PORT1</td><td>23</td><td>24</td><td>EF3</td></tr>
<tr><td>/DMA_IN</td><td>25</td><td>26</td><td>EF4</td></tr>
<tr><td>/DMA_OUT</td><td>27</td><td>28</td><td>INT</td></tr>
<tr><td>/MRD</td><td>29</td><td>30</td><td>/MWR</td></tr>
<tr><td>SC0</td><td>31</td><td>32</td><td>SC1</td></tr>
<tr><td>Q</td><td>33</td><td>34</td><td>GND</td></tr>
<tr><td>PORT2</td><td>35</td><td>36</td><td>PORT5</td></tr>
<tr><td>PORT3</td><td>37</td><td>38</td><td>PORT6</td></tr>
<tr><td>PORT4</td><td>39</td><td>40</td><td>PORT7</td></tr>
</table>

Bill of Materials
-----------------
<table>
<tr><th colspan = "2">Part #</th><th>Qty</th><th>Description</th></tr>
<tr><td colspan = "2">U1</td><td>1</td><td>LM7805 5v Regulator</td></tr>
<tr><td colspan = "2">U2</td><td>1</td><td>L4HC32 Quad OR Gate</td></tr>
<tr><td colspan = "2">U3</td><td>1</td><td>L4HC374 Octal D Flip-flop</td></tr>
<tr><td colspan = "2">U4</td><td>1</td><td>Teensy 3.2 Development Board</td></tr>
<tr><td colspan = "2">Q1</td><td>1</td><td>2N3904 NPN Transistor</td></tr>
<tr><td colspan = "2">R1</td><td>1</td><td>33k ohm 1/4 Watt Resistor</td></tr>
<tr><td colspan = "2">R2</td><td>1</td><td>10k ohm 1/4 Watt Resistor</td></tr>
<tr><td colspan = "2">R3,R4</td><td>2</td><td>1k ohm 1/4 Watt Resistors</td></tr>
<tr><td colspan = "2">C1</td><td>1</td><td>0.33 uF Capacitor</td></tr>
<tr><td colspan = "2">C2-C5</td><td>4</td><td>0.1 uF Capacitors</td></tr>
<tr><td colspan = "2">D1</td><td>1</td><td>5mm Red LED</td></tr>
<tr><td colspan = "2">J1</td><td>1</td><td>PJ-202A 2x5.5mm 3 pin Power Jack</td></tr>
<tr><td colspan = "2">J2</td><td>1</td><td>2x20 Male 40 Pin Connector, 2.54mm spacing</td></tr>
<tr><td colspan = "2">J3</td><td>1</td><td>2x3 Male 6 Pin Connector, 2.54mm spacing</td></tr>
<tr><td colspan = "2">J4</td><td>1</td><td>20 Female Pin Header, 2.54mm spacing</td></tr>
<tr><td colspan = "2">J5</td><td>1</td><td>2 Male Pin Connector, 2.54mm spacing</td></tr>
</table>

  License Information
  -------------------

  This code is public domain under the MIT License, but please buy me a beer
  if you use this and we meet someday (Beerware).

  References to any products, programs or services do not imply
  that they will be available in all countries in which their respective owner operates.

  Sparkfun, the Sparkfun logo, and other Sparkfun products and services are
  trademarks of the Sparkfun Electronics Corporation, in the United States,
  other countries or both.

  Adafruit, the Adafruit logo, and other Adafruit products and services are
  trademarks of the Adafruit Industries, in the United States,other countries or both.

  PJRC, the PJRC logo, and other PJRC products and services are
  trademarks of the PJRC.com LLC, in the United States,other countries or both.

  Other company, product, or services names may be trademarks or services marks of others.

  All libraries used in this code are copyright their respective authors.

  Universal 8bit Graphics Library
  Copyright (c) 2016-2021, olikraus
  All Rights Reserved

  The Teensy 3.2 hardware and software
  Copyright (c) 2016-2021 by Paul Stoffregen, PJRC.com LLC

  The Pico/Elf v2 1802 microcomputer hardware and software
  Copyright (c) 2004-2021 by Mike Riley.

  Elf/OS and RcAsm Software
  Copyright (c) 2004-2021 by Mike Riley.

  Many thanks to the original authors for making their designs and code available as open source.

  This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

  The MIT License (MIT)

  Copyright (c) 2021 by Gaston Williams

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  **THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.**
