tree = {type=2,title='根',childs={
	{type=1,title='有敌人',childs={
		{type=7,title='空中警戒600',func = 'air_check_player_target', args={up=600, down=600,left=600,right=600}},
		{type=2,title='攻击或移动',childs={
			{type=1,title='对话',childs={
				{type=7,title='下方节点执行1次',func = 'execute_count', args={n=1}},
				{type=7,title='气泡对话',func = 'bubble_dialogue',args={id = {2031,2032,1000,1000,1000},time =3}}
				}},
			{type=1,title='普攻1',childs={
				{type=7,title='目标360以内',func = 'target_in_range', args={max=360}},
				{type=7,title='attack',func = 'ai_state', args = {state = 'attack', cd = 5}}
				}},
			{type=7,title='飞向敌人320,200',func = 'fly_to_player' ,args={width=320,height=200}}
			}}
		}},
	{type=1,title='没敌人',childs={
		{type=7,title='空中警戒600',func = 'air_monster_no_target', args={up=600, down=600,left=600,right=600}},
		{type=7,title='移动到随机点',func = 'fly_to_rand_pos', args={left_dis=100,right_dis=400,rand=9,multiple=10}}
		}}
	}
}