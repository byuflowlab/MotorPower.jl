using MotorPower
using Base.Test

#MOTOR

#maxon 305013 EC-4pole 30 Ø30 mm, brushless, 200 Watt
# function motorval(threshold)
    threshold = 0.0001
    Vm = 24
    I0 = .728
    Imax = 7.58
    eta_max = .89
    Kv = 700 #rpm/volt
    Kv = Kv * pi/30

    Q, omega, Po, eta_M, mass_M, Ro = MotorPower.motorVI(Vm,Imax,Kv,I0;numMotors=1,Case=0,mtype = "hobby")
    RPM = omega * 30/pi

    # Nominalvoltage=24V
    # Noloadspeed=16700rpm
    # Noloadcurrent=728mA
    Nominalspeed=16100 #rpm
    Nominaltorquemaxcontinuoustorque=.0946 #Nm
    # Nominalcurrent(max.continuouscurrent)=7.58A
    # Stalltorque=3220mNm
    # Stallcurrent=236A
    Maxefficiency=.89
    # Characteristics
    Terminalresistance=0.102#Ω
    # Terminalinductance=0.016mH
    # Torqueconstant=13.6mNm/A
    # Speedconstant=700rpm/V
    # Speed/torquegradient=5.21rpm/mNm
    # Mechanicaltimeconstant=1.82ms
    # Rotorinertia=33.3gcm²
    # Thermaldata
    # Thermalresistancehousing-ambient=7.4K/W
    # Thermalresistancewinding-housing=0.209K/W
    # Thermaltimeconstantwinding=2.11s
    # Thermaltimeconstantmotor=1180s
    # Ambienttemperature=-20...+100°C
    # Max.windingtemperature=+155°C
    # Mechanicaldata
    # Bearingtype=ballbearings
    # Max.speed=25000rpm
    # Axialplay=0-0.14mm
    # Maxaxialload(dynamic)=5.5N
    # Maxforceforpressfits(static)=73N
    # (static,shaftsupported)=1300N
    # Max.radialload=25N,5mmfromflange
    # Otherspecifications
    # Numberofpolepairs=2
    # Numberofphases=3
    # Numberofautoclavecycles=0
    # Product
    Weight=300 #g
println("HOBBY")
    V2, Im2, Pshaft2, eta_M2, mass_M2, Ro2 = MotorPower.motorVI(Nominaltorquemaxcontinuoustorque,Nominalspeed*pi/30,Kv,I0;numMotors=1,Case=1,mtype = "hobby")
    println("Omega1: $omega Q1: $Q V1: $Vm Im1: $Imax Pshaft1: $Po eta_M1: $eta_M mass_M: $mass_M Ro1: $Ro")
    println("Omega2: $(Nominalspeed*pi/30) Q2: $Nominaltorquemaxcontinuoustorque V2: $V2 Im2: $Im2 Pshaft2: $Pshaft2 eta_M2: $eta_M2 mass_M2: $mass_M2 Ro2: $Ro2 ")


    println()
    println("Motor Model Validation Against Maxon 305013 Brushless Motor:")
    println("Motor Model Case: V and I in")
    println("Motor Efficiency Differs by: $((eta_M-Maxefficiency)/Maxefficiency*100)%")
    println("Motor Torque Differs by: $((Q-Nominaltorquemaxcontinuoustorque)/Nominaltorquemaxcontinuoustorque*100)%")
    println("Motor RPM Differs by: $((RPM-Nominalspeed)/Nominalspeed*100)%")
    println("Motor Mass Differs by: $((mass_M*1000-Weight)/Weight*100)%")
    println("Motor Ro Differs by: $((Ro*1000-Terminalresistance)/Terminalresistance*100)%")

    println()
    println("Motor Model Case: Q and Ω in")
    println("Motor Efficiency Differs by: $((eta_M2-Maxefficiency)/Maxefficiency*100)%")
    println("Motor Voltage Differs by: $((V2-Vm)/Vm*100)%")
    println("Motor Current Differs by: $((Im2-Imax)/Imax*100)%")
    println("Motor Mass Differs by: $((mass_M2*1000-Weight)/Weight*100)%")
    println("Motor Ro Differs by: $((Ro2*1000-Terminalresistance)/Terminalresistance*100)%")

println("\n ASTROFLIGHT")
Q, omega, Po, eta_M, mass_M, Ro = MotorPower.motorVI(Vm,Imax,Kv,I0;numMotors=1,Case=0,mtype = "astroflight")
V2, Im2, Pshaft2, eta_M2, mass_M2, Ro2 = MotorPower.motorVI(Nominaltorquemaxcontinuoustorque,Nominalspeed*pi/30,Kv,I0,numMotors=1,Case=1,mtype ="astroflight")
println("Omega1: $omega Q1: $Q V1: $Vm Im1: $Imax Pshaft1: $Po eta_M1: $eta_M mass_M: $mass_M Ro1: $Ro")
println("Omega2: $(Nominalspeed*pi/30) Q2: $Nominaltorquemaxcontinuoustorque V2: $V2 Im2: $Im2 Pshaft2: $Pshaft2 eta_M2: $eta_M2 mass_M2: $mass_M2 Ro2: $Ro2 ")


println()
println("Motor Model Validation Against Maxon 305013 Brushless Motor:")
println("Motor Model Case: V and I in")
println("Motor Efficiency Differs by: $((eta_M-Maxefficiency)/Maxefficiency*100)%")
println("Motor Torque Differs by: $((Q-Nominaltorquemaxcontinuoustorque)/Nominaltorquemaxcontinuoustorque*100)%")
println("Motor RPM Differs by: $((RPM-Nominalspeed)/Nominalspeed*100)%")
println("Motor Mass Differs by: $((mass_M*1000-Weight)/Weight*100)%")
println("Motor Ro Differs by: $((Ro*1000-Terminalresistance)/Terminalresistance*100)%")

println()
println("Motor Model Case: Q and Ω in")
println("Motor Efficiency Differs by: $((eta_M2-Maxefficiency)/Maxefficiency*100)%")
println("Motor Voltage Differs by: $((V2-Vm)/Vm*100)%")
println("Motor Current Differs by: $((Im2-Imax)/Imax*100)%")
println("Motor Mass Differs by: $((mass_M2*1000-Weight)/Weight*100)%")
println("Motor Ro Differs by: $((Ro2*1000-Terminalresistance)/Terminalresistance*100)%")

#GEARBOX

#maxon 305013 EC-4pole 30 Ø30 mm, brushless, 200 Watt
# function motorval(threshold)
    threshold = 0.0001
    Vm = 24
    I0 = .728
    Imax = 7.58
    eta_max = .89
    Kv = 700 #rpm/volt
    Kv = Kv * pi/30

    Q, omega, Po, eta_M, mass_M, Ro = MotorPower.motorVI(Vm,Imax,Kv,I0;numMotors=1,Case=0,mtype = "hobby")
    RPM = omega * 30/pi

    # Nominalvoltage=24V
    # Noloadspeed=16700rpm
    # Noloadcurrent=728mA
    Nominalspeed=16100 #rpm
    Nominaltorquemaxcontinuoustorque=.0946 #Nm
    # Nominalcurrent(max.continuouscurrent)=7.58A
    # Stalltorque=3220mNm
    # Stallcurrent=236A
    Maxefficiency=.89
    # Characteristics
    Terminalresistance=0.102#Ω
    # Terminalinductance=0.016mH
    # Torqueconstant=13.6mNm/A
    # Speedconstant=700rpm/V
    # Speed/torquegradient=5.21rpm/mNm
    # Mechanicaltimeconstant=1.82ms
    # Rotorinertia=33.3gcm²
    # Thermaldata
    # Thermalresistancehousing-ambient=7.4K/W
    # Thermalresistancewinding-housing=0.209K/W
    # Thermaltimeconstantwinding=2.11s
    # Thermaltimeconstantmotor=1180s
    # Ambienttemperature=-20...+100°C
    # Max.windingtemperature=+155°C
    # Mechanicaldata
    # Bearingtype=ballbearings
    # Max.speed=25000rpm
    # Axialplay=0-0.14mm
    # Maxaxialload(dynamic)=5.5N
    # Maxforceforpressfits(static)=73N
    # (static,shaftsupported)=1300N
    # Max.radialload=25N,5mmfromflange
    # Otherspecifications
    # Numberofpolepairs=2
    # Numberofphases=3
    # Numberofautoclavecycles=0
    # Product
    Weight=300 #g
println("HOBBY")
    V2, Im2, Pshaft2, eta_M2, mass_M2, Ro2 = MotorPower.motorVI(Nominaltorquemaxcontinuoustorque,Nominalspeed*pi/30,Kv,I0;numMotors=1,Case=1,mtype = "hobby")
    println("Omega1: $omega Q1: $Q V1: $Vm Im1: $Imax Pshaft1: $Po eta_M1: $eta_M mass_M: $mass_M Ro1: $Ro")
    println("Omega2: $(Nominalspeed*pi/30) Q2: $Nominaltorquemaxcontinuoustorque V2: $V2 Im2: $Im2 Pshaft2: $Pshaft2 eta_M2: $eta_M2 mass_M2: $mass_M2 Ro2: $Ro2 ")


    println()
    println("Motor Model Validation Against Maxon 305013 Brushless Motor:")
    println("Motor Model Case: V and I in")
    println("Motor Efficiency Differs by: $((eta_M-Maxefficiency)/Maxefficiency*100)%")
    println("Motor Torque Differs by: $((Q-Nominaltorquemaxcontinuoustorque)/Nominaltorquemaxcontinuoustorque*100)%")
    println("Motor RPM Differs by: $((RPM-Nominalspeed)/Nominalspeed*100)%")
    println("Motor Mass Differs by: $((mass_M*1000-Weight)/Weight*100)%")
    println("Motor Ro Differs by: $((Ro*1000-Terminalresistance)/Terminalresistance*100)%")

    println()
    println("Motor Model Case: Q and Ω in")
    println("Motor Efficiency Differs by: $((eta_M2-Maxefficiency)/Maxefficiency*100)%")
    println("Motor Voltage Differs by: $((V2-Vm)/Vm*100)%")
    println("Motor Current Differs by: $((Im2-Imax)/Imax*100)%")
    println("Motor Mass Differs by: $((mass_M2*1000-Weight)/Weight*100)%")
    println("Motor Ro Differs by: $((Ro2*1000-Terminalresistance)/Terminalresistance*100)%")

println("\n ASTROFLIGHT")
Q, omega, Po, eta_M, mass_M, Ro = MotorPower.motorVI(Vm,Imax,Kv,I0;numMotors=1,Case=0,mtype = "astroflight")
V2, Im2, Pshaft2, eta_M2, mass_M2, Ro2 = MotorPower.motorVI(Nominaltorquemaxcontinuoustorque,Nominalspeed*pi/30,Kv,I0,numMotors=1,Case=1,mtype ="astroflight")
println("Omega1: $omega Q1: $Q V1: $Vm Im1: $Imax Pshaft1: $Po eta_M1: $eta_M mass_M: $mass_M Ro1: $Ro")
println("Omega2: $(Nominalspeed*pi/30) Q2: $Nominaltorquemaxcontinuoustorque V2: $V2 Im2: $Im2 Pshaft2: $Pshaft2 eta_M2: $eta_M2 mass_M2: $mass_M2 Ro2: $Ro2 ")


println()
println("Motor Model Validation Against Maxon 305013 Brushless Motor:")
println("Motor Model Case: V and I in")
println("Motor Efficiency Differs by: $((eta_M-Maxefficiency)/Maxefficiency*100)%")
println("Motor Torque Differs by: $((Q-Nominaltorquemaxcontinuoustorque)/Nominaltorquemaxcontinuoustorque*100)%")
println("Motor RPM Differs by: $((RPM-Nominalspeed)/Nominalspeed*100)%")
println("Motor Mass Differs by: $((mass_M*1000-Weight)/Weight*100)%")
println("Motor Ro Differs by: $((Ro*1000-Terminalresistance)/Terminalresistance*100)%")

println()
println("Motor Model Case: Q and Ω in")
println("Motor Efficiency Differs by: $((eta_M2-Maxefficiency)/Maxefficiency*100)%")
println("Motor Voltage Differs by: $((V2-Vm)/Vm*100)%")
println("Motor Current Differs by: $((Im2-Imax)/Imax*100)%")
println("Motor Mass Differs by: $((mass_M2*1000-Weight)/Weight*100)%")
println("Motor Ro Differs by: $((Ro2*1000-Terminalresistance)/Terminalresistance*100)%")

# end #function
@test 1 == 2
