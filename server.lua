-- server.lua (sfx_ttwp)
-- Lightweight server bridge for notifications + optional ACE permission check.

local ResourceName = GetCurrentResourceName()

RegisterNetEvent("sfx_ttwp:notify")
AddEventHandler("sfx_ttwp:notify", function(message)
    local src = source
    if type(message) ~= "string" or message == "" then return end
    -- Prefer chat:addMessage if available
    TriggerClientEvent("chat:addMessage", src, { args = { "^5TTWP", message } })
end)

-- Optional ACE permission check called by clients
RegisterNetEvent("sfx_ttwp:hasAce")
AddEventHandler("sfx_ttwp:hasAce", function(aceName)
    local src = source
    local allowed = false
    if type(aceName) == "string" and aceName ~= "" then
        -- IsPlayerAceAllowed returns boolean
        allowed = IsPlayerAceAllowed(src, aceName)
    else
        allowed = true -- no ace configured means allowed
    end
    TriggerClientEvent("sfx_ttwp:aceResult", src, allowed)
end)
