GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})
AddRecipe2("gary_amulet", {Ingredient("thulecite", 3), Ingredient("moonglass", 8), 
                            Ingredient("nightmarefuel", 8), Ingredient("amulet", 1), 
                            Ingredient("yellowamulet", 1)},
  TECH.MAGIC_THREE,{}, {"MAGIC"})

modimport("scripts/languages/" .. GetModConfigData("gary_amulet_language", KnownModIndex:GetModActualName("Ancient Amulet")))
--modimport("scripts/languages/strings_CHN.lua")

RegisterInventoryItemAtlas("images/gary_amulet.xml", "gary_amulet.tex")
RegisterInventoryItemAtlas("images/gary_amulet.xml", hash("gary_amulet.tex"))
STRINGS.NAMES.gary_amulet = "远古项链 Ancient Amulet"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARY_AMULET = "它在动？"

STRINGS.NAMES.GARY_AMULET_LIVING_TISSUE = "活性组织"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GARY_AMULET_LIVING_TISSUE = "从强大生物上分离的组织，能为远古护符提供能量"

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
    {"nothing_1", "金块"}, 
    {"purebrilliance", "纯粹辉煌"}, 
    {"horrorfuel", "纯粹恐惧"}, 
   }

local function addtradabletage(item_name)
  AddPrefabPostInit(item_name,function(inst)
    if not GLOBAL.TheNet:GetIsServer() then
      return
    end
    if not inst.components.tradable then
      inst:AddComponent("tradable")
      end
  end)
end

for _, item in ipairs(UpgradeItems) do
  addtradabletage(item[1])
end

for _, item in ipairs(SingleUseItems) do
  addtradabletage(item[1])
end

PrefabFiles={
             "gary_amulet",
             "gary_amulet_living_tissue",
             "gary_amulet_buff_hungerregen",
             "gary_amulet_buff_attackrange",
             "gary_amulet_buff_areaattack",
             "gary_amulet_bramblefx",
            }