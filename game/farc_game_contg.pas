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
   ,farc_data_textfiles
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_univ_func;

//===================================================END OF INIT============================

procedure FCMgCG_Core_Proceed;
{:Purpose: initialize the current game.
    Additions:
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
   CPcount
   ,CPeCnt
   ,CPoobj
   ,CPsat
   ,CPssys
   ,CPstar
   ,CPttl: integer;

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
   FCMgfxC_TerrainsCollection_Init;
   if not Assigned(FCRdiSettlementPictures[1])
   then FCMgfxC_Settlements_Init;
   {.data initialization}
   SetLength(FCGtskLstToProc,1);
   FCMdF_DBStarSystems_Load;

   FCMuiM_Messages_Reset;
   {.load current game}
   FCMdFSG_Game_Load;

   {.prevent a file error}
   if FCRplayer.P_starSysLoc=''
   then
   begin
      DeleteFile(FCVdiPathConfigDir+'SavedGames\'+FCRplayer.P_gameName+'.xml');
      FCRplayer.P_gameName:='';
      FCMdF_ConfigurationFile_Save(false);
   end
   else
   begin
      {.entities initialization loop}
      CPeCnt:=0;
      while CPeCnt<=FCCdiFactionsMax do
      begin
         {.set space units in orbits, if there's any}
         CPttl:=length(FCentities[CPeCnt].E_spU)-1;
         if CPttl>0
         then
         begin
            CPcount:=1;
            while CPcount<=CPttl do
            begin
               if FCentities[CPeCnt].E_spU[CPcount].SUO_status=susInOrbit
               then
               begin
                  CPssys:=FCFuF_StelObj_GetDbIdx(
                     ufsoSsys
                     ,FCentities[CPeCnt].E_spU[CPcount].SUO_starSysLoc
                     ,0
                     ,0
                     ,0
                     );
                  CPstar:=FCFuF_StelObj_GetDbIdx(
                     ufsoStar
                     ,FCentities[CPeCnt].E_spU[CPcount].SUO_starLoc
                     ,CPssys
                     ,0
                     ,0
                     );
                  CPoobj:=FCFuF_StelObj_GetDbIdx(
                     ufsoOObj
                     ,FCentities[CPeCnt].E_spU[CPcount].SUO_oobjLoc
                     ,CPssys
                     ,CPstar
                     ,0
                     );
                  if FCentities[CPeCnt].E_spU[CPcount].SUO_satLoc<>''
                  then CPsat:=FCFuF_StelObj_GetDbIdx(
                     ufsoSat
                     ,FCentities[CPeCnt].E_spU[CPcount].SUO_satLoc
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
                     ,CPcount
                     ,false
                     );
               end; //==END== if FCentities[CPeCnt].E_spU[CPcount].SUO_status=susInOrbit ==//
               inc(CPcount);
            end; //==END== while CPcount<=CPttl do ==//
         end; {.if CPttl>0 then}
         inc(CPeCnt);
      end; //==END== while CPeCnt<=FCCfacMax do ==//
      {.free useless data}
      CPcount:=1;
      while CPcount<=1 do
      begin
         setlength(
            FCDBfactions[CPcount].F_facCmode
            ,0
            );
         setlength(FCDBfactions[CPcount].F_facStartLocList,0);
         inc(CPcount);
      end;
      {.set the game user's interface}
      FCWinMain.FCGLSRootMain.Tag:=1;
      {.restore the message queue}
      CPttl:=length(FCVmsgStoTtl)-1;
      if CPttl>0
      then
      begin
         FCVmsgCount:=CPttl;
         CPcount:=1;
         while CPcount<=CPttl do
         begin
            {.update message headers list}
            FCWinMain.FCWM_MsgeBox_List.Items.Add('<b>'+IntToStr(CPcount)+'</b> - '+FCVmsgStoTtl[CPcount]);
            if CPcount=CPttl
            then
            begin
               FCWinMain.FCWM_MsgeBox_List.ItemIndex:=FCWinMain.FCWM_MsgeBox_List.Items.Count-1;
               FCMuiM_MessageDesc_Upd;
               FCWinMain.FCWM_MsgeBox.Show;
            end;
            inc(CPcount);
         end; {.while CPcount<=CPttl}
      end; {.if CPttl>0}
      {.3d initialization}
      try
         FCWinMain.FCWM_3dMainGrp.Show;
         FCMoglInit_Initialize;
      finally
         {DEV NOTE: OF COURSE OGL INIT IS ONLY IN CASE OF A NEW AND FIRST GAME SINCE FARC IS
         LAUNCHED.}
         CPssys:=FCFuF_StelObj_GetDbIdx(
            ufsoSsys
            ,FCRplayer.P_starSysLoc
            ,0
            ,0
            ,0
            );
         CPstar:=FCFuF_StelObj_GetDbIdx(
            ufsoStar
            ,FCRplayer.P_starLoc
            ,CPssys
            ,0
            ,0
            );
         CPoobj:=FCFuF_StelObj_GetDbIdx(
            ufsoOObj
            ,FCRplayer.P_oObjLoc
            ,CPssys
            ,CPstar
            ,0
            );
         if FCRplayer.P_satLoc<>''
         then CPsat:=FCFuF_StelObj_GetDbIdx(
            ufsoSat
            ,FCRplayer.P_satLoc
            ,CPssys
            ,CPstar
            ,CPoobj
            )
         else CPsat:=0;
         FC3doglSelectedPlanetAsteroid:=CPoobj;
         {.3d view initialization}
         FCMoglVM_MView_Upd(
            FCRplayer.P_starSysLoc,
            FCRplayer.P_starLoc,
            false,
            true
            );
         if CPsat>0
         then FC3doglSelectedSatellite:=FCFoglVM_SatObj_Search(CPoobj, CPsat)
         else if (CPsat=0)
            and (FC3doglTotalSatellites>0)
         then FC3doglSelectedSatellite:=1;
      end; //==END== 3d initialization try..finally ==//
      FCMuiSP_SurfaceEcosphere_Set(0, 0, true);
      FCWinMain.caption:=FCWinMain.caption+'   ['+FCFdTFiles_UIStr_Get(uistrUI,'comCurGame')+FCRplayer.P_gameName+']';
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutCPS);
   end; //==END== else of if FCRplayer.Play_starSysLoc='' ==//
end;

end.
