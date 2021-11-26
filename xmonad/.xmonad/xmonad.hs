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
import qualified Data.List as L
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Ratio ((%)) -- needed for IM layout
import System.IO (hClose, hPutStr)
import Control.Exception (bracket)
import Control.Monad (when, forM_)

import XMonad.Config.Desktop


import XMonad.Layout

import XMonad.Layout.Simplest

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
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.LayoutCombinators hiding ( (|||) )

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat, composeOne, (-?>), transience', MaybeManageHook) 
import XMonad.Hooks.SetWMName

import XMonad.Util.Run(spawnPipe, hPutStrLn)
import XMonad.Util.SpawnOnce(spawnOnce)
import XMonad.Util.NamedScratchpad
import XMonad.Util.EZConfig (additionalKeysP, mkKeymap, mkNamedKeymap, removeKeysP)  
import XMonad.Util.Themes
import XMonad.Util.NamedActions
import XMonad.Util.Dmenu

import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies, copyToAll)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.RotSlaves (rotSlavesDown, rotSlavesUp, rotAllDown, rotAllUp)
import XMonad.Actions.Promote (promote)
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer

import System.Posix.Unistd

-- -------- Main {{{1

main = do
  host <- fmap nodeName getSystemID
  bars <- loadBars host
  -- bar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc-europa"
  -- bars <- return (\x -> hPutStrLn bar0 x)
  xmonad $ ewmh $ docks $ addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) (myKeys host) $ myConfig host bars
  -- xmonad $ ewmh $ docks $ addDescrKeys' ((mod4Mask, xK_F1), rofiBindings) (myKeys host) $ myConfig host bar0

loadBars :: String -> IO (String -> IO ())
loadBars "europa" = do
  bar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc-europa"
  bar1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc-europa"
  -- return (\x -> hPutStrLn bar x)
  return (\x -> hPutStrLn bar0 x >> hPutStrLn bar1 x)
loadBars "pulsar" = do
  bar0 <- spawnPipe "xmobar -x 0 ~/.config/xmobar/xmobarrc-pulsar" 
  bar1 <- spawnPipe "xmobar -x 1 ~/.config/xmobar/xmobarrc-pulsar"
  return (\x -> hPutStrLn bar0 x >> hPutStrLn bar1 x)

-- rofiBindings :: [((KeyMask, KeySym), NamedAction)] -> X ()
-- rofiBindings bindings = do
--   handle <- spawnPipe "rofi -dmenu -i"
--   liftIO $ hPutStrLn handle (unlines $ showKm bindings)

confirm :: String -> X () -> X ()
confirm msg action = do
  response <- menuArgs "rofi" ["-dmenu", "-i", "-p", msg] ["No", "Yes"]
  when ("Yes" `L.isPrefixOf` response) action

showNotification title text = spawn ("notify-send \"" ++ title ++ "\" \"" ++ text ++ "\"")

-- -------- Config {{{1

myTerm = "alacritty"

myConfig host bars = def
  { terminal           = myTerm
  , focusFollowsMouse  = True
  , clickJustFocuses   = False
  , borderWidth        = 3
  , modMask            = mod4Mask
  , workspaces         = myWorkspaces
  -- , normalBorderColor  = "#292d3e"
  -- , focusedBorderColor = "#bbc5ff"
  , normalBorderColor  = "#401545"
  , focusedBorderColor = "#c345d1"
  , mouseBindings      = myMouseBindings
  , layoutHook         = myLayoutHook
  , manageHook         = myManageHook host
  , handleEventHook    = myEventHook
  , logHook            = myLogHook bars
  , startupHook        = myStartupHook host
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

myLogHook bars = 
  ( dynamicLogWithPP 
  $ namedScratchpadFilterOutWorkspacePP 
  $ xmobarPP 
    { ppOutput          = bars
    -- { ppOutput          = (\x -> forM_ bars (\b -> hPutStrLn b x))
    -- { ppOutput          = (\x -> hPutStrLn bar0 x >> hPutStrLn bar1 x)
    -- { ppOutput          = (\x -> hPutStrLn bar0 x)
    -- , ppCurrent         = xmobarColor "#8ec07c" "" . wrap "[" "]" -- Current workspace in xmobar
    , ppCurrent         = xmobarColor "#c345d1" "" . wrap "[" "]" -- Current workspace in xmobar
    , ppVisible         = xmobarColor "#c345d1" ""                -- Visible but not current workspace
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
  ) >> updatePointer (0.5, 0.5) (0.5, 0.5)

-- -------- Keybindings {{{1

myKeys host c =  

  titleSection c "General"
    [ ("M-S-r"          , addName "Recompile & restart"    $ spawn "xmonad --recompile; xmonad --restart")
    , ("M-S-q"          , addName "Quit"                   $ confirm "Really Quit?" $ io exitSuccess)
    , ("M-<Return>"     , addName "Start terminal"         $ spawn myTerm)
    , ("M-S-c"          , addName "Close window"           $ kill1)
    , ("M-S-a"          , addName "Close all"              $ confirm "Close All?" $ killAll)
    ]

  ^++^ titleSection c "System"
    [ ("M-S-<Print>"    , addName "Screenshot region copy" $ spawn "~/.local/bin/screenshot copy-region")
    , ("M-<Print>"      , addName "Screenshot menu"        $ spawn "~/.local/bin/dmenu-screenshot")
    , ("M1-q"           , addName "Application launcher"   $ spawn "rofi -show drun -show-icons")
    , ("M1-S-q"         , addName "Command launcher"       $ spawn "rofi -show combi -combi-modi run,drun")
    , ("M-S-<Escape>"   , addName "Leave Xorg"             $ confirm "Leave Xorg?" $ spawn "killall Xorg") 
    ]

  ^++^ titleSection c "Floating windows"
    [ ("M-<Delete>"     , addName "Floating to tile"       $ withFocused $ windows . W.sink)
    , ("M-S-<Delete>"   , addName "ALL floating to tile"   $ sinkAll)
    , ("M-<Space>"      , addName "Switch between layers"  $ switchLayer)
    ]

  ^++^ titleSection c "Window navigation"
    [ ("M-m"            , addName "Focus master"           $ windows W.focusMaster)
    , ("M-j"            , addName "Focus down"             $ windows W.focusDown)
    , ("M-k"            , addName "Focus up"               $ windows W.focusUp)
    , ("M1-<Tab>"       , addName "Focus down"             $ windows W.focusDown)
    , ("M1-S-<Tab>"     , addName "Focus up"               $ windows W.focusUp)
    , ("M-S-m"          , addName "Swap master"            $ windows W.swapMaster)
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

  ^++^ titleSection c "Layouts"
    [ ("M-<Tab>"        , addName "Go to next layout"      $ sendMessage NextLayout)
    , ("M-S-<Space>"    , addName "Toggle struts"          $ sendMessage ToggleStruts)
    , ("M-S-n"          , addName "Toggle NOBORDERS"       $ sendMessage $ Toggle NOBORDERS)

    , ("M-z"            , addName "Toggle Zoom"            $ toggleZoom)
    , ("M-S-m"          , addName "Toggle MIRROR"          $ sendMessage $ Toggle MIRROR)
    , ("M-\\"           , addName "Toggle ReflectX"        $ sendMessage $ Toggle REFLECTX)
    , ("M-S-\\"         , addName "Toggle ReflectY"        $ sendMessage $ Toggle REFLECTY)
    , ("M-S-g"          , addName "Toggle Spacing"         $ toggleScreenSpacingEnabled >> toggleWindowSpacingEnabled)

    -- , ("M-<KP_Multiply>", addName "Inc master windows cnt" $ sendMessage (IncMasterN 1))
    -- , ("M-<KP_Divide>"  , addName "Dec master windows cnt" $ sendMessage (IncMasterN (-1)))

    -- Resize tile with meta+alt+{h,j,k,l}
    , ("M-M1-h"         , addName "Shrink"                 $ sendMessage Shrink)
    , ("M-M1-l"         , addName "Expand"                 $ sendMessage Expand)
    , ("M-M1-j"         , addName "Mirror Shrink"          $ sendMessage MirrorShrink)
    , ("M-M1-k"         , addName "Mirror Expand"          $ sendMessage MirrorExpand)
    ]

  ^++^ titleSection c "Screen"
    [ ("M-."            , addName "Focus next screen"      $ nextScreen)
    , ("M-,"            , addName "Focus prev screen"      $ prevScreen)
    , ("M-S-."          , addName "Move to next screen"    $ shiftNextScreen)
    , ("M-S-,"          , addName "Move to prev screen"    $ shiftPrevScreen)

    , ("M-M1-<Left>"    , addName "" $ sendMessage $ ExpandTowards L)
    , ("M-M1-<Right>"   , addName "" $ sendMessage $ ShrinkFrom L)
    , ("M-M1-<Up>"      , addName "" $ sendMessage $ ExpandTowards U)
    , ("M-M1-<Down>"    , addName "" $ sendMessage $ ShrinkFrom U)
    , ("M-M1-C-<Left>"  , addName "" $ sendMessage $ ShrinkFrom R)
    , ("M-M1-C-<Right>" , addName "" $ sendMessage $ ExpandTowards R)
    , ("M-M1-C-<Up>"    , addName "" $ sendMessage $ ShrinkFrom D)
    , ("M-M1-C-<Down>"  , addName "" $ sendMessage $ ExpandTowards D)
    ]

  ^++^ titleSection c "Scratchpads"
    -- Default scratchpad bindings
    ( [ ("<F12>"        , addName "Toggle Tmux"            $ toggleNSP host "tmux")
      , ("M-p M-p"      , addName "Toggle player"          $ toggleNSP host "music")
      , ("M-p <Space>"  , addName "Play/Pause"             $ spawn "playerctl play-pause")
      , ("M-p n"        , addName "Next"                   $ spawn "playerctl next")
      , ("M-p p"        , addName "Previous"               $ spawn "playerctl previous")
      , ("M-<F9>"       , addName "Toggle Pavucontrol"     $ toggleNSP host "pavucontrol")
      , ("M-c"          , addName "Toggle calculator"      $ toggleNSP host "calculator")
      , ("M-t"          , addName "Toggle translate"       $ toggleNSP host "translate")
      ] 
      ++
      case host of
        "europa" ->
          [ ("M-`"      , addName "Toggle Notes"           $ toggleNSP host "notes")
          , ("M-<F10>"  , addName "Toggle pwd manager"     $ toggleNSP host "pwd")
          , ("M-g"      , addName "Toggle mermaid-live"    $ toggleNSP host "mermaid-live")
          ] 
        "pulsar" ->
          [ ("M-`"      , addName "Toggle Notes"           $ toggleNSP host "notes")
          , ("M-S-<F9>" , addName "Toggle XAir"            $ toggleNSP host "xair")
          ] 
        _ -> []
    )

  ^++^ titleSection c "Media Keys"
    [ ("<XF86MonBrightnessUp>"  , addName "Brightness +10%" $ spawn "xbacklight -inc 10")
    , ("<XF86MonBrightnessDown>", addName "Brightness -10%" $ spawn "xbacklight -dec 10")
    , ("<XF86AudioRaiseVolume>" , addName "Volume +5%"      $ spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    , ("<XF86AudioLowerVolume>" , addName "Volume -5%"      $ spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
    , ("<XF86AudioMute>"        , addName "Volume mute"     $ spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ("<XF86AudioMicMute>"     , addName "Volume mic mute" $ spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    , ("M-S-<Up>"               , addName "Brightness +10%" $ spawn "xbacklight -inc 10")
    , ("M-S-<Down>"             , addName "Brightness -10%" $ spawn "xbacklight -dec 10")
    , ("M-<Up>"                 , addName "Volume +5%"      $ spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
    , ("M-<Down>"               , addName "Volume -5%"      $ spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
    ]

  ^++^ titleSection c "Custom Prefix" 
    [ ("M-a v u"        , addName "VPN enable"              $ spawn "nmcli con up Smule")
    , ("M-a v d"        , addName "VPN disable"             $ spawn "nmcli con down Smule")
    , ("M-a t"          , addName "Change term theme"       $ spawn "~/.local/bin/alacritty-change-theme")
    -- , ("M-a h"          , addName "Hibernate"               $ confirm "Hibernate?"  $ spawn "systemctl hibernate")
    -- , ("M-a s"          , addName "Suspend"                 $ confirm "Suspend?"    $ spawn "systemctl suspend")
    , ("M-a l"          , addName "Lock Screen"             $ spawn "i3lock -c 000000")
    ] 

  ^++^ titleSection c "Workspaces"
    ( [ ("M-l", addName "Cycle through not visible workspaces" $ moveTo Next nonEmptyWS) 
      , ("M-h", addName "Cycle through not visible workspaces" $ moveTo Prev nonEmptyWS) 
      ]
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


-- utility function for defining a named section for NamedActions
titleSection c title keys = (subtitle title :) $ mkNamedKeymap c keys

nonEmptyWS = WSIs $ return (\w -> nonNSP w && nonEmpty w)
  where nonNSP (W.Workspace tag _ _) = tag /= "NSP"
        nonEmpty = isJust . W.stack
toggleZoom       = sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts
toggleNSP host n = namedScratchpadAction (scratchpads host) n

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
  $ smartBorders             -- don't use borders on single window (on a single screen) and also if the window covers the entier screen (mpv)
  $ toggleLayouts floats     -- add ability to toggle floats on all layouts
  $ fullScreenToggle         -- adds the ability to toggle fullscreen for all layouts/windows
  $ reflectXToggle           -- add toggle for reflect on X on all layouts
  $ reflectYToggle           -- add toggle for reflect on Y on all layouts
  $ mirrorToggle             -- add toggle for mirror (rotate 90 degrees) 
  $ perWsLayouts 2 chatLayouts     -- set layout set for 'chat' workspace
  $ perWsLayouts 3 devLayouts      -- set layout set for 'development' workspace
  $ perWsLayouts 4 meetingLayouts  -- set layout set for 'gaming' workspace
  $ myDefaultLayout          -- set the default layout set
  where 

    -- toggle aliases
    fullScreenToggle = mkToggle (NBFULL ?? NOBORDERS ?? EOT) -- alias for fullscreen toggle config
    reflectXToggle   = mkToggle (single REFLECTX)            -- alias for reflect X toggle config
    reflectYToggle   = mkToggle (single REFLECTY)            -- alias for reflect Y toggle config
    mirrorToggle     = mkToggle (single MIRROR)              -- alias for reflect Y toggle config

    -- alias function to specify per-workspace layouts
    perWsLayouts n layouts = onWorkspace (myWorkspaces !! (n - 1)) layouts

    -- Define individual layout sets for specific workspaces and a default one
    chatLayouts     = im    ||| myDefaultLayout
    devLayouts      = ide   ||| myDefaultLayout
    meetingLayouts  = zoom  ||| myDefaultLayout
    myDefaultLayout = tall  ||| oneBig  ||| grid ||| bsp ||| tab ||| monocle ||| floats

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

    -- Configure each individual layout:
    -- apply renaming, limiting windows, spacing, toggles, size/resize ratios, theming, etc.
    monocle = rename "Monocle" 
      $ limitWindows 20 
      $ noBorders 
      $ Full

    tall = rename "Tall"
      $ limitWindows 8 
      $ mySpacing
      $ ResizableTall 1 (3/100) (1/2) []

    grid = rename "Grid" 
      $ limitWindows 12 
      $ mySpacing 
      $ Grid (16/10)

    oneBig = rename "OneBig"  
      $ limitWindows 8  
      $ mySpacing 
      $ OneBig (5/9) (8/12)

    tab = rename "Tabbed" 
      $ limitWindows 20 
      $ noBorders 
      $ addTabs shrinkText tabTheme
      $ tabbed shrinkText tabTheme

    floats = rename "Floats"
      $ limitWindows 20 
      $ simplestFloat

    bsp = rename "BSP"
      $ limitWindows 20 
      $ mySpacing 
      $ emptyBSP

    ide = rename "IDE"
      $ limitWindows 8 
      $ mySpacing' 0 
      $ OneBig (6/8) (6/8)

    im = rename "IM"      
      $ ifMax 4 grid oneBig

    zoom = rename "Zoom"
      $ withIM (1%7) (Title "Zoom - Free Account") tall ||| monocle

-- -------- Workspaces {{{1

xmobarEscape = concatMap el
  where 
    el '<' = "<<"
    el x   = [x]
        
myWorkspaces :: [String]   
myWorkspaces = clickable . (map xmobarEscape) $ 
  [ "\xfa9e "      -- 1: browser
  , "\xf860 "      -- 2: IMs
  , "\xf66b "      -- 3: development
  , "\xf8f5 "      -- 4: meetings
  -- ,"4:\xf1b7 "  -- gaming
  -- ,"5:\xf04b "  -- media
  -- ,"6:\xf013 "  -- auxiliary
  ] ++ (map show [5..8]) -- Unallocated wss
    ++ [ "\xf415 " -- 9: personal
       ]
  where 
    clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                    (i, ws) <- zip [1..9] l,                                        
                    let n = i ] 

-- move window to workspace (idx)
toWs :: Int -> ManageHook
toWs n = doShift (myWorkspaces !! (n - 1))

-- -------- Manage Hook {{{1

-- NOTE: Window properties (can verify with xprop utility):
-- className - second argument of WM_CLASS
-- resource / appName - first argument of WM_CLASS
-- title - WM_NAME
-- role - custom definition - WM_WINDOW_ROLE
myManageHook :: String -> ManageHook
myManageHook host = manageDocks 
  <+> namedScratchpadManageHook (scratchpads host)
  <+> transience'
  <+> appsManageHook host

appsManageHook :: String -> ManageHook
appsManageHook host = composeOne . concat $ 
  [ commonManageHook
  , perHostManageHook host
  ] 
    where

      commonManageHook :: [MaybeManageHook]
      commonManageHook = 
        [ isDialog                                -?> doCenterFloat
        , isFullscreen                            -?> doFullFloat
        , resource     =?  "xmobar"               -?> doIgnore
        , className    =?  "trayer"               -?> doIgnore
        , resource     =?  "localhost"            -?> doCenterFloat
        , resource     =?  "nm-connection-editor" -?> doCenterFloat
        , resource     =?  "yad"                  -?> doCenterFloat
        , resource     =?  "xmessage"             -?> doCenterFloat
        , resource     =?  "mpv"                  -?> doCenterFloat
        , resource     =?  "gimp-2.10"            -?> doCenterFloat
        , resource     =?  "plexamp"              -?> doCenterFloat
        , title        =?  "JetBrains Toolbox"    -?> doCenterFloat <+> toWs 3
        , className    =?  "jetbrains-idea"       -?> toWs 3
        , className    =?  "Peek"                 -?> doCenterFloat
        ] 

      perHostManageHook :: String -> [MaybeManageHook]
      perHostManageHook "europa" = 
        [ className    =?  "Slack"                -?> toWs 2
        , resource     =?  "gmail.com"            -?> toWs 2
        , resource     =?  "calendar.google.com"  -?> toWs 2
        , resource     =?  "Viber"                -?> toWs 9
        , resource     =?  "zoom"                 -?> toWs 4
        , className    =?  "Brave-browser"        -?> toWs 1
        , className    =?  "Google-chrome"        -?> toWs 1
        ]
      perHostManageHook "pulsar" = 
        [ className    =?  "Slack"                -?> toWs 2
        , className    =?  "viber"                -?> toWs 2
        , resource     =?  "telegram-desktop"     -?> toWs 2
        , className    =?  "Brave-browser"        -?> toWs 1
        , className    =?  "Google-chrome"        -?> toWs 1
        ]
      perHostManageHook _ = []
      
      role = stringProperty "WM_WINDOW_ROLE"
      
      -- | Match against start of Query
      (=?^) :: Eq a => Query [a] -> [a] -> Query Bool
      (=?^) q x = L.isPrefixOf x <$> q
      
      -- | Match against end of Query
      (=?$) :: Eq a => Query [a] -> [a] -> Query Bool
      (=?$) q x = L.isSuffixOf x <$> q
      
      -- match window by class name, title or app name (resource)
      -- matchApp c = className =? c <||> title =? c <||> resource =? c

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

myStartupHook :: String -> X()
myStartupHook "europa" = do
  setWMName "LG3D"
  spawnOnce "trayer --edge top --align right --widthtype request --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282A36 --height 20 --monitor 0 --iconspacing 2 --padding 5 &"
  spawnOnce "brave-browser --new-window &"
  spawnOnce "brave-browser --new-window --app=\"https://gmail.com\" &"
  spawnOnce "brave-browser --new-window --app=\"https://calendar.google.com\" &"
  spawnOnce "zoom &"
  spawnOnce "slack &"
  spawnOnce "/opt/viber/Viber &"
  spawnOnce "espanso start"
  -- spawnOnce "~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox &"
  spawnOnce "udiskie --notify --tray --no-automount &"

myStartupHook "pulsar" = do
  setWMName "LG3D"
  spawnOnce "trayer --edge top --align right --widthtype request --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 0 --tint 0x282A36 --height 20 --monitor 0 --iconspacing 2 --padding 5 &"
  spawnOnce "brave &"
  spawnOnce "telegram-desktop &"
  spawnOnce "viber &"
  spawnOnce "slack &"
  spawnOnce "udiskie --notify --tray --no-automount &"
myStartupHook _ = return ()
  
-- -------- Scratchpads {{{1

scratchpads :: String -> [NamedScratchpad]
scratchpads "europa" = 
  [ NS "tmux"
      (myTerm ++ " -t scratchpad_tmux -e 'tmuxdd'")
      (title =? "scratchpad_tmux")
      $ nsFloat 1 0.6 0 0

  , NS "notes"
      "~/software/Obsidian-0.12.19.AppImage"
      (resource =? "obsidian")
      $ nsFullFloat

  , NS "pavucontrol"
      "pavucontrol"
      (className =? "Pavucontrol")
      $ nsCenterFloat 0.5 0.7

 , NS "calculator"
     "speedcrunch"
     (resource =? "speedcrunch")
     $ nsCenterFloat 0.2 0.3

  , NS "pwd"
      "keepassxc"
      (className =? "KeePassXC")
      $ nsCenterFloat 0.5 0.6

  , NS "music"
      "~/AppImages/Plexamp.AppImage"
      (className =? "Plexamp")
      $ nsCenterFloat 0.17 0.6

  , NS "translate"
      "brave-browser --new-window --app=\"https://translate.google.com/?sl=en&tl=bg&op=translate\" &"
      (resource =? "translate.google.com")
      $ nsCenterFloat 0.5 0.7

  , NS "mermaid-live"
      "brave-browser --new-window --app=\"http://localhost:8878\" &"
      (resource =? "localhost")
      $ nsBigCenterFloat

  ] 

scratchpads "pulsar" = 
  [ NS "tmux"
      (myTerm ++ " -t scratchpad_tmux -e 'tmuxdd'")
      (title =? "scratchpad_tmux")
      $ nsFloat 1 0.6 0 0

  -- , NS "note"
  --     "emacsclient -a '' -nc -F '(quote (name . \"scratchpad_emacs\"))'"
  --     -- "emacsclient -a '' -e \"(setq frame-title-format \\\"scratchpad_emacs\\\")\""
  --     -- "emacsclient -c -F '((name . \"scratchpad_emacs\"))'"
  --     (title =? "scratchpad_emacs")
  --     $ nsBigCenterFloat 

  -- , NS "note"
  --     "code-oss"
  --     (className =? "code-oss")
  --     $ nsBigCenterFloat 

  , NS "notes"
      "obsidian"
      (resource =? "obsidian")
      $ nsCenterFloat 0.7 0.9

  , NS "pavucontrol"
      "pavucontrol"
      (className =? "Pavucontrol")
      $ nsCenterFloat 0.5 0.7

 , NS "calculator" 
      "speedcrunch"
      (resource =? "speedcrunch")
      $ nsCenterFloat 0.2 0.3

  , NS "music"
      "Plexamp.AppImage"
      (className =? "Plexamp")
      $ nsCenterFloat 0.17 0.6

  , NS "translate"
      "brave --new-window --app=\"https://translate.google.com/?sl=en&tl=bg&op=translate\" &"
      (resource =? "translate.google.com")
      $ nsCenterFloat 0.5 0.7

 , NS "xair"
      "/home/antoniy/software/xair/X-AIR-Edit"
      (title =? "X AIR Edit [XR16, IP: 10.10.0.99]")
      $ nsCenterFloat 0.8 0.8
  ] 

nsFloat w h l t   = customFloating $ W.RationalRect l t w h
nsCenterFloat w h = nsFloat w h ((1 - w) / 2) ((1 - h) / 2)
nsBigCenterFloat  = nsCenterFloat 0.9 0.9
nsFullFloat       = nsFloat 1 0.98 0 0.02
