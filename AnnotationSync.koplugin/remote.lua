local json = require("json")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local T = require("ffi/util").template
local SyncService = require("apps/cloudstorage/syncservice")
local _ = require("gettext")

local annotations = require("annotations")

local M = {}

function M.sync_annotations(widget, json_path)
    local server_json = G_reader_settings:readSetting("cloud_server_object")
    if server_json and server_json ~= "" then
        local server = json.decode(server_json)
        SyncService.sync(server, json_path, function(local_file, cached_file, income_file)
            return annotations.sync_callback(widget, local_file, cached_file, income_file)
        end, false)
    else
        UIManager:show(InfoMessage:new {
            text = T(_("设置中未配置云存储目标。")),
            timeout = 4
        })
    end
end

function M.save_server_settings(server)
    G_reader_settings:saveSetting("cloud_server_object", json.encode(server))
    G_reader_settings:saveSetting("cloud_download_dir", server.url)
    if server.type then
        G_reader_settings:saveSetting("cloud_provider_type", server.type)
    end
    UIManager:show(InfoMessage:new {
        text = T(_("云存储目标已设置为：\n%1\n提供商：%2\n请重启 KOReader 使更改生效。"),
            server.url, server.type or "unknown"),
        timeout = 4
    })
    UIManager:close()
end

return M
