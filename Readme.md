BBB-Tor
==========

Beablebone Black Tor Middle - BeagleBone Black based onion router.
___
((Host))----[usb0]<[BBB]>[eth0]---((Internet))
___

First cobbled attempt: Colin Vallance <crvallance@keybase.io>

Major Thanks: 
==========
Inspiration from the gruq and his PORTAL / PORTALofPi projects (https://github.com/grugq/PORTALofPi)

Robert C Nelson (http://www.rcn-ee.com/) for the prebuilt images for the BBB.

Adafruit's learning tutorial on TOR (https://learn.adafruit.com/onion-pi/install-tor)

Jeff Jarmoc (https://twitter.com/jjarmoc) for the all around mentoring and the push to get this working.


Basic Steps
=====
This script is meant to be run on a vanila install of Debian from Robert C Nelson.  I do not take any responsibility for absolute security while using this implementation.  As I am no expert, there may be leaks and/or misconfigurations.  If you see anything please feel free to let me know and/or fork / patch / submit a pull request.

1. Take a look at http://elinux.org/BeagleBoardDebian#BeagleBone.2FBeagleBone_Black for prebuilt images and how to flash or build them.
  * Page is updated normally but root for all wheezy images is https://rcn-ee.net/deb/microsd/wheezy/
2. Flash an SD card
  * Use dd or win32diskimager (https://wiki.ubuntu.com/Win32DiskImager)
  * Optionally expand the ext3 partition on your sdcard to fill the rest of the disk.  You're on your own for this one.
3. Boot in to debian with a network connection 
  * I suggest a wired connection in eth0
4. Become root
  * Quick and dirty `sudo bash`
5. Grab the build.sh file
  * Easiest is probably `git clone https://github.com/crvallance/BBB-Tor.git`
6. Make executable and run
  * `cd BBB-Tor`
  * `chmod +x ./build.sh`
  * `./build.sh`
7. You should see stuff in stdout as well as in /var/log/syslog
8. Check out https://check.torproject.org to see if things are working!
