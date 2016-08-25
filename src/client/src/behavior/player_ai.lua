tree = {type=2,title='根',childs={
	{type=7,title='释放技能',func = 'try_cast_skill', args={}},
	{type=1,title='怪不同平台',childs={
		{type=7,title='检查不同平台',func = 'check_difference_ground', args={}},
		{type=2,title='下平台',childs={
			{type=1,title='哪边',childs={
				{type=7,title='escape_platform',func = 'escape_platform', args={}},
				{type=7,title='右move_to_right',func = 'move_to_right', args={}}
				}},
			{type=7,title='左move_to_left',func = 'move_to_left', args={}}
			}}
		}},
	{type=1,title='攻击行为',childs={
		{type=7,title='30%概率',func = 'probability', args={30,100}},
		{type=2,title='行为执行',childs={
			{type=1,title='上挑',childs={
				{type=7,title='20%概率',func = 'probability', args={20,100}},
				{type=7,title='敌在盒子flipped',func = 'enemy_in_box_flipped', args={50,70,200,650}},
				{type=7,title='上挑',func = 'slide_up', args={}}
				}},
			{type=1,title='下砍',childs={
				{type=7,title='20%概率',func = 'probability', args={20,100}},
				{type=7,title='敌在盒子flipped',func = 'enemy_in_box_flipped', args={50,-650,280,20}},
				{type=7,title='下砍',func = 'slide_down', args={}}
				}},
			{type=1,title='左冲',childs={
				{type=7,title='20%概率',func = 'probability', args={20,100}},
				{type=7,title='敌在盒子',func = 'enemy_in_box', args={-550,0,0,150}},
				{type=7,title='左冲',func = 'charge_left', args={}}
				}},
			{type=1,title='右冲',childs={
				{type=7,title='20%概率',func = 'probability', args={20,100}},
				{type=7,title='敌在盒子',func = 'enemy_in_box', args={ 0, 0, 550, 150}},
				{type=7,title='右冲',func = 'charge_right', args={}}
				}}
			}}
		}},
	{type=1,title='靠近行为',childs={
		{type=7,dec=3,title='敌在盒子flipped',func = 'enemy_in_box_flipped', args={-300,0,300,150}},
		{type=7,title='敌在盒子flipped',func = 'enemy_in_box_flipped', args={-450,0,450,1000}},
		{type=2,title='是否跳',childs={
			{type=1,title='有敌人',childs={
				{type=7,title='同平台有怪物',func = 'check_platform_enemy', args={}},
				{type=7,title='平台在盒子',func = 'platforms_in_box', args={0,0,300,250}}
				}},
			{type=7,title='跳',func = 'jump', args={}}
			}}
		}},
	{type=7,title='靠近150',func = 'move_to_target', args={distance_max=150}},
	{type=1,title='过关',childs={
		{type=7,title='走向传送门',func = 'move_to_portal', args={}}
		}}
	}
}