{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: common functions & procedures - core unit

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

   ,DecimalRounding_JH1;

type TFCEcfConversions=(
   cMetersToSpaceUnitSize
   ,cKmTo3dViewUnits
   ,c3dViewUnitsToKm
   ,cAU_to3dViewUnits
   ,c3dViewUnitsToAU
   ,cAsteroidDiameterKmTo3dViewUnits
   ,cVelocityKmSecTo3dViewUnits
   ,cMinutesToGameTicks
   );

type TFCEcfRoundToTypes=(
   rtt3dposition
   ,rttCustom1Decimal
   ,rttCustom2Decimal
   ,rttCustom3Decimal
   ,rttDistanceKm
   ,rttVelocityKmSec
   ,rttSizeInMeters
   ,rttVolume
   ,rttSurface
   ,rttMassAsteroid
   ,rttMasstons
   ,rttPowerKw
   );

type TFCEufClassDisplayForms=(
   cdfRaw
   ,cdfAbr
   ,cdfFull
   );

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

///<summary>
///   return the version of Far Colony. This code come from Alexandre of the
///   www.developpez.com website, is not my proper code. 
///</summary>
function FCFcF_FARCVersion_Get: string;

///<summary>
///   protect the ln() function with value <= 0
///</summary>
///   <param name="Value">value to apply the ln() to</param>
///   <returns>result of the logarithm or 0</returns>
function FCFcF_Ln_Protected( const Value: extended): extended;

///<summary>
///   "real" random function including a randomize each time
///</summary>
///   <returns>the randomized float</returns>
function FCFcF_Random_DoFloat: extended;

///<summary>
///   "real" random function including a randomize each time
///</summary>
///   <param name="Range">range integer for the random processing</param>
///   <returns>the randomized integer included in the range</returns>
function FCFcF_Random_DoInteger(const Range: integer): integer;

///<summary>
///   "real" randg function including a randomize each time
///</summary>
///   <param name="Mean">mean value</param>
///   <param name="StdDev">coef</param>
///   <returns>the randomized float</returns>
function FCFcF_Rand_G( const Mean, StdDev: extended ): extended;

///<summary>
///   round the target value according to the value type
///</summary>
///   <param name="RoundType">kind of rounding</param>
///   <param name="Value">value to round</param>
///   <returns>the rounded value</returns>
function FCFcF_Round(
   const RoundType: TFCEcfRoundToTypes;
   const Value: extended
   ): extended;

///<summary>
///   centralized conversion function
///</summary>
///   <param name="Conversion">kind conversion</param>
///   <param name="Value">value to convert</param>
///   <returns>the converted value</returns>
function FCFcF_Scale_Conversion(
   const Conversion: TFCEcfConversions;
   const Value: extended
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
   const SGCformat: TFCEufClassDisplayForms;
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

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   delete w/ wildcards support. From Ion_T@DelphiPages.com
///</summary>
///<param name="FDpath">path must have the last "/"</param>
///<param name="FDname">filename w/ wildcards</param>
procedure FCMcF_Files_Del(const FDpath, FDname: string);

implementation

uses
   farc_data_init
   ,farc_data_game
   ,farc_data_spu
   ,farc_data_textfiles
   ,farc_data_univ
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================

function FCFcF_FARCVersion_Get: string;
{:Purpose: return the version of FAR Colony. This code come from Alexandre of the
    www.developpez.com website, is not my proper code.
   Additions:
      -2012Dec09- *code audit:
                     (x)var formatting + refactoring     (_)if..then reformatting   (x)function/procedure refactoring
                     (_)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
                  *mod: update according to the last planned roadmap.
      -2012May27- *add: take into account of the alpha #.
}
   var
      Dummy
      ,VersionInfoSize
      ,VersionValueSize: DWord;

      VersionInfo: Pointer;

      VersionValue: PVSFixedFileInfo;
begin
   VersionInfoSize:=GetFileVersionInfoSize( PChar( ParamStr( 0 ) ), Dummy );
   If VersionInfoSize<>0 then
   begin
      GetMem( VersionInfo, VersionInfoSize );
      GetFileVersionInfo( PChar( ParamStr( 0 ) ), 0, VersionInfoSize, VersionInfo );
      VerQueryValue( VersionInfo, '\', Pointer( VersionValue ), VersionValueSize );
      if ( ( VersionValue^.dwFileVersionMS shr 16 )=0 )
      then Result:='Alpha '+FCCdiAlphaNumber+' '
      else if ( ( VersionValue^.dwFileVersionMS shr 16 )=1 )
        and ( ( VersionValue^.dwFileVersionMS and $FFFF )=0 )
      then Result:=Result+'Beta'
      else Result:=Result+'Final';
      Result:=Result+'['+IntTostr( VersionValue^.dwFileVersionMS shr 16 );//0
      Result:=Result+'.'+IntTostr( VersionValue^.dwFileVersionMS and $FFFF );//.4
      Result:=Result+'.'+IntTostr( VersionValue^.dwFileVersionLS shr 16 );//.0
      Result:=Result+'.'+IntTostr( VersionValue^.dwFileVersionLS and $FFFF )+']';//.177
      FreeMem( VersionInfo, VersionInfoSize );
   end
   else Result:='Unknown Version';
end;

function FCFcF_Ln_Protected( const Value: extended): extended;
{:Purpose: protect the ln() function with value <= 0.
    Additions:
      -2012Dec09- *code audit:
                     (_)var formatting + refactoring     (-)if..then reformatting   (_)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
}
begin
   Result:=Value;
   if Value>0
   then Result:=ln( Value );
end;

function FCFcF_Random_DoFloat: extended;
{:Purpose: "real" random function including a randomize each time.
    Additions:
}
begin
   Result:=0;
   Randomize;
   Result:=random;
end;

function FCFcF_Random_DoInteger(const Range: integer): integer;
{:Purpose: "real" random function including a randomize each time.
    Additions:
      -2012Dec09- *code audit:
                     (_)var formatting + refactoring     (_)if..then reformatting   (x)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (_)code optimizations
                     (_)float local variables=> extended (_)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
}
begin
   Result:=0;
   Randomize;
   Result:=random( Range );
end;

function FCFcF_Rand_G( const Mean, StdDev: extended ): extended;
{:Purpose: "real" randg function including a randomize each time.
    Additions:
}
{ Marsaglia-Bray algorithm }
var
  U1, S2: Extended;
begin
   Result:=0;
   repeat
    U1 := 2*FCFcF_Random_DoFloat - 1;
    S2 := Sqr(U1) + Sqr(2*FCFcF_Random_DoFloat-1);
   until S2 < 1;
   Result := Sqrt(-2*Ln(S2)/S2) * U1 * StdDev + Mean;
end;

function FCFcF_Round(
   const RoundType: TFCEcfRoundToTypes;
   const Value: extended
   ): extended;
{:Purpose: round the target value according to the value type.
    Additions:
      -2012Dec09- *code audit:
                     (_)var formatting + refactoring     (_)if..then reformatting   (o)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (-)code optimizations
                     (_)float local variables=> extended (x)case..of reformatting   (-)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
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
   Result:=0;
   case RoundType of
      rtt3dposition: result:=DecimalRound( Value, 9, 0.00000000001 );

		rttCustom1Decimal: result:=DecimalRound( Value, 1, 0.001 );

      rttCustom2Decimal: result:=DecimalRound( Value, 2, 0.0001 );

      rttCustom3Decimal: result:=DecimalRound( Value, 3, 0.00001 );

      rttDistanceKm: result:=DecimalRound( Value, 2, 0.0001 );

      rttVelocityKmSec: result:=DecimalRound( Value, 2, 0.0001 );

      rttSizeInMeters: result:=DecimalRound( Value, 1, 0.001 );

      rttVolume: result:=DecimalRound( Value, 3, 0.00001 );

      rttSurface: result:=DecimalRound( Value, 2, 0.0001 );

      rttMassAsteroid: result:=DecimalRound( Value, 6, 0.00000001 );

      rttMasstons: result:=DecimalRound( Value, 3, 0.00001 );

      rttPowerKw: result:=DecimalRound( Value, 2, 0.0001 );
   end;
end;

function FCFcF_Scale_Conversion(
   const Conversion: TFCEcfConversions;
   const Value: extended
   ): extended;
{:Purpose: centralized conversion function.
    Additions:
      -2012Dec09- *code audit:
                     (x)var formatting + refactoring     (_)if..then reformatting   (x)function/procedure refactoring
                     (x)parameters refactoring           (x) ()reformatting         (x)code optimizations
                     (_)float local variables=> extended (x)case..of reformatting   (_)local methods
                     (x)summary completion               (_)protect all float add/sub w/ FCFcFunc_Rnd
                     (_)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (_)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (_)use of enumindex                 (_)use of StrToFloat( x, FCVdiFormat ) for all float data w/ XML
                     (_)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2012Oct28- *add: cf3dctKmTo3dViewUnit - round correctly the result.
      -2012Oct21- *add: cf3dctAUto3dViewUnit - round correctly the result.
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
      Calculations: extended;
begin
   Calculations:=0;
   Result:=0;
   case Conversion of
      cMetersToSpaceUnitSize:
      begin
         Calculations:=( FCDdsuSpaceUnitDesigns[round( Value )].SUD_internalStructureClone.IS_length*0.02 )/CFC3dUnInKm;
         Result:=FCFcF_Round( rtt3dposition, Calculations );
      end;

      cKmTo3dViewUnits:
      begin
         Calculations:=Value/CFC3dUnInKm;
         Result:=FCFcF_Round( rtt3dposition, Calculations );
      end;

      cAU_to3dViewUnits:
      begin
         Calculations:=Value*CFC3dUnInAU;
         Result:=FCFcF_Round( rtt3dposition, Calculations );
      end;

      c3dViewUnitsToKm:
      begin
         Calculations:=Value*CFC3dUnInKm;
         Result:=FCFcF_Round( rttDistanceKm, Calculations );
      end;

      c3dViewUnitsToAU:
      begin
         Calculations:=Value/CFC3dUnInAU;
         Result:=FCFcF_Round( rttDistanceKm, Calculations );
      end;

      cAsteroidDiameterKmTo3dViewUnits:
      begin
         Calculations:=Value/(CFC3dAstConv);
         Result:=FCFcF_Round( rtt3dposition, Calculations );
      end;

      cMinutesToGameTicks: Calculations:=round( Value*0.1 );

      cVelocityKmSecTo3dViewUnits:
      begin
         Calculations:=( ( Value*600 )/CFC3dUnInKm );
         Result:=FCFcF_Round( rtt3dposition, Calculations );
      end;
   end;

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
{:DEV NOTES: PUT THAT IN farc_spu_functions.}
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
   const SGCformat: TFCEufClassDisplayForms;
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
               cdfRaw: result:='cB5';
               cdfAbr: result:='B5I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B5I)';
            end;
         end;
         cB6:
         begin
            case SGCformat of
               cdfRaw: result:='cB6';
               cdfAbr: result:='B6I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B6I)';
            end;
         end;
         cB7:
         begin
            case SGCformat of
               cdfRaw: result:='cB7';
               cdfAbr: result:='B7I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B7I)';
            end;
         end;
         cB8:
         begin
            case SGCformat of
               cdfRaw: result:='cB8';
               cdfAbr: result:='B8I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B8I)';
            end;
         end;
         cB9:
         begin
            case SGCformat of
               cdfRaw: result:='cB9';
               cdfAbr: result:='B9I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCB')+' (B9I)';
            end;
         end;
         cA0:
         begin
            case SGCformat of
               cdfRaw: result:='cA0';
               cdfAbr: result:='A0I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A0I)';
            end;
         end;
         cA1:
         begin
            case SGCformat of
               cdfRaw: result:='cA1';
               cdfAbr: result:='A1I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A1I)';
            end;
         end;
         cA2:
         begin
            case SGCformat of
               cdfRaw: result:='cA2';
               cdfAbr: result:='A2I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A2I)';
            end;
         end;
         cA3:
         begin
            case SGCformat of
               cdfRaw: result:='cA3';
               cdfAbr: result:='A3I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A3I)';
            end;
         end;
         cA4:
         begin
            case SGCformat of
               cdfRaw: result:='cA4';
               cdfAbr: result:='A4I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A4I)';
            end;
         end;
         cA5:
         begin
            case SGCformat of
               cdfRaw: result:='cA5';
               cdfAbr: result:='A5I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A5I)';
            end;
         end;
         cA6:
         begin
            case SGCformat of
               cdfRaw: result:='cA6';
               cdfAbr: result:='A6I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A6I)';
            end;
         end;
         cA7:
         begin
            case SGCformat of
               cdfRaw: result:='cA7';
               cdfAbr: result:='A7I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A7I)';
            end;
         end;
         cA8:
         begin
            case SGCformat of
               cdfRaw: result:='cA8';
               cdfAbr: result:='A8I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A8I)';
            end;
         end;
         cA9:
         begin
            case SGCformat of
               cdfRaw: result:='cA9';
               cdfAbr: result:='A9I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCA')+' (A9I)';
            end;
         end;
         cK0:
         begin
            case SGCformat of
               cdfRaw: result:='cK0';
               cdfAbr: result:='K0I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K0I)';
            end;
         end;
         cK1:
         begin
            case SGCformat of
               cdfRaw: result:='cK1';
               cdfAbr: result:='K1I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K1I)';
            end;
         end;
         cK2:
         begin
            case SGCformat of
               cdfRaw: result:='cK2';
               cdfAbr: result:='K2I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K2I)';
            end;
         end;
         cK3:
         begin
            case SGCformat of
               cdfRaw: result:='cK3';
               cdfAbr: result:='K3I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K3I)';
            end;
         end;
         cK4:
         begin
            case SGCformat of
               cdfRaw: result:='cK4';
               cdfAbr: result:='K4I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K4I)';
            end;
         end;
         cK5:
         begin
            case SGCformat of
               cdfRaw: result:='cK5';
               cdfAbr: result:='K5I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K5I)';
            end;
         end;
         cK6:
         begin
            case SGCformat of
               cdfRaw: result:='cK6';
               cdfAbr: result:='K6I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K6I)';
            end;
         end;
         cK7:
         begin
            case SGCformat of
               cdfRaw: result:='cK7';
               cdfAbr: result:='K7I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K7I)';
            end;
         end;
         cK8:
         begin
            case SGCformat of
               cdfRaw: result:='cK8';
               cdfAbr: result:='K8I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K8I)';
            end;
         end;
         cK9:
         begin
            case SGCformat of
               cdfRaw: result:='cK9';
               cdfAbr: result:='K9I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCK')+' (K9I)';
            end;
         end;
         cM0:
         begin
            case SGCformat of
               cdfRaw: result:='cM0';
               cdfAbr: result:='M0I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M0I)';
            end;
         end;
         cM1:
         begin
            case SGCformat of
               cdfRaw: result:='cM1';
               cdfAbr: result:='M1I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M1I)';
            end;
         end;
         cM2:
         begin
            case SGCformat of
               cdfRaw: result:='cM2';
               cdfAbr: result:='M2I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M2I)';
            end;
         end;
         cM3:
         begin
            case SGCformat of
               cdfRaw: result:='cM3';
               cdfAbr: result:='M3I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M3I)';
            end;
         end;
         cM4:
         begin
            case SGCformat of
               cdfRaw: result:='cM4';
               cdfAbr: result:='M4I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M4I)';
            end;
         end;
         cM5:
         begin
            case SGCformat of
               cdfRaw: result:='cM5';
               cdfAbr: result:='M5I';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclCM')+' (M5I)';
            end;
         end;
         gF0:
         begin
            case SGCformat of
               cdfRaw: result:='gF0';
               cdfAbr: result:='F0III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F0III)';
            end;
         end;
         gF1:
         begin
            case SGCformat of
               cdfRaw: result:='gF1';
               cdfAbr: result:='F1III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F1III)';
            end;
         end;
         gF2:
         begin
            case SGCformat of
               cdfRaw: result:='gF2';
               cdfAbr: result:='F2III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F2III)';
            end;
         end;
         gF3:
         begin
            case SGCformat of
               cdfRaw: result:='gF3';
               cdfAbr: result:='F3III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F3III)';
            end;
         end;
         gF4:
         begin
            case SGCformat of
               cdfRaw: result:='gF4';
               cdfAbr: result:='F4III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F4III)';
            end;
         end;
         gF5:
         begin
            case SGCformat of
               cdfRaw: result:='gF5';
               cdfAbr: result:='F5III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F5III)';
            end;
         end;
         gF6:
         begin
            case SGCformat of
               cdfRaw: result:='gF6';
               cdfAbr: result:='F6III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F6III)';
            end;
         end;
         gF7:
         begin
            case SGCformat of
               cdfRaw: result:='gF7';
               cdfAbr: result:='F7III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F7III)';
            end;
         end;
         gF8:
         begin
            case SGCformat of
               cdfRaw: result:='gF8';
               cdfAbr: result:='F8III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F8III)';
            end;
         end;
         gF9:
         begin
            case SGCformat of
               cdfRaw: result:='gF9';
               cdfAbr: result:='F9III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGF')+' (F9III)';
            end;
         end;
         gG0:
         begin
            case SGCformat of
               cdfRaw: result:='gG0';
               cdfAbr: result:='G0III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G0III)';
            end;
         end;
         gG1:
         begin
            case SGCformat of
               cdfRaw: result:='gG1';
               cdfAbr: result:='G1III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G1III)';
            end;
         end;
         gG2:
         begin
            case SGCformat of
               cdfRaw: result:='gG2';
               cdfAbr: result:='G2III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G2III)';
            end;
         end;
         gG3:
         begin
            case SGCformat of
               cdfRaw: result:='gG3';
               cdfAbr: result:='G3III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G3III)';
            end;
         end;
         gG4:
         begin
            case SGCformat of
               cdfRaw: result:='gG4';
               cdfAbr: result:='G4III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G4III)';
            end;
         end;
         gG5:
         begin
            case SGCformat of
               cdfRaw: result:='gG5';
               cdfAbr: result:='G5III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G5III)';
            end;
         end;
         gG6:
         begin
            case SGCformat of
               cdfRaw: result:='gG6';
               cdfAbr: result:='G6III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G6III)';
            end;
         end;
         gG7:
         begin
            case SGCformat of
               cdfRaw: result:='gG7';
               cdfAbr: result:='G7III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G7III)';
            end;
         end;
         gG8:
         begin
            case SGCformat of
               cdfRaw: result:='gG8';
               cdfAbr: result:='G8III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G8III)';
            end;
         end;
         gG9:
         begin
            case SGCformat of
               cdfRaw: result:='gG9';
               cdfAbr: result:='G9III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGG')+' (G9III)';
            end;
         end;
         gK0:
         begin
            case SGCformat of
               cdfRaw: result:='gK0';
               cdfAbr: result:='K0III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K0III)';
            end;
         end;
         gK1:
         begin
            case SGCformat of
               cdfRaw: result:='gK1';
               cdfAbr: result:='K1III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K1III)';
            end;
         end;
         gK2:
         begin
            case SGCformat of
               cdfRaw: result:='gK2';
               cdfAbr: result:='K2III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K2III)';
            end;
         end;
         gK3:
         begin
            case SGCformat of
               cdfRaw: result:='gK3';
               cdfAbr: result:='K3III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K3III)';
            end;
         end;
         gK4:
         begin
            case SGCformat of
               cdfRaw: result:='gK4';
               cdfAbr: result:='K4III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K4III)';
            end;
         end;
         gK5:
         begin
            case SGCformat of
               cdfRaw: result:='gK5';
               cdfAbr: result:='K5III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K5III)';
            end;
         end;
         gK6:
         begin
            case SGCformat of
               cdfRaw: result:='gK6';
               cdfAbr: result:='K6III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K6III)';
            end;
         end;
         gK7:
         begin
            case SGCformat of
               cdfRaw: result:='gK7';
               cdfAbr: result:='K7III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K7III)';
            end;
         end;
         gK8:
         begin
            case SGCformat of
               cdfRaw: result:='gK8';
               cdfAbr: result:='K8III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K8III)';
            end;
         end;
         gK9:
         begin
            case SGCformat of
               cdfRaw: result:='gK9';
               cdfAbr: result:='K9III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGK')+' (K9III)';
            end;
         end;
         gM0:
         begin
            case SGCformat of
               cdfRaw: result:='gM0';
               cdfAbr: result:='M0III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M0III)';
            end;
         end;
         gM1:
         begin
            case SGCformat of
               cdfRaw: result:='gM1';
               cdfAbr: result:='M1III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M1III)';
            end;
         end;
         gM2:
         begin
            case SGCformat of
               cdfRaw: result:='gM2';
               cdfAbr: result:='M2III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M2III)';
            end;
         end;
         gM3:
         begin
            case SGCformat of
               cdfRaw: result:='gM3';
               cdfAbr: result:='M3III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M3III)';
            end;
         end;
         gM4:
         begin
            case SGCformat of
               cdfRaw: result:='gM4';
               cdfAbr: result:='M4III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M4III)';
            end;
         end;
         gM5:
         begin
            case SGCformat of
               cdfRaw: result:='gM5';
               cdfAbr: result:='M5III';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclGM')+' (M5III)';
            end;
         end;
         O5:
         begin
            case SGCformat of
               cdfRaw: result:='O5';
               cdfAbr: result:='O5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O5V)';
            end;
         end;
         O6:
         begin
            case SGCformat of
               cdfRaw: result:='O6';
               cdfAbr: result:='O6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O6V)';
            end;
         end;
         O7:
         begin
            case SGCformat of
               cdfRaw: result:='O7';
               cdfAbr: result:='O7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O7V)';
            end;
         end;
         O8:
         begin
            case SGCformat of
               cdfRaw: result:='O8';
               cdfAbr: result:='O8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O8V)';
            end;
         end;
         O9:
         begin
            case SGCformat of
               cdfRaw: result:='O9';
               cdfAbr: result:='O9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclO')+' (O9V)';
            end;
         end;
         B0:
         begin
            case SGCformat of
               cdfRaw: result:='B0';
               cdfAbr: result:='B0V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B0V)';
            end;
         end;
         B1:
         begin
            case SGCformat of
               cdfRaw: result:='B1';
               cdfAbr: result:='B1V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B1V)';
            end;
         end;
         B2:
         begin
            case SGCformat of
               cdfRaw: result:='B2';
               cdfAbr: result:='B2V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B2V)';
            end;
         end;
         B3:
         begin
            case SGCformat of
               cdfRaw: result:='B3';
               cdfAbr: result:='B3V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B3V)';
            end;
         end;
         B4:
         begin
            case SGCformat of
               cdfRaw: result:='B4';
               cdfAbr: result:='B4V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B4V)';
            end;
         end;
         B5:
         begin
            case SGCformat of
               cdfRaw: result:='B5';
               cdfAbr: result:='B5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B5V)';
            end;
         end;
         B6:
         begin
            case SGCformat of
               cdfRaw: result:='B6';
               cdfAbr: result:='B6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B6V)';
            end;
         end;
         B7:
         begin
            case SGCformat of
               cdfRaw: result:='B7';
               cdfAbr: result:='B7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B7V)';
            end;
         end;
         B8:
         begin
            case SGCformat of
               cdfRaw: result:='B8';
               cdfAbr: result:='B8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B8V)';
            end;
         end;
         B9:
         begin
            case SGCformat of
               cdfRaw: result:='B9';
               cdfAbr: result:='B9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclB')+' (B9V)';
            end;
         end;
         A0:
         begin
            case SGCformat of
               cdfRaw: result:='A0';
               cdfAbr: result:='A0V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A0V)';
            end;
         end;
         A1:
         begin
            case SGCformat of
               cdfRaw: result:='A1';
               cdfAbr: result:='A1V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A1V)';
            end;
         end;
         A2:
         begin
            case SGCformat of
               cdfRaw: result:='A2';
               cdfAbr: result:='A2V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A2V)';
            end;
         end;
         A3:
         begin
            case SGCformat of
               cdfRaw: result:='A3';
               cdfAbr: result:='A3V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A3V)';
            end;
         end;
         A4:
         begin
            case SGCformat of
               cdfRaw: result:='A4';
               cdfAbr: result:='A4V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A4V)';
            end;
         end;
         A5:
         begin
            case SGCformat of
               cdfRaw: result:='A5';
               cdfAbr: result:='A5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A5V)';
            end;
         end;
         A6:
         begin
            case SGCformat of
               cdfRaw: result:='A6';
               cdfAbr: result:='A6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A6V)';
            end;
         end;
         A7:
         begin
            case SGCformat of
               cdfRaw: result:='A7';
               cdfAbr: result:='A7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A7V)';
            end;
         end;
         A8:
         begin
            case SGCformat of
               cdfRaw: result:='A8';
               cdfAbr: result:='A8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A8V)';
            end;
         end;
         A9:
         begin
            case SGCformat of
               cdfRaw: result:='A9';
               cdfAbr: result:='A9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclA')+' (A9V)';
            end;
         end;
         F0:
         begin
            case SGCformat of
               cdfRaw: result:='F0';
               cdfAbr: result:='F0V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F0V)';
            end;
         end;
         F1:
         begin
            case SGCformat of
               cdfRaw: result:='F1';
               cdfAbr: result:='F1V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F1V)';
            end;
         end;
         F2:
         begin
            case SGCformat of
               cdfRaw: result:='F2';
               cdfAbr: result:='F2V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F2V)';
            end;
         end;
         F3:
         begin
            case SGCformat of
               cdfRaw: result:='F3';
               cdfAbr: result:='F3V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F3V)';
            end;
         end;
         F4:
         begin
            case SGCformat of
               cdfRaw: result:='F4';
               cdfAbr: result:='F4V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F4V)';
            end;
         end;
         F5:
         begin
            case SGCformat of
               cdfRaw: result:='F5';
               cdfAbr: result:='F5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F5V)';
            end;
         end;
         F6:
         begin
            case SGCformat of
               cdfRaw: result:='F6';
               cdfAbr: result:='F6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F6V)';
            end;
         end;
         F7:
         begin
            case SGCformat of
               cdfRaw: result:='F7';
               cdfAbr: result:='F7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F7V)';
            end;
         end;
         F8:
         begin
            case SGCformat of
               cdfRaw: result:='F8';
               cdfAbr: result:='F8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F8V)';
            end;
         end;
         F9:
         begin
            case SGCformat of
               cdfRaw: result:='F9';
               cdfAbr: result:='F9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclF')+' (F9V)';
            end;
         end;
         G0:
         begin
            case SGCformat of
               cdfRaw: result:='G0';
               cdfAbr: result:='G0V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G0V)';
            end;
         end;
         G1:
         begin
            case SGCformat of
               cdfRaw: result:='G1';
               cdfAbr: result:='G1V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G1V)';
            end;
         end;
         G2:
         begin
            case SGCformat of
               cdfRaw: result:='G2';
               cdfAbr: result:='G2V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G2V)';
            end;
         end;
         G3:
         begin
            case SGCformat of
               cdfRaw: result:='G3';
               cdfAbr: result:='G3V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G3V)';
            end;
         end;
         G4:
         begin
            case SGCformat of
               cdfRaw: result:='G4';
               cdfAbr: result:='G4V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G4V)';
            end;
         end;
         G5:
         begin
            case SGCformat of
               cdfRaw: result:='G5';
               cdfAbr: result:='G5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G5V)';
            end;
         end;
         G6:
         begin
            case SGCformat of
               cdfRaw: result:='G6';
               cdfAbr: result:='G6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G6V)';
            end;
         end;
         G7:
         begin
            case SGCformat of
               cdfRaw: result:='G7';
               cdfAbr: result:='G7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G7V)';
            end;
         end;
         G8:
         begin
            case SGCformat of
               cdfRaw: result:='G8';
               cdfAbr: result:='G8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G8V)';
            end;
         end;
         G9:
         begin
            case SGCformat of
               cdfRaw: result:='G9';
               cdfAbr: result:='G9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclG')+' (G9V)';
            end;
         end;
         K0:
         begin
            case SGCformat of
               cdfRaw: result:='K0';
               cdfAbr: result:='K0V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K0V)';
            end;
         end;
         K1:
         begin
            case SGCformat of
               cdfRaw: result:='K1';
               cdfAbr: result:='K1V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K1V)';
            end;
         end;
         K2:
         begin
            case SGCformat of
               cdfRaw: result:='K2';
               cdfAbr: result:='K2V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K2V)';
            end;
         end;
         K3:
         begin
            case SGCformat of
               cdfRaw: result:='K3';
               cdfAbr: result:='K3V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K3V)';
            end;
         end;
         K4:
         begin
            case SGCformat of
               cdfRaw: result:='K4';
               cdfAbr: result:='K4V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K4V)';
            end;
         end;
         K5:
         begin
            case SGCformat of
               cdfRaw: result:='K5';
               cdfAbr: result:='K5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K5V)';
            end;
         end;
         K6:
         begin
            case SGCformat of
               cdfRaw: result:='K6';
               cdfAbr: result:='K6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K6V)';
            end;
         end;
         K7:
         begin
            case SGCformat of
               cdfRaw: result:='K7';
               cdfAbr: result:='K7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K7V)';
            end;
         end;
         K8:
         begin
            case SGCformat of
               cdfRaw: result:='K8';
               cdfAbr: result:='K8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K8V)';
            end;
         end;
         K9:
         begin
            case SGCformat of
               cdfRaw: result:='K9';
               cdfAbr: result:='K9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclK')+' (K9V)';
            end;
         end;
         M0:
         begin
            case SGCformat of
               cdfRaw: result:='M0';
               cdfAbr: result:='M0V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M0V)';
            end;
         end;
         M1:
         begin
            case SGCformat of
               cdfRaw: result:='M1';
               cdfAbr: result:='M1V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M1V)';
            end;
         end;
         M2:
         begin
            case SGCformat of
               cdfRaw: result:='M2';
               cdfAbr: result:='M2V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M2V)';
            end;
         end;
         M3:
         begin
            case SGCformat of
               cdfRaw: result:='M3';
               cdfAbr: result:='M3V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M3V)';
            end;
         end;
         M4:
         begin
            case SGCformat of
               cdfRaw: result:='M4';
               cdfAbr: result:='M4V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M4V)';
            end;
         end;
         M5:
         begin
            case SGCformat of
               cdfRaw: result:='M5';
               cdfAbr: result:='M5V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M5V)';
            end;
         end;
         M6:
         begin
            case SGCformat of
               cdfRaw: result:='M6';
               cdfAbr: result:='M6V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M6V)';
            end;
         end;
         M7:
         begin
            case SGCformat of
               cdfRaw: result:='M7';
               cdfAbr: result:='M7V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M7V)';
            end;
         end;
         M8:
         begin
            case SGCformat of
               cdfRaw: result:='M8';
               cdfAbr: result:='M8V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M8V)';
            end;
         end;
         M9:
         begin
            case SGCformat of
               cdfRaw: result:='M9';
               cdfAbr: result:='M9V';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclM')+' (M9V)';
            end;
         end;
         WD0:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD0';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD0)';
            end;
         end;
         WD1:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD1';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD1)';
            end;
         end;
         WD2:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD2';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD2)';
            end;
         end;
         WD3:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD3';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD3)';
            end;
         end;
         WD4:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD4';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD4)';
            end;
         end;
         WD5:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD5';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD5)';
            end;
         end;
         WD6:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD6';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD6)';
            end;
         end;
         WD7:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD7';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD7)';
            end;
         end;
         WD8:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD8';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD8)';
            end;
         end;
         WD9:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='WD8';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclWD')+' (WD9)';
            end;
         end;
         PSR:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='PSR';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclPSR')+' (PSR)';
            end;
         end;
         BH:
         begin
            case SGCformat of
               cdfRaw, cdfAbr: result:='BH';
               cdfFull: result:=FCFdTFiles_UIStr_Get(uistrUI,'stclBH')+' (BH)';
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

//===========================END FUNCTIONS SECTION==========================================

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

