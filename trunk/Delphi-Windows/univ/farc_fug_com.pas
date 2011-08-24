{======(C) Copyright Aug.2009-2011 Jean-Francois Baconnet All rights reserved==============

         Title:  FAR Colony
         Author: Jean-Francois Baconnet
         Project Started: August 16 2009
         Platform: Delphi
         License: GPLv3
         Website: http://farcolony.sourceforge.net/

         Unit: common FUG unit

 ============================================================================================
 ********************************************************************************************
 Copyright (c) 2009-2011, Jean-Francois Baconnet

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

procedure FCMfC_Initialize;

implementation

uses
   farc_main
   ,farc_win_fug;

//=======================================END OF INIT========================================

procedure FCMfC_Initialize;
{:Purpose: initialize the FUG window and input/outputs.
    Additions:
      -2010Jul13- *add: companion star 1 and 2 ui.
      -2010Jul11- *add: main star class, temperature, diameter, mass, luminosity, system type and orbit generation init.
                  *add: initialize FUG window size and location.
      -2010Jul04- *add: main star init.
}
begin
   FCWinFUG.Width:=FCWinMain.Width;
   FCWinFUG.Height:=FCWinMain.Height;
   FCWinFUG.Left:=FCWinMain.Left;
   FCWinFUG.Top:=FCWinMain.Top;
   FCWinFUG.FCWFssysToken.Text:='stelsys';
   FCWinFUG.FCWFlocX.Text:='';
   FCWinFUG.FCWFlocY.Text:='';
   FCWinFUG.FCWFlocZ.Text:='';
   FCWinFUG.FUGmStartoken.Text:='star';
   FCWinFUG.FUGmStarClass.ItemIndex:=0;
   FCWinFUG.FUGmStarTemp.Text:='';
   FCWinFUG.FUGmStarDiam.Text:='';
   FCWinFUG.FUGmStarMass.Text:='';
   FCWinFUG.FUGmStarLum.Text:='';
   FCWinFUG.FUGmSType.ItemIndex:=0;
   FCWinFUG.FUGmStarOG.ItemIndex:=0;
   FCWinFUG.FUGmStarNumOrb.Enabled:=false;
   FCWinFUG.FUGmStarNumOrb.Text:='';
   FCWinFUG.FUGcs1Check.Checked:=false;
   FCWinFUG.FUGcs1token.Text:='star';
   FCWinFUG.FUGcs1Class.ItemIndex:=0;
   FCWinFUG.FUGcs1Temp.Text:='';
   FCWinFUG.FUGcs1Diam.Text:='';
   FCWinFUG.FUGcs1Mass.Text:='';
   FCWinFUG.FUGcs1Lum.Text:='';
   FCWinFUG.FUGcs1Type.ItemIndex:=0;
   FCWinFUG.FUGcs1OG.ItemIndex:=0;
   FCWinFUG.FUGcs1NumOrb.Enabled:=false;
   FCWinFUG.FUGcs1NumOrb.Text:='';
   FCWinFUG.FUGcs2Check.Checked:=false;
   FCWinFUG.FUGcs2token.Text:='star';
   FCWinFUG.FUGcs2Class.ItemIndex:=0;
   FCWinFUG.FUGcs2Temp.Text:='';
   FCWinFUG.FUGcs2Diam.Text:='';
   FCWinFUG.FUGcs2Mass.Text:='';
   FCWinFUG.FUGcs2Lum.Text:='';
   FCWinFUG.FUGcs2Type.ItemIndex:=0;
   FCWinFUG.FUGcs2OG.ItemIndex:=0;
   FCWinFUG.FUGcs2NumOrb.Enabled:=false;
   FCWinFUG.FUGcs2NumOrb.Text:='';
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
end;

end.
