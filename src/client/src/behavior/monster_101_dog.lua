tree = {type=2,title='根',childs={
	{type=1,title='逃窜',childs={
		{type=7,title='血量10%~20%',func = 'hp_range', args={10, 20}},
		{type=7,title='逃跑计数15次',func = 'create_counter', args = {counter_id = 1, count = 15}},
		{type=7,dec=1,title='远离目标',func = 'flee_player', args={flee_dis = 300, speed_multiple = 1 }},
		{type=2,title='保持距离',childs={
			{type=7,title='身边500距离目标',func = 'flee_aim_target', args={front=500, behind=500}},
			{type=7,title='靠近400距离',func = 'move_to_target', args={distance_max = 400}}
			}}
		}},
	{type=1,title='有敌人',childs={
		{type=7,title='获取500目标',func = 'aim_platform_target',args={dis=500}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='对话',childs={
				{type=7,title='下方节点执行2次',func = 'execute_count', args={n=1}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {1011,1000,1000},time =3}}
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
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取500目标',func = 'aim_platform_target',args={dis=500}},
		{type=7,title='概率',func = 'probability', args={70,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}