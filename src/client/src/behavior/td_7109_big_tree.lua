tree = {type=2,title='根',childs={
	{type=1,title='战斗',childs={
		{type=7,title='获取10000目标',func = 'aim_platform_target',args={dis=10000}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='技能2',childs={
				{type=7,title='目标550以内',func = 'target_in_range', args={max=550}},
				{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 10}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {1091,1092,1000},time =5}}
				}},
			{type=1,title='技能',childs={
				{type=7,title='目标400以内',func = 'target_in_range', args={max=400}},
				{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 10}}
				}},
			{type=1,title='普攻1',childs={
				{type=7,title='目标50-300',func = 'target_in_range', args={min=50, max=300}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 9}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标250以内',func = 'target_in_range', args={max=250}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 9}}
				}},
			{type=7,title='移动目标360',func = 'move_to_target', args={distance_max = 360}}
			}}
		}}
	}
}