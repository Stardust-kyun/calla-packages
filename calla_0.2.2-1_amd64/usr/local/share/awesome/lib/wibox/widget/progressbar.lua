---------------------------------------------------------------------------
--- A progressbar widget.
--
-- ![Components](../images/progressbar.svg)
--
-- Common usage examples
-- =====================
--
-- To add text on top of the progressbar, a `wibox.layout.stack` can be used:
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_text.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--     wibox.widget {
--         {
--             max_value     = 1,
--             value         = 0.5,
--             forced_height = 20,
--             forced_width  = 100,
--             paddings      = 1,
--             border_width  = 1,
--             border_color  = beautiful.border_color,
--             widget        = wibox.widget.progressbar,
--         },
--         {
--             text   = &#3450%&#34,
--             valign = &#34center&#34,
--             halign = &#34center&#34,
--             widget = wibox.widget.textbox,
--         },
--         layout = wibox.layout.stack
--     }
--
-- To display the progressbar vertically, use a `wibox.container.rotate` widget:
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_vertical.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--     wibox.widget {
--         {
--             max_value     = 1,
--             value         = 0.33,
--             widget        = wibox.widget.progressbar,
--         },
--         forced_height = 100,
--         forced_width  = 20,
--         direction     = &#34east&#34,
--         layout        = wibox.container.rotate,
--     }
--
-- By default, this widget will take all the available size. To prevent this,
-- a `wibox.container.constraint` widget or the `forced_width`/`forced_height`
-- properties have to be used.
--
-- To have a gradient between 2 colors when the bar reaches a threshold, use
-- the `gears.color` gradients:
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_grad1.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--     wibox.widget {
--         color = {
--             type  = &#34linear&#34,
--             from  = { 0  , 0 },
--             to    = { 100, 0 },
--             stops = {
--                 { 0  , &#34#0000ff&#34 },
--                 { 0.8, &#34#0000ff&#34 },
--                 { 1  , &#34#ff0000&#34 }
--             }
--         },
--         max_value     = 1,
--         value         = 1,
--         forced_height = 20,
--         forced_width  = 100,
--         paddings      = 1,
--         border_width  = 1,
--         border_color  = beautiful.border_color,
--         widget        = wibox.widget.progressbar,
--     }
--
-- The same goes for multiple solid colors:
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_grad2.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--     for _, value in ipairs { 0.3, 0.5, 0.7, 1 } do
--         wibox.widget {
--             color = {
--                 type  = &#34linear&#34,
--                 from  = { 0  , 0 },
--                 to    = { 100, 0 },
--                 stops = {
--                     { 0  , &#34#00ff00&#34 },
--                     { 0.5, &#34#00ff00&#34 },
--                     { 0.5, &#34#ffff00&#34 },
--                     { 0.7, &#34#ffff00&#34 },
--                     { 0.7, &#34#ffaa00&#34 },
--                     { 0.8, &#34#ffaa00&#34 },
--                     { 0.8, &#34#ff0000&#34 },
--                     { 1  , &#34#ff0000&#34 }
--                 }
--             },
--             max_value     = 1,
--             value         = value,
--             forced_height = 20,
--             forced_width  = 100,
--             paddings      = 1,
--             border_width  = 1,
--             border_color  = beautiful.border_color,
--             widget        = wibox.widget.progressbar,
--         }
--     end
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_defaults_progressbar.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- wibox.widget {
--     max_value     = 1,
--     value         = 0.33,
--     forced_height = 20,
--     forced_width  = 100,
--     shape         = gears.shape.rounded_bar,
--     border_width  = 2,
--     border_color  = beautiful.border_color,
--     widget        = wibox.widget.progressbar,
-- }
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @widgetmod wibox.widget.progressbar
-- @supermodule wibox.widget.base
---------------------------------------------------------------------------

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local gdebug =  require("gears.debug")
local base = require("wibox.widget.base")
local color = require("gears.color")
local beautiful = require("beautiful")
local shape = require("gears.shape")
local gtable = require("gears.table")

local progressbar = { mt = {} }

--- The progressbar border color.
--
-- If the value is nil, no border will be drawn.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_border_color.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, color in ipairs { {nil}, {&#34#ff0000&#34}, {&#34#00ff00&#34}, {&#34#0000ff44&#34} } do
--     wibox.widget {
--         value        = 0.33,
--         border_width = 2,
--         border_color = color[1],
--         widget       = wibox.widget.progressbar,
--     }
-- end
--
-- @property border_color
-- @tparam color|nil border_color The border color to set.
-- @propemits true false
-- @propbeautiful
-- @see gears.color

--- The progressbar border width.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_border_width.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, width in ipairs { 0, 2, 4, 6 } do
--     wibox.widget {
--         value        = 0.33,
--         border_width = width,
--         border_color = &#34#ff0000&#34,
--         widget       = wibox.widget.progressbar,
--     }
-- end
--
-- @property border_width
-- @tparam number|nil border_width
-- @propertytype nil Defaults to `beautiful.progressbar_border_width`.
-- @propertytype number The number of pixels
-- @propertyunit pixel
-- @negativeallowed false
-- @propbeautiful
-- @propemits true false
-- @propbeautiful

--- The progressbar inner border color.
--
-- If the value is nil, no border will be drawn.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_bar_border_color.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, color in ipairs { {nil}, {&#34#ff0000&#34}, {&#34#00ff00&#34}, {&#34#0000ff44&#34} } do
--     wibox.widget {
--         value            = 0.33,
--         bar_border_width = 2,
--         bar_border_color = color[1],
--         widget           = wibox.widget.progressbar,
--     }
-- end
--
-- @property bar_border_color
-- @tparam color|nil bar_border_color The border color to set.
-- @propemits true false
-- @propbeautiful
-- @see gears.color

--- The progressbar inner border width.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_bar_border_width.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, width in ipairs { 0, 2, 4, 6 } do
--     wibox.widget {
--         value            = 0.33,
--         bar_border_width = width,
--         bar_border_color = &#34#ff0000&#34,
--         widget           = wibox.widget.progressbar,
--     }
-- end
--
-- @property bar_border_width
-- @tparam number|nil bar_border_width
-- @propertyunit pixel
-- @negativeallowed false
-- @propbeautiful
-- @usebeautiful beautiful.progressbar_border_width Fallback when
--  `beautiful.progressbar_bar_border_width` isn't set.
-- @propemits true false

--- The progressbar foreground color.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_color.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, color in ipairs { {nil}, {&#34#ff0000&#34}, {&#34#00ff00&#34}, {&#34#0000ff44&#34} } do
--     wibox.widget {
--         value  = 0.33,
--         color  = color[1],
--         widget = wibox.widget.progressbar,
--     }
-- end
--
-- @property color
-- @tparam color|nil color The progressbar color.
-- @propertytype nil Fallback to the current value of `beautiful.progressbar_fg`.
-- @propemits true false
-- @usebeautiful beautiful.progressbar_fg
-- @see gears.color

--- The progressbar background color.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_background_color.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, color in ipairs { {nil}, {&#34#ff0000&#34}, {&#34#00ff00&#34}, {&#34#0000ff44&#34} } do
--     wibox.widget {
--         value            = 0.33,
--         background_color = color[1],
--         widget           = wibox.widget.progressbar,
--     }
-- end
--
-- @property background_color
-- @tparam color|nil background_color The progressbar background color.
-- @propertytype nil Fallback to the current value of `beautiful.progressbar_bg`.
-- @propemits true false
-- @usebeautiful beautiful.progressbar_bg
-- @see gears.color

--- The progressbar inner shape.
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_bar_shape.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, shape in ipairs {&#34rounded_bar&#34, &#34octogon&#34, &#34hexagon&#34, &#34powerline&#34 } do
--     l:add(wibox.widget {
--           value            = 0.33,
--           bar_shape        = gears.shape[shape],
--           bar_border_color = beautiful.border_color,
--           bar_border_width = 1,
--           border_width     = 2,
--           border_color     = beautiful.border_color,
--           paddings         = 1,
--           widget           = wibox.widget.progressbar,
--       })
-- end
--
-- @property bar_shape
-- @tparam shape|nil bar_shape
-- @propemits true false
-- @propbeautiful
-- @see gears.shape

--- The progressbar shape.
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_shape.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, shape in ipairs {&#34rounded_bar&#34, &#34octogon&#34, &#34hexagon&#34, &#34powerline&#34 } do
--     l:add(wibox.widget {
--           value         = 0.33,
--           shape         = gears.shape[shape],
--           border_width  = 2,
--           border_color  = beautiful.border_color,
--           widget        = wibox.widget.progressbar,
--       })
-- end
--
-- @property shape
-- @tparam shape|nil shape
-- @propemits true false
-- @propbeautiful
-- @see gears.shape

--- Set the progressbar to draw vertically.
--
-- This doesn't do anything anymore, use a `wibox.container.rotate` widget.
--
-- @deprecated set_vertical
-- @tparam boolean vertical
-- @deprecatedin 4.0

--- Force the inner part (the bar) to fit in the background shape.
--
--
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_clip.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
--     wibox.widget {
--         value            = 75,
--         max_value        = 100,
--         border_width     = 2,
--         border_color     = beautiful.border_color,
--         color            = beautiful.border_color,
--         shape            = gears.shape.rounded_bar,
--         bar_shape        = gears.shape.rounded_bar,
--         clip             = false,
--         forced_height    = 30,
--         forced_width     = 100,
--         paddings         = 5,
--         margins          = {
--             top    = 12,
--             bottom = 12,
--         },
--         widget = wibox.widget.progressbar,
--     }
--
-- @property clip
-- @tparam[opt=true] boolean clip
-- @propemits true false

--- The progressbar to draw ticks.
--
-- The add a little bar in between the values.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_ticks.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, has_ticks in ipairs { true, false } do
--     wibox.widget {
--         value        = 0.33,
--         border_width = 2,
--         ticks        = has_ticks,
--         widget       = wibox.widget.progressbar,
--     }
-- end
--
-- @property ticks
-- @tparam[opt=false] boolean ticks
-- @propemits true false
-- @see ticks_gap
-- @see ticks_size

--- The progressbar ticks gap.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_ticks_gap.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, gap in ipairs { 0, 2, 4, 6 } do
--     wibox.widget {
--         value        = 0.33,
--         border_width = 2,
--         ticks        = true,
--         ticks_gap    = gap,
--         widget       = wibox.widget.progressbar,
--     }
-- end
--
-- @property ticks_gap
-- @tparam[opt=1] number ticks_gap
-- @propertyunit pixel
-- @negativeallowed false
-- @propemits true false
-- @see ticks_size
-- @see ticks

--- The progressbar ticks size.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_ticks_size.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--    for _, size in ipairs { 0, 2, 4, 6 } do
--        wibox.widget {
--            value        = 0.33,
--            border_width = 2,
--            ticks        = true,
--            ticks_size   = size,
--            widget       = wibox.widget.progressbar,
--        }
--    end
--
-- It is also possible to mix this feature with the `bar_shape` property:
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_ticks_size2.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--    for _, size in ipairs { 0, 2, 4, 6 } do
--        -- Plane shapes.
--        wibox.widget {
--            value        = 1,
--            border_width = 2,
--            ticks        = true,
--            ticks_size   = size,
--            ticks_gap    = 3,
--            paddings     = 2,
--            bar_shape    = gears.shape.rounded_bar,
--            widget       = wibox.widget.progressbar,
--        }
--         
--        -- With a border for each shape.
--        wibox.widget {
--            value            = 1,
--            border_width     = 2,
--            ticks            = true,
--            ticks_size       = size,
--            ticks_gap        = 3,
--            paddings         = 2,
--            bar_shape        = gears.shape.rounded_bar,
--            bor_border_width = 2,
--            bar_border_color = beautiful.border_color,
--            widget           = wibox.widget.progressbar,
--        }
--         
--        -- With a gradient.
--        wibox.widget {
--            color = {
--                type  = &#34linear&#34,
--                from  = { 0 , 0 },
--                to    = { 65, 0 },
--                stops = {
--                    { 0   , &#34#0000ff&#34 },
--                    { 0.75, &#34#0000ff&#34 },
--                    { 1   , &#34#ff0000&#34 }
--                }
--            },
--            paddings     = 2,
--            value        = 1,
--            border_width = 2,
--            ticks        = true,
--            ticks_size   = size,
--            ticks_gap    = 3,
--            bar_shape    = gears.shape.rounded_bar,
--            widget       = wibox.widget.progressbar,
--        }
--    end
--
-- @property ticks_size
-- @tparam[opt=4] number ticks_size
-- @propertyunit pixel
-- @negativeallowed false
-- @propemits true false
-- @see ticks_gap
-- @see ticks

--- The maximum value the progressbar should handle.
--
-- By default, the value is 1. So the content of `value` is
-- a percentage.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_max_value.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, value in ipairs { 0, 10, 42, 999 } do
--     wibox.widget {
--         value     = value,
--         max_value = 42,
--         widget    = wibox.widget.progressbar,
--     }
-- end
--
-- @property max_value
-- @tparam[opt=1] number max_value
-- @negativeallowed true
-- @propemits true false
-- @see value

--- The progressbar background color.
--
-- @beautiful beautiful.progressbar_bg
-- @param color

--- The progressbar foreground color.
--
-- @beautiful beautiful.progressbar_fg
-- @param color

--- The progressbar shape.
--
-- @beautiful beautiful.progressbar_shape
-- @tparam[opt=gears.shape.rectangle] shape shape
-- @see gears.shape

--- The progressbar border color.
--
-- @beautiful beautiful.progressbar_border_color
-- @param color

--- The progressbar outer border width.
--
-- @beautiful beautiful.progressbar_border_width
-- @param number

--- The progressbar inner shape.
--
-- @beautiful beautiful.progressbar_bar_shape
-- @tparam[opt=gears.shape.rectangle] gears.shape shape
-- @see gears.shape

--- The progressbar bar border width.
--
-- @beautiful beautiful.progressbar_bar_border_width
-- @param number

--- The progressbar bar border color.
--
-- @beautiful beautiful.progressbar_bar_border_color
-- @param color

--- The progressbar margins.
--
-- The margins are around the progressbar. If you want to add space between the
-- bar and the border, use `paddings`.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_margins2.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--    wibox.widget {
--        {
--            margins = {
--                top    = 4,
--                bottom = 2,
--                right  = 10,
--                left   = 5
--            },
--            value        = 0.33,
--            border_width = 2,
--            border_color = &#34#00ff00&#34,
--            background   = &#34#0000ff&#34,
--            widget       = wibox.widget.progressbar,
--        },
--        forced_width = 75, --DOC_hIDE
--        bg     = &#34#ff0000&#34,
--        widget = wibox.container.background
--    }
--
-- Note that if the `clip` is disabled, this allows the background to be smaller
-- than the bar.
--
-- It is also possible to specify a single number instead of a border for each
-- direction;
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_margins1.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, margin in ipairs { 0, 2, 4, 6 } do
--     wibox.widget {
--         value   = 0.33,
--         margins = margin,
--         widget  = wibox.widget.progressbar,
--     }
-- end
--
-- @property margins
-- @tparam[opt=0] table|number|nil margins A table for each side or a number
-- @tparam[opt=0] number margins.top
-- @tparam[opt=0] number margins.bottom
-- @tparam[opt=0] number margins.left
-- @tparam[opt=0] number margins.right
-- @propertyunit pixel
-- @negativeallowed true
-- @propertytype number Use the same value for each side.
-- @propertytype table Use a different value for each side:
-- @propemits false false
-- @propbeautiful
-- @see clip
-- @see paddings
-- @see wibox.container.margin

--- The progressbar padding.
--
-- This is the space between the inner bar and the progressbar outer border.
--
-- Note that if the `clip` is disabled, this allows the bar to be taller
-- than the background.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_paddings2.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--    wibox.widget {
--        paddings = {
--            top    = 4,
--            bottom = 2,
--            right  = 10,
--            left   = 5
--        },
--        value            = 1,
--        border_width     = 2,
--        border_color     = &#34#00ff00&#34,
--        bar_border_wisth = 2,
--        bar_border_color = &#34#ffff00&#34,
--        bor_color        = &#34#ff00ff&#34,
--        background       = &#34#0000ff&#34,
--        widget           = wibox.widget.progressbar,
--    }
--
-- The paddings can also be a single numeric value:
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_paddings1.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, padding in ipairs { 0, 2, 4, 6 } do
--     wibox.widget {
--         value   = 0.33,
--         paddings = padding,
--         widget  = wibox.widget.progressbar,
--     }
-- end
--
-- @property paddings
-- @tparam[opt=0] table|number|nil paddings A table for each side or a number
-- @tparam[opt=0] number paddings.top
-- @tparam[opt=0] number paddings.bottom
-- @tparam[opt=0] number paddings.left
-- @tparam[opt=0] number paddings.right
-- @propertyunit pixel
-- @negativeallowed true
-- @propertytype number Use the same value for each side.
-- @propertytype table Use a different value for each side:
-- @propemits false false
-- @propbeautiful
-- @see clip
-- @see margins

--- The progressbar margins.
--
-- Note that if the `clip` is disabled, this allows the background to be smaller
-- than the bar.
-- @beautiful beautiful.progressbar_margins
-- @tparam[opt=0] (table|number|nil) margins A table for each side or a number
-- @tparam[opt=0] number margins.top
-- @tparam[opt=0] number margins.bottom
-- @tparam[opt=0] number margins.left
-- @tparam[opt=0] number margins.right
-- @see clip
-- @see beautiful.progressbar_paddings
-- @see wibox.container.margin

--- The progressbar padding.
--
-- Note that if the `clip` is disabled, this allows the bar to be taller
-- than the background.
-- @beautiful beautiful.progressbar_paddings
-- @tparam[opt=0] (table|number|nil) padding A table for each side or a number
-- @tparam[opt=0] number paddings.top
-- @tparam[opt=0] number paddings.bottom
-- @tparam[opt=0] number paddings.left
-- @tparam[opt=0] number paddings.right
-- @see clip
-- @see beautiful.progressbar_margins


local properties = { "border_color", "color"     , "background_color",
                     "value"       , "max_value" , "ticks",
                     "ticks_gap"   , "ticks_size", "border_width",
                     "shape"       , "bar_shape" , "bar_border_width",
                     "clip"        , "margins"   , "bar_border_color",
                     "paddings",
                   }

function progressbar.draw(pbar, _, cr, width, height)
    local ticks_gap = pbar._private.ticks_gap or 1
    local ticks_size = pbar._private.ticks_size or 4

    -- We want one pixel wide lines
    cr:set_line_width(1)

    local max_value = pbar._private.max_value

    local value = math.min(max_value, math.max(0, pbar._private.value))

    if value >= 0 then
        value = value / max_value
    end
    local border_width = pbar._private.border_width
        or beautiful.progressbar_border_width or 0

    local bcol = pbar._private.border_color or beautiful.progressbar_border_color

    border_width = bcol and border_width or 0

    local bg = pbar._private.background_color or
        beautiful.progressbar_bg or "#ff0000aa"

    local bg_width, bg_height = width, height

    local clip = pbar._private.clip ~= false and beautiful.progressbar_clip ~= false

    -- Apply the margins
    local margin = pbar._private.margins or beautiful.progressbar_margins

    if margin then
        if type(margin) == "number" then
            cr:translate(margin, margin)
            bg_width, bg_height = bg_width - 2*margin, bg_height - 2*margin
        else
            cr:translate(margin.left or 0, margin.top or 0)
            bg_height = bg_height -
                (margin.top  or 0) - (margin.bottom or 0)
            bg_width = bg_width   -
                (margin.left or 0) - (margin.right  or 0)
        end
    end

    -- Draw the background shape
    if border_width > 0 then
        -- Cairo draw half of the border outside of the path area
        cr:translate(border_width/2, border_width/2)
        bg_width, bg_height = bg_width - border_width, bg_height - border_width
        cr:set_line_width(border_width)
    end

    local background_shape = pbar._private.shape or
        beautiful.progressbar_shape or shape.rectangle

    background_shape(cr, bg_width, bg_height)

    cr:set_source(color(bg))

    local over_drawn_width  = bg_width  + border_width
    local over_drawn_height = bg_height + border_width

    if border_width > 0 then
        cr:fill_preserve()

        -- Draw the border
        cr:set_source(color(bcol))

        cr:stroke()

        over_drawn_width  = over_drawn_width  - 2*border_width
        over_drawn_height = over_drawn_height - 2*border_width
    else
        cr:fill()
    end

    -- Undo the translation
    cr:translate(-border_width/2, -border_width/2)

    -- Make sure the bar stay in the shape
    if clip then
        background_shape(cr, bg_width, bg_height)
        cr:clip()
        cr:translate(border_width, border_width)
    else
        -- Assume the background size is irrelevant to the bar itself
        if type(margin) == "number" then
            cr:translate(-margin, -margin)
        else
            cr:translate(-(margin.left or 0), -(margin.top or 0))
        end

        over_drawn_height = height
        over_drawn_width  = width
    end

    -- Apply the padding
    local padding = pbar._private.paddings or beautiful.progressbar_paddings

    if padding then
        if type(padding) == "number" then
            cr:translate(padding, padding)
            over_drawn_height = over_drawn_height - 2*padding
            over_drawn_width  = over_drawn_width  - 2*padding
        else
            cr:translate(padding.left or 0, padding.top or 0)

            over_drawn_height = over_drawn_height -
                (padding.top  or 0) - (padding.bottom or 0)
            over_drawn_width = over_drawn_width   -
                (padding.left or 0) - (padding.right  or 0)
        end
    end

    over_drawn_width  = math.max(over_drawn_width , 0)
    over_drawn_height = math.max(over_drawn_height, 0)

    local rel_x = over_drawn_width * value


    -- Draw the progressbar shape

    local explicit_bar_shape = pbar._private.bar_shape or beautiful.progressbar_bar_shape
    local bar_shape = explicit_bar_shape or shape.rectangle

    local bar_border_width = pbar._private.bar_border_width or
        beautiful.progressbar_bar_border_width or pbar._private.border_width or
        beautiful.progressbar_border_width or 0

    local bar_border_color = pbar._private.bar_border_color or
        beautiful.progressbar_bar_border_color

    bar_border_width = bar_border_color and bar_border_width or 0

    over_drawn_width  = over_drawn_width  - bar_border_width
    over_drawn_height = over_drawn_height - bar_border_width
    cr:translate(bar_border_width/2, bar_border_width/2)

    if pbar._private.ticks and explicit_bar_shape then
        local tr_off = 0

        -- Make all the shape and fill later in case the `color` is a gradient.
        for _=0, width / (ticks_size+ticks_gap)-border_width do
            bar_shape(cr, ticks_size - (bar_border_width/2), over_drawn_height)
            cr:translate(ticks_size+ticks_gap, 0)
            tr_off = tr_off + ticks_size+ticks_gap
        end

        -- Re-align the (potential) color gradients to 0,0.
        cr:translate(-tr_off, 0)

        if bar_border_width > 0 then
            cr:set_source(color(bar_border_color))
            cr:set_line_width(bar_border_width)
            cr:stroke_preserve()
        end

        cr:set_source(color(pbar._private.color or beautiful.progressbar_fg or "#ff0000"))

        cr:fill()
    else
        bar_shape(cr, rel_x, over_drawn_height)

        cr:set_source(color(pbar._private.color or beautiful.progressbar_fg or "#ff0000"))

        if bar_border_width > 0 then
            cr:fill_preserve()
            cr:set_source(color(bar_border_color))
            cr:set_line_width(bar_border_width)
            cr:stroke()
        else
            cr:fill()
        end
    end

    -- Legacy "ticks" bars. It looks horrible, but to avoid breaking the
    -- behavior, so be it.
    if pbar._private.ticks  and not explicit_bar_shape then
        for i=0, width / (ticks_size+ticks_gap)-border_width do
            local rel_offset = over_drawn_width / 1 - (ticks_size+ticks_gap) * i

            if rel_offset <= rel_x then
                cr:rectangle(rel_offset,
                                border_width,
                                ticks_gap,
                                over_drawn_height)
            end
        end
        cr:set_source(color(pbar._private.background_color or "#000000aa"))
        cr:fill()
    end
end

function progressbar:fit(_, width, height)
    return width, height
end

--- Set the progressbar value.
--
-- By default, unless `max_value` is set, it is number between
-- zero and one.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_wibox_widget_progressbar_value.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- @usage
-- for _, value in ipairs { 0, 0.2, 0.5, 1 } do
--     wibox.widget {
--         value  = value,
--         widget = wibox.widget.progressbar,
--     }
-- end
--
-- @property value
-- @tparam[opt=0] number value
-- @negativeallowed true
-- @propemits true false
-- @see max_value

function progressbar:set_value(value)
    value = value or 0

    self._private.value = value

    self:emit_signal("widget::redraw_needed")
    return self
end

function progressbar:set_max_value(max_value)

    self._private.max_value = max_value

    self:emit_signal("widget::redraw_needed")
end

--- Set the progressbar height.
--
-- This method is deprecated.  Use a `wibox.container.constraint` widget or
-- `forced_height`.
--
-- @tparam number height The height to set.
-- @deprecated set_height
-- @renamedin 4.0
function progressbar:set_height(height)
    gdebug.deprecate("Use a `wibox.container.constraint` widget or `forced_height`", {deprecated_in=4})
    self:set_forced_height(height)
end

--- Set the progressbar width.
--
-- This method is deprecated.  Use a `wibox.container.constraint` widget or
-- `forced_width`.
--
-- @tparam number width The width to set.
-- @deprecated set_width
-- @renamedin 4.0
function progressbar:set_width(width)
    gdebug.deprecate("Use a `wibox.container.constraint` widget or `forced_width`", {deprecated_in=4})
    self:set_forced_width(width)
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not progressbar["set_" .. prop] then
        progressbar["set_" .. prop] = function(pbar, value)
            pbar._private[prop] = value
            pbar:emit_signal("widget::redraw_needed")
            pbar:emit_signal("property::"..prop, value)
            return pbar
        end
    end
    if not progressbar["get_"..prop] then
        progressbar["get_" .. prop] = function(pbar)
            return pbar._private[prop]
        end
    end
end

function progressbar:set_vertical(value) --luacheck: no unused_args
    gdebug.deprecate("Use a `wibox.container.rotate` widget", {deprecated_in=4})
end


--- Create a progressbar widget.
--
-- @tparam table args Standard widget() arguments. You should add width and
--  height constructor parameters to set progressbar geometry.
-- @tparam[opt] number args.width The width.
-- @tparam[opt] number args.height The height.
-- @tparam[opt] gears.color args.border_color The progressbar border color.
-- @tparam[opt] number args.border_width The progressbar border width.
-- @tparam[opt] gears.color args.bar_border_color The progressbar inner border color.
-- @tparam[opt] number args.bar_border_width The progressbar inner border width.
-- @tparam[opt] gears.color args.color The progressbar foreground color.
-- @tparam[opt] gears.color args.background_color The progressbar background color.
-- @tparam[opt] gears.shape args.bar_shape The progressbar inner shape.
-- @tparam[opt] gears.shape args.shape The progressbar shape.
-- @tparam[opt] boolean args.clip Force the inner part (the bar) to fit in the background shape.
-- @tparam[opt] boolean args.ticks The progressbar to draw ticks.
-- @tparam[opt] number args.ticks_gap The progressbar ticks gap.
-- @tparam[opt] number args.ticks_size The progressbar ticks size.
-- @tparam[opt] number args.max_value The maximum value the progressbar should handle.
-- @tparam[opt] table|number args.margins The progressbar margins.
-- @tparam[opt] table|number args.paddings The progressbar padding.
-- @tparam[opt] number args.value Set the progressbar value.
-- @treturn wibox.widget.progressbar A progressbar widget.
-- @constructorfct wibox.widget.progressbar
function progressbar.new(args)
    args = args or {}

    local pbar = base.make_widget(nil, nil, {
        enable_properties = true,
    })

    pbar._private.width     = args.width or 100
    pbar._private.height    = args.height or 20
    pbar._private.value     = 0
    pbar._private.max_value = 1

    gtable.crush(pbar, progressbar, true)

    return pbar
end

function progressbar.mt:__call(...)
    return progressbar.new(...)
end

return setmetatable(progressbar, progressbar.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
