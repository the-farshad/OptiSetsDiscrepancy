using JuMP
using Gurobi
log_file_path = "/scratchbeta/clementf/30.txt"
# 2d continuous case, basic model using dummy points, full constraints

# julia command: include("Sparse2_cont.jl")

# prerequisites in julia:

# using DelimitedFiles

# using JuMP

# using Gurobi

# Define the model name: Sparse

# Define the model name: Sparse
Sparse = Model()

# Select the solver
set_optimizer(Sparse,Gurobi.Optimizer)

# Activate the nonconvex option for Gurobi
set_optimizer_attribute(Sparse, "NonConvex", 2)
#set_optimizer_attribute(Sparse, "MIPGap", 0.000001)
#set_time_limit_sec(Sparse, 40000.0)

# number of points to be located: m
set_optimizer_attribute(Sparse, "LogFile", log_file_path)
m =10

# minimum distance between points in x1 and x2 direction, and minimum distance from 0
eps = 0.0001*1/m


# definition of the continuous variables defining the points: x^i=(x[2i-1],x[2i]) for i=1:m
@variable(Sparse, 0<=x[0:2*m+1]<=1)

# definition of binary variables that identify the ordering of the points w.r.t. the x2-coordinate. y[i,j]=1 if x^i_2=x[2i]<x[2j]=x^2_j or if i=j, and zero otherwise
@variable(Sparse, y[0:m+1,0:m], Bin)

# continuous variable that takes on the value of the star-discrepancy
@variable(Sparse, z>=0)

# constraints (4a)
@constraint(Sparse, [i in 1:m, j in 1:i], 1/m* sum(y[u,j] for u in 1:i) - x[2*i-1]*x[2*j] <= z + 1 - y[i,j])

# constraints (4b')
@constraint(Sparse, [i in 1:m+1, j in 0:i-1], -1/m* (sum(y[u,j] for u in 0:i-1) -1) + x[2*i-1]*x[2*j] <= z + 1 - y[i,j])

# constraints (4f)
@constraint(Sparse, [i in 1:m-1], x[2*i+1] - x[2*i-1] >= eps)
@constraint(Sparse, [i in 1:m-1], x[2*i+1] - x[2*i-1] >= y[i,i+1]-1+1/m)

# constraints (4g)
#@constraint(Sparse, [i in 1:m-1, j in i+1:m], x[2*j]-x[2*i] >= y[i,j]-1+eps)

@constraint(Sparse, [i in 1:m-1, j in i+1:m], x[2*j]-x[2*i] >= y[i,j]-1+1/m)

#
@constraint(Sparse, x[0] == 1)
@constraint(Sparse, x[2*m+1] == 1)
@constraint(Sparse, [j in 1:m], y[0,j] == 0)
@constraint(Sparse, [j in 0:m], y[j,0] == 1)
@constraint(Sparse, [j in 0:m], y[m+1,j] == 1)

# 
@constraint(Sparse, x[1] == z)
@constraint(Sparse, [i in 1:m], x[2*i] >= z)

# constraints (4h)
@constraint(Sparse, [i in 1:m-1, j in i+1:m], x[2*j]-x[2*i] <= y[i,j])

# constraints (4i)
@constraint(Sparse, [i in 1:m, j in 1:i-1], y[i,j]==1-y[j,i])

# constraints (4j)
@constraint(Sparse, [i in 1:m], y[i,i]==1)

# constraints (4k)
@constraint(Sparse, z>= 1/m)

# constraints (4l)
@constraint(Sparse, [i in 1:m, j in 1:m, k in 1:m], y[i,j] + y[j,k] -1 <= y[i,k])

# constraints (4m)
@constraint(Sparse, [i in 1:m, j in 1:m, k in 1:m], y[i,j] + y[j,k] >= y[i,k])

# constraint (4n)
@constraint(Sparse, sum(y[i,j] for i in 1:m for j in 1:m) == m*(m+1)/2)


@constraint(Sparse, [i in 1:m], x[2*i-1] <= z + (i-1)/m)

@constraint(Sparse, [i in 1:m], x[2*i-1] >= i/m -z)


@objective(Sparse, Min, z)

optimize!(Sparse)

# to save the solution as a vector in file - the name follows the concept Sample2d_cont_m
output_file= open("/scratchbeta/clementf/OC_30.jl", "w")
write(output_file, "x = ")
show(output_file, value.(x))
close(output_file)
