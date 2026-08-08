local InfectionDiagnosisShared = {}

local SAMPLE_ITEM_TYPES = {
    ["InfectionDiagnosis.BloodSampleSlide"] = true,
    ["BloodSampleSlide"] = true,
}

local function getFormattedGameTime()
    local gt = getGameTime()
    local months = {
        [0] = "Jan",
        [1] = "Feb",
        [2] = "Mar",
        [3] = "Apr",
        [4] = "May",
        [5] = "Jun",
        [6] = "Jul",
        [7] = "Aug",
        [8] = "Sep",
        [9] = "Oct",
        [10] = "Nov",
        [11] = "Dec"
    }
    local day = gt:getDay() + 1
    local monthStr = months[gt:getMonth()] or "Jan"
    local hour = string.format("%02d", gt:getHour())
    local minute = string.format("%02d", gt:getMinutes())
    return day .. " " .. monthStr .. " " .. hour .. ":" .. minute
end

function InfectionDiagnosisShared.isSampleItem(item)
    if not item or not item.getType then
        return false
    end
    local ok, itemType = pcall(item.getType, item)
    return ok and itemType ~= nil and SAMPLE_ITEM_TYPES[itemType] == true
end

function InfectionDiagnosisShared.OnCreateBloodSample(craftRecipeData, player)
    if not craftRecipeData or not player then
        return
    end

    local createdItems = craftRecipeData:getAllCreatedItems()
    local result = createdItems and createdItems:get(0)
    if not result then
        return
    end

    local modData = result:getModData()
    if not modData then
        return
    end

    local bodyDamage  = player:getBodyDamage()
    modData.Infected  = bodyDamage ~= nil and bodyDamage:isInfected() or false
    modData.Collector = player:getDisplayName() or "Unknown"
    modData.Time      = getFormattedGameTime()
    result:syncItemFields()

end

function InfectionDiagnosisShared.hasInventorySample(player)
    if not player then
        return false
    end
    local inventory = player:getInventory()
    if not inventory then
        return false
    end
    return inventory:getFirstTypeRecurse("BloodSampleSlide") ~= nil
        or inventory:getFirstTypeRecurse("InfectionDiagnosis.BloodSampleSlide") ~= nil
end

local function findSample(container, callback)
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if InfectionDiagnosisShared.isSampleItem(item) then
            local found = callback(item)
            if found ~= nil then
                return found
            end
        end
    end
    return nil
end

local function isUninspected(item)
    local modData = item:getModData()
    return not modData or modData.Inspected ~= true
end

function InfectionDiagnosisShared.hasUninspectedSample(player)
    if not player then
        return false
    end
    local inventory = player:getInventory()
    if not inventory then
        return false
    end

    return findSample(inventory, function(item)
        return isUninspected(item) or nil
    end) == true
end

function InfectionDiagnosisShared.inspectNextSample(player)
    if not player then
        return nil
    end
    local inventory = player:getInventory()
    if not inventory then
        return nil
    end

    local sample = findSample(inventory, function(item)
        if isUninspected(item) then
            return item
        end
        return nil
    end)
    if not sample then
        return nil
    end

    local modData     = sample:getModData()
    modData.Inspected = true
    modData.Collector = modData.Collector or (player:getDisplayName() or "Unknown")
    modData.Time      = modData.Time or "1 Jan 12:00"
    return sample
end

_G.InfectionDiagnosisShared = InfectionDiagnosisShared

return InfectionDiagnosisShared
