if isClient() then return end

local function OnClientCommand(module, command, player, args)
    if module == "InfectionDiagnosis" and command == "ApplySampleDamage" then
        if not player or not args then return end
        if InfectionDiagnosisShared and InfectionDiagnosisShared.ApplyCraftingDamage then
            InfectionDiagnosisShared.ApplyCraftingDamage(player, args.bodyPart, args.damageAmount)
        end
    end
end
Events.OnClientCommand.Add(OnClientCommand)