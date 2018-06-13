# MotorPower

[![Build Status](https://travis-ci.org/moore54/MotorPower.jl.svg?branch=master)](https://travis-ci.org/moore54/MotorPower.jl)

[![Coverage Status](https://coveralls.io/repos/moore54/MotorPower.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/moore54/MotorPower.jl?branch=master)

[![codecov.io](http://codecov.io/github/moore54/MotorPower.jl/coverage.svg?branch=master)](http://codecov.io/github/moore54/MotorPower.jl?branch=master)

# Installation

```julia

Pkg.clone("https://github.com/byuflowlab/MotorPower.jl.git")

```

# Testing
```julia

Pkg.test("MotorPower")

```

# Use

```julia

Vm = 24
I0 = .728
Imax = 7.58
eta_max = .89
Kv = 700 #rpm/volt
Kv = Kv * pi/30

Q, omega, Po, eta_M, mass_M, Ro = MotorPower.motorVI(Vm,Imax,Kv,I0;numMotors=1,Case=0,mtype = "hobby")


```

# I/O
```julia
"""
motorVI
Author: Kevin Moore
Date: 26 June 2017
Updates:
Units: SI
Inputs:
Q: N-m
omega: rad/s
Parameters:
Kv: rad/s/volt
Ro: ohms
I0: amps
numMotors: #
Constants:
Outputs:
V: volts
Im: amps
Pshaft: watts
eta_M: efficiency base 1
mass_M: kg
Method: 1st order model
Assumptions/Limitiations: thermal resistance increase neglected
References:
"""
```
