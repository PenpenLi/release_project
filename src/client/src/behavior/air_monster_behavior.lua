tree = {type=2,title='根',childs={
	{type=1,title='死了',childs={
		{type=7,title='是否死亡',func = 'is_dead' },
		{type=7,title='死去',func = 'dont_move'}
		}},
	{type=2,title='活着的动作',childs={
		{type=1,title='有敌人',childs={
			{type=7,title='检查周围有没有敌人',func = 'air_check_player_target', args={front=300, back=300,}},
			{type=7,title='飞向敌人',func = 'fly_to_player' ,args={width=250,height=100}},
			{type=7,title='概率',func = 'probability', args={70,100}},
			{type=7,title='攻击目标',func = 'attack', args={tick = 180}}
			}},
		{type=1,title='没敌人',childs={
			{type=7,title='木有目标',func = 'air_monster_no_target', args={front=300, back=300,}},
			{type=7,title='移动到随机点',func = 'fly_to_rand_pos', args={left_dis=100,right_dis=400,rand=9,multiple=10}}
			}}
		}}
	}
}