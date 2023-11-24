using JuMP
using Gurobi
log_file_path = "/scratchbeta/clementf/72.txt"
# 2d continuous case - assignment version for 4-corner discrepancy

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
#set_optimizer_attribute(Sparse, "MIPGap", 0.0001)

# number of points to be located: m
set_optimizer_attribute(Sparse, "LogFile", log_file_path)
m =4

# definition of the continuous variables defining the x-coordinates of points, in non-decreasing order, index m+1 for the dummy points, value 1
@variable(Sparse, 0.00001<=x[1:m+1]<=1)

# definition of the continuous variables defining the y-coordinates of points, in non-decreasing order, index m+1 for the dummy points, value 1
@variable(Sparse, 0.00001<=y[1:m+1]<=1)


# definition of binary variables that identify the assigment of x- to y-components
@variable(Sparse, a[1:m+1,1:m+1], Bin)

# continuous variable that takes on the value of the star-discrepancy
@variable(Sparse, z>=0)

@constraint(Sparse, z<=0.9)


# constraints (5a) Extreme or Normal
@constraint(Sparse, [i in 1:m, j in 1:m], 1/m* sum(a[u,v] for u in 1:i, v in 1:j) - x[i]*y[j] <= z + (2- sum(a[u,j] for u in 1:i)-sum(a[i,v] for v in 1:j)))

# constraints (5b)
@constraint(Sparse, [i in 1:m+1, j in 1:m+1], -1/m* sum(a[u,v] for u in 1:i-1, v in 1:j-1) + x[i]*y[j] <= z + (2- sum(a[u,j] for u in 1:i-1)-sum(a[i,v] for v in 1:j-1)))


@constraint(Sparse, [i in 1:m, j in 1:m], 1/m* sum(a[v,u] for u in 1:j, v in i:m) - (1-x[i])*y[j] <= z )
@constraint(Sparse, [i in 1:m+1, j in 1:m+1], -1/m* sum(a[v,u] for u in 1:j-1, v in i+1:m) + (1-x[i])*y[j] <= z)

@constraint(Sparse, [i in 1:m, j in 1:m], 1/m* sum(a[u,v] for u in i:m, v in j:m) - (1-x[i])*(1-y[j]) <= z )
@constraint(Sparse, [i in 1:m+1, j in 1:m+1], -1/m* sum(a[u,v] for u in i+1:m, v in j+1:m) + (1-x[i])*(1-y[j]) <= z)

@constraint(Sparse, [i in 1:m, j in 1:m], 1/m* sum(a[v,u] for u in j:m, v in 1:i) - (1-y[j])*x[i] <= z )
@constraint(Sparse, [i in 1:m+1, j in 1:m+1], -1/m* sum(a[v,u] for u in j+1:m, v in 1:i-1) + x[i]*(1-y[j]) <= z)





# constraints (5f)
#@constraint(Sparse, [i in 1:m-1], x[i+1] - x[i] >= epsi)
#@constraint(Sparse, [i in 1:m-1], y[i+1] - y[i] >= epsi)
 
#
@constraint(Sparse, a[1,m+1] == 1)
@constraint(Sparse, a[m+1,1] == 1)
@constraint(Sparse, [i in 2:m+1], a[i,m+1] == 0)
@constraint(Sparse, [j in 2:m+1], a[m+1,j] == 0)

@constraint(Sparse, x[m+1] == 1)
@constraint(Sparse, y[m+1] == 1)

# Assignment constraints
@constraint(Sparse, [i in 1:m], sum(a[i,j] for j in 1:m) == 1)
@constraint(Sparse, [j in 1:m], sum(a[i,j] for i in 1:m) == 1)

@constraint(Sparse, sum(a[i,j] for i in 1:m, j in 1:m) == m)

#@constraint(Sparse, [i in 1:m], sum(a[1,j] for j in 1:i) <= sum(a[j,1] for j in 1:i))

# constraints (5k)
@constraint(Sparse, z>= 1/m)



@objective(Sparse, Min, z)

optimize!(Sparse)
output_file= open("/scratchbeta/clementf/OC_72.jl", "w")
write(output_file, "x = ")
show(output_file, value.(x))
write(output_file, "\n")
write(output_file, "y = ")
show(output_file, value.(y))
write(output_file, "\n")
write(output_file, "a = ")
show(output_file, value.(a))
write(output_file, "\n")
close(output_file)