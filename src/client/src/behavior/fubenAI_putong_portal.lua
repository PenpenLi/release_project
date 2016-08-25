tree = {type=1,title='根',childs={
	{type=2,title='结算',childs={
		{type=1,title='失败',childs={
			{type=7,title='玩家阵亡',func = 'player_dead'},
			{type=7,title='显示失败结算',func = 'show_defeated'}
			}},
		{type=1,title='胜利',childs={
			{type=7,title='没怪了',func = 'check_entity_count', args={types={1,2,3},max=0}},
			{type=7,title='传到下一关',func = 'portal_to_next', args = {offset = {200, 180}, conf_id = 5557, gravity = false }}
			}}
		}}
	}
}