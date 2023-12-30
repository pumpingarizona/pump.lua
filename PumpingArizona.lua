script_name('Pumping Arizona')
script_version('1')

require 'lib.moonloader'
local dlstatus = require('moonloader').download_status
local inicfg = require("inicfg")
local sampev = require('lib.samp.events')
local Telegram = require('dolbogram')

ini_name = "PumpingArizona.ini"

local ini = inicfg.load({
    telegram_bot = {
        token = 'token',
        secret = 'pumping',
        user = 'id'
    },
    account = {
        password = '123123123'
    }
})

function save()
    inicfg.save(ini, ini_name)
end

function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60

    local formattedTime = string.format("%02d часов %02d минут %02d секунд", hours, minutes, remainingSeconds)
    return formattedTime
end

function DisplayMessage(text) sampAddChatMessage('{848482}[' .. thisScript().name .. ']{FFFFFF} '.. text, -1) end

local bot = Telegram(ini.telegram_bot.token)

function SendToTelegram(data) 
    bot:sendMessage{chat_id = ini.telegram_bot.user, text = data}
end

bot:connect()
bot:on('ready', function(data)
    DisplayMessage('Телеграм-Бот успешно запущен!')
end)

bot:on('message', function(message)
    user_id = message.from.id
    if user_id == ini.telegram_bot.user then
        text = message.text
        if text == '/start' then
            SendToTelegram(user_id, 'Привет! Чтобы узнать список команд, напиши /help')
        elseif text == '/help' then
            local emo = '%f0%9f%92%a0 '
            local help_text = "%f0%9f%93%9d | Список доступных Вам команд:\n\n"
            help_text = help_text .. emo .. "/help – показать список команд\n"
            help_text = help_text .. emo .. "/check – проверить бота на доступность\n"
            help_text = help_text .. emo .. "/server – вывести статистику сервера\n"
            help_text = help_text .. emo .. "/online – вывести онлайн бота\n"
            help_text = help_text .. emo .. "/ac [request] – отправить запрос\n"
            help_text = help_text .. emo .. "/q – покинуть игру\n"
        elseif text == '/check' then
            SendToTelegram('Бот доступен!')
        elseif text == '/server' then
            local server_stats = "%F0%9F%93%8A Название сервера: "..sampGetCurrentServerName().."\n"
            server_stats = server_stats.. "%F0%9F%93%AB Адрес сервера: "..sampGetCurrentServerAddress().."\n"
            server_stats = server_stats.. "%F0%9F%8C%B8 Онлайн сервера: "..sampGetPlayerCount(false).."\n"
            server_stats = server_stats.. "%F0%9F%93%B6 Пинг: "..sampGetPlayerPing(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))).."\n"
            SendToTelegram(server_stats)
        elseif text == '/online' then
            local seconds = os.time() - startTime
            local formattedTime = formatTime(seconds)
            local online_text = "%F0%9F%95%90 Бот в онлайне: " ..formattedTime
            SendToTelegram(online_text)
        end
    else
        bot:sendMessage{chat_id = user_id, text = 'Вы не прописаны в боте!'}
    end
end)

local enable_autoupdate = true
function AutoUpdate()
    if enable_autoupdate then
        local e = os.tmpname()
        downloadUrlToFile("https://raw.githubusercontent.com/pumpingarizona/pump.lua/main/version.json", e, function (id, status, p1, p2)
            if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                VersionFile = io.open(e, "r")
                if VersionFile then
                    local InformationAboutUpdate = decodeJson(VersionFile:read())
                    VersionFile:close()
                    os.remove(e)

                    if tonumber(InformationAboutUpdate["version"]) > tonumber(thisScript().version) then
                        DisplayMessage("Обнаружено обновление! Пробуем загрузить.")

                        DownloadUpdateFile(InformationAboutUpdate["url"], InformationAboutUpdate["update_release_date"])
                    end
                end
            end
        end)
    end
end

function DownloadUpdateFile(url, date)
    DisplayMessage("Устанавливаем обновление за " .. date)

    lua_thread.create(function()
        wait(500)
        downloadUrlToFile(url, thisScript().path, function (id, status, p1, p2)
            DisplayMessage("Обновление установлено! Перезагружаемся..")
            thisScript():reload()
        end)
    end)
end

function main()
    while not isSampAvailable() do wait(0) end
    AutoUpdate()

    DisplayMessage('Started! Version: '.. thisScript().version)
    DisplayMessage('Если телеграм-бот не запустился, проверьте телеграм-токен.')

    startTime = os.time()

    sampRegisterChatCommand('pump', function(token)
        if token then
            DisplayMessage('Установлен новый токен для телеграм-бота!')
            ini.telegram_bot.token = token
            save()
        else
            DisplayMessage('Используйте {708090}/pump [токен бота]{FFFFFF}!')
        end
    end)

    wait(-1)
end
