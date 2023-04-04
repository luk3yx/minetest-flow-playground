-- Tutorial 5: Fields
-- This tutorial shows how to use field values.

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    return gui.VBox{
        gui.Label{label = "Field demo:"},

        -- This is a button element
        gui.Field{
            -- The name of the field. The field's name can be
            -- used to access the value of the field by using
            -- ctx.form.<field name>. For example, you can get
            -- the value of this field with ctx.form.my_field.
            name = "my_field",

            -- The label of the field (optional)
            -- In a lot of cases it can be better to use a
            -- separate gui.Label element.
            label = "Field label",

            -- The default value of the field (optional)
            -- If ctx.form.<field name> is present, it will
            -- override this value.
            default = "Field value",

            -- You can also add on_event to fields, however
            -- this is not recommended as it is simpler to
            -- use ctx.form to get the field's value when
            -- needed.
            -- on_event = function(player, ctx)
            --     print("Field value sent to server!")
            -- end,
        },

        -- Add a button that can be used to display the field's value
        gui.Button{
            label = "Display field value",
            on_event = function(player, ctx)
                -- print() will display a "chat" message in the
                -- playground
                print("Field value: " .. ctx.form.my_field)
            end,
        },

        -- You can change a field's value by modifying ctx.form
        -- Note that flow currently doesn't have a workaround for
        -- https://github.com/minetest/minetest/issues/10432
        gui.Button{
            label = "Clear field",
            on_event = function(player, ctx)
                ctx.form.my_field = ""

                -- Update the form
                return true
            end,
        },
    }
end)

my_gui:show(minetest.get_player_by_name("playground"))
