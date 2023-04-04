-- Tutorial 7: Expansion and alignment
-- Elements can be expanded to fill in any empty space in the
-- form.

-- Elements are always expanded vertically if they're inside a
-- HBox, horizontally if they're inside a VBox, or in both
-- directions inside a Stack.

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    return gui.VBox{
        min_w = 10,
        gui.Label{label = "Expansion/alignment demo:"},

        -- This box has a width of 0.5 but gets automatically
        -- expanded to fill the remaining space.
        gui.Box{w = 0.5, h = 0.5, color = "white"},

        -- The default behaviour of expanded elements varies
        -- depending on the type, for example images are centred instead:
        gui.Image{w = 0.5, h = 0.5, texture_name = "default_mese_crystal.png"},

        -- However, if you put the same element into a HBox,
        -- it gets expanded vertically instead:
        gui.HBox{
            min_h = 1,
            gui.Label{label = "Not expanded:", w = 3},
            gui.Box{w = 0.5, h = 0.5, color = "white"},
        },

        -- You can make it get expanded in both directions by
        -- adding expand = true to the element's definition.
        gui.HBox{
            min_h = 1,
            gui.Label{label = "Expanded:", w = 3},
            gui.Box{w = 0.5, h = 0.5, color = "white", expand = true},
        },

        -- To control what an expanded node does with the extra
        -- space, you can set align_h (horizontal) or align_v
        -- (vertical) to one of the below:
        -- "auto" (default): Automatically chooses one of the
        -- below options based on the type of the element.
        -- "fill": Increases the size of the element to fill
        --         all remaining space
        -- "start", "top", "left": Positions the element at
        --                         the start.
        -- "center", "centre": Positions the element in the
        --                     middle of the expanded area.
        -- "end", "bottom", "right": Positions the element at
        --                           the end.
        -- Expanded space is shared equally between elements.
        gui.Label{label = "This label is centred!", align_h = "centre"},

        -- In this example, the "bottom right" button is
        -- pushed to the right-hand side of the form when the
        -- top left button gets expanded.
        gui.HBox{
            min_h = 1.5,
            gui.Button{label = "Top left", expand = true, align_h = "left", align_v = "top"},
            gui.Button{label = "Bottom right", align_v = "bottom"},
        },

        -- The gui.Spacer element automatically expands and
        -- can be used to separate groups of elements:
        gui.HBox{
            -- Left side
            gui.Box{w = 1, h = 1, color = "red"},
            gui.Box{w = 1, h = 1, color = "green"},
            gui.Box{w = 1, h = 1, color = "blue"},

            gui.Spacer{},

            -- Right side
            gui.Box{w = 1, h = 1, color = "red"},
            gui.Box{w = 1, h = 1, color = "green"},
            gui.Box{w = 1, h = 1, color = "blue"},
        },

        -- You need to take care with fields, since flow
        -- treats their label as part of the element. This
        -- can sometimes lead to unexpected behaviour (though
        -- I feel that if they behaved differently there would
        -- be even more unexpected behaviour).
        gui.HBox{
            gui.Field{
                name = "field1",
                label = "Misaligned button:",
                expand = true
            },

            -- This button will get expanded to include the
            -- height of the label!
            gui.Button{label = "Submit"},
        },

        -- You can fix this by aligning the button to the
        -- bottom of the HBox. Since buttons and fields have
        -- the same height by default they will be aligned
        -- properly.
        gui.HBox{
            gui.Field{
                name = "field2",
                label = "Properly aligned button:",
                expand = true
            },
            gui.Button{label = "Submit", align_v = "bottom"},
        },
    }
end)

-- If you want to try an interactive demonstration of
-- expansion, you can select "/flow-example form" in the
-- dropdown at the top of the page.

my_gui:show(minetest.get_player_by_name("playground"))

-- Tutorial 4 briefly mentioned the ability to set an
-- initial value for ctx. It's also possible to provide
-- data for ctx.form in that value:
-- my_gui:show(minetest.get_player_by_name("playground"), {
--     form = {field1 = "Value 1", field2 = "Value 2"}
-- })
