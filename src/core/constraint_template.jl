### Switch Constraints ###
"enforces static switch constraints"
function constraint_dc_switch_state(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    switch = _PM.ref(pm, nw, :dcswitch, i)

    if switch["state"] == 0
        f_idx = (i, switch["f_busdc"], switch["t_busdc"])
        constraint_dc_switch_state_open(pm, nw, f_idx)
    else
        @assert switch["state"] == 1
        constraint_dc_switch_state_closed(pm, nw, switch["f_busdc"], switch["t_busdc"])
    end
end

"enforces controlable switch constraints"
function constraint_dc_switch_on_off(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    switch = _PM.ref(pm, nw, :dcswitch, i)

    f_idx = (i, switch["f_busdc"], switch["t_busdc"])
    vad_min = _PM.ref(pm, nw, :off_angmin)
    vad_max = _PM.ref(pm, nw, :off_angmax)

    constraint_dc_switch_power_on_off(pm, nw, i, f_idx)
    constraint_dc_switch_voltage_on_off(pm, nw, i, switch["f_busdc"], switch["t_busdc"], vad_min, vad_max)
end

"enforces an mva limit on the power flow over a switch"
function constraint_dc_switch_thermal_limit(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    switch = _PM.ref(pm, nw, :dcswitch, i)

    if haskey(switch, "thermal_rating")
        f_idx = (i, switch["f_busdc"], switch["t_busdc"])
        constraint_dc_switch_thermal_limit(pm, nw, f_idx, switch["thermal_rating"])
    end
end


function constraint_power_balance_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    bus_arcs_dcgrid = _PM.ref(pm, nw, :bus_arcs_dcgrid, i)
    bus_convs_dc = _PM.ref(pm, nw, :bus_convs_dc, i)
    pd = _PM.ref(pm, nw, :busdc, i)["Pdc"]
    constraint_power_balance_dc_ots(pm, nw, i, bus_arcs_dcgrid, bus_convs_dc, pd)
end

function constraint_power_balance_dc_switch(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    bus_arcs_dcgrid = _PM.ref(pm, nw, :bus_arcs_dcgrid, i)
    bus_convs_dc = _PM.ref(pm, nw, :bus_convs_dc, i)
    bus_arcs_sw_dc = _PM.ref(pm, nw, :bus_arcs_sw_dc, i)
    pd = _PM.ref(pm, nw, :busdc, i)["Pdc"]
    constraint_power_balance_dc_switch(pm, nw, i, bus_arcs_dcgrid, bus_convs_dc, bus_arcs_sw_dc, pd)
end

function constraint_converter_current_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    conv = _PM.ref(pm, nw, :convdc, i)
    Vmax = conv["Vmmax"]
    Imax = conv["Imax"]
    constraint_converter_current_dc_ots(pm, nw, i, Vmax, Imax)
end


function constraint_voltage_angle_difference_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    branch = _PM.ref(pm,nw,:branch,i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    pair = (f_bus, t_bus)
    buspair = _PM.ref(pm, nw, :buspairs, pair)

    #if buspair["branch"] == i
        constraint_voltage_angle_difference_ots(pm, nw, i, f_idx, buspair["angmin"], buspair["angmax"])
    #end
end

# These need to be updated

function thermal_constraint_ots_fr(pm::_PM.AbstractACPModel, i::Int, nw::Int=_PM.nw_id_default)

    branch = _PM.ref(pm,nw,:branch,i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = _PM.calc_branch_y(branch)
    g_fr = branch["g_fr"]
    b_fr = branch["b_fr"]

    thermal_constraint_ots_fr(pm, nw, i, f_bus, t_bus, f_idx, t_idx, g, b, g_fr, b_fr)

end

function thermal_constraint_ots_to(pm::_PM.AbstractACPModel, i::Int, nw::Int=_PM.nw_id_default)

    branch = _PM.ref(pm,nw,:branch,i)
    f_bus = branch["f_bus"]
    t_bus = branch["t_bus"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    g, b = _PM.calc_branch_y(branch)
    g_to = branch["g_to"]
    b_to = branch["b_to"]

    thermal_constraint_ots_to(pm, nw, i, f_bus, t_bus, f_idx, t_idx, g, b, g_to, b_to)
end


function constraint_ohms_ots_dc_branch(pm::_PM.AbstractACPModel, i::Int; nw::Int=_PM.nw_id_default)
    branch = _PM.ref(pm,nw,:branchdc,i)
    f_bus = branch["fbusdc"]
    t_bus = branch["tbusdc"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    p = _PM.ref(pm, nw, :dcpol)

    constraint_ohms_ots_dc_branch(pm, nw, f_bus, t_bus, f_idx, t_idx, branch["r"], p)
end


## dc OTS
function constraint_converter_losses_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    conv = _PM.ref(pm, nw, :convdc, i)
    a = conv["LossA"]
    b = conv["LossB"]
    c = conv["LossCinv"]
    plmax = conv["LossA"] + conv["LossB"] * conv["Pacrated"] + conv["LossCinv"] * (conv["Pacrated"])^2
    constraint_converter_losses_dc_ots(pm, nw, i, a, b, c, plmax)
end

function constraint_converter_losses_dc_ots_fully_constrained(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    conv = _PM.ref(pm, nw, :convdc, i)
    a = conv["LossA"]
    b = conv["LossB"]
    c = conv["LossCinv"]
    plmax = conv["LossA"] + conv["LossB"] * conv["Pacrated"] + conv["LossCinv"] * (conv["Pacrated"])^2
    constraint_converter_losses_dc_ots_fully_constrained(pm, nw, i, a, b, c, plmax)
end

function constraint_conv_filter_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    conv = _PM.ref(pm, nw, :convdc, i)
    constraint_conv_filter(pm, nw, i, conv["bf"], Bool(conv["filter"]) )
end


function constraint_conv_transformer_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    conv = _PM.ref(pm, nw, :convdc, i)
    constraint_conv_transformer_dc_ots(pm, nw, i, conv["rtf"], conv["xtf"], conv["busac_i"], conv["tm"], Bool(conv["transformer"]))
end

function constraint_branch_limit_on_off_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    branch = _PM.ref(pm, nw, :branchdc, i)
    f_bus = branch["fbusdc"]
    t_bus = branch["tbusdc"]
    f_idx = (i, f_bus, t_bus)
    t_idx = (i, t_bus, f_bus)

    pmax = branch["rateA"]
    pmin = -branch["rateA"]
    vpu = 0.8; #as taken in the variable creation
    imax = (branch["rateA"]/0.8)^2
    imin = 0
    constraint_branch_limit_on_off_dc_ots(pm, nw, i, f_idx, t_idx, pmax, pmin, imax, imin)
end


function constraint_converter_limit_on_off_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    bigM = 1.2
    conv = _PM.ref(pm, nw, :convdc, i)
    pmax = conv["Pacrated"]
    pmin = -conv["Pacrated"]
    qmax = conv["Qacrated"]
    qmin = -conv["Qacrated"]
    pmaxdc = conv["Pacrated"] * bigM
    pmindc = -conv["Pacrated"] * bigM
    imax = conv["Imax"]

    constraint_converter_limit_on_off_dc_ots(pm, nw, i, pmax, pmin, qmax, qmin, pmaxdc, pmindc, imax)
end


function constraint_conv_reactor_dc_ots(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    conv = _PM.ref(pm, nw, :convdc, i)
    constraint_conv_reactor_dc_ots(pm, nw, i, conv["rc"], conv["xc"], Bool(conv["reactor"]))
end



# Busbar splitting
function constraint_exclusivity_switch(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    switch_couple = _PM.ref(pm, nw, :switch_couples, i)
    constraint_exclusivity_switch(pm, nw, switch_couple["f_sw"], switch_couple["t_sw"])
end

function constraint_exclusivity_dc_switch(pm::_PM.AbstractPowerModel, i::Int; nw::Int=_PM.nw_id_default)
    switch_couple = _PM.ref(pm, nw, :dc_switch_couples, i)
    constraint_exclusivity_dc_switch(pm, nw, switch_couple["f_sw"], switch_couple["t_sw"])
end