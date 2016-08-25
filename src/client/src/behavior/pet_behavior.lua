tree = {type=2,title='根',childs={
	{type=1,title='宠物挂了',childs={
		{type=7,title='主角是否死亡',func = 'is_dead' },
		{type=7,title='宠物死去',func = 'dont_move'}
		}},
	{type=1,title='宠物跟随主角',childs={
		{type=7,title='获取主角目标',func = 'aim_player_target'},
		{type=7,title='移动向主角',func = 'move_to_player', args={leave_player_dis=120, speed_percent=16}}
		}}
	}
}