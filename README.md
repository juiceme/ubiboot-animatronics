# ubiboot-animatronics

This repository contains the ubiboot-02 animation creation toolkit and filesystem seed for the RAMFS of ubiboot kernel.

## Description

There are two scripts associated with animated menu creation;
 * create_animations.sh to compile the animation sequences.
 * pack_cpio.sh to create the CPIO format archve from the compiled sequence.

The directory imagebase/ holds the icon templates for menus.
The directory menuscripts/ holds the animation scripts and control files.
The directory ubifs/ holds the RAMFS seed.
The directory patches/ holds the kernel patch you will need if you want to start with the standard HArmattan kernel.

## Usage

For menu compilation, use create_animations.sh script. With no parameters it will read the content of imagebase/ and create a filesystem structure containing the animation sequences and needed scripts and configuration from menuscripts/.
This hierarchy is written to a file called animatronics.tar that you need to pack into a cpio archive that the ubiboot kernel mounts as root directory when it starts

To create and pack the whole menu system and support files into the runnable archive, use commands
```
./create_animations.sh
./pack_cpio.sh --create animatronics.tar
```

This will output a file called ubiboot-02.menus.cpio which can be copied to ubiboot configuration directory of your device. 

## Simple modifications

 You can change the look of your top menu easily:

 For example, the icon templates are located in the "imagebase" subdirectory. There are 8 image definitions in the beginning of the "create_animations.sh" script, and changing those will change the icons in the menu accordingly.
For best effect the icons need to be 200x200 pixel PNG images that have enough of black border around the edges, or else there may be artifacts left on the animation.

You can change the number and location of the menu icons easily:

If you want to have less than 8 icons in main menu, you need to define the icons that you want to hide as empty image. (there is "empty_200x200.png" provided for that purpose in the "imagebase" subdirectory)

In addition to that, you need to edit the mapfile that defines the touch actions so that there is no action for the emptied area.
The mapfile is "menuscripts/animated_menu_top.map" The format of the mapfile is described in the file itself. Just comment out the unnecessary line with a "#".

## Advanced modifications

Almost anything is possible, you can study the "create_animations.sh" script further to create any kind of animations you desire. For example, it would be no brainer to create different fade effects or for example make the icons "roll away" from screen.
