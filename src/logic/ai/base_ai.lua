local class = require "middleclass"

local FSM = require "fsm"


local BaseAI = class("BaseAI")

function BaseAI:initialize(data)
    self.path = nil
    self.fsm = FSM(self)
    self.states = {}
end

function BaseAI:get_fsm()
    return self.fsm
end

function BaseAI:set_path(path)
    self.path = path
end

function BaseAI:get_path()
    return self.path
end

function BaseAI:get_states()
    return self.states
end

return BaseAI
