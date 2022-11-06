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

dofile('renderer.lua?rev=10')

loadfile, dofile = loadfile_raw, dofile_raw

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


minetest = {}

local PLAYER_NAME = "playground"
local current_formname

function minetest.get_player_by_name(name)
    if name ~= PLAYER_NAME then return end

    return {
        get_player_name = function()
            return name
        end
    }
end

function minetest.get_connected_players()
    return {minetest.get_player_by_name(PLAYER_NAME)}
end

local chat
local chat_div = document:getElementById("chat")
function minetest.chat_send_all(msg)
    chat[#chat + 1] = msg
    if #chat > 10 then
        table.remove(chat, 1)
    end

    chat_div.textContent = table.concat(chat, "\n")
end

function minetest.chat_send_player(name, msg)
    if name == PLAYER_NAME then
        minetest.chat_send_all(msg)
    end
end

function minetest.is_yes(value)
    return value:lower() == "true"
end

local function noop() end
minetest.get_player_information = noop
minetest.register_on_leaveplayer = noop
minetest.is_singleplayer = noop
minetest.get_us_time = noop

local field_elems
local output = document:getElementById("output")
-- local fs_elem = document:getElementById("formspec")
function minetest.show_formspec(name, formname, formspec)
    assert(name == PLAYER_NAME)

    if formspec == "" then
        if formname == "" or formname == current_formname then
            current_formname = nil
            field_elems = nil
            output.innerHTML = ""
            output.classList:remove("fs-open")
        end
        return
    end

    current_formname = formname
    field_elems = {}
    output.innerHTML = ""
    output.classList:add("fs-open")

    local elem = assert(renderer.render_formspec(formspec, nil,
        {store_json = false}))

    output:appendChild(elem)

    -- fs_elem.textContent = formspec
end

function minetest.close_formspec(name, formname)
    minetest.show_formspec(name, formname, "")
end

-- Callbacks
local on_receive_fields = {}
local function fire_event(node_name, value, exit)
    local player = minetest.get_player_by_name(PLAYER_NAME)
    local fields = {}
    for field, elem in pairs(field_elems) do
        fields[field] = elem.value
    end
    fields[node_name] = value

    if exit then
        minetest.close_formspec(PLAYER_NAME, "")
    end

    for _, func in ipairs(on_receive_fields) do
        local ok, err = pcall(func, player, current_formname, fields)
        if not ok then
            minetest.chat_send_all(err)
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
                fire_event(node.name, tostring(dropdown.selectedIndex + 1))
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

function minetest.register_on_player_receive_fields(callback)
    on_receive_fields[#on_receive_fields + 1] = callback
end

-- Load flow
function minetest.get_current_modname() return "flow" end
function minetest.get_modpath(n) return n == "flow" and n or nil end
dofile("flow/init.lua")
minetest.get_current_modname = noop

local on_receive_fields_bkp = table.copy(on_receive_fields)

-- Makes a new Lua environment
local function reset_environment()
    chat = {}
    chat_div.textContent = ""

    minetest.close_formspec(PLAYER_NAME, "")
    on_receive_fields = table.copy(on_receive_fields_bkp)
    local flow_copy = {}
    for k, v in pairs(flow) do
        flow_copy[k] = v
    end
    return {
        print = function(...)
            local t = {}
            for i = 1, select("#", ...) do
                t[i] = tostring(select(i, ...))
            end
            minetest.chat_send_all(table.concat(t, "\t"))
        end,
        string = table.copy(string),
        table = table.copy(table),
        minetest = table.copy(minetest),
        flow = flow_copy,
        player = minetest.get_player_by_name(PLAYER_NAME),
        pairs = pairs,
        ipairs = ipairs,
    }
end

function window:run_playground_code(code)
    local f, err = load(code, "=(playground)", "t", reset_environment())
    if not f then
        output.classList:add("fs-open")
        output.innerHTML = ""
        chat_div.textContent = err
        return
    end

    output.classList:remove("fs-open")
    local ok, res = pcall(f)
    if not ok then
        output.classList:add("fs-open")
        output.innerHTML = ""
        chat_div.textContent = res
        return
    end
end
