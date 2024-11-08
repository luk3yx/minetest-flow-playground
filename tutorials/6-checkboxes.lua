-- Tutorial 6: Checkboxes and dropdowns
-- Checkboxes and dropdowns are used in a similar way as fields

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    return gui.VBox{
        gui.Checkbox{
            -- The name of the checkbox.
            name = "checkbox",

            -- The label of the checkbox.
            -- Flow will detect that you've accessed
            -- ctx.form.checkbox from here and will
            -- automatically redraw the form if the checkbox
            -- is clicked on.
            label = ctx.form.checkbox and "Uncheck me!" or "Check me!",

            -- The default value of the checkbox
            -- default = false,
        },

        -- When the GUI is first drawn, ctx.form.checkbox will
        -- be nil instead of the value of the checkbox. The
        -- same thing applies to other elements like fields
        -- and dropdowns.
        gui.Label{label = "Checkbox value: " .. tostring(ctx.form.checkbox)},

        -- Add a button that can be used to display the field's value
        gui.Button{
            label = "Display checkbox value",
            on_event = function(player, ctx)
                -- The checkbox value is guaranteed to exist
                -- from callbacks, flow will add it based on
                -- the default value of the checkbox.
                print("Checkbox value: " .. tostring(ctx.form.checkbox))
            end,
        },

        -- Add a button to toggle the checkbox
        gui.Button{
            label = "Toggle checkbox",
            on_event = function(player, ctx)
                ctx.form.checkbox = not ctx.form.checkbox

                -- Update the form
                return true
            end,
        },

        -- Separator
        gui.Box{w = 1, h = 0.05, color = "grey", padding = 0.25},

        -- Dropdown example
        gui.Label{label = "Dropdown example:"},

        gui.Dropdown{
            -- The name of the dropdown
            name = "test",

            -- A list of items
            items = {"Item 1", "Item 2", "Item 3"},

            -- Optional: The default index of the dropdown
            -- Note that ctx.form.<name> will override this
            -- value if it exists.
            selected_idx = 2,

            -- If index_event is enabled, ctx.form.dropdown
            -- will be a number instead of a string.
            index_event = true,
        },
        gui.Label{label = "Dropdown value: " .. tostring(ctx.form.test)},

        -- Add a button that can be used to display the dropdown's value
        gui.Button{
            label = "Display dropdown value",
            on_event = function(player, ctx)
                -- As with checkboxes, the value is guaranteed
                -- to not be nil here.
                print("Dropdown value: " .. ctx.form.test)
            end,
        },

        -- Add a button to change the dropdown's value
        gui.Button{
            label = "Set selected item to 1",
            on_event = function(player, ctx)
                -- If index_event is enabled:
                ctx.form.test = 1

                -- If index_event is not enabled:
                -- ctx.form.test = "Item 1"

                -- Redraw the form
                return true
            end,
        },
    }
end)

my_gui:show(core.get_player_by_name("playground"))
