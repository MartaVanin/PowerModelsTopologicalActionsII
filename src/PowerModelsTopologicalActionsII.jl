isdefined(Base, :__precompile__) && __precompile__()

module PowerModelsTopologicalActionsII

# import Compat

import Memento
import PowerModelsACDC
const _PMACDC = PowerModelsACDC
import PowerModels
const _PM = PowerModels
import InfrastructureModels
const _IM = InfrastructureModels

import JuMP

import Plots
import PlotlyJS
# Create our module level logger (this will get precompiled)
const _LOGGER = Memento.getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `getlogger(PowerModels)`
# NOTE: If this line is not included then the precompiled `_PM._LOGGER` won't be registered at runtime.

__init__() = Memento.register(_LOGGER)

include("core/constraint.jl")
include("core/constraint_template.jl")
include("core/variableots.jl")
include("core/busbar_splitting.jl")
include("core/base.jl")

include("prob/acdcots_AC.jl")
include("prob/acdcots_DC.jl")
include("prob/acdcots_AC_DC.jl")
include("prob/acdcsw_AC.jl")
include("prob/acdcsw_DC.jl")
include("prob/ots_AC.jl")

include("form/acp.jl")



end # module PowerModelsTopologicalActionsII