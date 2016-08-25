-- scene
ChangeSceneDelay	= 0.5	-- 场景切换延时

-- battle
JumpSpeed		= 10
AutoAttX		= 150 	-- 自动攻击距离x轴（玩家到受击盒边界距离）
AutoAttY		= 100 	-- 自动攻击距离y轴（玩家到受击盒边界距离）
AttackCount		= 3 	-- 同一帧最大攻击数量
DotFormula		= loadstring('ans = -b.max_hp*0.03') 	-- buff掉血小于此值进入受击
StarSpace		= 1000 	-- 根据battle_id 算出 star_id : star_id = chapter_id * StarSpace + fuben_id

-- entity
RunSpeed		= 80 	-- 移动速度 
FallGroundYSpeed = 130


-- state config
InfiniteTime	= 18000		-- 5 mins

MonsterAlertLevel = 185


HitIdleStateOrder              = {'death','fall_ground', 'fly_hit', 'hit_fly','hit', 'idle',}
GroundMonsterDefaultStateOrder = {'death','fall_ground', 'fly_hit', 'hit_fly',{ 'attack', 'attack2','attack3', 'skill' ,'skill2','skill3',},'hit',  'run','idle', }
AirMonsterDefaultStateOrder    = {'death','hit', { 'attack', 'attack2', 'skill' ,'skill2',}, 'run','idle', }
BossDefaultStateOrder          = {'death',{ 'attack', 'attack2','attack3', 'skill' ,'skill2','skill3',}, 'hit', 'run','idle', }
BossHumanDefaultStateOrder     = {'death','fall_ground', 'fly_hit', 'hit_fly',{ 'attack', 'attack2','attack3', 'skill' ,'skill2','skill3',}, 'hit', 'run','idle', }

BubbleDialogueFrameColor={cc.c3b(0,0,0),150}
BubbleDialogueFontColor=cc.c3b(255,255,255)
BubbleDialogueFontType='fonts/msyh.ttf'
BubbleDialogueFontSize=18

BasicFormula	= loadstring('d = a.attack*(1-b.def_rate)*(1+crit()*0.5)')


--FightingCapacityFormula = loadstring('fc = a.attack*(1+a.crit_rate*0.5) + a.max_hp/(1-a.def_rate)/4')
FightingCapacityFormula = loadstring('fc = a.attack * 0.75 + a.crit_level * 1.17 + a.max_hp * 0.2 + a.defense * 0.95')
SkillFightingCapacityFormula = loadstring('fc = s.fc_factor*s.star*(s.f_att+s.i_att+s.n_att+s.f_def+s.i_def+s.n_def)')