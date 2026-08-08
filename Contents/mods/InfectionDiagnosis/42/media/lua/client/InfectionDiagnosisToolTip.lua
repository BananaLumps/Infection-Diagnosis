
require "InfectionDiagnosisShared"
require "ISUI/ISToolTipInv"

local original_render = ISToolTipInv.render

function ISToolTipInv:render()
        original_render(self)
    local extraLines = {}
    if InfectionDiagnosisShared.isSampleItem(self.item) then
        local modData = self.item:getModData()
                table.insert(extraLines, getText("Print_Text_InfectionDiagnosis.Collector") .. tostring(modData.Collector).. "; " .. getText("Print_Text_InfectionDiagnosis.Taken") .. tostring(modData.Time))
---             table.insert(extraLines, getText("Print_Text_InfectionDiagnosis.Taken") .. tostring(modData.Time))
            if modData.Inspected == true then
             table.insert(extraLines, getText("Print_Text_InfectionDiagnosis.Infected").. (modData.Infected and getText("Print_Text_InfectionDiagnosis.Yes") or getText("Print_Text_InfectionDiagnosis.No")))
                end
        end
if #extraLines == 0 then return end

    local extraHeight = #extraLines * 18 + 4
    local oldHeight = self.height
    self.height = oldHeight + extraHeight

    -- repaint background over the newly added strip (overlap a couple px
    -- to cover the old bottom border line), then redraw the full border
    local bg = self.backgroundColor or {r=0, g=0, b=0, a=0.9}
    local bd = self.borderColor or {r=0.4, g=0.4, b=0.4, a=1}

    self:drawRect(0, oldHeight - 2, self.width, extraHeight + 2, bg.a, bg.r, bg.g, bg.b)
    self:drawRectBorder(0, 0, self.width, self.height, bd.a, bd.r, bd.g, bd.b)

    local y = oldHeight + 2
    for _, line in ipairs(extraLines) do
        self:drawText(line, 10, y, 1, 1, 1, 1)
        y = y + 18
    end
end
