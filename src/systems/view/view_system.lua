local class = require "middleclass"

local Timer = require "hump.timer"

local TileDrawer = require "utils.tile_drawer"

local DrawHandler = require "systems.view.draw_handler"

local cells = require "enums.cells"
local EffectTypes = require "enums.effect_types"

local UpdateViewEvent = require "events.update_view_event"
local ShowEffectEvent = require "events.show_effect_event"
local ScreenLogEvent = require "events.screen_log_event"


local ViewSystem = class("ViewSystem", System)

function ViewSystem:initialize(data)
    System.initialize(self)

    if not data.map then
        error("ViewSystem:initialize data.map is nil!")
    end

    if not data.event_manager then
        error("ViewSystem:initialize data.event_manager is nil!")
    end

    self.map = data.map
    self.event_manager = data.event_manager

    self.timer = Timer.new()

    self.cell_size = 32
    self.radius_x = 15
    self.radius_y = 10

    self.shift_x = 8
    self.shift_y = 8

    self.map_canvas = love.graphics.newCanvas()
    self.ui_canvas = love.graphics.newCanvas()
    self.log_canvas = love.graphics.newCanvas()

    self.tc = TileDrawer()

    self.effects = {}

    self.draw_handler = DrawHandler({
        tc = self.tc,
        radius_x = self.radius_x,
        radius_y = self.radius_y,
        cell_size = self.cell_size,
        shift_x = self.shift_x,
        shift_y = self.shift_y,
    })
end

function ViewSystem:update(dt)
    self.timer:update(dt)
end

function ViewSystem:draw()
    love.graphics.setColor(1, 1, 1);
    love.graphics.draw(self.map_canvas)
    love.graphics.draw(self.ui_canvas)
    love.graphics.draw(self.log_canvas)
end

function ViewSystem:requires()
    return {}
end

function ViewSystem:handle_event(event)
    if event.class.name == UpdateViewEvent.name then
        self.draw_handler:draw_map({
            map_grid = self.map:get_grid(),
            hero = self.map:get_hero(),
            map = self.map,
            map_canvas = self.map_canvas,
            effects = self.effects
        })

        self.draw_handler:draw_ui({
            ui_canvas = self.ui_canvas,
            hero = self.map:get_hero(),
            map = self.map
        })
    elseif event.class.name == ShowEffectEvent.name then
        if event:get_type() == EffectTypes.no_path then
            local x, y = event:get_position()

            table.insert(self.effects, {cell = cells.no_path, x = x, y = y})

            local effect_index = #self.effects

            self.timer:after(
                0.1,
                function()
                    table.remove(self.effects, effect_index)
                    self.event_manager:fireEvent(UpdateViewEvent())
                end
            )
        elseif event:get_type() == EffectTypes.fight then
            local x, y = event:get_position()

            table.insert(self.effects, {cell = cells.fight, x = x, y = y})

            self.timer:after(
                0.1,
                function()
                    table.remove(self.effects, 1)
                    self.event_manager:fireEvent(UpdateViewEvent())
                end
            )
        end
    elseif event.class.name == ScreenLogEvent.name then
        self.draw_handler:draw_log({
            log_canvas = self.log_canvas,
            new_msg = event:get_message()
        })
    end
end

return ViewSystem
