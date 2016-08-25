tree = {type=2,title='根',childs={
	{type=2,title='攻击或移动',childs={
		{type=1,title='技能',childs={
			{type=7,title='目标230-478以内',func = 'target_in_range', args={min=230,max=478}},
			{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 5}}
			}},
		{type=1,title='技能2',childs={
			{type=7,title='目标540',func = 'target_in_range', args={max=540}},
			{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 11}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='目标1000以内',func = 'target_in_range', args={max=1000}},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 10}}
			}},
		{type=1,title='普攻1',childs={
			{type=7,title='目标440',func = 'target_in_range', args={max=440}},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 10}}
			}},
		{type=1,title='敌人太近',childs={
			{type=7,title='身边350距离目标',func = 'flee_aim_target', args={front=350, behind=350}},
			{type=7,title='概率',func = 'probability', args={50,100}},
			{type=2,title='特殊移动',childs={
				{type=1,title='后闪',childs={
					{type=7,title='概率',func = 'probability', args={50,100}},
					{type=7,title='skill3',func = 'ai_state', args = {state = 'skill3', cd = 1}}
					}},
				{type=7,title='前闪(attack3)',func = 'ai_state', args = {state = 'attack3', cd = 1}}
				}}
			}},
		{type=1,title='有敌人',childs={
			{type=7,title='获取1200目标',func = 'aim_platform_target',args={dis=1200}},
			{type=7,title='移动目标300',func = 'move_to_target', args={distance_max = 300}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取1200目标',func = 'aim_platform_target',args={dis=1200}},
		{type=7,title='概率',func = 'probability', args={50,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}