name = "Ancient Amulet"
description = [[
Add an amulet that can give you multiple abilities, useful in all game stages.
]]
author = "Gary Clock"
version = "0.97"
forumthread = ""

api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

reign_of_giants_compatible = true
dont_starve_compatible = true

all_clients_require_mod = true

client_only_mod = false

dst_compatible = true

configuration_options = {
	{name = "",
	label = "语言 Language",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_language",
		label = "language",
		hover = "language",
		options = {
			{ description = "English",  data = "strings_ENG.lua" },
			{ description = "中文",  data = "strings_CHN.lua" },
		},
		default = "strings_CHN.lua"
	},

	{name = "",
	label = "基本属性",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_durability",
		label = "初始耐久度",
		hover = "远古护符的初始耐久上限",
		options = {
			{ description = "120",  data = 120 },
			{ description = "240 (default)",  data = 240 },
			{ description = "360",  data = 360 },
			{ description = "480",  data = 480 },
			{ description = "600",  data = 600 },
			{ description = "720",  data = 720 },
			{ description = "999",  data = 999 },
		},
		default = 240
	},
    {
		name = "gary_amulet_durability_parameter",
		label = "耐久度成长值",
		hover = "每级提供的远古护符最大耐久度（饱食度）加成",
		options = {
			{ description = "10",  data = 10 },
			{ description = "20 (default)",  data = 20 },
			{ description = "30",  data = 30 },
			{ description = "40",  data = 40 },
			{ description = "50",  data = 50 },
			{ description = "60",  data = 60 },
			{ description = "90",  data = 4 },
			{ description = "120",  data = 4 },
		},
		default = 20
	},
    {
		name = "gary_amulet_basic_consuming",
		label = "基础饱食消耗",
		hover = "远古护符的初始饱食度消耗速率",
		options = {
			{ description = "每天0点",  data = 0 },
			{ description = "每天30点",  data = 0.25 },
			{ description = "每天60点 (default)",  data = 0.5 },
			{ description = "每天90点",  data = 0.75 },
			{ description = "每天120点",  data = 1 },
			{ description = "每天150点",  data = 1.25 },
			{ description = "每天180点",  data = 1.5 },
		},
		default = 0.5
	},
    {
		name = "gary_amulet_living_tissue_probability",
		label = "活性组织掉落率",
		hover = "4000血以上的强大生物掉落活性组织的概率",
		options = {
			{ description = "0%",  data = 0 },
			{ description = "1%",  data = 0.01 },
			{ description = "3%",  data = 0.03 },
			{ description = "5% (default)",  data = 0.05 },
			{ description = "10%",  data = 0.1 },
			{ description = "20%",  data = 0.2 },
			{ description = "50%",  data = 0.5 },
			{ description = "100%",  data = 1 },
		},
		default = 0.05
	},
    {
		name = "gary_amulet_living_tissue_parameter",
		label = "饱食消耗减免",
		hover = "吞噬的每个活性组织为远古护符提供的饱食度消耗速率减免",
		options = {
			{ description = "每天15点",  data = 0.125 },
			{ description = "每天30点 (default)",  data = 0.25 },
			{ description = "每天60点",  data = 0.5 },
			{ description = "每天75点",  data = 0.625 },
			{ description = "每天90点",  data = 0.75 },
			{ description = "每天120点",  data = 1 },
			{ description = "每天150点",  data = 1.25 },
			{ description = "每天180点",  data = 1.5 },
			{ description = "每天240点",  data = 2 },
		},
		default = 0.5
	},

	{name = "",
	label = "最大生命值",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_maxhealth_ratio",
		label = "生命加成转化率",
		hover = "吞噬回血食物时，将一定比例的食物回血量转化为最大生命值加成",
		options = {
			{ description = "0.5%",  data = 0.005 },
			{ description = "1% (default)",  data = 0.01 },
			{ description = "2%",  data = 0.02 },
			{ description = "5%",  data = 0.05 },
			{ description = "10%",  data = 0.1 },
			{ description = "100%",  data = 1 },
		},
		default = 0.01
	},
	{
		name = "gary_amulet_health_regan_ratio",
		label = "生命回复共享率",
		hover = "吞噬回血食物时，人物也回复一定比例的食物回血量",
		options = {
			{ description = "20%",  data = 0.2 },
			{ description = "40%",  data = 0.4 },
			{ description = "60%",  data = 0.6 },
			{ description = "80%",  data = 0.8 },
			{ description = "100% (default)",  data = 1.0 },
		},
		default = 1.0
	},

    {name = "",
	label = "生命回复",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_health_regen_speed",
		label = "生命回复成长率",
		hover = "每级提供的生命回复量（每四秒）",
		options = {
			{ description = "0.1",  data = 0.1 },
			{ description = "0.5",  data = 0.5 },
			{ description = "1 (default)",  data = 1 },
			{ description = "1.5",  data = 1.5 },
			{ description = "2",  data = 2 },
			{ description = "4",  data = 4 },
		},
		default = 1
	},
    {
		name = "gary_amulet_health_regen_consume",
		label = "生命回复消耗",
		hover = "回复1点生命值时消耗的远古护符耐久度（饱食度）",
		options = {
			{ description = "0",  data = 0 },
			{ description = "1",  data = 1 },
			{ description = "2",  data = 2 },
			{ description = "3 (default)",  data = 3 },
			{ description = "4",  data = 4 },
		},
		default = 3
	},

    {name = "",
	label = "伤害减免",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_damage_absorb_parameter",
		label = "伤害减免成长率",
		hover = "每级提供的伤害减免加成（会衰减，随等级提高无限逼近100%）",
		options = {
			{ description = "2%",  data = 2 },
			{ description = "5%",  data = 5 },
			{ description = "10% (default)",  data = 10 },
			{ description = "15%",  data = 15 },
			{ description = "20%",  data = 20 },
			{ description = "30%",  data = 30 },
			{ description = "40%",  data = 40 },
			{ description = "50%",  data = 50 },
		},
		default = 10
	},
    {
		name = "gary_amulet_damage_absorb_consume",
		label = "每级额外消耗",
		hover = "每级伤害吸收额外增加的远古护符耐久消耗（每日口粮）",
		options = {
			{ description = "每天12点",  data = 0.1 },
			{ description = "每天24点 (default)",  data = 0.2 },
			{ description = "每天36点",  data = 0.3 },
			{ description = "每天48点",  data = 0.4 },
			{ description = "每天60点",  data = 0.5 },
		},
		default = 0.2
	},

    {name = "",
	label = "普通伤害加成",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_damage_multiplie_parameter",
		label = "伤害加成成长率",
		hover = "每级提供的普通伤害加成",
		options = {
			{ description = "2%",  data = 0.02 },
			{ description = "5%",  data = 0.05 },
			{ description = "10% (default)",  data = 0.10 },
			{ description = "15%",  data = 0.15 },
			{ description = "20%",  data = 0.20 },
			{ description = "30%",  data = 0.30 },
			{ description = "40%",  data = 0.40 },
			{ description = "50%",  data = 0.50 },
		},
		default = 0.1
	},
    {
		name = "gary_amulet_damage_multiplie_consume",
		label = "每级额外消耗",
		hover = "每级伤害加成额外增加的远古护符耐久消耗（每日口粮）",
		options = {
			{ description = "每天0点",  data = 0 },
			{ description = "每天3点",  data = 0.025 },
			{ description = "每天6点",  data = 0.05 },
			{ description = "每天7.5点 (default)",  data = 0.0625 },
			{ description = "每天9点",  data = 0.075 },
			{ description = "每天12点",  data = 0.1 },
			{ description = "每天15点",  data = 0.125 },
		},
		default = 0.0625
	},

    {name = "",
	label = "位面伤害",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_damage_planar_parameter",
		label = "位面伤害成长率",
		hover = "每级提供的额外位面伤害点数（只对位面武器有效）",
		options = {
			{ description = "0.1",  data = 0.1 },
			{ description = "0.2",  data = 0.2 },
			{ description = "0.5",  data = 0.5 },
			{ description = "1 (default)",  data = 1 },
			{ description = "2",  data = 2 },
			{ description = "3",  data = 3 },
			{ description = "4",  data = 4 },
			{ description = "5",  data = 5 },
		},
		default = 1
	},
    {
		name = "gary_amulet_damage_planar_consume",
		label = "每级额外消耗",
		hover = "每级位面伤害加成额外增加的远古护符耐久消耗（每日口粮）",
		options = {
			{ description = "每天0点",  data = 0 },
			{ description = "每天3点 (default)",  data = 0.025 },
			{ description = "每天6点",  data = 0.05 },
			{ description = "每天7.5点",  data = 0.0625 },
			{ description = "每天9点",  data = 0.075 },
			{ description = "每天12点",  data = 0.1 },
			{ description = "每天15点",  data = 0.125 },
		},
		default = 0.025
	},

    {name = "",
	label = "作祟复活",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
	{
		name = "gary_amulet_haunt_consume",
		label = "复活耐久消耗",
		hover = "通过作祟远古护符复活时额外消耗的护符耐久度（饱食度，不足仍能复活）",
		options = {
			{ description = "0",  data = 0 },
			{ description = "60 (default)",  data = 60 },
			{ description = "75",  data = 75 },
			{ description = "120",  data = 120 },
			{ description = "180",  data = 180 },
			{ description = "240",  data = 240 },
		},
		default = 60
	},

}