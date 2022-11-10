-- Welcome to the flow playground!
-- This webpage provides a limited Lua environment to create
-- flow UIs with. If you edit the below code, you can click the
-- "run" button above this code editor to see the result.

-- Flow has a number of GUI elements defined in flow.widgets,
-- setting the gui variable to flow.widgets reduces the amount
-- of typing required.
local gui = flow.widgets

-- This creates a new GUI. The function passed to flow.make_gui
-- must return a valid GUI element which will be rendered.
local my_gui = flow.make_gui(function(player, ctx)
    -- The "player" variable is the player object.
    -- The "ctx" variable is explained later.
    return gui.Label{label = "Hello, " .. player:get_player_name() .. "!"}
end)

-- This shows the GUI to a player called "playground".
my_gui:show(minetest.get_player_by_name("playground"))

-- To see the next tutorial, click on the dropdown above
-- this code and select "Tutorial 2: Boxes".
