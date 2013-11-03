{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: continue game core unit for all game and ui process

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

unit farc_game_contg;

interface

uses
   SysUtils;

///<summary>
///   initialize the current game
///</summary>
procedure FCMgCG_Core_Proceed;

implementation

uses
   farc_data_3dopengl
   ,farc_data_files
   ,farc_data_game
   ,farc_data_filesavegame
   ,farc_data_init
   ,farc_data_messages
   ,farc_data_missionstasks
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_functions
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_survey_core
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_univ_func;

//===================================================END OF INIT============================

procedure FCMgCG_Core_Proceed;
{:Purpose: initialize the current game.
    Additions:
      -2013Mar24- *add: FCMsC_ReleaseList_Clear.
      -2010Sep19- *add: entities code.
      -2010Jun19- *rem: the french fix became useless and removed.
      -2010Jun15- *mod: use the new space locator.
      -2010Mar17- *fix: avoid surface panel display crash when the language is not in
                  english. It's a fast and dirty (but usable) hack since i haven't found
                  which string cause the trouble (dunno if it will do the same for a foreign
                  non french language).
      -2010Mar10- *add: free useless data.
      -2010Feb18- *add: FCMuiWin_TerrGfxColl_Init.
      -2010Feb02- *add: init surface hotspots.
      -2010Jan20- *add: FUG menu visibility.
      -2009Dec20- *add: satellite orbits.
      -2009Dec18- *add: satellite location for in orbit space units sub-routine.
      -2009Dec01- *disable new game menu for now.
      -2009Nov28- *restore the message queue.
      -2009Nov12- *initialize GGFtaskProcUnit.
                  *enable FCWM_MMenu_G_Save.
                  *create the threads.
      -2009Nov10- *add FCMspuF_Orbits_Process for set the orbits occupied by a space unit.
}
var
   Count2
   ,Count1
   ,CPoobj
   ,CPsat
   ,CPssys
   ,CPstar
   ,Max1
   ,Max2: integer;

   CPlang: string;
begin
   {.set some user's interface}
   FCWinMain.FCWM_MMenu_G_Cont.Enabled:=false;
   FCWinMain.FCWM_MMenu_G_New.Enabled:=false;
//   if FCWinMain.FCWM_MMenu_DebTools.Visible
//   then FCWinMain.FCWM_MMenu_DebTools.Visible:=false;
{:DEV NOTES: put the data loading in a proc and load it also for a new game setup (one time loading).}
FCMdF_DBProducts_Load;
   FCMdF_DBSPMitems_Load;
   FCMdF_DBFactions_Load;
   FCMdF_DBInfrastructures_Load;
   FCMdF_DBSpaceUnits_Load;
   FCMgfxC_Main_Init;
   {.data initialization}
   SetLength(FCDdmtTaskListToProcess,1);
   FCMdG_Entities_Clear;
   FCMdF_DBStarSystems_Load;

   Max1:=length( FCDduStarSystem ) - 1;
   Count1:=1;
   while Count1 <= Max1 do
   begin
      Max2:=3;//length( FCDduStarSystem[Count1].SS_stars ) - 1;
      Count2:=1;
      while Count2 <= Max2 do
      begin
         if FCDduStarSystem[Count1].SS_stars[Count2].S_token=''
         then break
         else FCMdF_DBStarOrbitalObjects_Load( FCDduStarSystem[Count1].SS_token, FCDduStarSystem[Count1].SS_stars[Count2].S_token );
         inc( Count2 );
      end;
      inc( Count1 );
   end;

   FCMuiM_Messages_Reset;
   {.load current game}
   FCMdFSG_Game_Load;

   {.prevent a file error}
   if FCVdgPlayer.P_viewStarSystem='' then
   begin
      DeleteFile(FCVdiPathConfigDir+'SavedGames\'+FCVdgPlayer.P_gameName+'.xml');
      FCVdgPlayer.P_gameName:='';
      FCMdF_ConfigurationFile_Save(false);
   end
   else begin
      {.entities initialization loop}
      Count1:=0;
      while Count1<=FCCdiFactionsMax do
      begin
         {.set space units in orbits, if there's any}
         Max2:=length(FCDdgEntities[Count1].E_spaceUnits)-1;
         if Max2>0 then
         begin
            Count2:=1;
            while Count2<=Max2 do
            begin
               if FCDdgEntities[Count1].E_spaceUnits[Count2].SU_status=susInOrbit then
               begin
                  CPssys:=FCFuF_StelObj_GetDbIdx(
                     ufsoSsys
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationStarSystem
                     ,0
                     ,0
                     ,0
                     );
                  CPstar:=FCFuF_StelObj_GetDbIdx(
                     ufsoStar
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationStar
                     ,CPssys
                     ,0
                     ,0
                     );
                  CPoobj:=FCFuF_StelObj_GetDbIdx(
                     ufsoOObj
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationOrbitalObject
                     ,CPssys
                     ,CPstar
                     ,0
                     );
                  if FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationSatellite<>''
                  then CPsat:=FCFuF_StelObj_GetDbIdx(
                     ufsoSat
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationSatellite
                     ,CPssys
                     ,CPstar
                     ,CPoobj
                     )
                  else CPsat:=0;
                  FCMspuF_Orbits_Process(
                     spufoioAddOrbit
                     ,CPssys
                     ,CPstar
                     ,CPoobj
                     ,CPsat
                     ,0
                     ,Count2
                     ,false
                     );
               end; //==END== if FCentities[CPeCnt].E_spU[CPcount].SUO_status=susInOrbit ==//
               inc(Count2);
            end; //==END== while CPcount<=CPttl do ==//
         end; {.if CPttl>0 then}
         inc(Count1);
      end; //==END== while CPeCnt<=FCCfacMax do ==//
      {.free useless data}
      Count2:=1;
      while Count2<=1 do
      begin
         setlength(
            FCDdgFactions[Count2].F_colonizationModes
            ,0
            );
         setlength(FCDdgFactions[Count2].F_startingLocations,0);
         inc(Count2);
      end;
      {.set the game user's interface}
      FCVdi3DViewToInitialize:=true;
      {.restore the message queue}
      Max2:=length(FCVmsgStoTtl)-1;
      if Max2>0 then
      begin
         FCVmsgCount:=Max2;
         Count2:=1;
         while Count2<=Max2 do
         begin
            {.update message headers list}
            FCWinMain.FCWM_MsgeBox_List.Items.Add('<b>'+IntToStr(Count2)+'</b> - '+FCVmsgStoTtl[Count2]);
            if Count2=Max2 then
            begin
               FCWinMain.FCWM_MsgeBox_List.ItemIndex:=FCWinMain.FCWM_MsgeBox_List.Items.Count-1;
               FCMuiM_MessageDesc_Upd;
               FCWinMain.FCWM_MsgeBox.Show;
            end;
            inc(Count2);
         end; {.while CPcount<=CPttl}
      end; {.if CPttl>0}
      FCVdi3DViewToInitialize:=true;
      {.3d initialization}
      try
         FCWinMain.WM_MainViewGroup.Show;
         FCVdi3DViewRunning:=true;
         FCMoglInit_Initialize;
      finally
         {DEV NOTE: OF COURSE OGL INIT IS ONLY IN CASE OF A NEW AND FIRST GAME SINCE FARC IS
         LAUNCHED.}
         CPssys:=FCFuF_StelObj_GetDbIdx(
            ufsoSsys
            ,FCVdgPlayer.P_viewStarSystem
            ,0
            ,0
            ,0
            );
         CPstar:=FCFuF_StelObj_GetDbIdx(
            ufsoStar
            ,FCVdgPlayer.P_viewStar
            ,CPssys
            ,0
            ,0
            );
         CPoobj:=FCFuF_StelObj_GetDbIdx(
            ufsoOObj
            ,FCVdgPlayer.P_viewOrbitalObject
            ,CPssys
            ,CPstar
            ,0
            );
         if FCVdgPlayer.P_viewSatellite<>''
         then CPsat:=FCFuF_StelObj_GetDbIdx(
            ufsoSat
            ,FCVdgPlayer.P_viewSatellite
            ,CPssys
            ,CPstar
            ,CPoobj
            )
         else CPsat:=0;
         FCMovM_3DView_Initialize;
         FC3doglSelectedPlanetAsteroid:=CPoobj;
         {.3d view initialization}
         FCMovM_3DView_Update(
            FCVdgPlayer.P_viewStarSystem,
            FCVdgPlayer.P_viewStar
            );
         if CPsat>0
         then FC3doglSelectedSatellite:=FCFoglF_Satellite_SearchObject(CPoobj, CPsat)
         else if (CPsat=0)
            and (FC3doglMainViewTotalSatellites>0)
         then FC3doglSelectedSatellite:=1;
      end; //==END== 3d initialization try..finally ==//
      FCMuiSP_SurfaceEcosphere_Set(0,0,0, 0, true);
      FCWinMain.caption:=FCWinMain.caption+'   ['+FCFdTFiles_UIStr_Get(uistrUI,'comCurGame')+FCVdgPlayer.P_gameName+']';
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutCPS);
   end; //==END== else of if FCRplayer.Play_starSysLoc='' ==//
end;

end.
