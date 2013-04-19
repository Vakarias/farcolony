{======(C) Copyright Aug.2009-2013 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FUG - geophysical unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2013, Jean-Francois Baconnet

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************************}
unit farc_fug_geophysical;

interface

uses
   Math

   ,farc_data_univ;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   calculate the asteroids belt's diameter
///</summary>
/// <param name="Distance">distance of the belt from its star</param>
/// <returns>the diameter in AU</returns>   
/// <remarks>format [x.xx]</remarks>
function FCFfG_AsteroidsBelt_CalculateDiameter( const Distance: extended ): extended;

///<summary>
///   calculate the orbital object's density
///</summary>
/// <param name="ObjectType">basic type of the object</param>
/// <param name="OrbitalZone">orbital zone in which the object is</param>
/// <returns>the density in kg</returns>   
/// <remarks>format [x.xxx]</remarks>
function FCFfG_Density_Calculation( 
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;

///<summary>
///   calculate the orbital object's diameter
///</summary>
/// <param name="ObjectType">basic type of the object</param>
/// <param name="OrbitalZone">orbital zone in which the object is</param>
/// <returns>the diameter in km</returns>   
/// <remarks>format [x.x]</remarks>
function FCFfG_Diameter_Calculation( 
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;

///<summary>
///   calculate the orbital object's escape velocity
///</summary>
/// <param name="Diameter">orbital object's diameter</param>
/// <param name="Mass">orbital object's mass</param>
/// <returns>the escape velocity in km/sec</returns>
/// <remarks>format [x.xx]</remarks>
function FCFfG_EscapeVelocity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;

///<summary>
///   calculate the orbital object's gravity
///</summary>
/// <param name="Diameter">orbital object's diameter</param>
/// <param name="Mass">orbital object's mass</param>
/// <returns>the gravity in gees</returns>
/// <remarks>format [x.xxx]</remarks>
function FCFfG_Gravity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;

///<summary>
///   calculate the orbital object's mass equivalent
///</summary>
/// <param name="Diameter">orbital object's diameter</param>
/// <param name="Density">orbital object's density</param>
/// <param name="isAsteroid">[=true]: specificity for asteroids</param>
/// <returns>the mass in Earth mass equivalent</returns>
/// <remarks>format [x.xxxx] for planets and [x.xxxxxxxxxx] for asteroids</remarks>
function FCFfG_Mass_Calculation(
   const Diameter
         , Density: extended;
   const isAsteroid: boolean
   ): extended;

///<summary>
///   calculate the orbital object's rotation period
///</summary>
/// <param name=""></param>
/// <param name=""></param>
/// <param name=""></param>
/// <returns>the rotation period in hours</returns>
/// <remarks>format [x.]</remarks>
function FCFfG_RotationPeriod_Calculation(
   const StarMass
         ,StarLuminosity
         ,OrbitalObjectDistance: extended
   ): extended;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_common_func
   ,farc_data_init;
//
//   ,farc_data_init
//   ,farc_data_planetarysurvey
//   ,farc_game_colony
//   ,farc_game_prodrsrcspots
//   ,farc_survey_functions
//   ,farc_ui_coredatadisplay
//   ,farc_univ_func
//   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFfG_AsteroidsBelt_CalculateDiameter( const Distance: extended ): extended;
{:Purpose: calculate the asteroids belt's diameter.
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   if Distance < 1.5
   then WorkingFloat:=FCFcF_Random_DoFloat + 0.5
   else if ( Distance >= 1.5 )
      and ( Distance < 20 )
   then WorkingFloat:=FCFcF_Random_DoInteger( 5 ) + 1
   else if Distance >= 20
   then WorkingFloat:=FCFcF_Random_DoInteger( 10 ) + 1;
   Result:=FCFcF_Round( rttCustom2Decimal, WorkingFloat );
end;

function FCFfG_Density_Calculation( 
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;
{:Purpose: calculate the orbital object's density.
   -Additions-
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   case ObjectType of
      oobtAsteroid:
      begin
         if OrbitalZone in[hzInner..hzIntermediary]
         then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01 )
         else if OrbitalZone = hzOuter
         then WorkingFloat:=( 0.1 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.005 ) ) * 0.5;
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;
      
      oobtTelluricPlanet:
      begin
         if OrbitalZone in[hzInner..hzIntermediary]
         then WorkingFloat:=0.3 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.01 )
         else if OrbitalZone = hzOuter
         then WorkingFloat:=0.1 + ( ( FCFcF_Random_DoInteger( 99 ) + 1 ) * 0.005 );
         if WorkingFloat<0.54
         then WorkingFloat:=0.54 +( FCFcF_Random_DoInteger( 99 ) * 0.001 );
         WorkingFloat:=WorkingFloat * FCCdiDensityEqEarth;
      end;
      
      oobtGaseousPlanet: WorkingFloat:=FCFcF_Random_DoInteger( 1351 ) + 579;
   end;
   Result:=round( WorkingFloat );
end;

function FCFfG_Diameter_Calculation( 
   const ObjectType: TFCEduOrbitalObjectBasicTypes;
   const OrbitalZone: TFCEduHabitableZones
   ): extended;
{:Purpose: calculate the orbital object's diameter.
   -Additions-
}
   var
      WorkingFloat: extended;
begin
   Result:=0;
   WorkingFloat:=0;
   case ObjectType of
      oobtAsteroid: WorkingFloat:=FCFcF_Random_DoInteger( 1987 ) + 12.5;
      
      oobtTelluricPlanet:
      begin
         case OrbitalZone of
            hzInner: WorkingFloat:=FCFcF_Random_DoInteger( 5110 ) + 2000;
            
            hzIntermediary: WorkingFloat:=FCFcF_Random_DoInteger( 29676 ) + 2324;
            
            hzOuter: WorkingFloat:=FCFcF_Random_DoInteger( 8520 ) + 2000;
         end;
      end;
      
      oobtGaseousPlanet: WorkingFloat:=FCFcF_Random_DoInteger( 130000 ) + 30000;
   end;
   Result:=FCFcF_Round( rttCustom1Decimal, WorkingFloat );
end;

function FCFfG_InclinationAxis_Calculation: extended;
begin
   {.axial tilt
        OCCA_revol:=0;
        if TabOrbit[OrbDBCounter].TypeAstre in [1..2] then TabOrbit[OrbDBCounter].InclAx:=0
        else if TabOrbit[OrbDBCounter].TypeAstre>5 then begin
            try
                OCCA_Proba:=random(99)+1;
            finally
                case OCCA_Proba of
                    1..20: OCCA_revol:=random(10);
                    21..40: OCCA_revol:=10+(random(9)+1);
                    41..60: OCCA_revol:=20+(random(9)+1);
                    61..80: OCCA_revol:=30+(random(9)+1);
                    81..100: OCCA_revol:=40+((random(99)+1)*1.4);
                end;
                if OCCA_revol>90 then TabOrbit[OrbDBCounter].PerRot:=-(TabOrbit[OrbDBCounter].PerRot);
            end;
                TabOrbit[OrbDBCounter].InclAx:=roundto(OCCA_revol,-1);
        end;}
end;

function FCFfG_EscapeVelocity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;
{:Purpose: calculate the orbital object's escape velocity.
}
   var
      CalculatedEscapeVelocity
      ,MassInKg
      ,RadiusInMeters: extended;
begin
   Result:=0;
   MassInKg:=Mass * FCCdiMassEqEarth;
   RadiusInMeters:=Diameter * 500;
   CalculatedEscapeVelocity:=sqrt( 2 * FCCdiGravitationalConst * MassInKg / sqr( RadiusInMeters ) ) / FCCdiMetersBySec_In_1G;
   Result:=FCFcF_Round( rttCustom2Decimal, CalculatedEscapeVelocity );
end;

function FCFfG_Gravity_Calculation(
   const Diameter
         ,Mass: extended
   ): extended;
{:Purpose: calculate the orbital object's gravity.
    Additions:
}
   var
      CalculatedGravity
      ,MassInKg
      ,RadiusInMeters: extended;
begin
   Result:=0;
   MassInKg:=Mass * FCCdiMassEqEarth;
   RadiusInMeters:=Diameter * 500;
   CalculatedGravity:=( FCCdiGravitationalConst * MassInKg / sqr( RadiusInMeters ) ) / FCCdiMetersBySec_In_1G;
   Result:=FCFcF_Round( rttCustom3Decimal, CalculatedGravity );
end;

function FCFfG_Mass_Calculation(
   const Diameter
         , Density: extended;
   const isAsteroid: boolean
   ): extended;
{:Purpose: calculate the orbital object's mass equivalent.
    Additions:
}
   var
      CalculatedMass
      ,RadiusInMeters: extended;
begin
   Result:=0;
   RadiusInMeters:=Diameter * 500;
   CalculatedMass:=( 4/3 * Pi * power( RadiusInMeters, 3 ) ) / FCCdiMassEqEarth;
   if not isAsteroid
   then Result:=FCFcF_Round( rttCustom4Decimal, CalculatedMass )
   else Result:=FCFcF_Round( rttMassAsteroid, CalculatedMass );
end;

function FCFfG_RotationPeriod_Calculation(
   const StarMass
         ,StarLuminosity
         ,OrbitalObjectDistance: extended
   ): extended;
begin
   {plan_mass:=0;
        if (TabOrbit[OrbDBCounter].TypeAstre=1)
            or (TabOrbit[OrbDBCounter].TypeAstre=2) then TabOrbit[OrbDBCounter].PerRot:=0
        else if TabOrbit[OrbDBCounter].TypeAstre>5 then begin
            try
                try
                    shortest_period_in_hrs:=sqrt((2*pi)/(0.19*TabOrbit[OrbDBCounter].Grav*9.81));
                    tidal_force:=(StarClone_Mass*26640000)/power(TabOrbit[OrbDBCounter].Distance*400,3);
                    OCCA_Proba:=1;
                finally
                    tidal_proba:=((0.83+(OCCA_Proba*0.03))*tidal_force*StarClone_Age)/6.6;
                end;
            finally
                if tidal_proba>1 then begin
                    try
                        if tidal_force>=1 then begin
                            if Taborbit[OrbDBCounter].Ecc<0.21 then OCCA_revol:=TabOrbit[OrbDBCounter].Revol*24
                            else if (TabOrbit[OrbDBCounter].Ecc>=0.21)
                                and (TabOrbit[OrbDBCounter].Ecc<0.39) then OCCA_revol:=(TabOrbit[OrbDBCounter].Revol/1.5)*24
                            else if (TabOrbit[OrbDBCounter].Ecc>=0.39)
                                and (TabOrbit[OrbDBCounter].Ecc<0.57) then OCCA_revol:=(TabOrbit[OrbDBCounter].Revol*0.5)*24
                            else if (TabOrbit[OrbDBCounter].Ecc>=0.57)
                                and (TabOrbit[OrbDBCounter].Ecc<0.72) then OCCA_revol:=(TabOrbit[OrbDBCounter].Revol/2.5)*24
                            else if (TabOrbit[OrbDBCounter].Ecc>=0.72)
                                and (TabOrbit[OrbDBCounter].Ecc<0.87) then OCCA_revol:=(TabOrbit[OrbDBCounter].Revol/3)*24
                            else if TabOrbit[OrbDBCounter].Ecc>=0.87 then OCCA_revol:=(TabOrbit[OrbDBCounter].Revol/3.5)*24;
                            if OCCA_revol<shortest_period_in_hrs then OCCA_revol:=shortest_period_in_hrs*(1+(4*random(10)));
                        end
                        else OCCA_revol:=0;
                    finally
                        TabOrbit[OrbDBCounter].PerRot:=roundto(OCCA_revol,-2);
                    end;
                end
                else if tidal_proba<=1 then begin
                    try
                        try
                            j:=1.46E-19;
                            eq_radius_in_cm:=TabOrbit[OrbDBCounter].Diam*100000;
                            if TabOrbit[OrbDBCounter].TypeAstre=6 then plan_mass:=TabOrbit[OrbDBCounter].Mass*10e20*1000
                            else if TabOrbit[OrbDBCounter].TypeAstre<>6 then plan_mass:=TabOrbit[OrbDBCounter].Mass
                                *5.976e24*1000;
                            k2:=((0.19*StarClone_Mass)/TabOrbit[OrbDBCounter].Distance)*TabOrbit[OrbDBCounter].Grav;
                        finally
                            OCCA_revol:=sqrt(2*j*plan_mass/(k2*sqr(eq_radius_in_cm)));
                            OCCA_revol:=1/((OCCA_revol/(2*pi))*3600);
                        end;
                        OCCA_Proba:=random(99)+1;
                        if TabOrbit[OrbDBCounter].TypeAstre<31 then begin
                            if OCCA_Proba <=35 then revol1:=1
                            else if (OCCA_Proba>35) and (OCCA_Proba<=55) then revol1:=1+(random(3)/10)
                            else if (OCCA_Proba>55) and (OCCA_Proba<=85) then revol1:=30+random(10)
                            else if OCCA_Proba>85 then revol1:=110+random(110);
                        end
                        else if TabOrbit[OrbDBCounter].TypeAstre>=31 then begin
                            if OCCA_Proba<=40 then revol1:=1
                            else if (OCCA_Proba>40) and (OCCA_Proba<=60) then revol1:=1+(random(6)/10)
                            else if OCCA_Proba>60 then revol1:=1+(random(10)/10);
                        end;
                        try
                            OCCA_revol:=OCCA_revol*revol1;
                        finally
                            if OCCA_revol<shortest_period_in_hrs then OCCA_revol:=shortest_period_in_hrs*(1+(4*random(10)));
                        end;
                    finally
                        TabOrbit[OrbDBCounter].PerRot:=roundto(OCCA_revol,-2); }
end;

//===========================END FUNCTIONS SECTION==========================================



end.
