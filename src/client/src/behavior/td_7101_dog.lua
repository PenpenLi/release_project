tree = {type=2,title='根',childs={
	{type=1,title='有敌人',childs={
		{type=7,title='获取10000目标',func = 'aim_platform_target',args={dis=10000}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='对话',childs={
				{type=7,title='下方节点执行1次',func = 'execute_count', args={n=1}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {71011},time =3}}
				}},
			{type=1,title='普攻1',childs={
				{type=7,title='目标200以内',func = 'target_in_range', args={max=200}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 4}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标200以内',func = 'target_in_range', args={max=200}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 6}}
				}},
			{type=7,title='移动目标200',func = 'move_to_target', args={distance_max = 200}}
			}}
		}}
	}
}