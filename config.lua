-- config.lua
-- Teleport-To-Waypoint (sfx_ttwp) configuration

Config = {}

-- Cooldown in milliseconds between teleports
Config.CooldownTime = 5000

-- If true, teleports the whole vehicle when the player is the driver; otherwise only the ped
Config.TeleportVehicleIfDriver = true

-- Maximum Z height to start probing for ground if no safe coord is found
Config.MaxProbeHeight = 1200.0

-- If the landing spot is over water, raise the destination to this height and give a parachute
Config.ParachuteHeightOverWater = 400.0

-- Keymapping (optional). Players can bind a key to the "sfx_ttwp:tpw" command
Config.RegisterKeyMapping = true   -- allows users to bind via FiveM key binds menu

-- Optional permission gate (ACE). If empty, no check.
-- Add an ACE in server.cfg, e.g.:
-- add_ace group.admin sfx.ttwp allow
-- add_principal identifier.steam:110000112345678 group.admin
Config.RequiredAce = "" -- e.g. "sfx.ttwp"

-- Optional job check (ESX/QBCore). Leave false to skip (this is a standalone script).
Config.RequireFrameworkJob = false
Config.AllowedJobs = { "police", "ambulance", "admin" } -- only used if RequireFrameworkJob=true

-- Command names
Config.Commands = { "tpw", "tpm" } -- both /tpw and /tpm will work

-- Enable chat suggestions (requires chat resource)
Config.ChatSuggestions = true
