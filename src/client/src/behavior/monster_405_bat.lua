tree = {type=2,title='根',childs={
	{type=1,title='有敌人',childs={
		{type=7,title='空中警戒600',func = 'air_check_player_target', args={up=600, down=600,left=600,right=600}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='普攻2',childs={
				{type=7,title='目标600',func = 'target_in_range', args={max=600}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 9}}
				}},
			{type=1,title='普攻1',childs={
				{type=7,title='目标265',func = 'target_in_range', args={min=0,max=265}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 5}}
				}},
			{type=7,title='飞向敌人265,70',func = 'fly_to_player' ,args={width=265,height=70}}
			}}
		}},
	{type=1,title='没敌人',childs={
		{type=7,title='空中警戒600',func = 'air_monster_no_target', args={up=600, down=600,left=600,right=600}},
		{type=7,title='移动到随机点',func = 'fly_to_rand_pos', args={left_dis=100,right_dis=400,rand=9,multiple=10}}
		}}
	}
}