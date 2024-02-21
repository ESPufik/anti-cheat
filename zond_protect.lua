-- Защита от Fafnirov. Zond

-- Проверка, является ли игрок администратором ULX
local function IsULXAdmin(ply)
    if ULib and ply:IsUserGroup("superadmin") then
        return true
    elseif ply:IsAdmin() then -- Проверка на встроенного администратора
        return true
    end
    return false
end

-- Отключение консоли для всех, кроме администраторов
local function DisableConsole(ply, cmd, args)
    if not IsULXAdmin(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Консоль доступна только администраторам.")
        return
    end
end
concommand.Add("gm_lua", DisableConsole)
concommand.Add("lua_run", DisableConsole)
concommand.Add("lua_run_cl", DisableConsole)
concommand.Add("lua_run_server", DisableConsole)
concommand.Add("lua_open", DisableConsole)

-- Блокировка опасных функций
local function BlockExploit(ply, funcName)
    if not IsULXAdmin(ply) then
        local oldFunc = _G[funcName]
        _G[funcName] = function(...)
            ply:Kick("Попытка использования опасной функции: " .. funcName)
            -- Можно добавить дополнительные действия, например, запись в логи
        end
    end
end

local function SetupExploitProtection()
    local blockedFunctions = {
        "RunString",
        "CompileString",
        "CompileFile"
    }

    for _, funcName in ipairs(blockedFunctions) do
        BlockExploit(funcName)
    end
end
hook.Add("CheckPassword", "CheckExploits", SetupExploitProtection)

-- Защита от загрузки файлов
local function CheckResource(ply)
    if not IsULXAdmin(ply) then
        local files = {
            "ulib/modules/sh/init.lua", -- пример недоверенного файла
            "darkrp/gamemode/init.lua" -- основной файл DarkRP
        }

        for _, file in ipairs(files) do
            if file.Exists(file, "LUA") then
                ply:Kick("Загружен недопустимый файл: " .. file)
                -- Можно добавить дополнительные действия, например, запись в логи
                return
            end
        end
    end
end
hook.Add("PlayerInitialSpawn", "CheckResource", CheckResource)

hook.Add("Initialize", "ScriptInitialized", function()
    print("Zond-Fafnirov.M - работает. Я защищу твой сервер!")
end)
--Кинь эт все по lua/server. Все чики-пики. Если все заработало, то вы увидите оповещение, что он работает.