--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2017, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        program.lua
--

--[[ Console User Interface (cui) ]-----------------------------------------
Author: Tiago Dionizio (tiago.dionizio AT gmail.com)
$Id: program.lua 18 2007-06-21 20:43:52Z tngd $
--------------------------------------------------------------------------]]

-- load modules
local rect   = require("ui/rect")
local group  = require("ui/group")
local event  = require("ui/event")
local curses = require("ui/curses")

-- define module
local program = program or group()

-- init program
function program:init(name)

    -- init main window
    local main_window = self:main_window()

    -- disable echo
    curses.echo(false)

    -- disable input cache
    curses.cbreak(true)

    -- disable newline
    curses.nl(false)

    -- to filter characters being output to the screen
    -- this will filter all characters where a chtype or chstr is used
    curses.map_output(true)

    -- on WIN32 ALT keys need to be mapped, so to make sure you get the wanted keys,
    -- only makes sense when using keypad(true) and echo(false)
    curses.map_keyboard(true)

    -- init colors
    if (curses.has_colors()) then 
        curses.start_color() 
    end

    -- disable main window cursor
    main_window:leaveok(false)

    -- enable special key map
    main_window:keypad(true)

    -- non-block for getch()
    main_window:nodelay(true)

    -- get 8-bits character for getch()
    main_window:meta(true)

    -- init group
    group.init(self, name, rect {0, 0, curses.columns(), curses.lines()})
end

-- exit program
function program:exit()

    -- exit group
    group.exit(self)

    -- (attempt to) make sure the screen will be cleared
    -- if not restored by the curses driver
    self:main_window():clear()
    self:main_window():noutrefresh()
    curses.doupdate()

    -- exit curses
    assert(not curses.isdone())
    curses.done()
end

-- get the main window
function program:main_window()

    -- init main window if not exists
    local main_window = self._MAIN_WINDOW
    if not main_window then
        
        -- init main window
        main_window = curses.init()
        assert(main_window, "cannot init main window!")

        -- save main window
        self._MAIN_WINDOW = main_window
    end
    return main_window
end

-- get the command arguments
function program:argv()
    return self._ARGV
end

-- get the current event
function program:event()

    -- get input key
    local key_code, key_name, key_meta = self:_input_key()
    if key_code then
        if key_name == "Resize" or key_name == "CtrlL" then
            self:change_bounds(Rect{0, 0, curses.columns(), curses.lines()})
            self:refresh()
        elseif key_name == "Refresh" then
            self:refresh()
        else
            return event.keyboard{key_code, key_name, key_meta}
        end
    end
end

-- put an event to view
function program:event_put(e)
    -- TODO
end

-- run program loop
function program:loop(argv)

    -- save the current arguments
    self._ARGV = argv

    -- execute group
    self:execute()
end

-- get key map
function program:_key_map()
    if not self._KEYMAP then
        self._KEYMAP =
        {
            [ 1] = "CtrlA", [ 2] = "CtrlB", [ 3] = "CtrlC",
            [ 4] = "CtrlD", [ 5] = "CtrlE", [ 6] = "CtrlF",
            [ 7] = "CtrlG", [ 8] = "CtrlH", [ 9] = "CtrlI",
            [10] = "CtrlJ", [11] = "CtrlK", [12] = "CtrlL",
            [13] = "CtrlM", [14] = "CtrlN", [15] = "CtrlO",
            [16] = "CtrlP", [17] = "CtrlQ", [18] = "CtrlR",
            [19] = "CtrlS", [20] = "CtrlT", [21] = "CtrlU",
            [22] = "CtrlV", [23] = "CtrlW", [24] = "CtrlX",
            [25] = "CtrlY", [26] = "CtrlZ",

            [  8] = "Backspace",
            [  9] = "Tab",
            [ 10] = "Enter",
            [ 13] = "Enter",
            [ 27] = "Esc",
            [ 31] = "CtrlBackspace",
            [127] = "Backspace",

            [curses.KEY_DOWN        ] = "Down",
            [curses.KEY_UP          ] = "Up",
            [curses.KEY_LEFT        ] = "Left",
            [curses.KEY_RIGHT       ] = "Right",
            [curses.KEY_HOME        ] = "Home",
            [curses.KEY_END         ] = "End",
            [curses.KEY_NPAGE       ] = "PageDown",
            [curses.KEY_PPAGE       ] = "PageUp",
            [curses.KEY_IC          ] = "Insert",
            [curses.KEY_DC          ] = "Delete",
            [curses.KEY_BACKSPACE   ] = "Backspace",
            [curses.KEY_F1          ] = "F1",
            [curses.KEY_F2          ] = "F2",
            [curses.KEY_F3          ] = "F3",
            [curses.KEY_F4          ] = "F4",
            [curses.KEY_F5          ] = "F5",
            [curses.KEY_F6          ] = "F6",
            [curses.KEY_F7          ] = "F7",
            [curses.KEY_F8          ] = "F8",
            [curses.KEY_F9          ] = "F9",
            [curses.KEY_F10         ] = "F10",
            [curses.KEY_F11         ] = "F11",
            [curses.KEY_F12         ] = "F12",

            [curses.KEY_RESIZE      ] = "Resize",
            [curses.KEY_REFRESH     ] = "Refresh",

            [curses.KEY_BTAB        ] = "ShiftTab",
            [curses.KEY_SDC         ] = "ShiftDelete",
            [curses.KEY_SIC         ] = "ShiftInsert",
            [curses.KEY_SEND        ] = "ShiftEnd",
            [curses.KEY_SHOME       ] = "ShiftHome",
            [curses.KEY_SLEFT       ] = "ShiftLeft",
            [curses.KEY_SRIGHT      ] = "ShiftRight",
        }
    end
    return self._KEYMAP
end

-- get input key
function program:_input_key()

    -- get main window
    local main_window = self:main_window()

    -- get input character
    local ch = main_window:getch()
    if not ch then 
        return
    end

    -- this is the time limit in ms within Esc-key sequences are detected as
    -- Alt-letter sequences. useful when we can't generate Alt-letter sequences
    -- directly. sometimes this pause may be longer than expected since the
    -- curses driver may also pause waiting for another key (ncurses-5.3)
    local esc_delay = 400

    -- get key map
    local key_map = self:_key_map()

    -- is alt?
    local alt = ch == 27
    if alt then

        -- get the next input character
        ch = main_window:getch()
        if not ch then

            -- since there is no way to know the time with millisecond precision
            -- we pause the the program until we get a key or the time limit
            -- is reached
            local t = 0
            while true do
                ch = main_window:getch()
                if ch or t >= esc_delay then
                    break
                end

                -- wait some time, 50ms
                curses.napms(50) 
                t = t + 50
            end

            -- nothing was typed... return Esc
            if not ch then 
                return 27, "Esc", false 
            end
        end
        if ch > 96 and ch < 123 then 
            ch = ch - 32 
        end
    end

    -- map character to key
    local key = key_map[ch]
    local key_name = nil
    if key then
        key_name = alt and "Alt".. key or key
    elseif (ch < 256) then
        key_name = alt and "Alt".. string.char(ch) or string.char(ch)
    else
        return ch, '(noname)', alt
    end

    -- return key info
    return ch, key_name, alt
end

-- return module
return program
