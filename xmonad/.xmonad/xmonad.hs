-- -------- Modules {{{1
-- For quickly search where a keyword or a function is coming from 
-- go to https://hoogle.haskell.org/ and search for it.
import XMonad
import Data.Monoid
import Data.Maybe (isJust)
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Ratio ((%)) -- needed for IM layout

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
import XMonad.Layout.IfMax
import XMonad.Layout.ResizeScreen
import XMonad.Layout.IM

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat) 
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.SetWMName
import XMonad.Hooks.RefocusLast

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
import XMonad.Actions.Navigation2D

-- -------- Main {{{1

main = do
  bar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc0"
  bar1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc1"
  xmonad $ ewmh $ docks $ withNavigation2DConfig myNav2DConfig $ myConfig bar0 bar1 `additionalKeysP` myKeys

-- -------- Config {{{1

myTerm = "alacritty"

myConfig bar0 bar1 = desktopConfig 
  { terminal           = myTerm
  , focusFollowsMouse  = True
  , clickJustFocuses   = False
  , borderWidth        = 1
  , modMask            = mod4Mask
  , workspaces         = myWorkspaces
  , normalBorderColor  = "#292d3e"
  , focusedBorderColor = "#bbc5ff"
  , mouseBindings      = myMouseBindings
  , layoutHook         = myLayoutHook
  , manageHook         = myManageHook 
  , handleEventHook    = myEventHook
  , logHook            = myLogHook bar0 bar1
  , startupHook        = myStartupHook
  } 

-- -------- Navigation2D Config {{{1
myNav2DConfig = def
  { defaultTiledNavigation    = centerNavigation
  , floatNavigation           = centerNavigation
  , screenNavigation          = lineNavigation
  , layoutNavigation          = [("Monocle", centerNavigation)]
  , unmappedWindowRect        = [("Monocle", singleWindowRect)]
  }
-- -------- Log Hook and PP {{{1

windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myLogHook bar0 bar1 = dynamicLogWithPP 
  $ namedScratchpadFilterOutWorkspacePP 
  $ xmobarPP 
    { ppOutput          = (\x -> hPutStrLn bar0 x >> hPutStrLn bar1 x)
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
  -- -------- General {{{2
  [ ("M-S-r"     , xmonadRestart) -- Restarts xmonad
  , ("M-S-q"     , xmonadExit)    -- Quits xmonad
  , ("M-<Return>", spawn myTerm)  -- Spawn terminal
  , ("M-S-c"     , kill1)         -- Kill the currently focused client
  , ("M-S-a"     , killAll)       -- Kill all the windows on current workspace

  -- -------- Floating windows {{{2

  , ("M-<Delete>"  , withFocused $ windows . W.sink) -- Push floating window back to tile.
  , ("M-S-<Delete>", sinkAll)                        -- Push ALL floating windows back to tile.

  -- -------- Windows navigation {{{2

  , ("M-m"            , windows W.focusMaster)       -- Move focus to the master window
  , ("M-j"            , windows W.focusDown)         -- Move focus to the next window
  , ("M-k"            , windows W.focusUp)           -- Move focus to the prev window
  , ("M1-<Tab>"       , windows W.focusDown)         -- Move focus to the next window
  , ("M1-S-<Tab>"     , windows W.focusUp)           -- Move focus to the prev window
  -- , ("M-S-m"          , windows W.swapMaster)        -- Swap the focused window and the master window
  , ("M-S-j"          , windows W.swapDown)          -- Swap the focused window with the next window
  , ("M-S-k"          , windows W.swapUp)            -- Swap the focused window with the prev window
  , ("M-<Backspace>"  , promote)                     -- Moves focused window to master, all others maintain order
  , ("M-<Page_Up>"    , rotSlavesUp)                 -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M-<Page_Down>"  , rotSlavesDown)               -- (Alt-Shift-Tab) Rotate all windows except master and keep focus in place
  , ("M-S-<Page_Up>"  , rotAllUp)                    -- (Alt-Ctrl-Tab) Rotate all the windows in the current stack
  , ("M-S-<Page_Down>", rotAllDown)                  -- (Alt-Ctrl-Tab) Rotate all the windows in the current stack
  , ("M-S-s"          , windows copyToAll)           -- Copy focused window to all workspaces
  , ("M-S-z"          , killAllOtherCopies)          -- Remove all other copies of the focused window

  
  , ("M-<Space>", switchLayer) -- Switch between layers

  -- Directional navigation of windows
  , ("M-<Right>"  , windowGo R False)
  , ("M-<Left>"   , windowGo L False)
  , ("M-<Up>"     , windowGo U False)
  , ("M-<Down>"   , windowGo D False)

  , ("M-S-<Right>", windowSwap R False)
  , ("M-S-<Left>" , windowSwap L False)
  , ("M-S-<Up>"   , windowSwap U False)
  , ("M-S-<Down>" , windowSwap D False)
  
  -- -------- Layouts {{{2

  , ("M-<Tab>"        , sendMessage NextLayout)         -- Switch to next layout
  , ("M-S-<Space>"    , sendMessage ToggleStruts)       -- Toggles struts
  , ("M-S-n"          , sendMessage $ Toggle NOBORDERS) -- Toggles noborder

  , ("M-z"            , zoom)                           -- Toggles noborder/full - essentially zoom the window
  , ("M-S-m"          , sendMessage $ Toggle MIRROR)    -- Toggles mirror to the layout
  , ("M-\\"           , sendMessage $ Toggle REFLECTX)  -- Toggles horizontal reflection for the layout
  , ("M-S-\\"         , sendMessage $ Toggle REFLECTY)  -- Toggles vertical reflection for the layout
  , ("M-S-g"          , toggleScreenSpacingEnabled >> toggleWindowSpacingEnabled)  

  , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))     -- Increase number of clients in the master pane
  , ("M-<KP_Divide>"  , sendMessage (IncMasterN (-1)))  -- Decrease number of clients in the master pane

  -- , ("M-<KP_0>", sendMessage $ JumpToLayout "Monocle") -- switch to layout Monocle
  -- , ("M-<KP_1>", sendMessage $ JumpToLayout "Tall")    -- switch to layout Tall
  -- , ("M-<KP_2>", sendMessage $ JumpToLayout "Tabbed")  -- switch to layout Tabbed
  -- , ("M-<KP_3>", sendMessage $ JumpToLayout "Grid")    -- switch to layout Grid
  -- , ("M-<KP_4>", sendMessage $ JumpToLayout "OneBig")  -- switch to layout OneBig
  -- , ("M-<KP_5>", sendMessage $ JumpToLayout "IDE")     -- switch to layout IDE

  -- Resize tile with meta+alt+{h,j,k,l}
  , ("M-M1-h", sendMessage Shrink)
  , ("M-M1-l", sendMessage Expand)
  , ("M-M1-j", sendMessage MirrorShrink)
  , ("M-M1-k", sendMessage MirrorExpand)

  -- -------- Workspaces {{{2
  , ("M-x", moveTo Next HiddenNonEmptyWS) -- Cycle through not visible workspaces

  -- -------- Screens {{{2
  , ("M-."  , nextScreen)      -- Switch focus to next monitor
  , ("M-,"  , prevScreen)      -- Switch focus to prev monitor
  , ("M-S-.", shiftNextScreen) -- Move focused window to next screen
  , ("M-S-,", shiftPrevScreen) -- Move focused window to previous screen

  -- -------- Scratchpads{{{2
  , ("<F12>"  , namedScratchpadAction scratchpads "tmux")
  , ("M-<F12>", namedScratchpadAction scratchpads "note")
  , ("M-<F10>", namedScratchpadAction scratchpads "htop")
  , ("M-<F9>" , namedScratchpadAction scratchpads "pavucontrol")
  -- }}}
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

-- alias function to specify per-workspace layouts
wsLayouts idx layouts = onWorkspace (myWorkspaces !! idx) layouts

myLayoutHook = avoidStruts 
  $ refocusLastLayoutHook    -- refocus to last focused window when current window looses focus or is closed (default focuses the newest window)
  $ smartBorders             -- don't use borders on single window (on a single screen) and also if the window covers the entier screen (mpv)
  $ toggleLayouts floats     -- add ability to toggle floats on all layouts
  $ fullScreenToggle         -- adds the ability to toggle fullscreen for all layouts/windows
  $ reflectXToggle           -- add toggle for reflect on X on all layouts
  $ reflectYToggle           -- add toggle for reflect on Y on all layouts
  $ wsLayouts 0 wwwLayouts   -- set layout set for 'www' workspace
  $ wsLayouts 1 chatLayouts  -- set layout set for 'chat' workspace
  $ wsLayouts 2 devLayouts   -- set layout set for 'development' workspace
  $ wsLayouts 3 gameLayouts  -- set layout set for 'gaming' workspace
  $ myDefaultLayout          -- set the default layout set
  where 
    fullScreenToggle = mkToggle (NBFULL ?? NOBORDERS ?? EOT) -- alias for fullscreen toggle config
    reflectXToggle = mkToggle (single REFLECTX)              -- alias for reflect X toggle config
    reflectYToggle = mkToggle (single REFLECTY)              -- alias for reflect Y toggle config

    -- Define individual layout sets for specific workspaces and a default one
    wwwLayouts      = tab   ||| tall    ||| monocle 
    chatLayouts     = im    ||| grid    ||| tab     ||| monocle
    devLayouts      = ide   ||| tall    ||| tab     ||| monocle
    gameLayouts     = steam ||| monocle ||| tall    
    mediaLayouts    = tall  ||| grid    ||| tab     ||| monocle
    myDefaultLayout = tall  ||| oneBig  ||| grid    ||| tab      ||| monocle ||| floats

    -- Define default spacing configuration used by the layouts
    mySpacing    = mySpacing' 3 
    mySpacing' i = spacingRaw 
      True             -- smartBorders
      (Border 0 i i i) -- screen borders
      True             -- screen borders enabled
      (Border i i i i) -- window borders
      True             -- window borders enabled

    rename n = renamed [Replace n]

    -- Configure each individual layout - apply renaming, limiting windows, spacing, toggles, size/resize ratios, theming, etc.
    resizableTall = resizableTall' 3 1 (1/2) []
    resizableTall' sp nmaster ratio slaves = limitWindows 8 $ mySpacing' sp $ mkToggle (single MIRROR) $ ResizableTall nmaster (3/100) ratio slaves

    monocle = rename "Monocle" $ limitWindows 20 $ noBorders $ Full
    tall    = rename "Tall"    $ ifMax 1 monocle resizableTall
    grid    = rename "Grid"    $ ifMax 1 monocle $ limitWindows 12 $ mySpacing $ mkToggle (single MIRROR) $ Grid (16/10)
    oneBig  = rename "OneBig"  $ ifMax 1 monocle $ limitWindows 8  $ mySpacing $ mkToggle (single MIRROR) $ OneBig (5/9) (8/12)
    tab     = rename "Tabbed"  $ ifMax 1 monocle $ limitWindows 20 $ noBorders $ tabbed shrinkText $ theme adwaitaDarkTheme
    floats  = rename "Floats"  $ limitWindows 20 $ simplestFloat
    ide     = rename "IDE"     $ ifMax 1 monocle $ resizableTall' 0 2 (3/4) [1.66]
    im      = rename "IM"      $ ifMax 3 tall oneBig
    steam   = rename "Steam"   $ withIM (1%7) (Title "Friends List") tall ||| monocle


-- -------- Workspaces {{{1

xmobarEscape = concatMap el
  where 
    el '<' = "<<"
    el x   = [x]
        
myWorkspaces :: [String]   
myWorkspaces = clickable . (map xmobarEscape) $ 
  ["1:\xfa9e " -- browser
  ,"2:\xf860 " -- IMs
  ,"3:\xf66b " -- development
  ,"4:\xf1b7 " -- gaming
  ,"5:\xf04b " -- media
  ,"6:\xf013 " -- auxiliary
  ]
  where 
    clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                    (i, ws) <- zip [1..9] l,                                        
                    let n = i ] 

-- -------- Manage Hook {{{1

-- match window by class name, title or app name (resource)
matchApp c = className =? c <||> title =? c <||> resource =? c

-- move window to workspace (idx)
moveToWs idx = doShift (myWorkspaces !! idx)

-- myManageHook ::  ManageHook
myManageHook = insertPosition End Newer 
  <+> manageHook desktopConfig 
  <+> manageDocks 
  <+> namedScratchpadManageHook scratchpads
  <+> appsManageHook

appsManageHook = composeAll . concat $
  [ [ isDialog     --> doCenterFloat               ]
  , [ isFullscreen --> doFullFloat                 ]
  , [ matchApp c   --> doIgnore      | c <- bars   ]
  , [ matchApp c   --> doFloat       | c <- float  ]
  , [ matchApp c   --> doCenterFloat | c <- cfloat ]
  , [ matchApp c   --> moveToWs 0    | c <- www    ]
  , [ matchApp c   --> moveToWs 1    | c <- chat   ]
  , [ matchApp c   --> moveToWs 2    | c <- dev    ]
  , [ matchApp c   --> moveToWs 3    | c <- game   ]
  , [ matchApp c   --> moveToWs 4    | c <- media  ]
  , [ role =?  "browser"   --> moveToWs 0    | c <- www    ]
  ]
  where    
      bars   = ["xmobar", "trayer"]
      float  = ["nm-connection-editor", "jetbrains-toolbox", "Xmessage"]
      cfloat = ["mpv", "Gimp-2.10"]
      www    = ["Chromium", "Brave-browser", "Mozilla Firefox"]
      chat   = ["ViberPC", "TelegramDesktop", "Slack", "discord", "Skype", "Keybase", "Microsoft Teams - Preview"]
      dev    = ["jetbrains-idea", "JetBrains Toolbox"]
      game   = ["Steam"]
      media  = ["mpv", "vlc", "plexmediaplayer", "Audacity"]
      role   = stringProperty "WM_WINDOW_ROLE"

-- -------- Event Hook {{{1

-- Description:
--
-- * refocusLastWhen: we use that so we can automatically focus back to 
--   previously focused window when the current one is lost. Extremely important
--   when working with IDEs and their dialogs. Otherwise we loose focus for the IDE.
--
-- * 
myEventHook = refocusLastWhen myPred <+> fullscreenEventHook
  where
    myPred = refocusingIsActive <||> isFloat

-- -------- Startup {{{1

myStartupHook = do
  setWMName "LG3D"
  spawnOnce "trayer --edge top --align right --widthtype request --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282A36 --height 20 --monitor 0 --iconspacing 2 --padding 5 &"
  spawnOnce "brave &"
  spawnOnce "telegram-desktop &"
  spawnOnce "viber &"
  spawnOnce "slack &"
  
-- -------- Scratchpads {{{1

nsFloat l t w h = customFloating $ W.RationalRect l t w h

scratchpads = [ NS "tmux"        spawnTerm findTerm manageTerm 
              , NS "note"        spawnNote findNote manageNote 
              , NS "pavucontrol" spawnVol  findVol  manageVol
              , NS "htop"        spawnTop  findTop  manageTop
              -- , NS "pavucontrol" "pavucontrol" (className =? "Pavucontrol") nsFloat 
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

    spawnNote  = "code-oss"
    findNote   = className =? "code-oss"
    manageNote = customFloating $ W.RationalRect l t w h 
      where
        h = 0.9
        w = 0.9
        t = 0.95 -h
        l = 0.95 -w

    spawnVol  = "pavucontrol"
    findVol   = className =? "Pavucontrol"
    manageVol = customFloating $ W.RationalRect l t w h 
      where
        h = 0.7
        w = 0.5
        t = (0.95 -h) / 2
        l = (0.95 -w) / 2

    spawnTop  = myTerm ++ " -t scratchpad_htop -e htop"
    findTop   = title =? "scratchpad_htop"
    manageTop = customFloating $ W.RationalRect l t w h 
      where
        h = 0.9
        w = 0.9
        t = 0.95 -h
        l = 0.95 -w

