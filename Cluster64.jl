using JuMP
using Gurobi
log_file_path = "./logs/64.txt"
# 3d continuous case, Model 5 - assignment version

# julia command: include("M5_cont3d.jl")

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

# number of points to be located: m
set_optimizer_attribute(Sparse, "LogFile", log_file_path)
m =4

# minimum distance between points in x1 and x2 direction, and minimum distance from 0
eps = 0.0001*1/m


# definition of the continuous variables defining the x-coordinates of points, in non-decreasing order, index m+1 for the dummy points, vlaue 1
@variable(Sparse, 0<=x[1:m+1]<=1)

# definition of the continuous variables defining the y-coordinates of points, in non-decreasing order, index m+1 for the dummy points, vlaue 1
@variable(Sparse, 0<=y[1:m+1]<=1)

# definition of the continuous variables defining the z-coordinates of points, in non-decreasing order, index m+1 for the dummy points, vlaue 1
@variable(Sparse, 0<=z[1:m+1]<=1)

# to avoid cubic terms
@variable(Sparse, 0<=q[1:m+1,1:m+1]<=1)


# definition of binary variables that identify the assigment of x- to y-components
@variable(Sparse, a[1:m,1:m,1:m], Bin)

# continuous variable that takes on the value of the star-discrepancy
@variable(Sparse, d>=0)

# constraints (5a)
@constraint(Sparse, [i in 1:m, j in 1:m, k in 1:m], 1/m* sum(a[u,v,w] for u in 1:i, v in 1:j, w in 1:k) - q[i,j]*z[k] <= d)

# constraints (5b)
@constraint(Sparse, [i in 1:m+1, j in 1:m+1, k in 1:m+1], -1/m* sum(a[u,v,w] for u in 1:i-1, v in 1:j-1, w in 1:k-1) + q[i,j]*z[k] <= d)

# quadratic terms
@constraint(Sparse, [i in 1:m+1, j in 1:m+1], q[i,j] == x[i]*y[j])

# constraints (5f)
@constraint(Sparse, [i in 1:m-1], x[i+1] - x[i] >= eps)
@constraint(Sparse, [i in 1:m-1], y[i+1] - y[i] >= eps)
@constraint(Sparse, [i in 1:m-1], z[i+1] - z[i] >= eps)

# 
@constraint(Sparse, x[1] == d)
@constraint(Sparse, y[1] == d)
@constraint(Sparse, z[1] == d)

#
@constraint(Sparse, x[m+1] == 1)
@constraint(Sparse, y[m+1] == 1)
@constraint(Sparse, z[m+1] == 1)

# Assignment constraints
@constraint(Sparse, [i in 1:m], sum(a[i,j,k] for j in 1:m, k in 1:m) == 1)
@constraint(Sparse, [j in 1:m], sum(a[i,j,k] for i in 1:m, k in 1:m) == 1)
@constraint(Sparse, [k in 1:m], sum(a[i,j,k] for i in 1:m, j in 1:m) == 1)


# constraints (5k)
@constraint(Sparse, d>= 1/m)


@objective(Sparse, Min, d)

optimize!(Sparse)


# to save the solution as a vector in file - the name follows the concept Sample2d_cont_m
output_file= open("./outputs/OC_64.jl", "w")
write(output_file, "x = ")
show(output_file, value.(x))
close(output_file)




