-- Tutorial 4: Buttons and events
-- This tutorial shows how to add callbacks to buttons.

local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    -- The "ctx" variable is a table that you can use to store
    -- context-specific values. Note that "ctx.form" is
    -- reserved and will be explained in a later tutorial.

    return gui.VBox{
        gui.Label{label = "Callback demo:"},

        -- This is a button element
        gui.Button{
            -- Buttons can have a name which can be used for
            -- styling, however this is optional.
            -- name = "my_button",

            -- The label of the button
            label = "Click me!",

            -- The on_event function is called when the button
            -- is pressed. It gets passed "player" and "ctx"
            -- arguments which should be used instead of the
            -- player and ctx arguments above.
            on_event = function(player, ctx)
                minetest.chat_send_player(player:get_player_name(),
                    "Button pressed!")

                -- Increase the saved count
                ctx.count = (ctx.count or 0) + 1

                -- on_event functions can return true if the
                -- form should be redrawn. If you comment this
                -- out, the below "button presses" label won't
                -- be updated when the button is pressed.
                return true
            end,
        },

        -- Show the amount of button presses
        gui.Label{
            label = "Button presses: " .. (ctx.count or "(none)"),

            -- When the label's value changes, the form's size
            -- may change. This is because the label's width is
            -- calculated based on the length of its text. This
            -- is not always an issue, other elements may be
            -- larger than the label and prevent it from
            -- increasing the size of the form.

            -- To fix this issue, you can specifiy a minimum
            -- width for the label with "min_w". You can see
            -- this problem by commenting out the below line
            -- and clicking "run".
            min_w = 5,

            -- To stop flow from using the label's text to
            -- calculate the width, you can specify a width
            -- manually. However, the form may break if the
            -- label is too long to fit.
            -- w = 4,
        },
    }
end)

my_gui:show(minetest.get_player_by_name("playground"))

-- You can provide an initial value for ctx by adding a second
-- parameter to show(). The below code will start the counter
-- at 10.
-- my_gui:show(minetest.get_player_by_name("playground"), {count = 10})
