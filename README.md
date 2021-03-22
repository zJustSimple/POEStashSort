# POEStashSort
An updated version of Kokosoida's Stash Sorter.

# New Features:

* Added most currencies up until 3.13

* Changed classes.txt parser to split strings in substrings based by commas, giving us the ability to compare the item's full name as in "Maven's Orb, mvn" instead of "Maven's mvn"

* TOS Friendly version

# HOW TO USE: 
1. Open Path Of Exile
2. Open the stash tab you want to sort
3. Double click read_stash.ahk
4. (Optional for now) If you're using the TOS friendly version, press F to progress forward with the sorting
5. Watch how everything is automagically sorted.

#### NOTICE:
By default, the script is set to work with the game running at 1280x1024. If you run any other resolution you'll need to find out the stash tile offset and coordinates yourself.
Run POE in windowed at your desired resolution, run AHK's WindowSpy and focus the POE window. Place your cursor in the middle of the top left corner stash tab "square" ( coordinates 1x1 ) The values you need should be in the Mouse Position category under "Window". The offset is calculated by taking the second "square" ( in horizontal or vertical order ) position and substracting the first "square's" position.
