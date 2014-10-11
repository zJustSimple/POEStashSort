SPEED := 2
MOUSE_OVER_DELAY := 10
CLIPBOAD_DELAY := 100



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
    clipboard =
    while (j < 13)
    {
        j := j + 1
        Send ^c
        Sleep, CLIPBOAD_DELAY
        regclip := RegExReplace(clipboard, "s)---..*$")

        FileAppend, <el i=%i% j=%j%>%regclip%</el>`n, inv.txt
        clipboard =
        
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