import XMonad
import Data.Monoid
import Data.Maybe (isJust)
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Config.Desktop

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat) 

import XMonad.Util.Run(spawnPipe, hPutStrLn)
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig (additionalKeysP, mkKeymap)  

import XMonad.Layout
import XMonad.Layout.LimitWindows
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.NoBorders (noBorders)
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.GridVariants (Grid(Grid))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
-- import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))

import XMonad.Actions.MouseResize
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies, copyToAll)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.Promote (promote)
-- import XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)

main = do
  bar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc"
  bar1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc"
  xmonad $ ewmh $ docks $ myConfig bar0 bar1 `additionalKeysP` myKeys

-- -------- Config {{{1

myTerminal = "alacritty"
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myConfig bar0 bar1 = desktopConfig 
  { terminal           = myTerminal
  , focusFollowsMouse  = True
  , clickJustFocuses   = False
  , borderWidth        = 2
  , modMask            = mod4Mask
  , workspaces         = myWorkspaces
  , normalBorderColor  = "#292d3e"
  , focusedBorderColor = "#bbc5ff"
  -- , keys               = myKeys
  , mouseBindings      = myMouseBindings
  , layoutHook         = myLayoutHook
  , manageHook         = ( isFullscreen --> doFullFloat) <+> myManageHook <+> manageHook desktopConfig <+> manageDocks
  , handleEventHook    = myEventHook
  , logHook            = dynamicLogWithPP $ myPP bar0 bar1
  , startupHook        = myStartupHook
  } 

-- -------- Xmobar pretty prints {{{1

myPP bar0 bar1 = xmobarPP 
  { ppOutput = \x -> hPutStrLn bar0 x  >> hPutStrLn bar1 x
  , ppCurrent = xmobarColor "#c3e88d" "" . wrap "[" "]" -- Current workspace in xmobar
  , ppVisible = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
  , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
  , ppHiddenNoWindows = xmobarColor "#F07178" ""        -- Hidden workspaces (no windows)
  , ppTitle = xmobarColor "#d0d0d0" "" . shorten 80     -- Title of active window in xmobar
  , ppSep =  "<fc=#666666> | </fc>"                     -- Separators in xmobar
  , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
  , ppExtras  = [windowCount]                           -- # of windows current workspace
  , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
  }

-- -------- Keybindings {{{1

xmonadExit       = io exitSuccess
xmonadRestart    = spawn "xmonad --recompile; xmonad --restart"

myKeys = 
  -- Xmonad
  [ ("M-S-r", xmonadRestart)        -- Restarts xmonad
  , ("M-S-q", xmonadExit)                  -- Quits xmonad
    
  -- Terminal
  , ("M-<Return>", spawn myTerminal)

  -- Windows
  , ("M-S-c", kill1)                           -- Kill the currently focused client
  , ("M-S-a", killAll)                         -- Kill all the windows on current workspace

  -- Floating windows
  , ("M-<Delete>", withFocused $ windows . W.sink)  -- Push floating window back to tile.
  , ("M-S-<Delete>", sinkAll)                  -- Push ALL floating windows back to tile.

  -- Windows navigation
  , ("M-m", windows W.focusMaster)             -- Move focus to the master window
  , ("M-j", windows W.focusDown)               -- Move focus to the next window
  , ("M-k", windows W.focusUp)                 -- Move focus to the prev window
  , ("M-S-m", windows W.swapMaster)            -- Swap the focused window and the master window
  , ("M-S-j", windows W.swapDown)              -- Swap the focused window with the next window
  , ("M-S-k", windows W.swapUp)                -- Swap the focused window with the prev window
  , ("M-<Backspace>", promote)                 -- Moves focused window to master, all others maintain order
  , ("M1-S-<Tab>", rotSlavesDown)              -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M1-C-<Tab>", rotAllDown)                 -- (Alt-Ctrl-Tab) Rotate all the windows in the current stack
  , ("M-S-s", windows copyToAll)  
  , ("M-C-s", killAllOtherCopies) 
  
  , ("M-C-M1-<Up>", sendMessage Arrange)
  , ("M-C-M1-<Down>", sendMessage DeArrange)
  , ("M-<Up>", sendMessage (MoveUp 10))             --  Move focused window to up
  , ("M-<Down>", sendMessage (MoveDown 10))         --  Move focused window to down
  , ("M-<Right>", sendMessage (MoveRight 10))       --  Move focused window to right
  , ("M-<Left>", sendMessage (MoveLeft 10))         --  Move focused window to left
  , ("M-S-<Up>", sendMessage (IncreaseUp 10))       --  Increase size of focused window up
  , ("M-S-<Down>", sendMessage (IncreaseDown 10))   --  Increase size of focused window down
  , ("M-S-<Right>", sendMessage (IncreaseRight 10)) --  Increase size of focused window right
  , ("M-S-<Left>", sendMessage (IncreaseLeft 10))   --  Increase size of focused window left
  , ("M-C-<Up>", sendMessage (DecreaseUp 10))       --  Decrease size of focused window up
  , ("M-C-<Down>", sendMessage (DecreaseDown 10))   --  Decrease size of focused window down
  , ("M-C-<Right>", sendMessage (DecreaseRight 10)) --  Decrease size of focused window right
  , ("M-C-<Left>", sendMessage (DecreaseLeft 10))   --  Decrease size of focused window left

  -- Layouts
  , ("M-<Tab>", sendMessage NextLayout)                              -- Switch to next layout
  , ("M-S-<Space>", sendMessage ToggleStruts)                          -- Toggles struts
  , ("M-S-n", sendMessage $ Toggle NOBORDERS)                          -- Toggles noborder
  , ("M-S-=", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
  , ("M-S-f", sendMessage (T.Toggle "float"))
  -- , ("M-S-x", sendMessage $ Toggle REFLECTX)
  -- , ("M-S-y", sendMessage $ Toggle REFLECTY)
  , ("M-S-m", sendMessage $ Toggle MIRROR)
  , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))   -- Increase number of clients in the master pane
  , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))  -- Decrease number of clients in the master pane
  , ("M-S-<KP_Multiply>", increaseLimit)              -- Increase number of windows that can be shown
  , ("M-S-<KP_Divide>", decreaseLimit)                -- Decrease number of windows that can be shown

  , ("M-h", sendMessage Shrink)
  , ("M-l", sendMessage Expand)
  , ("M-C-j", sendMessage MirrorShrink)
  , ("M-C-k", sendMessage MirrorExpand)
  -- , ("M-S-;", sendMessage zoomReset)
  -- , ("M-;", sendMessage ZoomFullToggle)

  -- Workspaces
  , ("M-.", nextScreen)                           -- Switch focus to next monitor
  , ("M-,", prevScreen)                           -- Switch focus to prev monitor
  , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next workspace
  , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to previous workspace

  -- Scratchpads
  , ("<F12>", namedScratchpadAction scratchpads "scratchpad_tmux")
  ] where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
          nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))

-- -------- Mouse bindings {{{1

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
  -- mod-button1, Set the window to floating mode and move by dragging
  [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                     >> windows W.shiftMaster))
  -- mod-button2, Raise the window to the top of the stack
  , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
  -- mod-button3, Set the window to floating mode and resize by dragging
  , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                     >> windows W.shiftMaster))
  -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

-- -------- Layouts {{{1

myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ myDefaultLayout 
  where 
    myDefaultLayout = tall ||| noBorders monocle ||| tab ||| grid ||| floats
    -- myDefaultLayout = tall ||| grid ||| threeCol ||| threeRow ||| oneBig ||| noBorders monocle ||| space ||| floats

tall       = renamed [Replace "tall"]     $ limitWindows 6 $ spacing 5 $ ResizableTall 1 (3/100) (1/2) []
monocle    = renamed [Replace "monocle"]  $ limitWindows 20 $ Full
tab        = renamed [Replace "tabbed"]   $ limitWindows 20 $ simpleTabbed
floats     = renamed [Replace "floats"]   $ limitWindows 20 $ simplestFloat
grid       = renamed [Replace "grid"]     $ limitWindows 12 $ spacing 5 $ mkToggle (single MIRROR) $ Grid (16/10)
-- threeCol   = renamed [Replace "threeCol"] $ limitWindows 3  $ ThreeCol 1 (3/100) (1/2) 
-- threeRow   = renamed [Replace "threeRow"] $ limitWindows 3  $ Mirror $ mkToggle (single MIRROR) zoomRow
-- oneBig     = renamed [Replace "oneBig"]   $ limitWindows 6  $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (5/9) (8/12)
-- space      = renamed [Replace "space"]    $ limitWindows 4  $ spacing 12 $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (2/3) (2/3)

-- -------- Workspaces {{{1

xmobarEscape = concatMap doubleLts
  where 
    doubleLts '<' = "<<"
    doubleLts x   = [x]
        
myWorkspaces :: [String]   
myWorkspaces = clickable . (map xmobarEscape) $ ["www","im","dev","steam","sys","6","7","8","9"]
  where 
    clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                    (i, ws) <- zip [1..9] l,                                        
                    let n = i ] 

-- -------- Other hooks {{{1

myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll 
  [ className  =? "Brave"    --> doShift "www"
  , title      =? "Steam"    --> doShift "steam"
  , className  =? "Gimp"     --> doFloat
  , className  =? "mpv"      --> doFloat
  , className  =? "viber"    --> doShift "im"
  , title      =? "Telegram" --> doShift "im"
  , (className =? "Firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
  ] <+> namedScratchpadManageHook scratchpads

myEventHook = mempty

myStartupHook = return ()  

-- -------- Scratchpads {{{1
scratchpads = [ NS "scratchpad_tmux" spawnTerm findTerm manageTerm ] 
  where
    spawnTerm  = myTerminal ++ " -t scratchpad_tmux -e 'tmux'"
    findTerm   = title =? "scratchpad_tmux"
    manageTerm = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
