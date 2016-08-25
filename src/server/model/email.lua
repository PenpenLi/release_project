local avatar		 = import('entities.avatar')
local db			 = import('db')

broadcast_emails = {}

function create_email(email_id)
	local tbl = {
		_id = oid_to_str(db.gen_oid()),
--		_id = 1000,
		eid = email_id,
		has_read = false,
		has_get_items = false,
	}
	return tbl
end

-- 发送邮件
function send_email(email_id, players)
	if email_id == nil then
		return
	end
	local email = create_email(email_id)
	broadcast_emails[email._id] = email  --添加广播
	
	local function func(e)
		e:_email_to_client(email)
	end
	broadcast_avatars(func)
end

