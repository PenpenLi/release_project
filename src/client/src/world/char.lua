local music_mgr		= import( 'world.music_mgr' )
local bubble_dialog 	= import( 'ui.bubble_dialog.bubble_dialog' ) 
local fast_actions		= import( 'utils.actions' )

char = lua_class( 'char' )

function char:_init( model )
	self.cc = cc.Sprite:create()
	self.loaded_json = {}
	
	self.say_id = nil
	self.dialog = nil
	self.dialog_con = nil

	self.anim_flipped = model.anim_flipped
	self.default_hit_box = model.default_hit_box

	self.pause_count = 0
	if model.default_anim ~= nil then
		self.def_anim = model.default_anim
	else
		self.def_anim = nil
	end
	if model.equip_conf ~= nil then
		self.equip_conf = model.equip_conf
	else
		self.equip_conf = {}
	end
	self:setup_armatrue(model)
	self.scale_x = 1
	if model.scale_x ~= nil then
		self.scale_x = model.scale_x
	end
	self.playing = nil

	music_mgr.preload_role_sound(model)
	-- position
	-- self.cc:setPosition(0, -50)
	self.particle_add_count=0
	--self:shapeshifting()
	self.temp_effect = {}

	if model.default_fade ~= nil then
		self.cc:setCascadeOpacityEnabled(true)
		self.cc:setOpacity(model.default_fade)
	end
end

function char:setup_armatrue(model)
	if model.json == nil then
		return
	end
	self.json = model.json
	self.ejson = model.ejson
	if model.aname == nil then
		self.armature_name = model.name
	else
		self.armature_name = model.aname
	end
	self:add_loaded_json(model.json)
	self.armature = ccs.Armature:create( self.armature_name )
	self.cc:addChild(self.armature)
	self.cc:setPosition(cc.p(-10000,-10000))

	if self.ejson ~= nil then
		self:add_loaded_json(model.ejson)
		self.effect_armature = ccs.Armature:create( self.armature_name )
		self.cc:addChild(self.effect_armature)
	end
end

function char:change_wing( wing, role_type )
	-- wing = {id = 1}
	if wing == nil then
		return
	else
		return
	end

	local d = data.wing[wing.id]

	if d == nil then
		return
	end

	if self.wjson ~= nil then
		ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(self.wjson)
	end

	self.wjson = d[role_type .. '_json']

	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(self.wjson)
	self.wing_armature = ccs.Armature:create( d[role_type .. '_name'] )
	-- self.wing_armature:getAnimation():play('Attack1', 80, -1)

	local bone  = ccs.Bone:create("wing_bone")
	bone:addDisplay(self.wing_armature, 0)
	bone:changeDisplayWithIndex(0, true)
	bone:setIgnoreMovementBoneData(true)
	-- bone2:setLocalZOrder(100)
	-- bone2:setScale(0.9)

	self.armature:addBone(bone,"翅膀骨骼点")
end

-- 换装
function char:change_equip(equip_conf_id, equipment)
	equip_config = data.equip[equip_conf_id]
	if equip_config == nil or equipment == nil then
		return
	end

	local confiles = equipment.data[equip_config.confield]
	if confiles ~= nil then
		for _, v in pairs(confiles) do
			self:add_loaded_json(v)
		end
	end

	for bone_name, bone_field in pairs(equip_config.skeletons) do
		local bone = self.armature: getBone(bone_name)
		local field_data = equipment.data[bone_field]
		local skin_number = 1
		if equip_config.skin_num ~= nil then
			skin_number = equip_config.skin_num[bone_name] or 1
		end
		local skin = nil

		if bone ~= nil then

			local function add_skin_to_bone( new_skin, idx )
				bone: setVisible( false )
				bone:addDisplay(new_skin, idx)
			end

			if field_data == nil then
				if skin_number ~= nil and skin_number > 1 then
					for i = 0, skin_number - 1 do
						skin = ccs.Skin: create()
						add_skin_to_bone( skin, i )
					end
				else
					skin = ccs.Skin: create()
					add_skin_to_bone( skin, 0 )
				end
			elseif type(field_data) == 'string' then
				skin = ccs.Skin:createWithSpriteFrameName(field_data)
				add_skin_to_bone( skin, 0 )
			else
				local temp_idx = 0
				for k, v in pairs(field_data) do
					skin = ccs.Skin:createWithSpriteFrameName(v)
					add_skin_to_bone(skin, temp_idx)
					temp_idx = temp_idx + 1
				end
			end

		end
	end

	--[[
    local p1 = cc.ParticleSystemQuad:create("particles/SmallSun.plist")
    -- local p1 = cc.ParticleSystemQuad:create("skeleton/renA2/Lz-Buff-Z03.plist")
	p1:setPositionType(cc.POSITION_TYPE_FREE)
    local bone  = self.armature:getBone('手1')
    bone:addDisplay(p1, 0)
    bone:changeDisplayWithIndex(0, true)
	-- tolua.cast(bone:getDisplayRenderNode(), "cc.ParticleSystemQuad"):setPositionType(cc.POSITION_TYPE_RELATIVE)
	--]]
end

function char:add_loaded_json( json_file )
	if self.loaded_json[json_file] == nil then
		self.loaded_json[json_file] = 1
	else
		-- 纯统计，没什么用
		self.loaded_json[json_file] = self.loaded_json[json_file] + 1
	end
	for k, _ in pairs(self.loaded_json) do
		ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(k)
	end
end

function char:set_flipped( is_flipped )
	if is_flipped == true then
		self.cc:setScaleX(-self.scale_x)
		--更新说话
		self:update_say(is_flipped)
	else
		self.cc:setScaleX(self.scale_x)
		--更新说话
		self:update_say(is_flipped)
	end
end

-- 播放默认动画
function char:play_def_anim()
	if self.def_anim == nil then
		return
	end
	self:do_play(self.def_anim)
end

function char:play_anim( anim )
	-- self.cc:stopAllActions()
	if anim == nil then 
		return
	elseif anim.name ~= nil then
		self:do_play(anim)
	else
		local anim_count = #anim
		local random_idx = math.random(anim_count)
		self:do_play(anim[random_idx])
	end

	--[[
	local bone = self.armature:getBone('Layer2')
	if bone ~= nil then 
		local bone_particle = bone:getDisplayRenderNode()
		-- print( ' display node type: ::::::::::::::::::::::: ' , bone:getDisplayRenderNodeType())
	
		if bone_particle ~= nil then
			print('FREE:' .. cc.POSITION_TYPE_FREE, 'RELATIVE:' .. cc.POSITION_TYPE_RELATIVE, 'GROUPED:'.. cc.POSITION_TYPE_GROUPED )
			print(' Layer2的粒子模式：', bone_particle:getPositionType())
			local bone2  = self.armature:getBone('手1')
			if bone2 ~= nil then 
				local bone2_particle = tolua.cast(bone2:getDisplayRenderNode(), "cc.ParticleSystem")
				if bone2_particle ~= nil then
					print(' 手1的粒子模式：', bone2_particle: getPositionType())
					print(' 手1的粒子类型：', bone2: getDisplayRenderNodeType())
					if bone2_particle: getPositionType() ~= cc.POSITION_TYPE_RELATIVE then
						print(' change 手1 ')
						bone2_particle: setPositionType(cc.POSITION_TYPE_RELATIVE)
					end
				end
			end
			-- tolua.cast(bone:getDisplayRenderNode(), "cc.ParticleSystemQuad"):setPositionType(cc.POSITION_TYPE_RELATIVE)
			if bone_particle:getPositionType() ~= cc.POSITION_TYPE_RELATIVE then
				-- print(' change ~~~ ')
				bone:getDisplayRenderNode():setPositionType(cc.POSITION_TYPE_GROUPED)
				bone_particle:setVisible(false)
			end
		end
	end
	--]]

end

function char:tick()
	local bone_effect  = self.armature:getBone('特效')
	if bone_effect ~= nil then 
		local bone_effect_p = bone_effect:getDisplayRenderNode()
		if bone_effect_p ~= nil then
			bone_effect_p: setGlobalZOrder(ZEffect)
		end
	end
end

function char:do_play(anim)
	if --[[self.playing ~= anim and]] anim ~= nil and anim.name ~= nil then
		self:setup_armatrue(anim)
		self.playing = anim
		local dr = anim.duration or 1
		local begin = anim.begin or 0
		local fc = anim.framecount or 1
		local loop = -1
		if anim.loop ~= nil then
			loop = anim.loop
		end
		local speedscale = (fc-begin-1) / dr
		self.armature:getAnimation(): setSpeedScale(speedscale)
		self.armature:getAnimation(): play(anim.name, fc, loop)
		self.armature:getAnimation(): gotoAndPlay(begin)
		if anim.effect ~= nil then
			if self.ejson ~= nil then
				self.effect_armature:getAnimation():gotoAndPause(0)
			end
			local info = anim.effect
			if self.temp_effect[info.json] == nil then
				self:add_loaded_json(info.json)
				local effect = ccs.Armature:create( info.armature_name )
				self.cc:addChild(effect)
				self.temp_effect[info.json] = effect
			end
			self.temp_effect[info.json]:getAnimation(): setSpeedScale(speedscale)
			self.temp_effect[info.json]:getAnimation(): play(info.name, fc, loop)
			self.temp_effect[info.json]:getAnimation(): gotoAndPlay(begin)
		elseif self.ejson ~= nil then
			self.effect_armature:getAnimation(): setSpeedScale(speedscale)
			self.effect_armature:getAnimation(): play(anim.name, fc, loop)
			self.effect_armature:getAnimation(): gotoAndPlay(begin)
		end
		if self.wjson ~= nil then
			self.wing_armature:getAnimation(): setSpeedScale(speedscale)
			self.wing_armature:getAnimation(): play(anim.name, fc, loop)
			self.wing_armature:getAnimation(): gotoAndPlay(begin)
		end
	end
end

function char:pause_anim()
	--self.pause_count = self.pause_count + 1
	--if self.pause_count == 1 then
		self.armature: pause()
		if self.ejson ~= nil then
			self.effect_armature: pause()
		end
	--end
end

function char:resume_anim()
	--self.pause_count = self.pause_count - 1
	--if self.pause_count == 0 then
		self.armature: resume()
		if self.ejson ~= nil then
			self.effect_armature: resume()
		end
	--end
end

function char:release()
	-- cclog(debug.traceback())
	if self.ejson ~= nil then
		ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(self.ejson)
	end
	self.ejson = nil
	for k, _ in pairs(self.temp_effect) do
		ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(k)
	end
	self.temp_effect = {}
	if self.wjson ~= nil then
		ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(self.wjson)
	end
	--移除气泡对话
	self:remove_dialog(  )
	self.cc:removeFromParent()
	ccs.ArmatureDataManager: getInstance(): removeArmatureFileInfo(self.json)
	print('remove: ' , self.json)
	
end

function char:hit_red_body(  )
	self.armature:stopAllActions()
	self.armature:runAction(
		cc.Spawn:create(
			fast_actions.shake_action(0.4, 5, 0, 1, 0),
			cc.Sequence:create(
				cc.TintTo:create(0.3, 255, 120, 120),
				cc.TintTo:create(0, 255, 255, 255)
			)
		)
	)
end

function char:color_mask( color_rgb )
	if color_rgb == nil then
		return
	end

	self.armature:stopAllActions()
	self.armature:runAction(
	cc.Sequence:create(cc.TintTo:create(0.12, color_rgb[1], color_rgb[2], color_rgb[3]),cc.DelayTime:create(0.4),cc.TintTo:create(0.02, 255, 255, 255)))
end

--[[
function char:start_buff_effect( plist )
	print(' lizi texiao : ' .. plist )
    local p1 = cc.ParticleSystemQuad:create(plist)
    local p2 = cc.ParticleSystemQuad:create('skeleton/shouji_huo/lizi.plist')
	p1:setPositionType(cc.POSITION_TYPE_RELATIVE)
	p2:setPositionType(cc.POSITION_TYPE_RELATIVE)
	self.cc: addChild(p1)
	self.cc: addChild(p2)
end

function char:cancel_buff_effect( )
end
--]]
-- [[
function char:start_buff_effect( json, armature_name, anim_name, effect_pos, scale )
	if self.temp_effect[json] == nil then
		self:add_loaded_json(json)
		local effect = ccs.Armature:create( armature_name )
		if effect_pos ~= nil then
			local pos = 0
			if self.default_hit_box ~= nil then

				-- mao
				local hit_box = nil
				if type(self.default_hit_box[1]) == 'table' then
					hit_box = self.default_hit_box[1]
				else
					hit_box = self.default_hit_box
				end

				print(' default hit box ')
				if effect_pos[1] == 'top' then
					pos = hit_box[4]
				elseif effect_pos[1] == 'center' then
					pos = hit_box[2] + (hit_box[4] - hit_box[2])/2
				end
			end
			effect: setPosition( tonumber(effect_pos[2]), tonumber(effect_pos[3])+pos)
		else
			effect: setPosition( 0, 0 )
		end
		effect: setScale(scale)
		self.cc:addChild(effect)
		self.temp_effect[json] = effect
	end
	self.temp_effect[json]: setVisible( true )
	self.temp_effect[json]:getAnimation(): play(anim_name[1], anim_name[2], -1)
end

function char:cancel_buff_effect( json )
	if self.temp_effect[json] ~= nil then
		self.temp_effect[json]: setVisible( false )
		self.temp_effect[json]: getAnimation(): stop()
	end
end
-- ]]


-----------------对话相关-------------------------
--移除对话
function char:remove_dialog(  )
	if self.dialog ~= nil  then
		if self.dialog_con ~= nil then
			self.cc:removeChild(self.dialog_con)
		end
		self.dialog_con = nil
		self.dialog = nil
	end
end

--加入对话
function char:add_dialog( x,y )
	if self.dialog_con == nil then
		self.dialog = bubble_dialog.bubble_dialog()
		self.dialog_con = self.dialog:get_dialog()
		
		if self.say_id ~= nil then

			local num = #self.say_id 
			id =self.say_id[math.random(1, num)]
			local name = data.bubble_dia[id].name
			if id ~= nil and name ~= nil then
				self.dialog:set_string(name)
			end
			if name == nil then
				self.dialog:set_string('a')
				self.dialog_con:setVisible(false)
			else
				self.dialog_con:setVisible(true)
			end
		end

		self.cc:addChild(self.dialog_con,1)

		if self.anim_flipped == true then
			self.dialog_con:setPosition( -x,y )
		else
			self.dialog_con:setPosition( x,y )
		end
	end
end


function char:update_say( dir )
	if self.dialog ~= nil then
		self.dialog:set_Direction(dir,self.anim_flipped)
	end
end

--设置对话内容id
function char:set_dialog_id( ids )
	self.say_id = ids
end

function char:setScaleX( scale )
	self.cc: setScaleX( scale )
end

function char:setScaleY( scale )
	self.cc: setScaleY( scale )
end

function char:getAnimation()
	return self.armature: getAnimation()
end

function char:setVisible( vis )
	self.cc: setVisible( vis )
end

function char:setPosition( ... )
	self.cc: setPosition( ... )
end

function char:removeFromParent()
	self.cc: removeFromParent()
end

function char:fade( t, op )
	self.cc:setCascadeOpacityEnabled(true)
	local action = cc.FadeTo:create(t/Fps,op)
	self.cc:runAction(action)
end