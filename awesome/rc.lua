-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")

-- -----------------------
local path = "/sys/class/power_supply/BAT0/"
showbatinfos = nil
lock = false
pluglock = false


function get_conky()
    local clients = client.get()
    local conky = nil
    local i = 1
    while clients[i]
    do
        if clients[i].class == "Conky"
        then
            conky = clients[i]
        end
        i = i + 1
    end
    return conky
end
function raise_conky()
    local conky = get_conky()
    if conky
    then
        conky.ontop = true
    end
end
function lower_conky()
    local conky = get_conky()
    if conky
    then
        conky.ontop = false
    end
end
function toggle_conky()
    local conky = get_conky()
    if conky
    then
        if conky.ontop
        then
            conky.ontop = false
        else
            conky.ontop = true
        end
    end
end

ip_int = ""
-- ip_ext = ""
function conky_info()
    -- result = "YOLO<span color='red'>Bar</span>LOL\n" .. os.date("%a %d %B %Y")
    result = "\n"
    result = result .. "    <span font_desc='Michroma bold 16' color='#b2ff34'>" .. os.date("%H:%M") .. "</span>    \n"
    result = result .. "    <span font_desc='normal 10' color='#ffffff'>" .. os.date("%a %d %B %Y") .. "</span>    \n"
    result = result .. "\n"

    result = result .. "    <span font_desc='Michroma bold 10' color='#b2ff34'>Keyboard</span>    \n"
    result = result .. "    <span font_desc='Michroma 10' color='#ffffff'>" .. string.upper(kbdcfg.layout[kbdcfg.current][1]) .. "</span>    \n"
    result = result .. "\n"

    local handle = io.popen("upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E percentage | awk '{ print $2 }'")
    local battery = handle:read("a")
    handle.close()
    result = result .. "    <span font_desc='Michroma bold 10' color='#b2ff34'>Battery</span>    \n"
    result = result .. "    <span font_desc='Michroma 10' color='#ffffff'>" .. battery .. "</span>    \n"
    result = result .. "\n"

    --[[
    result = result .. "    <span font_desc='Michroma bold 10' color='#b2ff34'>NETWORK</span>\n"
    local data = io.popen("nmcli dev | grep ' connected' | cut -d ' ' -f1")
    local wifi = data:read("*all")
    wifi = string.gsub(wifi, "\n", "")
    data:close()
    result = result .. "    <span font_desc='normal 8' color='#ffffff'>" .. wifi .. "</span>\n"

    --data = io.popen("ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1' ")
    data = io.popen("ip addr | grep 'inet ' | grep  " .. wifi .. "| tr -s ' ' | cut -d ' ' -f 3  | cut -d '/' -f 1")
    local ip_int = data:read("*all")
    --ip_int = string.gsub(ip_int, "\n", "\n    ")
    data:close()
    result = result .. "    <span font_desc='normal 8' color='#ffffff'>" .. ip_int .. "</span>\n"
    --[[

    local f = io.open("/tmp/netstats_for_awesome_wm.txt")
    local ns = f:read("*all")
    nt = string.gsub(ip_int, "\n", "")
    f:close()

    result = result .. "<span font_desc='normal 8' color='#ffffff'>" .. ns .. "</span>"




    result = result .. "\n"
    result = result .. "    <span font_desc='Michroma bold 10' color='#b2ff34'>CPU</span>\n"

    data = io.popen("mpstat -P ALL | tail -n 8 |  sed 's/\\([0-9]\\)*/\\1/' | awk '{print \"    CPU \" $3 \" - \" $4\"%\"}'")
    local cpu = data:read("*all")
    data:close()

    result = result .. "<span font_desc='normal 8' color='#ffffff'>" .. cpu .. "</span>\n"


    result = result .. "    <span font_desc='Michroma bold 10' color='#b2ff34'>RAM</span>\n"

    data = io.popen("FREE_DATA=`free -m | grep Mem`; CURRENT=`echo $FREE_DATA | cut -f3 -d' '`; TOTAL=`echo $FREE_DATA | cut -f2 -d' '`; echo RAM - $(echo \"scale = 4; $CURRENT/$TOTAL\" | bc | awk '{print $1*100 \"%\"}')")
    local cpu = data:read("*all")
    data:close()

    result = result .. "    <span font_desc='normal 8' color='#ffffff'>" .. cpu .. "</span>\n"
    ]]

    return result


    --[[
    local tmpfile = "/tmp/ip_ext.txt"
    os.execute("wget -q -O- http://ipecho.net/plain > "..tmpfile)
    local f = io.open(tmpfile)
    local ip_ext = ""
    for line in f:lines() do
        ip_ext = ip_ext .. line
    end
    f:close()

    result = result .. "    <span font_desc='normal 10' color='#ffffff'>"
    result = result .. ip_ext
    result = result .. "</span>    \n"
    ]]


end

function show_info()
    if notification_id == nil then
        notification_id = naughty.notify({
            text = conky_info(),
            screen = awful.screen.focused().index,
            timeout = 0
        }).id

        --[[
        -- Not sure what's broken here...
        refresh = true
        local coco = coroutine.create(function()
            while refresh == true do
                notification_id = naughty.notify({
                    text = conky_info(),
                    screen = 1,
                    replaces_id = notification_id
                }).id
            coroutine.yield()
            end
        end)

        while coroutine.status ~= "dead" do
            coroutine.resume(coco)
            socket.sleep(5)
        end
        ]]
    else
        refresh = false
        naughty.notify({
            text = conky_info(),
            screen = 1,
            timeout = 0.001,
            replaces_id = notification_id
        })
        notification_id = nil
    end
end

batinfo = wibox.widget.textbox()
-- batinfo = widget({ type = "textbox" , name = "batinfo" })
batinfo:add_signal('mouse::enter', function () dispinfo(path) end)
batinfo:add_signal('mouse::leave', function () clearinfo(showbatinfos) end)



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/michel/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
--    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "  Applejack  ", "  Pinkie Pie  ", "  Fluttershy  ", "  Rainbow Dash ", "  Rarity ", "  Twilight Sparkle ", "  Apple Bloom ", "  Scootaloo ", "  Sweetie Belle " }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}


-- {{{ Wibox

-- Create a textclock widget
-- mytextclock = awful.widget.textclock()


-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- for s = 1, screen.count() do
awful.screen.connect_for_each_screen(function(screen)
    local s = screen.index
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    -- left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    -- if s == 2 then right_layout:add(mytextclock) end
    -- right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Keyboard
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", "" }, { "us", "intl" } }
kbdcfg.current = 1  -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][1] .. " ")
kbdcfg.switch = function ()
    kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
    local t = kbdcfg.layout[kbdcfg.current]
    kbdcfg.widget:set_text(" " .. t[1] .. " ")
    os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )

    showbatinfos = naughty.notify( {
        title       = "  Keyboard layout  ",
        text        = "          " .. string.upper(kbdcfg.layout[kbdcfg.current][1]) .. " " .. kbdcfg.layout[kbdcfg.current][2],
        timeout     = 1,
        screen      = mouse.screen })

end

 -- Mouse bindings
kbdcfg.widget:buttons(
    awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)

-- }}}


-- {{{ Key bindings
function moveToRightTag(c)
    if client.focus ~= nil then
        local curidx = awful.tag.getidx()
        if curidx == 9 then
            awful.client.movetotag(tags[awful.screen.focused().index][1])

        else
            awful.client.movetotag(tags[awful.screen.focused().index][curidx + 1])
        end
        awful.tag.viewnext()
    end
end
function moveToLeftTag(c)
    if client.focus ~= nil then
        local curidx = awful.tag.getidx()
        if curidx == 1 then
            awful.client.movetotag(tags[awful.screen.focused().index][9])
        else
            awful.client.movetotag(tags[awful.screen.focused().index][curidx - 1])
        end
        awful.tag.viewprev()
    end
end
function nextWindow()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
end
function previousWindow ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end
globalkeys = awful.util.table.join(
    -- Move the the next/previous tag
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "h",      awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "l",      awful.tag.viewnext       ),

    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- Like Alt Tab
    awful.key({ modkey,           }, "j",      nextWindow               ),
    awful.key({ modkey,           }, "Tab",    nextWindow               ),
    awful.key({ modkey,           }, "k",      previousWindow           ),
    awful.key({ modkey, "Shift"   }, "Tab",    previousWindow           ),


    -- Move window in respect to others
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),

    -- Switch monitor
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "h", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "`", function () awful.screen.focus_relative(1) end),

    -- Not sure what it does
    -- awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

    -- Open terminal
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal, {
      tag = mouse.screen.selected_tag,
    }) end),

    -- Restart awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),

    -- Quit awesome
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Increment/decrement the number of master windows
    awful.key({ modkey,    }, "i",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey,    }, "u",     function () awful.tag.incnmaster(-1)      end),

    awful.key({ modkey,    }, "y",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey,    }, "o",     function () awful.tag.incncol(-1)         end),

    -- Switch layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Not sure what it does
    -- awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Move to the next/previous tag
    awful.key({ modkey, "Shift"   }, "h",     moveToLeftTag),
    awful.key({ modkey, "Shift"   }, "Left",  moveToLeftTag),
    awful.key({ modkey, "Shift"   }, "l",     moveToRightTag),
    awful.key({ modkey, "Shift"   }, "Right", moveToRightTag),


    -- Prompt
    awful.key({ modkey },            "r",     function () 
      mypromptbox[awful.screen.focused().index]:run()
    end),

    -- Not sure if useful for now
    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run({ prompt = "Run Lua code: " },
    --               mypromptbox[mouse.screen].widget,
    --               awful.util.eval, nil,
    --               awful.util.getdir("cache") .. "/history_eval")
    --           end),

    -- Menubar kind of useless, but let's keep it just in case
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Lock screen
    awful.key({ modkey }, "F12", function () awful.util.spawn("xscreensaver-command -lock") end),

    -- Switch the keyboard layout -- Alt Ctrl space
    awful.key({ "Mod1" , "Control"}, "space", function () kbdcfg.switch() end),


    -- Screenshot
    awful.key({ }, "Print", function () awful.util.spawn("scrot 'screenshot_%Y-%m-%d_%H-%M-%S.png' -e 'mv $f ~/Pictures/'", false) end),
    
    -- Notification
    --awful.key({ modkey,    }, "m",     toggle_conky ),
    awful.key({ modkey,    }, "m",    function() show_info() end ),
    --awful.key({ modkey,    }, "w",    function() show_info() end ),

    --awful.key({ modkey }, "h",          function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey }, "w",          function () awful.tag.incmwfact( 0.05) end),
    awful.key({ modkey }, "s",          function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "w", function () awful.client.incwfact( 0.05) end),
    awful.key({ modkey, "Shift" }, "s", function () awful.client.incwfact(-0.05) end),


    -- Volume
    awful.key({ }, "XF86AudioLowerVolume", function () vicious.contrib.pulse.add(-5,"alsa_output.pci-0000_00_1b.0.analog-stereo") end),
    awful.key({ }, "XF86AudioRaiseVolume", function () vicious.contrib.pulse.add(5,"alsa_output.pci-0000_00_1b.0.analog-stereo") end),
    awful.key({ }, "XF86AudioMute", function () vicious.contrib.pulse.toggle("alsa_output.pci-0000_00_1b.0.analog-stereo") end)


)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Shift" }, "f",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Control" }, "space",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end)
    --[[,
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
    ]]
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Conky" },
      properties = {
          floating = true,
          sticky = true,
          ontop = false,
          focusable = false,
          size_hints = {"program_position", "program_size"}
      } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))
        right_layout:add(kbdcfg.widget)

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


