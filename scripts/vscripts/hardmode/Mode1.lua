--这个是专门调整难度的文件，由玩家的选择之后被调用
--这里分别更改了每一轮怪物的个数
--升级所需要的经验
--物品掉落KV的关联

_G.hardmode = 1--普通难度

--每一关有三类怪，A类视为队长，通常只有一个，爆率更高，B类为辅助和配合的小兵，C类为召唤物

ROUND_UNITS=
    {--01-05
    5,1,nil,    10,10,1,    10,1,nil,   2,1,nil,    1,nil,nil,
    ---06-10
    3,8,1,      1,5,nil,    1,7,2,      1,6,nil,    1,nil,nil,
    ---11-15
    9,1,nil,    3,1,6,      1,6,nil,    7,1,nil,    1,nil,nil,
    ---16-20
    7,1,nil,    1,9,nil,    1,9,nil,    1,9,nil,    1,nil,nil,
    ---21-25
    8,1,1,      4,1,1,      5,1,1,      5,1,1,      1,nil,nil,
    ---26-20
    8,1,1,      8,1,1,      8,1,1,      4,1,1,      1,nil,nil,
    ---31-35
    1,1,2,      1,1,6,      1,1,4,      1,1,8,      1,nil,nil,
    ---36-40
    1,5,nil,    1,5,nil,    1,4,nil,    1,9,nil,    1,nil,nil,
    ---41-45
    1,5,nil,    1,4,nil,    1,5,nil,    1,5,nil,    1,nil,nil,
    ---46-50
    1,4,nil,    1,9,nil,    1,7,nil,    1,3,6,      1,nil,nil,
    }

--几级就是几百的经验，10级需要1000的经验升级
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
    XP_PER_LEVEL_TABLE[i] = i * 100
end

--爆率设置
GameRules.DropTable = LoadKeyValues("scripts/kv/item_drops_1.kv")

--出门的球，编写有误，写好了就删掉OnNPCSpawned里面的发球
--建立一个表单，做一个循环，，随机一个数，在表单里加入，上传表单
value = {}
bbbbbb = {1,2,3,4,5,6,7,8,9,10}
for i =1,10 do
    local elindoor = RandomInt( 1, #bbbbbb )--在bbbbbb按个数随机一个序号
    value[bbbbbb[elindoor]] = 1             --这个序号在bbbbbb里面指向的值作为value的key,指向为1，也就是该KEY对应的球有1个
    table.remove(bbbbbb, elindoor)          --在bbbbbb里面移掉刚刚的数字
end
function SetTableValue(plc)
CustomNetTables:SetTableValue("Elements_Tabel",tostring(plc),value)
plc:AddNewModifier(plc, nil, "modifiers/modifier_mode1", {})

end