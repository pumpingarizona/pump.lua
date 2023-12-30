script_name('Pumping Arizona')
script_version('1')

require 'lib.moonloader'
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

if not doesFileExist(ini_name) then save() end

function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60

    local formattedTime = string.format("%02d ����� %02d ����� %02d ������", hours, minutes, remainingSeconds)
    return formattedTime
end

function DisplayMessage(text) sampAddChatMessage('{848482}[' .. script_name .. ']{FFFFFF} '.. text, -1) end

local bot = Telegram(ini.telegram_bot.token)

function SendToTelegram(data) 
    DisplayMessage(text)
end

bot:connect()
bot:on('ready', function(data)
    DisplayMessage('��������-��� ������� �������!')
end)

bot:on('message', function(message)
    user_id = message.from.id
    if user_id == ini.telegram_bot.user then
        text = message.text
        if text == '/start' then
            SendToTelegram(chat_id = user_id, text = '������! ����� ������ ������ ������, ������ /help')
        elseif text == '/help' then
            local emo = '%f0%9f%92%a0 '
            local help_text = "%f0%9f%93%9d | ������ ��������� ��� ������:\n\n"
            help_text = help_text .. emo .. "/help � �������� ������ ������\n"
            help_text = help_text .. emo .. "/check � ��������� ���� �� �����������\n"
            help_text = help_text .. emo .. "/server � ������� ���������� �������\n"
            help_text = help_text .. emo .. "/online � ������� ������ ����\n"
            help_text = help_text .. emo .. "/ac [request] � ��������� ������\n"
            help_text = help_text .. emo .. "/q � �������� ����\n"
        elseif text == '/check' then
            SendToTelegram('��� ��������!')
        elseif text == '/server' then
            local server_stats = "%F0%9F%93%8A �������� �������: "..sampGetCurrentServerName().."\n"
            server_stats = server_stats.. "%F0%9F%93%AB ����� �������: "..sampGetCurrentServerAddress().."\n"
            server_stats = server_stats.. "%F0%9F%8C%B8 ������ �������: "..sampGetPlayerCount(false).."\n"
            server_stats = server_stats.. "%F0%9F%93%B6 ����: "..sampGetPlayerPing(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))).."\n"
            SendToTelegram(server_stats)
        elseif text == '/online' then
            local seconds = os.time() - startTime
            local formattedTime = formatTime(seconds)
            local online_text = "%F0%9F%95%90 ��� � �������: " ..formattedTime
            SendToTelegram(online_text)
        end
    else
        bot:sendMessage{chat_id = user_id, text = '�� �� ��������� � ����!'}
    end
end)

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring,
        [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('��������� %d �� %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('�������� ���������� ���������.')sampAddChatMessage(b..'���������� ���������!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'���������� ������ ��������. �������� ���������� ������..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': ���������� �� ���������.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, ������� �� �������� �������� ����������. ��������� ��� ��������� �������������� �� '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/qrlk/wraith.lua/master/version.json?" ..
                                  tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/qrlk/wraith.lua/"
        end
    end
end

local enable_autoupdate = true
function AutoUpdate()
    if enable_autoupdate then
        local e = os.tmpname()
        downloadUrlToFile("https://raw.githubusercontent.com/pumpingarizona/pump.lua/main/version.json", e, function (id, status, p1, p2)
            VersionFile = io.open(e, "r")
            if VersionFile then
                InformationAboutUpdate = decodeJson(VersionFile:read())
                VersionFile:close()
                os.remove(e)

                if InformationAboutUpdate["version"] > thisScript().version then
                    DisplayMessage("���������� ����������! ������� ���������.")

                    DownloadUpdateFile(InformationAboutUpdate["url"], InformationAboutUpdate["update_release_date"])
                end
            end
        end)
    end
end

function DownloadUpdateFile(url, date)
    DisplayMessage("������������� ���������� �� " .. date)
    downloadUrlToFile(url, thisScript().path, function (id, status, p1, p2)
        DisplayMessage("���������� �����������! ���������������..")
        thisScript().reload()
    end)
end

function main()
    while not isSampAvailable() do wait(0) end

    DisplayMessage('Started! Version: '.. thisScript().version)
    DisplayMessage('���� ��������-��� �� ����������, ��������� ��������-�����.')

    startTime = os.time()

    sampRegisterChatCommand('pump', function(token)
        if token then
            DisplayMessage('���������� ����� ����� ��� ��������-����!')
            ini.telegram_bot.token = token
            save()
        else
            DisplayMessage('����������� {708090}/pump [����� ����]{FFFFFF}!')
        end
    end)

    wait(-1)
end