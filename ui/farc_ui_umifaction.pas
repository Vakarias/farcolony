{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Unified Management Interface (UMI) - faction unit

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
unit farc_ui_umifaction;

interface

uses
   ComCtrls
   ,SysUtils;

type TFCEuiUMIFpoliticalActions=(
   paPoliticalStructureAll
   ,paPoliticalStructureGovernment
   ,paPoliticalStructureBureaucracy
   ,paPoliticalStructureCorruption
   ,paPoliticalStructureEconomy
   ,paPoliticalStructureHealthcare
   ,paPoliticalStructureSpiritual
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   update the display regarding the selection in the available policies list
///</summary>
procedure FCMumi_AvailPolList_UpdClick;

///<summary>
///   update the colonies list
///</summary>
///   <param name="Colony">entity[0]'s colony index, if = 0, the complete list is updated, if>0, only a particular colony is updated</param>
procedure FCMuiUMIF_Colonies_Update( const Colony: integer);

///<summary>
///   update all the dependence status components
///</summary>
procedure FCMuiUMIF_DependenceStatus_UpdateAll;

///<summary>
///   update the faction's economic dependency circular progress and its associated label
///</summary>
procedure FCMuiUMIF_DependenceEconomic_Update;

///<summary>
///   update the faction's military dependency circular progress and its associated label
///</summary>
procedure FCMuiUMIF_DependenceMilitary_Update;

///<summary>
///   update the faction's social dependency circular progress and its associated label
///</summary>
procedure FCMuiUMIF_DependenceSocial_Update;

///<summary>
///   recalculate and update the size of all the Faction tab components that require to be resized
///</summary>
procedure FCMuiUMIF_Components_SetSize;

///<summary>
///   update the faction's level circular progress and its associated label
///</summary>
procedure FCMuiUMIF_FactionLevel_Update;

///<summary>
///   update the acceptance probability and enforcement subsection
///</summary>
procedure FCMuiUMIF_PolicyEnforcement_Update;

///<summary>
///   update the policy enforcement sub-tab
///</summary>
procedure FCMuiUMIF_PolicyEnforcement_UpdateAll;

///<summary>
///   update the political structure
///</summary>
///   <param name="UpdateTarget">determine which section to update</param>
procedure FCMuiUMIF_PoliticalStructure_Update( const UpdateTarget: TFCEuiUMIFpoliticalActions );

///<summary>
///   update the trees of the SPM settings
///</summary>
procedure FCMuiUMIF_SPMSettings_Update;

//===========================END FUNCTIONS SECTION==========================================

implementation

uses
   farc_data_textfiles
   ,farc_data_game
   ,farc_data_html
   ,farc_data_spm
   ,farc_game_colony
   ,farc_game_spm
   ,farc_game_spmdata
   ,farc_main
   ,farc_ui_html;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

var
   //==========faction tab variables========================================================
   StatusEconBaseSize: integer;
   StatusSocBaseSize: integer;
   StatusMilBaseSize:integer;

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMumi_AvailPolList_UpdClick;
{:Purpose: update the display regarding the selection in the available policies list.
    Additions:
      -2012Aug27- *code audit:
                     (-)var formatting + refactoring     (-)if..then reformatting   (-)function/procedure refactoring
                     (-)parameters refactoring           (-) ()reformatting         (o)code optimizations
                     (-)float local variables=> extended (-)case..of reformatting   (-)local methods
                     (-)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (-)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (-)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
}
var
   TokenRes: string;

   RetVal: boolean;
begin
   if (FCWinMain.FCWM_UMI.Visible)
      and (not FCWinMain.FCWM_UMI.Collaps)
      and (FCWinMain.FCWM_UMI_TabSh.ActivePage=FCWinMain.FCWM_UMI_TabShFac)
      and (FCWinMain.FCWM_UMIFac_TabSh.ActivePage=FCWinMain.FCWM_UMIFac_TabShSPMpol)
   then
   begin
      RetVal:=false;
      TokenRes:=FCFuiHTML_AnchorInAhrefFromQuestionMarkItem_Extract( FCWinMain.FCWM_UMIFSh_AFlist.Items.ValueFromIndex[FCWinMain.FCWM_UMIFSh_AFlist.ItemIndex] );
      RetVal:=FCFgSPM_PolicyEnf_Preproc(0, TokenRes);
//      FCMumi_Faction_Upd(uiwSPMpolEnfRAP, RetVal);
   end;
end;

procedure FCMuiUMIF_Colonies_Update( const Colony: integer);
{:Purpose: update the colonies list.
    Additions:
}
   var
      Count
      , Max: integer;

      Str: String;
begin
   if Colony=0 then
   begin
      Max:=length( FCDdgEntities[0].E_colonies )-1;
      FCWinMain.FCWM_UMIFac_Colonies.Items.Clear;
      if Max=0
      then FCWinMain.FCWM_UMIFac_Colonies.Items.Add( nil, FCFdTFiles_UIStr_Get( uistrUI, 'UMInocol' ) )
      else if Max>0
      then
      begin
         Count:=1;
         while Count<=Max do
         begin
            if FCDdgEntities[0].E_colonies[Count].C_locationSatellite<>''
            then Str:=FCDdgEntities[0].E_colonies[Count].C_locationSatellite
            else Str:=FCDdgEntities[0].E_colonies[Count].C_locationOrbitalObject;
            FCWinMain.FCWM_UMIFac_Colonies.Items.Add(
               nil, FCDdgEntities[0].E_colonies[Count].C_name
               +';<p align="center">'+FCFdTFiles_UIStr_Get(dtfscPrprName, Str)+'  -(<b>'+FCFdTFiles_UIStr_Get(dtfscPrprName, FCDdgEntities[0].E_colonies[Count].C_locationStar)+'</b>)-'
               +';<p align="center">'+FCFdTFiles_UIStr_Get(uistrUI, FCFgC_HQ_GetStr(0,Count))
               +';<p align="center">'+IntToStr(FCDdgEntities[0].E_colonies[Count].C_cohesion)+' %'
               );
            inc(Count);
         end;
      end;
   end
   else if Colony>0 then
   begin
   end;
end;

procedure FCMuiUMIF_Components_SetSize;
{:Purpose: recalculate and update the size of all the Faction tab components that require to be resized.
    Additions:
      -2012Sep08- *add: policies enforcement interface components.
                  *code audit:
                     (_)var formatting + refactoring     (_)if..then reformatting   (_)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (_)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (_)if the procedure reset the same record's data or external data put:
                     ///   <remarks>the procedure/function reset the /data/</remarks>
}
   var
      BaseCalculation: integer;
      SPMtreesWidth: integer;
      UMIUFwd:integer;
begin
   FCWinMain.FCWM_UMI_FacData.Height:=( FCWinMain.FCWM_UMI_FacDatG.Height shr 1 )-8;
   BaseCalculation:=( FCWinMain.FCWM_UMI.Width shr 5 )*17;
   StatusEconBaseSize:=( BaseCalculation shr 1 )+16;
   StatusSocBaseSize:=BaseCalculation;
   StatusMilBaseSize:=StatusSocBaseSize+( StatusSocBaseSize-StatusEconBaseSize );
   FCWinMain.FCWM_UMI_FacLvl.Left:=16;
   FCWinMain.FCWM_UMI_FDLvlVal.Left:=FCWinMain.FCWM_UMI_FacLvl.Left+( FCWinMain.FCWM_UMI_FacLvl.Width shr 1)-( FCWinMain.FCWM_UMI_FDLvlVal.Width shr 1);
   FCWinMain.FCWM_UMI_FDLvlValDesc.Left:=FCWinMain.FCWM_UMI_FacLvl.Left+FCWinMain.FCWM_UMI_FacLvl.Width+4;
   FCWinMain.FCWM_UMI_FacEcon.Left:=StatusEconBaseSize;
   FCWinMain.FCWM_UMI_FDEconVal.Left:=FCWinMain.FCWM_UMI_FacEcon.Left+( FCWinMain.FCWM_UMI_FacEcon.Width shr 1)-( FCWinMain.FCWM_UMI_FDEconVal.Width shr 1);
   FCWinMain.FCWM_UMI_FDEconValDesc.Left:=FCWinMain.FCWM_UMI_FacEcon.Left+FCWinMain.FCWM_UMI_FacEcon.Width+4;
   FCWinMain.FCWM_UMI_FacSoc.Left:=StatusSocBaseSize;
   FCWinMain.FCWM_UMI_FDSocVal.Left:=FCWinMain.FCWM_UMI_FacSoc.Left+( FCWinMain.FCWM_UMI_FacSoc.Width shr 1)-( FCWinMain.FCWM_UMI_FDSocVal.Width shr 1);
   FCWinMain.FCWM_UMI_FDSocValDesc.Left:=FCWinMain.FCWM_UMI_FacSoc.Left+FCWinMain.FCWM_UMI_FacSoc.Width+4;
   FCWinMain.FCWM_UMI_FacMil.Left:=StatusMilBaseSize;
   FCWinMain.FCWM_UMI_FDMilVal.Left:=FCWinMain.FCWM_UMI_FacMil.Left+( FCWinMain.FCWM_UMI_FacMil.Width shr 1)-( FCWinMain.FCWM_UMI_FDMilVal.Width shr 1);
   FCWinMain.FCWM_UMI_FDMilValDesc.Left:=FCWinMain.FCWM_UMI_FacMil.Left+FCWinMain.FCWM_UMI_FacMil.Width+4;
   FCWinMain.FCWM_UMI_FDLvlValDesc.Width:=FCWinMain.FCWM_UMI_FacEcon.Left-FCWinMain.FCWM_UMI_FDLvlValDesc.Left;
   FCWinMain.FCWM_UMI_FDEconValDesc.Width:=FCWinMain.FCWM_UMI_FacSoc.Left-FCWinMain.FCWM_UMI_FDEconValDesc.Left;
   FCWinMain.FCWM_UMI_FDSocValDesc.Width:=FCWinMain.FCWM_UMI_FacMil.Left-FCWinMain.FCWM_UMI_FDSocValDesc.Left;
   FCWinMain.FCWM_UMI_FDMilValDesc.Width:=FCWinMain.FCWM_UMI_FacDatG.Width-FCWinMain.FCWM_UMI_FDMilValDesc.Left-8;
   UMIUFwd:=FCWinMain.FCWM_UMIFac_Colonies.Width shr 4;
   FCWinMain.FCWM_UMIFac_Colonies.Columns[0].Width:=UMIUFwd*4;
   FCWinMain.FCWM_UMIFac_Colonies.Columns[1].Width:=UMIUFwd*7;
   FCWinMain.FCWM_UMIFac_Colonies.Columns[2].Width:=UMIUFwd*3;
   FCWinMain.FCWM_UMIFac_Colonies.Columns[3].Width:=UMIUFwd*2;
   SPMtreesWidth:=FCWinMain.FCWM_UMIFSh_SPMlistTop.Width div 3;
   FCWinMain.FCWM_UMIFSh_SPMadmin.Width:=SPMtreesWidth;
   FCWinMain.FCWM_UMIFSh_SPMecon.Width:=SPMtreesWidth;
   FCWinMain.FCWM_UMIFSh_SPMmedca.Width:=SPMtreesWidth;
   FCWinMain.FCWM_UMIFSh_SPMsoc.Width:=SPMtreesWidth;
   FCWinMain.FCWM_UMIFSh_SPMspol.Width:=SPMtreesWidth;
   FCWinMain.FCWM_UMIFSh_SPMspi.Width:=SPMtreesWidth;
   FCWinMain.FCWM_UMIFSh_SPMlistBottom.Height:=FCWinMain.FCWM_UMIFac_TabSh.Height shr 1;
   FCWinMain.FCWM_UMISh_CEFenforce.Left:=(FCWinMain.FCWM_UMISh_CEnfF.Width shr 1)-(FCWinMain.FCWM_UMISh_CEFenforce.Width shr 1);
   FCWinMain.FCWM_UMISh_CEFretire.Top:=FCWinMain.FCWM_UMISh_CEnfF.Height-(FCWinMain.FCWM_UMISh_CEFretire.Height+2);
   FCWinMain.FCWM_UMISh_CEFcommit.Left:=FCWinMain.FCWM_UMISh_CEnfF.Width-FCWinMain.FCWM_UMISh_CEFcommit.Width-2;
   FCWinMain.FCWM_UMISh_CEFcommit.Top:=FCWinMain.FCWM_UMISh_CEFretire.Top;
end;

procedure FCMuiUMIF_DependenceEconomic_Update;
{:Purpose: update the faction's economic dependency circular progress and its associated label.
    Additions:
}
begin
   FCWinMain.FCWM_UMI_FacEcon.Position:=Integer( FCVdgPlayer.P_economicStatus );
   FCWinMain.FCWM_UMI_FDEconVal.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDEconVal.HTMLText.Add('<b>'+IntToStr( Integer( FCVdgPlayer.P_economicStatus ) )+'</b>');
   FCWinMain.FCWM_UMI_FDEconValDesc.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDEconValDesc.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, FCFgSPMD_Level_GetToken( FCVdgPlayer.P_economicStatus ) ) );
end;

procedure FCMuiUMIF_DependenceMilitary_Update;
{:Purpose: update the faction's military dependency circular progress and its associated label.
    Additions:
}
begin
   FCWinMain.FCWM_UMI_FacMil.Position:=Integer( FCVdgPlayer.P_militaryStatus );
   FCWinMain.FCWM_UMI_FDMilVal.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDMilVal.HTMLText.Add('<b>'+IntToStr( Integer( FCVdgPlayer.P_militaryStatus ) )+'</b>');
   FCWinMain.FCWM_UMI_FDMilValDesc.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDMilValDesc.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, FCFgSPMD_Level_GetToken( FCVdgPlayer.P_militaryStatus ) ) );
end;

procedure FCMuiUMIF_DependenceSocial_Update;
{:Purpose: update the faction's social dependency circular progress and its associated label.
    Additions:
}
begin
   FCWinMain.FCWM_UMI_FacSoc.Position:=Integer( FCVdgPlayer.P_socialStatus );
   FCWinMain.FCWM_UMI_FDSocVal.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDSocVal.HTMLText.Add('<b>'+IntToStr( Integer( FCVdgPlayer.P_socialStatus ) )+'</b>');
   FCWinMain.FCWM_UMI_FDSocValDesc.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDSocValDesc.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, FCFgSPMD_Level_GetToken( FCVdgPlayer.P_socialStatus ) ) );
end;

procedure FCMuiUMIF_DependenceStatus_UpdateAll;
{:Purpose: update all the dependence status components.
    Additions:
}
begin
   FCWinMain.FCWM_UMI_FacData.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
      FCCFdHeadC
      +'<ind x="'+IntToStr(StatusSocBaseSize-( ( StatusSocBaseSize-StatusEconBaseSize ) shr 1 ) )+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'facstat')
      +FCCFdHeadEnd
      );
   {.header, idx=1}
   FCWinMain.FCWM_UMI_FacData.HTMLText.Add(
      FCCFdHeadC
      +'<ind x="'+IntToStr(FCWinMain.FCWM_UMI_FacLvl.Left)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'faclvl')
      +'<ind x="'+IntToStr(StatusEconBaseSize)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLecon')
      +'<ind x="'+IntToStr(StatusSocBaseSize)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLsoc')
      +'<ind x="'+IntToStr(StatusMilBaseSize)+'">'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsSLmil')
      +FCCFdHeadEnd
      );
   FCMuiUMIF_FactionLevel_Update;
   FCMuiUMIF_DependenceEconomic_Update;
   FCMuiUMIF_DependenceSocial_Update;
   FCMuiUMIF_DependenceMilitary_Update;
end;

procedure FCMuiUMIF_FactionLevel_Update;
{:Purpose: update the faction's level circular progress and its associated label.
    Additions:
}
   var
      LevelString: string;
begin
   LevelString:='';
   LevelString:=IntToStr( FCDdgEntities[0].E_factionLevel );
   FCWinMain.FCWM_UMI_FacLvl.Position:=FCDdgEntities[0].E_factionLevel;
   FCWinMain.FCWM_UMI_FDLvlVal.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDLvlVal.HTMLText.Add('<b>'+LevelString+'</b>');
   FCWinMain.FCWM_UMI_FDLvlValDesc.HTMLText.Clear;
   FCWinMain.FCWM_UMI_FDLvlValDesc.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI,'faclvl'+LevelString ) );
end;

procedure FCMuiUMIF_PolicyEnforcement_Update;
{:Purpose: update the acceptance probability and enforcement subsection.
    Additions:
      -2012Sep13- *add: apply the last update of the status rules for conditions.
}
   var
      HTMLFormat: string;

      isUniquePolicy: boolean;

      UMIUFpolArea: TFCEdgSPMarea;
begin
   {:DEV NOTES: COMPLETE THE DOC W/ POLICIES ENFORCEMENT LIMITATIONS ACCORDING TO THE STATUS LEVELS + UPDATE FCFgSPMD_PlyrStatus_ApplyRules (w/o make an audit yet).}
   FCWinMain.FCWM_UMIFSh_CAPFlab.HTMLText.Clear;
   HTMLFormat:='';
   FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
   FCWinMain.FCWM_UMISh_CEFcommit.Enabled:=false;
   FCWinMain.FCWM_UMISh_CEFretire.Enabled:=false;
   UMIUFpolArea:=FCFgSPM_EnforcPol_GetArea;
   isUniquePolicy:=FCFgSPM_EnforcPol_GetUnique;
   if isUniquePolicy
   then UMIUFisFSok:=FCFgSPMD_PlyrStatus_ApplyRules(gmspmdCanChangeGvt)
   else UMIUFisFSok:=true;
   if UMIUFisFSok
   then
   begin
      UMIUFstat:=round(FCFgSPM_EnforcData_Get(gspmAccProbability));
      UMIUFinfl:=round(FCFgSPM_EnforcData_Get(gspmInfl));
      UMIUFmargPen:=round(FCFgSPM_EnforcData_Get(gspmMargMod));
      if UMIUFinfl<0
      then HTMLFormat:=FCCFcolRed
      else if UMIUFinfl>0
      then HTMLFormat:=FCCFcolGreen+'+';
      FCWinMain.FCWM_UMIFSh_CAPFlab.HTMLText.Add(
         '<p align="center" valign="center"><font size="20">'+IntToStr(UMIUFstat)+' %</font></p><p align="left"><sub>'
            +FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfInflTtl')+' <b>'+HTMLFormat+IntToStr(UMIUFinfl)+FCCFcolEND+'</b>   '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfReqPen')
         );
      if UMIUFmargPen<0
      then HTMLFormat:=FCCFcolRed
      else HTMLFormat:='';
      FCWinMain.FCWM_UMIFSh_CAPFlab.HTMLText.Add(' <b>'+HTMLFormat+IntToStr(UMIUFmargPen)+'</b></sub></p>');
      FCWinMain.FCWM_UMISh_CEFenforce.Visible:=true;
   end
   else FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoUnique'));
   if not UMIUFrelocRetVal
   then
   begin
      FCWinMain.FCWM_UMISh_CEFenforce.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFenforceNreq');
      FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=false;
      FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfNReq'));
   end
   else if (UMIUFrelocRetVal)
      and (UMIUFisFSok)
   then
   begin
      FCWinMain.FCWM_UMISh_CEFenforce.Caption:=FCFdTFiles_UIStr_Get(uistrUI, 'FCWM_UMISh_CEFenforce');
      FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=true;
      UMIUFcalc:=FCFgSPM_PolicyProc_DoTest(50);
      FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfYReq1'));
      case UMIUFcalc of
         gspmResMassRjct: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolRed+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMassRej')+FCCFcolEND);
         gspmResReject: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolOrge+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltReject')+FCCFcolEND);
         gspmResFifFifty: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolYel+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltMitig')+FCCFcolEND);
         gspmResAccept: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCCFcolGreen+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfRsltComplAcc')+FCCFcolEND);
      end;
      FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfYReq2'));
      UMIUFpolToken:=FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, UMIUFpolArea);
      if (UMIUFisUnique)
         and (UMIUFpolToken<>'')
      then
      begin
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add('<br>'+FCCFcolWhBL+FCFdTFiles_UIStr_Get(uistrUI, 'UMIenfUnique')+'<b>'+FCFdTFiles_UIStr_Get(uistrUI, UMIUFpolToken)+'</b> ');
         case UMIUFpolArea of
            dgADMIN: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtPolSys' ) );
            dgECON: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtEcoSys' ) );
            dgMEDCA: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtHcareSys' ) );
            dgSPI: FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get( uistrUI, 'UMIgvtRelSys' ) );
         end;
         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add('.'+FCCFcolEND);
      end;
   end
   else FCWinMain.FCWM_UMISh_CEFenforce.Enabled:=false;
end;

procedure FCMuiUMIF_PolicyEnforcement_UpdateAll;
{:Purpose: update the policy enforcement sub-tab.
    Additions:
}
begin
//      FCWinMain.FCWM_UMIFSh_AFlist.Items.Clear;
//      FCWinMain.FCWM_UMIFSh_AFlist.Enabled:=true;
//      UMIUFisFSok:=FCFgSPMD_PlyrStatus_ApplyRules(gmspmdCanEnfPolicies);
//      if FCDdgEntities[0].E_hqHigherLevel=hqsNoHQPresent
//      then
//      begin
//         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
//         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, 'UMIhqNoMsg'));
//      end
//      else if (FCDdgEntities[0].E_hqHigherLevel>=hqsBasicHQ)
//         and (UMIUFisFSok)
//      then
//      begin
//         {.section update}
//         UMIUFmax:=length(FCDdgEntities[0].E_spmSettings)-1;
//         UMIUFcnt:=1;
//         while UMIUFcnt<=UMIUFmax do
//         begin
//            if (FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_isPolicy)
//               and (not FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_iPtIsSet)
//               and (FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_duration=0)
//            then FCWinMain.FCWM_UMIFSh_AFlist.Items.Add(
////               '<a href="'+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+'">'+
//               FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+
////               '</a>'
////               FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token)+
//               UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[UMIUFcnt].SPMS_token+UIHTMLencyEND
//               );
//            inc(UMIUFcnt)
//         end;
//         FCWinMain.FCWM_UMIFSh_AFlist.Sorted:=true;
//         FCWinMain.FCWM_UMIFSh_AFlist.SortWithHTML:=true;
//         FCWinMain.FCWM_UMIFSh_AFlist.ItemIndex:=0;
//         FCMumi_AvailPolList_UpdClick;
//      end
//      else
//      begin
//         UMIUFstatus:=FCFgSPMD_Level_GetToken(FCVdgPlayer.P_socialStatus);
//         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Clear;
//         FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add(
//            FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf1')
//            +'[<b>'+IntToStr(Integer(FCVdgPlayer.P_socialStatus))+'</b>]-<b>'+FCFdTFiles_UIStr_Get(uistrUI, UMIUFstatus)+'</b>, '+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf2')
//            +'[<b>'+IntToStr(Integer(TFCEdgPlayerFactionStatus.pfs2_SemiDependent))+'</b>]-<b>'+FCFdTFiles_UIStr_Get(uistrUI, 'cpsStatSD')+'</b>.<br>'
//            );
//         if Assigned(FCcps)
//         then FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf3') )
//         else FCWinMain.FCWM_UMISh_CEFreslt.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolenfRuleNoEnf4') );
//      end;
end;

procedure FCMuiUMIF_PoliticalStructure_Update( const UpdateTarget: TFCEuiUMIFpoliticalActions );
{:Purpose: update the political structure.
    Additions:
}
begin
   case UpdateTarget of
      paPoliticalStructureAll:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Clear;
         {.idx=0}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtPolSys')+FCCFdHeadEnd);
         {.idx=1}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgADMIN))+'<br>' );
         {.idx=2}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatBur')+FCCFdHeadEnd);
         {.idx=3}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(IntToStr(FCDdgEntities[0].E_bureaucracy)+' %<br>' );
         {.idx=4}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'SPMdatCorr')+FCCFdHeadEnd);
         {.idx=5}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(IntToStr(FCDdgEntities[0].E_corruption)+' %<br>' );
         {.idx=6}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtEcoSys')+FCCFdHeadEnd);
         {.idx=7}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add( FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgECON))+'<br>' );
         {.idx=8}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtHcareSys')+FCCFdHeadEnd);
         {.idx=9}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgMEDCA))+'<br>' );
         {.idx=10}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCCFdHeadC+FCFdTFiles_UIStr_Get(uistrUI, 'UMIgvtRelSys')+FCCFdHeadEnd);
         {.idx=11}
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Add(FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgSPI))+'<br>' );
      end;

      paPoliticalStructureGovernment:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(1, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgADMIN))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(2);
      end;

      paPoliticalStructureBureaucracy:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(3, IntToStr(FCDdgEntities[0].E_bureaucracy)+' %<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(4);
      end;

      paPoliticalStructureCorruption:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(5, IntToStr(FCDdgEntities[0].E_corruption)+' %<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(6);
      end;

      paPoliticalStructureEconomy:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(7, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgECON))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(8);
      end;

      paPoliticalStructureHealthcare:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(9, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgMEDCA))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(10);
      end;

      paPoliticalStructureSpiritual:
      begin
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Insert(11, FCFdTFiles_UIStr_Get(uistrUI, FCFgSPM_GvtEconMedcaSpiSystems_GetToken(0, dgSPI))+'<br>' );
         FCWinMain.FCWM_UMIFac_PGDdata.HTMLText.Delete(12);
      end;
   end; //==END== case UpdateTarget of ==//
end;

procedure FCMuiUMIF_SPMSettings_Update;
{:Purpose: update the trees of the SPM settings.
    Additions:
}
   var
      Count
      ,Max: integer;

      StrPolicySetMemePresent
      ,StrFormat
      ,StrMemeProgressUniquePolicy
      ,StrDuration: string;

      NodeRootSPMadministration
      ,NodeSPMitem
      ,NodeRootSPMeconomy
      ,NodeRootSPMmedicalCare
      ,NodeRootSPMsociety
      ,NodeRootSPMspacePolicy
      ,NodeRootSPMspirituality: TTreenode;

      UMIUFspmi: TFCRdgSPMi;
begin
   Count:=1;
   Max:=length( FCDdgEntities[0].E_spmSettings )-1;
   FCWinMain.FCWM_UMIFSh_SPMadmin.Items.Clear;
   NodeRootSPMadministration:=FCWinMain.FCWM_UMIFSh_SPMadmin.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaADMIN')+'</b>' );
   FCWinMain.FCWM_UMIFSh_SPMecon.Items.Clear;
   NodeRootSPMeconomy:=FCWinMain.FCWM_UMIFSh_SPMecon.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaECON')+'</b>' );
   FCWinMain.FCWM_UMIFSh_SPMmedca.Items.Clear;
   NodeRootSPMmedicalCare:=FCWinMain.FCWM_UMIFSh_SPMmedca.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaMEDCA')+'</b>' );
   FCWinMain.FCWM_UMIFSh_SPMsoc.Items.Clear;
   NodeRootSPMsociety:=FCWinMain.FCWM_UMIFSh_SPMsoc.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaSOC')+'</b>' );
   FCWinMain.FCWM_UMIFSh_SPMspol.Items.Clear;
   NodeRootSPMspacePolicy:=FCWinMain.FCWM_UMIFSh_SPMspol.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaSPOL')+'</b>' );
   FCWinMain.FCWM_UMIFSh_SPMspi.Items.Clear;
   NodeRootSPMspirituality:=FCWinMain.FCWM_UMIFSh_SPMspi.Items.Add( nil, '<b>'+FCFdTFiles_UIStr_Get(uistrUI,'SPMiAreaSPI')+'</b>' );
   FCWinMain.FCWM_UMIFSh_SPMadmin.FullExpand;
   FCWinMain.FCWM_UMIFSh_SPMecon.FullExpand;
   FCWinMain.FCWM_UMIFSh_SPMmedca.FullExpand;
   FCWinMain.FCWM_UMIFSh_SPMsoc.FullExpand;
   FCWinMain.FCWM_UMIFSh_SPMspol.FullExpand;
   FCWinMain.FCWM_UMIFSh_SPMspi.FullExpand;
   while Count<=Max do
   begin
      StrFormat:='';
      StrPolicySetMemePresent:='';
      StrMemeProgressUniquePolicy:='';
      StrDuration:='';
      UMIUFspmi:=FCFgSPM_SPMIData_Get(FCDdgEntities[0].E_spmSettings[Count].SPMS_token);
      if FCDdgEntities[0].E_spmSettings[Count].SPMS_isPolicy
      then
      begin
         if FCDdgEntities[0].E_spmSettings[Count].SPMS_iPtIsSet then
         begin
            StrPolicySetMemePresent:='  ['+FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolSet')+' <b>'+IntToStr(FCDdgEntities[0].E_spmSettings[Count].SPMS_iPtAcceptanceProbability)+'</b> %]';
            StrFormat:=FCCFcolGreen+FCFdTFiles_UIStr_Get( uistrUI, FCDdgEntities[0].E_spmSettings[Count].SPMS_token)+UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[Count].SPMS_token+UIHTMLencyEND+FCCFcolGreen+StrPolicySetMemePresent+FCCFcolEND;
            if not UMIUFspmi.SPMI_isUnique2set
            then StrDuration:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicyDur')+' [<b>'+IntToStr(FCDdgEntities[0].E_spmSettings[Count].SPMS_duration)+'</b> '
               +FCFdTFiles_UIStr_Get(uistrUI,'TimeFmonth')+']';
         end
         else if not FCDdgEntities[0].E_spmSettings[Count].SPMS_iPtIsSet then
         begin

            if FCDdgEntities[0].E_spmSettings[Count].SPMS_duration>0 then
            begin
               StrDuration:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicyDurFail')+' [<b>'+IntToStr(FCDdgEntities[0].E_spmSettings[Count].SPMS_duration)+'</b> '+FCFdTFiles_UIStr_Get(uistrUI,'TimeFmonth')+']';
               StrFormat:=FCCFcolRed;
            end;
            StrFormat:=StrFormat+FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[Count].SPMS_token)+UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[Count].SPMS_token+UIHTMLencyEND;
         end;
         if UMIUFspmi.SPMI_isUnique2set
         then StrMemeProgressUniquePolicy:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicy'+IntToStr(Integer(UMIUFspmi.SPMI_area)))
         else if not UMIUFspmi.SPMI_isUnique2set
         then StrMemeProgressUniquePolicy:=FCFdTFiles_UIStr_Get(uistrUI, 'UMIpolicy');
      end
      else if not FCDdgEntities[0].E_spmSettings[Count].SPMS_isPolicy
      then
      begin
         if FCDdgEntities[0].E_spmSettings[Count].SPMS_iPtBeliefLevel>blUnknown then
         begin
             StrPolicySetMemePresent:=FCCFcolBlueL+FCFdTFiles_UIStr_Get(uistrUI, 'UMImemeSet')+FCCFcolEND;
             StrFormat:=FCCFcolBlueL;
         end;
         StrFormat:=StrFormat+FCFdTFiles_UIStr_Get(uistrUI, FCDdgEntities[0].E_spmSettings[Count].SPMS_token)+UIHTMLencyBEGIN+FCDdgEntities[0].E_spmSettings[Count].SPMS_token+UIHTMLencyEND+StrPolicySetMemePresent;
         StrMemeProgressUniquePolicy:='  [<a href="SPMiBL">BL</a>: <b>'+FCFdTFiles_UIStr_Get(uistrUI, 'SPMiBL'+IntToStr( Integer( FCDdgEntities[0].E_spmSettings[Count].SPMS_iPtBeliefLevel ) ) )
            +'</b> / <a href="SPMiSV">SV</a>: <b>'+IntToStr(FCDdgEntities[0].E_spmSettings[Count].SPMS_iPtSpreadValue)+'</b> %]';
      end;
      case UMIUFspmi.SPMI_area of
         dgADMIN:
         begin
            NodeSPMitem:=FCWinMain.FCWM_UMIFSh_SPMadmin.Items.AddChild(
               NodeRootSPMadministration
               , StrFormat
               );

            FCWinMain.FCWM_UMIFSh_SPMadmin.Items.AddChild(
               NodeSPMitem
               ,StrMemeProgressUniquePolicy
               );
            if StrDuration<>''
            then FCWinMain.FCWM_UMIFSh_SPMadmin.Items.AddChild(
               NodeSPMitem
               ,StrDuration
               );
         end;
         dgECON:
         begin
            NodeSPMitem:=FCWinMain.FCWM_UMIFSh_SPMecon.Items.AddChild(
               NodeRootSPMeconomy
               ,StrFormat
               );

             FCWinMain.FCWM_UMIFSh_SPMecon.Items.AddChild(
               NodeSPMitem
               ,StrMemeProgressUniquePolicy
               );
            if StrDuration<>''
            then FCWinMain.FCWM_UMIFSh_SPMecon.Items.AddChild(
               NodeSPMitem
               ,StrDuration
               );
         end;
         dgMEDCA:
         begin
            NodeSPMitem:=FCWinMain.FCWM_UMIFSh_SPMmedca.Items.AddChild(
               NodeRootSPMmedicalCare
               ,StrFormat
               );

             FCWinMain.FCWM_UMIFSh_SPMmedca.Items.AddChild(
               NodeSPMitem
               ,StrMemeProgressUniquePolicy
               );
            if StrDuration<>''
            then FCWinMain.FCWM_UMIFSh_SPMmedca.Items.AddChild(
               NodeSPMitem
               ,StrDuration
               );
         end;
         dgSOC:
         begin
            NodeSPMitem:=FCWinMain.FCWM_UMIFSh_SPMsoc.Items.AddChild(
               NodeRootSPMsociety
               ,StrFormat
               );

             FCWinMain.FCWM_UMIFSh_SPMsoc.Items.AddChild(
               NodeSPMitem
               ,StrMemeProgressUniquePolicy
               );
            if StrDuration<>''
            then FCWinMain.FCWM_UMIFSh_SPMsoc.Items.AddChild(
               NodeSPMitem
               ,StrDuration
               );
         end;
         dgSPOL:
         begin

            NodeSPMitem:=FCWinMain.FCWM_UMIFSh_SPMspol.Items.AddChild(
               NodeRootSPMspacePolicy
               ,StrFormat
               );

             FCWinMain.FCWM_UMIFSh_SPMspol.Items.AddChild(
               NodeSPMitem
               ,StrMemeProgressUniquePolicy
               );
            if StrDuration<>''
            then FCWinMain.FCWM_UMIFSh_SPMspol.Items.AddChild(
               NodeSPMitem
               ,StrDuration
               );
         end;
         dgSPI:
         begin

            NodeSPMitem:=FCWinMain.FCWM_UMIFSh_SPMspi.Items.AddChild(
               NodeRootSPMspirituality
               ,StrFormat
               );

             FCWinMain.FCWM_UMIFSh_SPMspi.Items.AddChild(
               NodeSPMitem
               ,StrMemeProgressUniquePolicy
               );
            if StrDuration<>''
            then FCWinMain.FCWM_UMIFSh_SPMspi.Items.AddChild(
               NodeSPMitem
               ,StrDuration
               );
         end;
      end; //==END== case UMIUFspmi.SPMI_area of ==//
      inc(Count);
   end; //==END== while Count<=Max do ==//
   NodeRootSPMadministration.Expand(false);
   NodeRootSPMadministration.Selected:=true;
   NodeRootSPMeconomy.Expand(false);
   NodeRootSPMmedicalCare.Expand(false);
   NodeRootSPMsociety.Expand(false);
   NodeRootSPMspacePolicy.Expand(false);
   NodeRootSPMspirituality.Expand(false);
end;

end.
