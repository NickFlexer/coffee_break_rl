local class = require "middleclass"
local Grid = require "grid"
local Ring = require "ringer"

local FOV = require "ppfov"

local GenerateMapEvent = require "events.generate_map_event"
local SolveFovEvent = require "events.solve_fov_event"

local Ground = require "world.cells.ground"
local Mushroom = require "world.cells.mushroom"

local MapType = require "enums.map_type"
local cells = require "enums.cells"


local Map = class("Map")

function Map:initialize(data)
    self.map_size_x = 50
    self.map_size_y = 30
    self.world_map = Grid(self.map_size_x, self.map_size_y)

    for x, y, cell in self.world_map:iterate() do
        self.world_map:set_cell(x, y, Ground())
    end

    self.hero = data.hero

    self.characters = Ring()

    self.characters:insert(self.hero)
end

function Map:get_grid()
    return self.world_map
end

function Map:handle_event(event)
    if event.class.name == GenerateMapEvent.name then
        if event:get_map_type() == MapType.mushroom_forest then
            math.randomseed(os.time())

            for x, y, cell in self.world_map:iterate() do
                if math.random(100) <= 19 then
                    self.world_map:set_cell(x, y, Mushroom())
                end
            end
        end

        while true do
            local pos_x, pos_y = math.random(self.map_size_x), math.random(self.map_size_y)

            if self.world_map:get_cell(pos_x, pos_y):get_name() == cells.ground then
                self.world_map:get_cell(pos_x, pos_y):set_character(self.hero)

                break
            end
        end
    elseif event.class.name == SolveFovEvent.name then
        self:reset_visible()

        local is_transparent = function (x, y)
            if self.world_map:is_valid(x, y) then
                return self.world_map:get_cell(x, y):is_transparent()
            end
        end

        local on_visible = function (x, y)
            if self.world_map:is_valid(x, y) then
                if self.world_map:get_cell(x, y):is_obscured() then
                    self.world_map:get_cell(x, y):illuminate()
                end

                self.world_map:get_cell(x, y):set_visible(true)
            end
        end

        local hero_x, hero_y = self:get_hero_position()

        FOV(hero_x, hero_y, 8, is_transparent, on_visible)
    end
end

function Map:get_hero_position()
    for x, y, cell in self.world_map:iterate() do
        if cell:get_character() == self.hero then
            return x, y
        end
    end
end

function Map:get_characters()
    return self.characters
end

function Map:get_size()
    return self.map_size_x, self.map_size_y
end

function Map:can_move(x, y)
    return not self.world_map:get_cell(x, y):is_move_blocked()
end

function Map:move_cahracter(x0, y0, x1, y1)
    local character = self.world_map:get_cell(x0, y0):remove_character()
    self.world_map:get_cell(x1, y1):set_character(character)
end

function Map:reset_visible()
    for x, y, cell in self.world_map:iterate() do
        self.world_map:get_cell(x, y):set_visible(false)
    end
end

return Map
