{=======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: common functions and procedures

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

unit farc_common_func;

interface

uses
   SHFolder
   ,SysUtils
   ,Windows

   ,farc_data_init

   ,DecimalRounding_JH1;

type TFCEcfunc3dCvTp=(
   cf3dctMeterToSpUnitSize
   ,cf3dctKmTo3dViewUnit
   ,cf3dct3dViewUnitToKm
   ,cf3dctAUto3dViewUnit
   ,cf3dct3dViewUnitToAU
   ,cf3dctAstDiamKmTo3dViewUnit
   ,cf3dctVelkmSecTo3dViewUnit
   ,cf3dctMinToGameTicks
   );

type TFCEcfRndToTp=(
   cfrttp1dec
   ,cfrttp2dec
   ,cfrttp3dec
   ,cfrttpDistkm
   ,cfrttpVelkms
   ,cfrttpSizem
   ,cfrttpVolm3
   ,cfrttpSurfm2
   ,cfrttpMassAster
   ,rttMasstons
   ,rttPowerKw
   );

type TFCEufClassF=(
   ufcfRaw
   ,ufcfAbr
   ,ufcfFull
   );

///<summary>
///   return the version of Far Colony. This code come from Alexandre of the
///   www.developpez.com website, is not my proper code. This code is modified for taking
///   into account of the future beta (1.x) and regular rls (>=1.5)
///</summary>
function FCFcFunc_FARCVersion_Get: string;

///<summary>
///   protect the ln() function with value <= 0
///</summary>
///   <param name="aValue">value to apply the ln() to</param>
///   <returns>result of the logarithm or 0</returns>
function FCFcF_Ln_Protected( const aValue: extended): extended;

///<summary>
///   round the target value following value type
///</summary>
function FCFcFunc_Rnd(
   const RentryType: TFCEcfRndToTp;
   const Rval: extended
   ): extended;

///<summary>
///   "real' random function including a randomize each time
///</summary>
///   <param name="RIrange">range integer</param>
function FCFcFunc_Rand_Int(const RIrange: integer): integer;

///<summary>
///   convert units in all ways
///</summary>
///   <param name="TDSCconvertion">conversion switch</param>
///   <param name="TDSCvalue">value to convert</param>
function FCFcFunc_ScaleConverter(
   const SCconversion: TFCEcfunc3dCvTp;
   const SCvalue: extended
   ): extended;

///<summary>
///   swap the sign of a value (+ => - / - => +)
///</summary>
///   <param name="SSvalue">value to swap</param>
function FCFcF_SignSwap( const SSvalue: extended ): extended;

///<summary>
///   retrieve space unit id# from token id in a owned list
///</summary>
///    <param name="SUGODBfacTp">faction id #</param>
///    <param name="">owned space unit token id string</param>
function FCFcFunc_SpUnit_getOwnDB(
   const SUGODBentity: integer;
   const SUGODBtokenId: string
   ): integer;

///<summary>
///   get the star class string, either in full name or shorter one.
///</summary>
///    <param name="SGCformat">format type</param>
///    <param name="SGCstsIdx">star system index</param>
///    <param name="SGCstIdx">star index</param>
function FCFcFunc_Star_GetClass(
   const SGCformat: TFCEufClassF;
   const SGCstsIdx
         ,SGCstIdx: integer
   ): string;

///<summary>
///format the value in a thousand separator format
///</summary>
///    <param name="TSval">value</param>
///    <param name="TSchr">thousand separator character</param>
function FCFcFunc_ThSep(
   const TSval: integer;
   const TSchr: Char
   ): string; overload;

///<summary>
///format the value in a thousand separator format
///</summary>
///    <param name="TSval">value</param>
function FCFcFunc_ThSep( const TSval: integer ): string; overload;

///<summary>
///format the value in a thousand separator format
///</summary>
///    <param name="TSval">value</param>
///    <param name="TSchr">thousand separator character</param>
function FCFcFunc_ThSep(
   const TSval: extended;
   const TSchr: Char
   ): string; overload;

///<summary>
///   format the value in a thousand separator format
///</summary>
///   <param name="TSval">value</param>
function FCFcFunc_ThSep( const TSval: extended ): string; overload;

///<summary>
///   transform time values in readable date.
///</summary>
function FCFcF_Time_GetDate(
   const TGDday
         ,TGDmth
         ,TGDyr: integer
   ): string;

///<summary>
///   transform time ticks in readable date.
///</summary>
///    <param name="TTGDtick">ticks value. 1= 10min GT</param>
function FCFcFunc_TimeTick_GetDate(const TTGDtick: extended): string;

///<summary>
///   get the folder path of several kind of folders. The code is directly taken from
///   a CodeGear pdf file named VistaUACandDelphi.pdf written by Fredrik Haglund.
///   No need to re-invente the wheel :)
///</summary>
///<param name="WFGAcsidl">really dunno</param>
function FCFcFunc_WinFolders_GetAction(
   const WFGAcsidl: integer;
   const WFGAforcefolder: boolean=false
   ): string;

///<summary>get the folder path of My Documents folders The code is directly taken from a
///CodeGear pdf</summary>
///<summary>file named "VistaUACandDelphi.pdf" written by Fredrik Haglund. No need to
///re-invente the wheel :)</summary>
///<param name="WFGMDforcefolder">really dunno</param>
function FCFcFunc_WinFolders_GetMyDocs(const WFGMDforcefolder: boolean=false): string;

///<summary>
///   delete w/ wildcards support. From Ion_T@DelphiPages.com
///</summary>
///<param name="FDpath">path must have the last "/"</param>
///<param name="FDname">filename w/ wildcards</param>
procedure FCMcF_Files_Del(const FDpath, FDname: string);

const
   CFC3dAstConv=14960*30.59789;
   CFC3dUnInKm=14959.787;     {conversion constant 1 3d unit = 14959.787km}
   CFC3dUnInAU=FCCdiKm_In_1AU/CFC3dUnInKm;

implementation

uses
   farc_data_game
   ,farc_data_spu
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_win_debug;

//===================================END OF INIT============================================

function FCFcFunc_FARCVersion_Get: string;
{:Purpose: return the version of Far Colony. This code come from Alexandre of the
    www.developpez.com website, is not my proper code. This code is modified for taking into
    account of the future beta (0.9) and regular rls (>=1.0)
   Additions:
      -2012May27- *add: take into account of the alpha #.
}
var
  VerInfoSize, Dummy: DWord;
  VerInfo: Pointer;
  VerValueSize: DWord;
  VerValue: PVSFixedFileInfo;
begin
   VerInfoSize:=GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
   If VerInfoSize<>0 then
   begin
      GetMem(VerInfo, VerInfoSize);
      GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do
      begin

         if ((dwFileVersionMS shr 16)=0)
//            and ((dwFileVersionMS and $FFFF)<1)
         then Result:='Alpha '+FCCdiAlphaNumber+' '
         else if ((dwFileVersionMS shr 16)=1)
           and ((dwFileVersionMS and $FFFF)=0)
         then Result:=Result+'Beta'
         else if ((dwFileVersionMS shr 16)=1)
           and ((dwFileVersionMS and $FFFF)=1)
         then Result:=Result+'Final'
         ;
         Result:=Result+'['+IntTostr(dwFileVersionMS shr 16);//0
         Result:=Result+'.'+IntTostr(dwFileVersionMS and $FFFF);//.4
         Result:=Result+'.'+IntTostr(dwFileVersionLS shr 16);//.0
         Result:=Result+'.'+IntTostr(dwFileVersionLS and $FFFF)+']';//.177
      end;
      FreeMem(VerInfo, VerInfoSize);
   end
   else Result:='Unknown Version';
end;

function FCFcFunc_Rand_Int(const RIrange: integer): integer;
{:Purpose: "real' random function including a randomize each time.
    Additions:
}
begin
   Result:=0;
   Randomize;
   Result:=random(RIrange);
end;

function FCFcF_Ln_Protected( const aValue: extended): extended;
{:Purpose: protect the ln() function with value <= 0.
    Additions:
}
begin
   Result:=aValue;
   if aValue>0
   then Result:=ln(aValue);
end;

function FCFcFunc_Rnd(
   const RentryType: TFCEcfRndToTp;
   const Rval: extended
   ): extended;
{:Purpose: round the target value dollowing value type.
    Additions:
      -2011Jul17- *add: power/kW rounding.
                  *mod: put the surfm2 at 2 decimal like it should be.
      -2011May15-	*add: 1dec/2dec/3dec.
      -2011May06- *fix: max relative error values are correctly set to provide correct calculations.
      -2011May05- *mod: change the old mass by massAster
                  *mod: change volume round type x.xxx.
                  *add: mass round type x.xxx.
      -2010Jan10- *mod/fix: use DecimalRound from codegear code central. It remove the
                  floating point error i have because of the roundto.
      -2009Dec10- *add mass roundto -6.
}
begin
   result:=0;
   case RentryType of
		cfrttp1dec: result:=DecimalRound(Rval, 1, 0.001);
      cfrttp2dec: result:=DecimalRound(Rval, 2, 0.0001);
      cfrttp3dec: result:=DecimalRound(Rval, 3, 0.00001);
      cfrttpDistkm: result:=DecimalRound(Rval, 2, 0.0001);
      cfrttpVelkms: result:=DecimalRound(Rval, 2, 0.0001);
      cfrttpSizem: result:=DecimalRound(Rval, 1, 0.001);
      cfrttpVolm3: result:=DecimalRound(Rval, 3, 0.00001);
      cfrttpSurfm2: result:=DecimalRound(Rval, 2, 0.0001);
      cfrttpMassAster: result:=DecimalRound(Rval, 6, 0.00000001);
      rttMasstons: result:=DecimalRound(Rval, 3, 0.00001);
      rttPowerKw: result:=DecimalRound(Rval, 2, 0.0001);
   end;
end;

function FCFcFunc_ScaleConverter(
   const SCconversion: TFCEcfunc3dCvTp;
   const SCvalue: extended
   ): extended;
{:Purpose: convert units in all ways.
    Additions:
      -2010Apr05- *mod: simplify and cleanup cf3dctMeterToSpUnitSize.
      -2010Mar28- *mod: cleanup the cf3dctMeterToSpUnitSize.
      -2009Dec15- *add: asteroid size conversion (one way, the reverse is useless).
      -2009Dec09- *massive scale change for 3d view, all is unified under the same scale.
                  *multiple refactoring.
                  *removing useless code.
      -2009Oct29- *take the current time frame for convtp_kmsToLocStarViewUnit.
      -2009Oct26- *add convtp_kmsToLocStarViewUnit.
      -2009Oct24- *add convtp_minToGameTicks.
      -2009Sep19- *add convtp_meterToSpUnitSize.
      -2009Sep06- *change roundto for FCFcFunc_Round.
                  *add unitToLocStarViewUnit.
                  *add kmtoLoStarViewUnit.
      -2009Aug30- *add ua<->unit.
}
var
   TDSCdmpRes: extended;
begin
   TDSCdmpRes:=0;
   case SCconversion of
      {.unit (planet aera and oobj size) => 3d view unit. /20 for ua-unit *500}
      cf3dctMeterToSpUnitSize: TDSCdmpRes:=(FCDdsuSpaceUnitDesigns[round(SCvalue)].SUD_internalStructureClone.IS_length*0.02)/CFC3dUnInKm;
      {.kilometers => 3d view unit}
      cf3dctKmTo3dViewUnit: TDSCdmpRes:=SCvalue/CFC3dUnInKm;
      {.astronomical units => 3d view unit}
      cf3dctAUto3dViewUnit: TDSCdmpRes:=SCvalue*CFC3dUnInAU;
      {.3d view unit => kilometers}
      cf3dct3dViewUnitToKm: TDSCdmpRes:=FCFcFunc_Rnd(cfrttpDistkm,(SCvalue*CFC3dUnInKm));
      {.3d view unit => astronomical units}
      cf3dct3dViewUnitToAU: TDSCdmpRes:=FCFcFunc_Rnd(cfrttpDistkm, (SCvalue/CFC3dUnInAU));
      {.asteroid diameter in km => 3d view unit}
      {:DEV NOTE: WARNING, need to load CF data concerning star system and star indexes.}
      {:DEV NOTE: 14960*coef 3.7= earth size, *8.2697= normalsize.}
      cf3dctAstDiamKmTo3dViewUnit: TDSCdmpRes:=SCvalue/(CFC3dAstConv);
      {.minutes => game ticks, 1 tick=10min}
      cf3dctMinToGameTicks: TDSCdmpRes:=round(SCvalue*0.1);
      {.km/s velocity => 3d view unit / tick}
      cf3dctVelkmSecTo3dViewUnit: TDSCdmpRes:=((SCvalue*600)/CFC3dUnInKm);
   end;
   Result:=TDSCdmpRes;
end;

function FCFcF_SignSwap( const SSvalue: extended ): extended;
{:Purpose: swap the sign of a value (+ => - / - => +).
    Additions:
}
begin
   Result:=0;
   if SSvalue<0
   then Result:=abs( SSvalue )
   else if SSvalue>0
   then Result:=-SSvalue;
end;


function FCFcFunc_SpUnit_getOwnDB(
   const SUGODBentity: integer;
   const SUGODBtokenId: string
   ): integer;
{:Purpose: retrieve space unit id# from token id in a owned list.
    Additions:
      -2010Sep14- *add: entities code.
                  *mod: replace the first switch by faction id #.
}
var
   SUGODBcnt,
   SUGODBttl: integer;
begin
   SUGODBcnt:=0;
   SUGODBttl:=0;
   SUGODBttl:=length(FCDdgEntities[SUGODBentity].E_spaceUnits)-1;
   if SUGODBttl<=0
   then result:=-1
   else if SUGODBttl>0
   then
   begin
      SUGODBcnt:=1;
      while SUGODBcnt<=SUGODBttl do
      begin
         if FCDdgEntities[SUGODBentity].E_spaceUnits[SUGODBcnt].SU_token=SUGODBtokenId
         then
         begin
            Result:=SUGODBcnt;
            break;
         end;
         inc(SUGODBcnt);
      end;
   end;
end;

function FCFcFunc_Star_GetClass(
   const SGCformat: TFCEufClassF;
   const SGCstsIdx
         ,SGCstIdx: integer
   ): string;
{:Purpose: get the star class string, either in full name or shorter one..
    Additions:
      -2009Nov17- *completion.
}
begin
   with FCDduStarSystem[SGCstsIdx].SS_stars[SGCstIdx] do
   begin
      case S_class of
         cB5:
         begin
            case SGCformat of
               ufcfRaw: result:='cB5';
               ufcfAbr: result:='B5I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B5I)';
            end;
         end;
         cB6:
         begin
            case SGCformat of
               ufcfRaw: result:='cB6';
               ufcfAbr: result:='B6I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B6I)';
            end;
         end;
         cB7:
         begin
            case SGCformat of
               ufcfRaw: result:='cB7';
               ufcfAbr: result:='B7I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B7I)';
            end;
         end;
         cB8:
         begin
            case SGCformat of
               ufcfRaw: result:='cB8';
               ufcfAbr: result:='B8I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B8I)';
            end;
         end;
         cB9:
         begin
            case SGCformat of
               ufcfRaw: result:='cB9';
               ufcfAbr: result:='B9I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B9I)';
            end;
         end;
         cA0:
         begin
            case SGCformat of
               ufcfRaw: result:='cA0';
               ufcfAbr: result:='A0I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A0I)';
            end;
         end;
         cA1:
         begin
            case SGCformat of
               ufcfRaw: result:='cA1';
               ufcfAbr: result:='A1I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A1I)';
            end;
         end;
         cA2:
         begin
            case SGCformat of
               ufcfRaw: result:='cA2';
               ufcfAbr: result:='A2I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A2I)';
            end;
         end;
         cA3:
         begin
            case SGCformat of
               ufcfRaw: result:='cA3';
               ufcfAbr: result:='A3I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A3I)';
            end;
         end;
         cA4:
         begin
            case SGCformat of
               ufcfRaw: result:='cA4';
               ufcfAbr: result:='A4I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A4I)';
            end;
         end;
         cA5:
         begin
            case SGCformat of
               ufcfRaw: result:='cA5';
               ufcfAbr: result:='A5I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A5I)';
            end;
         end;
         cA6:
         begin
            case SGCformat of
               ufcfRaw: result:='cA6';
               ufcfAbr: result:='A6I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A6I)';
            end;
         end;
         cA7:
         begin
            case SGCformat of
               ufcfRaw: result:='cA7';
               ufcfAbr: result:='A7I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A7I)';
            end;
         end;
         cA8:
         begin
            case SGCformat of
               ufcfRaw: result:='cA8';
               ufcfAbr: result:='A8I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A8I)';
            end;
         end;
         cA9:
         begin
            case SGCformat of
               ufcfRaw: result:='cA9';
               ufcfAbr: result:='A9I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A9I)';
            end;
         end;
         cK0:
         begin
            case SGCformat of
               ufcfRaw: result:='cK0';
               ufcfAbr: result:='K0I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K0I)';
            end;
         end;
         cK1:
         begin
            case SGCformat of
               ufcfRaw: result:='cK1';
               ufcfAbr: result:='K1I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K1I)';
            end;
         end;
         cK2:
         begin
            case SGCformat of
               ufcfRaw: result:='cK2';
               ufcfAbr: result:='K2I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K2I)';
            end;
         end;
         cK3:
         begin
            case SGCformat of
               ufcfRaw: result:='cK3';
               ufcfAbr: result:='K3I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K3I)';
            end;
         end;
         cK4:
         begin
            case SGCformat of
               ufcfRaw: result:='cK4';
               ufcfAbr: result:='K4I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K4I)';
            end;
         end;
         cK5:
         begin
            case SGCformat of
               ufcfRaw: result:='cK5';
               ufcfAbr: result:='K5I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K5I)';
            end;
         end;
         cK6:
         begin
            case SGCformat of
               ufcfRaw: result:='cK6';
               ufcfAbr: result:='K6I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K6I)';
            end;
         end;
         cK7:
         begin
            case SGCformat of
               ufcfRaw: result:='cK7';
               ufcfAbr: result:='K7I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K7I)';
            end;
         end;
         cK8:
         begin
            case SGCformat of
               ufcfRaw: result:='cK8';
               ufcfAbr: result:='K8I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K8I)';
            end;
         end;
         cK9:
         begin
            case SGCformat of
               ufcfRaw: result:='cK9';
               ufcfAbr: result:='K9I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K9I)';
            end;
         end;
         cM0:
         begin
            case SGCformat of
               ufcfRaw: result:='cM0';
               ufcfAbr: result:='M0I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M0I)';
            end;
         end;
         cM1:
         begin
            case SGCformat of
               ufcfRaw: result:='cM1';
               ufcfAbr: result:='M1I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M1I)';
            end;
         end;
         cM2:
         begin
            case SGCformat of
               ufcfRaw: result:='cM2';
               ufcfAbr: result:='M2I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M2I)';
            end;
         end;
         cM3:
         begin
            case SGCformat of
               ufcfRaw: result:='cM3';
               ufcfAbr: result:='M3I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M3I)';
            end;
         end;
         cM4:
         begin
            case SGCformat of
               ufcfRaw: result:='cM4';
               ufcfAbr: result:='M4I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M4I)';
            end;
         end;
         cM5:
         begin
            case SGCformat of
               ufcfRaw: result:='cM5';
               ufcfAbr: result:='M5I';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M5I)';
            end;
         end;
         gF0:
         begin
            case SGCformat of
               ufcfRaw: result:='gF0';
               ufcfAbr: result:='F0III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F0III)';
            end;
         end;
         gF1:
         begin
            case SGCformat of
               ufcfRaw: result:='gF1';
               ufcfAbr: result:='F1III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F1III)';
            end;
         end;
         gF2:
         begin
            case SGCformat of
               ufcfRaw: result:='gF2';
               ufcfAbr: result:='F2III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F2III)';
            end;
         end;
         gF3:
         begin
            case SGCformat of
               ufcfRaw: result:='gF3';
               ufcfAbr: result:='F3III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F3III)';
            end;
         end;
         gF4:
         begin
            case SGCformat of
               ufcfRaw: result:='gF4';
               ufcfAbr: result:='F4III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F4III)';
            end;
         end;
         gF5:
         begin
            case SGCformat of
               ufcfRaw: result:='gF5';
               ufcfAbr: result:='F5III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F5III)';
            end;
         end;
         gF6:
         begin
            case SGCformat of
               ufcfRaw: result:='gF6';
               ufcfAbr: result:='F6III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F6III)';
            end;
         end;
         gF7:
         begin
            case SGCformat of
               ufcfRaw: result:='gF7';
               ufcfAbr: result:='F7III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F7III)';
            end;
         end;
         gF8:
         begin
            case SGCformat of
               ufcfRaw: result:='gF8';
               ufcfAbr: result:='F8III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F8III)';
            end;
         end;
         gF9:
         begin
            case SGCformat of
               ufcfRaw: result:='gF9';
               ufcfAbr: result:='F9III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F9III)';
            end;
         end;
         gG0:
         begin
            case SGCformat of
               ufcfRaw: result:='gG0';
               ufcfAbr: result:='G0III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G0III)';
            end;
         end;
         gG1:
         begin
            case SGCformat of
               ufcfRaw: result:='gG1';
               ufcfAbr: result:='G1III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G1III)';
            end;
         end;
         gG2:
         begin
            case SGCformat of
               ufcfRaw: result:='gG2';
               ufcfAbr: result:='G2III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G2III)';
            end;
         end;
         gG3:
         begin
            case SGCformat of
               ufcfRaw: result:='gG3';
               ufcfAbr: result:='G3III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G3III)';
            end;
         end;
         gG4:
         begin
            case SGCformat of
               ufcfRaw: result:='gG4';
               ufcfAbr: result:='G4III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G4III)';
            end;
         end;
         gG5:
         begin
            case SGCformat of
               ufcfRaw: result:='gG5';
               ufcfAbr: result:='G5III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G5III)';
            end;
         end;
         gG6:
         begin
            case SGCformat of
               ufcfRaw: result:='gG6';
               ufcfAbr: result:='G6III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G6III)';
            end;
         end;
         gG7:
         begin
            case SGCformat of
               ufcfRaw: result:='gG7';
               ufcfAbr: result:='G7III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G7III)';
            end;
         end;
         gG8:
         begin
            case SGCformat of
               ufcfRaw: result:='gG8';
               ufcfAbr: result:='G8III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G8III)';
            end;
         end;
         gG9:
         begin
            case SGCformat of
               ufcfRaw: result:='gG9';
               ufcfAbr: result:='G9III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G9III)';
            end;
         end;
         gK0:
         begin
            case SGCformat of
               ufcfRaw: result:='gK0';
               ufcfAbr: result:='K0III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K0III)';
            end;
         end;
         gK1:
         begin
            case SGCformat of
               ufcfRaw: result:='gK1';
               ufcfAbr: result:='K1III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K1III)';
            end;
         end;
         gK2:
         begin
            case SGCformat of
               ufcfRaw: result:='gK2';
               ufcfAbr: result:='K2III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K2III)';
            end;
         end;
         gK3:
         begin
            case SGCformat of
               ufcfRaw: result:='gK3';
               ufcfAbr: result:='K3III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K3III)';
            end;
         end;
         gK4:
         begin
            case SGCformat of
               ufcfRaw: result:='gK4';
               ufcfAbr: result:='K4III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K4III)';
            end;
         end;
         gK5:
         begin
            case SGCformat of
               ufcfRaw: result:='gK5';
               ufcfAbr: result:='K5III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K5III)';
            end;
         end;
         gK6:
         begin
            case SGCformat of
               ufcfRaw: result:='gK6';
               ufcfAbr: result:='K6III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K6III)';
            end;
         end;
         gK7:
         begin
            case SGCformat of
               ufcfRaw: result:='gK7';
               ufcfAbr: result:='K7III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K7III)';
            end;
         end;
         gK8:
         begin
            case SGCformat of
               ufcfRaw: result:='gK8';
               ufcfAbr: result:='K8III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K8III)';
            end;
         end;
         gK9:
         begin
            case SGCformat of
               ufcfRaw: result:='gK9';
               ufcfAbr: result:='K9III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K9III)';
            end;
         end;
         gM0:
         begin
            case SGCformat of
               ufcfRaw: result:='gM0';
               ufcfAbr: result:='M0III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M0III)';
            end;
         end;
         gM1:
         begin
            case SGCformat of
               ufcfRaw: result:='gM1';
               ufcfAbr: result:='M1III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M1III)';
            end;
         end;
         gM2:
         begin
            case SGCformat of
               ufcfRaw: result:='gM2';
               ufcfAbr: result:='M2III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M2III)';
            end;
         end;
         gM3:
         begin
            case SGCformat of
               ufcfRaw: result:='gM3';
               ufcfAbr: result:='M3III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M3III)';
            end;
         end;
         gM4:
         begin
            case SGCformat of
               ufcfRaw: result:='gM4';
               ufcfAbr: result:='M4III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M4III)';
            end;
         end;
         gM5:
         begin
            case SGCformat of
               ufcfRaw: result:='gM5';
               ufcfAbr: result:='M5III';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M5III)';
            end;
         end;
         O5:
         begin
            case SGCformat of
               ufcfRaw: result:='O5';
               ufcfAbr: result:='O5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O5V)';
            end;
         end;
         O6:
         begin
            case SGCformat of
               ufcfRaw: result:='O6';
               ufcfAbr: result:='O6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O6V)';
            end;
         end;
         O7:
         begin
            case SGCformat of
               ufcfRaw: result:='O7';
               ufcfAbr: result:='O7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O7V)';
            end;
         end;
         O8:
         begin
            case SGCformat of
               ufcfRaw: result:='O8';
               ufcfAbr: result:='O8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O8V)';
            end;
         end;
         O9:
         begin
            case SGCformat of
               ufcfRaw: result:='O9';
               ufcfAbr: result:='O9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O9V)';
            end;
         end;
         B0:
         begin
            case SGCformat of
               ufcfRaw: result:='B0';
               ufcfAbr: result:='B0V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B0V)';
            end;
         end;
         B1:
         begin
            case SGCformat of
               ufcfRaw: result:='B1';
               ufcfAbr: result:='B1V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B1V)';
            end;
         end;
         B2:
         begin
            case SGCformat of
               ufcfRaw: result:='B2';
               ufcfAbr: result:='B2V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B2V)';
            end;
         end;
         B3:
         begin
            case SGCformat of
               ufcfRaw: result:='B3';
               ufcfAbr: result:='B3V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B3V)';
            end;
         end;
         B4:
         begin
            case SGCformat of
               ufcfRaw: result:='B4';
               ufcfAbr: result:='B4V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B4V)';
            end;
         end;
         B5:
         begin
            case SGCformat of
               ufcfRaw: result:='B5';
               ufcfAbr: result:='B5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B5V)';
            end;
         end;
         B6:
         begin
            case SGCformat of
               ufcfRaw: result:='B6';
               ufcfAbr: result:='B6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B6V)';
            end;
         end;
         B7:
         begin
            case SGCformat of
               ufcfRaw: result:='B7';
               ufcfAbr: result:='B7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B7V)';
            end;
         end;
         B8:
         begin
            case SGCformat of
               ufcfRaw: result:='B8';
               ufcfAbr: result:='B8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B8V)';
            end;
         end;
         B9:
         begin
            case SGCformat of
               ufcfRaw: result:='B9';
               ufcfAbr: result:='B9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B9V)';
            end;
         end;
         A0:
         begin
            case SGCformat of
               ufcfRaw: result:='A0';
               ufcfAbr: result:='A0V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A0V)';
            end;
         end;
         A1:
         begin
            case SGCformat of
               ufcfRaw: result:='A1';
               ufcfAbr: result:='A1V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A1V)';
            end;
         end;
         A2:
         begin
            case SGCformat of
               ufcfRaw: result:='A2';
               ufcfAbr: result:='A2V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A2V)';
            end;
         end;
         A3:
         begin
            case SGCformat of
               ufcfRaw: result:='A3';
               ufcfAbr: result:='A3V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A3V)';
            end;
         end;
         A4:
         begin
            case SGCformat of
               ufcfRaw: result:='A4';
               ufcfAbr: result:='A4V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A4V)';
            end;
         end;
         A5:
         begin
            case SGCformat of
               ufcfRaw: result:='A5';
               ufcfAbr: result:='A5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A5V)';
            end;
         end;
         A6:
         begin
            case SGCformat of
               ufcfRaw: result:='A6';
               ufcfAbr: result:='A6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A6V)';
            end;
         end;
         A7:
         begin
            case SGCformat of
               ufcfRaw: result:='A7';
               ufcfAbr: result:='A7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A7V)';
            end;
         end;
         A8:
         begin
            case SGCformat of
               ufcfRaw: result:='A8';
               ufcfAbr: result:='A8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A8V)';
            end;
         end;
         A9:
         begin
            case SGCformat of
               ufcfRaw: result:='A9';
               ufcfAbr: result:='A9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A9V)';
            end;
         end;
         F0:
         begin
            case SGCformat of
               ufcfRaw: result:='F0';
               ufcfAbr: result:='F0V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F0V)';
            end;
         end;
         F1:
         begin
            case SGCformat of
               ufcfRaw: result:='F1';
               ufcfAbr: result:='F1V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F1V)';
            end;
         end;
         F2:
         begin
            case SGCformat of
               ufcfRaw: result:='F2';
               ufcfAbr: result:='F2V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F2V)';
            end;
         end;
         F3:
         begin
            case SGCformat of
               ufcfRaw: result:='F3';
               ufcfAbr: result:='F3V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F3V)';
            end;
         end;
         F4:
         begin
            case SGCformat of
               ufcfRaw: result:='F4';
               ufcfAbr: result:='F4V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F4V)';
            end;
         end;
         F5:
         begin
            case SGCformat of
               ufcfRaw: result:='F5';
               ufcfAbr: result:='F5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F5V)';
            end;
         end;
         F6:
         begin
            case SGCformat of
               ufcfRaw: result:='F6';
               ufcfAbr: result:='F6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F6V)';
            end;
         end;
         F7:
         begin
            case SGCformat of
               ufcfRaw: result:='F7';
               ufcfAbr: result:='F7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F7V)';
            end;
         end;
         F8:
         begin
            case SGCformat of
               ufcfRaw: result:='F8';
               ufcfAbr: result:='F8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F8V)';
            end;
         end;
         F9:
         begin
            case SGCformat of
               ufcfRaw: result:='F9';
               ufcfAbr: result:='F9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F9V)';
            end;
         end;
         G0:
         begin
            case SGCformat of
               ufcfRaw: result:='G0';
               ufcfAbr: result:='G0V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G0V)';
            end;
         end;
         G1:
         begin
            case SGCformat of
               ufcfRaw: result:='G1';
               ufcfAbr: result:='G1V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G1V)';
            end;
         end;
         G2:
         begin
            case SGCformat of
               ufcfRaw: result:='G2';
               ufcfAbr: result:='G2V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G2V)';
            end;
         end;
         G3:
         begin
            case SGCformat of
               ufcfRaw: result:='G3';
               ufcfAbr: result:='G3V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G3V)';
            end;
         end;
         G4:
         begin
            case SGCformat of
               ufcfRaw: result:='G4';
               ufcfAbr: result:='G4V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G4V)';
            end;
         end;
         G5:
         begin
            case SGCformat of
               ufcfRaw: result:='G5';
               ufcfAbr: result:='G5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G5V)';
            end;
         end;
         G6:
         begin
            case SGCformat of
               ufcfRaw: result:='G6';
               ufcfAbr: result:='G6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G6V)';
            end;
         end;
         G7:
         begin
            case SGCformat of
               ufcfRaw: result:='G7';
               ufcfAbr: result:='G7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G7V)';
            end;
         end;
         G8:
         begin
            case SGCformat of
               ufcfRaw: result:='G8';
               ufcfAbr: result:='G8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G8V)';
            end;
         end;
         G9:
         begin
            case SGCformat of
               ufcfRaw: result:='G9';
               ufcfAbr: result:='G9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G9V)';
            end;
         end;
         K0:
         begin
            case SGCformat of
               ufcfRaw: result:='K0';
               ufcfAbr: result:='K0V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K0V)';
            end;
         end;
         K1:
         begin
            case SGCformat of
               ufcfRaw: result:='K1';
               ufcfAbr: result:='K1V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K1V)';
            end;
         end;
         K2:
         begin
            case SGCformat of
               ufcfRaw: result:='K2';
               ufcfAbr: result:='K2V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K2V)';
            end;
         end;
         K3:
         begin
            case SGCformat of
               ufcfRaw: result:='K3';
               ufcfAbr: result:='K3V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K3V)';
            end;
         end;
         K4:
         begin
            case SGCformat of
               ufcfRaw: result:='K4';
               ufcfAbr: result:='K4V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K4V)';
            end;
         end;
         K5:
         begin
            case SGCformat of
               ufcfRaw: result:='K5';
               ufcfAbr: result:='K5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K5V)';
            end;
         end;
         K6:
         begin
            case SGCformat of
               ufcfRaw: result:='K6';
               ufcfAbr: result:='K6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K6V)';
            end;
         end;
         K7:
         begin
            case SGCformat of
               ufcfRaw: result:='K7';
               ufcfAbr: result:='K7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K7V)';
            end;
         end;
         K8:
         begin
            case SGCformat of
               ufcfRaw: result:='K8';
               ufcfAbr: result:='K8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K8V)';
            end;
         end;
         K9:
         begin
            case SGCformat of
               ufcfRaw: result:='K9';
               ufcfAbr: result:='K9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K9V)';
            end;
         end;
         M0:
         begin
            case SGCformat of
               ufcfRaw: result:='M0';
               ufcfAbr: result:='M0V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M0V)';
            end;
         end;
         M1:
         begin
            case SGCformat of
               ufcfRaw: result:='M1';
               ufcfAbr: result:='M1V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M1V)';
            end;
         end;
         M2:
         begin
            case SGCformat of
               ufcfRaw: result:='M2';
               ufcfAbr: result:='M2V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M2V)';
            end;
         end;
         M3:
         begin
            case SGCformat of
               ufcfRaw: result:='M3';
               ufcfAbr: result:='M3V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M3V)';
            end;
         end;
         M4:
         begin
            case SGCformat of
               ufcfRaw: result:='M4';
               ufcfAbr: result:='M4V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M4V)';
            end;
         end;
         M5:
         begin
            case SGCformat of
               ufcfRaw: result:='M5';
               ufcfAbr: result:='M5V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M5V)';
            end;
         end;
         M6:
         begin
            case SGCformat of
               ufcfRaw: result:='M6';
               ufcfAbr: result:='M6V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M6V)';
            end;
         end;
         M7:
         begin
            case SGCformat of
               ufcfRaw: result:='M7';
               ufcfAbr: result:='M7V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M7V)';
            end;
         end;
         M8:
         begin
            case SGCformat of
               ufcfRaw: result:='M8';
               ufcfAbr: result:='M8V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M8V)';
            end;
         end;
         M9:
         begin
            case SGCformat of
               ufcfRaw: result:='M9';
               ufcfAbr: result:='M9V';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M9V)';
            end;
         end;
         WD0:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD0';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD0)';
            end;
         end;
         WD1:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD1';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD1)';
            end;
         end;
         WD2:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD2';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD2)';
            end;
         end;
         WD3:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD3';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD3)';
            end;
         end;
         WD4:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD4';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD4)';
            end;
         end;
         WD5:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD5';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD5)';
            end;
         end;
         WD6:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD6';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD6)';
            end;
         end;
         WD7:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD7';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD7)';
            end;
         end;
         WD8:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD8';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD8)';
            end;
         end;
         WD9:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='WD8';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD9)';
            end;
         end;
         PSR:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='PSR';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclPSR')+' (PSR)';
            end;
         end;
         BH:
         begin
            case SGCformat of
               ufcfRaw, ufcfAbr: result:='BH';
               ufcfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclBH')+' (BH)';
            end;
         end;
      end; {.case SDB_class}
   end; {.with FCDBstarSys[SGCstsIdx].SS_star[SGCstIdx]}
end;

function FCFcFunc_ThSep(
   const TSval: integer;
   const TSchr: Char
   ): string; overload;
{:Purpose: format the value in a thousand separator format.
    Additions:
      -2011Jul24- *rem: remove the fix since this routine is for integer values.
      -2011Jul20- *fix: avoid to put a TSchr just before a decimal separation or ".".
}
var
   TSlen: Integer;
   TSstr: string;
begin
   TSstr:=IntToStr(TSval);
   Result:=TSstr;
   TSlen:=Length(TSstr)-2;
   while TSlen > 1 do
   begin
      Insert(
         TSchr
         ,Result
         ,TSlen
         );
      TSlen:=TSlen - 3;
   end;
end;

function FCFcFunc_ThSep( const TSval: integer ): string; overload;
{:Purpose: format the value in a thousand separator format.
    Additions:
}
begin
   Result:=FCFcFunc_ThSep( TSval, ',' );
end;

function FCFcFunc_ThSep(
   const TSval: extended;
   const TSchr: Char
   ): string; overload;
{:Purpose: format the value in a thousand separator format.
    Additions:
      -2011Jul24- *fix: full complete fix, allow any decimal and even non decimal float values.
      -2011Jul20- *fix: avoid to put a TSchr just before a decimal separation or ".".
}
var
   TSdecimalAt
   ,TSlen: Integer;

   TSstr
   ,TSnext: string;
begin
   TSstr:=FloatToStr(TSval);
   Result:=TSstr;
   TSdecimalAt:=Length(TSstr);
   while TSdecimalAt>1 do
   begin
      TSnext:=Copy(
         Result
         ,TSdecimalAt
         ,1
         );
      if (TSnext<>'.')
         and (TSdecimalAt>2)
      then TSdecimalAt:=TSdecimalAt-1
      else if (TSnext<>'.')
         and (TSdecimalAt<3)
      then TSdecimalAt:=0
      else if TSnext='.'
      then break;
   end;
   if TSdecimalAt=0
   then TSlen:=Length(TSstr)-2
   else if TSdecimalAt>0
   then TSlen:=TSdecimalAt-3;
   while TSlen>1 do
   begin
       Insert(
         TSchr
         ,Result
         ,TSlen
         );
      TSlen:=TSlen-3;
   end;
end;

function FCFcFunc_ThSep( const TSval: extended ): string; overload;
{:Purpose: format the value in a thousand separator format.
    Additions:
}
{:DEV NOTES: put this one at the right place, above.}
begin
   Result:=FCFcFunc_ThSep( TSval, ',' );
end;

function FCFcF_Time_GetDate(
   const TGDday
         ,TGDmth
         ,TGDyr: integer
   ): string;
{:Purpose: transform time values in readable date.
    Additions:
      -2012Jan29- *add: Spanish language.
}
var
   TGD1st: string;
begin
   TGD1st:='';
   if TGDday=1
   then TGD1st:=FCFdTFiles_UIStr_Get(uistrUI, 'TimeF1st');
   if FCVdiLanguage='EN'
   then
   begin
      Result:=FCFdTFiles_UIStr_Get(uistrUI, 'TimeFM'+IntToStr(TGDmth))
         +' '+IntToStr(TGDday)+TGD1st
         +' '+IntToStr(TGDyr);
   end
   else if FCVdiLanguage='FR'
   then
   begin
      Result:=IntToStr(TGDday)+TGD1st
         +' '+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFM'+IntToStr(TGDmth))
         +' '+IntToStr(TGDyr);
   end
   else if FCVdiLanguage='SP'
   then
   begin
      Result:=IntToStr(TGDday)+TGD1st
         +' '+FCFdTFiles_UIStr_Get(uistrUI, 'TimeFM'+IntToStr(TGDmth))
         +' '+IntToStr(TGDyr);
   end;
end;

function FCFcFunc_TimeTick_GetDate(const TTGDtick: extended): string;
{:Purpose: transform time ticks in readable date.
    Additions:
}
var
   TTGDdays,
   TTGDhrs,
   TTGDmin: extended;
   TTGDdaysFinal,
   TTGDhrsFinal,
   TTGDminFinal: integer;
begin
   TTGDdays:=TTGDtick/144;
   TTGDdaysFinal:=round(int(TTGDdays));
   TTGDhrs:=frac(TTGDdays)*24;
   TTGDhrsFinal:=round(int(TTGDhrs));
   TTGDmin:=frac(TTGDhrs)*6;
   TTGDminFinal:=round(TTGDmin)*10;
   Result
      :=IntToStr(TTGDdaysFinal)+' '+FCFdTFiles_UIStr_Get(uistrUI,'TimeFstdD')+' '+IntToStr(TTGDhrsFinal)+' hr '
         +IntToStr(TTGDminFinal)+' mn';
end;

function FCFcFunc_WinFolders_GetAction(
   const WFGAcsidl: integer;
   const WFGAforcefolder: boolean=false
   ): string;
{.Purpose: get the folder path of several kind of folders. The code is directly taken from
a CodeGear pdf file named "VistaUACandDelphi.pdf" written by Fredrik Haglund. No need to
re-invente the wheel :)
}
var WFGAstack: integer;
begin
   SetLength(Result, 255);
   if WFGAforcefolder
   then SHGetFolderPath(
      0
      ,WFGAcsidl or CSIDL_FLAG_CREATE
      ,0
      ,0
      ,PChar(Result)
      )
   else SHGetFolderPath(
      0
      ,WFGAcsidl
      ,0
      ,0
      ,PChar(Result)
      );
   WFGAstack:=pos(#0, Result);
   if WFGAstack>0
   then SetLength(Result, Pred(WFGAstack));
end;

function FCFcFunc_WinFolders_GetMyDocs(const WFGMDforcefolder: boolean=false): string;
{.Purpose: get the folder path of My Documents folders The code is directly taken from a
CodeGear pdf file named "VistaUACandDelphi.pdf" written by Fredrik Haglund. No need to
re-invente the wheel :)
   DEV NOTES:
      CSIDL_PERSONAL: My Documents
      CSDIL_APPDATA:  Application Data
      CSDIL_LOCAL_APPDATA: non roaming, user/local settings/application data
      CSDIL_COMMON_APPDATA:   all users/application data
      CSDIL_MYPICTURES: My Pictures
      CSDIL_COMMON_DOCUMENTS: all users/documents
      and so on :)
      CSIDL_APPDATA = données à porté utilisateur uniquement
      CSIDL_COMMON_APPDATA = données à porté machine
      CSIDL_LOCAL_APPDATA = données à porté utilisateur-machine: à la différence de CSIDL_APPDATA les
      données sont spécifiques à l'utilisateur sur cette machine (dans le cas d'un active directory avec
      informations du profile sauvegardé sur le réseau, par exemple, les données CSIDL_LOCAL_APPDATA ne sont
      pas dupliquées sur le réseau)
   Additions:
}
var
   FGMDresult: string;
begin
   FGMDresult:=FCFcFunc_WinFolders_GetAction(CSIDL_PERSONAL, WFGMDforcefolder);
   if not DirectoryExists(FGMDresult+'\farcolony')
   then MkDir(FGMDresult+'\farcolony');
   Result:=FGMDresult+'\farcolony\';
end;

procedure FCMcF_Files_Del(const FDpath, FDname: string);
{:Purpose: delete w/ wildcards support. From Ion_T@DelphiPages.com.
    Additions:
}
var FDsrec: TSearchRec;
begin
   if SysUtils.FindFirst(FDpath+FDname, faAnyFile, FDsrec)=0
   then
   begin
      DeleteFile(pchar(FDpath+FDsrec.Name));
      while FindNext(FDsrec)=0
      do DeleteFile(pchar(FDpath+FDsrec.Name));
      SysUtils.FindClose(FDsrec);
   end;

end;

end.

