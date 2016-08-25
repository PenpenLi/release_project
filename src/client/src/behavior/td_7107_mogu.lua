tree = {type=2,title='根',childs={
	{type=1,title='有敌人',childs={
		{type=7,title='获取12000目标',func = 'aim_platform_target',args={dis=12000}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻1',childs={
				{type=7,title='目标800以内',func = 'target_in_range', args={max=800}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 8}}
				}},
			{type=7,title='移动目标600',func = 'move_to_target', args={distance_max = 600}}
			}}
		}}
	}
}