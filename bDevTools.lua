-- =============================================================================
--  bDevTools
--    by: BurstBiscuit
-- =============================================================================

require "math"
require "table"
require "unicode"

require "lib/lib_Callback2"
require "lib/lib_ChatLib"
require "lib/lib_Debug"
require "lib/lib_InterfaceOptions"
require "lib/lib_MapMarker"
require "lib/lib_Slash"
require "lib/lib_SubTypeIds"
require "lib/lib_Vector"
require "lib/lib_Wallet"

Debug.EnableLogging(true)


-- =============================================================================
--  Variables
-- =============================================================================

local g_EntityMarkers = {}
local g_ItemDatabase = {}
local g_SearchIds = {}
local g_SubscribedEvents = {}


-- =============================================================================
--  Constants
-- =============================================================================

local c_Battleframes = {
    ["ASSAULT"] = {
        chassis = 76164,
        certifications = {732}
    },
    ["FIRECAT"] = {
        chassis = 76133,
        certifications = {733, 732}
    },
    ["TIGERCLAW"] = {
        chassis = 76132,
        certifications = {734, 732}
    },

    ["ENGINEER"] = {
        chassis = 75775,
        certifications = {735}
    },
    ["ELECTRON"] = {
        chassis = 76337,
        certifications = {736, 735}
    },
    ["BASTION"] = {
        chassis = 76338,
        certifications = {737, 735}
    },

    ["DREADNAUGHT"] = {
        chassis = 75772,
        certifications = {741}
    },
    ["MAMMOTH"] = {
        chassis = 76331,
        certifications = {742, 741}
    },
    ["RHINO"] = {
        chassis = 76332,
        certifications = {743, 741}
    },
    ["ARSENAL"] = {
        chassis = 82360,
        certifications = {748, 741}
    },

    ["BIOTECH"] = {
        chassis = 75774,
        certifications = {738}
    },
    ["DRAGONFLY"] = {
        chassis = 76335,
        certifications = {739, 738}
    },
    ["RECLUSE"] = {
        chassis = 76336,
        certifications = {740, 738}
    },

    ["RECON"] = {
        chassis = 75773,
        certifications = {744}
    },
    ["NIGHTHAWK"] = {
        chassis = 76333,
        certifications = {745, 744}
    },
    ["RAPTOR"] = {
        chassis = 76334,
        certifications = {746, 744}
    }
}

local c_Bounties = {
    -- Quick
    [870]   = "q",  -- Shepherd                     Kill 15 Chosen
    [871]   = "q",  -- Ronin                        Kill 15 Chosen without dying
    [872]   = "q",  -- Sky Diver                    Glide 500 meters
    [873]   = "q",  -- Icarus                       Glide 600 meters without touching the ground
    [874]   = "q",  -- Easy Rider                   Drive a vehicle 500 meters
    [875]   = "q",  -- Flatliner                    Revive 1 player
    [878]   = "q",  -- Party Animal                 Dance infront of 5 people at once
    [889]   = "q",  -- Accord Scout                 Complete 1 wandering encouter
    [940]   = "q",  -- [Rare] Shepherd              Kill 15 Chosen
    [942]   = "q",  -- [Rare] Ronin                 Kill 25 Chosen without dying
    [943]   = "q",  -- [Rare] Sky Diver             Glide 750 meters
    [944]   = "q",  -- [Rare] Icarus                Glide 800 meters without touching the ground
    [948]   = "q",  -- [Rare] Party Animal          Dance in front of 8 people at once
    [949]   = "q",  -- [Rare] Grizzled Veteran      Earn 100 experience without dying/re-suiting
    [958]   = "q",  -- [Rare] Accord Scout          Complete 2 wandering encounter
    [1030]  = "q",  -- Quick Killer                 Defeat 5 enemies in rapid succession
    [1031]  = "q",  -- [Rare] Quick Killer

    -- Daily
    [882]   = "d",  -- Vigilante                    Kill 50 Chosen
    [883]   = "d",  -- Immortal                     Kill 50 Chosen without dying
    [884]   = "d",  -- Daedalus                     Glide 20,000 meters
    [885]   = "d",  -- Globetrotter                 Drive a vehicle 5,000 meters
    [886]   = "d",  -- Hunter                       Defeat 100 enemies
    [887]   = "d",  -- Sentinel                     Complete 3 watchtower events
    [888]   = "d",  -- Altruist                     Complete 3 wandering encounters
    [892]   = "d",  -- Contractor                   Complete 3 ARES jobs
    [893]   = "d",  -- Supporter                    Complete 3 ARES assistance tasks
    [952]   = "d",  -- [Rare] Immortal              Kill 75 Chosen without dying
    [955]   = "d",  -- [Rare] Hunter                Defeat 150 enemies
    [957]   = "d",  -- [Rare] Altruist              Complete 4 wandering encounters
    [959]   = "d",  -- [Rare] Money Maker           Earn 500 Crystite
    [1007]  = "d",  -- Experienced Flatliner        Revive 5 players
    [1043]  = "d",  -- Team Survivor                Complete 1 Group Bounty in Bounty Squad without Medical System
    [1044]  = "d",  -- [Rare] Team Survivor         Complete 2 Group Bounties in Bounty Squad without Medical System

    -- Weekly
    [896]   = "w",  -- Ranger                       Defeat 800 enemies
    [897]   = "w",  -- Hired Gun                    Complete 12 ARES jobs
    [898]   = "w",  -- ARES Hero                    Complete 6 Core Missions
    [899]   = "w",  -- Epic Hero                    Complete 6 Epic Missions
    [970]   = "w",  -- [Rare] Breadwinner           100 Crystite earned without dying
    [1005]  = "w",  -- Team Player                  Complete 5 Group Bounties with 2 other players
    [1020]  = "w",  -- Operation Buddy              Completed 6 Operations or Missions in a group
    [1021]  = "w",  -- [Rare] Operation Buddy       Completed 6 Operations or Missions in a group
    [1041]  = "w",  -- Zone Ender                   Complete 6 zone events
    [1042]  = "w",  -- [Rare] Zone Ender            Complete 8 zone events

    -- Group
    [920]   = "g",  -- Grease Monkey
    [921]   = "g",  -- Happy Camper
    [934]   = "g",  -- Storm Chaser
    [977]   = "g",  -- [Rare] Grease Monkey         Complete 1 Crashed LGV encounter
    [982]   = "g",  -- [Rare] Confiscator           Complete 1 Bandit Cache encounter
}

local c_nilPlaceholder = math.huge --

local c_TextEmotes = {
    ["dongerbill"] = {
        text = '[̲̅$̲̅(̲̅ ͡° ͜ʖ ͡°̲̅)̲̅$̲̅]',
        description = 'Donger bill'
    },

    ["hamsterface, stupidfuckinghamsterface"] = {
        text = '(´•ω•`)',
        description = 'Stupid fucking hamster face'
    },

    ["lennyface"] = {
        text = '( ͡° ͜ʖ ͡°)',
        description = 'Le Lenny Face'
    },

    ["fliptable, tableflip"] = {
        text = '(╯°□°）╯︵ ┻━┻',
        description = 'Flip the table!'
    },

    ["happyface"] = {
        text = '•ᴗ•',
        description = 'Happy face'
    },

    ["unflip, unfliptable"] = {
        text = '┬─┬ノ( º _ ºノ)',
        description = 'Calm down'
    }
}

local c_SlashCommands = {
    -- ========================================================================
    --  EVENTS
    -- ========================================================================
    event = function(args)
        if (args[2]) then
            if (args[2] == "clear") then
                Debug.Log("======== EVENT CLEAR =============================")
                Notification("Unsubscribing from all UI events ...")

                for k, _ in pairs(g_SubscribedEvents) do
                    Debug.Log("Component.UnbindEvent()", unicode.upper(k))
                    Component.UnbindEvent(unicode.upper(k))

                    g_SubscribedEvents[unicode.upper(k)] = nil
                end

                Debug.Divider("=")
            elseif (args[2] == "list") then
                Debug.Log("======== EVENT LIST ==============================")
                Notification("The list of subscribed UI events has been printed to console")
                Debug.Table("g_SubscribedEvents", g_SubscribedEvents)
                Debug.Divider("=")
            elseif (args[2] == "bind") then
                if (args[3]) then
                    Debug.Log("======== EVENT BIND ==============================")
                    Notification("Subscribing to UI event: " .. unicode.upper(args[3]))
                    Debug.Table("Component.BindEvent()", Component.BindEvent(unicode.upper(args[3]), "OnEvent"))
                    Debug.Divider("=")

                    g_SubscribedEvents[unicode.upper(args[3])] = true
                else
                    Notification("Usage: /bdt event bind <event>")
                end
            elseif (args[2] == "unbind") then
                if (args[3]) then
                    Debug.Log("======== EVENT UNBIND ============================")
                    Notification("Unsubscribing from UI event: " .. unicode.upper(args[3]))
                    Debug.Table("Component.UnbindEvent()", Component.UnbindEvent(unicode.upper(args[3])))
                    Debug.Divider("=")

                    g_SubscribedEvents[unicode.upper(args[3])] = nil
                else
                    Notification("Usage: /bdt event unbind <event>")
                end
            else
                Notification("Usage: /bdt event <list | bind | unbind>")
            end
        else
            Notification("Usage: /bdt event <list | bind | unbind>")
        end
    end,

    -- ========================================================================
    --  ITEMS
    -- ========================================================================
    item = function(args)
        if (args[2]) then
            if (args[2] == "find") then
                if (args[3]) then
                    local searchParameters = {
                        class_certs     = nil,
                        item_subtype    = nil,
                        item_type       = nil,
                        match_string    = tostring(args[3]),
                        max_level       = nil,
                        max_quality     = nil,
                        min_level       = nil,
                        min_quality     = nil
                    }

                    for i = 4, #args do
                        if (args[i]) then
                            local parameter = unicode.match(args[i], "^[%a_]+")
                            local value     = unicode.match(args[i], "[%w_]+$")

                            if (parameter and value) then
                                if (parameter == "class_certs") then
                                    if (unicode.match(value, "^%d+") or unicode.match(value, "^%d+%:%d+$")) then
                                        local certifications = {certifications = {}}

                                        for certificate in unicode.gmatch(value, "%d+") do
                                            table.insert(certifications.certifications, tonumber(certificate))
                                        end

                                        searchParameters[parameter] = certifications

                                    elseif (c_Battleframes[unicode.upper(value)]) then
                                        searchParameters[parameter] = c_Battleframes[unicode.upper(value)]
                                    end
                                else
                                    searchParameters[parameter] = value
                                end
                            end
                        end
                    end

                    -- Generate a custom searchId
                    local characters    = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"
                    local localUnixTime = System.GetLocalUnixTime()
                    local searchId      = ""

                    for i = 1, 3 do
                        local character = math.random(1, unicode.len(characters))
                        searchId = searchId .. unicode.sub(characters, character, character)
                    end

                    searchId = searchId .. "_" .. localUnixTime

                    if (searchId) then
                        g_SearchIds[tostring(searchId)] = true
                        Callback2.FireAndForget(FindItems, {searchId = searchId, searchParameters = searchParameters}, 0.1)
                        Notification("Searching ...")
                    end

                    Debug.Log("======== ITEM FIND ===============================")
                    Debug.Table("FindItems()", searchId)
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt item find <match_string> [match_description=0 | item_subtype=0 | item_type=any | max_level=50 | max_quality=legendary | min_level=1 | min_quality=salvage]")
                end
            elseif (args[2] == "info") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== ITEM INFO ===============================")

                    if (unicode.len(args[3]) > 16) then
                        Debug.Table("Player.GetItemInfo()", Player.GetItemInfo(args[3]))
                    else
                        Debug.Table("Game.GetItemInfoByType()", Game.GetItemInfoByType(args[3]))
                    end

                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt item info <itemTypeId | itemId>")
                end
            elseif (args[2] == "link") then
                if (args[3] and unicode.match(args[3], "^%d+")) then
                    if (Game.GetItemInfoByType(unicode.match(args[3], "^%d+")).itemTypeId ~= nil) then
                        local moduleData = {
                            hiddenModules = {},
                            slottedModules = {}
                        }

                        for i = 4, #args do
                            if (args[i]) then
                                local modules = {}

                                for itemTypeId in unicode.gmatch(args[i], "%d+") do
                                    table.insert(modules, itemTypeId)
                                end

                                moduleData[unicode.match(args[i], "(%a+)%=")] = modules
                            end
                        end

                        Notification(ChatLib.EncodeItemLink(unicode.match(args[3], "^%d+"), moduleData.hiddenModules, moduleData.slottedModules))
                    else
                        Notification("Item with itemTypeId " .. unicode.match(args[3], "^%d+") .. " was not found")
                    end
                else
                    Notification("Usage: /bdt item link <itemTypeId> [hiddenModules=itemTypeId[:itemTypeId..] | slottedModules=itemTypeId[:itemTypeId..]]")
                end
            elseif (args[2] == "search") then
                if (args[3]) then
                    local searchParameters = {
                        class_certs     = nil,
                        item_subtype    = nil,
                        item_type       = nil,
                        match_string    = tostring(args[3]),
                        max_level       = nil,
                        max_quality     = nil,
                        min_level       = nil,
                        min_quality     = nil
                    }

                    for i = 4, #args do
                        if (args[i]) then
                            local parameter = unicode.match(args[i], "^[%a_]+")
                            local value     = unicode.match(args[i], "[%w_]+$")

                            if (parameter and value) then
                                if (parameter == "class_certs") then
                                    if (unicode.match(value, "^%d+") or unicode.match(value, "^%d+%:%d+$")) then
                                        local certifications = {certifications = {}}

                                        for certificate in unicode.gmatch(value, "%d+") do
                                            table.insert(certifications.certifications, tonumber(certificate))
                                        end

                                        searchParameters[parameter] = certifications

                                    elseif (c_Battleframes[unicode.upper(value)]) then
                                        searchParameters[parameter] = c_Battleframes[unicode.upper(value)]
                                    end
                                else
                                    searchParameters[parameter] = value
                                end
                            end
                        end
                    end

                    local searchId = Game.StartItemSearch(searchParameters)

                    if (searchId) then
                        g_SearchIds[tostring(searchId)] = true
                        Notification("Searching ...")
                    end

                    Debug.Log("======== ITEM SEARCH =============================")
                    Debug.Table("Game.StartItemSearch()", searchId)
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt item search <match_string> [item_subtype=0 | item_type=any | max_level=50 | max_quality=legendary | min_level=1 | min_quality=salvage]")
                end
            else
                Notification("Usage: /bdt item <find | info | link | search>")
            end
        else
            Notification("Usage: /bdt item <find | info | link | search>")
        end
    end,

    -- ========================================================================
    --  ABILITIES
    -- ========================================================================
    ability = function(args)
        if (args[2]) then
            if (args[2] == "info") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== ABILITY INFO ============================")
                    Debug.Table("Player.GetAbilityInfo()", Player.GetAbilityInfo(args[3]))
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt ability info <abilityId>")
                end
            elseif (args[2] == "state") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== ABILITY STATE ===========================")
                    Debug.Table("Player.GetAbilityState()", Player.GetAbilityState(args[3]))
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt ability state <abilityId>")
                end
            else
                Notification("Usage: /bdt ability <info | state>")
            end
        else
            Notification("Usage: /bdt ability <info | state>")
        end
    end,

    -- ========================================================================
    --  PLAYER
    -- ========================================================================
    player = function(args)
        if (args[2]) then
            if (args[2] == "loadout") then
                if (args[3]) then
                    if (args[3] == "get") then
                        Debug.Log("======== LOADOUT GET =============================")

                        if (args[4] and unicode.match(args[4], "^%d+$")) then
                            Debug.Table("Player.GetLoadoutInfoByID()", Player.GetLoadoutInfoByID(args[4]))
                        else
                            Debug.Table("Player.GetCurrentLoadout()", Player.GetCurrentLoadout())
                        end

                        Debug.Divider("=")
                    elseif (args[3] == "list") then
                        Debug.Log("======== LOADOUT LIST ============================")
                        Debug.Table("Player.GetLoadoutList()", Player.GetLoadoutList())
                        Debug.Divider("=")
                    else
                        Notification("Usage: /bdt player loadout <get|list>")
                    end
                else
                    Notification("Usage: /bdt player loadout <get|list>")
                end
            else
                Notification("Usage: /bdt player <loadout>")
            end
        else
            Notification("Usage: /bdt player <loadout>")
        end
    end,

    -- ========================================================================
    --  ZONES
    -- ========================================================================
    zone = function(args)
        if (args[2]) then
            if (args[2] == "info") then
                Debug.Log("======== ZONE INFO ===============================")

                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Table("Game.GetZoneInfo()", Game.GetZoneInfo(tonumber(args[3])))
                else
                    Debug.Table("Game.GetZoneInfo()", Game.GetZoneInfo(Game.GetZoneId()))
                end

                Debug.Divider("=")
            else
                Notification("Usage: /bdt zone <info>")
            end
        else
            Notification("/bdt zone <info>")
        end
    end,

    -- ========================================================================
    --  ARCS
    -- ========================================================================
    job = function(args)
        if (args[2]) then
            if (args[2] == "cancel") then
                Debug.Log("======== JOB CANCEL ==============================")

                local jobStatus = Player.GetJobStatus()
                if (jobStatus and jobStatus.job and jobStatus.job.arc_id) then
                    Debug.Table("Game.RequestCancelArc()", Game.RequestCancelArc(jobStatus.job.arc_id))
                end

                Debug.Divider("=")
            elseif (args[2] == "start") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== JOB START ===============================")
                    Debug.Table("Game.RequestStartArc()", Game.RequestStartArc(tonumber(args[3])))
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt job start <arc_id>")
                end
            elseif (args[2] == "status") then
                Debug.Log("======== JOB STATUS ==============================")
                Debug.Table("Player.GetJobStatus()", Player.GetJobStatus())
                Debug.Divider("=")
            else
                Notification("Usage: /bdt job <cancel | start | status>")
            end
        else
            Notification("Usage: /bdt job <cancel | start | status>")
        end
    end,

    -- ========================================================================
    --  MISSIONS
    -- ========================================================================
    mission = function(args)
        if (args[2]) then
            if (args[2] == "cancel") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== MISSION CANCEL ==========================")
                    Debug.Table("Player.AbortCampaignMission()", Player.AbortCampaignMission(tonumber(args[3])))
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt mission cancel <mission_id>")
                end
            elseif (args[2] == "dump") then
                Debug.Log("======== MISSION DUMP ============================")

                for missionId = 1, 250000 do
                    local missionInfo = Player.GetMissionInfo(missionId)
                    if (missionInfo) then
                        Debug.Log(tostring(missionId) ..  ": " .. tostring(missionInfo.name) .. " [" .. tostring(missionInfo.status) .. "]")
                        Debug.Log("\tDescription:", tostring(missionInfo.description))
                        Debug.Divider()
                    end
                end

                Debug.Divider("=")
            elseif (args[2] == "info") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== MISSION INFO ============================")
                    Debug.Table("Player.GetMissionInfo()", Player.GetMissionInfo(tonumber(args[3])))
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt mission info <mission_id>")
                end
            elseif (args[2] == "start") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    Debug.Log("======== MISSION START ===========================")
                    Debug.Table("ActivityDirector.RequestMission()", ActivityDirector.RequestMission(tonumber(args[3])))
                    Debug.Divider("=")
                else
                    Notification("Usage: /bdt mission start <mission_id>")
                end
            else
                Notification("Usage: /bdt mission <cancel | dump | info | start>")
            end
        else
            Notification("Usage: /bdt mission <cancel | dump | info | start>")
        end
    end,

    -- ========================================================================
    --  ENTITIES
    -- ========================================================================
    entity = function(args)
        if (args[2]) then
            if (args[2] == "bounds") then
                local playerTargetBounds = Game.GetTargetBounds(Player.GetTargetId())

                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    local targetBounds = Game.GetTargetBounds(args[3])

                    if (targetBounds) then
                        Debug.Log("======== ENTITY BOUNDS ===========================")
                        Debug.Table("targetBounds", {
                                targetBounds    = targetBounds,
                                vec2            = Vec2.Distance(playerTargetBounds, targetBounds),
                                vec3            = Vec3.Distance(playerTargetBounds, targetBounds)
                        })
                        Debug.Divider("=")
                    else
                        Notification("No info for entity " .. tostring(args[3]) .. " found")
                    end
                else
                    local reticleInfo = Player.GetReticleInfo()

                    if (reticleInfo.entityId) then
                        local targetBounds = Game.GetTargetBounds(reticleInfo.entityId)

                        if (targetBounds) then
                            Debug.Log("======== ENTITY BOUNDS ===========================")
                            Debug.Table("targetBounds", {
                                targetBounds    = targetBounds,
                                vec2            = Vec2.Distance(playerTargetBounds, targetBounds),
                                vec3            = Vec3.Distance(playerTargetBounds, targetBounds)
                            })
                            Debug.Divider("=")
                        else
                            Notification("No entity at reticle found")
                        end
                    else
                        Notification("No entity at reticle found")
                    end
                end
            elseif (args[2] == "info") then
                if (args[3] and unicode.match(args[3], "^%d+$")) then
                    local targetInfo = Game.GetTargetInfo(args[3])

                    if (targetInfo) then
                        Debug.Log("======== ENTITY INFO =============================")
                        Debug.Table("targetInfo", targetInfo)
                        Debug.Divider("=")
                    else
                        Notification("No info for entity " .. tostring(args[3]) .. " found")
                    end
                else
                    local reticleInfo = Player.GetReticleInfo()

                    if (reticleInfo.entityId) then
                        local targetInfo = Game.GetTargetInfo(reticleInfo.entityId)

                        if (targetInfo) then
                            Debug.Log("======== ENTITY INFO =============================")
                            Debug.Table("targetInfo", targetInfo)
                            Debug.Divider("=")
                        else
                            Notification("No entity at reticle found")
                        end
                    else
                        Notification("No entity at reticle found")
                    end
                end
            elseif (args[2] == "interact") then
                if (args[3] and unicode.match(args[3], "%d+")) then
                    if (Game.IsTargetAvailable(unicode.match(args[3], "^%d+$"))) then
                        Debug.Log("======== ENTITY INTERACT =========================")
                        Debug.Table("Player.BeginInteraction()", Player.BeginInteraction(args[3]))
                        Debug.Divider("=")
                    else
                        Notification("Entity " .. tostring(args[3]) .. " is not available")
                    end
                else
                    local reticleInfo = Player.GetReticleInfo()

                    if (reticleInfo.entityId) then
                        Debug.Log("======== ENTITY INTERACT =========================")
                        Debug.Table("Player.BeginInteraction()", Player.BeginInteraction(reticleInfo.entityId))
                        Debug.Divider("=")
                    else
                        Notification("No entity to interact with")
                    end
                end
            elseif (args[2] == "list") then
                local availableTargets = Game.GetAvailableTargets()
                local entityCount = 0
                local entityList = {}

                Debug.Log("======== ENTITY LIST =============================")

                if (args[3]) then
                    entityList[tostring(args[3])] = {}

                    for _, entityId in pairs(availableTargets) do
                        if (Game.IsTargetAvailable(entityId)) then
                            local targetInfo    = Game.GetTargetInfo(entityId)
                            local entityId      = tostring(entityId)

                            if (targetInfo and targetInfo.type) then
                                if (targetInfo.type == args[3]) then
                                    local targetType = tostring(targetInfo.type)

                                    if (not entityList[targetType]) then
                                        entityList[targetType] = {}
                                    end

                                    entityList[targetType][entityId]                    = {}
                                    entityList[targetType][entityId].name               = targetInfo.name
                                    entityList[targetType][entityId].deployableType     = targetInfo.deployableType
                                    entityList[targetType][entityId].deployableTypeId   = targetInfo.deployableTypeId

                                    entityCount = entityCount + 1
                                end
                            else
                                Debug.Warn("No targetInfo or targetInfo.type:", entityId)
                            end
                        end
                    end

                    Notification("Found " .. tostring(entityCount) .. " entities with type " .. tostring(args[3]))

                else
                    for _, entityId in pairs(availableTargets) do
                        if (Game.IsTargetAvailable(entityId)) then
                            local targetInfo = Game.GetTargetInfo(entityId)
                            local entityId = tostring(entityId)

                            if (targetInfo) then
                                if (targetInfo.type) then
                                    local targetType = tostring(targetInfo.type)

                                    if (not entityList[targetType]) then
                                        entityList[targetType] = {}
                                    end

                                    entityList[targetType][entityId]                    = {}
                                    entityList[targetType][entityId].name               = targetInfo.name
                                    entityList[targetType][entityId].deployableType     = targetInfo.deployableType
                                    entityList[targetType][entityId].deployableTypeId   = targetInfo.deployableTypeId

                                    entityCount = entityCount + 1
                                else
                                    if (not entityList.unknown) then
                                        entityList.unknown = {}
                                    end

                                    entityList.unknown[entityId]                        = {}
                                    entityList.unknown[entityId].name                   = targetInfo.name
                                    entityList[targetType][entityId].deployableType     = targetInfo.deployableType

                                    entityCount = entityCount + 1
                                end
                            else
                                Debug.Warn("No targetInfo:", entityId)
                            end
                        end
                    end

                    Notification("Found " .. tostring(entityCount) .. " entities")
                end

                Debug.Table("entityList", entityList)
                Debug.Divider("=")

            elseif (args[2] == "mark") then
                if (args[3]) then
                    if (unicode.match(args[3], "^%d+$")) then
                        if (g_EntityMarkers[args[3]]) then
                            Notification("Removing MapMarker for " .. args[3])

                            g_EntityMarkers[args[3]]:Destroy()
                            g_EntityMarkers[args[3]] = nil

                        else
                            if (Game.IsTargetAvailable(args[3])) then
                                Notification("Creating MapMarker for " .. args[3])

                                local MARKER = MapMarker.Create("bdt_" .. args[3])
                                local targetInfo = Game.GetTargetInfo(args[3])
                                g_EntityMarkers[args[3]] = MARKER

                                MARKER:BindToEntity(args[3])
                                MARKER:SetTitle(((targetInfo and targetInfo.name) and targetInfo.name or args[3]))
                                MARKER:ShowOnHud(true)
                                MARKER:ShowOnRadar(false)
                                MARKER:ShowOnWorldMap(true)
                                MARKER:ShowTrail(false)

                            else
                                Notification("Unable to create MapMarker: " .. args[3])
                            end
                        end

                    elseif (args[3] == "clear") then
                        Notification("Removing ALL MapMarker instances")

                        for markerId in pairs(g_EntityMarkers) do
                            g_EntityMarkers[markerId]:Destroy()
                            g_EntityMarkers[markerId] = nil
                        end

                    elseif (args[3] == "list") then
                        Debug.Table("g_EntityMarkers", g_EntityMarkers)

                    else
                        Notification("Usage: /bdt entity mark <entityId | clear>")
                    end

                else
                    Notification("Usage: /bdt entity mark <entityId | clear>")
                end

            else
                Notification("Usage: /bdt entity <bounds | interact | info | list | mark>")
            end
        else
            Notification("Usage: /bdt entity <bounds | interact | info | list | mark>")
        end
    end,

    -- =============================================================================
    --  Codices
    -- =============================================================================
    codex = function(args)
        if (args[2]) then
            if (args[2] == "dump") then
                for i = 1, 250000 do
                    local tutorialCards = Game.GetTutorialCards(i)

                    if (type(tutorialCards) == "table") then
                        local cardData = {}
                        local saveCard = false

                        for _, card in pairs(tutorialCards) do
                            if (card.TITLE and card.TITLE == "LORECARD_CODEX_TITLE") then
                                saveCard = true

                                table.insert(cardData,  {key = card.DESCRIPTION, text = Component.LookupText(card.DESCRIPTION)})
                            end
                        end

                        if (saveCard) then
                            Component.SaveSetting("tutorialCard_" .. unicode.format("%06i", i), cardData)
                        end
                     end
                end

            else
                Notification("Usage: /bdt codex <dump>")
            end

        else
            Notification("Usage: /bdt codex <dump>")
        end
    end,

    -- =============================================================================
    --  UTILITIES
    -- =============================================================================
    flushCharacterCache = function()
        Debug.Log("======== FLUSH CACHE =============================")
        Debug.Table("Player.FlushCharacterCache()", Player.FlushCharacterCache({all = true}))
        Debug.Divider("=")
    end,

    screditsalt = function() -- send credits from main to alt
        local count = Player.GetItemCount(Wallet.CREDITS_ID)
        Debug.Log("Credits amount:", count)

        if (count > 2000) then
            local attachments   = {
                item_type       = Wallet.CREDITS_ID,
                item_id         = nil,
                quantity        = 1000
            }

            Mail.SendMessage("BootyBiscuit", "The Good Stuff", "Take it.", attachments)
        end
    end,

    sendCreditsAll = function()
        local count = Player.GetItemCount(Wallet.CREDITS_ID)
        Debug.Log("Credits amount:", count)

        if (count > 1) then
            local attachments   = {
                item_type       = Wallet.CREDITS_ID,
                item_id         = nil,
                quantity        = count
            }

            Mail.SendMessage("BurstBiscuit", "Official Bribe", "You haven't seen a thing.", attachments)
        end
    end,


    scredits = function() -- send credits from alt to main
        local count = Player.GetItemCount(Wallet.CREDITS_ID)
        Debug.Log("Credits amount:", count)

        if (count > 1000) then
            local attachments   = {
                item_type       = Wallet.CREDITS_ID,
                item_id         = nil,
                quantity        = count - 1000
            }

            Mail.SendMessage("BurstBiscuit", "The Better Stuff", "Take it.", attachments)
        end
    end,

    stats = function() -- print all stats and item stats to console
        local stats = Player.GetAllStats()
        local loadout = Player.GetCurrentLoadout()
        local t_stats = {}

        for _, data in pairs(stats.attribute_categories) do
            local t_statinfo = {
                desc = "",
                value = 0
            }
            local value = data.current_value

            if data.is_scalar then
                value = value * 100
            end

            if (t_stats[data.stat_id]) then
                t_stats[data.stat_id].value = t_stats[data.stat_id].value + value
            else
                t_stats[data.stat_id] = {desc = data.designer_name, value = value}
            end

            fmt = "%5s %s: " .. data.localized_format_specifier
            Debug.Log(unicode.format(fmt, data.stat_id, data.designer_name, value))
        end

        t_stats = {}

        for _, data in pairs(stats.item_attributes) do
            local t_statinfo = {
                desc = "",
                value = 0
            }
            local value = data.current_value

            if (data.is_scalar) then
                value = value * 100
            end

            if t_stats[data.stat_id] then
                t_stats[data.stat_id].value = t_stats[data.stat_id].value + value
            else
                t_stats[data.stat_id]={desc = data.designer_name, value = value}
            end

            fmt = "%5s %s: " .. data.localized_format_specifier

            Debug.Log(unicode.format(fmt, data.stat_id, data.designer_name, value))
        end

        Debug.Log("Primary weapon stats:")

        if (loadout.items.primary_weapon.item_guid) then
            itemInfo = Player.GetItemInfo(loadout.items.primary_weapon.item_guid);

            for _, info in pairs(itemInfo.attributes) do
                local fmt = "%5s - %s: " .. info.format
                local value

                if (tonumber(info.stat_id) ~= 22) then
                    value = Player.GetAttribute(tonumber(info.stat_id), 1)
                else
                    value = info.value
                end

                Debug.Log(unicode.format(fmt, info.stat_id, info.dev_name, value))
            end
        end

        Debug.Log("Secondary weapon stats:")

        if (loadout.items.secondary_weapon.item_guid) then
            itemInfo = Player.GetItemInfo(loadout.items.secondary_weapon.item_guid)

            for _, info in pairs(itemInfo.attributes) do
                local fmt = "%5s - %s: " .. info.format
                local value

                if (tonumber(info.stat_id) ~= 22) then
                    value = Player.GetAttribute(tonumber(info.stat_id), 2)
                else
                    value = info.value
                end

                Debug.Log(unicode.format(fmt, info.stat_id, info.dev_name, value))
            end
        end
    end,

    -- =============================================================================
    --  FUN/SILLY STUFF
    -- =============================================================================
    fakeZT = function()
        Debug.Log("======== FAKE ZT SLAIN ===========================")
        Debug.Table("Chat.SendChannelText()", Chat.SendChannelText("zone", ChatLib.GetEndcapString() .. "ZT" .. ChatLib.GetLinkTypeIdBreak() .. "SLAIN" .. ChatLib.GetEndcapString()))
        Debug.Divider("=")
    end,

    ft = function(args)
        if (args[2] and unicode.len(args[2]) > 1) then
            local fanciedText = ""
            local text = unicode.gsub(unicode.gsub(unicode.gsub(args[2], "^%s+", ""), "%s+$", ""), "%s+", " ")
            local textLength = unicode.len(text)

            for i = 1, textLength do
                local substring = unicode.sub(text, i, i)

                if (unicode.len(fanciedText) >= 255) then
                    Notification("Reached the maximum chat message length, aborting")
                    break

                elseif (((i % 2) > 0) or unicode.match(substring, "%s+")) then
                    fanciedText = fanciedText .. substring

                else
                    local tmp = fanciedText .. ChatLib.EncodePlayerLink(substring)

                    if (unicode.len(tmp) > 255) then
                        Notification("Reached the maximum chat message length, aborting")
                        break

                    else
                        fanciedText = tmp
                    end
                end
            end

            ChatLib.AddTextToChatInput({text = fanciedText})

        else
            Notification("Please enter a text with >1 characters")
        end
    end,
}


-- =============================================================================
--  Functions
-- =============================================================================

function Notification(message)
    ChatLib.Notification({text = "[bDevTools] " .. tostring(message)})
end

function BuildItemDatabase()
    local Game_GetItemInfoByType = Game.GetItemInfoByType
    local table_insert = table.insert
    -- local itemDatabase = {}

    for i = 1, 250000 do
        local itemInfo = Game_GetItemInfoByType(i)

        if (itemInfo and type(itemInfo) == "table" and itemInfo.itemTypeId ~= nil) then
            local truncatedItemInfo = {
                itemTypeId      = tonumber(itemInfo.itemTypeId),
                name            = (itemInfo.name and tostring(itemInfo.name) or ""),
                description     = (itemInfo.description and tostring(itemInfo.description) or nil),
                type            = (itemInfo.type and tostring(itemInfo.type) or nil),
                subTypeId       = (itemInfo.subTypeId and tonumber(itemInfo.subTypeId) or nil),
                rarity          = (itemInfo.rarity and tostring(itemInfo.rarity) or nil),
                required_level  = (itemInfo.required_level and tonumber(itemInfo.required_level) or nil),
                certifications  = itemInfo.certifications
            }

            table_insert(g_ItemDatabase, truncatedItemInfo)
            -- table_insert(itemDatabase, itemInfo)
        end
    end

    -- Debug.Log("Sending item database to localhost")
    -- if (not HTTP.IsRequestPending("http://localhost:38080/")) then
        -- HTTP.IssueRequest("http://localhost:38080/", "POST", itemDatabase, nil)
    -- end
end

function FindItems(args)
    if (args.searchId and args.searchParameters) then
        local searchParameters = args.searchParameters
        local searchResults = {}

        Debug.Table("FindItems()", searchParameters)

        -- Search by name
        for i = 1, #g_ItemDatabase do
            if (g_ItemDatabase[i].name and unicode.match(g_ItemDatabase[i].name, searchParameters.match_string)) then
                table.insert(searchResults, g_ItemDatabase[i])

            elseif (searchParameters.match_description and g_ItemDatabase[i].description and unicode.match(g_ItemDatabase[i].description, searchParameters.match_string)) then
                table.insert(searchResults, g_ItemDatabase[i])
            end
        end

        -- Filter by type
        if (searchParameters.item_type and unicode.upper(searchParameters.item_type) ~= "ANY") then
            local c_TypeMap = {
                ["ABILITY"] = "ability_module",
                ["GEAR"]    = "frame_module",
                ["MODULE"]  = "item_module"
            }

            local itemType = unicode.upper(searchParameters.item_type)

            if (c_TypeMap[unicode.upper(searchParameters.item_type)]) then
                itemType = c_TypeMap[unicode.upper(searchParameters.item_type)]
            end

            local results = {}

            for i = 1, #searchResults do
                if (searchResults[i].type and unicode.upper(searchResults[i].type) == itemType) then
                    table.insert(results, searchResults[i])
                end
            end

            searchResults = results
        end

        -- Filter by subTypeId
        if (searchParameters.item_subtype and (SubTypeIds[searchParameters.item_subtype] or unicode.match(searchParameters.item_subtype, "^%d+$"))) then
            local subTypeId

            if (SubTypeIds[searchParameters.item_subtype]) then
                subTypeId = tonumber(SubTypeIds[searchParameters.item_subtype])

            else
                subTypeId = tonumber(searchParameters.item_subtype)
            end

            local results = {}

            for i = 1, #searchResults do
                if (searchResults[i].subTypeId and searchResults[i].subTypeId == subTypeId) then
                    table.insert(results, searchResults[i])
                end
            end

            searchResults = results
        end

        -- Filter by quality
        if (searchParameters.min_quality or searchParameters.max_quality) then
            local c_Rarities = {
                ["SALVAGE"]     = 1,
                ["COMMON"]      = 2,
                ["UNCOMMON"]    = 3,
                ["RARE"]        = 4,
                ["EPIC"]        = 5,
                ["LEGENDARY"]   = 6
            }

            local rarityMin = 1
            local rarityMax = 6

            if (searchParameters.min_quality and c_Rarities[unicode.upper(searchParameters.min_quality)]) then
                rarityMin = c_Rarities[unicode.upper(searchParameters.min_quality)]
            end

            if (searchParameters.max_quality and c_Rarities[unicode.upper(searchParameters.max_quality)]) then
                rarityMax = c_Rarities[unicode.upper(searchParameters.max_quality)]
            end

            local results = {}

            for i = 1, #searchResults do
                if (searchResults[i].rarity and c_Rarities[unicode.upper(searchResults[i].rarity)] and c_Rarities[unicode.upper(searchResults[i].rarity)] >= rarityMin and c_Rarities[unicode.upper(searchResults[i].rarity)] <= rarityMax) then
                    table.insert(results, searchResults[i])
                end
            end

            searchResults = results
        end

        -- Filter by level
        if ((searchParameters.min_level and unicode.match(searchParameters.min_level, "^%d+$")) or (searchParameters.max_level and unicode.match(searchParameters.max_level, "^%d+$"))) then
            local levelMin = 1
            local levelMax = 1000

            if (searchParameters.min_level and unicode.match(searchParameters.min_level, "^%d+$")) then
                levelMin = tonumber(searchParameters.min_level)
            end

            if (searchParameters.max_level and unicode.match(searchParameters.max_level, "^%d+$")) then
                levelMax = tonumber(searchParameters.max_level)
            end

            results = {}

            for i = 1, #searchResults do
                if (searchResults[i].rarity and searchResults[i].required_level >= levelMin and searchResults[i].required_level <= levelMax) then
                    table.insert(results, searchResults[i])
                end
            end

            searchResults = results
        end

        -- Filter by frame certifications
        if (searchParameters.class_certs and type(searchParameters.class_certs) == "table") then
            local results = {}

            for i = 1, #searchResults do
                if (searchResults[i].certifications) then
                    local matchFound = false

                    for _, itemCertificate in pairs(searchResults[i].certifications) do
                        if (matchFound) then
                            break
                        end

                        for _, searchCertificate in pairs(searchParameters.class_certs.certifications) do
                            if (tonumber(itemCertificate) == tonumber(searchCertificate)) then
                                table.insert(results, searchResults[i])
                                matchFound = true
                                break
                            end
                        end
                    end
                end
            end

            searchResults = results
        end

        -- Filtering finished, sort the results and only pass the itemTypeId to the output
        table.sort(searchResults, function(a, b) return a.itemTypeId < b.itemTypeId end)

        local itemTypeIds = {}

        for _, itemInfo in ipairs(searchResults) do
            table.insert(itemTypeIds, itemInfo.itemTypeId)
        end

        -- Search completed
        OnItemSearchCompleted({search_id = args.searchId, tokens = itemTypeIds})
    end
end

function CancelBounties(args)
    local callbackDelay = 0
    local canceledCount = 0

    Notification("Trying to cancel 'engaged' bounties, this might take some time ...")

    for missionId, bountyType in pairs(c_Bounties) do
        local missionInfo = Player.GetMissionInfo(missionId)

        if (missionInfo and missionInfo.status and unicode.lower(missionInfo.status) == "engaged"
                and ((args[1] and args[1] == bountyType) or not args[1])) then
            Callback2.FireAndForget(Player.AbortCampaignMission, missionId, callbackDelay)
            callbackDelay = callbackDelay + 2
            canceledCount = canceledCount + 1
        end
    end

    Callback2.FireAndForget(Notification, "Canceled " .. tostring(canceledCount) .. " bounties, relog or switch zone to refresh", callbackDelay)
end

function FixBounties()
    local callbackDelay = 0
    local canceledCount = 0

    Notification("Trying to cancel 'completed' 'engaged' bounties, this might take some time ...")

    for missionId in pairs(c_Bounties) do
        local missionInfo = Player.GetMissionInfo(missionId)

        if (missionInfo and missionInfo.status and unicode.lower(missionInfo.status) == "engaged" and missionInfo.objectives and missionInfo.objectives[1] and missionInfo.objectives[1].completed) then
            Callback2.FireAndForget(Player.AbortCampaignMission, missionId, callbackDelay)
            callbackDelay = callbackDelay + 2
            canceledCount = canceledCount + 1
        end
    end

    Callback2.FireAndForget(Notification, "Canceled " .. tostring(canceledCount) .. " bounties, relog or switch zone to refresh", callbackDelay)
end

function ConvertString(text)
    -- Convert to nil placeholder
    if     (text == "nil") then
        return c_nilPlaceholder

    -- Convert to boolean
    elseif (text == "true" or text == "false") then
        return (text == "true" and true or false)

    -- Convert to integer
    elseif (unicode.match(text, "^[%+%-]?%d+$") and unicode.len(unicode.match(text, "%d+")) < 15) then
        return tonumber(text)

    -- Convert to float
    elseif (unicode.match(text, "^[%+%-]?%d+%.%d+$") and unicode.len(unicode.match(text, "(%d+)%."), "%d") < 9 and unicode.len(unicode.match(text, "%.(%d+)"), "%d") < 9) then
        return tonumber(text)

    -- Convert JSON to a table
    elseif (unicode.match(text, "^json:.+")) then
        return jsontotable(unicode.match(text, "^json:(.+)"))

    -- Convert to string if nothing matches
    else
        return tostring(text)
    end
end

function GenericFunction(args)
    if (args[1] and args[2]) then
        Debug.Log("======== GENERIC FUNCTION CALL ====================")

        local params    = {}
        local result    = nil

        local function unpack2(t, k, n)
            k = k or 1
            n = n or #t

            if (k > n) then
                return
            end

            local v = t[k]

            if (v == c_nilPlaceholder) then
                v = nil
            end

            return v, unpack2(t, k + 1, n)
        end

        for i = 3, #args do
            if (args[i]) then
                table.insert(params, ConvertString(args[i]))
            end
        end

        Debug.Table("params", params)

        if     (args[1] == "ActivityDirector") then
            result = (args[3] and {ActivityDirector[args[2]](unpack2(params))} or {ActivityDirector[args[2]]()})

        elseif (args[1] == "Chat") then
            result = (args[3] and {Chat[args[2]](unpack2(params))} or {Chat[args[2]]()})

        elseif (args[1] == "Component") then
            result = (args[3] and {Component[args[2]](unpack2(params))} or {Component[args[2]]()})

        elseif (args[1] == "Database") then
            result = (args[3] and {Database[args[2]](unpack2(params))} or {Database[args[2]]()})

        elseif (args[1] == "Friends") then
            result = (args[3] and {Friends[args[2]](unpack2(params))} or {Friends[args[2]]()})

        elseif (args[1] == "Game") then
            result = (args[3] and {Game[args[2]](unpack2(params))} or {Game[args[2]]()})

        elseif (args[1] == "HTTP") then
            result = (args[3] and {HTTP[args[2]](unpack2(params))} or {HTTP[args[2]]()})

        elseif (args[1] == "Lobby") then
            result = (args[3] and {Lobby[args[2]](unpack2(params))} or {Lobby[args[2]]()})

        elseif (args[1] == "Paperdoll") then
            result = (args[3] and {Paperdoll[args[2]](unpack2(params))} or {Paperdoll[args[2]]()})

        elseif (args[1] == "Platoon") then
            result = (args[3] and {Platoon[args[2]](unpack2(params))} or {Platoon[args[2]]()})

        elseif (args[1] == "Player") then
            result = (args[3] and {Player[args[2]](unpack2(params))} or {Player[args[2]]()})

        elseif (args[1] == "Radio") then
            result = (args[3] and {Radio[args[2]](unpack2(params))} or {Radio[args[2]]()})

        elseif (args[1] == "Replay") then
            result = (args[3] and {Replay[args[2]](unpack2(params))} or {Replay[args[2]]()})

        elseif (args[1] == "Sinvironment") then
            result = (args[3] and {Sinvironment[args[2]](unpack2(params))} or {Sinvironment[args[2]]()})

        elseif (args[1] == "Squad") then
            result = (args[3] and {Squad[args[2]](unpack2(params))} or {Squad[args[2]]()})

        elseif (args[1] == "System") then
            result = (args[3] and {System[args[2]](unpack2(params))} or {System[args[2]]()})

        elseif (args[1] == "Vehicle") then
            result = (args[3] and {Vehicle[args[2]](unpack2(params))} or {Vehicle[args[2]]()})

        else
            Notification("Namespace " .. tostring(args[2]) .. " not defined")
        end

        Debug.Table(args[1] .. "." .. args[2] .. "()", result)
        Debug.Divider("=")

    else
        Notification("No namespace or method supplied")
    end
end

function SleepGlitch()
    local currentLoadout = Player.GetCurrentLoadout()

    if (currentLoadout and currentLoadout.id and currentLoadout.items) then
        local itemTypeId
        local slotTypeId

        if (currentLoadout.items.vehicle) then
            itemTypeId = currentLoadout.items.vehicle
            slotTypeId = 157

        elseif (currentLoadout.items.glider) then
            itemTypeId = currentLoadout.items.glider
            slotTypeId = 158

        else
            Debug.Warn("No vehicle/glider equipped")
            return
        end

        Game.SlashCommand("sleep")

        Callback2.FireAndForget(function()
            Player.RequestSlotGear(currentLoadout.id, nil, nil, slotTypeId)
        end, nil, 0.1)

        Callback2.FireAndForget(function()
            Player.RequestSlotGear(currentLoadout.id, itemTypeId, nil, slotTypeId)
        end, nil, 5)
    end
end

function OnEvent(args)
    Debug.Event(args)
end

function OnSlashCommand(args)
    if (args[1] and c_SlashCommands[args[1]]) then
        c_SlashCommands[args[1]](args)

    else
        Notification("Sub-command not found")
    end
end


-- =============================================================================
--  Events
-- =============================================================================

function OnComponentLoad()
    LIB_SLASH.BindCallback({
        slash_list = "bdevtools, bdt",
        description = "bDevTools: Creeping up on you",
        func = OnSlashCommand
    })

    LIB_SLASH.BindCallback({
        slash_list = "bcmd",
        description = "bDevTools: Generic function",
        func = GenericFunction
    })

    LIB_SLASH.BindCallback({
        slash_list = "bsleep",
        description = "bDevTools: Sleep glitch",
        func = SleepGlitch
    })

    LIB_SLASH.BindCallback({
        slash_list = "cancelbounties",
        description = "bDevTools: Try to cancel ALL bounties",
        func = CancelBounties
    })

    LIB_SLASH.BindCallback({
        slash_list = "fixbounties",
        description = "bDevTools: Try to cancel stuck bounties",
        func = FixBounties
    })

    for k, v in pairs(c_TextEmotes) do
        LIB_SLASH.BindCallback({
            slash_list = k,
            description = v.description,
            func = function(args)
                ChatLib.AddTextToChatInput({text = v.text})
            end
        })
    end

    BuildItemDatabase()
end

function OnItemSearchCompleted(args)
    if (args.search_id and g_SearchIds[tostring(args.search_id)]) then
        Debug.Log("======== ITEM SEARCH RESULT ======================")

        if (args.tokens) then
            local notificationStrings = {}
            table.insert(notificationStrings, "Found " .. tostring(#args.tokens) .. " items")

            if (#args.tokens > 0) then
                local page = #notificationStrings
                notificationStrings[#notificationStrings] = notificationStrings[#notificationStrings] .. ":\n\t"
                Debug.Table("notificationStrings", notificationStrings)

                for i = 1, #args.tokens do
                    local hiddenModules = {}
                    local itemTypeId = unicode.match(args.tokens[i], "^%d+")

                    if (unicode.match(args.tokens[i], "^%d+%:%d+$")) then
                        hiddenModules = {unicode.match(args.tokens[i], "%d+$")}
                    end

                    local itemInfo = Game.GetItemInfoByType(itemTypeId, hiddenModules)

                    Debug.Log(unicode.format("%6s", args.tokens[i]), itemInfo.name)

                    notificationStrings[page] = notificationStrings[page] .. ChatLib.EncodeItemLink(itemTypeId, hiddenModules)

                    if (i % 100 == 0 and i < #args.tokens) then
                        page = page + 1
                        notificationStrings[page] = "\n\t"

                    elseif (i % 3 == 0 and i < #args.tokens) then
                        notificationStrings[page] = notificationStrings[page] .. "\n\t"

                    elseif (i < #args.tokens) then
                        notificationStrings[page] = notificationStrings[page] .. " "
                    end
                end
            end

            notificationStrings[#notificationStrings] = notificationStrings[#notificationStrings] .. "\n--- End of search results ---"

            for _, notificationString in ipairs(notificationStrings) do
                Notification(notificationString)
            end
        end

        g_SearchIds[tostring(args.search_id)] = nil

        Debug.Divider("=")
    end
end
