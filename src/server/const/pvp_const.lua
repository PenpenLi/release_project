
Point_h_win   = loadstring('s = (a.pvp_point - b.pvp_point)*0.1')
Point_l_win   = loadstring('s = (b.pvp_point - a.pvp_point)*0.2')
Point_h_fail  = loadstring('s = (b.pvp_point - a.pvp_point)*0.2')
Point_l_fail  = loadstring('s = (a.pvp_point - b.pvp_point)*0.1')

--绝对值范围
Point_abs_max = 15
Point_abs_min = 1

HonorFormula = loadstring('s = a.pvp_point * 0.01 + b.pvp_point * 0.01')

--券数超过不恢复
Ticket = 3

--券恢复间隔
TicketRecoverTime = 60 * 10

--刷新对战人选间隔
RefreshCandidateTime = 20 

--排行榜最大人数
RankCount = 50

--战斗记录最大数目
RecordCount = 5

--排行榜限制条件
LevelLimit = 1
PointLimit = 1000

--选人积分倍数线
CandidateList = {2, 1.5, 1.0, 0.8}

