-- // CONFIG
local BROOKHAVEN_PLACEID = 4924922222

-- mapa
local brookhavenMobileUrl = "https://api.junkie-development.de/api/v1/luascripts/public/70fb06e810cb70718fb699ace6f8153868e8ac9f2f8bb4c5fc9fe54511f57d08/download"


-- WEBHOOK
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1449083334633459863/HLqMTR8Ez8GCNS0pPt3QkOHePvi251OUO_EZAvZYl2CSGVcVMo34gzVhc82sSV3ES8J7"

------------------------------------------------------
-- HORA ATUAL (HH:MM)
------------------------------------------------------
local function getTime()
    local t = os.date("*t")
    return string.format("%02d:%02d", t.hour, t.min)
end


------------------------------------------------------
-- DETECTAR EXECUTOR REAL
------------------------------------------------------
local function detectExecutor()
    if type(identifyexecutor) == "function" then
        local ok, ret = pcall(identifyexecutor)
        if ok and ret then return tostring(ret) end
    end
    return "Desconhecido"
end


------------------------------------------------------
-- ENVIAR WEBHOOK
------------------------------------------------------
local function sendWebhook()
    task.spawn(function()
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local MarketplaceService = game:GetService("MarketplaceService")

        local jobId = tostring(game.JobId or "Desconhecido")
        local placeId = tostring(game.PlaceId or "Desconhecido")
        local playerName = "Desconhecido"

        local okPlayer, lp = pcall(function() return Players.LocalPlayer end)
        if okPlayer and lp and lp.Name then
            playerName = lp.Name
        end

        local executor = detectExecutor()

        local gameName = "Desconhecido"
        pcall(function()
            local info = MarketplaceService:GetProductInfo(tonumber(game.PlaceId) or game.PlaceId)
            if info and info.Name then
                gameName = info.Name
            end
        end)

        local joinScript = ("game:GetService('TeleportService'):TeleportToPlaceInstance(%s, '%s', game.Players.LocalPlayer)"):format(placeId, jobId)

        local data = {
            content = "**Novo usuário executou o NIGHT CLIENT CARALHO!**",
            embeds = {{
                title = "Execução Detectada",
                color = 6488063,
                fields = {
                    { name = "Jogador", value = tostring(playerName), inline = true },
                    { name = "Executor Detectado", value = tostring(executor), inline = true },
                    { name = "Mapa", value = tostring(gameName), inline = true },
                    { name = "Horário da Execução", value = getTime(), inline = true },
                    { name = "Job ID", value = "```\n"..tostring(jobId).."\n```", inline = false },
                    { name = "Entrar no mesmo servidor", value = "```lua\n"..joinScript.."\n```", inline = false }
                }
            }}
        }

        local body = HttpService:JSONEncode(data)

        local req = http_request or request
        if not req and syn and syn.request then req = syn.request end
        if not req and fluxus and fluxus.request then req = fluxus.request end
        if not req and http and http.request then req = http.request end
        if not req then return end

        pcall(function()
            req({
                Url = DISCORD_WEBHOOK,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
    end)
end

sendWebhook()


------------------------------------------------------
-- FAST LOAD
------------------------------------------------------
local function fastLoad(url)
    local ok, response = pcall(function()
        if type(game.HttpGet) == "function" then
            return game:HttpGet(url)
        elseif http and http.get then
            return http.get(url)
        elseif (syn and syn.request) or (fluxus and fluxus.request) then
            local r = (syn and syn.request) or (fluxus and fluxus.request)
            local res = r({ Url = url, Method = "GET" })
            return (res and (res.Body or res.body)) or nil
        else
            return nil
        end
    end)

    if ok and response and response ~= "" then
        pcall(function()
            local fn, err = loadstring(response)
            if fn then fn() end
        end)
    end
end


------------------------------------------------------
-- DETECÇÃO DO JOGO
------------------------------------------------------
local id = game.PlaceId

if id == BROOKHAVEN_PLACEID then
    fastLoad(brookhavenMobileUrl)

elseif id == CARDEALER_PLACEID then
    fastLoad(cardealerUrl)

elseif id == STEAL_PLACEID_MAIN or id == STEAL_PLACEID_NEW then
    fastLoad(stealUrl)

else
    fastLoad(universalUrl)
end