tree = {type=1,title='根',childs={
	{type=2,title='boss血条显示',childs={
		{type=1,title='没有boss不显示血条',childs={
			{type=7,title='没有boss',func = 'check_entity_count', args={conf_id=1,max=0}},
			{type=7,title='不显示血条', func = 'hide_boss_hp', args={}}
			}},
		{type=7,title='显示血条', func = 'show_boss_hp', args={}}
		}},
	{type=2,title='结算',childs={
		{type=1,title='失败',childs={
			{type=7,title='玩家阵亡',func = 'player_dead'},
			{type=7,title='显示失败结算',func = 'show_defeated', args={scene_id=2}}
			}},
		{type=1,title='胜利',childs={
			{type=7,title='没有boss了',func = 'check_entity_count', args={conf_id=1,max=0}},
			{type=7,title='没有近程小怪了',func = 'check_entity_count', args={conf_id=2,max=0}},
			{type=7,title='没有远程小怪了',func = 'check_entity_count', args={conf_id=3,max=0}},
			{type=7,title='显示胜利结算',func = 'show_victory', args={scene_id=2}}
			}}
		}}
	}
}