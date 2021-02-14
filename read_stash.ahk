SPEED := 2 ;;; mouse movement speed
MOUSE_OVER_DELAY := 20 ;;; delay after mouse moved
CLIPBOAD_DELAY := 50 ;;; delay after ctrl + c pressed
CLICK_DELAY := 300 ;;; delay after mouse click
BETWEEN_ACTIONS_DELAY := 300 ;;;

SORT_FILE := "sort1.txt" ;;; name of file with sort layout

TOP_RIGHT_CORNER_X := 30 ;;; Top right X coordinate of stash
TOP_RIGHT_CORNER_Y := 125 ;;; Top right Y coordinate of stash

LOGGING := 0
NOTIFICATIONS := 0

EMPTY_PLACE := "___"
UNLISTED := "???"
ANY := "any"

;;; Prepare classes parser
ParseCount := 0
Loop, read, classes.txt
{
    ParseCount := ParseCount + 1
    StringSplit, Parse%ParseCount%_, A_LoopReadLine, `,

}



;;; Read info from POE stash
_InvOffsetX := 36
_InvOffsetY := 36

WinWait, Path of Exile
WinActivate ;
FileDelete, inv.txt

MouseMove, TOP_RIGHT_CORNER_X, TOP_RIGHT_CORNER_Y, SPEED
Sleep, MOUSE_OVER_DELAY
i := 1
while (i < 13)
{
    j := 1
    clipboard := ""
    while (j < 13)
    {

        Send ^c
        Sleep, CLIPBOAD_DELAY
        
        ;;; Use parser
        if (clipboard == "")
        {
            Stash%i%_%j% := EMPTY_PLACE ;;; Empty place
        }
        else
        {
            p := 1
            Stash%i%_%j% := UNLISTED ;;; ??? is some shit that is not listed in classes file
            while (p <= ParseCount)
            { 
                el := Parse%p%_1
                FoundPos := 0
                clipboard := RegExReplace(clipboard, "s)---..*$") ;;; Cut everything but first 2 lines
                FoundPos := RegExMatch(clipboard, el)
                if (FoundPos > 0)
                {
                    Stash%i%_%j% := Parse%p%_2
                    Stash%i%_%j%_p := p ;;; priority
                    break
                }
                p := p + 1
            }
        }
        el := Stash%i%_%j%
        if (LOGGING > 0) 
            FileAppend, %el%%A_Space%, inv.txt
        clipboard := ""
        j := j + 1
        if (j < 13)
        {
            MouseMove, _InvOffsetX, 0, SPEED, R
            Sleep, MOUSE_OVER_DELAY
        }    
        
    }
    MouseMove, -11*_InvOffsetX, _InvOffsetY, SPEED, R
    Sleep, MOUSE_OVER_DELAY
    i := i + 1
    if (LOGGING > 0) 
        FileAppend, `n, inv.txt
}


;;; Read info from inventory file
;;; Prepare classes parser
i := 1
Loop, read, %SORT_FILE%
{    
    StringSplit, Desire%i%_, A_LoopReadLine, %A_Space%
    i := i + 1
}

FoundX =  
FoundY = 

;;; Ctrl + click unlisted shit

i := 1
while (i < 13)
{
    j := 1
    while (j < 13)
    {
        el := Stash%i%_%j%
        if (el == UNLISTED)
        {   
            GetCoords(j, i)
            MouseMove, %FoundX%, %FoundY%, SPEED
            Sleep, MOUSE_OVER_DELAY
            Send ^{Click}
            Sleep, CLICK_DELAY
            Stash%i%_%j% := EMPTY_PLACE
        }
        j := j + 1
    } 
    i := i + 1
} 

;;; Now sort stash
FileDelete, log.txt
iter := 1
while (iter <= ParseCount)
{
    if (NOTIFICATIONS > 0) 
        TrayTip,Progress,%iter%/%ParseCount%,10
    i := 1
    while (i < 13)
    {
        j := 1
        while (j < 13)
        {
            
            
            el := Stash%i%_%j%
            if (LOGGING > 0) 
                FileAppend, `ni=%i% j=%j% el=%el%, log.txt
            if (el!=UNLISTED AND el!=EMPTY_PLACE)
            {
                des := Desire%i%_%j%
                if (el == des) ;;; Element already on it's place
                {
                    if (LOGGING > 0) 
                        FileAppend, el==des, log.txt
                    Stash%i%_%j% := UNLISTED
                    Desire%i%_%j% := UNLISTED
                }
                else
                {
                    res := FindPlace(i, j, iter)
                    if (LOGGING > 0) 
                        FileAppend, _res==%res%_ , log.txt
                    if (res < 0) ;;; Element couldn't be placed anywhere
                    {
                        Sleep, BETWEEN_ACTIONS_DELAY
                        if (LOGGING > 0) 
                            FileAppend, _disband element_ , log.txt
                        GetCoords(j, i)
                        MouseMove, %FoundX%, %FoundY%, SPEED
                        Sleep, MOUSE_OVER_DELAY
                        Send ^{Click}
                        Sleep, CLICK_DELAY
                        Stash%i%_%j% := EMPTY_PLACE
                    }
                    if (res > 0) ;;; Element can be placed
                    {
                        tmpx := FoundX
                        tmpy := FoundY
                        tmp:=Stash%tmpx%_%tmpy%
                        if (LOGGING > 0) 
                            FileAppend, _FoundX==%tmpx% FoundY==%tmpy% elem=%tmp%_, log.txt
                        
                        if (i==tmpx AND j == tmpy)
                        {
                            if (LOGGING > 0)    
                                FileAppend, _on it's place_ , log.txt
                            Stash%tmpx%_%tmpy% := UNLISTED
                            Desire%tmpx%_%tmpy% := UNLISTED
                        }
                        else if (Stash%i%_%j% == Stash%tmpx%_%tmpy%)
                        {
                            if (LOGGING > 0) 
                                FileAppend, _no need to swap_ , log.txt
                            Stash%tmpx%_%tmpy% := UNLISTED
                            Desire%tmpx%_%tmpy% := UNLISTED
                            j := j - 1
                        }                      
                        else
                        {
                            Sleep, BETWEEN_ACTIONS_DELAY
                            if (LOGGING > 0) 
                                FileAppend, _swapping_, log.txt
                            Swap(j, i, tmpy, tmpx)
                        
                            Stash%i%_%j% := Stash%tmpx%_%tmpy%
                            Stash%i%_%j%_p := Stash%tmpx%_%tmpy%_p
                            Stash%tmpx%_%tmpy% := UNLISTED
                            Desire%tmpx%_%tmpy% := UNLISTED
                            j := j - 1
                        }
                    }
                }
                
            }
            
            j := j + 1
        } 
        i := i + 1
    } 
    iter := iter + 1
}
if (NOTIFICATIONS > 0)
    TrayTip,Progress,Finished!,10





Swap(sx, sy, s1x, s1y)
{
    global
    GetCoords(sx, sy)
    MouseMove, %FoundX%, %FoundY%, SPEED
    Sleep, MOUSE_OVER_DELAY
    Send {Click}
    Sleep, CLICK_DELAY
    
    GetCoords(s1x, s1y)
    MouseMove, %FoundX%, %FoundY%, SPEED
    Sleep, MOUSE_OVER_DELAY
    Send {Click}
    Sleep, CLICK_DELAY
    
    swel := Stash%s1y%_%s1x%
    if (swel != EMPTY_PLACE)
    {
        GetCoords(sx, sy)
        MouseMove, %FoundX%, %FoundY%, SPEED
        Sleep, MOUSE_OVER_DELAY
        Send {Click}
        Sleep, CLICK_DELAY
    }
}


GetCoords(gcx, gcy)
{
    global
    FoundX := TOP_RIGHT_CORNER_X + (gcx-1)*_InvOffsetX
    FoundY := TOP_RIGHT_CORNER_Y + (gcy-1)*_InvOffsetY
}

FindPlace(fpx, fpy, iteration)
{
    global
    
    el := Stash%fpx%_%fpy%
    el_pr := Stash%fpx%_%fpy%_p

    
    local ii:=1
    local jj:=1
    while (ii < 13)
    {
        jj := 1
        while (jj < 13)
        {
            tmp := Desire%ii%_%jj%
            if (tmp == el)
            {
                FoundX := ii
                FoundY := jj
                return 1
            }
            jj := jj + 1
        } 
        ii := ii + 1
    } 
    
    if (LOGGING > 0) 
        FileAppend, _try any iter = %iteration% elpr == %el_pr%_ , log.txt
    if (iteration == el_pr)
    {
        ii := 1
        while (ii < 13)
        {
            jj := 1
            while (jj < 13)
            {
                tmp := Desire%ii%_%jj%
                if (tmp == ANY)
                {
                    FoundX := ii
                    FoundY := jj
                    return 2
                }
                jj := jj + 1
            } 
            ii := ii + 1
        }
        return -1
    }        
    
    return 0
}  
    
ExitApp 
Esc::ExitApp