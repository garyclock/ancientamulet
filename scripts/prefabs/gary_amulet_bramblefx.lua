local assets =
{
    Asset("ANIM", "anim/gary_amulet_bramblefx.zip"),
    Asset("ANIM", "anim/gary_amulet_pocketwatch_weapon_fx.zip"),
}

--DSV uses 4 but ignores physics radius
local MAXRANGE = 3
local NO_TAGS_NO_PLAYERS =	{ "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "player", "companion" }
local NO_TAGS =				{ "INLIMBO", "notarget", "noattack", "flight", "invisible", "wall", "playerghost" }
local COMBAT_TARGET_TAGS = { "_combat" }

local function OnUpdateThorns(inst)
    -- inst.range = inst.range + .75
    -- inst.range = inst.range + 7.5
    -- inst.damage = inst.owner.components.health.maxhealth

    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, inst.range + 3, COMBAT_TARGET_TAGS, inst.canhitplayers and NO_TAGS or NO_TAGS_NO_PLAYERS)) do
        if not inst.ignore[v] and
            v:IsValid() and
            v.entity:IsVisible() and
            v.components.combat ~= nil then
            local range = inst.range + v:GetPhysicsRadius(0)
            if v:GetDistanceSqToPoint(x, y, z) < range * range then
                if inst.owner ~= nil and not inst.owner:IsValid() then
                    inst.owner = nil
                end
                if inst.owner ~= nil then
					if inst.owner.components.combat ~= nil and
						inst.owner.components.combat:CanTarget(v) and
						not inst.owner.components.combat:IsAlly(v)
					then
                        inst.ignore[v] = true
						v.components.combat:GetAttacked(v.components.follower and v.components.follower:GetLeader() == inst.owner and inst or inst.owner, inst.damage, nil, nil, nil)
                        --V2C: wisecracks make more sense for being pricked by picking
                        --v:PushEvent("thorns")
                    end
                elseif v.components.combat:CanBeAttacked() then
                    -- NOTES(JBK): inst.owner is nil here so this is for non worn things like the bramble trap.
					local isally = false
					if not inst.canhitplayers then
						--non-pvp, so don't hit any player followers (unless they are targeting a player!)
						local leader = v.components.follower ~= nil and v.components.follower:GetLeader() or nil
						isally = leader ~= nil and leader:HasTag("player") and
							not (v.components.combat ~= nil and
								v.components.combat.target ~= nil and
								v.components.combat.target:HasTag("player"))
					end
					if not isally then
						inst.ignore[v] = true
						v.components.combat:GetAttacked(inst, inst.damage, nil, nil, nil)
						--v:PushEvent("thorns")
					end
                end
            end
        end
    end

    if inst.range >= MAXRANGE then
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateThorns)
    end
end

local function SetFXOwner(inst, owner)
    inst.Transform:SetPosition(owner.Transform:GetWorldPosition())
    inst.owner = owner
    inst.canhitplayers = not owner:HasTag("player") or TheNet:GetPVPEnabled()
    inst.ignore[owner] = true
    inst.damage = owner.components.health.maxhealth * 0.1
end

local function MakeFX(name, anim, damage, planardamage)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        if planardamage then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end

        inst:AddTag("FX")
        inst:AddTag("thorny")
        if name == "bramblefx_trap" then
            inst:AddTag("trapdamage")
        end

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("pocketwatch_weapon_fx")
        inst.AnimState:SetBuild("pocketwatch_weapon_fx")
        inst.AnimState:SetScale(2.5, 2.5, 2.5)

        -- 使用math.random选择一个随机数，然后根据这个数选择对应的动画
        local randomEffect = math.random(1, 3)
        local animationName = "idle_big_" .. randomEffect  -- 生成动画名称字符串，如 "idle_big_1", "idle_big_2" 或 "idle_big_3"

        -- inst.AnimState:PlayAnimation("idle_big_3")
        inst.AnimState:PlayAnimation(animationName)

        inst:SetPrefabNameOverride("pocketwatch_weapon_fx")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateThorns)

        inst:ListenForEvent("animover", inst.Remove)
        inst.persists = false
        -- inst.damage = TUNING[damage]
        -- inst.damage = 233
        
		-- inst.spdmg = planardamage and { planar = TUNING[planardamage] } or nil
        inst.range = 5
        inst.ignore = {}
        inst.canhitplayers = true
        --inst.owner = nil

        inst.SetFXOwner = SetFXOwner
    
        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeFX("gary_amulet_bramblefx_armor", "idle", "ARMORBRAMBLE_DMG" --[[TUNING.ARMORBRAMBLE_DMG]]),
    MakeFX("gary_amulet_bramblefx_armor_upgrade", "idle", "ARMORBRAMBLE_DMG", "ARMORBRAMBLE_DMG_PLANAR_UPGRADE"--[[TUNING.ARMORBRAMBLE_DMG]]),
    MakeFX("gary_amulet_bramblefx_trap", "trap", "TRAP_BRAMBLE_DAMAGE"--[[TUNING.TRAP_BRAMBLE_DAMAGE]])
