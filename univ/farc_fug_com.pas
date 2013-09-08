{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

         Title:  FAR Colony
         Author: Jean-Francois Baconnet
         Project Started: August 16 2009
         Platform: Delphi
         License: GPLv3
         Website: http://farcolony.sourceforge.net/

         Unit: common FUG unit

 ============================================================================================
 ********************************************************************************************
 Copyright (c) 2009-2012, Jean-Francois Baconnet

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
unit farc_fug_com;

interface

uses
   forms
   ,SysUtils
   ,TypInfo;

procedure FCMfC_Initialize( isCreateWindow: boolean );

///<summary>
///   apply the changes when the AtmosphereEdit checkbox is checked or not
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmfC_AtmosphereEditTrigger_Update;

procedure FCmfC_AtmosphereGas_ArUpdate;

procedure FCmfC_AtmosphereGas_CH4Update;

procedure FCmfC_AtmosphereGas_COUpdate;

procedure FCmfC_AtmosphereGas_CO2Update;

procedure FCmfC_AtmosphereGas_H2Update;

procedure FCmfC_AtmosphereGas_H2OUpdate;

procedure FCmfC_AtmosphereGas_H2SUpdate;

procedure FCmfC_AtmosphereGas_HeUpdate;

procedure FCmfC_AtmosphereGas_N2Update;

procedure FCmfC_AtmosphereGas_NeUpdate;

procedure FCmfC_AtmosphereGas_NH3Update;

procedure FCmfC_AtmosphereGas_NO2Update;

procedure FCmfC_AtmosphereGas_NOUpdate;

procedure FCmfC_AtmosphereGas_O2Update;

procedure FCmfC_AtmosphereGas_O3Update;

procedure FCmfC_AtmosphereGas_SO2Update;

///<summary>
///   update the atmospheric pressure
///</summary>
procedure FCmfC_AtmosphericPressure_Update;

procedure FCmfC_HydrosphereArea_Update;

///<summary>
///   apply the changes when the HydrosphereEdit checkbox is checked or not
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmfC_HydrosphereEditTrigger_Update;

procedure FCmfC_HydrosphereType_Update;

///<summary>
///   update the orbital object density
///</summary>
procedure FCmfC_OrbitPicker_DensityUpdate;

///<summary>
///   update the orbital object diameter
///</summary>
procedure FCmfC_OrbitPicker_DiameterUpdate;

///<summary>
///   update the orbital object distance
///</summary>
procedure FCmfC_OrbitPicker_DistanceUpdate;

///<summary>
///   update the orbital object escape velocity
///</summary>
procedure FCmfC_OrbitPicker_EscapeVelUpdate;

///<summary>
///   update the orbital object gravity
///</summary>
procedure FCmfC_OrbitPicker_GravityUpdate;

///<summary>
///   update the orbital object inclination axis
///</summary>
procedure FCmfC_OrbitPicker_InclinationAxisUpdate;

///<summary>
///   update the orbital object magnetic field
///</summary>
procedure FCmfC_OrbitPicker_MagFieldUpdate;

///<summary>
///   update the orbital object mass
///</summary>
procedure FCmfC_OrbitPicker_MassUpdate;

///<summary>
///   update the orbital object type
///</summary>
procedure FCmfC_OrbitPicker_ObjectTypeUpdate;

///<summary>
///   update the orbital object rotation period
///</summary>
procedure FCmfC_OrbitPicker_RotationPeriodUpdate;

///<summary>
///   update the orbital object tectonic activity
///</summary>
procedure FCmfC_OrbitPicker_TectonicActivityUpdate;

///<summary>
///   update the orbital object token
///</summary>
procedure FCmfC_OrbitPicker_TokenUpdate;

///<summary>
///   update the current orbital object tab / orbital object picker
///</summary>
///   <param name="UpdateSat">[true] update also the satellites automatically, [false] prevent it, useful for satlist picker</param>
procedure FCmfC_OrbitPicker_UpdateCurrent( const UpdateSat: boolean );

///<summary>
///   update the atmosphere primary gas volume
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmfC_PrimaryGasVolume_Update;

procedure FCmfC_Region_Update;

procedure FCmfC_RegionMapClimate_Update;

procedure FCmfC_RegionMapLightColor_Update;

procedure FCmfC_RegionMapSeed_Update;

procedure FCMfC_RegionOceanicCoastal_Update;

procedure FCMfC_RegionRelief_Update;

///<summary>
///   update the satellite setting
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmC_SatPicker_Update;

///<summary>
///   update the current satellite object tab / satellite picker
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmfC_SatPicker_UpdateCurrent;


///<summary>
///   update the satpicker list according to the current setting
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmC_SatPicker_UpdateList;

procedure FCmfC_SatTrigger_Update;

procedure FCMfC_StarPicker_Update;

///<summary>
///   update the trace atmosphere check
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCmfC_TraceAtmosphereTrigger_Update;

implementation

uses
   farc_data_univ
   ,farc_fug_data
   ,farc_main
   ,farc_win_fug;

//=======================================END OF INIT========================================

procedure FCMfC_Initialize( isCreateWindow: boolean );
{:Purpose: initialize the FUG window and input/outputs + the data.
    Additions:
      -2013Apr06- *add: isCreateWindow parameter.
      -2010Jul13- *add: companion star 1 and 2 ui.
      -2010Jul11- *add: main star class, temperature, diameter, mass, luminosity, system type and orbit generation init.
                  *add: initialize FUG window size and location.
      -2010Jul04- *add: main star init.
}
begin
   if ( isCreateWindow )
      and ( FCWinFUG=nil ) then
   begin
      FCWinFUG:=TFCWinFUG.Create(Application);
      FCWinFUG.Width:=FCWinMain.Width;
      FCWinFUG.Height:=FCWinMain.Height;
      FCWinFUG.Left:=FCWinMain.Left;
      FCWinFUG.Top:=FCWinMain.Top;
   end;
   FCWinFUG.SSSG_StellarSysToken.Text:='stelsys';
   FCWinFUG.SSSG_LocationX.Text:='';
   FCWinFUG.SSSG_LocationY.Text:='';
   FCWinFUG.SSSG_LocationZ.Text:='';
   FCWinFUG.TMS_StarToken.Text:='star';
   FCWinFUG.TMS_StarClass.ItemIndex:=0;
   FCWinFUG.TMS_StarTemp.Text:='';
   FCWinFUG.TMS_StarDiam.Text:='';
   FCWinFUG.TMS_StarMass.Text:='';
   FCWinFUG.TMS_StarLum.Text:='';
   FCWinFUG.TMS_SystemType.ItemIndex:=0;
   FCWinFUG.TMS_OrbitGeneration.ItemIndex:=0;
   FCWinFUG.TMS_OrbitGenerationNumberOrbits.Enabled:=false;
   FCWinFUG.TMS_OrbitGenerationNumberOrbits.Text:='';
   FCWinFUG.TC1S_EnableGroupCompanion1.Checked:=false;
   FCWinFUG.TC1S_StarToken.Text:='star';
   FCWinFUG.TC1S_StarClass.ItemIndex:=0;
   FCWinFUG.TC1S_StarTemp.Text:='';
   FCWinFUG.TC1S_StarDiam.Text:='';
   FCWinFUG.TC1S_StarMass.Text:='';
   FCWinFUG.TC1S_StarLum.Text:='';
   FCWinFUG.TC1S_SystemType.ItemIndex:=0;
   FCWinFUG.TC1S_OrbitGeneration.ItemIndex:=0;
   FCWinFUG.TC1S_OrbitGenerationNumberOrbits.Enabled:=false;
   FCWinFUG.TC1S_OrbitGenerationNumberOrbits.Text:='';
   FCWinFUG.TC2S_EnableGroupCompanion2.Checked:=false;
   FCWinFUG.TC2S_StarToken.Text:='star';
   FCWinFUG.TC2S_StarClass.ItemIndex:=0;
   FCWinFUG.TC2S_StarTemp.Text:='';
   FCWinFUG.TC2S_StarDiam.Text:='';
   FCWinFUG.TC2S_StarMass.Text:='';
   FCWinFUG.TC2S_StarLum.Text:='';
   FCWinFUG.TC2S_SystemType.ItemIndex:=0;
   FCWinFUG.TC2S_OrbitGeneration.ItemIndex:=0;
   FCWinFUG.TC2S_OrbitGenerationNumberOrbits.Enabled:=false;
   FCWinFUG.TC2S_OrbitGenerationNumberOrbits.Text:='';
   FCWinFUG.TOO_StarPicker.ItemIndex:=0;
   setlength( FCDfdMainStarObjectsList, 1 );
   setlength( FCDfdComp1StarObjectsList, 1 );
   setlength( FCDfdComp2StarObjectsList, 1 );
   FCWinFUG.WF_XMLOutput.Clear;
   {.finally we display the window and set interface of the main FARC window if required}
   if not FCWinFUG.Visible
   then
   begin
      FCWinMain.FCWM_MMenu_G_New.Enabled:=false;
      FCWinMain.FCWM_MMenu_G_Cont.Enabled:=false;
      FCWinMain.FCWM_MMenu_G_Save.Enabled:=false;
      FCWinMain.FCWM_MMenu_G_FlushOld.Enabled:=false;
      FCWinFUG.Show;
      FCWinFUG.BringToFront;
   end;
   FCDduStarSystem:=nil;
   SetLength(FCDduStarSystem, 1);
   FCWinFUG.WF_ConfigurationMultiTab.ActivePageIndex:=0;
end;

procedure FCmfC_AtmosphereEditTrigger_Update;
{:Purpose: apply the changes when the AtmosphereEdit checkbox is checked or not.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_fug_isAtmosphereEdited:=FCWinFUG.COO_AtmosphereEdit.Checked;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_fug_isAtmosphereEdited:=FCWinFUG.COO_AtmosphereEdit.Checked;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_fug_isAtmosphereEdited:=FCWinFUG.COO_AtmosphereEdit.Checked;
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_isAtmosphereEdited:=FCWinFUG.COO_AtmosphereEdit.Checked;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_isAtmosphereEdited:=FCWinFUG.COO_AtmosphereEdit.Checked;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_isAtmosphereEdited:=FCWinFUG.COO_AtmosphereEdit.Checked;
      end;
   end;
   FCWinFUG.COO_TraceAtmosphereTrigger.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasH2.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasHe.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasCH4.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasNH3.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasH2O.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasNe.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasN2.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasCO.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasNO.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasO2.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasH2S.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasAr.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasCO2.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasNO2.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasO3.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_GasSO2.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_PrimGasVol.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
   FCWinFUG.COO_AtmosphericPressure.Enabled:=FCWinFUG.COO_AtmosphereEdit.Checked;
end;

procedure FCmfC_AtmosphereGas_ArUpdate;
{:Purpose: apply the changes concerning the Ar gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasAr.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasAr.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasAr.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasAr.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasAr.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceAr:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasAr.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_CH4Update;
{:Purpose: apply the changes concerning the CH4 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCH4.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCH4.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCH4.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCH4.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCH4.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCH4:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCH4.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_COUpdate;
{:Purpose: apply the changes concerning the CO gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_CO2Update;
{:Purpose: apply the changes concerning the CO2 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO2.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasCO2.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_H2Update;
{:Purpose: apply the changes concerning the H2 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_H2OUpdate;
{:Purpose: apply the changes concerning the H2O gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2O.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2O.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2O.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2O.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2O.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2O:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2O.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_H2SUpdate;
{:Purpose: apply the changes concerning the H2S gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2S.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2S.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2S.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2S.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2S.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2S:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasH2S.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_HeUpdate;
{:Purpose: apply the changes concerning the He gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasHe.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasHe.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasHe.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasHe.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasHe.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceHe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasHe.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_N2Update;
{:Purpose: apply the changes concerning the N2 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasN2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasN2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasN2.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasN2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasN2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceN2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasN2.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_NeUpdate;
{:Purpose: apply the changes concerning the Ne gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNe.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNe.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNe.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNe.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNe.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNe:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNe.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_NH3Update;
{:Purpose: apply the changes concerning the NH3 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNH3.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNH3.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNH3.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNH3.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNH3.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNH3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNH3.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_NOUpdate;
{:Purpose: apply the changes concerning the NO gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_NO2Update;
{:Purpose: apply the changes concerning the NO2 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO2.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasNO2.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_O2Update;
{:Purpose: apply the changes concerning the O2 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO2.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO2.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_O3Update;
{:Purpose: apply the changes concerning the O3 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO3.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO3.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO3.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO3.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO3.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO3:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasO3.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphereGas_SO2Update;
{:Purpose: apply the changes concerning the SO2 gas status.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasSO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasSO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasSO2.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasSO2.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasSO2.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceSO2:=TFCEduAtmosphericGasStatus( FCWinFUG.COO_GasSO2.ItemIndex );
      end;
   end;
end;

procedure FCmfC_AtmosphericPressure_Update;
{:Purpose: update the orbital object atmospheric pressure.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphericPressure:=strtofloat( FCWinFUG.COO_AtmosphericPressure.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphericPressure:=strtofloat( FCWinFUG.COO_AtmosphericPressure.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphericPressure:=strtofloat( FCWinFUG.COO_AtmosphericPressure.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphericPressure:=strtofloat( FCWinFUG.COO_AtmosphericPressure.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphericPressure:=strtofloat( FCWinFUG.COO_AtmosphericPressure.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphericPressure:=strtofloat( FCWinFUG.COO_AtmosphericPressure.Text );
      end;
   end;
end;

procedure FCmfC_HydrosphereArea_Update;
{:Purpose: update the hydrosphere area.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat
      ,Test: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   Test:=strtoint( FCWinFUG.COO_HydroArea.Text );
   if Test > 100
   then Test:=100;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_hydrosphereArea:=Test;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_hydrosphereArea:=Test;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_hydrosphereArea:=Test;
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphereArea:=Test;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphereArea:=Test;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphereArea:=Test;
      end;
   end;
end;

procedure FCmfC_HydrosphereEditTrigger_Update;
{:Purpose: apply the changes when the HydrosphereEdit checkbox is checked or not.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_isHydrosphereEdited:=FCWinFUG.COO_HydrosphereEdit.Checked;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_isHydrosphereEdited:=FCWinFUG.COO_HydrosphereEdit.Checked;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_isHydrosphereEdited:=FCWinFUG.COO_HydrosphereEdit.Checked;
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isHydrosphereEdited:=FCWinFUG.COO_HydrosphereEdit.Checked;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isHydrosphereEdited:=FCWinFUG.COO_HydrosphereEdit.Checked;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isHydrosphereEdited:=FCWinFUG.COO_HydrosphereEdit.Checked;
      end;
   end;
   FCWinFUG.COO_HydroType.Enabled:=FCWinFUG.COO_HydrosphereEdit.Checked;
   FCWinFUG.COO_HydroArea.Enabled:=FCWinFUG.COO_HydrosphereEdit.Checked;
end;

procedure FCmfC_HydrosphereType_Update;
{:Purpose: apply the changes concerning the hydrosphere type.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_hydrosphere:=TFCEduHydrospheres( FCWinFUG.COO_HydroType.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_hydrosphere:=TFCEduHydrospheres( FCWinFUG.COO_HydroType.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_hydrosphere:=TFCEduHydrospheres( FCWinFUG.COO_HydroType.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphere:=TFCEduHydrospheres( FCWinFUG.COO_HydroType.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphere:=TFCEduHydrospheres( FCWinFUG.COO_HydroType.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphere:=TFCEduHydrospheres( FCWinFUG.COO_HydroType.ItemIndex );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_DensityUpdate;
{:Purpose: update the orbital object density.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_density:=strtoint( FCWinFUG.COO_Density.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_density:=strtoint( FCWinFUG.COO_Density.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_density:=strtoint( FCWinFUG.COO_Density.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density:=strtoint( FCWinFUG.COO_Density.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density:=strtoint( FCWinFUG.COO_Density.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density:=strtoint( FCWinFUG.COO_Density.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_DiameterUpdate;
{:Purpose: update the orbital object diameter.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_DistanceUpdate;
{:Purpose: update the orbital object distance.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar:=strtofloat( FCWinFUG.COO_Distance.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar:=strtofloat( FCWinFUG.COO_Distance.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar:=strtofloat( FCWinFUG.COO_Distance.Text );
      end;
   end
   else begin
      {:DEV NOTE: reminder, it's in thousands of km}
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=strtofloat( FCWinFUG.COO_Distance.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=strtofloat( FCWinFUG.COO_Distance.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar:=strtofloat( FCWinFUG.COO_Distance.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_EscapeVelUpdate;
{:Purpose: update the orbital object escape velocity.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_GravityUpdate;
{:Purpose: update the orbital object gravity.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_InclinationAxisUpdate;
{:Purpose: update the orbital object inclination axis.
    Additions:
      -2013May07- *rem: satellite is removed, it's a non sat data.
      -2013May06- *add: satellite.
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_axialTilt:=strtofloat( FCWinFUG.COO_InclAxis.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_axialTilt:=strtofloat( FCWinFUG.COO_InclAxis.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_axialTilt:=strtofloat( FCWinFUG.COO_InclAxis.Text );
   end;
end;

procedure FCmfC_OrbitPicker_MagFieldUpdate;
{:Purpose: update the orbital object magnetic field.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_magneticField:=strtofloat( FCWinFUG.COO_MagField.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_magneticField:=strtofloat( FCWinFUG.COO_MagField.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_magneticField:=strtofloat( FCWinFUG.COO_MagField.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField:=strtofloat( FCWinFUG.COO_MagField.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField:=strtofloat( FCWinFUG.COO_MagField.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField:=strtofloat( FCWinFUG.COO_MagField.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_MassUpdate;
{:Purpose: update the orbital object mass.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_ObjectTypeUpdate;
{:Purpose: update the orbital object type.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_fug_BasicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_fug_BasicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_fug_BasicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );
      end;
   end
   else begin
      {.prevent the setup of asteroids belt or gaseous planet}
      if FCWinFUG.COO_ObjecType.ItemIndex=1
      then FCWinFUG.COO_ObjecType.ItemIndex:=2
      else if FCWinFUG.COO_ObjecType.ItemIndex=4
      then FCWinFUG.COO_ObjecType.ItemIndex:=3;
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_BasicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_BasicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_BasicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_RotationPeriodUpdate;
{:Purpose: update the orbital object rotation period.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod:=strtofloat( FCWinFUG.COO_RotationPeriod.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod:=strtofloat( FCWinFUG.COO_RotationPeriod.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod:=strtofloat( FCWinFUG.COO_RotationPeriod.Text );
   end;
end;

procedure FCmfC_OrbitPicker_TectonicActivityUpdate;
{:Purpose: update the orbital object tectonic activity.
    Additions:
      -2013May06- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_tectonicActivity:=TFCEduTectonicActivity( FCWinFUG.COO_TectonicActivity.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_tectonicActivity:=TFCEduTectonicActivity( FCWinFUG.COO_TectonicActivity.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_tectonicActivity:=TFCEduTectonicActivity( FCWinFUG.COO_TectonicActivity.ItemIndex );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_tectonicActivity:=TFCEduTectonicActivity( FCWinFUG.COO_TectonicActivity.ItemIndex );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_tectonicActivity:=TFCEduTectonicActivity( FCWinFUG.COO_TectonicActivity.ItemIndex );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_tectonicActivity:=TFCEduTectonicActivity( FCWinFUG.COO_TectonicActivity.ItemIndex );
      end;
   end;
end;

procedure FCmfC_OrbitPicker_TokenUpdate;
{:Purpose: update the orbital object token.
    Additions:
      -2013May05- *add: satellite.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_dbTokenId:=FCWinFUG.COO_Token.Text;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_dbTokenId:=FCWinFUG.COO_Token.Text;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_dbTokenId:=FCWinFUG.COO_Token.Text;
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId:=FCWinFUG.COO_Token.Text;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId:=FCWinFUG.COO_Token.Text;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId:=FCWinFUG.COO_Token.Text;
      end;
   end;
end;

procedure FCmfC_OrbitPicker_UpdateCurrent( const UpdateSat: boolean );
{:Purpose: update the current orbital object tab / orbital object picker.
    Additions:
      -2013Sep08- *fix: display the negative rotation periods.
      -2013Jun24- *add: hydrosphere.
      -2013Jun16- *add: atmosphere.
      -2013May05- *add: satellites setup.
      -2013May01- *add: tectonic activity.
}
   var
      CurrentObject: integer;
begin
   if not FCWinFUG.TOO_CurrentOrbitalObject.Visible
   then FCWinFUG.TOO_CurrentOrbitalObject.Show;
   if not FCWinFUG.COO_RotationPeriod.Visible
   then FCWinFUG.COO_RotationPeriod.Show;
   if not FCWinFUG.COO_InclAxis.Visible
   then FCWinFUG.COO_InclAxis.Show;
   FCWinFUG.COO_Distance.EditLabel.Caption:='Distance';
   if not FCWinFUG.COO_SatTrigger.Visible then
   begin
      FCWinFUG.COO_SatTrigger.Show;
      FCWinFUG.COO_SatNumber.Show;
   end;
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0:
      begin
         if FCDfdMainStarObjectsList[CurrentObject].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdMainStarObjectsList[CurrentObject].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='orbobj';
         if FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar )
         else FCWinFUG.COO_Distance.Text:='';
         {.geophysical data}
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdMainStarObjectsList[CurrentObject].OO_fug_BasicType ) );
         if FCDfdMainStarObjectsList[CurrentObject].OO_diameter>0
         then FCWinFUG.COO_Diameter.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_diameter )
         else FCWinFUG.COO_Diameter.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_density>0
         then FCWinFUG.COO_Density.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_density )
         else FCWinFUG.COO_Density.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_mass>0
         then FCWinFUG.COO_Mass.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_mass )
         else FCWinFUG.COO_Mass.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_gravity>0
         then FCWinFUG.COO_Gravity.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_gravity )
         else FCWinFUG.COO_Gravity.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_escapeVelocity>0
         then FCWinFUG.COO_EscapeVel.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_escapeVelocity )
         else FCWinFUG.COO_EscapeVel.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod<>0
         then FCWinFUG.COO_RotationPeriod.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod )
         else FCWinFUG.COO_RotationPeriod.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_axialTilt>0
         then FCWinFUG.COO_InclAxis.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_axialTilt )
         else FCWinFUG.COO_InclAxis.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_magneticField>0
         then FCWinFUG.COO_MagField.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_magneticField )
         else FCWinFUG.COO_MagField.Text:='';
         FCWinFUG.COO_TectonicActivity.Text:=GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDfdMainStarObjectsList[CurrentObject].OO_tectonicActivity ) );
         {.ecosphere data}
         FCWinFUG.COO_AtmosphereEdit.Checked:=FCDfdMainStarObjectsList[CurrentObject].OO_fug_isAtmosphereEdited;
         FCmfC_AtmosphereEditTrigger_Update;
         FCWinFUG.COO_TraceAtmosphereTrigger.Checked:=FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_traceAtmosphere;
         FCWinFUG.COO_GasH2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2 );
         FCWinFUG.COO_GasHe.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceHe );
         FCWinFUG.COO_GasCH4.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCH4 );
         FCWinFUG.COO_GasNH3.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNH3 );
         FCWinFUG.COO_GasH2O.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2O );
         FCWinFUG.COO_GasNe.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNe );
         FCWinFUG.COO_GasN2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceN2 );
         FCWinFUG.COO_GasCO.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO );
         FCWinFUG.COO_GasNO.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO );
         FCWinFUG.COO_GasO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO2 );
         FCWinFUG.COO_GasH2S.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2S );
         FCWinFUG.COO_GasAr.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceAr );
         FCWinFUG.COO_GasCO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO2 );
         FCWinFUG.COO_GasNO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO2 );
         FCWinFUG.COO_GasO3.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO3 );
         FCWinFUG.COO_GasSO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceSO2 );
         FCWinFUG.COO_PrimGasVol.Text:=inttostr( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_primaryGasVolumePerc );
         FCWinFUG.COO_AtmosphericPressure.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_atmosphericPressure );
         {.hydrosphere}
         FCWinFUG.COO_HydrosphereEdit.Checked:=FCDfdMainStarObjectsList[CurrentObject].OO_isHydrosphereEdited;
         FCmfC_HydrosphereEditTrigger_Update;
         FCWinFUG.COO_HydroType.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_hydrosphere );
         FCWinFUG.COO_HydroArea.Text:=inttostr( FCDfdMainStarObjectsList[CurrentObject].OO_hydrosphereArea );
         if ( UpdateSat )
            and ( length( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList )-1 > 0 ) then
         begin
            if FCWinFUG.COO_SatTrigger.Checked
            then FCmfC_SatTrigger_Update
            else FCWinFUG.COO_SatTrigger.Checked:=true;
         end
         else if UpdateSat
         then FCWinFUG.COO_SatTrigger.Checked:=false;
      end;

      1:
      begin
         if FCDfdComp1StarObjectsList[CurrentObject].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdComp1StarObjectsList[CurrentObject].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='orbobj';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar )
         else FCWinFUG.COO_Distance.Text:='';
         {.geophysical data}
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_fug_BasicType ) );
         if FCDfdComp1StarObjectsList[CurrentObject].OO_diameter>0
         then FCWinFUG.COO_Diameter.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_diameter )
         else FCWinFUG.COO_Diameter.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_density>0
         then FCWinFUG.COO_Density.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_density )
         else FCWinFUG.COO_Density.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_mass>0
         then FCWinFUG.COO_Mass.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_mass )
         else FCWinFUG.COO_Mass.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_gravity>0
         then FCWinFUG.COO_Gravity.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_gravity )
         else FCWinFUG.COO_Gravity.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_escapeVelocity>0
         then FCWinFUG.COO_EscapeVel.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_escapeVelocity )
         else FCWinFUG.COO_EscapeVel.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod<>0
         then FCWinFUG.COO_RotationPeriod.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod )
         else FCWinFUG.COO_RotationPeriod.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_axialTilt>0
         then FCWinFUG.COO_InclAxis.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_axialTilt )
         else FCWinFUG.COO_InclAxis.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_magneticField>0
         then FCWinFUG.COO_MagField.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_magneticField )
         else FCWinFUG.COO_MagField.Text:='';
         FCWinFUG.COO_TectonicActivity.Text:=GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_tectonicActivity ) );
         {.ecosphere data}
         FCWinFUG.COO_AtmosphereEdit.Checked:=FCDfdComp1StarObjectsList[CurrentObject].OO_fug_isAtmosphereEdited;
         FCmfC_AtmosphereEditTrigger_Update;
         FCWinFUG.COO_TraceAtmosphereTrigger.Checked:=FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_traceAtmosphere;
         FCWinFUG.COO_GasH2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2 );
         FCWinFUG.COO_GasHe.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceHe );
         FCWinFUG.COO_GasCH4.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCH4 );
         FCWinFUG.COO_GasNH3.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNH3 );
         FCWinFUG.COO_GasH2O.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2O );
         FCWinFUG.COO_GasNe.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNe );
         FCWinFUG.COO_GasN2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceN2 );
         FCWinFUG.COO_GasCO.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO );
         FCWinFUG.COO_GasNO.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO );
         FCWinFUG.COO_GasO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO2 );
         FCWinFUG.COO_GasH2S.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2S );
         FCWinFUG.COO_GasAr.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceAr );
         FCWinFUG.COO_GasCO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO2 );
         FCWinFUG.COO_GasNO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO2 );
         FCWinFUG.COO_GasO3.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO3 );
         FCWinFUG.COO_GasSO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceSO2 );
         FCWinFUG.COO_PrimGasVol.Text:=inttostr( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_primaryGasVolumePerc );
         FCWinFUG.COO_AtmosphericPressure.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphericPressure );
         {.hydrosphere}
         FCWinFUG.COO_HydrosphereEdit.Checked:=FCDfdComp1StarObjectsList[CurrentObject].OO_isHydrosphereEdited;
         FCmfC_HydrosphereEditTrigger_Update;
         FCWinFUG.COO_HydroType.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_hydrosphere );
         FCWinFUG.COO_HydroArea.Text:=inttostr( FCDfdComp1StarObjectsList[CurrentObject].OO_hydrosphereArea );
         if ( UpdateSat )
            and ( length( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList )-1 > 0 ) then
         begin
            if FCWinFUG.COO_SatTrigger.Checked
            then FCmfC_SatTrigger_Update
            else FCWinFUG.COO_SatTrigger.Checked:=true;
         end
         else if UpdateSat
         then FCWinFUG.COO_SatTrigger.Checked:=false;
      end;

      2:
      begin
         if FCDfdComp2StarObjectsList[CurrentObject].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdComp2StarObjectsList[CurrentObject].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='orbobj';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar )
         else FCWinFUG.COO_Distance.Text:='';
         {.geophysical data}
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_fug_BasicType ) );
         if FCDfdComp2StarObjectsList[CurrentObject].OO_diameter>0
         then FCWinFUG.COO_Diameter.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_diameter )
         else FCWinFUG.COO_Diameter.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_density>0
         then FCWinFUG.COO_Density.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_density )
         else FCWinFUG.COO_Density.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_mass>0
         then FCWinFUG.COO_Mass.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_mass )
         else FCWinFUG.COO_Mass.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_gravity>0
         then FCWinFUG.COO_Gravity.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_gravity )
         else FCWinFUG.COO_Gravity.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_escapeVelocity>0
         then FCWinFUG.COO_EscapeVel.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_escapeVelocity )
         else FCWinFUG.COO_EscapeVel.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod<>0
         then FCWinFUG.COO_RotationPeriod.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_rotationPeriod )
         else FCWinFUG.COO_RotationPeriod.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_axialTilt>0
         then FCWinFUG.COO_InclAxis.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_axialTilt )
         else FCWinFUG.COO_InclAxis.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_magneticField>0
         then FCWinFUG.COO_MagField.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_magneticField )
         else FCWinFUG.COO_MagField.Text:='';
         FCWinFUG.COO_TectonicActivity.Text:=GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_tectonicActivity ) );
         {.ecosphere data}
         FCWinFUG.COO_AtmosphereEdit.Checked:=FCDfdComp2StarObjectsList[CurrentObject].OO_fug_isAtmosphereEdited;
         FCmfC_AtmosphereEditTrigger_Update;
         FCWinFUG.COO_TraceAtmosphereTrigger.Checked:=FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_traceAtmosphere;
         FCWinFUG.COO_GasH2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2 );
         FCWinFUG.COO_GasHe.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceHe );
         FCWinFUG.COO_GasCH4.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCH4 );
         FCWinFUG.COO_GasNH3.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNH3 );
         FCWinFUG.COO_GasH2O.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2O );
         FCWinFUG.COO_GasNe.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNe );
         FCWinFUG.COO_GasN2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceN2 );
         FCWinFUG.COO_GasCO.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO );
         FCWinFUG.COO_GasNO.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO );
         FCWinFUG.COO_GasO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO2 );
         FCWinFUG.COO_GasH2S.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceH2S );
         FCWinFUG.COO_GasAr.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceAr );
         FCWinFUG.COO_GasCO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceCO2 );
         FCWinFUG.COO_GasNO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceNO2 );
         FCWinFUG.COO_GasO3.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceO3 );
         FCWinFUG.COO_GasSO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_gasPresenceSO2 );
         FCWinFUG.COO_PrimGasVol.Text:=inttostr( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_primaryGasVolumePerc );
         FCWinFUG.COO_AtmosphericPressure.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphericPressure );
         {.hydrosphere}
         FCWinFUG.COO_HydrosphereEdit.Checked:=FCDfdComp2StarObjectsList[CurrentObject].OO_isHydrosphereEdited;
         FCmfC_HydrosphereEditTrigger_Update;
         FCWinFUG.COO_HydroType.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_hydrosphere );
         FCWinFUG.COO_HydroArea.Text:=inttostr( FCDfdComp2StarObjectsList[CurrentObject].OO_hydrosphereArea );
         if ( UpdateSat )
            and ( length( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList )-1 > 0 ) then
         begin
            if FCWinFUG.COO_SatTrigger.Checked
            then FCmfC_SatTrigger_Update
            else FCWinFUG.COO_SatTrigger.Checked:=true;
         end
         else if UpdateSat
         then FCWinFUG.COO_SatTrigger.Checked:=false;
      end;
   end; //==END== case FCWinFUG.TOO_StarPicker.ItemIndex of ==//
end;

procedure FCmfC_PrimaryGasVolume_Update;
{:Purpose: update the atmosphere primary gas volume.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_primaryGasVolumePerc:=strtoint( FCWinFUG.COO_PrimGasVol.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_primaryGasVolumePerc:=strtoint( FCWinFUG.COO_PrimGasVol.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_primaryGasVolumePerc:=strtoint( FCWinFUG.COO_PrimGasVol.Text );
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_primaryGasVolumePerc:=strtoint( FCWinFUG.COO_PrimGasVol.Text );

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_primaryGasVolumePerc:=strtoint( FCWinFUG.COO_PrimGasVol.Text );

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_primaryGasVolumePerc:=strtoint( FCWinFUG.COO_PrimGasVol.Text );
      end;
   end;
end;

procedure FCmfC_Region_Update;
{:Purpose: update the intrinsic data of the selected region.
    Additions:
}
begin
   FDcurrentRegion:=FCWinFUG.CR_CurrentRegion.ItemIndex + 1;
   if FDcurrentRegionSat<=0 then
   begin
         case FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType of
         rst01RockyDesert..rst06Fertile:
         begin
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=false;
            FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex:=0;
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=true;
         end;

         rst07Oceanic:
         begin
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=false;
            FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex:=2;
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=true;
         end;

         rst08CoastalRockyDesert..rst13CoastalFertile:
         begin
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=false;
            FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex:=1;
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=true;
         end;
      end;
      FCWinFUG.CR_ReliefAdjustment.Enabled:=false;
      FCWinFUG.CR_ReliefAdjustment.ItemIndex:=Integer( FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_relief );
      FCWinFUG.CR_ReliefAdjustment.Enabled:=true;
   end
   else begin
      case FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType of
         rst01RockyDesert..rst06Fertile:
         begin
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=false;
            FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex:=0;
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=true;
         end;

         rst07Oceanic:
         begin
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=false;
            FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex:=2;
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=true;
         end;

         rst08CoastalRockyDesert..rst13CoastalFertile:
         begin
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=false;
            FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex:=1;
            FCWinFUG.CR_OceanicCoastalAdjustment.Enabled:=true;
         end;
      end;
      FCWinFUG.CR_ReliefAdjustment.Enabled:=false;
      FCWinFUG.CR_ReliefAdjustment.ItemIndex:=Integer( FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_relief );
      FCWinFUG.CR_ReliefAdjustment.Enabled:=true;
   end;
end;

procedure FCmfC_RegionMapClimate_Update;
{:Purpose: update the Fractal Terrains climate file # used to generate the actual surface map.
    Additions:
}
begin
   if FDcurrentRegionSat <= 0
   then FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_fug_Worldclimatefile:=FCWinFUG.CR_InputClimateFileNumber.Text
   else FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_fug_Worldclimatefile:=FCWinFUG.CR_InputClimateFileNumber.Text;
end;

procedure FCmfC_RegionMapLightColor_Update;
{:Purpose: update the Fractal Terrains light & color file # used to generate the actual surface map.
    Additions:
}
begin
   if FDcurrentRegionSat <= 0
   then FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_fug_Worldlightcolorfile:=FCWinFUG.CR_InputLightColorFileNumber.Text
   else FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_fug_Worldlightcolorfile:=FCWinFUG.CR_InputLightColorFileNumber.Text;
end;

procedure FCmfC_RegionMapSeed_Update;
{:Purpose: update the Fractal Terrains map seed used to generate the actual surface map.
    Additions:
}
begin
   if FDcurrentRegionSat <= 0
   then FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_fug_WorldSeed:=FCWinFUG.CR_InputSeed.Text
   else FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_fug_WorldSeed:=FCWinFUG.CR_InputSeed.Text;
end;

procedure FCMfC_RegionOceanicCoastal_Update;
{:Purpose: update the Oceanic-Coastal manual adjustment.
    Additions:
}
begin
   {:DEV NOTES:
      for reference, build the combo box as this:

      idx#0: No Coastal/Oceanic Region

      idx#1: Coastal Region

      idx#2: Oceanic Region
   }
   if FDcurrentRegionSat <= 0 then
   begin
      case FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex of
         0: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=FCDfdRegions[FDcurrentRegion].RC_landType;

         1:
         begin
            case FCDfdRegions[FDcurrentRegion].RC_landType of
               rst01RockyDesert: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst08CoastalRockyDesert;

               rst02SandyDesert: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst09CoastalSandyDesert;

               rst03Volcanic: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst10CoastalVolcanic;

               rst04Polar: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst11CoastalPolar;

               rst05Arid: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst12CoastalArid;

               rst06Fertile: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst13CoastalFertile;
            end;
         end;

         2:
         begin
            FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_landType:=rst07Oceanic;
         end;
      end;
   end
   else begin
      case FCWinFUG.CR_OceanicCoastalAdjustment.ItemIndex of
         0: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=FCDfdRegions[FDcurrentRegion].RC_landType;

         1:
         begin
            case FCDfdRegions[FDcurrentRegion].RC_landType of
               rst01RockyDesert: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst08CoastalRockyDesert;

               rst02SandyDesert: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst09CoastalSandyDesert;

               rst03Volcanic: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst10CoastalVolcanic;

               rst04Polar: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst11CoastalPolar;

               rst05Arid: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst12CoastalArid;

               rst06Fertile: FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst13CoastalFertile;
            end;
         end;

         2:
         begin
            FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_landType:=rst07Oceanic;
         end;
      end;
   end;
end;

procedure FCMfC_RegionRelief_Update;
{:Purpose: update the Relief manual adjustment.
    Additions:
      -2013Aug31- *add: also adjust the relief into FCDfdRegions dagta structure.
}
begin
   {:DEV NOTES:
      for reference, build the combo box as this:

      idx#0: Plain

      idx#1: Broken

      idx#2: Mountainous
   }
   if FDcurrentRegionSat <= 0
   then FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_regions[FDcurrentRegion].OOR_relief:=TFCEduRegionReliefs( FCWinFUG.CR_ReliefAdjustment.ItemIndex )
   else FCDduStarSystem[0].SS_stars[FDcurrentRegionStar].S_orbitalObjects[FDcurrentRegionOrbObj].OO_satellitesList[FDcurrentRegionSat].OO_regions[FDcurrentRegion].OOR_relief:=TFCEduRegionReliefs( FCWinFUG.CR_ReliefAdjustment.ItemIndex );
   FCDfdRegions[FDcurrentRegion].RC_reliefType:=TFCEduRegionReliefs( FCWinFUG.CR_ReliefAdjustment.ItemIndex );
end;

procedure FCmC_SatPicker_Update;
{:Purpose: update the satellite setting.
    Additions:
}
   var
      CurrentObject
      ,NumberOfSatellites: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   NumberOfSatellites:=strtoint( FCWinFUG.COO_SatNumber.Text );
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: SetLength( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList, NumberOfSatellites + 1 );

      1: SetLength( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList, NumberOfSatellites + 1 );

      2: SetLength( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList, NumberOfSatellites + 1 );
   end;
   FCmC_SatPicker_UpdateList;
end;

procedure FCmfC_SatPicker_UpdateCurrent;
{:Purpose: update the current satellite object tab / satellite picker.
    Additions:
      -2013Jun16- *add: (wip) atmosphere.
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   if not FCWinFUG.TOO_CurrentOrbitalObject.Visible
   then FCWinFUG.TOO_CurrentOrbitalObject.Show;
   if FCWinFUG.COO_RotationPeriod.Visible
   then FCWinFUG.COO_RotationPeriod.Hide;
   if FCWinFUG.COO_InclAxis.Visible
   then FCWinFUG.COO_InclAxis.Hide;
   FCWinFUG.COO_Distance.EditLabel.Caption:='Distance from Planet - Th of Km';
   if FCWinFUG.COO_SatTrigger.Visible then
   begin
      FCWinFUG.COO_SatTrigger.Hide;
      FCWinFUG.COO_SatNumber.Hide;
   end;
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0:
      begin
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='sat';
         if not FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSatellite
         then FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSatellite:=true;
         if FCDfdMainStarObjectsList[CurrentObject].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar )
         else FCWinFUG.COO_Distance.Text:='';
         {.geophysical data}
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_BasicType ) );
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter>0
         then FCWinFUG.COO_Diameter.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter )
         else FCWinFUG.COO_Diameter.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density>0
         then FCWinFUG.COO_Density.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density )
         else FCWinFUG.COO_Density.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass>0
         then FCWinFUG.COO_Mass.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass )
         else FCWinFUG.COO_Mass.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity>0
         then FCWinFUG.COO_Gravity.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity )
         else FCWinFUG.COO_Gravity.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity>0
         then FCWinFUG.COO_EscapeVel.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity )
         else FCWinFUG.COO_EscapeVel.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField>0
         then FCWinFUG.COO_MagField.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField )
         else FCWinFUG.COO_MagField.Text:='';
         FCWinFUG.COO_TectonicActivity.Text:=GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_tectonicActivity ) );
         {.ecosphere data}
         FCWinFUG.COO_AtmosphereEdit.Checked:=FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_isAtmosphereEdited;
         FCmfC_AtmosphereEditTrigger_Update;
         FCWinFUG.COO_TraceAtmosphereTrigger.Checked:=FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_traceAtmosphere;
         FCWinFUG.COO_GasH2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2 );
         FCWinFUG.COO_GasHe.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceHe );
         FCWinFUG.COO_GasCH4.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCH4 );
         FCWinFUG.COO_GasNH3.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNH3 );
         FCWinFUG.COO_GasH2O.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2O );
         FCWinFUG.COO_GasNe.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNe );
         FCWinFUG.COO_GasN2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceN2 );
         FCWinFUG.COO_GasCO.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO );
         FCWinFUG.COO_GasNO.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO );
         FCWinFUG.COO_GasO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO2 );
         FCWinFUG.COO_GasH2S.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2S );
         FCWinFUG.COO_GasAr.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceAr );
         FCWinFUG.COO_GasCO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO2 );
         FCWinFUG.COO_GasNO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO2 );
         FCWinFUG.COO_GasO3.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO3 );
         FCWinFUG.COO_GasSO2.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceSO2 );
         FCWinFUG.COO_PrimGasVol.Text:=inttostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_primaryGasVolumePerc );
         FCWinFUG.COO_AtmosphericPressure.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphericPressure );
         {.hydrosphere}
         FCWinFUG.COO_HydrosphereEdit.Checked:=FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isHydrosphereEdited;
         FCmfC_HydrosphereEditTrigger_Update;
         FCWinFUG.COO_HydroType.ItemIndex:=Integer( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphere );
         FCWinFUG.COO_HydroArea.Text:=inttostr( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphereArea );
      end;

      1:
      begin
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='sat';
         if not FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSatellite
         then FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSatellite:=true;
         if FCDfdComp1StarObjectsList[CurrentObject].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar )
         else FCWinFUG.COO_Distance.Text:='';
         {.geophysical data}
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_BasicType ) );
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter>0
         then FCWinFUG.COO_Diameter.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter )
         else FCWinFUG.COO_Diameter.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density>0
         then FCWinFUG.COO_Density.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density )
         else FCWinFUG.COO_Density.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass>0
         then FCWinFUG.COO_Mass.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass )
         else FCWinFUG.COO_Mass.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity>0
         then FCWinFUG.COO_Gravity.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity )
         else FCWinFUG.COO_Gravity.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity>0
         then FCWinFUG.COO_EscapeVel.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity )
         else FCWinFUG.COO_EscapeVel.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField>0
         then FCWinFUG.COO_MagField.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField )
         else FCWinFUG.COO_MagField.Text:='';
         FCWinFUG.COO_TectonicActivity.Text:=GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_tectonicActivity ) );
         {.ecosphere data}
         FCWinFUG.COO_AtmosphereEdit.Checked:=FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_isAtmosphereEdited;
         FCmfC_AtmosphereEditTrigger_Update;
         FCWinFUG.COO_TraceAtmosphereTrigger.Checked:=FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_traceAtmosphere;
         FCWinFUG.COO_GasH2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2 );
         FCWinFUG.COO_GasHe.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceHe );
         FCWinFUG.COO_GasCH4.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCH4 );
         FCWinFUG.COO_GasNH3.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNH3 );
         FCWinFUG.COO_GasH2O.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2O );
         FCWinFUG.COO_GasNe.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNe );
         FCWinFUG.COO_GasN2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceN2 );
         FCWinFUG.COO_GasCO.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO );
         FCWinFUG.COO_GasNO.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO );
         FCWinFUG.COO_GasO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO2 );
         FCWinFUG.COO_GasH2S.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2S );
         FCWinFUG.COO_GasAr.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceAr );
         FCWinFUG.COO_GasCO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO2 );
         FCWinFUG.COO_GasNO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO2 );
         FCWinFUG.COO_GasO3.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO3 );
         FCWinFUG.COO_GasSO2.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceSO2 );
         FCWinFUG.COO_PrimGasVol.Text:=inttostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_primaryGasVolumePerc );
         FCWinFUG.COO_AtmosphericPressure.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphericPressure );
         {.hydrosphere}
         FCWinFUG.COO_HydrosphereEdit.Checked:=FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isHydrosphereEdited;
         FCmfC_HydrosphereEditTrigger_Update;
         FCWinFUG.COO_HydroType.ItemIndex:=Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphere );
         FCWinFUG.COO_HydroArea.Text:=inttostr( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphereArea );
      end;

      2:
      begin
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='sat';
         if not FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSatellite
         then FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isSatellite:=true;
         if FCDfdComp2StarObjectsList[CurrentObject].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar )
         else FCWinFUG.COO_Distance.Text:='';
         {.geophysical data}
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_BasicType ) );
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter>0
         then FCWinFUG.COO_Diameter.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_diameter )
         else FCWinFUG.COO_Diameter.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density>0
         then FCWinFUG.COO_Density.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_density )
         else FCWinFUG.COO_Density.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass>0
         then FCWinFUG.COO_Mass.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_mass )
         else FCWinFUG.COO_Mass.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity>0
         then FCWinFUG.COO_Gravity.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_gravity )
         else FCWinFUG.COO_Gravity.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity>0
         then FCWinFUG.COO_EscapeVel.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_escapeVelocity )
         else FCWinFUG.COO_EscapeVel.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField>0
         then FCWinFUG.COO_MagField.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_magneticField )
         else FCWinFUG.COO_MagField.Text:='';
         FCWinFUG.COO_TectonicActivity.Text:=GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_tectonicActivity ) );
         {.ecosphere data}
         FCWinFUG.COO_AtmosphereEdit.Checked:=FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_fug_isAtmosphereEdited;
         FCmfC_AtmosphereEditTrigger_Update;
         FCWinFUG.COO_TraceAtmosphereTrigger.Checked:=FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_traceAtmosphere;
         FCWinFUG.COO_GasH2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2 );
         FCWinFUG.COO_GasHe.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceHe );
         FCWinFUG.COO_GasCH4.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCH4 );
         FCWinFUG.COO_GasNH3.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNH3 );
         FCWinFUG.COO_GasH2O.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2O );
         FCWinFUG.COO_GasNe.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNe );
         FCWinFUG.COO_GasN2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceN2 );
         FCWinFUG.COO_GasCO.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO );
         FCWinFUG.COO_GasNO.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO );
         FCWinFUG.COO_GasO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO2 );
         FCWinFUG.COO_GasH2S.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceH2S );
         FCWinFUG.COO_GasAr.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceAr );
         FCWinFUG.COO_GasCO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceCO2 );
         FCWinFUG.COO_GasNO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceNO2 );
         FCWinFUG.COO_GasO3.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceO3 );
         FCWinFUG.COO_GasSO2.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_gasPresenceSO2 );
         FCWinFUG.COO_PrimGasVol.Text:=inttostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_primaryGasVolumePerc );
         FCWinFUG.COO_AtmosphericPressure.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphericPressure );
         {.hydrosphere}
         FCWinFUG.COO_HydrosphereEdit.Checked:=FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_isHydrosphereEdited;
         FCmfC_HydrosphereEditTrigger_Update;
         FCWinFUG.COO_HydroType.ItemIndex:=Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphere );
         FCWinFUG.COO_HydroArea.Text:=inttostr( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_hydrosphereArea );
      end;
   end; //==END== case FCWinFUG.TOO_StarPicker.ItemIndex of ==//
end;

procedure FCmC_SatPicker_UpdateList;
{:Purpose: update the satpicker list according to the current setting.
    Additions:
}
 var
      Count
      ,CurrentObject
      ,NumberOfSatellites: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   FCWinFUG.TOO_SatPicker.Items.Clear;
   FCWinFUG.TOO_SatPicker.ItemIndex:=-1;
   FCWinFUG.TOO_SatPicker.Enabled:=false;
   NumberOfSatellites:=strtoint( FCWinFUG.COO_SatNumber.Text );
   if NumberOfSatellites<>-1 then
   begin
      FCWinFUG.TOO_SatPicker.Items.Add( '0 - Central OObj' );
      Count:=1;
      while Count <= NumberOfSatellites do
      begin
         FCWinFUG.TOO_SatPicker.Items.Add( inttostr( Count ) );
         inc( Count );
      end;
      if not FCWinFUG.TOO_SatPicker.Visible
      then FCWinFUG.TOO_SatPicker.Show;
      FCWinFUG.TOO_SatPicker.ItemIndex:=0;
      FCWinFUG.TOO_SatPicker.Enabled:=true;
   end;
end;

procedure FCmfC_SatTrigger_Update;
{:Purpose: update the sat trigger and all related interface elements.
    Additions:
}
   var
      CurrentObject
      ,NumberOfSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   if not FCWinFUG.COO_SatTrigger.Checked then
   begin
      FCWinFUG.TOO_SatPicker.ItemIndex:=-1;
      FCWinFUG.TOO_SatPicker.Items.Clear;
      FCWinFUG.TOO_SatPicker.Hide;
      FCWinFUG.COO_SatNumber.Enabled:=false;
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: SetLength( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList, 1 );

         1: SetLength( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList, 1 );

         2: SetLength( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList, 1 );
      end;
   end
   else begin
      FCWinFUG.COO_SatNumber.Enabled:=true;
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: NumberOfSat:=length( FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList ) - 1;

         1: NumberOfSat:=length( FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList ) - 1;

         2: NumberOfSat:=length( FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList ) - 1;
      end;
      if ( NumberOfSat< -1 )
         or ( NumberOfSat=0 )  then
      begin
         FCWinFUG.COO_SatNumber.Text:='1';
         FCmC_SatPicker_Update;
      end
      else begin
         FCWinFUG.COO_SatNumber.Text:=inttostr( NumberOfSat );
         FCmC_SatPicker_UpdateList;
      end;
   end;
end;

procedure FCMfC_StarPicker_Update;
{:Purpose: update the orbital object tab / star picker.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   FCWinFUG.TOO_CurrentOrbitalObject.Hide;
   FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex:=-1;
   FCWinFUG.TOO_OrbitalObjectPicker.Items.Clear;
   FCWinFUG.TOO_OrbitalObjectPicker.Hide;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0:
      begin
         if ( FCWinFUG.TMS_SystemType.ItemIndex < 3 )
            and ( FCWinFUG.TMS_OrbitGeneration.ItemIndex = 2 )
            and ( FCWinFUG.TMS_OrbitGenerationNumberOrbits.Text<>'' ) then
         begin
            Max:=strtoint( FCWinFUG.TMS_OrbitGenerationNumberOrbits.Text );
            Count:=1;
            while Count<=Max do
            begin
               FCWinFUG.TOO_OrbitalObjectPicker.Items.Add( inttostr( Count ) );
               inc( Count );
            end;
            FCWinFUG.TOO_OrbitalObjectPicker.Show;
            FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex:=0;
         end
         else begin
            Max:=length( FCDfdMainStarObjectsList )-1;
            if Max>0
            then SetLength( FCDfdMainStarObjectsList, 1 );
         end;
      end;

      1:
      begin
         if ( FCWinFUG.TC1S_SystemType.ItemIndex < 3 )
            and ( FCWinFUG.TC1S_OrbitGeneration.ItemIndex = 2 )
            and ( FCWinFUG.TC1S_OrbitGenerationNumberOrbits.Text<>'' ) then
         begin
            Max:=strtoint( FCWinFUG.TC1S_OrbitGenerationNumberOrbits.Text );
            Count:=1;
            while Count<=Max do
            begin
               FCWinFUG.TOO_OrbitalObjectPicker.Items.Add( inttostr( Count ) );
               inc( Count );
            end;
            FCWinFUG.TOO_OrbitalObjectPicker.Show;
            FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex:=0;
         end
         else begin
            Max:=length( FCDfdComp1StarObjectsList )-1;
            if Max>0
            then SetLength( FCDfdComp1StarObjectsList, 1 );
         end;
      end;

      2:
      begin
         if ( FCWinFUG.TC2S_SystemType.ItemIndex < 3 )
            and ( FCWinFUG.TC2S_OrbitGeneration.ItemIndex = 2 )
            and ( FCWinFUG.TC2S_OrbitGenerationNumberOrbits.Text<>'' ) then
         begin
            Max:=strtoint( FCWinFUG.TC2S_OrbitGenerationNumberOrbits.Text );
            Count:=1;
            while Count<=Max do
            begin
               FCWinFUG.TOO_OrbitalObjectPicker.Items.Add( inttostr( Count ) );
               inc( Count );
            end;
            FCWinFUG.TOO_OrbitalObjectPicker.Show;
            FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex:=0;
         end
         else begin
            Max:=length( FCDfdComp2StarObjectsList )-1;
            if Max>0
            then SetLength( FCDfdComp2StarObjectsList, 1 );
         end;
      end;
   end;
end;

procedure FCmfC_TraceAtmosphereTrigger_Update;
{:Purpose: update the trace atmosphere check.
    Additions:
}
   var
      CurrentObject
      ,CurrentSat: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   CurrentSat:=FCWinFUG.TOO_SatPicker.ItemIndex;
   if CurrentSat<=0 then
   begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_atmosphere.AC_traceAtmosphere:=FCWinFUG.COO_TraceAtmosphereTrigger.Checked;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_atmosphere.AC_traceAtmosphere:=FCWinFUG.COO_TraceAtmosphereTrigger.Checked;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_atmosphere.AC_traceAtmosphere:=FCWinFUG.COO_TraceAtmosphereTrigger.Checked;
      end;
   end
   else begin
      case FCWinFUG.TOO_StarPicker.ItemIndex of
         0: FCDfdMainStarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_traceAtmosphere:=FCWinFUG.COO_TraceAtmosphereTrigger.Checked;

         1: FCDfdComp1StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_traceAtmosphere:=FCWinFUG.COO_TraceAtmosphereTrigger.Checked;

         2: FCDfdComp2StarObjectsList[CurrentObject].OO_satellitesList[CurrentSat].OO_atmosphere.AC_traceAtmosphere:=FCWinFUG.COO_TraceAtmosphereTrigger.Checked;
      end;
   end;
end;

end.
