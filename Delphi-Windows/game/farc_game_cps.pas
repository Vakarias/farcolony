{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: CPS / Colonization Phase System core

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

unit farc_game_cps;

interface

uses
   Classes
   ,Controls
   ,Graphics
   ,Math
   ,SysUtils
   ,Windows

   ,AdvPanel
   ,HTMLabel

   ,DecimalRounding_JH1

   ,farc_data_game
   ,farc_game_cpsobjectives;

   {.viability objective data structure}
   {:DEV NOTE: update TFCcps.Create + FCMdFiles_Game_Save/load.}
   {:DEV NOTES: update TFCRcpsoViabilityObjective if needed.}
   type TFCRcpsObj=record
      CPSO_score: integer;
      case CPSO_type: TFCEcpsoObjectiveTypes of
         otEcoEnEff: ();

         otEcoIndustrialForce: (
            CPSO_ifProduct: string[20];
            CPSO_ifThreshold: extended;
            );

         otEcoLowCr: ();

         otEcoSustCol: ();

         otSocSecPop: ();
   end;
   {.colonization phase system class}
   {:DEV NOTE: update TFCcps.Create + FCMdFiles_Game_Save/load.}
   type TFCcps = class(TObject)
      private
         {.colonization viability score}
         CPScvs: integer;
         {.time left in ticks}
         CPStLft: integer;
         {.credit line current interest used}
         CPSint: extended;
         {.credit line max and currently used}
         CPScrLineM: integer;
         CPScrLineU: extended;
         procedure FCM_ViabObj_Load(const VOLobjList: array of TFCRcpsoViabilityObjective); overload;
         procedure FCM_ViabObj_Load(const VOLobjList: array of TFCRcpsObj); overload;
      public
         {.cps panel location}
         CPSpX: integer;
         CPSpY: integer;
         CPSisEnabled: boolean;
         {.viability objectives panel}
         CPSobjPanel: TAdvPanel;
         CPSobjP_List: THTMLabel;
         {.viability objectives list}
         CPSviabObj: array of TFCRcpsObj;
         {.routines}
         constructor Create(
            const CPSCcredRng
                  ,CPSCintRng: TFCEcrIntRg;
            const CPSCobjList: array of TFCRcpsoViabilityObjective
            ); overload;
         constructor Create(
            const CPSCcvs
                  ,CPSCtlft
                  ,CPSCcrLineM : integer;
            const CPSCint
                  ,CPSCcrLineU: extended;
            const CPSCobjList: array of TFCRcpsObj;
            const CPSCisEnabled: boolean
            ); overload;

         ///<summary>
         ///   return the credit line interest with or w/o the '%'
         ///</summary>
         function FCF_CredLineInterest_Get( const isUseARawValue: boolean): string; overload;

         ///<summary>
         ///   return the credit line interest value
         ///</summary>
         function FCF_CredLineInterest_Get: extended; overload;

         ///<summary>
         ///   return the used or max credit line in UC (w/o the acronym)
         ///</summary>
         ///    <param name="GCLgetUsed">true= get used, false= get max credit line</param>
         ///    <param name="GCLraw">true= get the raw value, false return a x,xxx,xxx.xx format</param>
         function FCF_CredLine_Get(const GCLgetUsed, GCLraw: boolean): string; overload;

         ///<summary>
         ///   return the used or max credit line value
         ///</summary>
         ///    <param name="GCLgetUsed">true= get used, false= get max credit line</param>
         function FCF_CredLine_Get(const GCLgetUsed: boolean): extended; overload;

         ///<summary>
         ///   return Colony Viability Score
         ///</summary>
         function FCF_CVS_Get: string;

         ///<summary>
         ///   update the CVS with a new value
         ///</summary>
         ///   <param name="NewCVS">new value to replace the current CVS</param>
         procedure FCM_CVS_update( NewCVS: integer );

         ///<summary>
         ///   end of colonization phase process
         ///</summary>
         procedure FCM_EndPhase_Proc;

         ///<summary>
         ///   initialize the objective panel
         ///</summary>
         procedure FCM_ObjPanel_Init;

         ///<summary>
         ///   get the descriptive string of the numeric viability threshold
         ///</summary>
         ///   <param name="Threshold">threshold value</param>
         ///   <returns>threshold descriptive string (difficulty (ideology))</returns>
         function FCF_Threshold_GetString( const Threshold: integer ): string;

         ///<summary>
         ///   update the time left (one click less), and trigger the end of phase when needed
         ///   return true if end of phase
         ///</summary>
         function FCF_TimeLeft_Upd: boolean;

         ///<summary>
         ///   return time left in converted date
         ///</summary>
         function FCF_TimeLeft_Get(const TLGraw: boolean): string;

         ///<summary>
			///	initialize each viability objective and update the viability objectives panel
			///</summary>
			procedure FCM_ViabObj_Init(VOIinclCalc: boolean);

         ///<summary>
         ///   update a specific type of objective, if exists, and also update in accordance the panel
         ///</summary>
         ///    <param name="VOUobj">viability objective type</param>
         procedure FCF_ViabObj_Use( const VOUobj: TFCEcpsoObjectiveTypes );
         //=================================================================================
         //CONSTANTS
         const
            {.credit range mi=min ma=max}
            CRmiPoor=20000;
            CRmaPoor=49999;
            CRmiUnde=50000;
            CRmaUnde=100000;
            CRmiBAvg=120000;
            CRmaBAvg=249999;
            CRmiAvge=250000;
            CRmaAvge=499999;
            CRmiAbAv=500000;
            CRmaAbAv=1000000;
            CRmiRich=1250000;
            CRmaRich=2499999;
            CRmiOvFu=2500000;
            CRmaOvFu=4999999;
            CRmiUnli=5000000;
            CRmaUnli=10000000;
            {.interest range mi=min ma=max}
            IRmiPoor=0.5;
            IRmaPoor=0.9;
            IRmiUnde=1;
            IRmaUnde=2.9;
            IRmiBAvg=3;
            IRmaBAvg=4.9;
            IRmiAvge=5;
            IRmaAvge=10.9;
            IRmiAbAv=11;
            IRmaAbAv=14.9;
            IRmiRich=15;
            IRmaRich=18.9;
            IRmiOvFu=19;
            IRmaOvFu=24.9;
            IRmiUnli=25;
            IRmaUnli=33;
   end;

var
   FCcps: TFCcps;
   FCcpsObjectivesLines: integer;

implementation

uses
   farc_common_func
   ,farc_data_init
   ,farc_data_textfiles
   ,farc_main
   ,farc_ui_cps
   ,farc_ui_win;

//=============================================END OF INIT==================================

constructor TFCcps.Create(
            const CPSCcredRng
                  ,CPSCintRng: TFCEcrIntRg;
            const CPSCobjList: array of TFCRcpsoViabilityObjective
            );
{:Purpose: CPS creation and initialization.
    Additions:
      -2012Feb09- *mod: put the local float data in extended format.
      -2010Jun06- *add: viability objectives panel creation.
      -2010Mar22- *add: time left initialization.
      -2010Mar13- *mod: put viability objectives initialization in a separate method.
      -2010Mar11- *add: initialize viability objectives.
}
var
   CPSCcnt
   ,CPSCmax: integer;
   CPSCint: extended;
begin
   inherited Create;
   {.set time left, 52560 ticks= 365 standard days}
   CPStLft:=52560;
   {.set credit line}
   case CPSCcredRng of
      {.add a function randomrng that use the custom random function}
      crirPoor_Insign: CPScrLineM:=RandomRange(CRmiPoor, CRmaPoor);
      crirUndFun_Low: CPScrLineM:=RandomRange(CRmiUnde, CRmaUnde);
      crirBelAvg_Mod: CPScrLineM:=RandomRange(CRmiBAvg, CRmaBAvg);
      crirAverage: CPScrLineM:=RandomRange(CRmiAvge, CRmaAvge);
      crirAbAvg_Maj: CPScrLineM:=RandomRange(CRmiAbAv, CRmaAbAv);
      crirRch_High: CPScrLineM:=RandomRange(CRmiRich, CRmaRich);
      crirOvrFun_Usu: CPScrLineM:=RandomRange(CRmiOvFu, CRmaOvFu);
      crirUnl_Ins: CPScrLineM:=RandomRange(CRmiUnli, CRmaUnli);
   end;
   CPScrLineU:=0;
   case CPSCintRng of
      crirPoor_Insign: CPSCint:=IRmiPoor+( (FCFcFunc_Rand_Int(100)+1)*(IRmaPoor-IRmiPoor)*0.01 );
      crirUndFun_Low: CPSCint:=IRmiUnde+( (FCFcFunc_Rand_Int(100)+1)*(IRmaUnde-IRmiUnde)*0.01 );
      crirBelAvg_Mod: CPSCint:=IRmiBAvg+( (FCFcFunc_Rand_Int(100)+1)*(IRmaBAvg-IRmiBAvg)*0.01 );
      crirAverage: CPSCint:=IRmiAvge+( (FCFcFunc_Rand_Int(100)+1)*(IRmaAvge-IRmiAvge)*0.01 );
      crirAbAvg_Maj: CPSCint:=IRmiAbAv+( (FCFcFunc_Rand_Int(100)+1)*(IRmaAbAv-IRmiAbAv)*0.01 );
      crirRch_High: CPSCint:=IRmiRich+( (FCFcFunc_Rand_Int(100)+1)*(IRmaRich-IRmiRich)*0.01 );
      crirOvrFun_Usu: CPSCint:=IRmiOvFu+( (FCFcFunc_Rand_Int(100)+1)*(IRmaOvFu-IRmiOvFu)*0.01 );
      crirUnl_Ins: CPSCint:=IRmiUnli+( (FCFcFunc_Rand_Int(100)+1)*(IRmaUnli-IRmiUnli)*0.01 );
   end;
   CPSint:=DecimalRound(CPSCint, 1, 0.01);
   {.set viability objectives}
   FCM_ViabObj_Load(CPSCobjList);
   {.initialize objectives panel}
   FCM_ObjPanel_Init;
   CPSisEnabled:=false;
end;

constructor TFCcps.Create(
   const CPSCcvs
         ,CPSCtlft
         ,CPSCcrLineM : integer;
   const CPSCint
         ,CPSCcrLineU: extended;
   const CPSCobjList: array of TFCRcpsObj;
   const CPSCisEnabled: boolean
   );
{:Purpose: second CPS initialization alternative.
    Additions:
      -2011Apr20- *add: isEnabled parameter.
      -2010Jun06- *add: viability objectives panel creation.
      -2010Mar22- *add: time left.
}
begin
   inherited Create;
   CPScvs:=CPSCcvs;
   CPStLft:=CPSCtlft;
   CPSint:=CPSCint;
   CPScrLineM:=CPSCcrLineM;
   CPScrLineU:=CPSCcrLineU;
   {.set viability objectives}
   FCM_ViabObj_Load(CPSCobjList);
   {.initialize objectives panel}
   FCM_ObjPanel_Init;
   CPSisEnabled:=CPSCisEnabled;
end;

function TFCcps.FCF_CredLineInterest_Get( const isUseARawValue: boolean): string;
{:Purpose: return the credit line interest with or w/o the '%'.
    Additions:
}
begin
   Result:='';
   if not isUseARawValue
   then Result:=FloatToStr(CPSint)+' %'
   else Result:=FloatToStr(CPSint);
end;

function TFCcps.FCF_CredLineInterest_Get: extended;
{:Purpose: return the credit line interest value.
    Additions:
}
begin
   Result:=CPSint;
end;

function TFCcps.FCF_CredLine_Get(const GCLgetUsed, GCLraw: boolean): string;
{:Purpose: return the used or max credit line in UC (w/o the acronym).
    Additions:
      -2010Mar11- *add: put a switch for the need of the raw data w/o formatting.
}
begin
   if not GCLraw
   then
   begin
      if GCLgetUsed
      then Result:=FCFcFunc_ThSep(CPScrLineU,',')
      else if not GCLgetUsed
      then Result:=FCFcFunc_ThSep(CPScrLineM,',');
   end
   else if GCLraw
   then
   begin
      if GCLgetUsed
      then Result:=FloatToStr(CPScrLineU)
      else if not GCLgetUsed
      then Result:=IntToStr(CPScrLineM);
   end;
end;

function TFCcps.FCF_CredLine_Get(const GCLgetUsed: boolean): extended;
{:Purpose: return the used or max credit line value.
    Additions:
}
begin
   Result:=0;
   if GCLgetUsed
   then Result:=CPScrLineU
   else if not GCLgetUsed
   then Result:=CPScrLineM;
end;

function TFCcps.FCF_CVS_Get: string;
{:Purpose: return Colony Viability Score.
    Additions:
}
begin
   Result:=IntTostr(CPScvs);
end;

procedure TFCcps.FCM_CVS_update( NewCVS: integer );
{:Purpose: update the CVS with a new value.
    Additions:
}
begin
   CPScvs:=NewCVS;
end;

procedure TFCcps.FCM_EndPhase_Proc;
{:Purpose: end of colonization phase process.
    Additions:
      -2010Jun08- *add: cps related ui finalization.
}
begin
   {:DEV NOTE: add final calculations + final status gathered.}
   {:DEV NOTE:add credit line reimburse + rented / lended equipment/spacecrafts.}
   {.free cps related ui}
   FCVwMcpsPstore:=false;
   CPSobjP_List.Free;
   CPSobjPanel.Free;
end;

procedure TFCcps.FCM_ObjPanel_Init;
{:Purpose: initialize the objective panel.
    Additions:
      -2012Mar15- *mod: change height calculation and refined its position.
      -2012Feb09- *fix: panel's height is fixed.
                  *add: panel's title is now localized.
}
begin
   CPSobjPanel:=TAdvPanel.Create(FCWinMain);
   CPSobjPanel.Parent:=FCWinMain.FCWM_3dMainGrp;
   CPSobjPanel.BevelOuter:=bvNone;
   CPSobjPanel.BorderColor:=clSilver;
   CPSobjPanel.BorderWidth:=1;
   CPSobjPanel.CanMove:=true;
   CPSobjPanel.Caption.CloseButton:=false;
   CPSobjPanel.Caption.Color:=clBlack;
   CPSobjPanel.Caption.ColorTo:=$006e6e6e;
   CPSobjPanel.Caption.Flat:=true;
   CPSobjPanel.Caption.Font.Color:=clWhite;
   CPSobjPanel.Caption.Font.Charset:=ANSI_CHARSET;
   CPSobjPanel.Caption.Font.Height:=-11;
   CPSobjPanel.Caption.Font.Name:='DejaVu Sans Condensed';
   CPSobjPanel.Caption.Font.Size:=FCFuiW_Font_GetSize(uiwPanelTitle);
   CPSobjPanel.Caption.GradientDirection:=gdVertical;
   CPSobjPanel.Caption.MinMaxButton:=true;
   CPSobjPanel.Caption.MinMaxButtonHoverColor:=clSkyBlue;
   CPSobjPanel.Caption.Shape:=csSemiRounded;
   CPSobjPanel.Caption.Text:=FCFdTFiles_UIStr_Get( uistrUI, 'FCWM_MMenu_O_LocVObj' );
   CPSobjPanel.Caption.Visible:=true;
   CPSobjPanel.CollapsColor:=clBlack;
   CPSobjPanel.CollapsDelay:=0;
   CPSobjPanel.Color:=clBlack;
   CPSobjPanel.FixedHeight:=true;
   CPSobjPanel.FixedWidth:=true;
   CPSobjPanel.Font.Color:=clWhite;
   CPSobjPanel.Font.Name:='Tahoma';
   CPSobjPanel.Height:=1;
   if FCVwMcpsPstore
   then
   begin
      CPSobjPanel.Left:=FCWinMain.FCGLSHUDcpsCredL.Tag;
      CPSpX:=CPSobjPanel.Left;
   end
   else CPSobjPanel.Left:=8;
   CPSobjPanel.Locked:=true;
   CPSobjPanel.ParentColor:=false;
   CPSobjPanel.ParentFont:=false;
   if FCVwMcpsPstore
   then
   begin
      CPSobjPanel.Top:=FCWinMain.FCGLSHUDcpsTlft.Tag;
      CPSpY:=CPSobjPanel.Top;
   end
   else CPSobjPanel.Top:=40;
   CPSobjPanel.UseDockManager:=true;
   CPSobjPanel.Visible:=false;
   CPSobjPanel.Width:=310;
   CPSobjP_List:=THTMLabel.Create(CPSobjPanel);
   CPSobjP_List.Parent:=CPSobjPanel;
   CPSobjP_List.Align:=alClient;
   CPSobjP_List.Color:=clBlack;
   CPSobjP_List.ColorTo:=$00404040;
   CPSobjP_List.Font.Charset:=ANSI_CHARSET;
   CPSobjP_List.Font.Color:=$00E1E1E1;
   CPSobjP_List.Font.Height:=-12;
   CPSobjP_List.Font.Name:='FrancophilSans';
   if (FCVwinMsizeW>=1152)
      and (FCVwinMsizeH>=896)
   then CPSobjP_List.Font.Size:=10
   else CPSobjP_List.Font.Size:=9;
   CPSobjP_List.GradientType:=gtFullVertical;
   CPSobjP_List.Hover:=true;
   CPSobjP_List.HoverColor:=clBlack;
   CPSobjP_List.HoverFontColor:=clSkyBlue;
   CPSobjP_List.ParentColor:=false;
   CPSobjP_List.ParentFont:=false;
   CPSobjP_List.Transparent:=false;
   CPSobjP_List.URLColor:=$00D6ABAB;
   CPSobjP_List.Visible:=true;
end;

function TFCcps.FCF_TimeLeft_Get(const TLGraw: boolean): string;
{:Purpose: return time left in converted date.
    Additions:
}
begin
   if TLGraw
   then Result:=IntToStr(FCcps.CPStLft)
   else if not TLGraw
   then Result:=FCFcFunc_TimeTick_GetDate(FCcps.CPStLft);
end;

function TFCcps.FCF_Threshold_GetString( const Threshold: integer ): string;
{:Purpose: get the descriptive string of the numeric viability threshold.
    Additions:
}
begin
   Result:='';
   case Threshold of
      70: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'cpsThr1');

      85: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'cpsThr2');

      100: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'cpsThr3');

      110: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'cpsThr4');

      120: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'cpsThr5');

      130: Result:=FCFdTFiles_UIStr_Get( uistrUI, 'cpsThr6');
   end;
end;

function TFCcps.FCF_TimeLeft_Upd: boolean;
{:Purpose: update the time left (one click less), and trigger the end of phase when needed.
    Additions:
}
begin
   Result:=false;
   dec(CPStLft);
   if CPStLft=0
   then
   begin
      FCM_EndPhase_Proc;
      Result:=true;
   end;
end;

procedure TFCcps.FCM_ViabObj_Init(VOIinclCalc: boolean);
{:Purpose: initialize each viability objective and update the viability objectives panel.
   Additions:
      -2012Mar11- *add: otEcoIndustrialForce.
}
var
   VOIcnt
   ,VOImax: integer;

  ItemString: string;
begin
   CPSobjP_List.HTMLText.Clear;
   FCcpsObjectivesLines:=0;
   VOIcnt:=1;
   VOImax:=length(CPSviabObj)-1;
   while VOIcnt<=VOImax do
   begin
      if (VOIinclCalc)
         and (VOIcnt<VOImax)
      then FCMgCPSO_Score_Update( VOIcnt, false )
      else if (VOIinclCalc)
         and (VOIcnt=VOImax)
      then FCMgCPSO_Score_Update( VOIcnt, true );
      CPSobjP_List.HTMLText.Add( FCFuiCPS_Objective_GetFormat( VOIcnt ) );
      inc(VOIcnt);
   end;
   CPSobjPanel.Height:=( ( length(CPSviabObj)-1+FCcpsObjectivesLines )*18);
   FCcps.CPSobjPanel.Visible:=true;
end;

procedure TFCcps.FCM_ViabObj_Load(const VOLobjList: array of TFCRcpsoViabilityObjective);
{:Purpose: load the viability objectives, case of first initialization.
    Additions:
      -2012Mar13- *fix: forgot to load the specific otEcoIndustrialForce if needed.
}
var
   VOLcnt: integer;
begin
   setlength(CPSviabObj, length(VOLobjList));
   VOLcnt:=1;
   while VOLcnt<=length(CPSviabObj) - 1 do
   begin
      CPSviabObj[VOLcnt].CPSO_type:=VOLobjList[VOLcnt].FVO_objTp;
      CPSviabObj[VOLcnt].CPSO_score:=-1;
      if CPSviabObj[VOLcnt].CPSO_type=otEcoIndustrialForce then
      begin
         CPSviabObj[VOLcnt].CPSO_ifProduct:=VOLobjList[VOLcnt].FVO_ifProduct;
         CPSviabObj[VOLcnt].CPSO_ifThreshold:=VOLobjList[VOLcnt].FVO_ifThreshold;
      end;
      inc(VOLcnt);
   end;
end;

procedure TFCcps.FCM_ViabObj_Load(const VOLobjList: array of TFCRcpsObj);
{:Purpose: load the viability objectives, case of a loading game.
    Additions:
      -2012Mar13- *fix: forgot to load the specific otEcoIndustrialForce if needed.
}
var
   VOLcnt: integer;
begin
   setlength(CPSviabObj, length(VOLobjList));
   VOLcnt:=1;
   while VOLcnt<=length(CPSviabObj) - 1 do
   begin
      CPSviabObj[VOLcnt].CPSO_type:=VOLobjList[VOLcnt].CPSO_type;
      CPSviabObj[VOLcnt].CPSO_score:=VOLobjList[VOLcnt].CPSO_score;
      if CPSviabObj[VOLcnt].CPSO_type=otEcoIndustrialForce then
      begin
         CPSviabObj[VOLcnt].CPSO_ifProduct:=VOLobjList[VOLcnt].CPSO_ifProduct;
         CPSviabObj[VOLcnt].CPSO_ifThreshold:=VOLobjList[VOLcnt].CPSO_ifThreshold;
      end;
      inc(VOLcnt);
   end;
end;

procedure TFCcps.FCF_ViabObj_Use( const VOUobj: TFCEcpsoObjectiveTypes );
{:Purpose: update a specific type of objective, if exists, and also update in accordance the panel, or return the value of the choosen colonization objective.
    Additions:
      -2012Mar14- *code: optimization.
      -2012Mar11- *add: otEcoIndustrialForce.
      -2012Feb09- *add: completion - Work-In-Progress.
      -2010Sep14- *add: entities code.
}
   var
      CPSobjCount
      ,CPSobjMax
      ,ObjectivePanelIndex: integer;

      ItemString: string;
begin
   CPSobjMax:=length( FCcps.CPSviabObj )-1;
   CPSobjCount:=1;
   ObjectivePanelIndex:=0;
   ItemString:='';
   while CPSobjCount<=CPSobjMax do
   begin
      if FCcps.CPSviabObj[ CPSobjCount ].CPSO_type=VOUobj
      then break
      else inc( CPSobjCount);
   end;
   if CPSobjCount<=CPSobjMax  then
   begin
      FCMgCPSO_Score_Update( CPSobjCount, true );
      ObjectivePanelIndex:=CPSobjCount-1;
      FCcps.CPSobjP_List.HTMLText.Insert( ObjectivePanelIndex,  FCFuiCPS_Objective_GetFormat( CPSobjCount ) );
      FCcps.CPSobjP_List.HTMLText.Delete( CPSobjCount );
   end;
end;

end.
