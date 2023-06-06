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

local List = {}
local PrivateList = {}
PrivateList.__index = PrivateList
PrivateList.__metatable = "LOCKED"
PrivateList.__newindex = function(_,_,_)
    error("LOCKED")
end

local privateObjList = {}

function List.New(id: string)
    local self = {}
    local private = {}

    local link = config["LINK_TO_USE"]

    private.Link = link
    private.LINK_FOR_RETRIEVAL = link.. "lists/"..id
    private.API_KEY = config["API_KEY"]
    private.API_TOKEN = config["API_TOKEN"]
    private.LIST_ID = id

    privateObjList[self] = private
    return setmetatable(self, PrivateList)
end 

--[[
    POST
    
    /1/cards?key=[KEY]&token=[token] w/ MetaData
]]

function PrivateList:CreateCardForList(data)
    if not data then return false end
    local private = privateObjList[self]
    
    local DataToSend = {
        ["Name"]= data["Name"] or nil, 
        ["Description"] = data["Desc"] or nil,
        ["Labels"] = data["Labels"] or nil,
    }

    local MetaData = HTTPS:JSONEncode({name = DataToSend.Name, desc = DataToSend.Description, idLabels = DataToSend.Labels, idList = private.LIST_ID})
    
    local res, err = pcall(function()
		HTTPS:PostAsync(private.Link.."cards".."?key=" .. private.API_KEY .. "&token=" .. private.API_TOKEN, MetaData)
	end)

    if err then return false end
    return true
end

--[[
    GET

    /1/lists/{id}/cards?key=[KEY]&token=[token]
]]
function PrivateList:GetAllCards()
    local private = privateObjList[self]
    local response = HTTPS:JSONDecode(HTTPS:GetAsync(private.LINK_FOR_RETRIEVAL.."?key=" .. private.API_KEY .. "&token=" .. private.API_TOKEN))
 
    return response or false
end 

return List