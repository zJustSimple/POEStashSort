SPEED := 4
MOUSE_OVER_DELAY := 50
CLIPBOAD_DELAY := 200



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
        Send ^c
        Sleep, CLIPBOAD_DELAY
        FileAppend, <el i=%i% j=%j%>%clipboard%</el>`n, inv.txt
        clipboard =
        
        MouseMove, _InvOffsetX, 0, SPEED, R
        Sleep, MOUSE_OVER_DELAY
        j := j + 1
    }
    MouseMove, -12*_InvOffsetX, _InvOffsetY, SPEED, R
    Sleep, MOUSE_OVER_DELAY
    i := i + 1
}



Esc::ExitApp