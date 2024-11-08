-- Tutorial 2: Boxes
-- Flow has two "box" elements: gui.HBox and gui.VBox.
-- Boxes can be used to lay out multiple elements.
-- Click the "Run" button to try this code.

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    -- This creates a horizontal box with three elements.
    -- The three elements will be positioned to the right
    -- of each other.
    return gui.VBox{
        gui.Label{label = "Box demo:"},
        gui.HBox{
            -- gui.Box is equivalent to box[]
            gui.Box{w = 1, h = 1, color = "red"},
            gui.Box{w = 1, h = 1, color = "green"},
            gui.Box{w = 1, h = 1, color = "blue"},
        }
    }
end)

my_gui:show(core.get_player_by_name("playground"))
