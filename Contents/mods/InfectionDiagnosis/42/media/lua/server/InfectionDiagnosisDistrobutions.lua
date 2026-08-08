require "Items/ProceduralDistributions"

local ITEM_NAME = "InfectionDiagnosis.BlankSlide"

local TARGET_LISTS = {
    TestingLab         = 15,
    ScienceMisc        = 6,
    Chemistry = 9,

}

local function addBlankSlideToLoot()
    local lists = ProceduralDistributions.list
    if not lists then return end

    for listName, chance in pairs(TARGET_LISTS) do
        local distribution = lists[listName]
        if distribution and distribution.items then
            table.insert(distribution.items, ITEM_NAME)
            table.insert(distribution.items, chance)
        end
    end
end

Events.OnPreDistributionMerge.Add(addBlankSlideToLoot)
