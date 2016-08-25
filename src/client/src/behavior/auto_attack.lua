tree = {type=2,title='根',childs={
	{type=1,title='死了',childs={
		{type=7,title='是否死亡',func = 'is_dead' },
		{type=7,title='死去',func = 'set_dead'}
		}},
	{type=2,title='活着的动作',childs={
		{type=1,title='有敌人',childs={
			{type=7,title='获取最近目标',func = 'aim_target'},
			{type=7,title='移动向目标',func = 'move_to_target', args={distance_max = 200}},
			{type=2,title='攻击或者跑开',childs={
				{type=1,title='攻击',childs={
					{type=7,title='概率',func = 'probability', args={75,100}},
					{type=7,title='攻击目标',func = 'attack'}
					}},
				{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={min_x=150, max_x=500}}
				}}
			}},
		{type=1,title='没敌人',childs={
			{type=7,title='木有目标',func = 'no_target'},
			{type=7,title='移动到随机点',func = 'move_to_rand_pos', args={min_x=150, max_x=1250}}
			}}
		}}
	}
}