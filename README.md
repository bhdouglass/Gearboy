Gearboy-Qt
==========
This is a fork of Ignacio Sanchez's Gearboy, focusing on Qt/QML and OpenGL ES for mobile phones.

<img src="https://github.com/RyanPattison/Gearboy/blob/master/platforms/ubuntu_touch/gearboy.png" width="64"> 
<img src="https://github.com/RyanPattison/Gearboy/blob/master/platforms/ubuntu_touch/screenshots/landscape.png" width="256">
<img src="https://github.com/RyanPattison/Gearboy/blob/master/platforms/ubuntu_touch/screenshots/portrait.png" height="256">

An Ubuntu Touch version is available in [Ubuntu Store](https://uappexplorer.com/app/gearboy.rpattison)

Build Instructions
===================

### Ubuntu Touch

  1. Install the Ubuntu Touch SDK  
  2. Open Ubuntu-SDK
  3. Go to `File > Open File or Project..` and open `GearBoy/platforms/ubuntu_touch/gearboy.pro`
  4. Add the armhf target
  5. In the menu select `Build > Ubuntu > Install Application on Device`
  6. Install in release mode

### Android & Desktop

Build these with Qt Creator and the project files under platforms. These versions exist to test on a variety of hardware and are not (yet) supported.
