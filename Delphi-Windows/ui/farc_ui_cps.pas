{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS interface core

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
unit farc_ui_cps;

interface

uses
   SysUtils

   ,farc_game_cpsobjectives;

type TFCEuicpsReportStage=(
   rsEndOfPhaseReportWithEnd
   );

///<summary>
///   format a string which contain the specified CPS objectives, its score, and additional data if needed
///</summary>
///   <param name="ObjectiveIndex">objective index #</param>
///   <returns>the formatted objective w/ score and data</returns>
function FCFuiCPS_Objective_GetFormat( const ObjectiveIndex: integer ): string;

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   set and display the end of phase report and settings at different stage
///</summary>
///   <param name="DisplayStage">specify at which stage the panel must be opened</param>
///   <param name="ScoreEcon">final economic score</param>
///   <param name="ScoreSoc">final social score</param>
///   <param name="ScoreSpMil">final space & military score</param>
procedure FCMuiCPS_EndPhaseReport_Show(
   const DisplayStage: TFCEuicpsReportStage;
   const ScoreEcon
         ,ScoreSoc
         ,ScoreSpMil: integer
   );

implementation

uses
   farc_data_game
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_game_cps
   ,farc_game_entitiesfactions
   ,farc_game_prod
   ,farc_main;

//===================================================END OF INIT============================

function FCFuiCPS_Objective_GetFormat( const ObjectiveIndex: integer ): string;
{:Purpose: format a string which contain the specified CPS objectives, its score, and additional data if needed.
    Additions:
      -2012Mar25- *add: otEcoEnEff + otEcoIndustrialForce + otEcoLowCr completion.
}
   var
      ResultStr1
      ,ResultStr2: string;
begin
   Result:='';
   ResultStr1:='';
   ResultStr2:='';
   case FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_type of
      otEcoEnEff:
      begin
         ResultStr1:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoEnEff');
         ResultStr2:=' <br>';
         FCcpsObjectivesLines:=FCcpsObjectivesLines+1;
      end;

      otEcoIndustrialForce:
      begin
         ResultStr1:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoIndustrialForce');
         ResultStr2:='Product to Produce: '+FCFdTFiles_UIStr_Get( uistrUI, FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_ifProduct )+'<br>'
            +'Threshold to Reach: '+FCFgP_StringFromUnit_Get(
               FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_ifProduct
               ,FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_ifThreshold
               ,''
               ,false
               ,false
               )+' /hr <br><br> ';
         FCcpsObjectivesLines:=FCcpsObjectivesLines+3;
      end;

      otEcoLowCr:
      begin
         ResultStr1:=FCCFdHead+FCFdTFiles_UIStr_Get(uistrUI, 'cpsVOotEcoLowCr');
         ResultStr2:=' <br>';
         FCcpsObjectivesLines:=FCcpsObjectivesLines+1;
      end;

      otEcoSustCol:;

//      otSocSecPop:;
   end;
   Result:=ResultStr1+'<ind x="250"> ['+inttostr(FCcps.CPSviabObj[ ObjectiveIndex ].CPSO_score)+'%]'+FCCFdHeadEnd+ResultStr2;

end;

//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiCPS_EndPhaseReport_Show(
   const DisplayStage: TFCEuicpsReportStage;
   const ScoreEcon
         ,ScoreSoc
         ,ScoreSpMil: integer
   );
{:Purpose: set and display the end of phase report and settings at different stage.
    Additions:
}
begin
//   case DisplayStage of
//      rsEndOfPhaseReportWithEnd:
//      begin
//   FCWinMain.FCWM_MainMenu.Items.Enabled:=false;
//   FCWinMain.FCWM_MainMenu.Items.Visible:=false;
   FCWinMain.FCWM_MMenu_Game.Enabled:=false;
   FCWinMain.FCWM_MMenu_Options.Enabled:=false;
   FCWinMain.FCWM_MMenu_Help.Enabled:=false;
   FCWinMain.FCWM_MMenu_DebTools.Enabled:=false;
   if FCWinMain.FCWM_ColDPanel.Visible
   then FCWinMain.FCWM_ColDPanel.Hide;

   if FCWinMain.FCWM_UMI.Visible
   then FCWinMain.FCWM_UMI.Hide;

   if FCWinMain.FCWM_DockLstPanel.Visible
   then FCWinMain.FCWM_DockLstPanel.Hide;
   if FCWinMain.FCWM_SurfPanel.Visible
   then FCWinMain.FCWM_SurfPanel.Hide;

   FCWinMain.FCGLSmainView.Enabled:=false;

   FCWinMain.FCWM_CPSreportSet.Left:=((FCWinMain.FCWM_3dMainGrp.Left+FCWinMain.FCWM_3dMainGrp.Width) shr 1)-(FCWinMain.FCWM_CPSreportSet.Width shr 1);
   FCWinMain.FCWM_CPSreportSet.Top:=((FCWinMain.FCWM_3dMainGrp.Top+FCWinMain.FCWM_3dMainGrp.Height) shr 1)-(FCWinMain.FCWM_CPSreportSet.Height shr 1);
   FCWinMain.FCWM_CPSRSbuttonConfirm.Left:=8;
   FCWinMain.FCWM_CPSRSbuttonConfirm.Top:=FCWinMain.FCWM_CPSreportSet.Height-FCWinMain.FCWM_CPSRSbuttonConfirm.Height-8;
   FCWinMain.FCWM_CPSRSIGscores.HTMLText.Clear;
   FCWinMain.FCWM_CPSRSIGscores.HTMLText.Add( '<p align="center"><font size="14">'+FCFdTFiles_UIStr_Get( uistrUI, 'CPSrepScoreTitle' )+'</p><br><br><p align="right">' );
   FCWinMain.FCWM_CPSRSIGscores.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'cpsSLecon' )+'  [ '+IntToStr(ScoreEcon)+'% ]<br>' );
   FCWinMain.FCWM_CPSRSIGscores.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'cpsSLsoc' )+'  [ '+IntToStr(ScoreSoc)+'% ]<br>' );
   FCWinMain.FCWM_CPSRSIGscores.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'cpsSLmil' )+'  [ '+IntToStr(ScoreSpMil)+'% ]' );
   FCWinMain.FCWM_CPSRSinfogroup.Caption:=FCFdTFiles_UIStr_Get( uistrUI, 'CPSreport' );
   FCWinMain.FCWM_CPSRSIGreport.HTMLText.Clear;
   if ( FCRplayer.P_ecoStat=fs0NViable )
      xor ( FCRplayer.P_socStat=fs0NViable )
      xor ( FCRplayer.P_milStat=fs0NViable )
   then FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add( 'Your colony didnt achieved to be viable on long term')
   else if ( FCRplayer.P_ecoStat=fs3Indep )
      and ( FCRplayer.P_socStat=fs3Indep )
      and ( FCRplayer.P_milStat=fs3Indep )
   then FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
      'Congratulation ! Your colony achieved to be fully independent !'
      )
   else begin
      FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
         'Congratulation ! Your colony is viable on long term, but not completely independent:<br>'
         );
      case FCRplayer.P_ecoStat of
         fs1StabFDep: FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
            FCCFidxL6+'- Economically, your colony will stay dependent'//, that mean that you cant '
            );

         fs2DepVar: FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
            FCCFidxL6+'- Economically, your colony will stay semi-dependent'
            );
      end;
      FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add('<br>');
      case FCRplayer.P_socStat of
         fs1StabFDep: FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
            FCCFidxL6+'- Socially, your colony will stay dependent'//, that mean that you cant '
            );

         fs2DepVar: FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
            FCCFidxL6+'- Socially, your colony will stay semi-dependent'
            );
      end;
      FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add('<br>');
      case FCRplayer.P_milStat of
         fs1StabFDep: FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
            FCCFidxL6+'- For the Space and the Army, your colony will stay dependent'//, that mean that you cant '
            );

         fs2DepVar: FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add(
            FCCFidxL6+'- For the Space and the Army, your colony will stay semi-dependent'
            );
      end;
   end;
   FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add( '<br><br>There'+chr(39)+'s nothing more beyond this phase, for now, until the development goes further.' );
   FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add( '<br>In the future, according to the status of the colony, you'+chr(39)+'ll have to set the political, economical, healthcare and spiritual systems.<br><br>' );
   FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add('<b>Sorry for the typos in the text, its a quick & dirty one and its not localized yet.</b><br><br>');
   FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add('I hope you liked it, even if this project is far to be feature complete and obviously is still in construction.<br>Future patches will consolidate this Alpha 1.');
   FCWinMain.FCWM_CPSRSIGreport.HTMLText.Add('<br><br><font size="12"><b>Thank you for your interest. :)');


   FCWinMain.FCWM_CPSreportSet.Show;
//      end;
end;

end.
