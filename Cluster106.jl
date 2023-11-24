using JuMP
using Gurobi
log_file_path = "/scratchbeta/clementf/106.txt"
# 2d case, M5, single lattice 

# 2d continuous case

# julia command: include("Sparse2_cont.jl")

# prerequisites in julia:

# using JuMP

# using Gurobi

# Define the model name: Sparse

# Define the model name: Sparse
Sparse = Model()

# Select the solver
set_optimizer(Sparse,Gurobi.Optimizer)

# Activate the nonconvex option for Gurobi
set_optimizer_attribute(Sparse, "NonConvex", 2)

# number of points to be located: m
set_optimizer_attribute(Sparse, "LogFile", log_file_path)
m =12

# minimum distance between points in x1 and x2 direction, and minimum distance from 0
eps = 0.0001

# rectangular box width that should contain at most one point, can be deactivated
w = 0.15

# definition of the continuous variables defining the points: x^i=(x[2i-1],x[2i]) for i=1:m
@variable(Sparse, 0<=x[1:2*m]<=1)

# definition of binary variables that identify the ordering of the points w.r.t. the x2-coordinate. y[i,j]=1 if x^i_2=x[2i]<x[2j]=x^2_j or if i=j, and zero otherwise
@variable(Sparse, y[1:m,1:m], Bin)

# continuous variable that takes on the value of the star-discrepancy
@variable(Sparse, z>=0)

#Variables for fractional parts
@variable(Sparse, k[1:m],Bin)

#Lattice variable-> change to table in higher dims
@variable(Sparse,1/m<=r<=1)


#constraint on lattice set
@constraint(Sparse,[i in 1:m], x[2*i-1]==(i-1)/m)




@constraint(Sparse,x[2]==0)
@constraint(Sparse,[i in 2:m], x[2*i]==x[2*i-2]+r-k[i])


#Constraints to define fractional part
@constraint(Sparse, [i in 2:m], x[2*i-2]+r-1 <=k[i])
@constraint(Sparse, [i in 2:m], x[2*i-2]+r>=k[i])




# constraints (4a)
@constraint(Sparse, [i in 1:m, j in 1:i], 1/m* sum(y[u,j] for u in 1:i) - x[2*i-1]*x[2*j] <= z + 1 - y[i,j])

# constraints (4b)
@constraint(Sparse, [i in 2:m, j in 1:i-1], -1/m* (sum(y[u,j] for u in 1:i-1) -1) + x[2*i-1]*x[2*j] <= z + 1 - y[i,j])

# constraint (4c)
@constraint(Sparse, x[1]*x[2] <= z)

# constraints (4d)
@constraint(Sparse, [j in 1:m], -1/m* (sum(y[u,j] for u in 1:m) - 1) + x[2*j] <= z)

# constraints (4e)
@constraint(Sparse, [i in 1:m], -(i-1)/m + x[2*i-1] <= z)

# constraints (4f)
@constraint(Sparse, [i in 1:m-1], x[2*i+1] - x[2*i-1] >= eps)

# constraints (4g)
@constraint(Sparse, [i in 1:m-1, j in i+1:m], x[2*j]-x[2*i] >= y[i,j]-1+eps)

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



@objective(Sparse, Min, z)

optimize!(Sparse)

# to show the solution: 
 #objective_value(Sparse)
 #value.(r)
 #solution_summary(Sparse)

#compute_conflict!(Sparse)
#iis_model, _ = copy_conflict(Sparse)
#print(iis_model)

 #to save the solution as a vector in file - the name follows the concept Sample2d_cont_m
output_file= open("/scratchbeta/clementf/OC_106.jl", "w")
write(output_file, "x = ")
show(output_file, value.(x))
write(output_file, "\n")
write(output_file, "r = ")
show(output_file, value.(r))

write(output_file, "\n")
close(output_file)