-- Tutorial 3: Spacing and padding
-- You can specify a "spacing" value on HBox and VBox to change
-- the amount of space that is between elements inside the box.

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    -- This creates a horizontal box with three elements.
    -- The three elements will be positioned to the right
    -- of each other.
    return gui.VBox{
        -- gui.HBox and gui.VBox can have a "spacing" field
        -- which sets the amount of spacing between the
        -- elements. If unspecified, this defaults to 0.2.
        gui.Label{label = "Spacing = 0.5:"},
        gui.HBox{
            spacing = 0.5,

            gui.Box{w = 1, h = 1, color = "red"},
            gui.Box{w = 1, h = 1, color = "green"},
            gui.Box{w = 1, h = 1, color = "blue"},
        },

        -- You can set a spacing of 0 to have no spacing
        -- between the elements inside the box.
        gui.Label{label = "Spacing = 0:"},
        gui.HBox{
            spacing = 0,
            gui.Box{w = 1, h = 1, color = "red"},
            gui.Box{w = 1, h = 1, color = "green"},
            gui.Box{w = 1, h = 1, color = "blue"},
        },

        -- If no "spacing" field is specified, it defaults to 0.2.
        gui.Label{label = "Spacing = 0.2 (default):"},
        gui.HBox{
            gui.Box{w = 1, h = 1, color = "red"},
            gui.Box{w = 1, h = 1, color = "green"},
            gui.Box{w = 1, h = 1, color = "blue"},
        },

        -- All elements can have a "padding" value to add
        -- empty space around the element. Defaults to 0.
        -- The image will be horizontally centred because
        -- it is in a VBox, this is explained in the expansion
        -- and alignment tutorial.
        gui.Label{label = "Padding demo:"},
        gui.Image{
            w = 1, h = 1,
            texture_name = "default_glass.png",
            padding = 0.5,
        },
    }
end)

my_gui:show(core.get_player_by_name("playground"))
