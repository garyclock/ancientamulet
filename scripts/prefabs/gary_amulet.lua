local assets = {
  Asset("ANIM", "anim/gary_amulet.zip"),
  Asset("ANIM", "anim/torso_gary_amulets.zip"),
  Asset("IMAGE", "images/gary_amulet.tex"),
  Asset("ATLAS", "images/gary_amulet.xml"),
  Asset("ATLAS_BUILD", "images/gary_amulet.xml", 256)
}

local gary_amulet_modname = KnownModIndex:GetModActualName("Ancient Amulet")

local function CLIENT_PlayFuelSound(inst)
  local parent = inst.entity:GetParent()
  local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
  if container ~= nil and container:IsOpenedBy(ThePlayer) then
    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
  end
end

local function commonfn(anim, tag, should_sink, can_refuel)
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()
  inst.entity:AddSoundEmitter()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank("gary_amulet")
  inst.AnimState:SetBuild("gary_amulet")
  inst.AnimState:PlayAnimation("idle")
  -- inst.AnimState:OverrideSymbol("swap_body", "sawp_gary_amulet", "sawp_gary_amulet")

  inst.scrapbook_anim = "idle"

  -- shadowlevel (from shadowlevel component) added to pristine state for optimization
  inst:AddTag("shadowlevel")

  if tag ~= nil then inst:AddTag(tag) end

  inst.foleysound = "dontstarve/movement/foley/jewlery"

  if can_refuel then
    inst.playfuelsound = net_event(inst.GUID, "amulet.playfuelsound")

    if not TheWorld.ismastersim then
      -- delayed because we don't want any old events
      inst:DoTaskInTime(0, inst.ListenForEvent, "amulet.playfuelsound", CLIENT_PlayFuelSound)
    end
  end

  if not should_sink then MakeInventoryFloatable(inst, "med", nil, 0.6) end

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then return inst end

  inst:AddComponent("inspectable")

  inst:AddComponent("equippable")
  inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY

  inst:AddComponent("inventoryitem")
  if should_sink then inst.components.inventoryitem:SetSinks(true) end

  inst:AddComponent("shadowlevel")
  inst.components.shadowlevel:SetDefaultLevel(TUNING.AMULET_SHADOW_LEVEL)

  return inst
end

local function reName(inst, owner)
  inst.components.named:SetName(STRINGS.NAMES.ANCIENT_AMULET .. "\n" .. STRINGS.NAMES.BONUS ..
      "\n" .. STRINGS.NAMES.BONUS_HEALTH .. ":" .. inst.gary_amulet_level_MaxHealth * inst.gary_amulet_Parameter_MaxHealth .. 
      -- "\n额外伤害减免:" ..inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb/(100 + inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb) ..
      "\n" .. STRINGS.NAMES.BONUS_ABSORB .. ":" ..math.floor(inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb/(100 + inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb) * 1000 + 0.5) / 10 .."%" ..
      "\n" .. STRINGS.NAMES.BONUS_REGAN .. ":" ..inst.gary_amulet_level_HealthRegen * inst.gary_amulet_Parameter_HealthRegen .. 
      "\n" .. STRINGS.NAMES.BONUS_MULTIPLE .. ":" ..inst.gary_amulet_Parameter_DamageMultiple*inst.gary_amulet_level_DamageMultiple*100 .."%" ..
      "\n" .. STRINGS.NAMES.BONUS_PLANAR .. ":" ..inst.gary_amulet_level_DamagePlanar*inst.gary_amulet_Parameter_DamagePlanar .. 
      "\n" .. STRINGS.NAMES.BONUS_REZ .. ":" .. inst.gary_amulet_level_REZ ..
      "\n" .. STRINGS.NAMES.BONUS_CONSUME .. ":" .. 
      120 * (inst.gary_amulet_PeriodicConsume
      + inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Consume_DamageAbsorb
      + inst.gary_amulet_level_DamageMultiple*inst.gary_amulet_Consume_DamageMultiple
      + inst.gary_amulet_level_DamagePlanar*inst.gary_amulet_Consume_DamagePlanar
      - inst.gary_amulet_level_PeriodicRepair*inst.gary_amulet_parameter_PeriodicRepair)
    )
end

------------发光------------
local function turnOnLight(inst, owner)
  if inst._light == nil or not inst._light:IsValid() then
      inst._light = SpawnPrefab("gary_amulet_light")
  end
  inst._light.entity:SetParent(owner.entity)
end

local function turnOffLight(inst)
  if inst._light ~= nil then
      if inst._light:IsValid() then
          inst._light:Remove()
      end
      inst._light = nil
  end
end
----------------------------

--生命恢复，以及其他有耐久才生效的（周期性）事件
local function PeriodicTask_consume(inst, owner)
  --Usetime repairing
  inst.components.finiteuses:Repair(inst.gary_amulet_level_PeriodicRepair*inst.gary_amulet_parameter_PeriodicRepair)
  --Usetime consuming
  inst.components.finiteuses:Use(inst.gary_amulet_PeriodicConsume
  + inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Consume_DamageAbsorb
  + inst.gary_amulet_level_DamageMultiple*inst.gary_amulet_Consume_DamageMultiple
  + inst.gary_amulet_level_DamagePlanar*inst.gary_amulet_Consume_DamagePlanar)
  local use_time = inst.components.finiteuses:GetUses()
  --yellow amulet effect
  if use_time <= 0 then
    turnOffLight(inst) --停止发光
  end
  --healing
  if owner.components.health ~= nil then
    local regen_health = inst.gary_amulet_level_HealthRegen * inst.gary_amulet_Parameter_HealthRegen
    if owner.components.health and owner.components.health:IsHurt() and not owner.components.oldager then
      if use_time >= regen_health*3 then
        owner.components.health:DoDelta(regen_health,false,"redamulet")
        inst.components.finiteuses:Use(regen_health*inst.gary_amulet_Consume_HealthRegen)
      elseif use_time > 0 then
        owner.components.health:DoDelta(use_time/inst.gary_amulet_Consume_HealthRegen,false,"redamulet")
        inst.components.finiteuses:Use(use_time)
      end
    end
  end
end

--作祟效果函数
local function OnHaunt(inst, haunter)
  if inst.gary_amulet_level_REZ > 0 then --不需要耐久
  -- if inst.gary_amulet_level_REZ > 0 
  -- and (inst.components.finiteuses and inst.components.finiteuses:GetUses() > 0 ) then --需要耐久大于零
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)
  inst.gary_amulet_level_REZ = inst.gary_amulet_level_REZ - 1
  inst.components.finiteuses:Use(inst.gary_amulet_Consume_REZ) --无论如何，仍会扣耐久
  elseif inst.gary_amulet_level_REZ == 0 then
    inst.components.hauntable.hauntvalue=nil
  end
  reName(inst, haunter)
  return true
end

--应用属性加成
local function AddOwnerAttribute(inst, owner)
  if owner.components.health ~= nil then
    --最大生命值, by gary
    if owner.components.health.currenthealth ~= nil then
      --local health_percent = owner.components.health:GetPercent()
      local CurrentHealth = owner.components.health.currenthealth
      owner.components.health:SetMaxHealth(owner.components.health.maxhealth + inst.gary_amulet_level_MaxHealth*inst.gary_amulet_Parameter_MaxHealth)
      --owner.components.health:SetPercent(health_percent)
      owner.components.health:SetCurrentHealth(CurrentHealth)
    end
    --减伤, by gary
    if owner.components.health.absorb ~= nil then
      local gary_amulet_AbsorbBonus = inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb/(100 + inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb)
      local inherent_DamageAbsorb = owner.components.health.absorb
      owner.components.health.externalabsorbmodifiers:SetModifier("gary_amulet", (1-inherent_DamageAbsorb)*gary_amulet_AbsorbBonus)
    end
  end
  --基础伤害倍率, by gary
  if owner.components.combat ~= nil then
    -- owner.components.combat.externaldamagemultipliers:SetModifier("gary_amulet", 
    -- owner.components.combat.externaldamagemultipliers:Get() + inst.gary_amulet_Parameter_DamageMultiple*inst.gary_amulet_level_DamageMultiple)
    owner.components.combat.externaldamagemultipliers:SetModifier("gary_amulet", 1 + inst.gary_amulet_Parameter_DamageMultiple*inst.gary_amulet_level_DamageMultiple)
  end
  --位面伤害等级
  if owner.components.planardamage ~= nil then
    owner.components.planardamage.externalbonuses:SetModifier("gary_amulet", inst.gary_amulet_level_DamagePlanar*inst.gary_amulet_Parameter_DamagePlanar)
  end
  --生命恢复，以及其他有耐久才生效的（周期性）事件，cite重生护符, by gary
  inst.task = inst:DoPeriodicTask(inst.gary_amulet_PeriodicTime, PeriodicTask_consume, nil, owner)
end

--解除属性加成
local function RemoveOwnerAttribute(inst, owner)
  if owner.components.health ~= nil then
    --最大生命值, by gary
    if owner.components.health.currenthealth ~= nil then
      local CurrentHealth = owner.components.health.currenthealth
      local UnequipMaxHealth = (owner.components.health.maxhealth - inst.gary_amulet_level_MaxHealth*inst.gary_amulet_Parameter_MaxHealth)
      owner.components.health:SetMaxHealth(UnequipMaxHealth)
      if CurrentHealth <= UnequipMaxHealth then
        owner.components.health:SetCurrentHealth(CurrentHealth)
      elseif CurrentHealth > UnequipMaxHealth then
        owner.components.health:SetCurrentHealth(UnequipMaxHealth)
      end
    end
    --减伤, by gary
    if owner.components.health.absorb ~= nil then
      owner.components.health.externalabsorbmodifiers:RemoveModifier("gary_amulet")
    end
  end
  --基础伤害倍率, by gary
  if owner.components.combat ~= nil then
    owner.components.combat.externaldamagemultipliers:RemoveModifier("gary_amulet")
  end
  --位面伤害等级
  if owner.components.planardamage ~= nil then
    owner.components.planardamage.externalbonuses:RemoveModifier("gary_amulet")
  end
  --生命恢复，以及其他有耐久才生效的（周期性）事件，cite重生护符, by gary
  if inst.task ~= nil then
    inst.task:Cancel()
    inst.task = nil
  end
end

local function OnKilled(killer, data)
  if data ~= nil and data.victim ~= nil and data.victim.prefab ~= nil 
  and data.victim.components.health ~= nil and data.victim.components.health:GetMaxWithPenalty() >= 4000 
  and math.random() < GetModConfigData("gary_amulet_living_tissue_probability", gary_amulet_modname) then
    data.victim.components.lootdropper:SpawnLootPrefab("gary_amulet_living_tissue")
    -- killer.components.talker:Say("哇，金色传说！")
  end
end

local function onequip_gary_amulet(inst, owner)
  owner.AnimState:OverrideSymbol("swap_body", "torso_gary_amulets", "greenamulet")
  -- owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "greenamulet")
  if inst.components.finiteuses:GetUses() > 0 then
    AddOwnerAttribute(inst, owner)
    turnOnLight(inst, owner)
  end
  owner:ListenForEvent("killed", OnKilled)
end

local function onunequip_gary_amulet(inst, owner)
  owner.AnimState:ClearOverrideSymbol("swap_body")
  if inst.components.finiteuses:GetUses() > 0 then
    RemoveOwnerAttribute(inst, owner)
    turnOffLight(inst, owner)
  end
  owner:RemoveEventCallback("killed", OnKilled)
end

local function onequiptomodel_gary_amulet(inst, owner, from_ground) end

--- 可接受的食物类型
local Accepted_Foodtype =
{
    "edible_" .. FOODTYPE.VEGGIE,  
    "edible_" .. FOODTYPE.BERRY,
    "edible_" .. FOODTYPE.SEEDS,
    "edible_" .. FOODTYPE.MEAT,
    "edible_" .. FOODTYPE.MONSTER,
    "edible_" .. FOODTYPE.GOODIES,
    "edible_" .. FOODTYPE.GENERIC,
    "edible_" .. FOODTYPE.RAW
}

--[[]]
local UpgradeItems = {
  {"slurper_pelt", "啜食兽毛皮"}, --等级（影响最大耐久）
  {"armorskeleton", "骨头盔甲"}, --减伤
  {"shadowheart", "暗影心脏"}, --生命回复
  {"opalpreciousgem", "彩虹宝石"}, --伤害加成
  {"alterguardianhatshard", "启迪之冠碎片"}, --额外位面伤害
  {"amulet", "重生护符"}, --复活次数
  {"gary_amulet_living_tissue", "活性组织"} --降低耐久消耗
 }

local SingleUseItems = {
  {"moonrocknugget", "月岩"}, --传送到绚丽之门or天体传送门
  {"nothing_1", "测试物"}, 
  {"purebrilliance", "纯粹辉煌"}, 
  {"horrorfuel", "纯粹恐惧"}, 
  }

local function valueExists(table_i, value_i)
  for i = 1, #table_i do
		if value_i == table_i[i][1] then
			return true
		end
  end
  return false
end

local function ItemTradeTest(inst, item)
  if item:HasOneOfTags(Accepted_Foodtype) then
    return true
  elseif valueExists(UpgradeItems, item.prefab) then
    return true
  elseif valueExists(SingleUseItems, item.prefab) then
    return true
  else
    return false
  end
end

local function FoodGiven(inst, giver, item) --食物带来的属性加成
  giver.components.talker:Say(STRINGS.NAMES.ONEAT)
  if item.components.edible.hungervalue > 0 then
    if inst.components.finiteuses:GetUses() == 0 and (inst == giver.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or giver.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)) then
      AddOwnerAttribute(inst, giver)
      turnOnLight(inst, giver)
    end
    inst.components.finiteuses:Repair(item.components.edible.hungervalue)
  end
  local DeltaHealth = 0
  if item.components.edible.healthvalue > 0 then
    inst.gary_amulet_level_MaxHealth = inst.gary_amulet_level_MaxHealth + item.components.edible.healthvalue --提升最大生命等级
    --giver.components.health:DoDelta(item.components.edible.healthvalue) --回复同等数值的生命，这个应该放在重新计算属性后
    DeltaHealth = item.components.edible.healthvalue * inst.gary_amulet_health_regan_ratio
  end
  return DeltaHealth
end

local function UpgradeGiven(inst, giver, item) --升级材料带来的属性or等级加成
  if item.prefab == UpgradeItems[1][1] then --等级(影响耐久)
    inst.gary_amulet_level = inst.gary_amulet_level + 1 
    inst.components.finiteuses:SetMaxUses(inst.gary_amulet_BaseUses + inst.gary_amulet_level*inst.gary_amulet_Parameter)
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_DURABILITY)
  elseif item.prefab == UpgradeItems[2][1] then --减伤
    inst.gary_amulet_level_DamageAbsorb = inst.gary_amulet_level_DamageAbsorb + 1
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_ABSORB)
  elseif item.prefab == UpgradeItems[3][1] then --生命回复
    inst.gary_amulet_level_HealthRegen = inst.gary_amulet_level_HealthRegen + 1
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_REGAN)
  elseif item.prefab == UpgradeItems[4][1] then --伤害加成
    inst.gary_amulet_level_DamageMultiple = inst.gary_amulet_level_DamageMultiple + 1
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_MULTIPLE)
  elseif item.prefab == UpgradeItems[5][1] then --位面伤害
    inst.gary_amulet_level_DamagePlanar = inst.gary_amulet_level_DamagePlanar + 1
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_PLANAR)
  elseif item.prefab == UpgradeItems[6][1] then --复活次数
    inst.gary_amulet_level_REZ = inst.gary_amulet_level_REZ + 1
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_REZ)
  elseif item.prefab == UpgradeItems[7][1] then
    inst.gary_amulet_level_PeriodicRepair = inst.gary_amulet_level_PeriodicRepair + 1
    giver.components.talker:Say(STRINGS.NAMES.LEVELUP_DURABILITYREGAN)
  end
end

local function SingleUseGiven(inst, giver, item) --一次性物品带来buff或其它效果
  if item.prefab == SingleUseItems[1][1] then --传送到绚丽之门or天体传送门
    local portal = TheSim:FindEntities(0, 0, 0, 10000, {"multiplayer_portal"}, nil, nil)
    if portal[1] ~= nil then
      giver.Transform:SetPosition(portal[1].Transform:GetWorldPosition())
    else 
      giver.components.inventory:GiveItem(SpawnPrefab(SingleUseItems[1][1]))
      giver.components.talker:Say(STRINGS.NAMES.PORTALNOTFOUND)
    end
  end
  if item.prefab == SingleUseItems[2][1] then
    giver:AddDebuff("gary_amulet_buff_hungerregen", "gary_amulet_buff_hungerregen")
    giver.components.talker:Say("test buff added")
  end
  if item.prefab == SingleUseItems[3][1] then
    giver:AddDebuff("gary_amulet_buff_attackrange", "gary_amulet_buff_attackrange")
    giver.components.talker:Say(STRINGS.NAMES.BUFF_ATTACKRANGE)
  end
  if item.prefab == SingleUseItems[4][1] then
    giver:AddDebuff("gary_amulet_buff_areaattack", "gary_amulet_buff_areaattack")
    giver.components.talker:Say(STRINGS.NAMES.BUFF_AREAATTACK)
  end
end

local function OnItemGiven(inst, giver, item)
  local OnEquipped = false
  if inst == giver.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or giver.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK) then
    OnEquipped = true
  end
  local CurrentHealth = giver.components.health.currenthealth --记录当前生命值
  local DeltaHealth = 0 --食物回复的生命值（若小于0则计0）
  --先解除属性加成
  if OnEquipped then
    RemoveOwnerAttribute(inst, giver)
  end
  --食物带来的属性加成
  if item:HasOneOfTags(Accepted_Foodtype) then
    DeltaHealth = FoodGiven(inst, giver, item)
  --升级材料带来等级加成
  elseif valueExists(UpgradeItems, item.prefab) then
    UpgradeGiven(inst, giver, item)
  --一次性物品效果
  elseif valueExists(SingleUseItems, item.prefab) then
    SingleUseGiven(inst, giver, item)
  end
  --计算升级后属性加成
  if OnEquipped then
    AddOwnerAttribute(inst, giver)
  end
  giver.components.health:DoDelta(CurrentHealth + DeltaHealth - giver.components.health.currenthealth) --回复同等数值的生命
  reName(inst, giver)
  return
end

local function onRefuseItem(inst, giver, item)
  giver.components.talker:Say(STRINGS.NAMES.REFUSE_GIVE)
end

-- 耐久为0处理
local function onFinishUses(inst, pos, caster)
  local owner = inst.components.inventoryitem.owner or nil
  if owner ~= nil then
    RemoveOwnerAttribute(inst, owner)
    owner.components.talker:Say(STRINGS.NAMES.EXHAUST)
  end
  turnOffLight(inst)
	return
end

local function OnSave(inst, data)
  for index, value in ipairs(inst.gary_amulet_level_table) do
    if data ~= nil and inst[value] ~= nil then
      data[value] = inst[value]
    else
      data[value] = 0
    end
  end
end

local function OnLoad(inst, data)
  for index, value in ipairs(inst.gary_amulet_level_table) do
    if data ~= nil and data[value] ~= nil then
      inst[value] = data[value]
    else
      inst[value] = 0
    end
  end
  inst.components.finiteuses:SetMaxUses(inst.gary_amulet_BaseUses + inst.gary_amulet_level*inst.gary_amulet_Parameter)
end

local function onUse(inst)
  local user = inst.components.inventoryitem.owner or nil
  if user then
    local MaxHunger = user.components.hunger.max
    local CurrentHunger = user.components.hunger.current
    local CostHunger = math.min(MaxHunger-CurrentHunger, inst.gary_amulet_hungervalue_Use)
    if CostHunger < 1 then
      user.components.talker:Say(STRINGS.NAMES.EAT_FULL)
    elseif inst.components.finiteuses:GetUses() > CostHunger then
      inst.components.finiteuses:Use(CostHunger)
      user.components.hunger:DoDelta(CostHunger)
      user.components.talker:Say(STRINGS.NAMES.EAT)
      inst.AnimState:PlayAnimation("hit")
    else
      user.components.talker:Say(STRINGS.NAMES.EAT_FALL)
    end
  end
  --使用冷却
  inst:DoTaskInTime(0.1,function()			
		if inst.components.useableitem ~= nil then
			inst.components.useableitem.inuse = false
		end
	end)
end

local function fn()
  local inst = commonfn("gary_amulet", "gary_amulet", false, true)
  -- trader (from trader component) added to pristine state for optimization
  inst:AddTag("trader")

  if not TheWorld.ismastersim then return inst end

  inst.components.equippable:SetOnEquip(onequip_gary_amulet)
  inst.components.equippable:SetOnUnequip(onunequip_gary_amulet)
  inst.components.equippable:SetOnEquipToModel(onequiptomodel_gary_amulet)

  
  --使用回复的饱食度
  inst.gary_amulet_hungervalue_Use = 50
  --物品等级（影响耐久度）, by gary
  inst.gary_amulet_level = 0
  inst.gary_amulet_Parameter = GetModConfigData("gary_amulet_durability_parameter", gary_amulet_modname)
  inst.gary_amulet_BaseUses = GetModConfigData("gary_amulet_durability", gary_amulet_modname)
  --最大生命值
  inst.gary_amulet_level_MaxHealth = 0 --等级
  inst.gary_amulet_Parameter_MaxHealth = GetModConfigData("gary_amulet_maxhealth_ratio", gary_amulet_modname) --成长率
  inst.gary_amulet_health_regan_ratio = GetModConfigData("gary_amulet_health_regan_ratio", gary_amulet_modname) --成长率
  --减伤等级
  inst.gary_amulet_level_DamageAbsorb = 0 --等级
  inst.gary_amulet_Parameter_DamageAbsorb = GetModConfigData("gary_amulet_damage_absorb_parameter", gary_amulet_modname) --成长率
  inst.gary_amulet_Consume_DamageAbsorb = GetModConfigData("gary_amulet_damage_absorb_consume", gary_amulet_modname) --每级额外耐久消耗/每周期
  --生命回复等级
  inst.gary_amulet_level_HealthRegen = 0 --等级
  inst.gary_amulet_Parameter_HealthRegen = GetModConfigData("gary_amulet_health_regen_speed", gary_amulet_modname) --成长率
  inst.gary_amulet_Consume_HealthRegen = GetModConfigData("gary_amulet_health_regen_consume", gary_amulet_modname) --回复一点生命消耗多少耐久
  --基础伤害倍率等级
  inst.gary_amulet_level_DamageMultiple = 0 --等级
  inst.gary_amulet_Parameter_DamageMultiple = GetModConfigData("gary_amulet_damage_multiplie_parameter", gary_amulet_modname) --成长率
  inst.gary_amulet_Consume_DamageMultiple = GetModConfigData("gary_amulet_damage_multiplie_consume", gary_amulet_modname) --每级额外耐久消耗/每周期
  --位面伤害等级
  inst.gary_amulet_level_DamagePlanar = 0 --等级
  inst.gary_amulet_Parameter_DamagePlanar = GetModConfigData("gary_amulet_damage_planar_parameter", gary_amulet_modname) --成长率
  inst.gary_amulet_Consume_DamagePlanar = GetModConfigData("gary_amulet_damage_planar_consume", gary_amulet_modname) --每级额外耐久消耗/每周期
  --作祟复活次数
  inst.gary_amulet_level_REZ = 1 --作祟复活次数
  inst.gary_amulet_Consume_REZ = GetModConfigData("gary_amulet_haunt_consume", gary_amulet_modname) --作祟复活消耗
  --耐久周期回复
  inst.gary_amulet_level_PeriodicRepair = 0 --等级
  inst.gary_amulet_parameter_PeriodicRepair = GetModConfigData("gary_amulet_living_tissue_parameter", gary_amulet_modname) --每级抵扣耐久消耗/每周期
  inst.gary_amulet_living_tissue_probability = GetModConfigData("gary_amulet_living_tissue_probability", gary_amulet_modname) --活性组织掉落率
  --耐久自然消耗
  inst.gary_amulet_PeriodicTime = 4 --n秒回复一次，480秒一天
  inst.gary_amulet_PeriodicConsume = GetModConfigData("gary_amulet_health_regan_ratio", gary_amulet_modname) --每周期自然消耗耐久度，乘以120即为每天消耗量

  inst.gary_amulet_level_table = {"gary_amulet_level",
                                  "gary_amulet_level_MaxHealth",
                                  "gary_amulet_level_DamageAbsorb",
                                  "gary_amulet_level_HealthRegen",
                                  "gary_amulet_level_DamageMultiple",
                                  "gary_amulet_level_DamagePlanar",
                                  "gary_amulet_level_PeriodicRepair",
                                  "gary_amulet_level_REZ",
                                  }

  --移动速度
  inst.components.equippable.walkspeedmult = 1.2
  --发光
  inst._light = nil

  inst.OnSave = OnSave
  inst.OnPreLoad = OnLoad

  inst:AddComponent("trader")
  --inst:AddComponent("named")
  inst.components.trader:SetAcceptTest(ItemTradeTest)
  inst.components.trader.onaccept = OnItemGiven
  inst.components.trader.onrefuse = onRefuseItem
  

	--耐久功能
  inst:AddComponent("finiteuses")
  inst.components.finiteuses:SetMaxUses(inst.gary_amulet_BaseUses)
  inst.components.finiteuses:SetUses(inst.gary_amulet_BaseUses)
  inst.components.finiteuses:SetOnFinished(onFinishUses)
  inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(onUse)

  --[[
  inst:AddComponent("armor")
  inst.components.armor:InitCondition(1000, 0.5)
  inst.components.armor.keeponfinished=true
  -- hack to check condition>0, otherwise cannot resist
  local old = inst.components.armor.CanResist
  inst.components.armor.CanResist = function(self, ...)
    if self.condition <= 0 then return false end
    return old(self, ...)
  end
  ]]--

  inst:AddComponent("hauntable")
  inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
  inst.components.hauntable:SetOnHauntFn(OnHaunt)

  inst:AddComponent("named")
  inst.components.named:SetName(STRINGS.NAMES.ANCIENT_AMULET .. "\n" .. STRINGS.NAMES.BONUS ..
  "\n" .. STRINGS.NAMES.BONUS_HEALTH .. ":0" .. 
  -- "\n额外伤害减免:" ..inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb/(100 + inst.gary_amulet_level_DamageAbsorb*inst.gary_amulet_Parameter_DamageAbsorb) ..
  "\n" .. STRINGS.NAMES.BONUS_ABSORB .. ":0%" ..
  "\n" .. STRINGS.NAMES.BONUS_REGAN .. ":0" .. 
  "\n" .. STRINGS.NAMES.BONUS_MULTIPLE .. ":0%" ..
  "\n" .. STRINGS.NAMES.BONUS_PLANAR .. ":0" .. 
  "\n" .. STRINGS.NAMES.BONUS_REZ .. ":1" ..
  "\n" .. STRINGS.NAMES.BONUS_CONSUME .. ":60")
  return inst
end

--发光
local function gary_amulet_lightfn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddLight()
  inst.entity:AddNetwork()

  inst:AddTag("FX")

  inst.Light:SetRadius(2)
  inst.Light:SetFalloff(.7)
  inst.Light:SetIntensity(.65)
  inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
      return inst
  end

  inst.persists = false

  return inst
end

return Prefab("gary_amulet", fn, assets),
       Prefab("gary_amulet_light", gary_amulet_lightfn)
