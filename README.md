# 1351mousedriver
1351 Mouse driver for Commodore 64, in 6502

For C64 OS, I had to go searching around the web looking for 1351 mouse driver code that I could embed and modify for my purposes. 

The only code I found was on codebase64.org. That code is directly lifted from the printed listing in the back few pages of the 1351 User's Guide. It's short, poorly documented, proportional but not accelerated, and not bounded to the screen edges.

This code is distantly based upon the code from the User's Manual, with significant improvements. 

### Improvements

* Commented
* Screen Edge Bounded
* Accelerated
* Two Sprites
* 16-bit Overflow Prevention

It could be commented better within the source code. But bear in mind that a full technical discussion has been published to the [C64os.com weblog](http://www.c64os.com/post/1351mousedriver).

Screen edge bounded means that the mouse cursor will stop when it hits an edge of the screen. Many C64 programs, likely those that got their mouse driver code from the 1351 User's Manual, allow the mouse to go beyond a screen edge, and often roll around to the bottom when you go to far off the top, etc.

Acceleration is a matter of a 2X multiple at a certain breakpoint. Currently hardcoded to 10, but this should be easy to modify if you want to customize the accleration. A mouse movement of 10 or less is translated 1-to-1 to pixels on the screen. But a movement of 12 becomes 24 pixels on screen and 40 becomes 80 etc. More sophisticated acceleration hardly seems necessary given the screen resolution of 320x200.

The code in the User's Manual only updates the position of one C64 sprite. This code updates the position of 2. This allows for a hires mouse pointer in two colors. This is what is used by C64 OS. Note, that this driver does not define the sprite pointer appearance. 

Lastly, how a sprite's X coordinate is represented is a bit odd. It's 9–bit, but the 9th bit is stored on another register, vic+$10. That register's 8 bits are used as the 9th bit for all 8 sprites. The User's Guide's source code manipulates the VIC-II registers directly. But, because of their odd storage arrangement and because 0,0 on the screen is not 0 and 0 in sprite positioning, it is hard to perform bounding, overflow prevention, and acceleration. Support a second sprite merely adds to the complication. 

This driver maintains a pair of 16–bit coordinates, where 0,0 is the top left of the screen. All mouse movements are performed on this set of coordinates. Bounds checking and limits are then performed on these coordinates. They are then mapped to the sprites by applying the screen offsets.

Lastly, it is convenient to use the 16–bit coordinates as the position of mouse events.

