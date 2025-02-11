using PowerModels; const _PM = PowerModels
using Ipopt, JuMP
using HiGHS, Gurobi, Juniper
using PowerModelsACDC; const _PMACDC = PowerModelsACDC
import PowerModelsTopologicalActionsII; const _PMTP = PowerModelsTopologicalActionsII
using PowerModelsTopologicalActionsII

# Define solver
ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
highs = JuMP.optimizer_with_attributes(HiGHS.Optimizer)
gurobi = JuMP.optimizer_with_attributes(Gurobi.Optimizer)
juniper = JuMP.optimizer_with_attributes(Juniper.Optimizer, "nl_solver" => ipopt_solver, "mip_solver" => highs, "time_limit" => 7200)


## Input data
test_case = "case5.m"
test_case_sw = "case5_sw.m"
test_case_acdc = "case5_acdc.m"


## Parsing with Powermodels
data_file_acdc = joinpath(@__DIR__,"data_sources",test_case_acdc)
#=
data_file = joinpath(@__DIR__,"data_sources",test_case)
data_file_sw = joinpath(@__DIR__,"data_sources",test_case_sw)

data_original = _PM.parse_file(data_file)
data = deepcopy(data_original)
data_busbar_split = deepcopy(data_original)
data_sw = _PM.parse_file(data_file_sw)
=#


data_original_acdc = _PM.parse_file(data_file_acdc)
data_acdc = deepcopy(data_original_acdc)
_PMACDC.process_additional_data!(data_acdc)
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)
data_dc_busbar_split = deepcopy(data_acdc)
#=
# AC OTS with PowerModels for AC grid
result_ots = _PM.solve_ots(data,ACPPowerModel,juniper)

# AC OPF for ACDC grid
result_opf = _PMACDC.run_acdcopf(data_acdc,ACPPowerModel,juniper)

# Solving AC OTS with OTS only on the DC grid part 
result_homemade_ots_DC = _PMTP.run_acdcots_DC(data_acdc,ACPPowerModel,juniper)

# Solving AC OTS with OTS only on the AC grid part
result_homemade_ots = _PMTP.run_acdcots_AC(data_acdc,ACPPowerModel,juniper)

# Solving AC OTS with OTS on both AC and DC grid part
result_homemade_ots_AC_DC = _PMTP.run_acdcots_AC_DC(data_acdc,ACPPowerModel,juniper)


data_sw, switch_couples, extremes_ZIL = _PMTP.AC_busbar_split(data_acdc,1)

# AC OTS with handmade for AC/DC grid with switches state as decision variable
result_PM_AC_DC_switch_AC = _PM._solve_oswpf(data_sw,DCPPowerModel,juniper)
result_AC_DC_switch_AC = _PMTP.run_acdcsw_AC(data_sw,ACPPowerModel,juniper)
=#
data_base_sw_dc = deepcopy(data_dc_busbar_split)
data_sw_dc, switch_dccouples, extremes_ZIL_dc = _PMTP.DC_busbar_split(data_base_sw_dc,1)

result_AC_DC_switch_DC = _PMTP.run_acdcsw_DC(data_sw_dc,ACPPowerModel,juniper)


#=
data_acdc["dcswitch"] = Dict{String,Any}()

data_busbar_split_dc, dc_switch_couples = _PMTP.busbar_split_creation_dc(data_acdc,1)

dc_switch_couples = _PMTP.compute_couples_of_dcswitches(data_acdc)

data_busbar_split_dc["dc_switch_couples"] = deepcopy(dc_switch_couples)

result_AC_DC_switch_DC = _PMTP._solve_oswpf_DC_busbar_splitting_AC_DC(data_busbar_split_dc,ACPPowerModel,juniper)


bus_arcs_sw_dc = Dict{String,Any}()

bus_arcs_sw_dc = Dict((i, Tuple{Int,Int,Int}[]) for (i,bus) in data_busbar_split_dc["busdc"])
for (l,i,j) in data_busbar_split_dc[:arcs_sw_dc]
    push!(bus_arcs_sw_dc[i], (l,i,j))
end
nw_ref[:bus_arcs_sw_dc] = bus_arcs_sw_dc



# Splitting the selected bus
grid, switch_couples = _PMTP.busbar_split_creation(data_busbar_split,1)

# AC OTS with PowerModels for AC grid with fixed switches
result_switch_fixed = _PM._solve_opf_sw(data_sw,ACPPowerModel,juniper)

# AC OTS with PowerModels and handmade for AC grid with switches state as decision variable
# Infeasible
result_PM_switch = _PM._solve_oswpf(grid,ACPPowerModel,juniper)
result_switch = _PMTP.solve_ots_switch(grid,ACPPowerModel,juniper)

# DC linearization working
result_PM_switch_DC_fixed = _PM._solve_opf_sw(grid,DCPPowerModel,juniper)
result_PM_switch_DC = _PM._solve_oswpf(grid,DCPPowerModel,juniper)
result_switch_DC = _PMTP.solve_ots_switch(grid,DCPPowerModel,juniper)
result_switch_DC_busbar_splitting = _PMTP._solve_oswpf_busbar_splitting(grid,DCPPowerModel,juniper)

# SOC relaxation working
result_PM_switch_SOC_fixed = _PM._solve_opf_sw(grid,SOCWRPowerModel,juniper)
result_PM_switch_SOC = _PM._solve_oswpf(grid,SOCWRPowerModel,juniper)
result_switch_SOC = _PMTP.solve_ots_switch(grid,SOCWRPowerModel,juniper)
result_switch_SOC_busbar_splitting = _PMTP._solve_oswpf_busbar_splitting(grid,SOCWRPowerModel,juniper)

# QC relaxation
result_PM_switch_QC_fixed = _PM._solve_opf_sw(grid,QCRMPowerModel,juniper)
result_PM_switch_QC = _PM._solve_oswpf(grid,QCRMPowerModel,juniper)
result_switch_QC = _PMTP.solve_ots_switch(grid,QCRMPowerModel,juniper)
result_switch_QC_busbar_splitting = _PMTP._solve_oswpf_busbar_splitting(grid,QCRMPowerModel,juniper)
=#

arcs_from_sw_dc = [] #Dict{String,Any}()
arcs_to_sw_dc   = [] #Dict{String,Any}()
arcs_sw_dc = [] #Dict{String,Any}()

arcs_from_sw_dc = [(i,switch["f_busdc"],switch["t_busdc"]) for (i,switch) in data_sw_dc["dcswitch"]]
arcs_to_sw_dc   = [(i,switch["t_busdc"],switch["f_busdc"]) for (i,switch) in data_sw_dc["dcswitch"]]
arcs_sw_dc = [arcs_from_sw_dc; arcs_to_sw_dc]


bus_arcs_sw_dc = Dict([(bus["busdc_i"], []) for (i,bus) in data_sw_dc["busdc"]])
for (l,i,j) in arcs_sw_dc
    push!(bus_arcs_sw_dc[i], (l,i,j))
end

    p_dc_sw_ = _PM.var(pm,nw)[:p_dc_sw] = JuMP.variable(pm.model,
        [(l,i,j) in _PM.ref(pm, nw, :arcs_from_sw_dc)], base_name="$(nw)_p_dc_sw",
        start = _PM.comp_start_value(_PM.ref(pm, nw, :dcswitch, l), "p_dc_sw_start")
    )

for (l,i,j) in arcs_from_sw_dc
    print(l,"\n")
end