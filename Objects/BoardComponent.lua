--[[

 __  __                 _                 _  _  _  _ 
|  \/  | __ _  _ _  ___| |_   _ __   ___ | || || || |
| |\/| |/ _` || '_|(_-/|   \ | '  \ / -_)| || | \_. |
|_|  |_|\__/_||_|  /__/|_||_||_|_|_|\___||_||_| |__/ 

Made by Marshmelly. All Rights Reserved.
Contact me at Marshmelly#0001 if any issues arise.

]]
--Imports
local RS = game:GetService("ReplicatedStorage")
local HTTPS = game:GetService("HttpService")

--Config
local config = require(game:GetService("ServerStorage").TrelloSettings)

local Board = {}
local PrivateBoard = {}
PrivateBoard.__index = PrivateBoard
PrivateBoard.__metatable = "LOCKED"
PrivateBoard.__newindex = function(_,_,_)
    error("LOCKED")
end

local privateObjList = {}

--[[
    GET
    
    /1/boards/[ID]?key=[KEY]&token=[token] w/ MetaData
]]

function Board.New(id: string)
    local self = {}
    local private = {}

    local res, err = pcall(function()
        local linkToUse = config["LINK_TO_USE"].. "boards/"..id.."?key=" .. config["API_KEY"] .. "&token=" .. config["API_TOKEN"]
        if HTTPS:GetAsync(linkToUse) then
            return true
        else
            return false
        end
    end)

    if res then
        private.Link = config["LINK_TO_USE"]
        private.LINK_TO_USE = config["LINK_TO_USE"].. "boards/"
        private.ID = id
        private.API_KEY = config["API_KEY"]
        private.API_TOKEN = config["API_TOKEN"]
    else
        return nil
    end

    privateObjList[self] = private
    return setmetatable(self, PrivateBoard)
end 

--[[
    POST

    /1/boards/
]]
function Board:CreateBoard(data:table)
    if not data then return false end
    if not data["Name"] or not data["Desc"] then return false end

    local private = privateObjList[self]
    
    local DataToSend = {
        ["Name"]= data["Name"] or nil, 
        ["Description"] = data["Desc"] or nil,
    }

    local MetaData = HTTPS:JSONEncode({name = DataToSend.Name, desc = DataToSend.Description})
    
    local res, err = pcall(function()
		HTTPS:PostAsync(private.LINK_TO_USE.."?key=" .. private.API_KEY .. "&token=" .. private.API_TOKEN, MetaData)
	end)

    if err then return false end
    return true
end

--[[
    GET
    
    /1/boards/[ID]/lists?key=[KEY]&token=[token] w/ MetaData
]]
function PrivateBoard:GetAllLists()
    local private = privateObjList[self]
    local response = HTTPS:JSONDecode(HTTPS:GetAsync(private.LINK_TO_USE ..private.ID.."/lists".. "?key=" .. private.API_KEY .. "&token=" .. private.API_TOKEN))
    
    return response or false
end

return Board