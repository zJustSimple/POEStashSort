POEStashSort
============
This is an updated version of Kokosoida's Stash Sorter.

New Features:
Added most currencies up until 3.13
Changed classes.txt parser to split strings in substrings based by commas, giving us the ability to compare the item's full name as in "Maven's Orb, mvn" instead of "Maven's mvn" 

NOTICE:
You will have to set-up the screen coordinates yourself, run POE in windowed mode and play with the `TOP_RIGHT_CORNER_X` &  `TOP_RIGHT_CORNER_Y` and `_InvOffsetX` & `_InvOffsetY` until you get it to move in the correct places. Even though the variable name is TOP RIGHT, it's actually a typo in the original script, it should be TOP LEFT.  So, play with corner coordinates until the first place the cursor goes is the middle of the top left corner square of the stash tab, then the offset until it jumps correctly to the next tile's middle.
