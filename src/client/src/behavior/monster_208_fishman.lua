tree = {type=2,title='根',childs={
	{type=2,title='攻击或移动',childs={
		{type=1,title='技能',childs={
			{type=7,title='目标290-460以内',func = 'target_in_range', args={min=290,max=460}},
			{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 10}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {2081,1000,1000},time =3}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='目标478以内',func = 'target_in_range', args={max=478}},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 9}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {2082,1000,1000},time =3}}
			}},
		{type=1,title='普攻1',childs={
			{type=7,title='目标250以内',func = 'target_in_range', args={max=250}},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 7}}
			}},
		{type=1,title='有敌人',childs={
			{type=7,title='获取600目标',func = 'aim_platform_target',args={dis=600}},
			{type=7,title='移动目标255',func = 'move_to_target', args={distance_max = 255}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取600目标',func = 'aim_platform_target',args={dis=600}},
		{type=7,title='70%概率',func = 'probability', args={70,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}