tree = {type=2,title='根',childs={
	{type=1,title='P1普通',childs={
		{type=7,title='获取10000目标',func = 'aim_platform_target',args={dis=10000}},
		{type=7,title='血量>70%',func = 'hp_range', args={70, 102}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻1',childs={
				{type=7,title='目标280以内',func = 'target_in_range', args={max=280}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 5}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标250以内',func = 'target_in_range', args={max=250}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 7}}
				}},
			{type=7,title='移动目标300',func = 'move_to_target', args={distance_max = 300}}
			}}
		}},
	{type=1,title='P2发狂',childs={
		{type=7,title='获取10000目标',func = 'aim_platform_target',args={dis=10000}},
		{type=7,title='血量<70%',func = 'hp_range', args={0, 70}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='技能2',childs={
				{type=7,title='目标300以内',func = 'target_in_range', args={max=300}},
				{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 5}}
				}},
			{type=1,title='技能1',childs={
				{type=7,title='目标280以内',func = 'target_in_range', args={max=280}},
				{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 6}}
				}},
			{type=7,title='移动目标300',func = 'move_to_target', args={distance_max = 300}}
			}}
		}}
	}
}