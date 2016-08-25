tree = {type=2,title='根',childs={
	{type=1,title='HP>70%之P1阶段',childs={
		{type=7,title='获取1200目标',func = 'aim_platform_target',args={dis=1200}},
		{type=7,title='血量>70%',func = 'hp_range', args={70, 101}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻1',childs={
				{type=7,title='目标330以内',func = 'target_in_range', args={min=0,max=330}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 3}}
				}},
			{type=1,title='技能2',childs={
				{type=7,title='目标300以内',func = 'target_in_range', args={max=300}},
				{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 7}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {1061},time =3}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标200-500',func = 'target_in_range', args={min=200, max=500}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 8}}
				}},
			{type=7,title='移动目标360',func = 'move_to_target', args={distance_max = 360}}
			}}
		}},
	{type=1,title='HP<70%之P2阶段',childs={
		{type=7,title='获取2400目标',func = 'aim_platform_target',args={dis=2400}},
		{type=7,title='血量<70%',func = 'hp_range', args={0, 70}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻1',childs={
				{type=7,title='目标330以内',func = 'target_in_range', args={min=0,max=330}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 2}}
				}},
			{type=1,title='技能2',childs={
				{type=7,title='目标300以内',func = 'target_in_range', args={max=300}},
				{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 6}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {1062},time =2}}
				}},
			{type=1,title='技能',childs={
				{type=7,title='目标500以内',func = 'target_in_range', args={max=500}},
				{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 5}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {1063},time =1.5}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标200-500',func = 'target_in_range', args={min=200, max=500}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 7}}
				}},
			{type=7,title='移动目标360',func = 'move_to_target', args={distance_max = 360}}
			}},
		{type=7,title='血量<5%',func = 'hp_range', args={0, 5},childs={
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {1064},time =3}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取1200目标',func = 'aim_platform_target',args={dis=1200}},
		{type=7,title='概率',func = 'probability', args={70,100}},
		{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={max_x=200}}
		}}
	}
}