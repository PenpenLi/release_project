local avatar        = import('model.avatar').avatar

function avatar:get_vip_send_sweep_ticket()
    local vip_lv    = self:get_vip().lv
    local vip_data  = data.vip[vip_lv + 1]
    if vip_data ~= nil then
        return vip_data.free_sweep 
    end 
    return 0
end

function avatar:get_vip_buy_energy_time()
    local vip_lv    = self:get_vip().lv
    local vip_data  = data.vip[vip_lv + 1]
    if vip_data ~= nil then
        return vip_data.energy_max
    end 
    return 0
end


function avatar:get_vip_midas_time()
    local vip_lv    = self:get_vip().lv
    local vip_data  = data.vip[vip_lv + 1]
    if vip_data ~= nil then
        return vip_data.midas_max
    end 
    return 0
end

function avatar:get_vip_reset_JY_time()
    local vip_lv    = self:get_vip().lv
    local vip_data  = data.vip[vip_lv + 1]
    if vip_data ~= nil then
        return vip_data.jy_reset_max
    end 
    return 0
end