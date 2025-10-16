# sfx_ttwp — Teleport To Waypoint (Standalone)

A lightweight, standalone `/tpw` (and `/tpm`) command that teleports you safely to your map waypoint.
Includes safe-ground detection, water handling with automatic parachute, vehicle teleport (if driver),
cooldowns, optional ACE permission gate, and an optional key mapping.

## Features
- **Waypoint teleport**: `/tpw` or `/tpm` will teleport to the active map waypoint.
- **Vehicle support**: If you’re driving, your vehicle is teleported too.
- **Safe landing**: Probes for ground. If over water/void, spawns high with a parachute.
- **Cooldowns**: Prevent accidental spam (configurable).
- **ACE permission (optional)**: Gate the command behind an ACE (e.g., admins only).
- **Key mapping (optional)**: Bind `F10` (or any key in the FiveM key-binds menu) to teleport.
- **Chat suggestion (optional)**: Adds `/tpw` help text to the default chat.

## Installation
1. Drop the **`sfx_ttwp`** folder into your server’s `resources/` directory.
2. Add to your `server.cfg`:
   ```cfg
   ensure sfx_ttwp
   ```
3. (Optional) ACE permission gate:
   ```cfg
   add_ace group.admin sfx.ttwp allow
   # add_principal identifier.steam:110000112345678 group.admin
   ```
   Then set `Config.RequiredAce = "sfx.ttwp"` in `config.lua`.

## Commands
- `/tpw` — Teleport to your current waypoint.
- `/tpm` — Alias for `/tpw`.
- Keybind command: `sfx_ttwp:tpw` (bindable in GTA V → Settings → Key Bindings → FiveM).

## Configuration
Edit `config.lua`:
```lua
Config.CooldownTime = 5000                -- ms
Config.TeleportVehicleIfDriver = true     -- teleport vehicle if player is driver
Config.MaxProbeHeight = 1200.0
Config.ParachuteHeightOverWater = 400.0
Config.RegisterKeyMapping = true
Config.RequiredAce = ""                   -- set to "sfx.ttwp" to require ACE
Config.RequireFrameworkJob = false        -- standalone by default
Config.AllowedJobs = { "police", "ambulance", "admin" }
Config.Commands = { "tpw", "tpm" }
Config.ChatSuggestions = true
```

## Notes
- **Standalone**: No ESX/QBCore dependency. If you want to restrict by job, integrate your framework in `frameworkJobAllowed()`.
- **Safety**: The script tries to avoid teleporting into the void. Over water, it equips a parachute and spawns you at a safe height.
- **Performance**: No persistent loops. All logic runs only on command usage.

## Troubleshooting
- **“No waypoint set.”** — Place a waypoint on the map first.
- **Permission denied** — If using ACE, verify `add_ace`/`add_principal` lines and `Config.RequiredAce`.
- **Parachute didn’t deploy** — Make sure you didn’t remove `GADGET_PARACHUTE` from allowed weapons.
