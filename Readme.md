BBB-Tor
==========

Beablebone Black Tor Middle - BeagleBone Black based onion router.

Development and Design Guide
=============================

By: Colin Vallance <colin@cvallance.net>

Thanks: Major inspiration from the gruq and his PORTAL / PORTALofPi projects (https://github.com/grugq/PORTALofPi)
Robert C Nelson (http://www.rcn-ee.com/) for the prebuilt images for the BBB.

Install Guide
=====

This script is meant to be run on a vanila install of Debian from Robert C Nelson.

Basic Steps
=====
1. Take a look at http://elinux.org/BeagleBoardDebian#BeagleBone.2FBeagleBone_Black for prebuilt images 
2. Flash an SD card (use dd or win32diskimager)
2b. Optionally expand the ext3 partition on your sdcard to fill the rest of the disk.  You're on your own for this one.
3. Boot in to debian with a network connection (I suggest a wired connection in eth0)
4. Grab the build.sh file (easiest is probably git clone https://github.com/crvallancegrugq/BBB-Tor.git)
5. Change in to the BBB-Tor dir and chmod +x ./build.sh
6. Become root (su -) and run ./build.sh
7. You should see stuff in stdout as well as in /var/log/syslog