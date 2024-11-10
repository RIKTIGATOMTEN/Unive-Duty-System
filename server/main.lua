ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local jobChats = {}  -- Store job-specific chats

-- Handle the server callback for getting data
ESX.RegisterServerCallback('unrp_dutysystem:getData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerIdentifier = xPlayer.identifier
    local job = xPlayer.getJob()

    -- Retrieve duty state from the database
    MySQL.Async.fetchScalar('SELECT onDuty FROM duty_status WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(onDuty)
        onDuty = onDuty or false  -- If there's no record, default to off duty

        -- Retrieve coworkers (players with the same job)
        local jobCoworkers = {}
        for _, player in ipairs(ESX.GetPlayers()) do
            local coworker = ESX.GetPlayerFromId(player)
            if coworker.getJob().name == job.name then
                table.insert(jobCoworkers, {
                    name = coworker.getName(),
                    identifier = coworker.identifier,
                    job_grade = coworker.getJob().grade_label
                })
            end
        end

        -- Send back data for the NUI interface
        cb({
            onDuty = onDuty,
            jobCoworkers = jobCoworkers,
            jobChat = jobChats[job.name] or {},
            playerIdentifier = playerIdentifier,
        })
    end)
end)

-- Change player duty status
ESX.RegisterServerCallback('unrp_dutysystem:changeState', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerIdentifier = xPlayer.identifier

    -- Save the new duty state in the database
    MySQL.Async.execute('REPLACE INTO duty_status (identifier, onDuty) VALUES (@identifier, @onDuty)', {
        ['@identifier'] = playerIdentifier,
        ['@onDuty'] = data.newDutyState
    }, function(rowsChanged)
        -- Notify the player about their duty status via ox_lib
        if data.newDutyState then
            lib.notify({
                title = 'Duty Status',
                description = 'You are now on duty.',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Duty Status',
                description = 'You are now off duty.',
                type = 'info'
            })
        end

        cb(true)
    end)
end)

-- Handle messages in job chat
ESX.RegisterServerCallback('unrp_dutysystem:sendMessage', function(source, cb, data)
    local xPlayer = ESX GetPlayerFromId(source)
    local job = xPlayer.getJob()

    -- Store the message in job chat
    jobChats[job.name] = jobChats[job.name] or {}
    table.insert(jobChats[job.name], {
        sender = xPlayer.getName(),
        message = data.message
    })

    -- Broadcast the updated chat to all players with the same job
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local coworker = ESX.GetPlayerFromId(playerId)
        if coworker.getJob().name == job.name then
            TriggerClientEvent('unrp_dutysystem:updateChat', playerId, jobChats[job.name])
        end
    end

    cb(true)
end)

-- Handle the event when the player opens the menu
RegisterNetEvent('unrp_gangsystem:openedMenu')
AddEventHandler('unrp_gangsystem:openedMenu', function()
    local source = source
    print(('Player %s opened the duty menu'):format(GetPlayerName(source)))
end)

-- Handle the event when the player closes the menu
RegisterNetEvent('unrp_gangsystem:closedMenu')
AddEventHandler('unrp_gangsystem:closedMenu', function()
    local source = source
    print(('Player %s closed the duty menu'):format(GetPlayerName(source)))
end)

-- (Optional) Track time spent on duty
RegisterNetEvent('unrp_dutysystem:addTime')
AddEventHandler('unrp_dutysystem:addTime', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerIdentifier = xPlayer.identifier

    -- Increment time on duty (if necessary)
    MySQL.Async.fetchScalar('SELECT onDuty FROM duty_status WHERE identifier = @identifier', {
        ['@identifier'] = playerIdentifier
    }, function(onDuty)
        if onDuty then
            -- Increment time logic here if needed
            print(('%s is currently on duty.'):format(GetPlayerName(source)))
        end
    end)
end)
