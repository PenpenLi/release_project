local music_mgr		= import( 'world.music_mgr' )
local bubble_dialog 	= import( 'ui.bubble_dialog.bubble_dialog' ) 

head_icon = lua_class( 'head_icon' )

local qishi_off_set = {73, -55}
local cike_off_set = {73, -45}
local bone_name = {"武器", "盾", "身", "左手", "右手", "左脚", "右脚", "斗篷", '翅膀骨骼点', '翅膀1', '翅膀2'}

function head_icon:_init( role_type, helmet_id )

	if role_type == nil then
		return nil
	end
	
	local conf = import('char.'.. role_type) 
	if conf.json == nil then
		return nil
	end

	self.equip_conf = conf.equip_conf
	self.json = conf.json
	self.cc = cc.Sprite:create()
	if conf.aname == nil then
		self.armature_name = conf.name
	else
		self.armature_name = conf.aname
	end
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(self.json)
	self.armature = ccs.Armature:create( self.armature_name )
	for _, v in pairs(bone_name) do
		local bone = self.armature:getBone(v)
		if bone ~= nil then
			bone:getDisplayRenderNode():setVisible(false)
			--self.armature:removeBone(bone)
		end
	end

	self.cc:addChild(self.armature, 1000)
	self.cc:setScale(0.68)
	self.cc:setLocalZOrder(10000)
	if role_type == 'qishi' then
		self.armature:setPosition(cc.p(qishi_off_set[1], qishi_off_set[2]))
	elseif role_type == 'cike' then
		self.armature:setPosition(cc.p(cike_off_set[1], cike_off_set[2]))
	end
	self:change_equip(helmet_id)
end

function head_icon:change_equip(helmet_id)
	if helmet_id ~= nil and data.item_id[helmet_id] ~= 'helmet' then
		return
	end
	ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(self.json)
	local equipment = data.helmet[helmet_id]
	local equip_config = data.equip[self.equip_conf.helmet]
	if equip_config == nil or equipment == nil then

		return
	end

	local confiles = equipment[equip_config.confield]
	if confiles ~= nil then
		for _, v in pairs(confiles) do
			ccs.ArmatureDataManager: getInstance(): addArmatureFileInfo(v)
		end
	end

	local bone_name = "头盔"
	local bone_field = equip_config.skeletons[bone_name]
	local bone = self.armature: getBone(bone_name)
	local field_data = equipment[bone_field]
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

function head_icon:set_scale(scale)
	self.cc:setScale(scale)
end

function head_icon:set_offset(x, y)
	if role_type == 'qishi' then
		self.armature:setPosition(cc.p(qishi_off_set[1] + x, qishi_off_set[2] + y))
	elseif role_type == 'cike' then
		self.armature:setPosition(cc.p(cike_off_set[1] + x, cike_off_set[2] + y))
	end
end