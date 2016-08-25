tree = {type=2,title='根',childs={
	{type=1,title='战斗',childs={
		{type=7,title='获取12000目标',func = 'aim_platform_target',args={dis=12000}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻',childs={
				{type=7,title='目标80-1200',func = 'target_in_range', args={min=80, max=1200}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 7}}
				}},
			{type=1,title='技能',childs={
				{type=7,title='目标50-600',func = 'target_in_range', args={min=50, max=600}},
				{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 8}}
				}},
			{type=1,title='技能2',childs={
				{type=7,title='目标400以内',func = 'target_in_range', args={max=400}},
				{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 20}}
				}},
			{type=7,title='移动目标500',func = 'move_to_target', args={distance_max = 500}}
			}}
		}}
	}
}