tree = {type=2,title='根',childs={
	{type=1,title='有敌人',childs={
		{type=7,title='空中警戒600',func = 'air_check_player_target', args={up=600, down=600,left=600,right=600}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='技能',childs={
				{type=7,title='目标400以内',func = 'target_in_range', args={max=400}},
				{type=7,title='skill',func = 'ai_state', args = {state = 'skill', cd = 8}}
				}},
			{type=1,title='普攻2',childs={
				{type=7,title='目标300以内',func = 'target_in_range', args={max=300}},
				{type=7,title='attack2',func = 'ai_state', args = {state = 'attack2', cd = 9}}
				}},
			{type=1,title='普攻1',childs={
				{type=7,title='目标280以内',func = 'target_in_range', args={min=0,max=280}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 5}}
				}},
			{type=7,title='飞向敌人280,120',func = 'fly_move_to_player' ,args={distance_max=280,height=120}}
			}}
		}},
	{type=1,title='没敌人',childs={
		{type=7,title='空中警戒600',func = 'air_monster_no_target', args={up=600, down=600,left=600,right=600}},
		{type=7,title='移动到随机点',func = 'fly_to_rand_pos', args={left_dis=100,right_dis=400,rand=9,multiple=10}}
		}}
	}
}