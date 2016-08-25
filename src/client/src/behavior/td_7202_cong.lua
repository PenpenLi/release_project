tree = {type=2,title='根',childs={
	{type=1,title='狂暴',childs={
		{type=7,title='血量少于75%',func = 'hp_range', args={0, 75}},
		{type=7,title='下方节点执行n次',func = 'execute_count', args={n=1}},
		{type=7,title='气泡对话',func = 'bubble_dialogue', args = {id = {72021}, time = 1}},
		{type=7,title='移动速度增加13',func = 'change_x_speed',args={v=13}},
		{type=7,title='给自身一个buff',func = 'ai_apply_buff',args={buff=9999}},
		{type=7,title='转换为阵营3',func = 'set_group', args={group=3}}
		}},
	{type=1,title='有敌人',childs={
		{type=7,title='获取10000目标',func = 'aim_platform_target',args={dis=10000}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻1',childs={
				{type=7,title='目标250以内',func = 'target_in_range', args={max=250}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 3}}
				}},
			{type=7,title='移动目标230',func = 'move_to_target', args={distance_max = 230}}
			}}
		}}
	}
}