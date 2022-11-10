local gui = flow.widgets

local my_gui = flow.make_gui(function(player, ctx)
    return gui.VBox{
        gui.HBox{
            gui.Image{texture_name = "default_mese_crystal.png", w = 1, h = 1},
            gui.Label{label = "Hello world!"},
        },
        gui.Label{label = "Here is a dropdown:"},
        gui.Dropdown{
            name = "my_dropdown",
            items = {'First item', 'Second item', 'Third item'},
            index_event = true,
        },
        gui.Label{label = ("Selected: %d"):format(ctx.form.my_dropdown or 1)},
        gui.HBox{
            gui.Button{
                label = "Print index", w = 3,
                on_event = function(player, ctx)
                    print(("Selected index: %d"):format(ctx.form.my_dropdown))
                end,
            },
            gui.ButtonExit{label = "Close form", w = 3},
        }
    }
end)

my_gui:show(minetest.get_player_by_name("playground"))
