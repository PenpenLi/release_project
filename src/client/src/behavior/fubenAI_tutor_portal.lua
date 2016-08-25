tree = {type=1,title='根',childs={
	{type=1,title='胜利',childs={
		{type=7,title='没怪了',func = 'check_entity_count', args={types={1,2,3},max=0}},
		{type=7,title='没传送门',func = 'check_entity_count', args={conf_id=100050,max=0}},
		{type=7,title='传到主城',func = 'portal_to_main', args = {offset = {200, 0}, conf_id = 100050, gravity = true }}
		}}
	}
}