local class = require "middleclass"

local Character = require "world.units.character"

local Cells = require "enums.cells"
local CharacterControl = require "enums.character_control"


local Zombie = class("Zombie", Character)

function Zombie:initialize(data)
    Character:initialize(self)

    self.tile = Cells.zombie
    self.control = CharacterControl.ai

    if not data.ai then
        error("Zombie:initialize no data.ai !")
    end

    if not data.hp then
        error("Zombie:initializ: no data.hp !")
    end

    if not data.view_radius then
        error("Zombie:initializ: no data.view_radius !")
    end

    if not data.damage then
        error("Zombie:initializ: no data.damage !")
    end

    if not data.speed then
        error("Zombie:initializ: no data.speed !")
    end

    self.ai = data.ai
    self.max_hp = data.hp
    self.current_hp = data.hp
    self.view_radius = data.view_radius
    self.damage = data.damage
    self.speed = data.speed
end

return Zombie
