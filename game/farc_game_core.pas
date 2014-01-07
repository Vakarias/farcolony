{======(C) Copyright Aug.2009-2014 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: game system - core unit

============================================================================================
********************************************************************************************
Copyright (c) 2009-2014, Jean-Francois Baconnet

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
unit farc_game_core;

interface

uses
   SysUtils;

type TFCEgcGameOverReason=(
   gfrCPScolonyBecameDissident
   ,gfrCPSendOfPhase
   ,gfrCPSentirePopulationDie
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   initialize all data injection, concentrated to this one place for new/continue game of game loading
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgC_Data_Injection;

///<summary>
///   the game over core feature, can be because of a failure or a success
///</summary>
///   <param name="GameOverReason">the reason of the game over</param>
procedure FCMgCore_GameOver_Process( const GameOverReason: TFCEgcGameOverReason );

///<summary>
///
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgC_Game_Initialize;

///<summary>
///   initialize and load a specified game file
///</summary>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <param name=""></param>
///   <returns></returns>
///   <remarks></remarks>
procedure FCMgC_LoadANewGame_Process( const GameDirectory, GameFilename: string );

implementation

uses
   farc_data_files
   ,farc_data_filesavegame
   ,farc_data_game
   ,farc_data_3dopengl
   ,farc_data_init
   ,farc_data_messages
   ,farc_data_missionstasks
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_game_cps
   ,farc_gfx_core
   ,farc_main
   ,farc_ogl_functions
   ,farc_ogl_init
   ,farc_ogl_ui
   ,farc_ogl_viewmain
   ,farc_spu_functions
   ,farc_ui_msges
   ,farc_ui_surfpanel
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug
   ,farc_win_savedgames;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMgC_Data_Injection;
{:Purpose: initialize all data injection, concentrated to this one place for new/continue game of game loading.
    Additions:
}
begin
   FCMdF_DBProducts_Load;
   FCMdF_DBSPMitems_Load;
   FCMdF_DBFactions_Load;
   FCMdF_DBInfrastructures_Load;
   FCMdF_DBSpaceUnits_Load;
   FCMdF_DBStarSystems_Load;
end;

procedure FCMgCore_GameOver_Process( const GameOverReason: TFCEgcGameOverReason );
{:Purpose: the game over core feature, can be because of a failure or a success.
    Additions:
      -2012May26- *add: gfrCPSendOfPhase.
}
begin
   {:DEV NOTES: for now there's only the case where there no more colony and no space unit available and able to settle one.}
//   FCWinMain.FCWM_3dMainGrp.Visible:=false;
   {:DEV NOTES: trigger failure message and display them.
                  for especially 1st phase, encourage the player to try again (depending the cause of failure).}
   FCVdiGameFlowTimer.Enabled:=false;
   FCWinMain.FCGLScadencer.Enabled:=false;
   case GameOverReason of
      gfrCPScolonyBecameDissident:;

      gfrCPSentirePopulationDie: if FCVdiDebugMode
      then FCWinDebug.AdvMemo1.Lines.Add('all population die of dehydration, enjoy :)');

      gfrCPSendOfPhase:
      begin
         if Assigned( FCcps )
         {:DEV NOTES: will be replaced in the future when post 1st alpha features will begin to implemented.}
         then FCWinMain.Close;
//         then begin
//         {.free cps related ui}
//         FCVwMcpsPstore:=false;
//         FCcps.CPSobjP_List.Free;
//         FCcps.CPSobjPanel.Free;
         {:DEV NOTES: *The Policies (including unique ones) must be adjusted by testing their requirements,
         if the requirement fail, the policy is retired (w/o any cohesion penalty). Memes are also adjusted according w/ proper memes rules.
         All without waiting a SPM phase. Unique policies (political system, economic system, healthcare system and religious system) must be changed if the requirement doesn't fit,
         since a system must be set the SPM gives the player's the possible choices (update policies list only with corresponding systems, one after the others).
         A natural short government destabilization occurs, w/o any fix than time
            *of course all SPM requirements are assured by the player's faction
            *and after the player is free to set policies he/she wants, since his/her faction is fully independent.}
      end;
   end; //==END== case GameOverReason of ==//
end;

procedure FCMgC_Game_Initialize;
{:Purpose: .
    Additions:
}
begin
   FCWinMain.MMGameSection_Continue.Enabled:=false;
   FCWinMain.MMDebugSection.Visible:=FCVdiDebugMode;
//   FCMgfxC_Main_Init;
   SetLength(FCDdmtTaskListToProcess, 1);
   SetLength(FCDdmtTaskListInProcess, 1);
   FCMdG_Entities_Clear;
//   FCMdF_DBStarSystems_Load;
end;

procedure FCMgC_LoadANewGame_Process( const GameDirectory, GameFilename: string );
{:Purpose: initialize and load a specified game file.
    Additions:
}
   type
   UIHTMLcharset = set of char;

const
   UIHTMLcharEndHref: UIHTMLcharset=['-'];

   UIHTMLcharEndHref1: UIHTMLcharset=['.'];

   var
//      dirName

      Count
      ,Count1
      ,Count2
      ,Max1
      ,Max2
      ,stringIndex: integer;

      resultString
      ,workingString: string;

      mustDoAReset: boolean;

      UniverseLocation: TFCRufStelObj;
begin
   mustDoAReset:=false;
   FCWinSavedGames.Close;
   if FCVdi3DViewRunning then
   begin
      FCVdi3DViewRunning:=false;
      mustDoAReset:=true;
   end
   else begin
      FCMgC_Data_Injection;
      FCMgfxC_Main_Init;
   end;
   FCMgC_Game_Initialize;
   FCVdgPlayer.P_gameName:=GameDirectory;
   workingString:=GameFilename;
   stringIndex:=5;
   Count:=1;
   while Count <= 6 do
   begin
      resultString:=workingString;
      delete( resultString, stringIndex, length(resultString) );
      case Count of
         1: FCVdgPlayer.P_currentTimeYear:=strtoint( resultString );

         2: FCVdgPlayer.P_currentTimeMonth:=StrToInt( resultString );

         3: FCVdgPlayer.P_currentTimeDay:=StrToInt( resultString );

         4: FCVdgPlayer.P_currentTimeHour:=StrToInt( resultString );

         5: FCVdgPlayer.P_currentTimeMinut:=StrToInt( resultString );

         6: FCVdgPlayer.P_currentTimeTick:=StrToInt( resultString );
      end;
      delete(workingString, 1, stringIndex);
      stringIndex:=1;
      if Count < 5
      then While ( stringIndex<=length(workingString)) and not (workingString[stringIndex] in UIHTMLcharEndHref ) do inc(stringIndex)
      else While ( stringIndex<=length(workingString)) and not (workingString[stringIndex] in UIHTMLcharEndHref1 ) do inc(stringIndex);
      inc( Count );
   end;
   FCMdF_ConfigurationFile_Save( true );
   {.data initialization}
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
      while Count1 <= FCCdiFactionsMax do
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
                  UniverseLocation:=FCFuF_StelObj_GetFullRow(
                     FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationStarSystem
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationStar
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationOrbitalObject
                     ,FCDdgEntities[Count1].E_spaceUnits[Count2].SU_locationSatellite
                     );
                  FCMspuF_Orbits_Process(
                     spufoioAddOrbit
                     ,UniverseLocation[1]
                     ,UniverseLocation[2]
                     ,UniverseLocation[3]
                     ,UniverseLocation[4]
                     ,Count1
                     ,Count2
                     ,false
                     );
               end; //==END== FCDdgEntities[Count1].E_spaceUnits[Count2].SU_status=susInOrbit ==//
               inc(Count2);
            end; //==END== while CPcount<=CPttl do ==//
         end; {.if CPttl>0 then}
         inc(Count1);
      end; //==END== while CPeCnt<=FCCfacMax do ==//
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
      try
         FCWinMain.WM_MainViewGroup.Show;
         if not mustDoAReset
         then FCMoglInit_Initialize;
         FCVdi3DViewRunning:=true;
      finally
         if mustDoAReset then
         begin
            FCMovM_3DView_Reset;
            FCMuiW_MainTitleBar_Init;
         end
         else FCMovM_3DView_Initialize;
         FC3doglSelectedPlanetAsteroid:=UniverseLocation[3];
         {.3d view initialization}
         FCMovM_3DView_Update(
            FCVdgPlayer.P_viewStarSystem,
            FCVdgPlayer.P_viewStar
            );
         if UniverseLocation[4] > 0
         then FC3doglSelectedSatellite:=FCFoglF_Satellite_SearchObject( UniverseLocation[3], UniverseLocation[4] )
         else if ( UniverseLocation[4] = 0 )
            and ( FC3doglMainViewTotalSatellites >0 )
         then FC3doglSelectedSatellite:=1;
      end; //==END== 3d initialization try..finally ==//
      FCMuiSP_SurfaceEcosphere_Set(0,0,0, 0, true);
      FCWinMain.caption:=FCWinMain.caption+'   ['+FCFdTFiles_UIStr_Get(uistrUI,'comCurGame')+FCVdgPlayer.P_gameName+']';
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutCPS);
   end; //==END== else of if FCRplayer.Play_starSysLoc='' ==//
end;

end.
