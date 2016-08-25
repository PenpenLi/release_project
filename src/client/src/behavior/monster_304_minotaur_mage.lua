tree = {type=2,title='根',childs={
	{type=1,title='敌人太近',childs={
		{type=7,title='身边500距离目标',func = 'flee_aim_target', args={front=500, behind=500}},
		{type=7,title='远离目标',func = 'flee_player', args={flee_dis = 600, speed_multiple = 1 }}
		}},
	{type=2,title='攻击或移动',childs={
		{type=1,title='对话',childs={
			{type=7,title='下方节点执行1次',func = 'execute_count', args={n=1}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3041,3042,1000,1000,1000},time =3}}
			}},
		{type=1,title='普攻1',childs={
			{type=7,title='目标600以内',func = 'target_in_range', args={max=600}},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 6}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='目标600以内',func = 'target_in_range', args={max=600}},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 13}}
			}},
		{type=1,title='有敌人',childs={
			{type=7,title='获取800目标',func = 'aim_platform_target',args={dis=800}},
			{type=7,title='移动目标600',func = 'move_to_target', args={distance_max = 600}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取800目标',func = 'aim_platform_target',args={dis=800}},
		{type=7,title='概率',func = 'probability', args={70,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}