-- Tutorial 8: Scroll containers
-- Flow provides a simple API to create a scrollable container.
-- The scrollbar size is calculated automatically and older
-- clients fall back to a paginator so that the form is still
-- usable.

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    return gui.VBox{
        gui.Label{label = "ScrollableVBox demo:"},

        -- The playground doesn't support scroll_container[] so
        -- you will see the fallback that gets sent to older
        -- clients. If you want to see this work with a
        -- scrollbar, try running this code in-game with
        -- https://content.luanti.org/packages/luk3yx/snippets
        gui.ScrollableVBox{
            -- A name must be provided for ScrollableVBox
            -- elements. You don't have to use this name
            -- anywhere else, it just makes sure flow doesn't
            -- mix up scrollbar states if one gets removed or
            -- if the order changes.
            name = "vbox1",

            -- The height should be set. You can also set a
            -- width, however it isn't required and will be
            -- calculated from the contents if unspecified.
            h = 5,

            -- Content
            gui.Label{label="I am a label!"},
            gui.Label{label="I am a second label!"},
            gui.Field{name = "field", label = "Field"},
            gui.Checkbox{name = "checkbox", label = "Checkbox"},
            gui.Image{w = 4, h = 4, texture_name = "default_mese_crystal.png"},
            gui.List{
                inventory_location = "current_player",
                list_name = "main",
                w = 8,
                h = 4,
            },
        },
    }
end)

my_gui:show(core.get_player_by_name("playground"))
