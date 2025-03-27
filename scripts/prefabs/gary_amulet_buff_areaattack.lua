local time_duration = TUNING.JELLYBEAN_DURATION * 1 -- 糖豆持续时间为1/4天

local function DoThorns(inst, owner)
    SpawnPrefab("gary_amulet_bramblefx_armor"):SetFXOwner(owner)
end

local function SpawnAreaDamage(inst, Attacker, data)
    Attacker.components.talker:Say(STRINGS.NAMES.ONATTACK)
    DoThorns(inst, Attacker)
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) 
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
    -- if target.components.combat ~= nil then
    --     target.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE + 3) --攻击距离增加3，即增加1.5个人物空手攻击距离的长度
    -- end
    -- inst:ListenForEvent("onattackother", SpawnAreaDamage(inst, target), target)
    inst.SpawnAreaDamage = function(target, _data) SpawnAreaDamage(inst, target, _data) end
    inst:ListenForEvent("onattackother", inst.SpawnAreaDamage, target)
    inst:ListenForEvent("attacked", inst.SpawnAreaDamage, target)
end

local function OnTimerDone(inst, data)
    if data.name == "attackrange" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)
    inst.components.timer:StopTimer("attackrange")
    inst.components.timer:StartTimer("attackrange", time_duration)
end

local function OnDetached(inst, target)
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

return Prefab("gary_amulet_buff_areaattack", fn)