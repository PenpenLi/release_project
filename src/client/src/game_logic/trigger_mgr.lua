local buff_cb	= import( 'game_logic.buff_callback' )
local buff_cond	= import( 'game_logic.buff_condition' )
local battle_const	= import( 'game_logic.battle_const' )
local combat	= import( 'model.combat' )
local director	= import( 'world.director')
local condition = import( 'game_logic.condition' )
local trigger_mgr = import( 'game_logic.trigger_mgr' )

math.randomseed(os.time())



--condition
function enemy_death(battle, att_e, hit_e, args)
	dir(hit_e)
	local flag = false
	if hit_e.combat_attr.hp <= 0 then
		flag = true
	end
	return flag
end

function cirt(battle, att_e, hit_e, args)
	if att_e.crit_flag == nil or att_e.crit_flag == false then
		return false
	end
	return true
end

-----------------------------------opeartion---------------------------------------
--args = hp
function add_hp(battle, att_e, hit_e, target, args)
	local e = att_e
	if target == 'e' then
		e = hit_e
	end
	if e:is_bullet() then
		local entity = e:get_is_from()
		entity.combat_attr:add_property('hp', args.hp)
	else
		e.combat_attr:add_property('hp', args.hp)
	end
	--e.combat_attr:add_property('hp', args.hp)
end

--args = mp
function add_mp(battle, att_e, hit_e, target, args)
	local e = att_e
	if target == 'e' then
		e = hit_e
	end

	if e:is_bullet() then
		local entity = e:get_is_from()
		entity.combat_attr:add_property('mp', args.mp)
	elseif e:is_player() then
		e.combat_attr:add_property('mp', args.mp)
	end
end

--args = buff_id
function apply_buff(battle, att_e, hit_e, target, args)
	local e = att_e
	if target == 'e' then
		e = hit_e
	end
	if e:is_bullet() then
		local entity = e:get_is_from()
		entity.buff:apply_buff( args.buff_id, nil, nil )
	else
		e.buff:apply_buff( args.buff_id, nil, nil )
	end
end

--args = skill_id, cd
function set_skill_cd(battle, att_e, hit_e, target, args)
	local e = att_e
	if target == 'e' then
		e = hit_e
	end

	local layer = battle.proxy
	local skill_btn = layer:get_skill_btn()
	local skill = skill_btn[args.skill_id]
	if skill == nil or args.cd == nil then 
		return 
	end
	skill:set_skill_cd(args.cd)

end
------------------------------------------------------------------------------------

local function check_condition(conditions, battle, att_e, hit_e)
	local flag = true
	if conditions == nil then
		return flag
	end
	for c, _ in pairs(conditions) do
		local cond = trigger_mgr[c]
		flag = flag and cond(battle, att_e, hit_e)
		if not flag  then
			flag = false
		end
	end
 	return flag
end

function try_trigger(battle, att_e, hit_e)
	local trigger = att_e.attack_info.trigger
	local flag
	for _, tri in pairs(trigger) do
		flag = true
		if tri.trigger_cond ~= nil then
			flag = check_condition(tri.trigger_cond, battle, att_e, hit_e)
		end
		if flag then
			local operations = tri.operation
			if operations ~= nil then

				for __, oper in pairs(operations) do

					local rand = math.random(100)
					if oper.probability == nil or rand <= oper.probability then
						trigger_mgr[oper.func](battle, att_e, hit_e, oper.tar, oper.args)
					end
				end
			end
		end
	end
end