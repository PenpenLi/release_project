tree = {type=2,title='根',childs={
	{type=2,title='攻击或移动',childs={
		{type=1,title='普攻1',childs={
			{type=7,title='左边',func = 'target_in_range', args={ x_min=-9999 , x_max = 0 }},
			{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 10}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3051,1000,1000},time =3}}
			}},
		{type=1,title='普攻2',childs={
			{type=7,title='右边',func = 'target_in_range', args={ x_min=0, x_max = 9999 }},
			{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 10}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3051,1000,1000},time =3}}
			}},
		{type=1,title='普攻3',childs={
			{type=7,title='目标200以内',func = 'target_in_range', args={max=200}},
			{type=7,title='attack3',func = 'ai_state', args = {state = 'attack3', cd = 10}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3053,1000,1000},time =3}}
			}},
		{type=1,title='技能',childs={
			{type=7,title='右边',func = 'target_in_range', args={ x_min=0, x_max = 9999 }},
			{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 12}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3054,1000,1000},time =3}}
			}},
		{type=1,title='技能2',childs={
			{type=7,title='左边',func = 'target_in_range', args={ x_min=-9999 , x_max = 0 }},
			{type=7,title='skill2',func = 'ai_state', args = {state = 'skill2', cd = 12}},
			{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {3052,1000,1000},time =3}}
			}}
		}},
	{type=2,title='没敌人',childs={
		{type=7,title='获取600目标',func = 'aim_platform_target',args={dis=600}},
		{type=7,title='70%概率',func = 'probability', args={70,100}}
		}}
	}
}