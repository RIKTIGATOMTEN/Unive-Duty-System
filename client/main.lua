ESX = exports['es_extended']:getSharedObject()

self = {
    callbacks = {
        close = function()
            SetNuiFocus(false, false)
            TriggerServerEvent('unrp_gangsystem:closedMenu')
        end,

        changeState = function(data, cb)
            ESX.TriggerServerCallback('unrp_dutysystem:changeState', function(result) 
                cb(true)
            end, data)
        end,

        sendMessage = function(data, cb)
            ESX.TriggerServerCallback('unrp_dutysystem:sendMessage', function(result) 
                cb(true)
            end, data)
        end
    }
}

RegisterCommand('duty', function()
    ESX.TriggerServerCallback('unrp_dutysystem:getData', function(result)
        SendNUIMessage({
            type = "open",
            data = {
                onDuty = result.onDuty,
                jobCoworkers = result.jobCoworkers,
                jobChat = result.jobChat,
                playerIdentifier = result.playerIdentifier,
                playerData = {
                    name = ("%s %s"):format(ESX.GetPlayerData().character.firstname, ESX.GetPlayerData().character.lastname),
                    identifier = ESX.GetPlayerData().identifier,
                    job_grade = ESX.GetPlayerData().job.grade_label,
                    grade = ESX.GetPlayerData().job.grade,
                    phonenumber = "0725439511"
                },
            }
        })
    
        SetNuiFocus(true, true)
        
        TriggerServerEvent('unrp_gangsystem:openedMenu')
    end)
end)

RegisterNetEvent("unrp_dutysystem:updateChat", function(messages)
    SendNUIMessage({
        type = "updateChat",
        data = {
            messages = messages
        }
    })
end)

RegisterNetEvent('unrp_dutySystem:forceUpdate')
AddEventHandler('unrp_dutySystem:forceUpdate', function(...)
    ESX.TriggerServerCallback('unrp_dutysystem:getData', function(result)
        SendNUIMessage({
            type = "open",
            data = {
                onDuty = result.onDuty,
                jobCoworkers = result.jobCoworkers,
                jobChat = result.jobChat,
                playerIdentifier = result.playerIdentifier,
                playerData = {
                    name = ("%s %s"):format(ESX.GetPlayerData().character.firstname, ESX.GetPlayerData().character.lastname),
                    identifier = ESX.GetPlayerData().identifier,
                    job_grade = ESX.GetPlayerData().job.grade_label,
                    grade = ESX.GetPlayerData().job.grade,
                    phonenumber = "0725439511"
                },
            }
        })
    end)
end)

-- Citizen.CreateThread(function()
--     while true do 
--         TriggerServerEvent('unrp_dutysystem:addTime')
--         Wait(60000)
--     end
-- end)

for key, value in pairs(self.callbacks) do
    RegisterNuiCallback(key, value)
end