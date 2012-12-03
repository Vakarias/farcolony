{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: manage all keystrokes of all forms and components of the game

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

unit farc_ui_keys;

interface

uses
   Classes
   ,SysUtils;

type TFCEuikBrowseKey=(
   uikbkNext
   ,uikbkPrev
   ,uikbkFirst
   ,uikbkLast
   );

type TFCEuikBrowseTp=(
   uikbtOObj
   ,uikbtSat
   ,uikbtSpU
   );

///<summary>
///   test key routine for about window.
///</summary>
///   <param="AWTkeyDump">key number</param>
///   <param="AWTshftCtrl">shift state</param>
procedure FCMuiK_AboutWin_Test(
   const AWTkeyDump: integer;
   const AWTshftCtrl: TShiftState
   );

///<summary>
///   centralized browsing keys
///</summary>
///    <param name="BKSbk">browsing command</param>
procedure FCMuiK_BrowseK_Set(
   const BKSbtp: TFCEuikBrowseTp;
   const BKSbk: TFCEuikBrowseKey
   );

///<summary>
///   test key routine for the CSM events tree of the colony data panel
///</summary>
///   <param="CPTkey">key number</param>
///   <param="CPTshftCtrl">shift state</param>
procedure FCMuiK_ColCSMev_Test(
   const CCSMEkey: integer;
   const CCSMEshftCtrl: TShiftState
   );

///<summary>
///   test key routine for colony data panel / colony name edit.
///</summary>
///   <param="CNTkeyDump">key number</param>
///   <param="CNTTshftCtrl">shift state</param>
procedure FCMuiK_ColName_Test(
   const CNTkeyDump: integer;
   const CNTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for colony name in mission setup panel.
///</summary>
///   <param="CNMTkeyDump">key number</param>
///   <param="CNMTTshftCtrl">shift state</param>
procedure FCMuiK_MissionColonyName_Test(
   const CNMTkeyDump: integer;
   const CNMTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for the population trees of the colony data panel
///</summary>
///   <param="CPTkey">key number</param>
///   <param="CPTshftCtrl">shift state</param>
procedure FCMuiK_ColPopulation_Test(
   const CPTkey: integer;
   const CPTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for help panel / hints list.
///</summary>
///   <param="ILTkey">key number</param>
///   <param="ILTshftCtrl">shift state</param>
procedure FCMuiK_HintsLst_Test(
   const HLTkey: integer;
   const HLTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for docking list.
///</summary>
///   <param="DLTkey">key number</param>
///   <param="DLTshftCtrl">shift state</param>
procedure FCMuiK_DockLst_Test(
   const DLTkey: integer;
   const DLTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for settlement name in mission setup panel
///</summary>
///   <param name=""></param>
///   <param name=""></param>
procedure FCMuiK_MissionSettleName_Test(
   const CNMTkeyDump: integer;
   const CNMTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for message box list
///</summary>
///   <param="MBLTkeyDump">key number</param>
///   <param="MBLTshftCtrl">shift state</param>
procedure FCMuiK_MsgBoxList_Test(
   const MBLTkeyDump: integer;
   const MBLTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for new game setup window
///</summary>
///   <param="NGSTkeyDump">key number</param>
///   <param="NGSTshftCtrl">shift state</param>
procedure FCMuiK_NewGSet_Test(
   const NGSTkeyDump: integer;
   const NGSTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for UMI/Faction/Policies Enforcement/AFList
///</summary>
///   <param="UMIFAFLkey">key number</param>
///   <param="UMIFAFLshftCtrl">shift state</param>
procedure FCMuiK_UMIFacAFL_Test(
   const UMIFAFLkey: integer;
   const UMIFAFLshftCtrl: TShiftState
   );

///<summary>
///   test key routine for UMI/Faction/Colonies List
///</summary>
///   <param="NGSTkeyDump">key number</param>
///   <param="NGSTshftCtrl">shift state</param>
procedure FCMuiK_UMIFacCol_Test(
   const UMIFCTkey: integer;
   const UMIFCTshftCtrl: TShiftState
   );

///<summary>
///   test key routine for UMI/Faction/SPM setting
///</summary>
///   <param="UMIFSPMkey">key number</param>
///   <param="UMIFSPMshftCtrl">shift state</param>
procedure FCMuiK_UMIFacSPM_Test(
   const UMIFSPMkey: integer;
   const UMIFSPMshftCtrl: TShiftState
   );

///<summary>
///   test key routine for main window
///</summary>
///   <param="WMTkeyDump">key number</param>
///   <param="WMTshftCtrl">shift state</param>
procedure FCMuiK_WinMain_Test(
   const WMTkeyDump: integer;
   const WMTshftCtrl: TShiftState
   );

implementation

uses
   farc_data_3dopengl
   ,farc_data_game
   ,farc_data_init
   ,farc_data_messages
   ,farc_data_missionstasks //debug add, remove when the command panel is done
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_game_gameflow
   ,farc_missions_core
   ,farc_game_newg
   ,farc_main
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_ui_coldatapanel
   ,farc_ui_infrapanel
   ,farc_ui_missionsetup
   ,farc_ui_msges
   ,farc_ui_umi
   ,farc_ui_surfpanel
   ,farc_win_about
   ,farc_win_newgset;

//=============================================END OF INIT==================================

procedure FCMuiK_AboutWin_Test(
   const AWTkeyDump: integer;
   const AWTshftCtrl: TShiftState
   );
{:Purpose: test key routine for about window.
    Additions:
}
begin
   if ssAlt in AWTshftCtrl
   then FCMuiK_WinMain_Test(AWTkeyDump, AWTshftCtrl);
   if AWTkeyDump<>27
   then FCMuiK_WinMain_Test(AWTkeyDump, AWTshftCtrl);
   {.ESCAPE}
   {.close the mission setup window}
   if AWTkeyDump=27
   then FCWinAbout.Close;
end;

procedure FCMuiK_BrowseK_Set(
   const BKSbtp: TFCEuikBrowseTp;
   const BKSbk: TFCEuikBrowseKey
   );
{:Purpose: centralized browsing keys.
    Additions:
      -2010Jun02-	*add: space unit: take in account if the object is visible or not.
      -2010Apr05- *fix: browsing previous object for an orbital object simply didn't work.
}
var
   BKScnt
   ,BKSdmp
   ,BKSfrwdSpU: integer;
begin
   case BKSbtp of
      uikbtOObj:
      begin
         case BKSbk of
            uikbkNext:
            begin
               if FC3doglSelectedPlanetAsteroid<FC3doglTotalOrbitalObjects
               then
               begin
                  inc(FC3doglSelectedPlanetAsteroid);
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
                  if FCWinMain.FCWM_MissionSettings.Visible
                  then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false)
                  else if (not FCWinMain.FCWM_MissionSettings.Visible)
                     and (FCWinMain.FCWM_SP_AutoUp.Checked)
                  then FCMuiSP_SurfaceEcosphere_Set(FC3doglSelectedPlanetAsteroid, 0, false);
               end;
            end;
            uikbkPrev:
            begin
               if (FCWinMain.FCWM_MissionSettings.Visible)
                  and (FC3doglSelectedPlanetAsteroid>1)
               then
               begin
                  dec(FC3doglSelectedPlanetAsteroid);
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
                  FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false);
               end
               else if not FCWinMain.FCWM_MissionSettings.Visible
               then
               begin
                  dec(FC3doglSelectedPlanetAsteroid);
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
                  if (FCWinMain.FCWM_SP_AutoUp.Checked)
                     and (FC3doglSelectedPlanetAsteroid>0)
                  then FCMuiSP_SurfaceEcosphere_Set(FC3doglSelectedPlanetAsteroid, 0, false);
               end;
            end;
            uikbkFirst:
            begin
               if FCWinMain.FCWM_MissionSettings.Visible
               then
               begin
                  FC3doglSelectedPlanetAsteroid:=1;
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
                  FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false);
               end
               else if not FCWinMain.FCWM_MissionSettings.Visible
               then
               begin
                  FC3doglSelectedPlanetAsteroid:=0;
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
               end;
            end;
            uikbkLast:
            begin
               if FC3doglSelectedPlanetAsteroid<>FC3doglTotalOrbitalObjects
               then
               begin
                  FC3doglSelectedPlanetAsteroid:=FC3doglTotalOrbitalObjects;
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
                  if FCWinMain.FCWM_MissionSettings.Visible
                  then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false)
                  else if (not FCWinMain.FCWM_MissionSettings.Visible)
                     and (FCWinMain.FCWM_SP_AutoUp.Checked)
                  then FCMuiSP_SurfaceEcosphere_Set(FC3doglSelectedPlanetAsteroid, 0, false);
               end;
            end;
         end; //==END== case BKSbk of ==//
      end; //==END== case - uikbtOObj ==//
      uikbtSat:
      begin
         case BKSbk of
            uikbkNext:
            begin
               if FC3doglSelectedSatellite<FC3doglTotalSatellites
               then
               begin
                  BKSdmp:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite+1].TagFloat);
                  if (FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite+1].Tag<=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag)
                     or (FC3doglSelectedPlanetAsteroid<>BKSdmp)
                  then FC3doglSelectedPlanetAsteroid:=BKSdmp;
                  inc(FC3doglSelectedSatellite);
               end;
            end;
            uikbkPrev:
            begin
               if FC3doglSelectedSatellite>1
               then
               begin
                  BKSdmp:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite-1].TagFloat);
                  if (FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite-1].Tag>=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag)
                     or (FC3doglSelectedPlanetAsteroid<>BKSdmp)
                  then FC3doglSelectedPlanetAsteroid:=BKSdmp;
                  dec(FC3doglSelectedSatellite);
               end;
            end;
            uikbkFirst:
            begin
               if FC3doglSelectedSatellite>1
               then
               begin
                  BKSdmp:=round(FC3doglSatellitesObjectsGroups[1].TagFloat);
                  if (BKSdmp<>FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat)
                     or (FC3doglSelectedPlanetAsteroid<>BKSdmp)
                  then FC3doglSelectedPlanetAsteroid:=BKSdmp;
                  FC3doglSelectedSatellite:=1;
               end;
            end;
            uikbkLast:
            begin
               if FC3doglSelectedSatellite<FC3doglTotalSatellites
               then
               begin
                  BKSdmp:=round(FC3doglSatellitesObjectsGroups[FC3doglTotalSatellites].TagFloat);
                  if (BKSdmp<>FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat)
                     or (FC3doglSelectedPlanetAsteroid<>BKSdmp)
                  then FC3doglSelectedPlanetAsteroid:=BKSdmp;
                  FC3doglSelectedSatellite:=FC3doglTotalSatellites;
               end;
            end;
         end; //==END== case BKSbk of ==//
         FCMoglVM_CamMain_Target(100, false);
         if FCWinMain.FCWM_MissionSettings.Visible
         then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false)
         else if (not FCWinMain.FCWM_MissionSettings.Visible)
            and (FCWinMain.FCWM_SP_AutoUp.Checked)
         then FCMuiSP_SurfaceEcosphere_Set(FC3doglSelectedPlanetAsteroid, FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].Tag, false);
      end; //==END== case - uikbtSat ==//
      uikbtSpU:
      begin
         FCMoglVMain_SpUnits_SetInitSize(true);
         case BKSbk of
            uikbkNext:
            begin
               if FC3doglSelectedSpaceUnit<FC3doglTotalSpaceUnits
               then
               begin
                  if not FC3doglSpaceUnits[FC3doglSelectedSpaceUnit+1].Visible
                  then
                  begin
                     BKScnt:=FC3doglSelectedSpaceUnit+2;
                     while BKScnt<=FC3doglTotalSpaceUnits do
                     begin
                        if FC3doglSpaceUnits[BKScnt].Visible
                        then
                        begin
                              FC3doglSelectedSpaceUnit:=BKScnt;
                              break;
                        end
                        else if not FC3doglSpaceUnits[BKScnt].Visible
                        then inc(BKScnt);
                     end;
                  end
                  else if FC3doglSpaceUnits[FC3doglSelectedSpaceUnit+1].Visible
                  then inc(FC3doglSelectedSpaceUnit);
               end;
            end;
            uikbkPrev:
            begin
               if FC3doglSelectedSpaceUnit>1
               then
               begin
                  if not FC3doglSpaceUnits[FC3doglSelectedSpaceUnit-1].Visible
                  then
                  begin
                     BKScnt:=FC3doglSelectedSpaceUnit-2;
                     while BKScnt>=1 do
                     begin
                        if FC3doglSpaceUnits[BKScnt].Visible
                        then
                        begin
                           FC3doglSelectedSpaceUnit:=BKScnt;
                           break;
                        end
                        else if not FC3doglSpaceUnits[BKScnt].Visible
                        then dec(BKScnt);
                     end;
                  end
                  else if FC3doglSpaceUnits[FC3doglSelectedSpaceUnit-1].Visible
                  then dec(FC3doglSelectedSpaceUnit);
               end;
            end;
            uikbkFirst:
            begin
               if (FC3doglSelectedSpaceUnit>1)
                  and (FC3doglSpaceUnits[1].Visible)
               then FC3doglSelectedSpaceUnit:=1
               else if (FC3doglSelectedSpaceUnit>2)
                  and (not FC3doglSpaceUnits[1].Visible)
               then
               begin
                  BKScnt:=2;
                  while BKScnt<FC3doglSelectedSpaceUnit do
                  begin
                     if FC3doglSpaceUnits[BKScnt].Visible
                     then
                     begin
                        FC3doglSelectedSpaceUnit:=BKScnt;
                        break;
                     end
                     else if not FC3doglSpaceUnits[BKScnt].Visible
                     then inc(BKScnt);
                  end;
               end;
            end;
            uikbkLast:
            begin
               if (FC3doglSelectedSpaceUnit<FC3doglTotalSpaceUnits)
                  and (FC3doglSpaceUnits[FC3doglTotalSpaceUnits].Visible)
               then FC3doglSelectedSpaceUnit:=FC3doglTotalSpaceUnits
               else if (FC3doglSelectedSpaceUnit<FC3doglTotalSpaceUnits-1)
                  and (not FC3doglSpaceUnits[FC3doglTotalSpaceUnits].Visible)
               then
               begin
                  BKScnt:=FC3doglTotalSpaceUnits-2;
                  while BKScnt>=1 do
                  begin
                     if FC3doglSpaceUnits[BKScnt].Visible
                     then
                     begin
                        FC3doglSelectedSpaceUnit:=BKScnt;
                        break;
                     end
                     else if not FC3doglSpaceUnits[BKScnt].Visible
                     then dec(BKScnt);
                  end;
               end;
            end;
         end; //==END== case BKSbk of ==//
         FCMoglVM_CamMain_Target(-1, true);
      end; //==END== case - uikbtSpU: ==//
   end; //==END== case BKSbtp of ==//
end;

procedure FCMuiK_ColCSMev_Test(
   const CCSMEkey: integer;
   const CCSMEshftCtrl: TShiftState
   );
{:Purpose: test key routine for the CSM events tree of the colony data panel.
    Additions:
}
begin
   if (ssAlt in CCSMEshftCtrl)
      or ((CCSMEkey<>38) or (CCSMEkey<>40))
   then FCMuiK_WinMain_Test(CCSMEkey, CCSMEshftCtrl);
end;

procedure FCMuiK_ColName_Test(
   const CNTkeyDump: integer;
   const CNTshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony data panel / colony name edit.
    Additions:
      -2011May24- *mod: use a private variable instead of a tag for the colony index.
      -2010Sep19- *add: entities code.
}
begin
   if (ssAlt in CNTshftCtrl)
   then FCMuiK_WinMain_Test(CNTkeyDump, CNTshftCtrl);
   if (CNTkeyDump<>13)
      and (CNTkeyDump<>32)
      and (CNTkeyDump<>39)
      and (
         (CNTkeyDump<65)
         or ((CNTkeyDump>90) and (CNTkeyDump<96))
         or ((CNTkeyDump>105) and (CNTkeyDump<180))
         )
   then FCMuiK_WinMain_Test(CNTkeyDump, CNTshftCtrl);
   {.ENTER}
   {.proceed setup if allowed}
   if CNTkeyDump=13
   then FCDdgEntities[0].E_colonies[FCFuiCDP_VarCurrentColony_Get].C_name:=FCWinMain.FCWM_CDPcolName.Text;
end;

procedure FCMuiK_MissionColonyName_Test(
   const CNMTkeyDump: integer;
   const CNMTshftCtrl: TShiftState
   );
{:Purpose: test key routine for colony name in mission setup panel.
    Additions:
}
begin
   if (ssAlt in CNMTshftCtrl)
   then FCMuiK_WinMain_Test(CNMTkeyDump, CNMTshftCtrl);
   if (CNMTkeyDump<>32)
      and (CNMTkeyDump<>39)
      and (
         (CNMTkeyDump<65)
         or ((CNMTkeyDump>90) and (CNMTkeyDump<96))
         or ((CNMTkeyDump>105) and (CNMTkeyDump<180))
         )
   then FCMgMC_KeyButtons_Test(CNMTkeyDump, CNMTshftCtrl);
end;

procedure FCMuiK_ColPopulation_Test(
   const CPTkey: integer;
   const CPTshftCtrl: TShiftState
   );
{:Purpose: test key routine for the population trees of the colony data panel.
    Additions:
}
begin
   if (ssAlt in CPTshftCtrl)
      or ((CPTkey<>38) or (CPTkey<>40))
   then FCMuiK_WinMain_Test(CPTkey, CPTshftCtrl);
end;

procedure FCMuiK_HintsLst_Test(
   const HLTkey: integer;
   const HLTshftCtrl: TShiftState
   );
{:Purpose: test key routine for help panel / hints list.
    Additions:
}
begin
   if (ssAlt in HLTshftCtrl)
      or ((HLTkey<>38) or (HLTkey<>40))
   then FCMuiK_WinMain_Test(HLTkey, HLTshftCtrl);
end;

procedure FCMuiK_DockLst_Test(
   const DLTkey: integer;
   const DLTshftCtrl: TShiftState
   );
{:Purpose: test key routine for docking list.
    Additions:
}
begin
   if (ssAlt in DLTshftCtrl)
   then FCMuiK_WinMain_Test(DLTkey, DLTshftCtrl);
   if ((DLTkey<>13) and (FCWinMain.Tag<>1))
      and (DLTkey<>27)
      and (DLTkey<>38)
      and (DLTkey<>40)
   then FCMuiK_WinMain_Test(DLTkey, DLTshftCtrl);
   {.ENTER}
   {.space unit selection}
   {:DEV NOTE: will be used for mission.}
   if DLTkey=13
   then
   begin

   end;
   {.ESCAPE}
   {.close the list}
   if DLTkey=27
   then
   begin
      FCWinMain.FCWM_DockLstPanel.Visible:=false;
      FCWinMain.FocusControl(FCWinMain.FCWM_MsgeBox_List);
   end;
end;

procedure FCMuiK_MissionSettleName_Test(
   const CNMTkeyDump: integer;
   const CNMTshftCtrl: TShiftState
   );
{:Purpose: test key routine for settlement name in mission setup panel.
    Additions:
}
begin
   if (ssAlt in CNMTshftCtrl)
   then FCMuiK_WinMain_Test(CNMTkeyDump, CNMTshftCtrl);
   if (CNMTkeyDump<>32)
      and (CNMTkeyDump<>39)
      and (
         (CNMTkeyDump<65)
         or ((CNMTkeyDump>90) and (CNMTkeyDump<96))
         or ((CNMTkeyDump>105) and (CNMTkeyDump<180))
         )
   then FCMgMC_KeyButtons_Test(CNMTkeyDump, CNMTshftCtrl);
end;

procedure FCMuiK_MsgBoxList_Test(
   const MBLTkeyDump: integer;
   const MBLTshftCtrl: TShiftState
   );
{:Purpose: test key routine for message box list.
    Additions:
      -2010Jun09- *add: supr key for message deletion.
                  *rem: enter key action is deprecated.
      -2009Oct14- *add ctrl override.
      -2009Oct08- *set correctly the tag.
      -2009Oct04- *total completion.
}
var
   MBLTclone
   ,MBLTcnt
   ,MBLTidx
   ,MBLTmax: integer;

   MBLTmsgStoMsg
   ,MBLTmsgStoTtl: array of string;
begin
   if (ssAlt in MBLTshftCtrl)
   then FCMuiK_WinMain_Test(MBLTkeyDump, MBLTshftCtrl);
   if (MBLTkeyDump<>27)
      and (MBLTkeyDump<>38)
      and (MBLTkeyDump<>40)
      and (MBLTkeyDump<>46)
   then FCMuiK_WinMain_Test(MBLTkeyDump, MBLTshftCtrl);
   case MBLTkeyDump of
      {.ESCAPE}
      {.minimize the box}
      27: if not FCWinMain.FCWM_MsgeBox.Collaps
         then FCMuiM_MessageBox_ResetState(true);
      {.DELETE}
      {.delete the current message}
      46:
      begin
         if not FCWinMain.FCWM_MsgeBox.Collaps
         then
         begin
            setlength(MBLTmsgStoTtl, length(FCVmsgStoTtl)-1);
            setlength(MBLTmsgStoMsg, length(FCVmsgStoMsg)-1);
            MBLTidx:=FCWinMain.FCWM_MsgeBox_List.ItemIndex+1;
            MBLTcnt:=1;
            MBLTclone:=0;
            MBLTmax:=FCVmsgCount;
            while MBLTcnt<=MBLTmax do
            begin
               if MBLTcnt<>MBLTidx
               then
               begin
                  inc(MBLTclone);
                  MBLTmsgStoTtl[MBLTclone]:=FCVmsgStoTtl[MBLTcnt];
                  MBLTmsgStoMsg[MBLTclone]:=FCVmsgStoMsg[MBLTcnt];
               end;
               inc(MBLTcnt);
            end;
            setlength(FCVmsgStoTtl, length(MBLTmsgStoTtl));
            setlength(FCVmsgStoMsg, length(MBLTmsgStoMsg));
            dec(FCVmsgCount);
            MBLTcnt:=1;
            MBLTmax:=length(FCVmsgStoTtl)-1;
            while MBLTcnt<=MBLTmax do
            begin
               FCVmsgStoTtl[MBLTcnt]:=MBLTmsgStoTtl[MBLTcnt];
               FCVmsgStoMsg[MBLTcnt]:=MBLTmsgStoMsg[MBLTcnt];
               inc(MBLTcnt);
            end;
            if FCVmsgCount=0
            then
            begin
               FCMuiM_MessageBox_ResetState(true);
               FCWinMain.FCWM_MsgeBox.Hide;
            end
            else
            begin
               FCWinMain.FCWM_MsgeBox_List.DeleteSelected;
               if MBLTidx=1
               then FCWinMain.FCWM_MsgeBox_List.ItemIndex:=0
               else if MBLTidx>1
               then FCWinMain.FCWM_MsgeBox_List.ItemIndex:=MBLTidx-2;
            end;
            if FCWinMain.FCWM_MsgeBox.Tag=1
            then FCMuiM_MessageDesc_Upd;
         end; //==END== if not FCWinMain.FCWM_MsgeBox.Collaps ==//
      end; //==END== case: 46 ==//
   end; //==END== case MBLTkeyDump of ==//
end;

procedure FCMuiK_NewGSet_Test(
   const NGSTkeyDump: integer;
   const NGSTshftCtrl: TShiftState
   );
{:Purpose: test key routine for new game setup window.
    Additions:
      -2009Nov18- *fix and complete keys.
      -2009Nov08- *add enter key for launch the new game in the edit section.
}
begin
   if (ssAlt in NGSTshftCtrl)
      or (ssCtrl in NGSTshftCtrl)
   then FCMuiK_WinMain_Test(NGSTkeyDump, NGSTshftCtrl);
   if (NGSTkeyDump<>65)
      and (NGSTkeyDump<>80)
      and (NGSTkeyDump<>13)
      and (NGSTkeyDump<>27)
   then FCMuiK_WinMain_Test(NGSTkeyDump, NGSTshftCtrl);
   {.ENTER}
   {.proceed setup if allowed}
   if (NGSTkeyDump=13)
      and (FCWinNewGSetup.FCWNGS_Frm_ButtProceed.Enabled)
   then FCMgNG_Core_Proceed;
   {.ESCAPE}
   {.close the mission setup window}
   if NGSTkeyDump=27
   then FCWinNewGSetup.Close;
end;

procedure FCMuiK_UMIFacAFL_Test(
   const UMIFAFLkey: integer;
   const UMIFAFLshftCtrl: TShiftState
   );
{:Purpose: test key routine for UMI/Faction/Policies Enforcement/AFList
    Additions:
}
begin
   if (ssAlt in UMIFAFLshftCtrl)
      or ((UMIFAFLkey<>38) or (UMIFAFLkey<>40))
   then FCMuiK_WinMain_Test(UMIFAFLkey, UMIFAFLshftCtrl);
end;

procedure FCMuiK_UMIFacCol_Test(
   const UMIFCTkey: integer;
   const UMIFCTshftCtrl: TShiftState
   );
{:Purpose: test key routine for UMI/Faction/Colonies List.
    Additions:
}
begin
   if (ssAlt in UMIFCTshftCtrl)
      or ((UMIFCTkey<>38) or (UMIFCTkey<>40))
   then FCMuiK_WinMain_Test(UMIFCTkey, UMIFCTshftCtrl);
end;

procedure FCMuiK_UMIFacSPM_Test(
   const UMIFSPMkey: integer;
   const UMIFSPMshftCtrl: TShiftState
   );
{:Purpose: test key routine for UMI/Faction/SPM setting.
    Additions:
}
begin
   if (ssAlt in UMIFSPMshftCtrl)
      or ((UMIFSPMkey<>38) or (UMIFSPMkey<>40))
   then FCMuiK_WinMain_Test(UMIFSPMkey, UMIFSPMshftCtrl);
end;

procedure FCMuiK_WinMain_Test(
   const WMTkeyDump: integer;
   const WMTshftCtrl: TShiftState
   );
{:DEV NOTE: DO NOT FORGET TO UPDATE THE HELP PANEL / KEYS TAB.}
{:Purpose: test key routine for main window.
    Additions:
      -2012Nov29- *add: action panel update.
      -2012Nov11- *fix: for the numpad browsing keys
                  *mod: optimization of the code concerning the shortcut keys for the 3d view.
      -2011May30- *add: infrastructure opanel linked with the escape key.
      -2010Nov01- *mod: update the keys for the UMI.
      -2010Oct18- *add: link to UMI set size when a tab is selected.
                  *add: when using m for message box, a bringtofront is applied.
      -2010Oct14- *add: bring to front the UMI if a UMI shortcut is called.
      -2010Oct13- *add: UMI shortcuts.
      -2010Sep30- *add: ctrl+q override.
      -2010Jul04- *add/fix: complete the pause key.
                  *add: escape key for mission setup window.
      -2010Jun09- *add: set the focus on the messages list if the message box is poped w/ m key.
      -2010Apr08- *add: new condition for blocking oobj/sat browsing w/ colonization mission setup.
      -2010Apr03- *mod: centralize all browsing keys code in FCMuiK_BrowseK_Set  .
      -2010Mar20- *add: auto update surface panel.
      -2010Mar15- *add: message box shortcut M.
      -2010Feb20- *fix: the star could be selected, during an interplanetary transit mission.
      -2010Feb17- *add: resize the unit during space unit browsing.
      -2010Jan18- *mod: disable F1 Help panel shortcut, since it's now implemented in the help panel menu item.
      -2010Jan08- *mod: change gameflow state method according to game flow changes.
      -2009Dec26- *add/fix: condition for satellite browsing (fix a data update during a transit mission.
      -2009Dec19- *mod/fix: switch in sat view only if the current orbital object have satellites.
      -2009Dec17- *mod: orbital object browse keys.
                  *add: complete space unit browse keys.
                  *add: satellite browse keys.
      -2009Dec16- *add: A for satellite view switch
      -2009Dec02- *F1 addon and modifications.
      -2009Dec01- *help panel with F1.
      -2009Nov09- *pause/unpause game with P.
      -2009Oct28- *game time phases switch.
      -2009Oct24- *prevent the central star to be selected during a mission setup.
      -2009Oct14- *add the case when then mission setup window is displayed.
                  *bugfix some key codes.
      -2009Oct04- *total rewrite completion.
                  *change browsing keys for space units to keypad keys.
      -2009Oct01- *add alt+f4.
                  *add control override.
                  *add m.
                  *use numpad for orbital object selection.
      -2009Sep22- *'s' is now a full switch between orbital object focus and space unit
                  focus, in main 3d view.
      -2009Sep20- *update s key w/3dMainGrp.
}
var
   WMTdmpPlan
   ,WMTfocus: integer;
begin
   if FCWinMain.WM_ActionPanel.Visible
   then FCWinMain.WM_ActionPanel.Hide;
   {.implement alt+f4 + ctrl+q in case of an override focus}
   if (ssAlt in WMTshftCtrl)
      and ((WMTkeyDump=115) or (WMTkeyDump=115))
   then FCWinMain.Close
   {.control + "" override}
   else if (ssCtrl in WMTshftCtrl)
   then
   begin

   end
   else
   begin
      {.ESC}
      if WMTkeyDump=27
      then
      begin
         if FCWinMain.FCWM_MissionSettings.Visible
         then FCMgMC_KeyButtons_Test(WMTkeyDump, WMTshftCtrl)
         else if FCWinMain.FCWM_InfraPanel.Visible
         then FCMuiIP_PanelKey_Test(WMTkeyDump, WMTshftCtrl);
      end;
      {.F1}
      {.used by help panel shortcut menu item, so no code here}
      {.F2 to F8 - UMI}
      if (WMTkeyDump>112)
         and (WMTkeyDump<120)
      then
      begin
         if not FCWinMain.FCWM_UMI.Visible
         then FCWinMain.FCWM_UMI.Visible:=true;
         if FCWinMain.FCWM_UMI.Collaps
         then FCWinMain.FCWM_UMI.Collaps:=false;
         FCWinMain.FCWM_UMI.BringToFront;
         if WMTkeyDump=113
         then
         begin
            FCWinMain.FCWM_UMI_TabSh.ActivePageIndex:=0;
//            FCMumi_Main_TabSetSize;
         end
         else if (WMTkeyDump>113)
            and (WMTkeyDump<117)
         then
         begin
            if FCWinMain.FCWM_UMI_TabSh.ActivePageIndex<>1
            then
            begin
               FCWinMain.FCWM_UMI_TabSh.ActivePageIndex:=1;
//               FCMumi_Main_TabSetSize;
            end;
            FCWinMain.FCWM_UMIFac_TabSh.ActivePageIndex:=WMTkeyDump-114;
         end
         else if (WMTkeyDump>116)
            and (WMTkeyDump<120)
         then
         begin
            FCWinMain.FCWM_UMI_TabSh.ActivePageIndex:=WMTkeyDump-115;
//            FCMumi_Main_TabSetSize;
         end;
         FCMuiUMI_CurrentTab_Update( true, true );
      end;
      {.=====================================}
      if (FCWinMain.FCWM_3dMainGrp.Visible)
         and ( (FCVdgPlayer.P_currentTimePhase=tphPAUSE) or  (FCVdgPlayer.P_currentTimePhase=tphPAUSEwo) )then
      begin
         case WMTkeyDump of
            {.P}
            {.unpause the game}
            80: FCMgTFlow_FlowState_Set(tphTac);
         end; //==END== case WMTkeyDump of ==//
      end //==END== if (FCWinMain.FCWM_3dMainGrp.Visible) and (FCVdgPlayer.P_currentTimePhase=tphPAUSE) then ==//
      else if (FCWinMain.FCWM_3dMainGrp.Visible)
         and (FCVdgPlayer.P_currentTimePhase<>tphPAUSE)
         and (FCVdgPlayer.P_currentTimePhase<>tphPAUSEwo) then
      begin
         case WMTkeyDump of
            {. A}
            {.switch satellite view <=> orbital object view}
            65:
            begin
               if (FC3doglTotalSatellites>0)
                  and (FCWinMain.FCGLSCamMainViewGhost.TargetObject<>FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite])
                  and
                     (
                        (
                           (not FCWinMain.FCWM_MissionSettings.Visible)
                           and
                           (length(FCDduStarSystem[FC3doglCurrentStarSystem].SS_stars[FC3doglCurrentStar].S_orbitalObjects[FC3doglSelectedPlanetAsteroid].OO_satellitesList)>1)
                        )
                        or
                        (
                           (FCWinMain.FCWM_MissionSettings.Visible)
                           and
                           (FCWinMain.FCWM_MissionSettings.Caption.Text
                              =FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
                           )
                        )
                     )
               then
               begin
                  if round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat)<>FC3doglSelectedPlanetAsteroid
                  then
                  begin
                     FC3doglSelectedPlanetAsteroid:=round(FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite].TagFloat);
                  end;
                  FCMoglVM_CamMain_Target(100, false);
                  if FCWinMain.FCWM_MissionSettings.Visible
                  then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false);
               end
               else if (FC3doglTotalSatellites>0)
                  and (FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSatellitesObjectsGroups[FC3doglSelectedSatellite])
               then
               begin
                  FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
                  if FCWinMain.FCWM_MissionSettings.Visible
                  then FCMuiMS_InterplanetaryTransitInterface_UpdateDestination(false);
               end;
            end;

            {.C}
            67:
            begin
               if ( (FCWinNewGSetup=nil) or ( (FCWinNewGSetup<>nil) and (  not FCWinNewGSetup.Visible) ) )
                  and (not FCWinMain.FCWM_MissionSettings.Visible)
                  and (FCVdgPlayer.P_currentTimePhase<>tphSTH)
               then FCMgTFlow_FlowState_Set(tphSTH);
            end;

            {.M}
            {.message box raise/expand}
            77:
            begin
               if not FCWinMain.FCWM_MissionSettings.Visible
               then
               begin
                  if FCWinMain.FCWM_MsgeBox.Collaps
                  then
                  begin
                     FCWinMain.FCWM_MsgeBox.Collaps:=false;
                     FCWinMain.FCWM_MsgeBox.Height:=FCWinMain.Height div 6;
                     FCWinMain.FCWM_MsgeBox.Top:=FCWinMain.FCWM_3dMainGrp.Height-(FCWinMain.FCWM_MsgeBox.Height+2);
                     FCWinMain.FCWM_MsgeBox.BringToFront;
                     FCWinMain.FCWM_MsgeBox_List.SetFocus;
                  end
                  else if (not FCWinMain.FCWM_MsgeBox.Collaps)
                     and (FCWinMain.FCWM_MsgeBox.Tag=0)
                  then FCFuiM_MessageBox_Expand
                  else if (not FCWinMain.FCWM_MsgeBox.Collaps)
                     and (FCWinMain.FCWM_MsgeBox.Tag=1)
                  then FCMuiM_MessageBox_ResetState(true);
               end;
            end;

            {.P}
            {.pause the game}
            80:
            begin
               FCMgTFlow_FlowState_Set(tphPAUSE);
               FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutTime);
            end;

            {. S}
            {.switch space unit view <=> orbital object view}
            83:
            begin
               if (FC3doglTotalSpaceUnits>0)
                  and (FCWinMain.FCGLSCamMainViewGhost.TargetObject<>FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
                  and (not FCWinMain.FCWM_MissionSettings.Visible)
               then FCMoglVM_CamMain_Target(-1, true)
               else if (FC3doglTotalSpaceUnits>0)
                  and (FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3doglSpaceUnits[FC3doglSelectedSpaceUnit])
                  and (not FCWinMain.FCWM_MissionSettings.Visible)
               then FCMoglVM_CamMain_Target(FC3doglSelectedPlanetAsteroid, true);
            end;

            {.X}
            88:
            begin
               if ( (FCWinNewGSetup=nil) or ( (FCWinNewGSetup<>nil) and (  not FCWinNewGSetup.Visible) ) )
                  and (not FCWinMain.FCWM_MissionSettings.Visible)
               then
               begin
                  if FCVdgPlayer.P_currentTimePhase<>tphMan
                  then FCMgTFlow_FlowState_Set(tphMan);
               end;
            end;

            {.Z}
            90:
            begin
               if ( (FCWinNewGSetup=nil) or ( (FCWinNewGSetup<>nil) and (  not FCWinNewGSetup.Visible) ) )
                  and (not FCWinMain.FCWM_MissionSettings.Visible)
               then
               begin
                  if FCVdgPlayer.P_currentTimePhase<>tphTac
                  then FCMgTFlow_FlowState_Set(tphTac);
               end;
            end;

            {NUMPAD1}
            {.last focused object}
            97:
            begin
               WMTfocus:=FCFoglVM_Focused_Get;
               case WMTfocus of
                  1, 2:
                  begin
                     if (not FCWinMain.FCWM_MissionSettings.Visible)
                        or (
                              (FCWinMain.FCWM_MissionSettings.Visible)
                              and
                              (FCWinMain.FCWM_MissionSettings.Caption.Text
                                 =FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
                              )
                           )
                     then
                     begin
                        if WMTfocus=1
                        then FCMuiK_BrowseK_Set(uikbtOObj, uikbkLast)
                        else if WMTfocus=2
                        then FCMuiK_BrowseK_Set(uikbtSat, uikbkLast);
                     end;
                  end;
                  3:
                  begin
                     if not FCWinMain.FCWM_MissionSettings.Visible
                     then FCMuiK_BrowseK_Set(uikbtSpU, uikbkLast);
                  end;
               end;
            end;

            {.NUMPAD4}
            {.previous focused object}
            100:
            begin
               WMTfocus:=FCFoglVM_Focused_Get;
               case WMTfocus of
                  1, 2:
                  begin
                     if (not FCWinMain.FCWM_MissionSettings.Visible)
                        or (
                              (FCWinMain.FCWM_MissionSettings.Visible)
                              and
                              (FCWinMain.FCWM_MissionSettings.Caption.Text
                                 =FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
                              )
                           )
                     then
                     begin
                        if WMTfocus=1
                        then FCMuiK_BrowseK_Set(uikbtOObj, uikbkPrev)
                        else if WMTfocus=2
                        then FCMuiK_BrowseK_Set(uikbtSat, uikbkPrev);
                     end;
                  end;
                  3:
                  begin
                     if not FCWinMain.FCWM_MissionSettings.Visible
                     then FCMuiK_BrowseK_Set(uikbtSpU, uikbkPrev);
                  end;
               end;
            end;

            {.NUMPAD6}
            {.next focused object}
            102:
            begin
               WMTfocus:=FCFoglVM_Focused_Get;
               case WMTfocus of
                  0, 1, 2:
                  begin
                     if (not FCWinMain.FCWM_MissionSettings.Visible)
                        or (
                              (FCWinMain.FCWM_MissionSettings.Visible)
                              and
                              (FCWinMain.FCWM_MissionSettings.Caption.Text
                                 =FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
                              )
                           )
                     then
                     begin
                        if (WMTfocus=0)
                           or (WMTfocus=1)
                        then FCMuiK_BrowseK_Set(uikbtOObj, uikbkNext)
                        else if WMTfocus=2
                        then FCMuiK_BrowseK_Set(uikbtSat, uikbkNext);
                     end;
                  end;
                  3:
                  begin
                     if not FCWinMain.FCWM_MissionSettings.Visible
                     then FCMuiK_BrowseK_Set(uikbtSpU, uikbkNext);
                  end;
               end;
            end;

            {.NUMPAD7}
            {.first focused object}
            103:
            begin
               WMTfocus:=FCFoglVM_Focused_Get;
               case WMTfocus of
                  1, 2:
                  begin
                     if (not FCWinMain.FCWM_MissionSettings.Visible)
                        or (
                              (FCWinMain.FCWM_MissionSettings.Visible)
                              and
                              (FCWinMain.FCWM_MissionSettings.Caption.Text
                                 =FCFdTFiles_UIStr_Get(uistrUI,'FCWinMissSet')+FCFdTFiles_UIStr_Get(uistrUI,'Mission.itransit')
                              )
                           )
                     then
                     begin
                        if WMTfocus=1
                        then FCMuiK_BrowseK_Set(uikbtOObj, uikbkFirst)
                        else if WMTfocus=2
                        then FCMuiK_BrowseK_Set(uikbtSat, uikbkFirst);
                     end;
                  end;
                  3:
                  begin
                     if not FCWinMain.FCWM_MissionSettings.Visible
                     then FCMuiK_BrowseK_Set(uikbtSpU, uikbkFirst);
                  end;
               end;
            end;
         end; //==END== case WMTkeyDump of ==//
      end; //==END== if (FCWinMain.FCWM_3dMainGrp.Visible) and (FCVdgPlayer.P_currentTimePhase<>tphPAUSE) then ==//
   end; //==END== else begin of if (ssAlt in WMTshftCtrl) and ((WMTkeyDump=115) or (WMTkeyDump=115)) + else if (ssCtrl in WMTshftCtrl) ==//
end;

end.
