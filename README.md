# MotorPower

# Installation

```julia
pkg> add https://github.com/byuflowlab/MotorPower.jl.git
```

# Testing
```julia
pkg> test MotorPower
```

# Example Usage

```julia
Vm = 24
I0 = 0.728
Imax = 7.58
eta_max = 0.89
Kv = 700 #rpm/volt
Kv = Kv * pi/30

Q, omega, Po, eta_M, mass_M, Ro = MotorPower.motorVI(Vm, Imax, Kv, I0; numMotors=1, Case=0, mtype = "hobby")
```

# I/O
```julia
"""
motorVI
Author: Kevin Moore
Date: 26 June 2017

Inputs:
V: volts
Im: amps
Kv: rad/s/volt
I0: amps
numMotors
Case: 
mtype:

Outputs:
Q: N-m
omega: rad/s
Pshaft: watts
eta_M: efficiency base 1
mass_M: kg
Ro: ohms

Method: 1st order model
Assumptions/Limitiations: thermal resistance increase neglected
References:
"""
```
