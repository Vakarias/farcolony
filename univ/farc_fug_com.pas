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
   ,SysUtils;

procedure FCMfC_Initialize( isCreateWindow: boolean );

procedure FCMfC_StarPicker_Update;

implementation

uses
   farc_data_univ
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

procedure FCMfC_StarPicker_Update;
{:Purpose: update the orbital object tab.
    Additions:
}
   var
      Count
      ,Max: integer;
begin
   {:DEV NOTES: hide the 3 oobj groups.}
   {:DEV NOTES: case item index=> display the right oobj group, if not random of course.}
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
         end;
      end;
   end;
end;

end.
