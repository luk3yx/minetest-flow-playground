--
-- Flow playground
--
-- Copyright © 2022 by luk3yx.
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--

-- Load renderer from the formspec editor
local baseurl = "https://luk3yx.gitlab.io/minetest-formspec-editor/"
local loadfile_raw, dofile_raw = loadfile, dofile
function loadfile(f, ...)
    return loadfile_raw(baseurl .. f, ...)
end

function dofile(f, ...)
    return dofile_raw(baseurl .. f, ...)
end

dofile('renderer.lua?rev=11')

loadfile, dofile = loadfile_raw, dofile_raw

-- Flow uses a table with weak values to track form names, however Fengari
-- doesn't support weak tables. This implementation should prevent memory leaks
local old_setmetatable = setmetatable
function setmetatable(t, mt)
    if mt.__mode == "v" and not mt.__index and not mt.__newindex and
            not mt.__len and window.WeakRef then
        local weak_table = {}
        function mt:__index(key)
            local value = weak_table[key]
            if value ~= nil then
                value = value:deref()
                -- Delete the WeakRef object if the value no longer exists
                if value == nil then
                    weak_table[key] = nil
                end
            end
            return value
        end

        function mt:__newindex(key, value)
            weak_table[key] = js.new(window.WeakRef, value)
        end

        function mt:__len()
            for i = #weak_table, 1, -1 do
                if self[i] ~= nil then
                    return i
                end
            end
            return 0
        end

        mt.__mode = nil
    end
    return old_setmetatable(t, mt)
end

-- Create a shim for some MT APIs
table.indexof = table.indexof or function(list, value)
    for i, item in ipairs(list) do
        if item == value then
            return i
        end
    end
    return -1
end

string.split = string.split or function(str, chr)
    local r, i, s, e = {}, 0, str:find(chr, nil, true)
    while s do
        r[#r + 1] = str:sub(i, s - 1)
        i = e + 1
        s, e  = str:find(chr, i, true)
    end
    r[#r + 1] = str:sub(i)
    return r
end


core = {}

-- Compatibility
minetest = core -- luacheck: ignore

local PLAYER_NAME = "playground"
local current_formname

function core.get_player_by_name(name)
    if name ~= PLAYER_NAME then return end

    return {
        get_player_name = function()
            return name
        end
    }
end

function core.get_connected_players()
    return {core.get_player_by_name(PLAYER_NAME)}
end

-- TODO
function core.get_color_escape_sequence()
    return ""
end

function core.colorize(_, text)
    return text
end

local chat
local chat_div = document:getElementById("chat")
function core.chat_send_all(msg)
    chat[#chat + 1] = msg
    if #chat > 10 then
        table.remove(chat, 1)
    end

    chat_div.textContent = table.concat(chat, "\n")
end

function core.chat_send_player(name, msg)
    if name == PLAYER_NAME then
        core.chat_send_all(msg)
    end
end

function core.is_yes(value)
    return value:lower() == "true"
end

local function noop() end
core.get_player_information = noop
core.register_on_leaveplayer = noop
core.is_singleplayer = noop
core.get_us_time = noop

local field_elems
local output = document:getElementById("output")
-- local fs_elem = document:getElementById("formspec")
function core.show_formspec(name, formname, formspec)
    assert(name == PLAYER_NAME)

    if formspec == "" then
        if formname == "" or formname == current_formname then
            current_formname = nil
            field_elems = nil
            output.innerHTML = ""
        end
        return
    end

    current_formname = formname
    field_elems = {}
    output.innerHTML = ""

    local elem = assert(renderer.render_formspec(formspec, nil,
        {store_json = false}))

    output:appendChild(elem)

    -- fs_elem.textContent = formspec
end

function core.close_formspec(name, formname)
    core.show_formspec(name, formname, "")
end

-- Callbacks
local on_receive_fields = {}
local function fire_event(node_name, value, exit)
    local player = core.get_player_by_name(PLAYER_NAME)
    local fields = {}
    for field, elem in pairs(field_elems) do
        fields[field] = elem.value
    end
    fields[node_name] = value

    if exit then
        core.close_formspec(PLAYER_NAME, "")
    end

    for _, func in ipairs(on_receive_fields) do
        local ok, err = pcall(func, player, current_formname, fields)
        if not ok then
            core.chat_send_all(err)
        end
    end
end

function renderer.default_elem_hook(node, e, scale)
    if node.type:find("button", 1, true) or node.type == "checkbox" then
        return function()
            local value
            if node.type == "checkbox" then
                node.selected = not node.selected
                value = tostring(node.selected)
                e:setAttribute("data-checked", value)
            else
                value = node.label or ""
            end

            fire_event(node.name, value, node.type:sub(-5) == "_exit")
        end
    elseif node.type == "dropdown" then
        local dropdown = e:querySelector("select")
        dropdown:addEventListener("change", function()
            if node.index_event then
                -- Use math.floor to remove the .0
                fire_event(node.name,
                    tostring(math.floor(dropdown.selectedIndex + 1)))
            else
                fire_event(node.name, dropdown.value)
            end
        end)
    elseif node.type == "field" or node.type == "pwdfield" then
        local field_elem = e:querySelector("input[type=text]")
        field_elem:removeAttribute("readonly")
        field_elems[node.name] = field_elem
    end
end

function core.register_on_player_receive_fields(callback)
    on_receive_fields[#on_receive_fields + 1] = callback
end

local unpack = table.unpack or unpack
local timeouts = {}
local function cancel_timeout(id)
    window:clearTimeout(id)
    timeouts[id] = nil
end

function core.after(delay, func, ...)
    local args = {...}
    local id
    id = window:setTimeout(function()
        timeouts[id] = nil
        local ok, err = pcall(func, unpack(args))
        if not ok then
            core.chat_send_all(tostring(err))
        end
    end, math.max(delay, 0.09) * 1000)

    timeouts[id] = true
    return {cancel = function() cancel_timeout(id) end}
end

function core.get_translator(modname)
    return function(str, ...)
        local args = {...}
        return (str:gsub("@(.)", function(c)
            local n = tonumber(c)
            if args[n] then
                return args[n]
            elseif c == "\n" or c == "n" then
                return "\n"
            elseif c == "@" or c == "=" then
                return c
            end
            error("Unrecognised translation escape: @" .. c, 4)
        end))
    end
end

-- Load flow
function core.get_current_modname() return "flow" end
function core.get_modpath(n) return n == "flow" and n or nil end
dofile("flow/init.lua")
core.get_current_modname = noop

local on_receive_fields_bkp = table.copy(on_receive_fields)

local function print_to_chat(...)
    local t = {}
    for i = 1, select("#", ...) do
        t[i] = tostring(select(i, ...))
    end
    core.chat_send_all(table.concat(t, "\t"))
end

-- Makes a new Lua environment
local function reset_environment()
    chat = {}
    chat_div.textContent = ""

    core.close_formspec(PLAYER_NAME, "")
    on_receive_fields = table.copy(on_receive_fields_bkp)
    local flow_copy = {}
    for k, v in pairs(flow) do
        flow_copy[k] = v
    end

    -- Clear any existing timeouts
    for id in pairs(timeouts) do
        cancel_timeout(id)
    end

    local core_copy = table.copy(core)
    return {
        _VERSION = _VERSION,
        assert = assert,
        core = core_copy,
        error = error,
        flow = flow_copy,
        formspec_ast = table.copy(formspec_ast),
        ipairs = ipairs,
        math = table.copy(math),
        minetest = core_copy,
        next = next,
        os = {clock = os.clock, date = os.date, difftime = os.difftime,
            time = os.time},
        pairs = pairs,
        pcall = pcall,
        player = core.get_player_by_name(PLAYER_NAME),
        print = print_to_chat,
        select = select,
        string = table.copy(string),
        table = table.copy(table),
        tonumber = tonumber,
        tostring = tostring,
        type = type,
        unpack = unpack,
        xpcall = xpcall,
    }
end

function window:run_playground_code(code)
    print("Loading playground code...")
    local f, err = load(code, "=(playground)", "t", reset_environment())
    if not f then
        print("Syntax error", err)
        output.innerHTML = ""
        chat_div.textContent = err
        return
    end

    local ok, res = pcall(f)
    if not ok then
        print("Runtime error", res)
        output.innerHTML = ""
        chat_div.textContent = res
        return
    end
    print("Playground code success")
end

print("Hello from init.lua!")

-- In case run_playground_code() was called before init.lua was loaded
if window.playground_code_tmp then
    print("window.playground_code_tmp exists")
    window:run_playground_code(window.playground_code_tmp)
    window.playground_code_tmp = nil
else
    print("window.playground_code_tmp does not exist")
end
