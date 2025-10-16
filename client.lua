-- client.lua (sfx_ttwp)
-- Teleport To Waypoint (TPW/TpM) with robust safety checks, cooldowns, and vehicle support.
-- Standalone (no ESX/QBCore required).

local lastTeleport = 0
local cachedAceAllowed = nil

-- Utilities
local function notify(msg)
    if not msg or msg == "" then return end
    TriggerServerEvent("sfx_ttwp:notify", msg)
end

local function ensureCollisionAt(x, y, z, timeoutMs)
    local ped = PlayerPedId()
    local timeout = GetGameTimer() + (timeoutMs or 5000)
    RequestCollisionAtCoord(x, y, z)
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
        RequestCollisionAtCoord(x, y, z)
        Wait(0)
    end
end

local function getWaypointBlip()
    local blipIterator = GetBlipInfoIdIterator()
    local blip = GetFirstBlipInfoId(8) -- 8 = waypoint
    return blip
end

local function findSafeCoord(x, y)
    -- First try native safe coord
    local found, safeZ = GetGroundZFor_3dCoord(x, y, 1000.0, false)
    local z = safeZ and (safeZ + 1.0) or 1000.0

    -- If failed, probe downwards
    if not found then
        for probe = Config.MaxProbeHeight, -50.0, -10.0 do
            local fnd, gz = GetGroundZFor_3dCoord(x, y, probe, false)
            if fnd then
                found = true
                z = gz + 1.0
                break
            end
            Wait(0)
        end
    end

    -- If still not found, check water and prepare parachute
    if not found then
        if TestProbeAgainstWater(x, y, 0.0) then
            z = Config.ParachuteHeightOverWater
            return true, x, y, z, true -- parachute case
        else
            -- default to high altitude with parachute anyway
            z = Config.ParachuteHeightOverWater
            return true, x, y, z, true
        end
    end

    return true, x, y, z, false
end

local function isDriverOfVehicle(ped, veh)
    return GetPedInVehicleSeat(veh, -1) == ped
end

local function hasCooldown()
    local now = GetGameTimer()
    return (now - lastTeleport) < Config.CooldownTime
end

local function frameworkJobAllowed()
    if not Config.RequireFrameworkJob then return true end
    -- Placeholder: user requested standalone; return true unless integrated manually.
    return true
end

local function checkAcePermission(cb)
    if cachedAceAllowed ~= nil then
        cb(cachedAceAllowed)
        return
    end
    if not Config.RequiredAce or Config.RequiredAce == "" then
        cachedAceAllowed = true
        cb(true)
        return
    end
    RegisterNetEvent("sfx_ttwp:aceResult")
    AddEventHandler("sfx_ttwp:aceResult", function(allowed)
        cachedAceAllowed = allowed and true or false
        cb(cachedAceAllowed)
    end)
    TriggerServerEvent("sfx_ttwp:hasAce", Config.RequiredAce)
end

local function doTeleport()
    if hasCooldown() then
        notify(("Cooldown active: wait %.1fs."):format((Config.CooldownTime - (GetGameTimer() - lastTeleport))/1000.0))
        return
    end
    if not frameworkJobAllowed() then
        notify("You are not allowed to use this command.")
        return
    end

    local wp = getWaypointBlip()
    if wp == 0 then
        notify("No waypoint set.")
        return
    end

    -- Get waypoint coords
    local x = GetBlipInfoIdCoord(wp).x
    local y = GetBlipInfoIdCoord(wp).y

    local ok, tx, ty, tz, parachute = findSafeCoord(x, y)
    if not ok then
        notify("Failed to find a safe landing spot.")
        return
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local teleportVehicle = false

    if veh ~= 0 and DoesEntityExist(veh) and Config.TeleportVehicleIfDriver and isDriverOfVehicle(ped, veh) then
        teleportVehicle = true
    end

    DoScreenFadeOut(350)
    while not IsScreenFadedOut() do Wait(0) end

    -- Give parachute if needed
    if parachute then
        GiveWeaponToPed(ped, `GADGET_PARACHUTE`, 1, false, true)
        SetPedParachuteTintIndex(ped, 5)
    end

    -- Teleport
    if teleportVehicle then
        SetEntityCoordsNoOffset(veh, tx, ty, tz, false, false, false)
        SetEntityHeading(veh, GetEntityHeading(veh))
        ensureCollisionAt(tx, ty, tz, 5000)
        SetGameplayCamRelativePitch(0.0, 1.0)
    else
        SetEntityCoordsNoOffset(ped, tx, ty, tz, false, false, false)
        ensureCollisionAt(tx, ty, tz, 5000)
        ClearPedTasksImmediately(ped)
    end

    lastTeleport = GetGameTimer()
    DoScreenFadeIn(350)
    notify("Teleported to waypoint.")
end

local function handleCommand()
    checkAcePermission(function(allowed)
        if not allowed then
            notify("You are not permitted to use /tpw.")
            return
        end
        doTeleport()
    end)
end

-- Register commands
for _, name in ipairs(Config.Commands) do
    RegisterCommand(name, handleCommand, false)
    if Config.ChatSuggestions then
        TriggerEvent('chat:addSuggestion', '/'..name, 'Teleport to your map waypoint', {})
    end
end

-- Optional key mapping
if Config.RegisterKeyMapping then
    RegisterKeyMapping("sfx_ttwp:tpw", "Teleport to Waypoint (TTWP)", "keyboard", "F10")
    RegisterCommand("sfx_ttwp:tpw", handleCommand, false)
end

-- Resource stop safety: nothing to clean up for now, but future-proof.
AddEventHandler("onResourceStop", function(res)
    if res == GetCurrentResourceName() then
        -- no persistent state
    end
end)
