--code:2014-7-30

local layer  	=  import('world.layer');
local battle    =  import( 'game_logic.battle' )
local camera_mgr=  import( 'game_logic.camera_mgr' )
damage_effect   =  lua_class("damage_effect", layer.layer)

local _opacity  = 255

local _top = 300
local _dis = 100
local _one 		= 1
local _two  	= 2
local _three 	= 3  --暴击
local _four 	= 4  --出血
local _five		= 5  --仙子加血
local _six		= 6  --回蓝
local _zorder   = ZEffect
local _bezier   = nil
local _res_path = {'fonts/miss.png', 'fonts/score.fnt', 'fonts/score_b.fnt', 'fonts/score_s.fnt', 'fonts/score_g.fnt', 'fonts/score_g.fnt'}

function damage_effect:_init()
	super(damage_effect, self)._init()
end 

function damage_effect:is_miss(pos, direction)
	-- self.miss_texture = cc.Director:getInstance():getTextureCache():addImage(_res_path[_one])
	-- local miss  = cc.Sprite:createWithTexture(self.miss_texture)
	local miss = cc.Sprite:create(_res_path[_one])
	
	self.cc:addChild(miss)
	miss:setLocalZOrder(_zorder)

	self:run_action(miss, pos, direction)
end


-- eff_table = {type=eff_type, pos=hit_e:get_world_pos(), direction = _direction, damage=combat_damage}
function damage_effect:show_effect(eff_table)

	if (math.floor(eff_table.damage.total)) == 0 then
		self:is_miss(eff_table.pos, eff_table.direction)
		return true
	end

	if eff_table.damage.is_crit == true then -- 暴击
		self:is_crit(eff_table.pos, eff_table.damage.total, eff_table.direction)
	else
		self:is_hit(eff_table.pos, eff_table.damage.total, eff_table.direction, eff_table.type)
	end
end

function damage_effect:is_hit(pos, damage_total, direction, eff_type) -- 被打

	local damage_label = cc.Label:createWithBMFont(_res_path[eff_type],"")
	damage_label:setVisible(true)
	damage_label:setString(math.floor(damage_total))
	damage_label:setOpacity(_opacity)
	self.cc:addChild(damage_label)
	self.cc:setLocalZOrder(_zorder)
	if eff_type == _five or eff_type == _six then
		print(' plain action ')
		self:plain_action(damage_label, pos)
	else
		self:run_action(damage_label, pos, direction)
	end
end

function damage_effect:is_crit(pos, damage_total, direction) -- 暴击
	local crit_label = cc.Label:createWithBMFont(_res_path[_three],"")
	crit_label:setLocalZOrder(_zorder)
	crit_label:setString(math.floor(damage_total));
	self.cc:addChild(crit_label)
	self.cc:setLocalZOrder(_zorder)
	self:run_action(crit_label, pos, direction)
end 

function damage_effect:run_action(ac_node, pos, direction)

    local random  = math.random(-30, 30)
    
	if  direction == -1  then
		--向左掉血
        ac_node:setPosition(cc.p(pos.x + random,  pos.y + 180 + random))
      	_bezier = {cc.p(pos.x + random,  pos.y + 180 + random), cc.p(pos.x + random - _dis, pos.y + 180 + random + 50),
			cc.p(pos.x + random - _dis, pos.y + 180 + random - 100)}
	elseif direction == 1 then
		--向右掉血
	 	 ac_node:setPosition(cc.p(pos.x + random,  pos.y + 180 + random))
      	_bezier = {cc.p(pos.x + random,  pos.y + 180 + random), cc.p(pos.x + random + _dis, pos.y + 180 + random + 50),
			cc.p(pos.x + random + _dis, pos.y + 180 + random - 100)}
	else
		-- 上方加血
		ac_node:setPosition(cc.p(pos.x,  pos.y + _top + random))
      	_bezier = {cc.p(pos.x,  pos.y + _top + random), cc.p(pos.x, pos.y + _top + random + 50),
			cc.p(pos.x, pos.y + _top + random + 70)}
	end

    ac_node:setScale(0.5)
	local scale_big   = cc.ScaleTo:create(0.1, 1.5);
    local scale_lit   = cc.ScaleTo:create(0.1, 1)
  
	local bezier_line = cc.BezierTo:create(0.8, _bezier)
    local ac_sequ     = cc.Sequence:create(cc.FadeIn:create(0.6), cc.FadeOut:create(0.1))
    local sca_seq     = cc.Sequence:create(scale_big, scale_lit)
    local spawn       = cc.Spawn:create(sca_seq, ac_sequ, bezier_line)
	local function remove()
		self.cc:removeChild(ac_node, true)
	end 
	local ease = cc.EaseSineOut:create(spawn)
  
	ac_node:runAction(cc.Sequence:create(ease, cc.CallFunc:create(remove)))
end 

function damage_effect:plain_action(ac_node, pos)

    local random  = math.random(-20, 10)
	ac_node:setPosition(pos.x,  pos.y + _top + random - 70)

    ac_node:setScale(0.6)
	local move_to 		= cc.MoveBy:create(0.6, cc.p(0, 50))
    local ac_sequ		= cc.Sequence:create(cc.FadeIn:create(0.4), cc.FadeOut:create(0.2))
	local zooom			= cc.Sequence:create(cc.ScaleTo:create(0.4, 1.2), cc.ScaleTo:create(0.2, 1))
	local spawn			= cc.Spawn:create(move_to, ac_sequ, zooom)
	local function remove()
		self.cc:removeChild(ac_node, true)
	end 
	local ease = cc.EaseSineOut:create(spawn)
  
	ac_node:runAction(cc.Sequence:create(ease, cc.CallFunc:create(remove)))
end 

function damage_effect:remove(id)
	--self.cc:removeChildByTag(id);
end 

function damage_effect:release()
end


