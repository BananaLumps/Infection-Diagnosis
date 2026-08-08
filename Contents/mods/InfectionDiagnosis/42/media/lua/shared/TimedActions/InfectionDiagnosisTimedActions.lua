require "TimedActions/ISBaseTimedAction"

local ISInspectSampleAction = ISBaseTimedAction:derive("InfectionDiagnosis_InspectSampleAction")

function ISInspectSampleAction:isValid()
    return self.character ~= nil
        and InfectionDiagnosisShared.hasUninspectedSample(self.character)
end

function ISInspectSampleAction:update()
    self.character:faceThisObject(self.object)
end

function ISInspectSampleAction:start()
    self:setActionAnim("Loot") 
    self.character:reportEvent("EventInspectSample")
end

function ISInspectSampleAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISInspectSampleAction:perform()
    InfectionDiagnosisShared.inspectNextSample(self.character)
    ISBaseTimedAction.perform(self)
end

function ISInspectSampleAction:new(character, object, time)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.object = object
    o.stopOnWalk = false
    o.stopOnRun = true
    o.maxTime = time or 5 * 60
    return o
end

-- REQUIRED as of B42.13: store globally under a prefixed key so
-- require() and multiplayer sync can both find the class.
_G[ISInspectSampleAction.Type] = ISInspectSampleAction

return ISInspectSampleAction