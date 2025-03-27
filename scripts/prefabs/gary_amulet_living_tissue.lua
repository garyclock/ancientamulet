local assets =
{
    Asset("ANIM", "anim/gary_amulet_living_tissue.zip"),
    Asset("IMAGE", "images/gary_amulet_living_tissue.tex"),
    Asset("ATLAS", "images/gary_amulet_living_tissue.xml"),
    Asset("ATLAS_BUILD", "images/gary_amulet_living_tissue.xml", 256)
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gary_amulet_living_tissue")
    inst.AnimState:SetBuild("gary_amulet_living_tissue")
    inst.AnimState:PlayAnimation("idle")

    -- inst.pickupsound = "wood"


    MakeInventoryFloatable(inst, "med", 0.05, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
    MakeMediumPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/gary_amulet_living_tissue.xml"

    return inst
end

return Prefab("gary_amulet_living_tissue", fn, assets)
