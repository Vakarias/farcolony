{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: regroup all OpenGL user's interface related methods and functions

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

unit farc_ogl_ui;

interface

uses
   Classes,
   SysUtils

   ,VectorGeometry;

type TFCEogluiHudDispTp=(
   ogluihdtStar
   ,ogluihdtOObj
   ,ogluihdtSat
   ,ogluihdtSpUn
   );

type TFCEogluiUpdTp=(
   oglupdtpAll
   ,oglupdtpTxtOnly
   ,oglupdtpLocOnly
   );

type TFCEogluiUpdTgt=(
   ogluiutAll
   ,ogluiutCPS
   ,ogluiutFocObj
   ,ogluiutTime
   );

///<summary>
///   trigger the help text of the selected element
///</summary>
procedure FCMoglUI_Elem_SelHelp(const ESHidx: integer);

///<summary>
///   set the data display for the choosen focused object
///</summary>
///    <param name="FODDtp">object type, variable added for display data not necessarly
///   related to the current focused object</param>
procedure FCMoglUI_FocusedObj_DDisp(const FODDtp: TFCEogluiHudDispTp);

///<summary>
///   update user's interface of the main3d view
///</summary>
procedure FCMoglUI_Main3DViewUI_Update(
   const M3DVUIUtype: TFCEogluiUpdTp;
   const M3DVUIUtarget: TFCEogluiUpdTgt
   );

implementation

uses
   farc_common_func
   ,farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_cps
   ,farc_game_gameflow
   ,farc_main
   ,farc_spu_functions
   ,farc_ui_win;

//=============================================END OF INIT==================================

procedure FCMoglUI_Elem_SelHelp(const ESHidx: integer);
{:Purpose: trigger the help text of the selected element.
    Additions:
      -2010Jul19- *add: orbit eccentricity.
      -2010Jul18- *mod; changed object picked method.
                  *add: albedo, star temperature.
}
begin
   case ESHidx of
      1: FCMuiW_HelpTDef_Link('univAlbedo', true);
      2: FCMuiW_HelpTDef_Link('univDis', true);
      3: FCMuiW_HelpTDef_Link('univEccOO', true);
      101: FCMuiW_HelpTDef_Link('univStarTemp', true);
   end;
end;

procedure FCMoglUI_FO_OObHide;
begin
   FCWinMain.FCGLSHUDobobjOrbDatHLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDistLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDist.Visible:=false;
   FCWinMain.FCGLSHUDobobjEccLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjEcc.Visible:=false;
   FCWinMain.FCGLSHUDobobjZoneLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjZone.Visible:=false;
   FCWinMain.FCGLSHUDobobjRevPerLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjRevPer.Visible:=false;
   FCWinMain.FCGLSHUDobobjRotPerLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjRotPer.Visible:=false;
   FCWinMain.FCGLSHUDobobjSatLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjSat.Visible:=False;
   FCWinMain.FCGLSHUDobobjGeophyHLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjObjTpLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjObjTp.Visible:=false;
   FCWinMain.FCGLSHUDobobjDiamLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDiam.Visible:=false;
   FCWinMain.FCGLSHUDobobjDensLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDens.Visible:=false;
   FCWinMain.FCGLSHUDobobjMassLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjMass.Visible:=false;
   FCWinMain.FCGLSHUDobobjGravLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjGrav.Visible:=false;
   FCWinMain.FCGLSHUDobobjEVelLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjEVel.Visible:=false;
   FCWinMain.FCGLSHUDobobjMagFLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjMagF.Visible:=false;
   FCWinMain.FCGLSHUDobobjAxTiltLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjAxTilt.Visible:=false;
   FCWinMain.FCGLSHUDobobjAlbeLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjAlbe.Visible:=false;
   FCWinMain.FCGLSHUDcolplyr.Visible:=false;
   FCWinMain.FCGLSHUDcolplyrName.Visible:=false;
end;

procedure FCMoglUI_FO_OObShow;
begin
   FCWinMain.FCGLSHUDobobjOrbDatHLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDistLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDist.Visible:=true;
   FCWinMain.FCGLSHUDobobjEccLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjEcc.Visible:=true;
   FCWinMain.FCGLSHUDobobjZoneLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjZone.Visible:=true;
   FCWinMain.FCGLSHUDobobjRevPerLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjRevPer.Visible:=true;
   FCWinMain.FCGLSHUDobobjRotPerLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjRotPer.Visible:=true;
   FCWinMain.FCGLSHUDobobjSatLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjSat.Visible:=true;
   FCWinMain.FCGLSHUDobobjGeophyHLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjObjTpLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjObjTp.Visible:=true;
   FCWinMain.FCGLSHUDobobjDiamLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDiam.Visible:=true;
   FCWinMain.FCGLSHUDobobjDensLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDens.Visible:=true;
   FCWinMain.FCGLSHUDobobjMassLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjMass.Visible:=true;
   FCWinMain.FCGLSHUDobobjGravLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjGrav.Visible:=true;
   FCWinMain.FCGLSHUDobobjEVelLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjEVel.Visible:=true;
   FCWinMain.FCGLSHUDobobjMagFLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjMagF.Visible:=true;
   FCWinMain.FCGLSHUDobobjAxTiltLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjAxTilt.Visible:=true;
   FCWinMain.FCGLSHUDobobjAlbeLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjAlbe.Visible:=true;
end;

procedure FCMoglUI_FO_SatHide;
begin
   FCWinMain.FCGLSHUDobobjOrbDatHLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDistLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDist.Visible:=false;
   FCWinMain.FCGLSHUDobobjRevPerLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjRevPer.Visible:=false;
   FCWinMain.FCGLSHUDobobjGeophyHLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjObjTpLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjObjTp.Visible:=false;
   FCWinMain.FCGLSHUDobobjDiamLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDiam.Visible:=false;
   FCWinMain.FCGLSHUDobobjDensLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjDens.Visible:=false;
   FCWinMain.FCGLSHUDobobjMassLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjMass.Visible:=false;
   FCWinMain.FCGLSHUDobobjGravLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjGrav.Visible:=false;
   FCWinMain.FCGLSHUDobobjEVelLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjEVel.Visible:=false;
   FCWinMain.FCGLSHUDobobjMagFLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjMagF.Visible:=false;
   FCWinMain.FCGLSHUDobobjAxTiltLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjAxTilt.Visible:=false;
   FCWinMain.FCGLSHUDobobjAlbeLAB.Visible:=false;
   FCWinMain.FCGLSHUDobobjAlbe.Visible:=false;
   FCWinMain.FCGLSHUDcolplyr.Visible:=false;
   FCWinMain.FCGLSHUDcolplyrName.Visible:=false;
end;

procedure FCMoglUI_FO_SatShow;
begin
   FCWinMain.FCGLSHUDobobjOrbDatHLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDistLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDist.Visible:=true;
   FCWinMain.FCGLSHUDobobjRevPerLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjRevPer.Visible:=true;
   FCWinMain.FCGLSHUDobobjGeophyHLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjObjTpLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjObjTp.Visible:=true;
   FCWinMain.FCGLSHUDobobjDiamLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDiam.Visible:=true;
   FCWinMain.FCGLSHUDobobjDensLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjDens.Visible:=true;
   FCWinMain.FCGLSHUDobobjMassLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjMass.Visible:=true;
   FCWinMain.FCGLSHUDobobjGravLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjGrav.Visible:=true;
   FCWinMain.FCGLSHUDobobjEVelLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjEVel.Visible:=true;
   FCWinMain.FCGLSHUDobobjMagFLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjMagF.Visible:=true;
   FCWinMain.FCGLSHUDobobjAxTiltLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjAxTilt.Visible:=true;
   FCWinMain.FCGLSHUDobobjAlbeLAB.Visible:=true;
   FCWinMain.FCGLSHUDobobjAlbe.Visible:=true;
end;

procedure FODD_FO_SpUnHide;
begin
   FCWinMain.FCGLSHUDspunSTATUSLAB.Visible:=false;
   FCWinMain.FCGLSHUDspunSTATUS.Visible:=false;
   FCWinMain.FCGLSHUDspunDvLAB.Visible:=false;
   FCWinMain.FCGLSHUDspunDV.Visible:=false;
   FCWinMain.FCGLSHUDspunRMassLAB.Visible:=false;
   FCWinMain.FCGLSHUDspunRMass.Visible:=false;
   FCWinMain.FCGLSHUDspunMissLAB.Visible:=false;
   FCWinMain.FCGLSHUDspunMiss.Visible:=false;
   FCWinMain.FCGLSHUDspunTaskLAB.Visible:=false;
   FCWinMain.FCGLSHUDspunTask.Visible:=false;
   FCWinMain.FCGLSHUDspunDockd.Visible:=false;
   FCWinMain.FCGLSHUDspunDockdDat.Visible:=false;
end;

procedure FODD_FO_SpUnShow;
begin
   FCWinMain.FCGLSHUDspunSTATUSLAB.Visible:=true;
   FCWinMain.FCGLSHUDspunSTATUS.Visible:=true;
   FCWinMain.FCGLSHUDspunDvLAB.Visible:=true;
   FCWinMain.FCGLSHUDspunDV.Visible:=true;
   FCWinMain.FCGLSHUDspunRMassLAB.Visible:=true;
   FCWinMain.FCGLSHUDspunRMass.Visible:=true;
   FCWinMain.FCGLSHUDspunMissLAB.Visible:=true;
   FCWinMain.FCGLSHUDspunMiss.Visible:=true;
   FCWinMain.FCGLSHUDspunTaskLAB.Visible:=true;
   FCWinMain.FCGLSHUDspunTask.Visible:=true;
end;

procedure FODD_FO_StarHide;
begin
   FCWinMain.FCGLSHUDstarClassLAB.Visible:=false;
   FCWinMain.FCGLSHUDstarClass.Visible:=false;
   FCWinMain.FCGLSHUDstarTempLAB.Visible:=false;
   FCWinMain.FCGLSHUDstarTemp.Visible:=false;
   FCWinMain.FCGLSHUDstarDiamLAB.Visible:=false;
   FCWinMain.FCGLSHUDstarDiam.Visible:=false;
   FCWinMain.FCGLSHUDstarMassLAB.Visible:=false;
   FCWinMain.FCGLSHUDstarMass.Visible:=false;
   FCWinMain.FCGLSHUDstarLumLAB.Visible:=false;
   FCWinMain.FCGLSHUDstarLum.Visible:=false;
end;

procedure FODD_FO_StarShow;
begin
   FCWinMain.FCGLSHUDstarClassLAB.Visible:=true;
   FCWinMain.FCGLSHUDstarClass.Visible:=true;
   FCWinMain.FCGLSHUDstarTempLAB.Visible:=true;
   FCWinMain.FCGLSHUDstarTemp.Visible:=true;
   FCWinMain.FCGLSHUDstarDiamLAB.Visible:=true;
   FCWinMain.FCGLSHUDstarDiam.Visible:=true;
   FCWinMain.FCGLSHUDstarMassLAB.Visible:=true;
   FCWinMain.FCGLSHUDstarMass.Visible:=true;
   FCWinMain.FCGLSHUDstarLumLAB.Visible:=true;
   FCWinMain.FCGLSHUDstarLum.Visible:=true;
end;

procedure FCMoglUI_FocusedObj_DDisp(const FODDtp: TFCEogluiHudDispTp);
{:Purpose: set the data display for the choosen focused object.
    Additions:
      -2010Mar27- *add: space unit docked icon+label.
      -2009Dec20- *add: satellite.
      -2009Nov23- *add sections for orbital object.
      -2009Nov22- *update w/ status, current mission and phase.
      -2009Nov18- *add sections for space unit.
}
begin
   case FODDtp of
      ogluihdtStar:
      begin
         FODD_FO_SpUnHide;
         FCMoglUI_FO_OObHide;
         FODD_FO_StarShow;
      end;
      ogluihdtOObj:
      begin
         FODD_FO_SpUnHide;
         FODD_FO_StarHide;
         FCMoglUI_FO_OObShow;
      end;
      ogluihdtSat:
      begin
         FODD_FO_SpUnHide;
         FODD_FO_StarHide;
         FCMoglUI_FO_OObHide;
         FCMoglUI_FO_SatShow;
      end;
      ogluihdtSpUn:
      begin
         FODD_FO_StarHide;
         FCMoglUI_FO_OObHide;
         FODD_FO_SpUnShow;
      end;
   end;
end;

procedure FCMoglUI_Main3DViewUI_Update(
   const M3DVUIUtype: TFCEogluiUpdTp;
   const M3DVUIUtarget: TFCEogluiUpdTgt
   );
{:Purpose: update user's interface of the main3d view.
    Additions:
      -2013Jun20- *add/mod: apply the new types of planets.
      -2012Aug26- *add: specific conditions for the Spanish language.
      -2012Aug13- *fix: bug fix for the one that display the CPS HUD informations during a resizing of the main window when the CPS isn't enabled.
      -2011Apr20- *fix: update the interface only if the CPS is enabled.
      -2010Sep15- *add: entities code - only the player's entity is concerned in this routine (index= 0).
      -2010Jul04- *add: player's colony icon + label, if the focused orbital object has one.
      -2010Jun10- *add: take tphTac time phase in account.
      -2010Apr05- *fix: hide correctly the space unit status icon "docked space units" if needed.
      -2010Mar27- *add: space unit docked icon+label.
      -2010Mar22- *add: CPS CVS, credit line and time left.
      -2010Mar21- *add: cps CVS label.
      -2010Feb18- *mod: data display are put to the right corner.
      -2009Dec25- *fix: set the correct central planet index # for satellite data display.
      -2009Dec21- *add: all the rest of satellite data.
      -2009Dec20- *add: satellite name.
      -2009Dec10- *update correctly the satellite number.
                  *update correctly the orbital object mass for an asteroid.
      -2009Dec01- *missed font data label initialization.
      -2009Nov25- *add orbital object escape velocity.
                  *add orbital object magnetic field.
                  *add orbital object axial tilt.
                  *add orbital object albedo.
      -2009Nov24- *add orbital object rotation period.
                  *add orbital object satellite number.
                  *add orbital object geophysics data header.
                  *add orbital object type.
                  *add orbital object diameter.
                  *add orbital object density.
                  *add orbital object mass.
                  *add orbital object gravity.
      -2009Nov23- *add data header font initialization.
                  *add orbital object orbital data header.
                  *add orbital object distance from star.
                  *add orbital object eccentricity.
                  *add orbital object zone.
                  *add orbital object revolution period.
      -2009Nov22- *add space unit current RMass.
                  *add space unit current status.
                  *add space unit current mission.
                  *add space unit current task.
      -2009Nov18- *add space unit current DV.
      -2009Nov17- *add star diameter.
                  *add star mass.
                  *add star luminosity.
                  *add hud display following focused object type.
      -2009Nov16- *add star class.
                  *add star temperature.
      -2009Nov09- *add pause status in time and date display section.
      -2009Oct28- *add FCGLSHUDgameTimePhase display.
      -2009Sep23- *complete focused object name by adding space unit name.
      -2009Sep22- *add focused object name.
      -2009Sep06- *add font size fot oglupdtgtTime.
}
var
   M3DVUIUcol
   ,M3DVUIUownSpU
   ,M3DVUIUsatIdx
   ,M3DVUIUsatPlanIdx
   ,M3DVUIUdock: integer;

   M3DVUIUdmpPhase
   ,M3DVUIUdmpStatus: string;
begin
   {.time and date display}
   if (M3DVUIUtarget=ogluiutAll)
      or (M3DVUIUtarget=ogluiutTime)
   then
   begin
      {.user's interface initialization}
      if (M3DVUIUtype=oglupdtpAll)
         or (M3DVUIUtype=oglupdtpLocOnly)
      then
      begin
         if FCVdiLanguage='SP'
         then FCWinMain.FCGLSHUDgameDate.Position.X:=FCWinMain.Width-110
         else FCWinMain.FCGLSHUDgameDate.Position.X:=FCWinMain.Width-102;
         FCWinMain.FCGLSHUDgameDate.Position.Y:=0;
         FCWinMain.FCGLSHUDgameTime.Position.X:=FCWinMain.FCGLSHUDgameDate.Position.X;
         FCWinMain.FCGLSHUDgameTime.Position.Y:=FCWinMain.FCGLSHUDgameDate.Position.Y+16;
         FCWinMain.FCGLSHUDgameTimePhase.Position.X:=FCWinMain.FCGLSHUDgameDate.Position.X;
         FCWinMain.FCGLSHUDgameTimePhase.Position.Y:=FCWinMain.FCGLSHUDgameTime.Position.Y+16;
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSFontDateTime.Font.Size:=11
         else FCWinMain.FCGLSFontDateTime.Font.Size:=10;
      end;
      {.text display}
      if (M3DVUIUtype=oglupdtpAll)
         or (M3DVUIUtype=oglupdtpTxtOnly)
      then
      begin
         FCWinMain.FCGLSHUDgameDate.Text
            :=IntToStr(FCVdgPlayer.P_currentTimeDay)+'/'+IntToStr(FCVdgPlayer.P_currentTimeMonth)+'/'+IntToStr(FCVdgPlayer.P_currentTimeYear);
         FCWinMain.FCGLSHUDgameTime.Text
            :=IntToStr(FCVdgPlayer.P_currentTimeHour)+'hr '+IntToStr(FCVdgPlayer.P_currentTimeMinut)+'mn ';
         case FCVdgPlayer.P_currentTimePhase of
            tphTac: M3DVUIUdmpPhase:=FCFdTFiles_UIStr_Get(uistrUI,'TimeFphaseTac');
            tphMan: M3DVUIUdmpPhase:=FCFdTFiles_UIStr_Get(uistrUI,'TimeFphaseMan');
            tphSTH: M3DVUIUdmpPhase:=FCFdTFiles_UIStr_Get(uistrUI,'TimeFphaseStH');
            tphPAUSE: M3DVUIUdmpPhase:=FCFdTFiles_UIStr_Get(uistrUI,'TimeFphasePAUSE');
            tphPAUSEwo: M3DVUIUdmpPhase:='';
         end;
         FCWinMain.FCGLSHUDgameTimePhase.Text:=M3DVUIUdmpPhase;
      end;
   end;
   {.object focused display}
   if (M3DVUIUtarget=ogluiutAll)
      or (M3DVUIUtarget=ogluiutFocObj)
   then
   begin
      {.user's interface initialization}
      if (M3DVUIUtype=oglupdtpAll)
         or (M3DVUIUtype=oglupdtpLocOnly)
      then
      begin
         {.hud name}
         FCWinMain.FCGLSHUDobjectFocused.Position.X:=(FCWinMain.Width shr 1)-8;
         FCWinMain.FCGLSHUDobjectFocused.Position.Y:=(FCWinMain.Height*502) div 768;
         if FCVdiWinMainHeight<896
         then FCWinMain.FCGLSHUDobjectFocused.Position.Y:=FCWinMain.FCGLSHUDobjectFocused.Position.Y+32;
            {.hud name font}
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSFontTitleMain.Font.Size:=15//9
         else FCWinMain.FCGLSFontTitleMain.Font.Size:=12;//8;
         {.colony}
         FCWinMain.FCGLSHUDcolplyr.Position.X:=FCWinMain.FCGLSHUDobjectFocused.Position.X-50;
         FCWinMain.FCGLSHUDcolplyr.Position.Y:=FCWinMain.FCGLSHUDobjectFocused.Position.Y/2.5;
         FCWinMain.FCGLSHUDcolplyrName.Position.X:=FCWinMain.FCGLSHUDcolplyr.Position.X+60;
         FCWinMain.FCGLSHUDcolplyrName.Position.Y:=FCWinMain.FCGLSHUDcolplyr.Position.Y-12;
         {.hud star class}
            {.label}
         FCWinMain.FCGLSHUDstarClassLAB.Position.X:=FCWinMain.WM_MainViewGroup.Width -400;
         FCWinMain.FCGLSHUDstarClassLAB.Position.Y:=(FCWinMain.WM_MainViewGroup.Height shr 3*3);
            {.data display}
         FCWinMain.FCGLSHUDstarClass.Position.X:=FCWinMain.FCGLSHUDstarClassLAB.Position.X+145;
         FCWinMain.FCGLSHUDstarClass.Position.Y:=FCWinMain.FCGLSHUDstarClassLAB.Position.Y;
         {.hud star temperature}
            {.label}
         FCWinMain.FCGLSHUDstarTempLAB.Position.X:=FCWinMain.FCGLSHUDstarClassLAB.Position.X;
         FCWinMain.FCGLSHUDstarTempLAB.Position.Y:=FCWinMain.FCGLSHUDstarClassLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDstarTemp.Position.X:=FCWinMain.FCGLSHUDstarClass.Position.X;
         FCWinMain.FCGLSHUDstarTemp.Position.Y:=FCWinMain.FCGLSHUDstarTempLAB.Position.Y;
         {.hud star diameter}
            {.label}
         FCWinMain.FCGLSHUDstarDiamLAB.Position.X:=FCWinMain.FCGLSHUDstarClassLAB.Position.X;
         FCWinMain.FCGLSHUDstarDiamLAB.Position.Y:=FCWinMain.FCGLSHUDstarTempLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDstarDiam.Position.X:=FCWinMain.FCGLSHUDstarClass.Position.X;
         FCWinMain.FCGLSHUDstarDiam.Position.Y:=FCWinMain.FCGLSHUDstarDiamLAB.Position.Y;
         {.hud star mass}
            {.label}
         FCWinMain.FCGLSHUDstarMassLAB.Position.X:=FCWinMain.FCGLSHUDstarClassLAB.Position.X;
         FCWinMain.FCGLSHUDstarMassLAB.Position.Y:=FCWinMain.FCGLSHUDstarDiamLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDstarMass.Position.X:=FCWinMain.FCGLSHUDstarClass.Position.X;
         FCWinMain.FCGLSHUDstarMass.Position.Y:=FCWinMain.FCGLSHUDstarMassLAB.Position.Y;
         {.hud star luminosity}
            {.label}
         FCWinMain.FCGLSHUDstarLumLAB.Position.X:=FCWinMain.FCGLSHUDstarClassLAB.Position.X;
         FCWinMain.FCGLSHUDstarLumLAB.Position.Y:=FCWinMain.FCGLSHUDstarMassLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDstarLum.Position.X:=FCWinMain.FCGLSHUDstarClass.Position.X;
         FCWinMain.FCGLSHUDstarLum.Position.Y:=FCWinMain.FCGLSHUDstarLumLAB.Position.Y;
         //================END STAR=========================================================
         //================SPACE UNIT=======================================================
         {.hud space unit status}
            {.label}
         FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X:=FCWinMain.WM_MainViewGroup.Width-400;
         FCWinMain.FCGLSHUDspunSTATUSLAB.Position.Y:=(FCWinMain.WM_MainViewGroup.Height shr 3*3);
            {.data display}
         FCWinMain.FCGLSHUDspunSTATUS.Position.X:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X+145;
         FCWinMain.FCGLSHUDspunSTATUS.Position.Y:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.Y;
         {.hud space unit current DV}
            {.label}
         FCWinMain.FCGLSHUDspunDvLAB.Position.X:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X;
         FCWinMain.FCGLSHUDspunDvLAB.Position.Y:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDspunDv.Position.X:=FCWinMain.FCGLSHUDspunSTATUS.Position.X;
         FCWinMain.FCGLSHUDspunDv.Position.Y:=FCWinMain.FCGLSHUDspunDvLAB.Position.Y;
         {.hud space unit current reaction mass}
            {.label}
         FCWinMain.FCGLSHUDspunRMassLAB.Position.X:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X;
         FCWinMain.FCGLSHUDspunRMassLAB.Position.Y:=FCWinMain.FCGLSHUDspunDvLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDspunRMass.Position.X:=FCWinMain.FCGLSHUDspunSTATUS.Position.X;
         FCWinMain.FCGLSHUDspunRMass.Position.Y:=FCWinMain.FCGLSHUDspunRMassLAB.Position.Y;
         {.hud space unit current mission}
            {.label}
         FCWinMain.FCGLSHUDspunMissLAB.Position.X:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X;
         FCWinMain.FCGLSHUDspunMissLAB.Position.Y:=FCWinMain.FCGLSHUDspunRMassLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDspunMiss.Position.X:=FCWinMain.FCGLSHUDspunSTATUS.Position.X;
         FCWinMain.FCGLSHUDspunMiss.Position.Y:=FCWinMain.FCGLSHUDspunMissLAB.Position.Y;
         {.hud space unit current phase}
            {.label}
         FCWinMain.FCGLSHUDspunTaskLAB.Position.X:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X;
         FCWinMain.FCGLSHUDspunTaskLAB.Position.Y:=FCWinMain.FCGLSHUDspunMissLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDspunTask.Position.X:=FCWinMain.FCGLSHUDspunSTATUS.Position.X;
         FCWinMain.FCGLSHUDspunTask.Position.Y:=FCWinMain.FCGLSHUDspunTaskLAB.Position.Y;
         {.hud space unit docking status}
            {.icon}
         FCWinMain.FCGLSHUDspunDockd.Position.X:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.X+20;
         FCWinMain.FCGLSHUDspunDockd.Position.Y:=FCWinMain.FCGLSHUDspunSTATUSLAB.Position.Y-30;
            {.label}
         FCWinMain.FCGLSHUDspunDockdDat.Position.X:=FCWinMain.FCGLSHUDspunDockd.Position.X;
         FCWinMain.FCGLSHUDspunDockdDat.Position.Y:=FCWinMain.FCGLSHUDspunDockd.Position.Y-40;
         //================END SPACE UNIT===================================================
         //================ORBITAL OBJECTS==================================================
         {.orbital data header}
         FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.X:=FCWinMain.WM_MainViewGroup.Width-270;
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.Y:=(FCWinMain.WM_MainViewGroup.Height shr 4*5)
         else FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.Y:=(FCWinMain.WM_MainViewGroup.Height shr 4*4);
         {.distance from star}
            {.label}
         if FCVdiLanguage='SP'
         then FCWinMain.FCGLSHUDobobjDistLAB.Position.X:=FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.X-50
         else FCWinMain.FCGLSHUDobobjDistLAB.Position.X:=FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.X-40;
         FCWinMain.FCGLSHUDobobjDistLAB.Position.Y:=FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.Y+20;
            {.data display}
         if FCVdiLanguage='SP'
         then FCWinMain.FCGLSHUDobobjDist.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X+175
         else FCWinMain.FCGLSHUDobobjDist.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X+150;
         FCWinMain.FCGLSHUDobobjDist.Position.Y:=FCWinMain.FCGLSHUDobobjDistLAB.Position.Y;
         {.eccentricity}
            {.label}
         FCWinMain.FCGLSHUDobobjEccLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjEccLAB.Position.Y:=FCWinMain.FCGLSHUDobobjDistLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjEcc.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjEcc.Position.Y:=FCWinMain.FCGLSHUDobobjEccLAB.Position.Y;
         {.orbital zone}
            {.label}
         FCWinMain.FCGLSHUDobobjZoneLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjZoneLAB.Position.Y:=FCWinMain.FCGLSHUDobobjEccLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjZone.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjZone.Position.Y:=FCWinMain.FCGLSHUDobobjZoneLAB.Position.Y;
         {.revolution period}
            {.label}
         FCWinMain.FCGLSHUDobobjRevPerLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjRevPerLAB.Position.Y:=FCWinMain.FCGLSHUDobobjZoneLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjRevPer.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjRevPer.Position.Y:=FCWinMain.FCGLSHUDobobjRevPerLAB.Position.Y;
         {.rotation period}
            {.label}
         FCWinMain.FCGLSHUDobobjRotPerLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjRotPerLAB.Position.Y:=FCWinMain.FCGLSHUDobobjRevPerLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjRotPer.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjRotPer.Position.Y:=FCWinMain.FCGLSHUDobobjRotPerLAB.Position.Y;
         {.satellites number}
            {.label}
         FCWinMain.FCGLSHUDobobjSatLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjSatLAB.Position.Y:=FCWinMain.FCGLSHUDobobjRotPerLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjSat.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjSat.Position.Y:=FCWinMain.FCGLSHUDobobjSatLAB.Position.Y;
         {.geophysics data header}
         FCWinMain.FCGLSHUDobobjGeophyHLAB.Position.X:=FCWinMain.FCGLSHUDobobjOrbDatHLAB.Position.X;
         FCWinMain.FCGLSHUDobobjGeophyHLAB.Position.Y:=FCWinMain.FCGLSHUDobobjSatLAB.Position.Y+20;
         {.orbital object type}
            {.label}
         FCWinMain.FCGLSHUDobobjObjTpLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjObjTpLAB.Position.Y:=FCWinMain.FCGLSHUDobobjGeophyHLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjObjTp.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjObjTp.Position.Y:=FCWinMain.FCGLSHUDobobjObjTpLAB.Position.Y;
         {.orbital object diameter}
            {.label}
         FCWinMain.FCGLSHUDobobjDiamLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjDiamLAB.Position.Y:=FCWinMain.FCGLSHUDobobjObjTpLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjDiam.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjDiam.Position.Y:=FCWinMain.FCGLSHUDobobjDiamLAB.Position.Y;
         {.orbital object density}
            {.label}
         FCWinMain.FCGLSHUDobobjDensLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjDensLAB.Position.Y:=FCWinMain.FCGLSHUDobobjDiamLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjDens.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjDens.Position.Y:=FCWinMain.FCGLSHUDobobjDensLAB.Position.Y;
         {.orbital object mass}
            {.label}
         FCWinMain.FCGLSHUDobobjMassLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjMassLAB.Position.Y:=FCWinMain.FCGLSHUDobobjDensLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjMass.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjMass.Position.Y:=FCWinMain.FCGLSHUDobobjMassLAB.Position.Y;
         {.orbital object gravity}
            {.label}
         FCWinMain.FCGLSHUDobobjGravLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjGravLAB.Position.Y:=FCWinMain.FCGLSHUDobobjMassLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjGrav.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjGrav.Position.Y:=FCWinMain.FCGLSHUDobobjGravLAB.Position.Y;
         {.orbital object escape velocity}
            {.label}
         FCWinMain.FCGLSHUDobobjEVelLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjEVelLAB.Position.Y:=FCWinMain.FCGLSHUDobobjGravLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjEVel.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjEVel.Position.Y:=FCWinMain.FCGLSHUDobobjEVelLAB.Position.Y;
         {.orbital object magnetic field}
            {.label}
         FCWinMain.FCGLSHUDobobjMagFLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjMagFLAB.Position.Y:=FCWinMain.FCGLSHUDobobjEVelLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjMagF.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjMagF.Position.Y:=FCWinMain.FCGLSHUDobobjMagFLAB.Position.Y;
         {.orbital object axial tilt}
            {.label}
         FCWinMain.FCGLSHUDobobjAxTiltLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjAxTiltLAB.Position.Y:=FCWinMain.FCGLSHUDobobjMagFLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjAxTilt.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjAxTilt.Position.Y:=FCWinMain.FCGLSHUDobobjAxTiltLAB.Position.Y;
         {.orbital object albedo}
            {.label}
         FCWinMain.FCGLSHUDobobjAlbeLAB.Position.X:=FCWinMain.FCGLSHUDobobjDistLAB.Position.X;
         FCWinMain.FCGLSHUDobobjAlbeLAB.Position.Y:=FCWinMain.FCGLSHUDobobjAxTiltLAB.Position.Y+20;
            {.data display}
         FCWinMain.FCGLSHUDobobjAlbe.Position.X:=FCWinMain.FCGLSHUDobobjDist.Position.X;
         FCWinMain.FCGLSHUDobobjAlbe.Position.Y:=FCWinMain.FCGLSHUDobobjAlbeLAB.Position.Y;
         //================FONTS============================================================
         {.hud data label font}
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSFontDataLabel.Font.Size:=9
         else FCWinMain.FCGLSFontDataLabel.Font.Size:=8;
         {.hud data font}
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSFontData.Font.Size:=9
         else FCWinMain.FCGLSFontData.Font.Size:=8;
         {.hud data header font}
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSFontDataHeader.Font.Size:=11
         else FCWinMain.FCGLSFontDataHeader.Font.Size:=10;
      end;
      {.data display}
      if (M3DVUIUtype=oglupdtpAll)
         or (M3DVUIUtype=oglupdtpTxtOnly)
      then
      begin
         {.for a focused space unit}
         if (FC3doglMainViewTotalSpaceUnits>0)
            and(FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
         then
         begin
            {.change data display}
            FCMoglUI_FocusedObj_DDisp(ogluihdtSpUn);
            {.in case of that space unit is owned by the player}
            if FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].Tag=0
            then
            begin
               M3DVUIUownSpU:=round(FC3doglSpaceUnits[FC3doglSelectedSpaceUnit].TagFloat);
               {.name}
               FCWinMain.FCGLSHUDobjectFocused.Text:=FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[0].E_spaceUnits[M3DVUIUownSpU].SU_name);
               {.attitude status}
               FCWinMain.FCGLSHUDspunSTATUSLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIspunAttStat');
               M3DVUIUdmpStatus:=FCFspuF_AttStatus_Get(0, M3DVUIUownSpU);
               FCWinMain.FCGLSHUDspunSTATUS.Text:=M3DVUIUdmpStatus;
               {.current DV}
               FCWinMain.FCGLSHUDspunDvLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIspunDV');
               FCWinMain.FCGLSHUDspunDV.Text:=FloatToStr(FCDdgEntities[0].E_spaceUnits[M3DVUIUownSpU].SU_deltaV)+' Km/s';
               {.current reaction mass}
               FCWinMain.FCGLSHUDspunRMassLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIspunRMass');
               FCWinMain.FCGLSHUDspunRMass.Text:=FloatToStr(FCDdgEntities[0].E_spaceUnits[M3DVUIUownSpU].SU_reactionMass)+' m3';
               {.current mission}
               FCWinMain.FCGLSHUDspunMissLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'spUnMissCurr');
               FCWinMain.FCGLSHUDspunMiss.Text:=FCFspuF_Mission_GetMissName(0, M3DVUIUownSpU);
               {.current phase}
               FCWinMain.FCGLSHUDspunTaskLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'spUnPhaseCurr');
               FCWinMain.FCGLSHUDspunTask.Text:=FCFspuF_Mission_GetPhaseName(0, M3DVUIUownSpU);
               {.docked status}
               M3DVUIUdock:=length(FCDdgEntities[0].E_spaceUnits[M3DVUIUownSpU].SU_dockedSpaceUnits);
               if M3DVUIUdock>1
               then
               begin
                  FCWinMain.FCGLSHUDspunDockd.Visible:=true;
                  FCWinMain.FCGLSHUDspunDockdDat.Visible:=true;
                  FCWinMain.FCGLSHUDspunDockdDat.Text:='x'+IntToStr(M3DVUIUdock-1);
               end
               else if (M3DVUIUdock<=1)
                  and (FCWinMain.FCGLSHUDspunDockd.Visible)
               then
               begin
                  FCWinMain.FCGLSHUDspunDockd.Visible:=false;
                  FCWinMain.FCGLSHUDspunDockdDat.Visible:=false;
               end;
            end; //==END== if FC3DobjSpUnit[FCV3DspUnSlctd].Tag=0 ==//
         end //==END== if (FCV3DspUnTtl>0) and(Ghost.TargetObject=FC3DobjSpUnit[FCV3DspUnSlctd]) ==//
         {.for a focused satellite}
         else if (FC3doglMainViewTotalSatellites>0)
            and(FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite])
         then
         begin
            {.change data display}
            FCMoglUI_FocusedObj_DDisp(ogluihdtSat);
            {.get satellite db index # + planet index #}
            M3DVUIUsatIdx:=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag;
            M3DVUIUsatPlanIdx:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
            {.name}
            FCWinMain.FCGLSHUDobjectFocused.Text
               :=FCFdTFiles_UIStr_Get(
                  dtfscPrprName
                  , FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx]
                     .OO_satellitesList[M3DVUIUsatIdx].OO_dbTokenId
                  );
            {.orbital data header}
            FCWinMain.FCGLSHUDobobjOrbDatHLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjOrbDatH');
            {.distance from central planet}
            FCWinMain.FCGLSHUDobobjDistLAB.Text
               :=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIsatDistFCP');
            FCWinMain.FCGLSHUDobobjDist.Text
               :=FloatToStrF(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx]
                  .OO_satellitesList[M3DVUIUsatIdx].OO_isSat_distanceFromPlanetOrAsterInBeltDistToStar*1000,ffNumber,35,0)
                  +' Km';
            {.revolution period}
            FCWinMain.FCGLSHUDobobjRevPerLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjRevPer');
            FCWinMain.FCGLSHUDobobjRevPer.Text
               :=IntToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
                  .S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_revolutionPeriod)
                  +' '+FCFdTFiles_UIStr_Get(uistrUI,'TimeFstdD');
            {.geophysics data header}
            FCWinMain.FCGLSHUDobobjGeophyHLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjGeophyDatH');
            {.object type}
            FCWinMain.FCGLSHUDobobjObjTpLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjOOType');
            {.a reminder for complete types not implemented}
            FCWinMain.FCGLSHUDobobjObjTp.Text:='N/A';
            case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx]
               .OO_satellitesList[M3DVUIUsatIdx].OO_type
            of
               ootSatellite_Asteroid_Metallic: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Metall');

               ootSatellite_Asteroid_Silicate: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Sili');

               ootSatellite_Asteroid_Carbonaceous: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Carbo');

               ootSatellite_Asteroid_Icy: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Icy');

               ootSatellite_Planet_Telluric: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Tellu');

               ootSatellite_Planet_Icy: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Icy');
            end;
            {.diameter}
            FCWinMain.FCGLSHUDobobjDiamLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjDiam');
            FCWinMain.FCGLSHUDobobjDiam.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx]
                  .OO_satellitesList[M3DVUIUsatIdx].OO_diameter)+' Km';
            {.density}
            FCWinMain.FCGLSHUDobobjDensLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjDens');
            FCWinMain.FCGLSHUDobobjDens.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx]
                  .OO_satellitesList[M3DVUIUsatIdx].OO_density)+' Kg';
            {.mass}
            FCWinMain.FCGLSHUDobobjMassLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjMass');
            if FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_type>ootSatellite_Asteroid_Icy
            then FCWinMain.FCGLSHUDobobjMass.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_mass)
            else FCWinMain.FCGLSHUDobobjMass.Text:=FloatToStr( FCFcF_Round( rttMassAsteroid, FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_mass ) );
            {.gravity}
            FCWinMain.FCGLSHUDobobjGravLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjGrav');
            FCWinMain.FCGLSHUDobobjGrav.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
               .S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_gravity)+' G';
            {.escape velocity}
            FCWinMain.FCGLSHUDobobjEVelLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjEscVel');
            FCWinMain.FCGLSHUDobobjEVel.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[M3DVUIUsatPlanIdx]
                  .OO_satellitesList[M3DVUIUsatIdx].OO_escapeVelocity)+' Km/s';
            {.magnetic field}
            FCWinMain.FCGLSHUDobobjMagFLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjMagF');
            FCWinMain.FCGLSHUDobobjMagF.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
               .S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_magneticField)+' Gauss';
            {.axial tilt}
//            FCWinMain.FCGLSHUDobobjAxTiltLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjAxTilt');
//            FCWinMain.FCGLSHUDobobjAxTilt.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
//                  .S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_inclinationAxis)+chr(176);
            {.albedo}
            FCWinMain.FCGLSHUDobobjAlbeLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjAlb');
            FCWinMain.FCGLSHUDobobjAlbe.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
               .S_orbitalObjects[M3DVUIUsatPlanIdx].OO_satellitesList[M3DVUIUsatIdx].OO_albedo);
         end //==END== else if (FCV3DsatTtl>0) and(Ghost.TargetObject=FC3DobjSatGrp[FCV3DsatSlctd]) ==//
         {.for a focused central star}
         else if FC3doglSelectedPlanetAsteroid=0 then
         begin
            {.change data display}
            FCMoglUI_FocusedObj_DDisp(ogluihdtStar);
            {.name}
            FCWinMain.FCGLSHUDobjectFocused.Text
               :=FCFdTFiles_UIStr_Get(dtfscPrprName, FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_token);
            {.star class}
            FCWinMain.FCGLSHUDstarClassLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIstarClass');
            FCWinMain.FCGLSHUDstarClass.Text:=FCFcFunc_Star_GetClass(cdfFull, FC3doglCurrentStarSystem, FC3doglCurrentStar);
            {.star temperature}
            FCWinMain.FCGLSHUDstarTempLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIstarTemp');
            FCWinMain.FCGLSHUDstarTemp.Text:=inttostr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_temperature)
                  +' Kelvin';
            {.star diameter}
            FCWinMain.FCGLSHUDstarDiamLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIstarDiam');
            FCWinMain.FCGLSHUDstarDiam.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_diameter);
            {.star mass}
            FCWinMain.FCGLSHUDstarMassLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIstarMass');
            FCWinMain.FCGLSHUDstarMass.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_mass);
            {.star luminosity}
            FCWinMain.FCGLSHUDstarLumLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIstarLum');
            FCWinMain.FCGLSHUDstarLum.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_luminosity);
         end {.else if FCV3dMVorbObjSlctd=0}
         {.for a focused orbital object}
         else if FC3doglSelectedPlanetAsteroid>0
         then
         begin
            {.change data display}
            FCMoglUI_FocusedObj_DDisp(ogluihdtOObj);
            {.colony presence}
            M3DVUIUcol:=FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_colonies[0];
            if M3DVUIUcol>0
            then
            begin
               FCWinMain.FCGLSHUDcolplyr.Visible:=true;
               FCWinMain.FCGLSHUDcolplyrName.Text:=FCDdgEntities[0].E_colonies[M3DVUIUcol].C_name;
               FCWinMain.FCGLSHUDcolplyrName.Visible:=true
            end
            else if M3DVUIUcol=0
            then
            begin
               FCWinMain.FCGLSHUDcolplyr.Visible:=false;
               FCWinMain.FCGLSHUDcolplyrName.Visible:=false;
            end;
            {.name}
            FCWinMain.FCGLSHUDobjectFocused.Text
               :=FCFdTFiles_UIStr_Get(
                  dtfscPrprName
                  ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_dbTokenId
                  );
            {.orbital data header}
            FCWinMain.FCGLSHUDobobjOrbDatHLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjOrbDatH');
            {.distance from star}
            {DEV NOTE: add distance for satellites later.
            look in FC_OpenGL_DataDisp.pas of the ancient iteration of FARC.}
            FCWinMain.FCGLSHUDobobjDistLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjDistFSt');
            FCWinMain.FCGLSHUDobobjDist.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_distanceFromStar)
                  +' '+FCFdTFiles_UIStr_Get(uistrUI, 'acronAU');
            {.orbit eccentricity}
            {DEV NOTE: add ecc for rings and protoplanetary disk later.
            look in FC_OpenGL_DataDisp.pas of the ancient iteration of FARC.}
            FCWinMain.FCGLSHUDobobjEccLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjEcc');
            FCWinMain.FCGLSHUDobobjEcc.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_eccentricity);
            {.orbital zone}
            {DEV NOTE: for sat use mother's planet zone.}
            FCWinMain.FCGLSHUDobobjZoneLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjOrbZone');
            case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_orbitalZone of
               hzInner: FCWinMain.FCGLSHUDobobjZone.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'zoneInner');
               hzIntermediary: FCWinMain.FCGLSHUDobobjZone.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'zoneInterm');
               hzOuter: FCWinMain.FCGLSHUDobobjZone.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'zoneOuter');
            end;
            {.revolution period}
            {DEV NOTE: add rev period for rings and protoplanetary disk later.
            look in FC_OpenGL_DataDisp.pas of the ancient iteration of FARC.}
            FCWinMain.FCGLSHUDobobjRevPerLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjRevPer');
            FCWinMain.FCGLSHUDobobjRevPer.Text
               :=IntToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
                  .S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_revolutionPeriod)
                  +' '+FCFdTFiles_UIStr_Get(uistrUI,'TimeFstdD');
            {.rotation period}
            FCWinMain.FCGLSHUDobobjRotPerLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjRotPer');
            if (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_rotationPeriod=0)
               and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type > ootAsteroidsBelt)
            then FCWinMain.FCGLSHUDobobjRotPer.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjTidLckd')
            else if (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_rotationPeriod=0)
               and (
                  (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type < ootAsteroid_Metallic )
                     or (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type >= ootPlanet_Gaseous_Uranus )
                  )
            then FCWinMain.FCGLSHUDobobjRotPer.Text:='N/A'
            else FCWinMain.FCGLSHUDobobjRotPer.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_rotationPeriod)
                  +' hrs';
            {.number of satellites}
            FCWinMain.FCGLSHUDobobjSatLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjSat');
            FCWinMain.FCGLSHUDobobjSat.Text
               :=IntToStr(length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid]
                  .OO_satellitesList)-1);
            {.geophysics data header}
            FCWinMain.FCGLSHUDobobjGeophyHLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjGeophyDatH');
            {.object type}
            {DEV NOTE: sat and rings are not implemented yet.}
            FCWinMain.FCGLSHUDobobjObjTpLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjOOType');
            {.a reminder for complete types not implemented}
            FCWinMain.FCGLSHUDobobjObjTp.Text:='N/A';
            case FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type of
               ootAsteroidsBelt: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'ootAsteroidsBelt');

               ootAsteroid_Metallic: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Metall');

               ootAsteroid_Silicate: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Sili');

               ootAsteroid_Carbonaceous: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Carbo');

               ootAsteroid_Icy: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpAster_Icy');

               ootPlanet_Telluric: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Tellu');

               ootPlanet_Icy: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Icy');

               ootPlanet_Gaseous_Uranus: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Gas');

               ootPlanet_Gaseous_Neptune: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Gas');

               ootPlanet_Gaseous_Saturn: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_GasGiant');

               ootPlanet_Jovian: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_Jovian');

               ootPlanet_Supergiant: FCWinMain.FCGLSHUDobobjObjTp.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'oobtpPlan_SuperGiant');
            end; {.case FCDBStarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB]
               .SDB_obobj[FCV3dMVorbObjSlctd].OO_type}
            {.diameter}
            FCWinMain.FCGLSHUDobobjDiamLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjDiam');
            FCWinMain.FCGLSHUDobobjDiam.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_diameter)+' Km';
            {.density}
            FCWinMain.FCGLSHUDobobjDensLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjDens');
            FCWinMain.FCGLSHUDobobjDens.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_density)+' Kg';
            {.mass}
            FCWinMain.FCGLSHUDobobjMassLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjMass');
            if (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type>ootAsteroid_Icy)
               and (FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_type<ootSatellite_Asteroid_Metallic)
            then FCWinMain.FCGLSHUDobobjMass.Text:=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
                  .S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_mass)
            else FCWinMain.FCGLSHUDobobjMass.Text
               :=FloatToStr
                  (
                     FCFcF_Round
                        (
                           rttMassAsteroid
                           ,FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar]
                              .S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_mass
                           )
                     );
            {.gravity}
            FCWinMain.FCGLSHUDobobjGravLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjGrav');
            FCWinMain.FCGLSHUDobobjGrav.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_gravity)+' G';
            {.escape velocity}
            FCWinMain.FCGLSHUDobobjEVelLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjEscVel');
            FCWinMain.FCGLSHUDobobjEVel.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_escapeVelocity)+' Km/s';
            {.magnetic field}
            FCWinMain.FCGLSHUDobobjMagFLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjMagF');
            FCWinMain.FCGLSHUDobobjMagF.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_magneticField)+' Gauss';
            {.axial tilt}
            FCWinMain.FCGLSHUDobobjAxTiltLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjAxTilt');
            FCWinMain.FCGLSHUDobobjAxTilt.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_isNotSat_axialTilt)+chr(176);
            {.albedo}
            FCWinMain.FCGLSHUDobobjAlbeLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI, 'MVUIoobjAlb');
            FCWinMain.FCGLSHUDobobjAlbe.Text
               :=FloatToStr(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_albedo);
         end; {.else if FCV3dMVorbObjSlctd>0}
      end; //==END== if (M3DVUIUtype=oglupdtpAll) or (M3DVUIUtype=oglupdtpTxtOnly ==//
   end; //==END== if (M3DVUIUtarget=ogluiutAll) or (M3DVUIUtarget=ogluiutFocObj) ==//
   {.CPS data}
   if (M3DVUIUtarget=ogluiutAll) or (M3DVUIUtarget=ogluiutCPS) then
   begin
      {.user's interface initialization}
      if (M3DVUIUtype=oglupdtpAll)
         or (M3DVUIUtype=oglupdtpLocOnly)
      then
      begin
//         FCWinMain.FCGLSHUDcpsCVSLAB.Visible:=true;
         FCWinMain.FCGLSHUDcpsCVSLAB.Position.X:=FCWinMain.Width shr 1;
         FCWinMain.FCGLSHUDcpsCVSLAB.Position.Y:=0;
//         FCWinMain.FCGLSHUDcpsCVS.Visible:=true;
         FCWinMain.FCGLSHUDcpsCVS.Position.X:=FCWinMain.FCGLSHUDcpsCVSLAB.Position.X+10;
         FCWinMain.FCGLSHUDcpsCVS.Position.Y:=FCWinMain.FCGLSHUDcpsCVSLAB.Position.Y+16;
//         FCWinMain.FCGLSHUDcpsCredL.Visible:=true;
         FCWinMain.FCGLSHUDcpsCredL.Position.X:=FCWinMain.FCGLSHUDcpsCVS.Position.X-40;
         FCWinMain.FCGLSHUDcpsCredL.Position.Y:=FCWinMain.FCGLSHUDcpsCVS.Position.Y;
//         FCWinMain.FCGLSHUDcpsTlft.Visible:=true;
         FCWinMain.FCGLSHUDcpsTlft.Position.X:=FCWinMain.FCGLSHUDcpsCVS.Position.X+40;
         FCWinMain.FCGLSHUDcpsTlft.Position.Y:=FCWinMain.FCGLSHUDcpsCVS.Position.Y;
         {.fonts}
         if (FCVdiWinMainWidth>=1152)
            and (FCVdiWinMainHeight>=896)
         then FCWinMain.FCGLSFontCPSData.Font.Size:=11
         else FCWinMain.FCGLSFontCPSData.Font.Size:=10;
      end;
      if (FCcps<>nil)
         and (FCcps.CPSisEnabled)
         and (FCWinMain.FCGLSHUDcpsCVSLAB.Visible=false)
      then
      begin
         FCWinMain.FCGLSHUDcpsCVSLAB.Visible:=true;
         FCWinMain.FCGLSHUDcpsCVS.Visible:=true;
         FCWinMain.FCGLSHUDcpsCredL.Visible:=true;
         FCWinMain.FCGLSHUDcpsTlft.Visible:=true;
      end
      else  if (FCcps=nil)
         or (not FCcps.CPSisEnabled) then
      begin
         FCWinMain.FCGLSHUDcpsCVSLAB.Visible:=false;
         FCWinMain.FCGLSHUDcpsCVS.Visible:=false;
         FCWinMain.FCGLSHUDcpsCredL.Visible:=false;
         FCWinMain.FCGLSHUDcpsTlft.Visible:=false;
      end;
      {.text display}
      if ((M3DVUIUtype=oglupdtpAll) or (M3DVUIUtype=oglupdtpTxtOnly))
         and (FCcps<>nil)
         and (FCcps.CPSisEnabled)
      then
      begin
         FCWinMain.FCGLSHUDcpsCVSLAB.Text:=FCFdTFiles_UIStr_Get(uistrUI,'MVUIcpsCVS');
         FCWinMain.FCGLSHUDcpsCVS.Text:=FCcps.FCF_CVS_Get+'%';
         FCWinMain.FCGLSHUDcpsCredL.Text
            :=FCcps.FCF_CredLine_Get(true, false)
               +' / '
               +FCcps.FCF_CredLine_Get(false, false)
               +' '+FCFdTFiles_UIStr_Get(uistrUI, 'acronUC');
         FCWinMain.FCGLSHUDcpsTlft.Text:=FCcps.FCF_TimeLeft_Get(false);
      end;
   end;
end;

end.
