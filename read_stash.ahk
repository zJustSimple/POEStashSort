SPEED := 2
MOUSE_OVER_DELAY := 10
CLIPBOAD_DELAY := 100



;;; Prepare classes parser
ParseCount := 0
Loop, read, classes.txt
{
    ParseCount := ParseCount + 1
    StringSplit, Parse%ParseCount%_, A_LoopReadLine, %A_Space%
}

;;; Read info from POE stash
_InvOffsetX := 29
_InvOffsetY := 29

WinWait, Path of Exile
WinActivate ;
FileDelete, inv.txt

MouseMove, 30, 135, SPEED
Sleep, MOUSE_OVER_DELAY
i := 1
while (i < 13)
{
    j := 1
    clipboard := ""
    while (j < 13)
    {
        j := j + 1
        Send ^c
        Sleep, CLIPBOAD_DELAY
        
        ;;; Use parser
        if (clipboard == "")
        {
            Stash%i%_%j% := "___" ;;; Empty place
        }
        else
        {
            p := 1
            Stash%i%_%j% := "???" ;;; ??? is some shit that is not listed in classes file
            while (p <= ParseCount)
            {
            
                el := Parse%p%_1
                FoundPos := 0
                clipboard := RegExReplace(clipboard, "s)---..*$") ;;; Cut everything but first 2 lines
                FoundPos := RegExMatch(clipboard, el)
                if (FoundPos > 0)
                {
                    Stash%i%_%j% := Parse%p%_2
                    break
                }
                p := p + 1
            }
        }
        el := Stash%i%_%j%
        FileAppend, %el%`n, inv.txt
        clipboard := ""
        
        if (j < 13)
        {
            MouseMove, _InvOffsetX, 0, SPEED, R
            Sleep, MOUSE_OVER_DELAY
        }    
        
    }
    MouseMove, -11*_InvOffsetX, _InvOffsetY, SPEED, R
    Sleep, MOUSE_OVER_DELAY
    i := i + 1
}



Esc::ExitApp