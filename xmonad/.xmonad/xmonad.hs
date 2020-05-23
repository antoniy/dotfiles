-- -------- Modules {{{1
import XMonad
import Data.Monoid
import Data.Maybe (isJust)
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Config.Desktop

import XMonad.Layout
import XMonad.Layout.LimitWindows
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.ToggleLayouts (toggleLayouts)
import XMonad.Layout.PerWorkspace
import XMonad.Layout.OneBig
import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat) 
import XMonad.Hooks.InsertPosition

import XMonad.Util.Run(spawnPipe, hPutStrLn)
import XMonad.Util.SpawnOnce(spawnOnce)
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig (additionalKeysP, mkKeymap)  
import XMonad.Util.Themes

import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies, copyToAll)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.RotSlaves (rotSlavesDown, rotSlavesUp, rotAllDown, rotAllUp)
import XMonad.Actions.Promote (promote)

-- -------- Main {{{1

main = do
  bar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc0"
  bar1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc1"
  xmonad $ ewmh $ docks $ myConfig bar0 bar1 `additionalKeysP` myKeys

-- -------- Config {{{1

myTerm = "alacritty"

myConfig bar0 bar1 = desktopConfig 
  { terminal           = myTerm
  , focusFollowsMouse  = True
  , clickJustFocuses   = False
  , borderWidth        = 2
  , modMask            = mod4Mask
  , workspaces         = myWorkspaces
  , normalBorderColor  = "#292d3e"
  , focusedBorderColor = "#bbc5ff"
  , mouseBindings      = myMouseBindings
  , layoutHook         = myLayoutHook
  , manageHook         = insertPosition End Newer <+> myManageHook <+> manageHook desktopConfig <+> manageDocks <+> namedScratchpadManageHook scratchpads
  , handleEventHook    = myEventHook <+> fullscreenEventHook
  , logHook            = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ myPP bar0 bar1
  , startupHook        = myStartupHook
  } 

-- -------- Xmobar pretty prints {{{1

windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myPP bar0 bar1 = xmobarPP 
  { ppOutput          = \x -> hPutStrLn bar0 x  >> hPutStrLn bar1 x
  , ppCurrent         = xmobarColor "#c3e88d" "" . wrap "[" "]" -- Current workspace in xmobar
  , ppVisible         = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
  , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""  -- Hidden workspaces in xmobar
  , ppHiddenNoWindows = xmobarColor "#F07178" ""                -- Hidden workspaces (no windows)
  , ppTitle           = xmobarColor "#d0d0d0" "" . shorten 80   -- Title of active window in xmobar
  , ppSep             = "<fc=#666666> | </fc>"                  -- Separators in xmobar
  , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" -- Urgent workspace
  , ppExtras          = [windowCount]                           -- # of windows current workspace
  , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
  }

-- -------- Keybindings {{{1

xmonadExit       = io exitSuccess
xmonadRestart    = spawn "xmonad --recompile; xmonad --restart"

myKeys = 
  -- Xmonad
  [ ("M-S-r", xmonadRestart) -- Restarts xmonad
  , ("M-S-q", xmonadExit)    -- Quits xmonad
    
  -- Terminal
  , ("M-<Return>", spawn myTerm)

  -- Windows
  , ("M-S-c", kill1)   -- Kill the currently focused client
  , ("M-S-a", killAll) -- Kill all the windows on current workspace

  -- Floating windows
  , ("M-<Delete>"  , withFocused $ windows . W.sink) -- Push floating window back to tile.
  , ("M-S-<Delete>", sinkAll)                        -- Push ALL floating windows back to tile.

  -- Windows navigation
  , ("M-m"          , windows W.focusMaster)       -- Move focus to the master window
  , ("M-j"          , windows W.focusDown)         -- Move focus to the next window
  , ("M-k"          , windows W.focusUp)           -- Move focus to the prev window
  -- , ("M-S-m"        , windows W.swapMaster)        -- Swap the focused window and the master window
  , ("M-S-j"        , windows W.swapDown)          -- Swap the focused window with the next window
  , ("M-S-k"        , windows W.swapUp)            -- Swap the focused window with the prev window
  , ("M-<Backspace>", promote)                     -- Moves focused window to master, all others maintain order
  , ("M1-<Tab>"     , moveTo Next nonEmptyNonNSP)  -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M1-S-<Tab>"   , moveTo Prev nonEmptyNonNSP)  -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M-<Page_Up>"  , rotSlavesUp)                 -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M-<Page_Down>", rotSlavesDown)               -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M-<Home>"     , rotAllUp)                    -- (Alt-Ctrl-Tab) Rotate all the windows in the current stack
  , ("M-<End>"      , rotAllDown)                  -- (Alt-Ctrl-Tab) Rotate all the windows in the current stack
  , ("M-S-s"        , windows copyToAll)           -- Copy focused window to all workspaces
  , ("M-S-z"        , killAllOtherCopies)          -- Remove all other copies of the focused window
  
  -- Layouts
  , ("M-<Tab>"        , sendMessage NextLayout)         -- Switch to next layout
  , ("M-S-<Space>"    , sendMessage ToggleStruts)       -- Toggles struts
  , ("M-S-n"          , sendMessage $ Toggle NOBORDERS) -- Toggles noborder
  , ("M-z"            , zoom)                           -- Toggles noborder/full
  , ("M-S-m"          , sendMessage $ Toggle MIRROR)    -- Toggles mirror to the layout
  , ("M-\\"           , sendMessage $ Toggle REFLECTX)
  , ("M-S-\\"         , sendMessage $ Toggle REFLECTY)
  , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))     -- Increase number of clients in the master pane
  , ("M-<KP_Divide>"  , sendMessage (IncMasterN (-1)))  -- Decrease number of clients in the master pane

  -- Resize tile with meta+alt+{h,j,k,l}
  , ("M-M1-h", sendMessage Shrink)
  , ("M-M1-l", sendMessage Expand)
  , ("M-M1-j", sendMessage MirrorShrink)
  , ("M-M1-k", sendMessage MirrorExpand)

  -- Workspaces
  , ("M-."  , nextScreen)      -- Switch focus to next monitor
  , ("M-,"  , prevScreen)      -- Switch focus to prev monitor
  , ("M-S-.", shiftNextScreen) -- Shifts focused window to next screen
  , ("M-S-,", shiftPrevScreen) -- Shifts focused window to previous screen

  -- Scratchpads
  , ("<F12>"  , namedScratchpadAction scratchpads "scratchpad_tmux")
  , ("M-<F12>", namedScratchpadAction scratchpads "scratchpad_code")
  ] where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
          nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))
          zoom            = sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts

-- -------- Mouse bindings {{{1

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
  -- mod-button1, Set the window to floating mode and move by dragging
  [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
  -- mod-button2, Raise the window to the top of the stack
  , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
  -- mod-button3, Set the window to floating mode and resize by dragging
  , ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
  -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]

-- -------- Layouts {{{1

-- specify per-workspace layouts
wsLayouts idx layouts = onWorkspace (myWorkspaces !! idx) layouts

myLayoutHook = avoidStruts $ smartBorders $ toggleLayouts floats $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ 
  mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $
  wsLayouts 0 wwwLayouts $
  wsLayouts 1 chatLayouts $
  wsLayouts 2 devLayouts $
  myDefaultLayout 
  where 
    wwwLayouts = monocle ||| tall ||| tab
    chatLayouts = oneBig ||| grid ||| monocle ||| tab
    devLayouts = monocle ||| tall
    myDefaultLayout = tall ||| oneBig ||| grid ||| monocle ||| tab ||| floats

mySpacing = spacingRaw 
  True             -- smartBorders
  (Border 0 3 3 3) -- screen borders
  True             -- screen borders enabled
  (Border 5 5 5 5) -- window borders
  True             -- window borders enabled

tall    = renamed [Replace "tall"]    $ limitWindows 6  $ mySpacing $ mkToggle (single MIRROR) $ ResizableTall 1 (3/100) (1/2) []
grid    = renamed [Replace "grid"]    $ limitWindows 12 $ mySpacing $ mkToggle (single MIRROR) $ Grid (16/10)
oneBig  = renamed [Replace "oneBig"]  $ limitWindows 6  $ mySpacing $ mkToggle (single MIRROR) $ OneBig (5/9) (8/12)
monocle = renamed [Replace "monocle"] $ limitWindows 20 $ noBorders $ Full
tab     = renamed [Replace "tabbed"]  $ limitWindows 20 $ noBorders $ tabbed shrinkText (theme adwaitaDarkTheme)
floats  = renamed [Replace "floats"]  $ limitWindows 20 $ simplestFloat

-- -------- Workspaces {{{1

xmobarEscape = concatMap el
  where 
    el '<' = "<<"
    el x   = [x]
        
myWorkspaces :: [String]   
myWorkspaces = clickable . (map xmobarEscape) $ ["www","chat","dev","editor","game","media","audio","sys","aux"]
  where 
    clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                    (i, ws) <- zip [1..9] l,                                        
                    let n = i ] 

-- -------- Manage Hook {{{1

-- match window by class name, title or app name (resource)
matchApp c = className =? c <||> title =? c <||> resource =? c

-- move window to workspace (idx)
moveToWs idx = doShift (myWorkspaces !! idx)

myManageHook ::  ManageHook
myManageHook = composeAll . concat $
    [ [ isDialog     --> doCenterFloat               ]
    , [ isFullscreen --> doFullFloat                 ]
    , [ matchApp c   --> doIgnore      | c <- bars   ]
    , [ matchApp c   --> doFloat       | c <- float  ]
    , [ matchApp c   --> doCenterFloat | c <- cfloat ]
    , [ matchApp c   --> moveToWs 0    | c <- www    ]
    , [ matchApp c   --> moveToWs 1    | c <- chat   ]
    , [ matchApp c   --> moveToWs 2    | c <- dev    ]
    , [ matchApp c   --> moveToWs 3    | c <- editor ]
    , [ matchApp c   --> moveToWs 4    | c <- game   ]
    , [ matchApp c   --> moveToWs 5    | c <- media  ]
    , [ matchApp c   --> moveToWs 6    | c <- audio  ]
    , [ role =?  "browser"   --> moveToWs 0    | c <- www    ]
    ]
    where    
        bars   = ["xmobar", "trayer"]
        float  = ["nm-connection-editor", "jetbrains-toolbox"]
        cfloat = ["mpv", "Gimp-2.10"]
        www    = ["Chromium", "Brave-browser", "Mozilla Firefox"]
        chat   = ["ViberPC", "TelegramDesktop", "Slack", "discord", "Skype", "Keybase"]
        dev    = ["jetbrains-idea", "JetBrains Toolbox"]
        game   = ["Steam"]
        editor = ["libreoffice-calc", "libreoffice-writer", "VirtualBox", "libreoffice", "spacefm", "zathura", "code-oss", "Subl3"]
        media  = ["mpv", "vlc", "plexmediaplayer"]
        audio  = ["Audacity", "Pavucontrol"]
        role   = stringProperty "WM_WINDOW_ROLE"

myEventHook = mempty

-- -------- Startup {{{1

myStartupHook = do
  spawnOnce "trayer --edge top --align right --widthtype request --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282A36 --height 20 --monitor 0 --iconspacing 2 --padding 5 &"
  spawnOnce "brave &"
  spawnOnce "telegram-desktop &"
  spawnOnce "viber &"
  spawnOnce "slack &"
  spawnOnce "discord &"
  spawnOnce "pavucontrol &"
  
-- -------- Scratchpads {{{1

scratchpads = [ NS "scratchpad_tmux" spawnTerm findTerm manageTerm 
              , NS "scratchpad_code" spawnCode findCode manageCode 
              ] 
  where
    spawnTerm  = myTerm ++ " -t scratchpad_tmux -e 'tmuxdd'"
    findTerm   = title =? "scratchpad_tmux"
    manageTerm = customFloating $ W.RationalRect l t w h 
      where
        h = 0.9
        w = 0.9
        t = 0.95 -h
        l = 0.95 -w

    spawnCode  = "code-oss"
    findCode   = className =? "code-oss"
    manageCode = customFloating $ W.RationalRect l t w h 
      where
        h = 0.9
        w = 0.9
        t = 0.95 -h
        l = 0.95 -w

