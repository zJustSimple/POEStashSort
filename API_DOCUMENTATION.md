## POEStashSort — API and Usage Guide

This document describes the public surface area (hotkeys, configuration, file formats) and internal functions of the POE stash sorter script (`read_stash.ahk`). It also includes setup instructions and examples.

### Overview
- Sorts a 12×12 Path of Exile stash tab according to a layout file (`sort1.txt`, `sort2.txt`, …).
- Detects items by reading the first two lines of the item tooltip via clipboard and matching them against patterns defined in `classes.txt`.
- Executes moves by clicking grid positions; unlisted items are offloaded to inventory via Ctrl+Click.
- TOS-friendly stepping: the script waits for you to press `F` before each action.

### Requirements
- Windows with AutoHotkey v1 (classic) installed.
- Path of Exile running in windowed mode.
- Default calibration assumes 1280×1024. Configure coordinates for other resolutions.

### Quick Start
1. Open Path of Exile and the target stash tab.
2. Double-click `read_stash.ahk` to run it.
3. If using TOS-friendly stepping, press `F` whenever prompted to advance actions.
4. Press `Esc` at any time to exit the script.

### Hotkeys and Commands
- Esc: Immediately exits the script.
- F: Advances scripted actions (moving/reading/clicking) when prompted by the script.

### Configuration Variables (in `read_stash.ahk`)
- `SPEED` (default `1.5`): Mouse movement speed used by `MouseMove`.
- `MOUSE_OVER_DELAY` (default `20`): Delay after moving mouse before reading tooltip.
- `CLIPBOAD_DELAY` (default `50`): Delay after `Ctrl+C` before reading clipboard.
- `CLICK_DELAY` (default `300`): Delay after each click.
- `BETWEEN_ACTIONS_DELAY` (default `300`): Delay between higher-level actions.
- `SORT_FILE` (default `"sort1.txt"`): Path to the 12×12 desired layout file.
- `TOP_LEFT_CORNER_X`, `TOP_LEFT_CORNER_Y` (default `47`, `173`): Pixel coordinates of stash grid cell (1,1).
- `LOGGING` (default `0`): When `> 0`, writes debug info to `inv.txt` and `log.txt`.
- `NOTIFICATIONS` (default `0`): When `> 0`, shows tray tips for progress.
- `EMPTY_PLACE` (default `"___"`): Token representing an empty stash slot.
- `UNLISTED` (default `"???"`): Token used internally for unlisted or already-placed elements.
- `ANY` (default `"any"`): Token meaning any item class may be placed in that slot.

Notes:
- For non-1280×1024 resolutions, calibrate `TOP_LEFT_CORNER_X/Y` and the cell offsets (see Calibration below).
- The script scans a 12×12 grid. It will not operate correctly on different grid sizes without code changes.

### Calibration for Other Resolutions
1. Run PoE in windowed mode at your desired resolution.
2. Open AHK’s Window Spy, focus the PoE window.
3. Place the cursor in the center of stash cell (1,1) and record Window coordinates — set `TOP_LEFT_CORNER_X/Y`.
4. Determine cell offsets by measuring distance between centers of (1,1) and (1,2) for vertical offset and (1,1) and (2,1) for horizontal offset. In this script, `_InvOffsetX` and `_InvOffsetY` are used internally (45 by default). Adjust them in code if necessary.

### File Formats

#### `classes.txt` — Item Classification Rules
Each line defines a classification rule as a comma-separated pair:
- Column 1: Pattern used with AHK `RegExMatch` against the first two lines of the item tooltip (after the script truncates the tooltip to those lines).
- Column 2: Short code (item class) placed into the 12×12 arrays and compared to the desired layout.

Examples:
```text
Maven's Orb, mvo
Deafening Essence of, es1
Orb of Fusing, fus
```
Guidelines:
- Patterns are regular expressions. Escape special characters when needed.
- More specific patterns higher in the file get higher priority (line number is used as `priority`).
- If no pattern matches, the slot is marked `UNLISTED` ("???").

#### `sort1.txt` / `sort2.txt` — Desired Stash Layout
- 12 lines, each with 12 whitespace-separated tokens.
- Tokens must be short codes that appear in `classes.txt`, or the special tokens `any` and `___`.
- `any` means any class is acceptable there (used for overflow or flexible areas).
- `___` reserves a slot to remain empty.

Examples:
```text
fus fus fus fus fus fus fus fus fus fus fus fus
fus fus fus fus fus fus fus fus fus fus fus fus
chr chr chr chr chr chr chs chs chs chs chs chs
exo exo chs chs chs chs bls bls bls div scg reg
vaa vaa vaa vaa gcp gcp chs chs chs chs rgl rgl
any any any any any any any any any any any any
any any any any any any any any any any any any
any any any any any any any any any any any any
any any any any any any any any any any any any
any any any any any any any any any any any any
any any any any any any any any any any any any
any any any any any any any any any any any any
```
You can also start from a blank canvas using `any` everywhere, e.g.:
```text
any any any any any any any any any any any any
...
```

### Runtime Behavior (What the Script Does)
1. Loads `classes.txt` into pattern rules and assigns a priority to each rule based on line number.
2. Scans the 12×12 stash grid:
   - Moves to each cell, waits, copies tooltip via `Ctrl+C`, truncates to first two lines.
   - Matches tooltip against `classes.txt` rules, assigns a class code and captures the rule priority.
   - When `LOGGING > 0`, writes raw classes to `inv.txt`.
3. Offloads unlisted items: any cell classified `UNLISTED` is `Ctrl+Click`ed into inventory.
4. Sorts the stash by iterations over rule priorities:
   - For each non-empty, non-unlisted element, finds its target location by comparing to desired layout.
   - If an exact target exists, moves or swaps items accordingly.
   - If no exact target but the current rule’s priority equals the iteration, places into the first `any` slot.
   - If neither applies, leaves the item to be reconsidered on later iterations.
5. On completion, shows a tray tip if `NOTIFICATIONS > 0`.

### Generated/Temporary Files
- `inv.txt`: Raw classification output (when `LOGGING > 0`).
- `log.txt`: Detailed step log of sorting decisions (when `LOGGING > 0`).

### Internal Functions (for contributors)
Although the script is designed as a runnable tool rather than a library, the following functions form its internal API. They are useful if you customize or extend the script.

#### `Swap(sx, sy, s1x, s1y)`
- Purpose: Clicks to move the item at grid (sx, sy) to grid (s1x, s1y), handling the case where the target is occupied.
- Parameters:
  - `sx`, `sy`: Source grid coordinates (1-based).
  - `s1x`, `s1y`: Target grid coordinates (1-based).
- Returns: None (uses side effects).
- Side effects:
  - Uses `GetCoords` twice to compute pixel positions, then clicks with delays.
  - If the target slot was not empty, it clicks back on the source to put down the held item.
  - Reads/modifies global arrays `Stash` and uses `FoundX`, `FoundY` as shared temporaries.
- Example (conceptual):
```ahk
; Move the item at (3,4) to (8,2)
Swap(3, 4, 8, 2)
```

#### `GetCoords(gcx, gcy)`
- Purpose: Compute and store the pixel coordinates of a given grid cell.
- Parameters:
  - `gcx`, `gcy`: Grid coordinates (1-based).
- Returns: None. Sets globals `FoundX`, `FoundY` to the pixel coordinates:
  - `FoundX := TOP_LEFT_CORNER_X + (gcx - 1) * _InvOffsetX`
  - `FoundY := TOP_LEFT_CORNER_Y + (gcy - 1) * _InvOffsetY`
- Example:
```ahk
GetCoords(1, 1)
MouseMove, %FoundX%, %FoundY%, SPEED
```

#### `FindPlace(fpx, fpy, iteration)`
- Purpose: Decide a placement target for the item currently at (fpx, fpy).
- Parameters:
  - `fpx`, `fpy`: Current grid coordinates of the item.
  - `iteration`: Current iteration counter (compared to item’s rule priority).
- Returns:
  - `1` when an exact desired slot exists; sets `FoundX`, `FoundY` to the target grid indices.
  - `2` when no exact slot is available but an `any` slot is available at the right iteration; sets `FoundX`, `FoundY` to that slot.
  - `0` when neither condition applies yet (try again in a later iteration).
  - `-1` when no `any` slot is available for this item in this iteration.
- Side effects: Sets `FoundX`, `FoundY` to grid indices (not pixel coords); caller typically invokes `GetCoords(FoundX, FoundY)` before clicking.
- Example:
```ahk
res := FindPlace(5, 7, iter)
if (res > 0) {
    tmpx := FoundX
    tmpy := FoundY
    ; do swap or click logic as in the main loop
}
```

### Examples

#### Example: Add a new class and assign positions
1. Edit `classes.txt` and add a line:
```text
Maven's Orb, mvo
```
2. Open `sort1.txt` and reserve a row of slots for `mvo`:
```text
mvo mvo mvo mvo mvo mvo mvo mvo mvo mvo mvo mvo
...
```
3. Run `read_stash.ahk` and press `F` to advance steps.

#### Example: Keep a column empty for trading
In `sort1.txt`, use `___` for an empty column:
```text
___ any any any any any any any any any any any
___ any any any any any any any any any any any
...
```

### Tips and Caveats
- Clipboard reading: Ensure PoE has focus and tooltips can be copied (`Ctrl+C`).
- Timing: If copying fails or PoE lags, increase `MOUSE_OVER_DELAY` and `CLIPBOAD_DELAY`.
- Safety: The script is TOS-friendly by requiring manual `F` confirmation before actions.
- Grid size: Hardcoded 12×12. Currency tab or specialized tabs with different layouts are not supported without code changes.
- Patterns: Prefer more specific patterns earlier in `classes.txt`.

### Contributing
- Keep variable names and side effects clear; `FoundX`/`FoundY` are intentionally reused for both pixel positions and grid indices in different contexts—be mindful when modifying logic.
- If you add new functions, document their parameters and effects here.
