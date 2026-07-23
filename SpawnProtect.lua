-- Settings
local ttu = 0.5 -- time to update
--

local GameObject = CS.UnityEngine.GameObject
local Vector3 = CS.UnityEngine.Vector3

---@class SpawnProtect:CS.Akequ.Base.Room
SpawnProtect = {}

SpawnProtect.ttu = ttu
SpawnProtect.players = {}

function SpawnProtect:Init()
    if self.main.netEvent.isServer then
        local time = CS.Config.GetInt("spawn_protect_time", 3)
        
        CS.HookManager.Add(self.main.netEvent.gameObject, "onPlayerSetClass", function(obj)
            local player = obj[0]
            if player == nil then return end
            if player.playerClass == nil then return end
            if player.godMode then return end

            player.godMode = true
            self.players[player] = time
        end)
    end
end

function SpawnProtect:Update()
    self.ttu = self.ttu - CS.UnityEngine.Time.deltaTime
    if self.ttu <= 0 then
        self.ttu = ttu
        self:PluginUpdate()
    end
end

-- SERVER
function SpawnProtect:PluginUpdate()
    for player, time in pairs(self.players) do
        if player == nil then 
            self.players[player] = nil
            goto continue
        end
        
        if time <= 0 then
            self.players[player] = nil
            player.godMode = false
        else
            time = time - ttu
            self.players[player] = time
        end

        ::continue::
    end
end


return SpawnProtect