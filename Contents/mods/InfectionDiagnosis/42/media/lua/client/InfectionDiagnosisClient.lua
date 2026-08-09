
require "TimedActions/ISWalkToTimedAction"
require "TimedActions/InfectionDiagnosisTimedActions"
require "InfectionDiagnosisShared"

local InfectionDiagnosisClient = {}
local MICROSCOPE_SPRITES = {
    ["location_community_medical_01_136"] = true,
    ["location_community_medical_01_137"] = true,
    ["location_community_medical_01_138"] = true,
    ["location_community_medical_01_139"] = true,
}
local function isMicroscope(worldObject)
    if not worldObject then
        return false
    end

    local sprite = worldObject.getSprite and worldObject:getSprite()
    if not sprite then
        return false
    end

    local ok, spriteName = pcall(sprite.getName, sprite)
    if not ok or not spriteName then
        return false
    end

    return MICROSCOPE_SPRITES[spriteName] == true
end
local function containsMicroscope(square)
    if not square then
        return false
    end

    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        if isMicroscope(objects:get(i)) then
            return true
        end
    end
    return false
end
local function findMicroscope(square)
    if not square then
        return nil
    end

    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        if isMicroscope(obj) then
            return obj
        end
    end
    return nil
end
local function onInspectSample(worldObjects, playerObj)
    local anyObject = worldObjects and worldObjects[1]
    if not anyObject then return end

    local square = anyObject:getSquare()
    local microscope = findMicroscope(square)
    if not microscope then return end
    if not luautils.walkAdj(playerObj, microscope:getSquare(), true) then
        return
    end
    ISTimedActionQueue.add(InfectionDiagnosis_InspectSampleAction:new(playerObj, microscope, 5 * 60))
end
function InfectionDiagnosisClient.onFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if not worldObjects or (#worldObjects < 1) then
        return
    end

    local obj = worldObjects[1]
    if not obj then return end

    local clickedSquare = obj:getSquare()
    if not clickedSquare then return end

    if not InfectionDiagnosisShared.hasInventorySample(getSpecificPlayer(playerNum)) then
        return
    end
    if not containsMicroscope(clickedSquare) then
        return
    end

    local option = context:addOption(getText("ContextMenu_InfectionDiagnosis.InspectSample"), worldObjects, onInspectSample, getSpecificPlayer(playerNum))
    if option and not InfectionDiagnosisShared.hasUninspectedSample(getSpecificPlayer(playerNum)) then
        option.notAvailable = true
         local toolTip = ISWorldObjectContextMenu.addToolTip()
        toolTip.description = getText("ContextMenu_InfectionDiagnosis.NoSamples")
        option.toolTip = toolTip
    end
end
Events.OnFillWorldObjectContextMenu.Add(InfectionDiagnosisClient.onFillWorldObjectContextMenu)

return InfectionDiagnosisClient
