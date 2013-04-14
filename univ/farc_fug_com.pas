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
///   update the orbital object token
///</summary>
procedure FCmfC_OrbitPicker_TokenUpdate;

///<summary>
///   update the orbital object tab / orbital object picker
///</summary>
procedure FCmfC_OrbitPicker_Update;

procedure FCMfC_StarPicker_Update;

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
end;

procedure FCmfC_OrbitPicker_DensityUpdate;
{:Purpose: update the orbital object density.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_density:=strtofloat( FCWinFUG.COO_Density.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_density:=strtofloat( FCWinFUG.COO_Density.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_density:=strtofloat( FCWinFUG.COO_Density.Text );
   end;
end;

procedure FCmfC_OrbitPicker_DiameterUpdate;
{:Purpose: update the orbital object diameter.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_diameter:=strtofloat( FCWinFUG.COO_Diameter.Text );
   end;
end;

procedure FCmfC_OrbitPicker_DistanceUpdate;
{:Purpose: update the orbital object distance.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar:=strtofloat( FCWinFUG.COO_Distance.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar:=strtofloat( FCWinFUG.COO_Distance.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar:=strtofloat( FCWinFUG.COO_Distance.Text );
   end;
end;

procedure FCmfC_OrbitPicker_EscapeVelUpdate;
{:Purpose: update the orbital object escape velocity.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_escapeVelocity:=strtofloat( FCWinFUG.COO_EscapeVel.Text );
   end;
end;

procedure FCmfC_OrbitPicker_GravityUpdate;
{:Purpose: update the orbital object gravity.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_gravity:=strtofloat( FCWinFUG.COO_Gravity.Text );
   end;
end;

procedure FCmfC_OrbitPicker_InclinationAxisUpdate;
{:Purpose: update the orbital object inclination axis.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_inclinationAxis:=strtofloat( FCWinFUG.COO_InclAxis.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_inclinationAxis:=strtofloat( FCWinFUG.COO_InclAxis.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_inclinationAxis:=strtofloat( FCWinFUG.COO_InclAxis.Text );
   end;
end;

procedure FCmfC_OrbitPicker_MassUpdate;
{:Purpose: update the orbital object mass.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_mass:=strtofloat( FCWinFUG.COO_Mass.Text );
   end;
end;

procedure FCmfC_OrbitPicker_ObjectTypeUpdate;
{:Purpose: update the orbital object type.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_basicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_basicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_basicType:=TFCEduOrbitalObjectBasicTypes( FCWinFUG.COO_ObjecType.ItemIndex );
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
      0: FCDfdMainStarObjectsList[CurrentObject].OO_rotationPeriod:=strtofloat( FCWinFUG.COO_RotationPeriod.Text );

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_rotationPeriod:=strtofloat( FCWinFUG.COO_RotationPeriod.Text );

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_rotationPeriod:=strtofloat( FCWinFUG.COO_RotationPeriod.Text );
   end;
end;

procedure FCmfC_OrbitPicker_TokenUpdate;
{:Purpose: update the orbital object token.
    Additions:
}
   var
      CurrentObject: integer;
begin
   CurrentObject:=FCWinFUG.TOO_OrbitalObjectPicker.ItemIndex+1;
   case FCWinFUG.TOO_StarPicker.ItemIndex of
      0: FCDfdMainStarObjectsList[CurrentObject].OO_dbTokenId:=FCWinFUG.COO_Token.Text;

      1: FCDfdComp1StarObjectsList[CurrentObject].OO_dbTokenId:=FCWinFUG.COO_Token.Text;

      2: FCDfdComp2StarObjectsList[CurrentObject].OO_dbTokenId:=FCWinFUG.COO_Token.Text;
   end;
end;

procedure FCmfC_OrbitPicker_Update;
{:Purpose: update the orbital object tab / orbital object picker.
    Additions:
}
   var
      CurrentObject: integer;
begin
   if not FCWinFUG.TOO_CurrentOrbitalObject.Visible
   then FCWinFUG.TOO_CurrentOrbitalObject.Show;
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
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdMainStarObjectsList[CurrentObject].OO_basicType ) );
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
         if FCDfdMainStarObjectsList[CurrentObject].OO_rotationPeriod>0
         then FCWinFUG.COO_RotationPeriod.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_rotationPeriod )
         else FCWinFUG.COO_RotationPeriod.Text:='';
         if FCDfdMainStarObjectsList[CurrentObject].OO_inclinationAxis>0
         then FCWinFUG.COO_InclAxis.Text:=floattostr( FCDfdMainStarObjectsList[CurrentObject].OO_inclinationAxis )
         else FCWinFUG.COO_InclAxis.Text:='';
      end;

      1:
      begin
         if FCDfdComp1StarObjectsList[CurrentObject].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdComp1StarObjectsList[CurrentObject].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='orbobj';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar )
         else FCWinFUG.COO_Distance.Text:='';
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdComp1StarObjectsList[CurrentObject].OO_basicType ) );
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
         if FCDfdComp1StarObjectsList[CurrentObject].OO_rotationPeriod>0
         then FCWinFUG.COO_RotationPeriod.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_rotationPeriod )
         else FCWinFUG.COO_RotationPeriod.Text:='';
         if FCDfdComp1StarObjectsList[CurrentObject].OO_inclinationAxis>0
         then FCWinFUG.COO_InclAxis.Text:=floattostr( FCDfdComp1StarObjectsList[CurrentObject].OO_inclinationAxis )
         else FCWinFUG.COO_InclAxis.Text:='';
      end;

      2:
      begin
         if FCDfdComp2StarObjectsList[CurrentObject].OO_dbTokenId<>''
         then FCWinFUG.COO_Token.Text:=FCDfdComp2StarObjectsList[CurrentObject].OO_dbTokenId
         else FCWinFUG.COO_Token.Text:='orbobj';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar>0
         then FCWinFUG.COO_Distance.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_isNotSat_distanceFromStar )
         else FCWinFUG.COO_Distance.Text:='';
         FCWinFUG.COO_ObjecType.Text:=GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDfdComp2StarObjectsList[CurrentObject].OO_basicType ) );
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
         if FCDfdComp2StarObjectsList[CurrentObject].OO_rotationPeriod>0
         then FCWinFUG.COO_RotationPeriod.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_rotationPeriod )
         else FCWinFUG.COO_RotationPeriod.Text:='';
         if FCDfdComp2StarObjectsList[CurrentObject].OO_inclinationAxis>0
         then FCWinFUG.COO_InclAxis.Text:=floattostr( FCDfdComp2StarObjectsList[CurrentObject].OO_inclinationAxis )
         else FCWinFUG.COO_InclAxis.Text:='';
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

end.
