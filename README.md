# Constructing Optimal \( L_{\infty} \) Star Discrepancy Sets

This repository contains the code used to generate the optimal \( L_{\infty} \) star discrepancy sets presented in the paper *"Constructing Optimal \( L_{\infty} \) Star Discrepancy Sets"* by François Clément, Carola Doerr, Kathrin Klamroth, and Luís Paquete.

### Requirements
[Julia](https://julialang.org/) is required to run the code. The code was tested with Julia 1.11.0.

### Running the code
The following Julia packages are required:
- [JuMP](https://jump.dev/JuMP.jl/stable/). The code was tested with JuMP 1.23.2.
- [Gurobi](https://www.gurobi.com/). The code was tested with Gurobi 1.3.1.

### Preparing the Environment

First, you can build the project with the following command:
```bash
julia --project=.
```

Then, open Julia and install the required packages. In Julia, switch to package mode by typing `]`, and then enter the following commands:
```julia
add JuMP
add Gurobi
```
Exit package mode by pressing `backspace`.

To use Gurobi, you need a valid license. If you are using the academic version, you can obtain a license by registering through the link below
[Gurobi Registration](https://portal.gurobi.com/iam/register/)
and then requesting an academic license through the link below:
[Gurobi License](https://portal.gurobi.com/iam/licenses/request)

The academic license is valid for 90 days and can be extended afterward. Download the `gurobi.lic` file and place it in a directory, for example: `~/license/gurobi.lic`. You can set the environment variable using the following command:
```bash
export GRB_LICENSE_FILE=~/license/gurobi.lic
```
To set the environment variable permanently, add the command to your `.bashrc` (for bash users) or `.zshrc` (for zsh users):
```bash
echo "export GRB_LICENSE_FILE=~/license/gurobi.lic" >> ~/.bashrc
```
or 
```bash
echo "export GRB_LICENSE_FILE=~/license/gurobi.lic" >> ~/.zshrc
```

Finally, to run `Cluster10.jl`, use the following command if you are in the project directory:
```bash
julia --project Cluster10.jl
```
Alternatively, if you are outside the project directory, use:
```bash
julia --project=PATH_TO_PROJECT Cluster10.jl
```

### Optimal Sets for the \( L_{\infty} \) Star/Periodic/Extreme/Multiple-Corner Discrepancy

In general:
- 1 to 20 correspond to the continuous model with few constraints.
- 21 to 40 correspond to the continuous model with all constraints. Models 40_bis and 40_ter are the 21 and 22 point models.
- 41 to 60 correspond to the assignment model with critical box checks.
- 41nc to 60nc correspond to the assignment model without critical box checks.
- 61 to 68 correspond to the 3D assignment model.
- 69 to 85 correspond to the multiple-corner cases.
- 86 to 94 correspond to the extreme discrepancy.
- 95 to 103 correspond to the periodic discrepancy.
- 104 to 165 correspond to single-parameter and double-parameter lattices (for \( n = 11 \) to 40).

Feel free to contact me at [francois.clement@lip6.fr](mailto:francois.clement@lip6.fr) for more models, sets, or plots, as not everything was uploaded.

### Link to the Paper
- [arXiv](https://arxiv.org/pdf/2311.17463)