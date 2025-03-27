local time_duration = TUNING.JELLYBEAN_DURATION * 1 --糖豆持续时间为1/4天

local function OnTick(inst, target)
    if not target.components.health:IsDead() and not target:HasTag("playerghost") then
        local x, _, z = target.Transform:GetWorldPosition()
        SpawnPrefab("moonpulse_fx").Transform:SetPosition(x, 0, z)
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) 
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, OnTick, nil, target)
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
    if target.components.combat ~= nil then
        target.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE + 3) --攻击距离增加3，即增加1.5个人物空手攻击距离的长度
    end
end

local function OnTimerDone(inst, data)
    if data.name == "attackrange" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)
    inst.components.timer:StopTimer("attackrange")
    inst.components.timer:StartTimer("attackrange", time_duration)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, OnTick, nil, target)
end

local function OnDetached(inst, target)
    if target.components.combat ~= nil then
        target.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("attackrange", time_duration)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("gary_amulet_buff_attackrange", fn)