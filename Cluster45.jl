using JuMP
using Gurobi
log_file_path = "/scratchbeta/clementf/45.txt"
# 2d continuous case - assignment version

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
m =5
epsi=0.0001


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



# constraints (5f)
@constraint(Sparse, [i in 1:m-1], x[i+1] - x[i] >= epsi)
@constraint(Sparse, [i in 1:m-1], y[i+1] - y[i] >= epsi)
 
#
@constraint(Sparse, a[1,m+1] == 1)
@constraint(Sparse, a[m+1,1] == 1)
@constraint(Sparse, [i in 2:m+1], a[i,m+1] == 0)
@constraint(Sparse, [j in 2:m+1], a[m+1,j] == 0)
 

#@constraint(Sparse, y[1] == z)

#
@constraint(Sparse, x[m+1] == 1)
@constraint(Sparse, y[m+1] == 1)

# Assignment constraints
@constraint(Sparse, [i in 1:m], sum(a[i,j] for j in 1:m) == 1)
@constraint(Sparse, [j in 1:m], sum(a[i,j] for i in 1:m) == 1)

@constraint(Sparse, sum(a[i,j] for i in 1:m, j in 1:m) == m)


# constraints (5k)
@constraint(Sparse, z>= 1/m)

@constraint(Sparse, [i in 1:m-1, j in i+1:m,k in 1:m], x[j]-x[i] >= 1/m - (1-sum(a[i,u]-a[j,u] for u in 1:k))) 

@constraint(Sparse, [i in 1:m-1, j in i+1:m,k in 1:m], y[j]-y[i] >= 1/m - (1-sum(a[u,i]-a[u,j] for u in 1:k))) 



@constraint(Sparse, [i in 1:m], x[i] <= z + (i-1)/m)

@constraint(Sparse, [i in 1:m], x[i] >= i/m -z)

@constraint(Sparse, [i in 1:m], y[i] <= z + (i-1)/m)

@constraint(Sparse, [i in 1:m], y[i] >= i/m -z)


@objective(Sparse, Min, z)

optimize!(Sparse)

# to save the solution as a vector in file - the name follows the concept Sample2d_cont_m
output_file= open("/scratchbeta/clementf/OC_45.jl", "w")
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