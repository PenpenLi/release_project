tree = {type=1,title='根',childs={
	{type=2,title='结算',childs={
		{type=7,title='更新杀怪进度',func = 'show_monster_count', args={group={2,3}}},
		{type=1,title='玩家死亡',childs={
			{type=7,title='玩家阵亡',func = 'player_dead'},
			{type=7,title='显示失败结算',func = 'show_defeated'}
			}},
		{type=1,title='基地摧毁',childs={
			{type=7,title='基地被摧毁',func = 'home_hp_range', args={0, 1}},
			{type=7,title='显示失败结算',func = 'show_defeated'}
			}},
		{type=1,title='出怪',childs={
			{type=7,title='CD冷却了',func = 'cd_over', args={}
},
			{type=7,title='刷出下一批怪',func = 'create_entitys', args={}
}
			}},
		{type=1,title='胜利',childs={
			{type=7,title='批次完了',func = 'all_over', args={}
},
			{type=7,title='没怪了',func = 'check_entity_count', args={types={1,2,3},max=2}},
			{type=7,title='结算',func = 'show_victory'}
			}}
		}}
	}
}