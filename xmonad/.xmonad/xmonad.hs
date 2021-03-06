-- __  ____  __                       _    __              _     _________    _    ____
-- \ \/ /  \/  | ___  _ __   __ _  __| |  / _| ___  _ __  | |   |__  / ___|  / \  / ___|
--  \  /| |\/| |/ _ \| '_ \ / _` |/ _` | | |_ / _ \| '__| | |     / /|___ \ / _ \| |
--  /  \| |  | | (_) | | | | (_| | (_| | |  _| (_) | |    | |___ / /_ ___) / ___ \ |___
-- /_/\_\_|  |_|\___/|_| |_|\__,_|\__,_| |_|  \___/|_|    |_____/____|____/_/   \_\____|

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
import System.IO (hClose, hPutStr)
import Control.Exception (bracket)

import XMonad.Config.Desktop


import XMonad.Layout

import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation

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
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat, composeOne, (-?>), transience') 
-- import XMonad.Hooks.InsertPosition
import XMonad.Hooks.SetWMName
-- import XMonad.Hooks.RefocusLast

import XMonad.Util.Run(spawnPipe, hPutStrLn)
import XMonad.Util.SpawnOnce(spawnOnce)
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig (additionalKeysP, mkKeymap, mkNamedKeymap, removeKeysP)  
import XMonad.Util.Themes
import XMonad.Util.NamedActions

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
  xmonad $ ewmh $ docks $ addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) myKeys $ myConfig bar0 bar1

-- -------- Config {{{1

myTerm = "alacritty"

myConfig bar0 bar1 = def
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
  -- , keys               = return ()
  } 
-- -------- Theme {{{1
tabTheme = def 
  { activeColor         = "#2d2d2d"
  , inactiveColor       = "#353535"
  , urgentColor         = "#15539e"
  , activeBorderColor   = "#070707"
  , inactiveBorderColor = "#1c1c1c"
  , urgentBorderColor   = "#030c17"
  , activeTextColor     = "#eeeeec"
  , inactiveTextColor   = "#929291"
  , urgentTextColor     = "#ffffff"
  , fontName            = "xft:Cantarell:bold:size=11"
  , decoWidth           = 400
  , decoHeight          = 25
  }
-- -------- Log Hook and PP {{{1

windowCount = gets $ Just . xmobarColor "#fe8019" "" . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myLogHook bar0 bar1 = 
  ( dynamicLogWithPP 
  $ namedScratchpadFilterOutWorkspacePP 
  $ xmobarPP 
    { ppOutput          = (\x -> hPutStrLn bar0 x >> hPutStrLn bar1 x)
    , ppCurrent         = xmobarColor "#8ec07c" "" . wrap "[" "]" -- Current workspace in xmobar
    , ppVisible         = xmobarColor "#8ec07c" ""                -- Visible but not current workspace
    , ppHidden          = xmobarColor "#d5c4a1" "" . wrap "*" ""  -- Hidden workspaces in xmobar
    , ppHiddenNoWindows = xmobarColor "#928374" ""                -- Hidden workspaces (no windows)
    , ppTitle           = xmobarColor "#ebdbb2" "" . shorten 80   -- Title of active window in xmobar
    , ppLayout          = xmobarColor "#b16286" ""
    , ppSep             = "<fc=#928374> | </fc>"                  -- Separators in xmobar
    , ppUrgent          = xmobarColor "#cc241d" "" . wrap "!" "!" -- Urgent workspace
    -- , ppExtras          = [(xmobarColor "#b16286" "" windowCount)]                           -- # of windows current workspace
    , ppExtras          = [windowCount]                           -- # of windows current workspace
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    }
  )

-- -------- Keybindings {{{1

myKeys c =
  -- -------- General {{{2
  titleSection c "General"
    [ ("M-S-r"          , addName "Recompile & restart"    $ spawn "xmonad --recompile; xmonad --restart")
    , ("M-S-q"          , addName "Quit"                   $ io exitSuccess)
    , ("M-<Return>"     , addName "Start terminal"         $ spawn myTerm)
    , ("M-S-c"          , addName "Close window"           $ kill1)
    , ("M-S-a"          , addName "Close all"              $ killAll)
    ]

  -- -------- System {{{2
  ^++^ titleSection c "System"
    -- [ ("S-<Print>"      , addName "Screenshot region copy" $ spawn "maim -s | xclip -selection clipboard -t image/png")
    [ ("M-S-<Print>"    , addName "Screenshot region copy" $ spawn "~/.local/bin/screenshot copy-region")
    , ("C-M1-<Delete>"  , addName "Lock Screen"            $ spawn "i3lock -c 000000")
    , ("M1-q"           , addName "Application launcher"   $ spawn "j4-dmenu-desktop")
    , ("M1-S-q"         , addName "Command launcher"       $ spawn "dmenu_run")
    , ("M-S-<Escape>"   , addName "Leave Xorg"             $ spawn "prompt 'Leave Xorg?' 'killall Xorg'")
    ]
  -- -------- Floating windows {{{2

  ^++^ titleSection c "Floating windows"
    [ ("M-<Delete>"     , addName "Floating to tile"       $ withFocused $ windows . W.sink)
    , ("M-S-<Delete>"   , addName "ALL floating to tile"   $ sinkAll)
    , ("M-<Space>"      , addName "Switch between layers"  $ switchLayer)
    ]

  -- -------- Windows navigation {{{2

  ^++^ titleSection c "Window navigation"
    [ ("M-m"            , addName "Focus master"           $ windows W.focusMaster)
    , ("M-j"            , addName "Focus down"             $ windows W.focusDown)
    , ("M-k"            , addName "Focus up"               $ windows W.focusUp)
    , ("M1-<Tab>"       , addName "Focus down"             $ windows W.focusDown)
    , ("M1-S-<Tab>"     , addName "Focus up"               $ windows W.focusUp)
    -- , ("M-S-m"         , windows W.swapMaster)
    , ("M-S-j"          , addName "Swap down"              $ windows W.swapDown)
    , ("M-S-k"          , addName "Swap up"                $ windows W.swapUp)
    , ("M-<Backspace>"  , addName "Promote to master"      $ promote)
    , ("M-<Page_Up>"    , addName "Rotate slaves up"       $ rotSlavesUp)
    , ("M-<Page_Down>"  , addName "Rotate slaves down"     $ rotSlavesDown)
    , ("M-S-<Page_Up>"  , addName "Rotate ALL up"          $ rotAllUp)
    , ("M-S-<Page_Down>", addName "Rotate ALL down"        $ rotAllDown)
    , ("M-S-s"          , addName "Copy to all workspaces" $ windows copyToAll)
    , ("M-S-z"          , addName "Remove all copies"      $ killAllOtherCopies)
    ]

  -- -------- Layouts {{{2

  ^++^ titleSection c "Layouts"
    [ ("M-<Tab>"        , addName "Go to next layout"      $ sendMessage NextLayout)
    , ("M-S-<Space>"    , addName "Toggle struts"          $ sendMessage ToggleStruts)
    , ("M-S-n"          , addName "Toggle NOBORDERS"       $ sendMessage $ Toggle NOBORDERS)

    , ("M-z"            , addName "Toggle Zoom"            $ toggleZoom)
    , ("M-S-m"          , addName "Toggle MIRROR"          $ sendMessage $ Toggle MIRROR)
    , ("M-\\"           , addName "Toggle ReflectX"        $ sendMessage $ Toggle REFLECTX)
    , ("M-S-\\"         , addName "Toggle ReflectY"        $ sendMessage $ Toggle REFLECTY)
    , ("M-S-g"          , addName "Toggle Spacing"         $ toggleScreenSpacingEnabled >> toggleWindowSpacingEnabled)

    , ("M-<KP_Multiply>", addName "Inc master windows cnt" $ sendMessage (IncMasterN 1))
    , ("M-<KP_Divide>"  , addName "Dec master windows cnt" $ sendMessage (IncMasterN (-1)))

    -- Resize tile with meta+alt+{h,j,k,l}
    , ("M-M1-h"         , addName "Shrink"                 $ sendMessage Shrink)
    , ("M-M1-l"         , addName "Expand"                 $ sendMessage Expand)
    , ("M-M1-j"         , addName "Mirror Shrink"          $ sendMessage MirrorShrink)
    , ("M-M1-k"         , addName "Mirror Expand"          $ sendMessage MirrorExpand)

    , ("M-C-h"          , addName "Pull group L"           $ sendMessage $ pullGroup L)
    , ("M-C-l"          , addName "Pull group R"           $ sendMessage $ pullGroup R)
    , ("M-C-k"          , addName "Pull group U"           $ sendMessage $ pullGroup U)
    , ("M-C-j"          , addName "Pull group D"           $ sendMessage $ pullGroup D)
    , ("M-C-m"          , addName "Merge All"              $ withFocused (sendMessage . MergeAll))
    , ("M-C-u"          , addName "UnMerge"                $ withFocused (sendMessage . UnMerge))
    , ("M-C-,"          , addName "Focus Up"               $ onGroup W.focusUp')
    , ("M-C-."          , addName "Focus Down"             $ onGroup W.focusDown')
    ]

  -- -------- Screens {{{2
  ^++^ titleSection c "Screen"
    [ ("M-."            , addName "Focus next screen"      $ nextScreen)
    , ("M-,"            , addName "Focus prev screen"      $ prevScreen)
    , ("M-S-."          , addName "Move to next screen"    $ shiftNextScreen)
    , ("M-S-,"          , addName "Move to prev screen"    $ shiftPrevScreen)
    ]

  -- -------- Scratchpads{{{2
  ^++^ titleSection c "Scratchpads"
    [ ("<F12>"          , addName "Toggle Tmux"            $ toggleNSP "tmux")
    , ("M-<F11>"        , addName "Toggle Notes"           $ toggleNSP "note")
    , ("M-<F10>"        , addName "Toggle bitwarden"       $ toggleNSP "bitwarden")
    , ("M-<F9>"         , addName "Toggle Pavucontrol"     $ toggleNSP "pavucontrol")
    , ("M-S-<F9>"       , addName "Toggle XAir"            $ toggleNSP "xair")
    , ("M-<F8>"         , addName "Toggle calculator"      $ toggleNSP "calculator")
    , ("M-<F7>"         , addName "Toggle htop"            $ toggleNSP "htop")
    ] 
  -- -------- Krasi Songs{{{2
  ^++^ titleSection c "Songs shortcuts"
    [ ("M-M1-1"         , addName "Play 'Aram zam zam'"    $ spawn "mpv --loop=5 ~/Music/krasi/aram-zam-zam.mp3")
    , ("M-M1-2"         , addName "Play 'Ako si vesel'"    $ spawn "mpv --loop=5 ~/Music/krasi/ako-si-vesel-i-shtastliv.mp3")
    , ("M-M1-3"         , addName "Play 'Bram bram bram'"  $ spawn "mpv --loop=5 ~/Music/krasi/bram-bram-bram.mp3")
    , ("M-M1-9"         , addName "Play All"               $ spawn "mpv --loop-playlist=5 ~/Music/krasi/*.mp3")
    , ("M-M1-0"         , addName "Stop all playback"      $ spawn "pkill mpv")
    ]

  -- -------- Workspaces {{{2
  ^++^ titleSection c "Workspaces"
    ( [ ("M-x", addName "Cycle through not visible workspaces" $ moveTo Next HiddenNonEmptyWS) ]
      ++ 
      [ ("M-" ++ m ++ k, addName (desc ++ k) $ f i)
        | (i, k) <- zip myWorkspaces (map show [1..9])
        , (f, m, desc) <- [(windows . W.greedyView, "", "Switch to workspace "), (\i -> windows (W.shift i) >> windows (W.greedyView i), "S-", "Move window to workspace ")]]
      ++ 
      [ ("M-" ++ m ++ k, addName (desc ++ (show sc)) (screenWorkspace sc >>= flip whenJust (windows . f)))
        | (k, sc) <- zip ["w", "e"] [0..]
        , (f, m, desc) <- 
          [ (W.view , ""  , "Change screen to ")
          , (W.shift, "S-", "Move to screen "  ) ]
      ]
    )

  -- }}}

-- utility function for defining a named section for NamedActions
titleSection c title keys = (subtitle title :) $ mkNamedKeymap c keys

nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))
toggleZoom      = sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts
toggleNSP n     = namedScratchpadAction scratchpads n

showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ bracket
  -- (spawnPipe "yad --text-info --font='FiraCode Nerd Font'")
  (spawnPipe "yad --text-info")
  hClose
  (\h -> hPutStr h (unlines $ showKm x))

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

myLayoutHook = avoidStruts 
  $ windowNavigation
  -- $ subTabbed
  $ addTabs shrinkText tabTheme
  $ smartBorders             -- don't use borders on single window (on a single screen) and also if the window covers the entier screen (mpv)
  -- $ refocusLastLayoutHook    -- refocus to last focused window when current window looses focus or is closed (default focuses the newest window)
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
    -- toggle aliases
    fullScreenToggle = mkToggle (NBFULL ?? NOBORDERS ?? EOT) -- alias for fullscreen toggle config
    reflectXToggle = mkToggle (single REFLECTX)              -- alias for reflect X toggle config
    reflectYToggle = mkToggle (single REFLECTY)              -- alias for reflect Y toggle config

    -- alias function to specify per-workspace layouts
    wsLayouts idx layouts = onWorkspace (myWorkspaces !! idx) layouts

    -- Define individual layout sets for specific workspaces and a default one
    wwwLayouts      = tab   ||| tall    ||| dtall   ||| monocle 
    chatLayouts     = im    ||| grid    ||| tall    ||| tab     ||| monocle
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

    -- alias function for rename
    rename n = renamed [Replace n]

    -- configure reusable ResizableTile layout with common modifiers and an alternative with some parameters
    resizableTile = resizableTile' 3 1 (1/2) []
    resizableTile' sp nmaster ratio slaves = limitWindows 8 $ mySpacing' sp $ mkToggle (single MIRROR) $ ResizableTall nmaster (3/100) ratio slaves

    -- Configure each individual layout - apply renaming, limiting windows, spacing, toggles, size/resize ratios, theming, etc.
    monocle = rename "Monocle" $ limitWindows 20 $ noBorders $ Full
    tall    = rename "Tall"    $ ifMax 1 monocle resizableTile
    dtall   = rename "dTall"   $ ifMax 1 monocle $ subLayout [] Simplest resizableTile 
    grid    = rename "Grid"    $ ifMax 1 monocle $ limitWindows 12 $ mySpacing $ mkToggle (single MIRROR) $ Grid (16/10)
    oneBig  = rename "OneBig"  $ ifMax 1 monocle $ limitWindows 8  $ mySpacing $ mkToggle (single MIRROR) $ OneBig (5/9) (8/12)
    tab     = rename "Tabbed"  $ limitWindows 20 $ noBorders $ tabbed shrinkText tabTheme
    floats  = rename "Floats"  $ limitWindows 20 $ simplestFloat

    -- Default IDE layout depends on number of windows visible on the workspace. The aim was to create 
    -- dynamically scalable layout based on development workflow with a simple layout configuration.
    --  * if 1 window - switch to Monocle layout to have fullscreen + bars but no spacing or borders
    --
    -- +-------------------------------+
    -- |                               |
    -- |                               |
    -- |                               |
    -- |                               |
    -- |           Master              |
    -- |                               |
    -- |                               |
    -- |                               |
    -- |                               |
    -- +-------------------------------+
    --
    --  * if 2 or more windows - switch to ResizableTile configured in a specific way - 2 master windows 
    --    with the first one being way taller (1.66), all slave windows are on the right and have 1/4 of 
    --    the horizontal space (look at the second graph below).
    --
    -- +-------------------------------+
    -- |                               |
    -- |                               |
    -- |                               |
    -- |           Master              |
    -- |                               |
    -- |                               |
    -- |                               |
    -- +-------------------------------+
    -- |           Slave 1             |
    -- +-------------------------------+
    --
    --  * if 3 or more windows are opened, the layout looks as follows:
    --
    -- +--------------------+----------+
    -- |                    |          |
    -- |                    |  Slave 2 |
    -- |                    |          |
    -- |       Master       +----------+
    -- |                    |          |
    -- |                    |  Slave 3 |
    -- |                    |          |
    -- +--------------------+----------+
    -- |     Slave 1        |  Slave 4 |
    -- +--------------------+----------+
    ide     = rename "IDE"     $ ifMax 1 monocle $ resizableTile' 0 2 (3/4) [1.66]

    -- Default chat layout which uses 
    --   * Monocle when there is a single window
    --   * Tall for 2 and 3 windows 
    --   * Grid for 4 windows 
    --   * OneBig for 5 and more windows
    im      = rename "IM"      $ ifMax 3 tall $ ifMax 4 grid oneBig

    -- Steam layout is used for gaming. For Steam client specifically we want to position the friend list on the 
    -- left vertically, taking 1/7 of the space and use the remaining space with some common layout - 'tall' in 
    -- our case. If no friend list has opened, the layout is just a normal 'tall'
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
  ] ++ (map show [7..9])
  where 
    clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                    (i, ws) <- zip [1..9] l,                                        
                    let n = i ] 

-- -------- Manage Hook {{{1

-- myManageHook ::  ManageHook
myManageHook = manageDocks 
  <+> namedScratchpadManageHook scratchpads
  <+> transience'
  <+> appsManageHook

appsManageHook = composeOne . concat $
  -- [ [ isDialog     -?> floatInsert <+> doCenterFloat               ]
  -- , [ isFullscreen -?> floatInsert <+> doFullFloat                 ]
  -- , [ matchApp c   -?> floatInsert <+> doCenterFloat | c <- float  ]
  [ [ isDialog     -?> doCenterFloat               ]
  , [ isFullscreen -?> doFullFloat                 ]
  , [ matchApp c   -?> doCenterFloat | c <- float  ]
  , [ matchApp c   -?> doIgnore      | c <- bars   ]
  , [ matchApp c   -?> toWs 0        | c <- www    ]
  , [ matchApp c   -?> toWs 1        | c <- chat   ]
  , [ matchApp c   -?> toWs 2        | c <- dev    ]
  , [ matchApp c   -?> toWs 3        | c <- game   ]
  , [ matchApp c   -?> toWs 4        | c <- media  ]
  -- , [ pure True    -?> normInsert                                  ]
  ]
  where    
      bars   = ["xmobar", "trayer"]
      float  = ["nm-connection-editor", "jetbrains-toolbox", "Xmessage", "SimpleScreenRecorder", "mpv", "Gimp-2.10", "Steam - News", "Qalculate-gtk"]
      www    = ["Chromium", "Brave-browser", "Mozilla Firefox"]
      chat   = ["ViberPC", "TelegramDesktop", "Slack", "discord", "Skype", "Keybase", "Microsoft Teams - Preview", "Signal", "Hexchat"]
      dev    = ["jetbrains-idea", "JetBrains Toolbox"]
      game   = ["Steam", "csgo_linux64"]
      media  = ["mpv", "vlc", "plexmediaplayer", "Audacity"]
      role   = stringProperty "WM_WINDOW_ROLE"

      -- move window to workspace (idx)
      -- toWs idx = normInsert <+> doShift (myWorkspaces !! idx)
      toWs idx = doShift (myWorkspaces !! idx)

      -- match window by class name, title or app name (resource)
      matchApp c = className =? c <||> title =? c <||> resource =? c

      -- floatInsert = insertPosition Above Newer
      -- normInsert  = insertPosition End Newer

-- -------- Event Hook {{{1

-- Description:
--
-- * refocusLastWhen: we use that so we can automatically focus back to 
--   previously focused window when the current one is lost. Extremely important
--   when working with IDEs and their dialogs. Otherwise we loose focus for the IDE.
--
-- * 
-- myEventHook = refocusLastWhen myPred <+> fullscreenEventHook
myEventHook = fullscreenEventHook

-- -------- Startup {{{1

myStartupHook = do
  setWMName "LG3D"
  spawnOnce "trayer --edge top --align right --widthtype request --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282A36 --height 20 --monitor 0 --iconspacing 2 --padding 5 &"
  spawnOnce "brave &"
  spawnOnce "telegram-desktop &"
  spawnOnce "viber &"
  spawnOnce "slack &"
  -- spawnOnce "hexchat &"
  -- spawnOnce "emacs --daemon &"
  
-- -------- Scratchpads {{{1

scratchpads = 
  [ NS "tmux"
      (myTerm ++ " -t scratchpad_tmux -e 'tmuxdd'")
      (title =? "scratchpad_tmux")
      $ customFloating $ W.RationalRect 0 0 1 0.6
      -- $ nsBigCenterFloat

  , NS "note"
      "emacsclient -a '' -nc -F '(quote (name . \"scratchpad_emacs\"))'"
      -- "emacsclient -a '' -e \"(setq frame-title-format \\\"scratchpad_emacs\\\")\""
      -- "emacsclient -c -F '((name . \"scratchpad_emacs\"))'"
      (title =? "scratchpad_emacs")
      $ nsBigCenterFloat 

  -- , NS "note"
  --     "code-oss"
  --     (className =? "code-oss")
  --     $ nsBigCenterFloat 

  , NS "pavucontrol"
      "pavucontrol"
      (className =? "Pavucontrol")
      $ nsCenterFloat 0.5 0.7

  , NS "htop"
      (myTerm ++ " -t scratchpad_htop -e htop")
      (title =? "scratchpad_htop")
      $ nsBigCenterFloat

  , NS "calculator"
      "qalculate-gtk"
      (className =? "Qalculate-gtk")
      $ nsCenterFloat 0.5 0.4

  , NS "bitwarden"
      "bitwarden-desktop"
      (className =? "Bitwarden")
      $ nsCenterFloat 0.5 0.6

  , NS "xair"
      "/home/antoniy/software/xair/X-AIR-Edit"
      (title =? "X AIR Edit [XR16, IP: 10.10.0.99]")
      $ nsCenterFloat 0.8 0.8
  ] 
  where
    nsFloat w h l t   = customFloating $ W.RationalRect l t w h
    nsCenterFloat w h = nsFloat w h ((1 - w) / 2) ((1 - h) / 2)
    nsBigCenterFloat  = nsCenterFloat 0.9 0.9

