tree = {type=2,title='根',childs={
	{type=1,title='None',childs={
		{type=7,title='获取500目标',func = 'aim_platform_target',args={dis=500}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻1',childs={
				{type=7,title='目标200以内',func = 'target_in_range', args={max=200}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 6}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标200以内',func = 'target_in_range', args={max=200}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 6}}
				}},
			{type=1,title='技能',childs={
				{type=7,title='目标200以内',func = 'target_in_range', args={max=200}},
				{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 6}}
				}},
			{type=7,title='移动目标200',func = 'move_to_target', args={distance_max = 200}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取500目标',func = 'aim_platform_target',args={dis=500}},
		{type=7,title='概率',func = 'probability', args={70,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}