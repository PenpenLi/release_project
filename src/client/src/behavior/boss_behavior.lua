tree = {type=2,title='根',childs={
	{type=1,title='死了',childs={
		{type=7,title='是否死亡',func = 'is_dead' }
		}},
	{type=2,title='活着的动作',childs={
		{type=1,title='奥义的时候做些什么',childs={
			{type=7,title='奥义状态',func = 'check_state', args = {state = 'ougi'}},
			{type=2,title='有目标就面向目标',childs={
				{type=7,title='木有目标',func = 'no_target'},
				{type=7,title='面向目标',func = 'face_target'}
				}},
			{type=2,title='有怪继续奥你的义',childs={
				{type=7,title='至少还有一只近战小怪',func = 'check_entity_count', args={conf_id=2,min=1}},
				{type=7,title='至少还有1个远程小怪',func = 'check_entity_count', args={conf_id=3,min=1}},
				{type=7,title='恢复正常状态',func = 'ai_state', args = {state = 'idle'}}
				}}
			}},
		{type=1,title='招近战小怪时候做些什么',childs={
			{type=7,title='招近战小怪状态',func = 'check_state', args = {state = 'skill2'}},
			{type=2,title='有目标就面向目标',childs={
				{type=7,title='木有目标',func = 'no_target'},
				{type=7,title='面向目标',func = 'face_target'}
				}},
			{type=2,title='有怪继续保持无敌',childs={
				{type=7,title='至少还有1个近战小怪',func = 'check_entity_count', args={conf_id=2,min=1}},
				{type=7,title='恢复正常状态',func = 'ai_state', args = {state = 'idle'}}
				}}
			}},
		{type=1,title='招远程小怪时候做些什么',childs={
			{type=7,title='招远程小怪状态',func = 'check_state', args = {state = 'skill3'}},
			{type=2,title='有目标就面向目标',childs={
				{type=7,title='木有目标',func = 'no_target'},
				{type=7,title='面向目标',func = 'face_target'}
				}},
			{type=2,title='有怪继续保持无敌',childs={
				{type=7,title='至少还有1个远程怪',func = 'check_entity_count', args={conf_id=3,min=1}},
				{type=7,title='恢复正常状态',func = 'ai_state', args = {state = 'idle'}}
				}}
			}},
		{type=1,title='有敌人',childs={
			{type=2,title='攻击',childs={
				{type=1,title='血量低于20,招小怪且放黑水',childs={
					{type=7,title='血量百分比',func = 'hp_percentage', args={20}},
					{type=7,title='发现目标',func = 'search_target'},
					{type=7,title='移动向目标',func = 'move_to_target', args={distance_max = 600}},
					{type=7,title='奥义',func = 'ai_state', args = {state = 'ougi'}}
					}},
				{type=1,title='血量低于30，招远程小怪',childs={
					{type=7,title='血量百分比',func = 'hp_percentage', args={30}},
					{type=7,title='发现目标',func = 'search_target'},
					{type=7,title='移动向目标',func = 'move_to_target', args={distance_max = 600}},
					{type=7,title='招远程小怪',func = 'ai_state', args = {state = 'skill3'}
}
					}},
				{type=1,title='血量低于40，招近战小怪',childs={
					{type=7,title='血量百分比',func = 'hp_percentage', args={40}},
					{type=7,title='发现目标',func = 'search_target'},
					{type=7,title='移动向目标',func = 'move_to_target', args={distance_max = 600}},
					{type=7,title='招近战小怪',func = 'ai_state', args = {state = 'skill2'}
}
					}},
				{type=1,title='血量低于50,60,70,放黑水',childs={
					{type=7,title='血量百分比',func = 'hp_percentage', args={50,60,70}},
					{type=7,title='发现目标',func = 'search_target'},
					{type=7,title='移动向目标',func = 'move_to_target', args={distance_max = 600}},
					{type=7,title='释放黑水',func = 'ai_state', args = {state = 'skill1'}

}
					}},
				{type=1,title='普通攻击',childs={
					{type=7,title='发现目标',func = 'search_target'},
					{type=7,title='移动向目标',func = 'move_to_target', args={distance_max = 200}},
					{type=7,title='攻击目标',func = 'attack', args={tick=180}}
					}}
				}}
			}},
		{type=1,title='没敌人',childs={
			{type=7,title='木有目标',func = 'no_target'},
			{type=7,title='移动到随机点',func = 'move_to_rand_pos'},
			{type=2,title='待机状态',childs={
				{type=7,title='是否待机',func = 'check_state', args = {state = 'idle'}},
				{type=7,title='进入待机',func = 'ai_state', args = {state = 'idle'}}
				}}
			}}
		}}
	}
}