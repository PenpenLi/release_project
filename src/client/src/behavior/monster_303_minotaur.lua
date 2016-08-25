tree = {type=2,title='根',childs={
	{type=2,title='攻击或移动',childs={
		{type=1,title='对话',childs={
			{type=7,title='下方节点执行1次',func = 'execute_count', args={n=1}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3031,3032,1000,1000},time =3}}
			}},
		{type=1,title='普攻1',childs={
			{type=7,title='目标350以内',func = 'target_in_range', args={max=350}},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 5}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='目标400以内',func = 'target_in_range', args={max=400}},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 12}}
			}},
		{type=1,title='有敌人',childs={
			{type=7,title='获取600目标',func = 'aim_platform_target',args={dis=600}},
			{type=7,title='移动目标360',func = 'move_to_target', args={distance_max = 360}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取600目标',func = 'aim_platform_target',args={dis=600}},
		{type=7,title='70%概率',func = 'probability', args={70,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}