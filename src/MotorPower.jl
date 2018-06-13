module MotorPower
using Dierckx
export shigleygear,planetarygear

__precompile__()

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
function motormass(Im,Kv,Vm,numMotors=1,mtype = "hobby") #Kv in is rad/s/V
    if mtype == "hobby" #TODO: I think that the units for the original data for R0 are incorrect, should be ohms and not mOhms
        k_Imax = [136.24,6.15153,-0.186447,0.00131255,-0.00304932,6.66054e-5] #TODO: revisit fit with cross validation
        mass_M  = (k_Imax[1] + k_Imax[2]*Im/numMotors + k_Imax[3]*(Kv*30/pi) + k_Imax[4]*(Im/numMotors).^2 + k_Imax[5]*Im/numMotors.*(Kv*30/pi) + k_Imax[6]*(Im/numMotors).^2)/1000 #This fit is for Kv - RPM/V
        mass_M = mass_M * numMotors
    end

    if mtype == "astroflight"
        mass_M = 2.464*Im/numMotors./(Kv*30/pi) + 0.368 #Kg, kv in RPM/V
        mass_M = mass_M * numMotors
    end

    if mtype == "FB"
        specificPower = 0.6 #kW/Kg
        mass_M = Im*Vm/specificPower #Kg
        mass_M = mass_M * numMotors
    end

    return mass_M
end #motormass

function motorVI(input1,input2,Kv,I0;numMotors=1,Case=0,mtype = "hobby")
    Vmax = 40000/(Kv*30/pi)

    if mtype == "hobby"
        k_params = [0.000144198,7.73731e-5,2.17626e-7,-3.77547e-5,-5.66064e-7,3.1259e-12,-1.29173e-7,1.4195e-7,9.93959e-11,-1.6806e-14]
        Ro = k_params[1] + k_params[2]*I0 + k_params[3]*(Kv*30/pi) + k_params[4]*I0.^2 + k_params[5]*I0.*(Kv*30/pi) + k_params[6]*(Kv*30/pi).^2 + k_params[7]*I0.^3 + k_params[8]*I0.^2.*(Kv*30/pi) + k_params[9]*I0.*(Kv*30/pi).^2 + k_params[10]*(Kv*30/pi).^3
        tune = Ro*.2
        Ro = Ro-tune
        Ro = 1
    end

    if mtype == "astroflight" || mtype == "FB"
        Ro = .0467*I0.^-1.892 #excel fit, TODO: assume FM motor is similar
    end

    if Case == 1
        Q = input1
        omega = input2
        #R2= Ro.*alpha.*delTmax./Imax^2  # include temperature and peak effects
        Ri= Ro#+R2.*I^2

        # Current Model
        Ii=I0+Kv.*Q #Kv in rad/s/V

        # Voltage Model
        Vm=omega./Kv
        V=Vm+Ri.*Ii

        # Derived Relations
        Pshaft=((V-(omega./Kv)).*(1.0./Ri)-I0).*(omega./Kv)
        eta_M=(1.0-((I0.*Ri)./(V-omega./Kv))).*(omega./(V.*Kv))
        Pm=Q.*omega./eta_M
        Im=Pm./V

        # Motor mass
        mass_M = motormass(Im,Kv,V,numMotors,mtype)

        # #Prevent motor from generating power
        # if Vm < 0
        #     Vm = 0
        # end
        # if Im <0
        #     Im = 0
        # end

        return  V, Im, Pshaft, eta_M, mass_M, Ro, Vmax
    else #Adapted from University of Auburn Master's thesis
        Vm = input1
        Im = input2

        #R2= Ro.*alpha.*delTmax./Imax^2  # include temperature and peak effects
        Ri= Ro#+R2.*I^2
        N_Pol = 12
        N_Phase = 3
        omegaMax = Vm*Kv
        L = 2/(N_Pol*omegaMax)*(Vm-Ri*I0)
        Tem = (N_Phase*N_Pol)/2*L*Im
        omega = (Vm/(N_Pol*L/2)-Ri /(N_Phase*(N_Pol*L/2)^2)*Tem)
        Kt = 1/Kv
        Q = Kt*Im
        Pi = Vm*Im
        Po =Q*omega#(Vm-Im*Ri)*(Im-I0) #TODO: this can become very wrong and be exploited by the optimizer: use Q*omega for now
        eta_M = Po/Pi

        mass_M = motormass(Im,Kv,Vm,numMotors,mtype)

        return  Q, omega, Po, eta_M, mass_M, Ro, Vmax
    end
end #motorVI

"""
motorcontroller

Author: Kevin Moore
Date: 26 June 2017

Updates:

Units: SI

Inputs:
Vm: volts
Im: amps

Parameters:

Constants:

Outputs:
eta_E: efficiency base 1
mass_E: kg

Method: Empirical fits, ohms law

Assumptions/Limitiations: accuracy of empirical data

References: http://www.drivecalc.de
"""

function ESC(Vm, Im;esctype="hobby")
    if esctype=="hobby" #From drivecalc, also consistent with astroflight hobby esc's
        mass_E = (7.1261*e^(.0114.*Im))/1000 #Kg
        R_E = 130.36*Im^(-0.9) / 1000 #ohms
        eta_E = (Vm-(Im*R_E))/Vm
    elseif esctype=="FB"
        specificPower = 4444.0 #W/Kg
        mass_E = Vm*Im/specificPower #Assume linear scaling
        eta_E = 0.97 #TODO...
    elseif esctype=="AstroFlightHighVoltage"
        specificPower = 22059.0 #W/Kg
        mass_E = Vm*Im/specificPower #Assume linear scaling
        eta_E = 0.97 #TODO...
    else #TODO... add more

    end

    return mass_E, eta_E
end #esc



"""
motorVI

Author: Kevin Moore
Date: 26 June 2017

Updates:

Units: SI

Inputs:
RPMi: RPM
RPMo: RPM
Pin: watts into pinion
Tprop: N prop thrust
Dp: m pinion diameter
F: m gears' face width
Pd: teeth/meter
PAR: parameters

Parameters:
PAR[:gearPitch] = 20*pi/180
PAR[:Cp] = 2300 sqrt.(psi) #steel # must review entire gearbox model if changed
PAR[:Hbp] = 240 #brindell hardness pinion
PAR[:Hbg] = 200 #brindell hardness gear
PAR[:rhoSteel] = 8050 #kg/m3
PAR[:rhoAl] = 2800 #kg/m3
PAR[:SF] = 1.25 #safety factor
PAR[:bearPerRod] = 2

Constants:

Outputs:
M_b: kg
plateArea: m2 (for gearbox drag)
Qgb: Nm output torque
cpb: pinion bending constraint
cgb: gear bending constraint
cpw: pinion wear constraint
cgw: gear wear constraint

Method: Shigely

Assumptions/Limitiations: changing materials requires changing much of the model

References: Shigley 14-4
"""
function shigleygear(RPMi, RPMo, Pin, Tprop, Dp, F, Pd,gearPitch,Cp,Hbp,Hbg,rhoSteel,rhoAl,SF,bearPerRod,Ndays)

    #--- Unpack parameters ---#
    # gearPitch =PAR[:gearPitch]
    # Cp = PAR[:Cp]#steel # must review entire gearbox model if changed
    # Hbp = PAR[:Hbp]#brindell hardness pinion
    # Hbg = PAR[:Hbg]#brindell hardness gear
    # rhoSteel = PAR[:rhoSteel]#kg/m3
    # rhoAl = PAR[:rhoAl]#kg/m3
    # SF =PAR[:SF] #safety factor
    # bearPerRod = PAR[:bearPerRod]
    # Ndays = PAR[:Ndays]

    # ----- Gear Calculation ----- #
    Dp = Dp * 39.1901 # pinion diameter inches
    F = F * 39.1901 # gear face width inches
    Pd = Pd / 39.1901 # diametrical pitch teeth/inch
    Tprop = Tprop * 0.224809

    Np = RPMi * 60 * 24 * Ndays #full 90 days of running
    Ng = RPMo * 60 * 24 * Ndays #full 90 days of running

    Dg = RPMi/RPMo*Dp

    HP = Pin/745.7

    V = pi*Dp*RPMi/12 #ft/min


    Wt = 33000*HP/V #lbf

    Ko = 1
    Qv = 6

    B =  0.25*(12-Qv)^(2/3)
    A = 50+56*(1-B)

    Kv = ((A + sqrt.(V))/A)^B

    #lewis form factor table 14-2
    teeth = [12,13,14,15,16,17,18,19,20,21,22,24,26,28,30,34,38,43,50,60,75,100,150,300,400]
    Y = [0.245,0.261,0.277,0.29,0.296,0.303,0.309,0.312,0.322,0.328,0.331,0.337,0.346,0.353,0.359,0.371,0.384,0.397,0.409,0.422,0.435,0.447,0.46,0.472,0.48]
    spl_Y = Dierckx.Spline1D(teeth, Y)
    Tp = pi*Dp*Pd
    Tg = pi*Dg*Pd
    Yp = spl_Y(Tp) #lewis form factor
    Yg = spl_Y(Tg) #lewis form factor

    KSp = 1.192*(F*sqrt.(Yp)/Pd)^.0535 #size factor
    KSg = 1.192*(F*sqrt.(Yg)/Pd)^.0535 #size factor

    Cmc = 1 #uncrowned
    Cpfp = F/10/Dp-0.025
    Cpfg = F/10/Dg-0.025
    Cpm = 1
    Cma = .27
    Ce = 1

    Kmp = 1+Cmc*(Cpfp*Cpm+Cma*Ce)
    Kmg = 1+Cmc*(Cpfg*Cpm+Cma*Ce)

    Kb = 1 #const thickness gears

    Ynp = 1.3558*Np^-.0178
    Yng = 1.3558*Ng^-.0178

    #Table 14.10
    #reliability = [.9999,.999,.99,.9,.5]
    #Krel = [1.5,1.25,1,.85,.7]
    Kr = 1 # for R = .99
    mg = RPMi/RPMo
    Kt = 1
    Ks = 1
    Cf = 1
    mn = 1
    Jp = .35 #TODO may need to fit a curve...
    Jg = .4

    I = cos(gearPitch)*sin(gearPitch)/(2*mn)*mg/(mg+1)

    Stp = 102*Hbp+16400 #bending strength grade 2 hardened steel
    Stg = 102*Hbp+16400

    Scp = 349*Hbp+34300 #contact fatigue strength grade 2 hardened steel
    Scg = 349*Hbg+34300

    Znp = 1.4488*Np^-.023
    Zng = 1.4488*Ng^-.023

    Aprime = 8.98e-3*Hbp/Hbg-8.29e-3 # for 1.2<Hbp/Hbg<1.7
    Ch = 1+Aprime*(mg-1)

    #Pinion Tooth bending
    sigmap = Wt*Ko*Kv*Ks*Pd/F*Kmp*Kb/Jp
    SFbp = Stp*Ynp/(Kt*Kr)/sigmap

    #Gear Tooth Bending
    sigmag = Wt*Ko*Kv*Ks*Pd/F*Kmg*Kb/Jg
    SFbg = Stg*Yng/(Kt*Kr)/sigmag

    #Pinion Tooth Wear
    # println("Wt: $Wt Ko: $Ko Kv: $Kv Ks: $Ks Kmp: $Kmp Dp: $Dp F: $F Cf: $Cf I: $I ")
    sigmaCp = Cp*(Wt*Ko*Kv*Ks*Kmp/Dp/F*Cf/I)^0.5
    SFwp = Scp*Znp/(Kt*Kr)/sigmaCp

    #Gear Tooth Wear
    sigmaCg = Cp*(Wt*Ko*Kv*Ks*Kmg/Dp/F*Cf/I)^0.5
    SFwg = Scg*Zng/(Kt*Kr)/sigmaCg

    #Gear Masses
    gearVolume = pi*F/39.1901*((Dp/2/39.1901)^2+(Dg/2/39.1901)^2)
    gearMass = gearVolume * rhoSteel #kg

    # ----- Bearing Calculation ----- #
    xDp = Np/1e6
    xDg = Ng/1e6

    #C10p = 1.2*Tprop/bearPerRod/10*(xDp/(.02+4.439(1-.99)^(1/1.483)))^(1/3) #Pinion supported by motor
    C10g = 1.2*Tprop*SF/bearPerRod*(xDg/(.02+4.439(1-.99)^(1/1.483)))^(1/3)

    bearingID = [10,12,15,17,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95] #mm
    bearingOD = [30,32,35,40,47,52,62,72,80,85,90,100,110,120,125,130,140,150,160,170] #mm
    bearingWidth = [9,10,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,28,30,32] ##
    deepGrooveC10Rating = [5.07,6.98,7.8,9.56,12.7,14.0,19.5,25.5,30.7,33.2,35.1,43.6,47.5,55.9,61.8,66.3,70.2,83.2,95.6,108.0] #Kn

    spl_RatVWidth = Dierckx.Spline1D(deepGrooveC10Rating, bearingWidth)
    spl_WidthVID = Dierckx.Spline1D(bearingWidth,bearingID)
    spl_WidthVOD = Dierckx.Spline1D(bearingWidth,bearingOD)

    #bear_wp = spl_RatVWidth(C10p)/1000
    bear_wg = spl_RatVWidth(C10g)/1000

    #bear_IDp = spl_WidthVID(bear_wp)/1000
    bear_IDg = spl_WidthVID(bear_wg)/1000

    #bear_IDg = spl_WidthVID(bear_wg)/1000
    bear_ODg = spl_WidthVOD(bear_wg)/1000

    #bearMassp = pi*((bearODp/2)^2-(bearIDp/2)^2)*bear_wp*rhoSteel
    bearMassg = pi*((bear_ODg/2)^2-(bear_IDg/2)^2)*bear_wg*rhoSteel
    bearMass = bearPerRod*(bearMassg) #kg, 2 bearings of each

    # ----- Shaft Calculation ----- #
    shaftLen = bear_IDg * 6 # 4D spacing between bearings and 2D to attach prop TODO
    shaftMass = pi*(bear_IDg/2)^2 * shaftLen * rhoAl #kg

    #Mounting Plate Mass (designed like y shape)
    plateVol = (Dg+Dp)/39.1901 * bear_ODg*1.2 * bear_wg + (bear_wg*bear_ODg*1.2*Dg/39.1901)
    plateArea = (Dg+Dp)/39.1901 * bear_ODg*1.2 #m^2
    #slightly wider than the bearing, as long as the gears, same depth as bearing
    mountMass = plateVol*rhoAl #Kg TODO estimate stress?

    # ----- Outputs ----- #
    gearMass = gearMass*.6*.8 #Assume 40% is drilled out and inner sections are thinner by ~15% TODO:
    M_b = gearMass#+shaftMass#+bearMass+gearMass+mountMass #gearbox mass in Kg

    #constraints
    cpb = (SF-SFbp)#/SFbp
    cgb = (SF-SFbg)#/SFbg
    cpw = (SF-SFwp)#/SFwp
    cgw = (SF-SFwg)#/SFwg


    eta_GB=.95 #TODO
    # # set mass and everything else to 0 for gear ratio of 1 (no gearbox)
    # sharpness = 1000.0
    # x_smooth = mg*sharpness-sharpness
    # if  x_smooth < 1.0 && x_smooth > 0.0
    #     correction = 3*x_smooth^2 - 2*x_smooth^3
    #     M_b = M_b*correction
    #     plateArea = plateArea*correction
    #     eta_GB = eta_GB+(1-eta_GB)*(1-correction)
    #     # cpb = cpb*correction
    #     # cgb = cgb*correction
    #     # cpw = cpw*correction
    #     # cgw = cgw*correction
    #
    # end
    # x_smooth2 = 1/mg*sharpness-sharpness
    # if  x_smooth2 < 1.0 && x_smooth2 > 0.0
    #     correction = 3*x_smooth2^2 - 2*x_smooth2^3
    #     M_b = M_b*correction
    #     plateArea = plateArea*correction
    #     eta_GB = eta_GB+(1-eta_GB)*(1-correction)
    #     # cpb = cpb*correction
    #     # cgb = cgb*correction
    #     # cpw = cpw*correction
    #     # cgw = cgw*correction
    #
    # end

    Qgb = Pin/(RPMo*pi/30)*eta_GB

    return eta_GB,M_b,plateArea,Qgb,cpb,cgb,cpw,cgw
end #function


function planetarygear(Qin, ratio)
    M_b = (30.818.*Qin+1.1846)/1000 #kg
    eta_GB = .95 #TODO

    # # set mass and everything else to 0 for gear ratio of 1 (no gearbox)
    # sharpness = 1000.0
    # x_smooth = ratio*sharpness-sharpness
    # if  x_smooth < 1.0 && x_smooth > 0.0
    #     correction = 3*x_smooth^2 - 2*x_smooth^3
    #     M_b = M_b*correction
    #     eta_GB = eta_GB+(1-eta_GB)*(1-correction)
    # end
    #
    # x_smooth2 = 1/ratio*sharpness-sharpness
    # if  x_smooth2 < 1.0 && x_smooth2 > 0.0
    #     correction = 3*x_smooth2^2 - 2*x_smooth2^3
    #     M_b = M_b*correction
    #     eta_GB = eta_GB+(1-eta_GB)*(1-correction)
    # end

    return eta_GB, M_b
end

function wire_1(volts, amps, distance, coreType, wireDensity)

    if coreType==1 #ie a single wire

        # line fits from data from http://www.engineeringtoolbox.com/wire-gauges-d_419.html
        diameter = (.0359.*amps+.6777)/1000 #for diameter in mm, convert to meters  #R² = 0.99407
        wireVolume = pi*(diameter./2).^2 .* distance
        wireMass = wireVolume * wireDensity
        #copperWeightN = wireMass .* g
        resistancePerKm = 22.447*(diameter*1000).^-2.007 #for diameter in mm R² = 0.99948
        resistance = resistancePerKm /1000 .* distance #convert to per meter and multiply by meter

        powerTransEfficiency = 1 - amps.*resistance./volts
    else
        println("TODO: inclue different core types")
    end

    return wireMass, powerTransEfficiency
end #wire_1

end # module
