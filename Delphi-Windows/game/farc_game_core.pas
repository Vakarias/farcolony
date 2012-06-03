{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: game system - core unit

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

unit farc_game_core;

interface

type TFCEgcGameOverReason=(
   gfrCPScolonyBecameDissident
   ,gfrCPSendOfPhase
   ,gfrCPSentirePopulationDie
   );

///<summary>
///   the game over core feature, can be because of a failure or a success
///</summary>
///   <param name="GameOverReason">the reason of the game over</param>
procedure FCMgCore_GameOver_Process( const GameOverReason: TFCEgcGameOverReason );

implementation

uses
   farc_data_init
   ,farc_game_cps
   ,farc_main
   ,farc_win_debug;

//=============================================END OF INIT==================================

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
   FCGtimeFlow.Enabled:=false;
   FCWinMain.FCGLScadencer.Enabled:=false;
   case GameOverReason of
      gfrCPScolonyBecameDissident:;

      gfrCPSentirePopulationDie: if FCGdebug
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
      end;
   end; //==END== case GameOverReason of ==//
end;

end.
