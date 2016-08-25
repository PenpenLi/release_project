tree = {type=2,title='根',childs={
	{type=2,title='攻击或移动',childs={
		{type=1,title='泰山压顶',childs={
			{type=7,title='目标400',func = 'target_in_range', args={max=400}},
			{type=7,title='attack3',func = 'ai_state', args = {state = 'attack3', cd = 15}}
			}},
		{type=1,title='技能3',childs={
			{type=7,title='目标1200',func = 'target_in_range', args={max=1200}},
			{type=7,title='skill3',func = 'ai_state', args = {state = 'skill3', cd = 15}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='目标480',func = 'target_in_range', args={max=480}},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 18}}
			}},
		{type=1,title='普攻1',childs={
			{type=7,title='目标390',func = 'target_in_range', args={max=390}},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 16}}
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