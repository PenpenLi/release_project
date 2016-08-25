tree = {type=2,title='根',childs={
	{type=2,title='攻击或移动',childs={
		{type=1,title='技能2',childs={
			{type=7,title='目标350-1050',func = 'target_in_range', args={min=350,max=1050}},
			{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 16}}
			}},
		{type=1,title='技能',childs={
			{type=7,title='目标900',func = 'target_in_range', args={max=900}},
			{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 18}}
			}},
		{type=1,title='普攻3',childs={
			{type=7,title='目标340',func = 'target_in_range', args={max=340}},
			{type=7,title='attack3',func = 'ai_state', args = {state = 'attack3', cd = 15}}
			}},
		{type=1,title='普攻1',childs={
			{type=7,title='目标100-475',func = 'target_in_range', args={min=100,max=475}},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 15}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='目标380',func = 'target_in_range', args={max=380}},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 12}}
			}},
		{type=1,title='敌人太近',childs={
			{type=7,title='身边300距离目标',func = 'flee_aim_target', args={front=300, behind=300}},
			{type=7,title='概率',func = 'probability', args={20,100}},
			{type=7,title='远离目标',func = 'flee_player', args={flee_dis = 380, speed_multiple = 0.6 }}
			}},
		{type=1,title='有敌人',childs={
			{type=7,title='获取1200目标',func = 'aim_platform_target',args={dis=1200}},
			{type=7,title='移动目标400',func = 'move_to_target', args={distance_max = 400}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取1200目标',func = 'aim_platform_target',args={dis=1200}},
		{type=7,title='概率',func = 'probability', args={50,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}