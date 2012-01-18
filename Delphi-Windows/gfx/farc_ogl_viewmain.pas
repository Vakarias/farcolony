{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved===============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: main 3d view core unit

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

unit farc_ogl_viewmain;

interface

uses
   Math
   ,SysUtils

   ,DecimalRounding_JH1

   ,GLAtmosphere
   ,GLColor
   ,GLObjects
   ,GLScene

   ,oxLib3dsMeshLoader;

type TFCEoglvmOobTp=(
   oglvmootNorm
   ,oglvmootAster
   ,oglvmootSatNorm
   ,oglvmootSatAster
   );

type TFCEoglvmOrbitTp=(
   oglvmotpPlanet
   ,oglvmotpSat
   ,oglvmotpSCraft
   );

type TFCEoglvmSCfrom=(
   scfDocked
   ,scfInOrbit
   ,scfInSpace
   );

///<summary>
///target a specified object in 3d view and initialize user's interface if needed
///</summary>
///   <param name="CMTidxOfObj">selected object index -10: space unit -1: central star >=0: orbital object 100: sat</param>
procedure FCMoglVM_CamMain_Target(
   const CMTidxOfObj: integer;
   const CMTisUpdPMenu: boolean
   );

///<summary>
///   return the focused object. 0= star, 1= orbital object, 2= satellite, 3= space unit
///</summary>
function FCFoglVM_Focused_Get(): integer;

///<summary>
///setup 3d main view: star itself and it's eventual planets and satellites
///</summary>
///   <param name="LSVUstarSysId">selected star system token db id</param>
///   <param name="LSVUstarId">selected star token db id</param>
///   <param name="LSVUresetSelect">switch for reset FCV3dMViewObjSlctdInScene</param>
procedure FCMoglVM_MView_Upd(
   const LSVUstarSysId
         ,LSVUstarId: string;
   const LSVUoobjReset,
         LSVUspUnReset: Boolean
   );

///<summary>
///   generate an orbit display at 1/4 and centered around central scene object for planet
///   orbit or full and centered around spacecraft for vessel beacon
///</summary>
procedure FCMoglVM_Orbits_Gen(
   const OBorbitType: TFCEoglvmOrbitTp;
   const OBobjIdx,
         OBsatIdx,
         OBsatCnt: integer;
   const OBdistInUnit: extended
   );

///<summary>
///   generate a 3d objects row of selected index
///</summary>
///   <param name="OOGobjClass">class of object to generate</param>
///   <param name="OGobjIdx">index of object row</param>
procedure FCMoglVM_OObj_Gen(
   const OOGobjClass: TFCEoglvmOobTp;
   const OOGobjIdx: integer
   );

///<summary>
///   change space unit scale according to it's distance, it's a fast&dirty fix
///</summary>
///    <param name="OOSUCSobjIdx">object index</param>
procedure FCMoglVM_OObjSpUn_ChgeScale(const OOSUCSobjIdx: integer);

///<summary>
///   display space units in orbit of a selected orbital object.
///</summary>
///    <param name="OOSUIOUoobjIdx">orbital object DB index id</param>
///    <param name="OOSUIOUsatIdx">satellite DB index id, if>0 then it gene</param>
///    <param name="OOSUIOUmustGen">true: generate the space unit 3d object</param>
procedure FCMoglVM_OObjSpUn_inOrbit(
   const OOSUIOUoobjIdx,
         OOSUIOUsatIdx,
         OOSUIOUsatObjIdx: integer;
   const OOSUIOUmustGen: boolean
   );

///<summary>
///   return the satellite object index of the choosen satellite in the current view.
///</summary>
function FCFoglVM_SatObj_Search(const SOSidxDBoob, SOSidxDBsat: integer): integer;

///<summary>
///   generate a space unit.
///</summary>
///   <param name="SUGstatus">space unit status</param>
///   <param name="SUGfac">faction 's index #</param>
///   <param name="SUGspUnOwnIdx">space unit owned index</param>
procedure FCMoglVM_SpUn_Gen(
   const SUGstatus: TFCEoglvmSCfrom;
   const SUGfac
         ,SUGspUnOwnIdx: integer
   );

///<summary>
///   restore the initial size of the targeted space unit
///</summary>
procedure FCMoglVMain_SpUnits_SetInitSize(const SUSIZresetSize: boolean);

///<summary>
///   resize the targeted space unit correctly, depending on distance
///</summary>
procedure FCMoglVM_SpUn_SetZoomScale;

implementation

uses
   farc_common_func
   ,farc_data_game
   ,farc_data_init
   ,farc_data_univ
   ,farc_data_textfiles
   ,farc_main
   ,farc_ogl_ui
   ,farc_spu_functions
   ,farc_ui_win
   ,farc_univ_func
   ,farc_win_debug;

//=============================================END OF INIT==================================

function FCFoglVMain_Aster_Set(
   const ASoobjIdx, ASsatIdx: integer;
   const ASisSat: boolean
   ): string;
{:Purpose: return .3ds path relative to aster type and load the AsterDmp with right
material.
    Additions:
}
var
   ASresDmp: string;
   ASobjTp: TFCEduOobjTp;
begin
   {.test if AsterDmp is created}
   if FC3DobjAsterDmp=nil then
   begin
      FC3DobjAsterDmp:=TDGLib3dsStaMesh(FCWinMain.FCGLSStarMain.AddNewChild(TDGLib3dsStaMesh));
      FC3DobjAsterDmp.Name:='FCGLSasterDmp';
      FC3DobjAsterDmp.UseGLSceneBuildList:=False;
      FC3DobjAsterDmp.UseShininessPowerHack:=0;
   end;
   {.get the object type}
   if ASisSat
   then ASobjTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASoobjIdx].OO_satList[ASsatIdx].OOS_type
   else if not ASisSat
   then ASobjTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASoobjIdx].OO_type;
   {.determine the type of asteroid to load}
   case ASobjTp of
      oobtpAster_Metall, oobtpSat_Aster_Metall:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVpathRsrc+'obj-3ds-aster\aster_metall.3ds';
         with FC3DobjAsterDmp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.2;
            Ambient.Green:=0.2;
            Ambient.Red:=0.2;
            Diffuse.Blue:=0.9;
            Diffuse.Green:=0.9;
            Diffuse.Red:=0.9;
            Emission.Color:=clrGray80;
            Shininess:=90;
         end;
      end;
      oobtpAster_Sili, oobtpSat_Aster_Sili:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVpathRsrc+'obj-3ds-aster\aster_sili.3ds';
         with FC3DobjAsterDmp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.2;
            Ambient.Green:=0.2;
            Ambient.Red:=0.2;
            Diffuse.Blue:=0.5;
            Diffuse.Green:=0.5;
            Diffuse.Red:=0.5;
            Emission.Color:=clrGray90;
            Shininess:=70;
         end;
      end;
      oobtpAster_Carbo, oobtpSat_Aster_Carbo:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVpathRsrc+'obj-3ds-aster\aster_carbo.3ds';
         with FC3DobjAsterDmp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.2;
            Ambient.Green:=0.2;
            Ambient.Red:=0.2;
            Diffuse.Blue:=0.8;
            Diffuse.Green:=0.8;
            Diffuse.Red:=0.8;
            Emission.Color:=clrBlack;
            Shininess:=50;
         end;
      end;
      oobtpAster_Icy, oobtpSat_Aster_Icy:
      begin
         {.set proper asteroid object and colors}
         ASresDmp:=FCVpathRsrc+'obj-3ds-aster\aster_icy.3ds';
         with FC3DobjAsterDmp.Material.FrontProperties do
         begin
            Ambient.Blue:=0.4;
            Ambient.Green:=0.4;
            Ambient.Red:=0.4;
            Diffuse.Blue:=0.8;
            Diffuse.Green:=0.8;
            Diffuse.Red:=0.8;
            Emission.Color:=clrGray10;
            Shininess:=80;
         end;
      end;
   end; //==END== case ASobjTp ==//
   Result:=ASresDmp;
end;

procedure FCMoglVMain_Atmosph_SetCol(
   const ASCoobjIdx
         ,ASCsatIdx
         ,ASCsatObjIdx: integer
   );
{:Purpose: set the atmosphere color following main gases which compose it..
    Additions:
      -2010Jan31- *mod: change in ASAsizeCoef.
      -2010Jan05- *add: set also atmosphere scale.
                  *mod: refactor the method considering the new function.
}
const
   ASAsizeCoef=2;//1.948;//.892
var
   ASChighColRed
   ,ASChighColGreen
   ,ASChighColBlue
   ,ASClowColRed
   ,ASClowColGreen
   ,ASClowColBlue: extended;

   ASCh2
   ,ASChe
   ,ASCn2
   ,ASCo2
   ,ASCh2s
   ,ASCco2
   ,ASCso2
   : TFCEatmGasStat;
begin
   if ASCsatIdx=0
   then
   begin
      ASCh2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasH2;
      ASChe:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasHe;
      ASCn2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasN2;
      ASCo2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasO2;
      ASCh2s:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasH2S;
      ASCco2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasCO2;
      ASCso2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_atmosph.agasSO2;
   end
   else if ASCsatIdx>0
   then
   begin
      ASCh2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasH2;
      ASChe:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasHe;
      ASCn2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasN2;
      ASCo2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasO2;
      ASCh2s:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasH2S;
      ASCco2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasCO2;
      ASCso2:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[ASCoobjIdx].OO_satList[ASCsatIdx].OOS_atmosph.agasSO2;
   end;
   {.N2 atmosphere - titan like}
   if (ASCn2=agsMain)
      and (ASCco2<agsMain)
      and (ASCo2<agsMain)
   then
   begin
      ASChighColRed:=0.223529;
      ASChighColGreen:=0.286274;
      ASChighColBlue:=0.415686;
      ASClowColRed:=0.615686;
      ASClowColGreen:=0.447058;
      ASClowColBlue:=0.247058;
   end
   {.N2/CO2 atmosphere - mars like}
   else if (ASCn2=agsMain)
      and (ASCco2=agsMain)
      and (ASCo2<agsMain)
   then
   begin
      ASChighColRed:=0.372549;
      ASChighColGreen:=0.364705;
      ASChighColBlue:=0.317647;
      ASClowColRed:=0.760784;
      ASClowColGreen:=0.745098;
      ASClowColBlue:=0.709803;
   end
   {.N2/O2 atmosphere - earth like}
   else if (ASCn2=agsMain)
      and (ASCco2<agsMain)
      and (ASCo2=agsMain)
   then
   begin
      ASChighColRed:=0.247058;
      ASChighColGreen:=0.392156;
      ASChighColBlue:=0.6;
      ASClowColRed:=0.196078;
      ASClowColGreen:=0.6;
      ASClowColBlue:=0.8;
   end
   {.H2/He atmosphere - saturn like}
   else if (ASCh2=agsMain)
      and (ASChe=agsMain)
   then
   begin
      ASChighColRed:=0.403921;
      ASChighColGreen:=0.454901;
      ASChighColBlue:=0.478431;
      ASClowColRed:=0.709803;
      ASClowColGreen:=0.639215;
      ASClowColBlue:=0.458823;
   end
   {.H2S/SO2 atmosphere - io like}
   else if (ASCh2s=agsMain)
      and (ASCso2=agsMain)
   then
   begin
      ASChighColRed:=0.556862;
      ASChighColGreen:=0.549019;
      ASChighColBlue:=0.325490;
      ASClowColRed:=0.866666;
      ASClowColGreen:=0.866666;
      ASClowColBlue:=0.866666;
   end;
   {.set the colors}
   if ASCsatIdx=0
   then
   begin
      FC3DobjAtmosph[ASCoobjIdx].HighAtmColor.Red:=ASChighColRed;
      FC3DobjAtmosph[ASCoobjIdx].HighAtmColor.Green:=ASChighColGreen;
      FC3DobjAtmosph[ASCoobjIdx].HighAtmColor.Blue:=ASChighColBlue;
      FC3DobjAtmosph[ASCoobjIdx].LowAtmColor.Red:=ASClowColRed;
      FC3DobjAtmosph[ASCoobjIdx].LowAtmColor.Green:=ASClowColGreen;
      FC3DobjAtmosph[ASCoobjIdx].LowAtmColor.Blue:=ASClowColBlue;
      FC3DobjAtmosph[ASCoobjIdx].SetOptimalAtmosphere2
         (
            FC3DobjPlan[ASCoobjIdx].Scale.X
            -(
               (sqrt(FC3DobjPlan[ASCoobjIdx].Scale.X)/ASAsizeCoef)
               -(sqrt(FC3DobjPlan[ASCoobjIdx].Scale.X)/2)
            )
         );
   end
   else if ASCsatIdx>0
   then
   begin
      FC3DobjSatAtmosph[ASCsatObjIdx].HighAtmColor.Red:=ASChighColRed;
      FC3DobjSatAtmosph[ASCsatObjIdx].HighAtmColor.Green:=ASChighColGreen;
      FC3DobjSatAtmosph[ASCsatObjIdx].HighAtmColor.Blue:=ASChighColBlue;
      FC3DobjSatAtmosph[ASCsatObjIdx].LowAtmColor.Red:=ASClowColRed;
      FC3DobjSatAtmosph[ASCsatObjIdx].LowAtmColor.Green:=ASClowColGreen;
      FC3DobjSatAtmosph[ASCsatObjIdx].LowAtmColor.Blue:=ASClowColBlue;
      FC3DobjSatAtmosph[ASCsatObjIdx].SetOptimalAtmosphere2
         (
            FC3DobjSat[ASCsatObjIdx].Scale.X
            -(
               (sqrt(FC3DobjSat[ASCsatObjIdx].Scale.X)/ASAsizeCoef)
               -(sqrt(FC3DobjSat[ASCsatObjIdx].Scale.X)/2)
            )
         );
   end;
end;

procedure FCMoglVM_CamMain_Target(
   const CMTidxOfObj: integer;
   const CMTisUpdPMenu: boolean
   );
{:Purpose: target a specified object in 3d view and initialize user's interface if needed.
    Additions:
      -2010Feb17- *add: set space unit size if targeted.
                  *add: restore space unit size, if it was previously targeted.
      -2009Dec20- *add: satellite data display link.
      -2009Dec16- *mod: change camera bias for satellite focus.
      -2009Dec15- *add: store the player's location.
                  *add: satellite focus.
      -2009Dec08- *change camera near plane following the target type.
      -2009Sep27- *add focused popup menu update.
      -2009Sep23- *display focused object name for space units.
      -2009Sep22- *tweaks in zoom for central star focus.
                  *display focused object name.
      -2009Sep20- *camera change for location and zoom during a space unit targeting.
      -2009Sep17- *add space unit targeting.
      -2009Sep06- *gone back to previous FARC camera settings for orbital object focus.
                  *use cubesize for objgroup.
      -2009Aug30- *other object targeting.
      -2009Aug27- *star targeting completion.
}
var
   CMTdmpCoef: extended;
   CMTdmpSatIdx
   ,CMTdmpSatPlanIdx: integer;
begin
   {.space unit selected}
   if CMTidxOfObj=-1
   then
   begin
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3DobjSpUnit[FCV3DselSpU];
      FCMoglVM_OObjSpUn_ChgeScale(FCV3DselSpU);
      CMTdmpCoef:=FC3DobjSpUnit[FCV3DselSpU].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU*8;
      FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=FC3DobjSpUnit[FCV3DselSpU].Position.X+FC3DobjSpUnit[FCV3DselSpU].Scale.X+(0.05*CMTdmpCoef);
      FCWinMain.FCGLSCamMainViewGhost.Position.Y
         :=FC3DobjSpUnit[FCV3DselSpU].Scale.Y+(0.04*CMTdmpCoef);
      FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=FC3DobjSpUnit[FCV3DselSpU].Position.Z+FC3DobjSpUnit[FCV3DselSpU].Scale.Z+(0.05*CMTdmpCoef);
      {.configuration}
      FCWinMain.FCGLSCamMainView.NearPlaneBias
         :=0.01+(sqrt(FC3DobjSpUnit[FCV3DselSpU].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU)/30);
      FCV3DspUnSiz:=FC3DobjSpUnit[FCV3DselSpU].Scale.X;
      FCMoglVM_SpUn_SetZoomScale;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3DobjSpUnit[FCV3DselSpU];
      {.update focused object name}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
     {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiW_FocusPopup_Upd(uiwpkSpUnit);
   end
   {.central star selected}
   else if CMTidxOfObj=0
   then
   begin
      if FCV3DspUnSiz<>0
      then FCMoglVMain_SpUnits_SetInitSize(true);
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FCWinMain.FCGLSStarMain;
      FCWinMain.FCGLSCamMainViewGhost.Position.X:=FCWinMain.FCGLSStarMain.Scale.X*2;
      FCWinMain.FCGLSCamMainViewGhost.Position.Y:=FCWinMain.FCGLSStarMain.Scale.Y*1.5;
      FCWinMain.FCGLSCamMainViewGhost.Position.Z:=0;
      {.camera near plane bias}
      FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FCWinMain.FCGLSStarMain;
      {.update focused object name}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
      {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiW_FocusPopup_Upd(uiwpkOrbObj);
   end
   {.orbital object selected}
   else if (CMTidxOfObj>0)
      and (CMTidxOfObj<100)
   then
   begin
      if FCV3DspUnSiz<>0
      then FCMoglVMain_SpUnits_SetInitSize(true);
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3DobjGrp[CMTidxOfObj];
      {.X location}
      if FC3DobjGrp[CMTidxOfObj].Position.X>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3DobjGrp[CMTidxOfObj].Position.X)-(FC3DobjGrp[CMTidxOfObj].CubeSize*2.3)
      else if FC3DobjGrp[CMTidxOfObj].Position.X<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3DobjGrp[CMTidxOfObj].Position.X)+(FC3DobjGrp[CMTidxOfObj].CubeSize*2.3);
      {.Y location}
      FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
      {.Z location}
      if FC3DobjGrp[CMTidxOfObj].Position.Z>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3DobjGrp[CMTidxOfObj].Position.Z)-(FC3DobjGrp[CMTidxOfObj].CubeSize*2.3)
      else if FC3DobjGrp[CMTidxOfObj].Position.Z<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3DobjGrp[CMTidxOfObj].Position.Z)+(FC3DobjGrp[CMTidxOfObj].CubeSize*2.3);
      {.camera near plane bias}
      FCWinMain.FCGLSCamMainView.NearPlaneBias:=1;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3DobjGrp[CMTidxOfObj];
      {.update focused object data}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
      {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiW_FocusPopup_Upd(uiwpkOrbObj);
      {.store the player's location}
      FCRplayer.P_oObjLoc:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[FCV3DselOobj].OO_token;
   end
   {.satellite selected}
   else if CMTidxOfObj=100
   then
   begin
      if FCV3DspUnSiz<>0
      then FCMoglVMain_SpUnits_SetInitSize(true);
      {.camera ghost settings}
      FCWinMain.FCGLSCamMainViewGhost.TargetObject:=FC3DobjSatGrp[FCV3DselSat];
      {.X location}
      if FC3DobjSatGrp[FCV3DselSat].Position.X>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3DobjSatGrp[FCV3DselSat].Position.X)-(FC3DobjSatGrp[FCV3DselSat].CubeSize*2.3)
      else if FC3DobjSatGrp[FCV3DselSat].Position.X<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.X
         :=(FC3DobjSatGrp[FCV3DselSat].Position.X)+(FC3DobjSatGrp[FCV3DselSat].CubeSize*2.3);
      {.Y location}
      FCWinMain.FCGLSCamMainViewGhost.Position.Y:=1;
      {.Z location}
      if FC3DobjSatGrp[FCV3DselSat].Position.Z>0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3DobjSatGrp[FCV3DselSat].Position.Z)-(FC3DobjSatGrp[FCV3DselSat].CubeSize*2.3)
      else if FC3DobjSatGrp[FCV3DselSat].Position.Z<0
      then FCWinMain.FCGLSCamMainViewGhost.Position.Z
         :=(FC3DobjSatGrp[FCV3DselSat].Position.Z)+(FC3DobjSatGrp[FCV3DselSat].CubeSize*2.3);
      {.camera near plane bias}
      FCWinMain.FCGLSCamMainView.NearPlaneBias:=0.55;
      {.smooth navigator target change}
      FCWinMain.FCGLSsmthNavMainV.MoveAroundParams.TargetObject:=FC3DobjSatGrp[FCV3DselSat];
      {.update focused object data}
      FCMoglUI_Main3DViewUI_Update(oglupdtpTxtOnly, ogluiutFocObj);
      {.update the corresponding popup menu}
      if CMTisUpdPMenu
      then FCMuiW_FocusPopup_Upd(uiwpkOrbObj);
      {.store the player's location}
      CMTdmpSatIdx:=FC3DobjSatGrp[FCV3DselSat].Tag;
      CMTdmpSatPlanIdx:=round(FC3DobjSatGrp[FCV3DselSat].TagFloat);
      FCRplayer.P_satLoc
         :=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[CMTdmpSatPlanIdx].OO_satList[CMTdmpSatIdx].OOS_token;
   end;
end;

function FCFoglVMain_CloudsCov_Conv2AtmOp(const CCC2AOcover: extended): extended;
{:Purpose: calculate atmosphere opacity following clouds covers given.à
   Additions:
      -2010Mar21- *add: reinstate round of the result with a new method.
}
var CCC2AOdmp: extended;
begin
   if CCC2AOcover=0
   then Result:=0
   else if CCC2AOcover=-1
   then Result:=0.7
   else
   begin
      try
         CCC2AOdmp:=CCC2AOcover/(10+(sqrt(CCC2AOcover)/8))   ;
      finally
         Result:=DecimalRound(CCC2AOdmp, 1, 0.01);
      end;
   end;
end;

procedure FCMoglVMain_MapTex_Assign(const MTAoobjIdx, MTAsatIdx, MTAsatObjIdx: integer);
{:Purpose: assign the correct surface/atmosphere texture map on a designed orbital object.
    Additions:
      -2010Jan07- *add: implement planet w/ personalized textures.
                  *add: the rest of telluric/icy planets w/ standard textures.
                  *add: implement calculations for mean temperature and and hydrosphere type for satellites.
      -2010Jan06- *add: implement calculations for mean temperature and and hydrosphere type.
}
var
   MTAdmpObjTp: TFCEduOobjTp;
   MTAdmpHydroTp: TFCEhydroTp;
   MTAdmpLibName
   ,MTAdmpOobjToken
   ,MTAdmpTexPath: string;
   MTAdmpTemp: extended;
begin
   MTAdmpLibName:='';
   if MTAsatIdx=0
   then
   begin
      MTAdmpObjTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[MTAoobjIdx].OO_type;
      MTAdmpHydroTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[MTAoobjIdx].OO_hydrotp;
      MTAdmpTemp:=FCFuF_OrbPeriod_GetMeanTemp(MTAoobjIdx, MTAsatIdx);
   end
   else if MTAsatIdx>0
   then
   begin
      MTAdmpObjTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[MTAoobjIdx].OO_satList[MTAsatIdx].OOS_type;
      MTAdmpHydroTp:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[MTAoobjIdx].OO_satList[MTAsatIdx].OOS_hydrotp;
      MTAdmpTemp:=FCFuF_OrbPeriod_GetMeanTemp(MTAoobjIdx, MTAsatIdx);
   end;
   {.for gaseous planets => standard textures}
   if (MTAdmpObjTp>oobtpPlan_Icy_CallistoH3H4Atm0)
      and (MTAdmpObjTp<oobtpSat_Aster_Metall)
   then
   begin
      case MTAdmpObjTp of
         oobtpPlan_Gas_Uranus:
         begin
            if MTAdmpTemp<=80
            then  MTAdmpLibName:='UranusCold'
            else if MTAdmpTemp>80
            then  MTAdmpLibName:='UranusHot';
         end;
         oobtpPlan_Gas_Neptun:
         begin
            if MTAdmpTemp<=80
            then  MTAdmpLibName:='NeptuneCold'
            else if MTAdmpTemp>80
            then  MTAdmpLibName:='NeptuneHot';
         end;
         oobtpPlan_Gas_Saturn:
         begin
            if MTAdmpTemp<=145
            then  MTAdmpLibName:='SaturnCold'
            else if MTAdmpTemp>145
            then  MTAdmpLibName:='SaturnHot';
         end;
         oobtpPlan_Jovian_Jupiter:
         begin
            if MTAdmpTemp<=175
            then  MTAdmpLibName:='JovianCold'
            else if MTAdmpTemp>175
            then  MTAdmpLibName:='JovianHot';
         end;
         oobtpPlan_Supergiant1:
         begin
            if MTAdmpTemp<=175
            then  MTAdmpLibName:='SuperGiantCold'
            else if MTAdmpTemp>175
            then  MTAdmpLibName:='SuperGiantHot';
         end;
      end; //==END== case MTAdmpObjTp ==//
   end //==END== if (MTAdmpObjTp>Plan_Icy_CallistoH3H4Atm0 and <Sat_Aster_Metall) ==//
   {.for planet w/ personalized textures}
   else if ((MTAdmpObjTp>oobtpAster_Icy) and (MTAdmpObjTp<oobtpPlan_Tellu_MercuH0))
      or ((MTAdmpObjTp>oobtpSat_Tellu_Io) and (MTAdmpObjTp<oobtpSat_Icy_Pluto))
   then
   begin
      if MTAsatIdx=0
      then MTAdmpOobjToken:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[MTAoobjIdx].OO_token
      else if MTAsatIdx>0
      then MTAdmpOobjToken:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[MTAoobjIdx]
         .OO_satList[MTAsatIdx].OOS_token;
   end
   {.for the rest of telluric/icy planets w/ standard textures}
   else begin
      case MTAdmpObjTp of
         oobtpPlan_Tellu_MercuH0: MTAdmpLibName:='MercuryH0';
         oobtpPlan_Tellu_MercuH3: MTAdmpLibName:='MercuryH3';
         oobtpPlan_Tellu_MercuH4: MTAdmpLibName:='MercuryH4';
         oobtpPlan_Icy_PlutoH3: MTAdmpLibName:='Pluto';
         oobtpPlan_Icy_EuropeH4: MTAdmpLibName:='Europa';
         oobtpPlan_Icy_CallistoH3H4Atm0:
         begin
            if  MTAdmpHydroTp=htIceSheet
            then MTAdmpLibName:='CallistoH3'
            else if  MTAdmpHydroTp=htCrystal
            then MTAdmpLibName:='CallistoH4';
         end;
         oobtpSat_Tellu_Lunar:
         begin
            if  MTAdmpTemp<234
            then MTAdmpLibName:='SatLunarCold'
            else if  MTAdmpTemp>=234
            then MTAdmpLibName:='SatLunar';
         end;
         oobtpSat_Tellu_Io: MTAdmpLibName:='SatIo';
         oobtpSat_Icy_Pluto: MTAdmpLibName:='SatPluto';
         oobtpSat_Icy_Europe: MTAdmpLibName:='SatEuropa';
         oobtpSat_Icy_Callisto:
         begin
            MTAdmpLibName:='SatCallistoH3';
            if  MTAdmpHydroTp=htIceSheet
            then MTAdmpLibName:='SatCallistoH3'
            else if  MTAdmpHydroTp=htCrystal
            then MTAdmpLibName:='SatCallistoH4';
         end;
      end; {.case MTAdmpObjTp of}
   end;
   {.assign standard texture}
   if MTAdmpLibName<>''
   then
   begin
      if MTAsatIdx=0
      then
      begin
         if FC3DobjPlan[MTAoobjIdx].Material.MaterialLibrary=nil
         then FC3DobjPlan[MTAoobjIdx].Material.MaterialLibrary:=FC3DmatLibSplanT;
         FC3DobjPlan[MTAoobjIdx].Material.LibMaterialName:=MTAdmpLibName;
      end
      else if MTAsatIdx>0
      then
      begin
         if FC3DobjSat[MTAsatObjIdx].Material.MaterialLibrary=nil
         then FC3DobjSat[MTAsatObjIdx].Material.MaterialLibrary:=FC3DmatLibSplanT;
         FC3DobjSat[MTAsatObjIdx].Material.LibMaterialName:=MTAdmpLibName;
      end;
   end
   {.assign personalized texture}
   else if MTAdmpLibName=''
   then
   begin
      if FileExists(FCVpathRsrc+'pics-ogl-oobj-pers\'+MTAdmpOobjToken+'.jpg')
      then MTAdmpTexPath:=FCVpathRsrc+'pics-ogl-oobj-pers\'+MTAdmpOobjToken+'.jpg'
      else MTAdmpTexPath:=FCVpathRsrc+'pics-ogl-oobj-pers\_error_map.jpg';
      if MTAsatIdx=0
      then FC3DobjPlan[MTAoobjIdx].Material.Texture.Image.LoadFromFile(MTAdmpTexPath)
      else if MTAsatIdx>0
      then FC3DobjSat[MTAsatObjIdx].Material.Texture.Image.LoadFromFile(MTAdmpTexPath);
   end;
end;

function FCFoglVM_Focused_Get(): integer;
{:Purpose: return the focused object. 0= star, 1= orbital object, 2= satellite, 3= space unit.
    Additions:
}
begin
   if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FCWinMain.FCGLSStarMain
   then Result:=0
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3DobjGrp[FCV3DselOobj]
   then Result:=1
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3DobjSatGrp[FCV3DselSat]
   then Result:=2
   else if FCWinMain.FCGLSCamMainViewGhost.TargetObject=FC3DobjSpUnit[FCV3DselSpU]
   then Result:=3;
end;

procedure FCMoglVM_MView_Upd(
   const LSVUstarSysId
         ,LSVUstarId: string;
   const LSVUoobjReset,
         LSVUspUnReset: Boolean
   );
{:Purpose: setup local star view: star itself and it's eventual planets & satellites.
    Additions:
      -2010Sep15- *add: entities code.
      -2010Jun15- *mod: use the new function for space location.
      -2010Apr25- *add: generate docked space units.
      -2010Apr05- *add: initialize star's specular colors for a better looking.
      -2010Mar07- *mod: change the display for space units which aren't in orbit.
      -2010Jan07- *add: sky/surface texture mapping for planets (satellites).
      -2010Jan05- *add: sky/surface texture mapping for planets.
                  *mod: small tweaks in atmosphere display.
      -2009Dec28- *add: set atmosphere color following main gases composition.
                  *mod: change the calculation of atmosphere size.
      -2009Dec18- *add: complete satellites display.
      -2009Dec12- *add: begin satellites display.
      -2009Dec09- *complete atmosphere display.
                  *change relative star display size for be more realistic after the
                  distance changes.
      -2009Dec07- *add atmosphere display.
      -2009Nov15- *re-enable and optimize space units generations that are in free space.
      -2009Nov05- *separate reset of FCV3dMVorbObjSlctd and FCV3dMVspUnitSlctd.
      -2009Sep23- *add space unit faction and proper id# directly in object itself.
      -2009Sep20- *load space unit location x/z in FCRplayer.Play_suOwned.
                  *display space unit in orbit for asteroids.
      -2009Sep19- *add space units in orbit.
      -2009Sep17- *add space units initialization.
      -2009Sep15- *set orbit build for asteroid.
      -2009Sep14- *add gravity well orbit.
      -2009Sep09- *add orbit object initialization.
      -2009Sep07- *test code for spacecraft display
      -2009Sep06- *fix objgroup size.
      -2009Sep03- *relocate correctly designed objects.
      -2009Sep01- *fix a bug in object count.
                  *set final size of 3d object lists at the end of process.
      -2009Aug31- *include new 3d object creation method.
                  *orbital object generation - planets.
      -2009Aug29- *orbital object generation - asteroids.
      -2009Aug26- *addition of FCV3dMViewObjSlctdInScene switch to reset this variable.
                  *post setup addition.
                  *star settings completion.
}
const
   LSVUblocCnt=128;
var
   j: integer;
   i: integer;
   LSVUangleRad
	,LSVUorbDistUnit
   ,LSVUsatDistUnit
   ,LSVUstarSize: extended;

   TDMVUorbObjCnt,
   MVUentCnt,
   LSVUorbObjTtlInDS,
   LSVUspUnCnt,
   LSVUspUnInTtl,
   LSVUspUnFacTtl,
   LSVUdmpCount,
   LSVUspUntOwnIdx,
   TDMVUsatCnt,
//   TDMVUsatInTtl,
   TDMVUsatTtlInDS,
   TDMVUsatIdx: integer;
   LSVUstarClssStr,
   LSVUasterFileName: string;
   LSVUtest: TGLBaseSceneObject;
begin
   {.scene and data cleanup in pre-process}
   FCV3DttlOobj:=0;
   FCV3DttlSpU:=0;
   FCV3DttlSat:=0;
   if LSVUoobjReset
   then
   begin
      FCV3DselOobj:=0;
      FCV3DselSat:=0;
   end;
   if LSVUspUnReset
   then FCV3DselSpU:=0;
   FCWinMain.FCGLSmainView.Hide;
   FCWinMain.FCGLScadencer.Enabled:=false;
   FCV3DselSsys:=FCFuF_StelObj_GetDbIdx(
      ufsoSsys
      ,LSVUstarSysId
      ,0
      ,0
      ,0
      );
   FCV3DselStar:=FCFuF_StelObj_GetDbIdx(
      ufsoStar
      ,LSVUstarId
      ,FCV3DselSsys
      ,0
      ,0
      );
   FC3DobjAtmosph:=nil;
   SetLength(FC3DobjAtmosph,1);
   FC3DobjPlanOrbit:=nil;
   SetLength(FC3DobjPlanOrbit,1);
   FC3DobjPlanGrav:=nil;
   SetLength(FC3DobjPlanGrav,1);
   FC3DobjSpUnit:=nil;
   SetLength(FC3DobjSpUnit,1);
   FC3DobjSatAster:=nil;
   SetLength(FC3DobjSatAster,1);
   FC3DobjSatAtmosph:=nil;
   SetLength(FC3DobjSatAtmosph,1);
   FC3DobjSatGrp:=nil;
   SetLength(FC3DobjSatGrp,1);
   FC3DobjSatGrav:=nil;
   SetLength(FC3DobjSatGrav,1);
   FC3DobjSatOrbit:=nil;
   SetLength(FC3DobjSatOrbit,1);
   FC3DobjSat:=nil;
   SetLength(FC3DobjSat,1);
   FC3DobjGrp:=nil;
   SetLength(FC3DobjGrp,1);
   FC3DobjPlan:=nil;
   SetLength(FC3DobjPlan,1);
   FC3DobjAster:=nil;
   SetLength(FC3DobjAster,1);
   {.set the update message}
   FCWinMain.FCWM_3dMainGrp.Caption:=FCFdTFiles_UIStr_Get(uistrUI,'FCWM_3dMainGrp.Upd');
   {.set star}
   LSVUstarSize:=FCFcFunc_ScaleConverter(
      cf3dctKmTo3dViewUnit
      ,(1390000*FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_diam)
      )*10;
   FCWinMain.FCGLSStarMain.Scale.X:=LSVUstarSize;
   FCWinMain.FCGLSStarMain.Scale.Y:=LSVUstarSize;
   FCWinMain.FCGLSStarMain.Scale.Z:=LSVUstarSize;
   FCWinMain.FCGLSStarMain.Position.X:=0;
   FCWinMain.FCGLSStarMain.Position.Y:=0;
   FCWinMain.FCGLSStarMain.Position.Z:=0;
   {.set starlight}
   FCWinMain.FCGLSSM_Light.Position.X:=0;
   FCWinMain.FCGLSSM_Light.Position.Y:=0;
   FCWinMain.FCGLSSM_Light.Position.Z:=0;
   {.set starlight diffuse color and star texture name}
   case FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_class of
      cB5, cB6, cB7, cB8, cB9:
      begin
         LSVUstarClssStr:='cB';//old file index 005
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.98;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.922;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.78;
      end;
      cA0, cA1, cA2, cA3, cA4:
      begin
         LSVUstarClssStr:='cAless5';//old file index 003
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.929;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.937;
      end;
      cA5, cA6, cA7, cA8, cA9:
      begin
         LSVUstarClssStr:='cAsupeg5';//old file index 004
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;
      cK0, cK1, cK2, cK3, cK4:
      begin
         LSVUstarClssStr:='cgKless5';//old file index 008
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;
      cK5, cK6, cK7, cK8:
      begin
         LSVUstarClssStr:='cgKeg5-8';//old file index 009
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      cK9:
      begin
         LSVUstarClssStr:='cgKeg9';//old file index 010
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;
      cM0, cM1, cM2, cM3, cM4:
      begin
         LSVUstarClssStr:='cgMless5';//old file index 014
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      cM5:
      begin
         LSVUstarClssStr:='cgMeg5';//old file index 015
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;
      gF0, gF1, gF2, gF3, gF4:
      begin
         LSVUstarClssStr:='gFless5';//old file index 018
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.808;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.843;
      end;
      gF5, gF6, gF7, gF8, gF9:
      begin
         LSVUstarClssStr:='gFsupeg5';//old file index 019
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.894;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.894;
      end;
      gG0, gG1, gG2, gG3, gG4:
      begin
         LSVUstarClssStr:='gGless5';//old file index 022
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.878;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.988;
      end;
      gG5, gG6, gG7, gG8:
      begin
         LSVUstarClssStr:='gGeg5-8';//old file index 023
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.788;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      gG9:
      begin
         LSVUstarClssStr:='gGeg9';//old file index 024
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.773;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      gK0, gK1, gK2, gK3, gK4:
      begin
         LSVUstarClssStr:='cgKless5';//old file index 008
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;
      gK5, gK6, gK7, gK8:
      begin
         LSVUstarClssStr:='cgKeg5-8';//old file index 009
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      gK9:
      begin
         LSVUstarClssStr:='cgKeg9';//old file index 010
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;
      gM0, gM1, gM2, gM3, gM4:
      begin
         LSVUstarClssStr:='cgMless5';//old file index 014
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      gM5:
      begin
         LSVUstarClssStr:='cgMeg5';//old file index 015
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;
      O5, O6, O7, O8, O9:
      begin
         LSVUstarClssStr:='O';//old file index 028
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=1;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.784;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.769;
      end;
      B0, B1, B2, B3, B4:
      begin
         LSVUstarClssStr:='Bless5';//old file index 006
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=1;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.784;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.769;
      end;
      B5, B6, B7, B8, B9:
      begin
         LSVUstarClssStr:='Bsupeg5';//old file index 007
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.98;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.922;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.78;
      end;
      A0, A1, A2, A3, A4:
      begin
         LSVUstarClssStr:='Aless5';//old file index 001
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.966;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.929;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.937;
      end;
      A5, A6, A7, A8, A9:
      begin
         LSVUstarClssStr:='Asupeg5';//old file index 002
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;
      F0, F1, F2, F3, F4:
      begin
         LSVUstarClssStr:='Fless5';//old file index 020
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.808;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.843;
      end;
      F5, F6, F7, F8, F9:
      begin
         LSVUstarClssStr:='Fsupeg5';//old file index 021
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.894;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.894;
      end;
      G0, G1, G2, G3, G4:
      begin
         LSVUstarClssStr:='Gless5';//old file index 025
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.878;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.996;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.988;
      end;
      G5, G6, G7, G8:
      begin
         LSVUstarClssStr:='Feg5-8';//old file index 026
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.788;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      G9:
      begin
         LSVUstarClssStr:='Feg9';//old file index 027
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.773;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.98;
      end;
      K0, K1, K2, K3, K4:
      begin
         LSVUstarClssStr:='Kless5';//old file index 011
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.792;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.902;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.976;
      end;
      K5, K6, K7, K8:
      begin
         LSVUstarClssStr:='Keg5-8';//old file index 012
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.843;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.925;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      K9:
      begin
         LSVUstarClssStr:='Keg9';//old file index 013
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.722;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.871;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.973;
      end;
      M0, M1, M2, M3, M4:
      begin
         LSVUstarClssStr:='Mless5';//old file index 016
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.776;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.984;
      end;
      M5, M6, M7, M8, M9:
      begin
         LSVUstarClssStr:='Msupeg5';//old file index 017
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.847;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.855;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.996;
      end;
      WD0..WD9:
      begin
         LSVUstarClssStr:='WDeg0-9';//old file index 029
         FCWinMain.FCGLSSM_Light.Diffuse.Color:=clrWhite;
      end;
      PSR:
      begin
         LSVUstarClssStr:='PSR';//old file index 030
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.584;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.584;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.584;
      end;
      BH:
      begin
         LSVUstarClssStr:='BH';//no old file (previous iteration of FAR Colony had no tex
         FCWinMain.FCGLSSM_Light.Diffuse.Blue:=0.325;
         FCWinMain.FCGLSSM_Light.Diffuse.Green:=0.325;
         FCWinMain.FCGLSSM_Light.Diffuse.Red:=0.325;
      end;
   end;
   FCWinMain.FCGLSSM_Light.Specular.Blue:=FCWinMain.FCGLSSM_Light.Diffuse.Blue;
   FCWinMain.FCGLSSM_Light.Specular.Green:=FCWinMain.FCGLSSM_Light.Diffuse.Blue;
   FCWinMain.FCGLSSM_Light.Specular.Red:=FCWinMain.FCGLSSM_Light.Diffuse.Red;
   {.set star's picture}
   FCWinMain.FCGLSStarMain.Material.Texture.Image.LoadFromFile(FCVpathRsrc+'pics-ogl-stars\star_'+LSVUstarClssStr+'.png');
   {.set orbital objects}
   LSVUorbObjTtlInDS:=Length(FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj)-1;
   if LSVUorbObjTtlInDS>0
   then
   begin
      with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar] do
      begin
         TDMVUorbObjCnt:=1;
         TDMVUsatCnt:=0;
         {.orbital objects + satellites creation loop}
         while TDMVUorbObjCnt<=LSVUorbObjTtlInDS do
         begin
            {.set the 3d object arrays, if needed}
            if TDMVUorbObjCnt >= Length(FC3DobjGrp)
            then
            begin
               SetLength(FC3DobjGrp, Length(FC3DobjGrp)+LSVUblocCnt);
               SetLength(FC3DobjPlan, Length(FC3DobjPlan)+LSVUblocCnt);
               SetLength(FC3DobjAtmosph, length(FC3DobjAtmosph)+LSVUblocCnt);
               SetLength(FC3DobjAster, Length(FC3DobjAster)+LSVUblocCnt);
               SetLength(FC3DobjPlanGrav, Length(FC3DobjPlanGrav)+LSVUblocCnt);
               SetLength(FC3DobjPlanOrbit, Length(FC3DobjPlanOrbit)+LSVUblocCnt);
            end;
            LSVUangleRad:=SDB_obobj[TDMVUorbObjCnt].OO_angle1stDay*FCCdeg2RadM;
            {.asteroid}
            if (SDB_obobj[TDMVUorbObjCnt].OO_type>=oobtpAster_Metall)
               and (SDB_obobj[TDMVUorbObjCnt].OO_type<=oobtpAster_Icy)
            then
            begin
               {.initialize 3d structure}
               FCMoglVM_OObj_Gen(oglvmootAster, TDMVUorbObjCnt);
               FC3DobjAster[TDMVUorbObjCnt].Load3DSFileFrom(FCFoglVMain_Aster_Set(TDMVUorbObjCnt, 0, false));
               {.set material}
               FC3DobjAster[TDMVUorbObjCnt].Material.FrontProperties:=FC3DobjAsterDmp.Material.FrontProperties;
               {.set common data}
               FC3DobjAster[TDMVUorbObjCnt].TurnAngle:=SDB_obobj[TDMVUorbObjCnt].OO_inclAx;
               FC3DobjAster[TDMVUorbObjCnt].scale.X
                  :=FCFcFunc_ScaleConverter(cf3dctAstDiamKmTo3dViewUnit, SDB_obobj[TDMVUorbObjCnt].OO_diam);
               FC3DobjAster[TDMVUorbObjCnt].scale.Y:=FC3DobjAster[TDMVUorbObjCnt].scale.X;
               FC3DobjAster[TDMVUorbObjCnt].scale.Z:=FC3DobjAster[TDMVUorbObjCnt].scale.X;
               {.set distance and location}
               LSVUorbDistUnit:=FCFcFunc_ScaleConverter(cf3dctAUto3dViewUnit,SDB_obobj[TDMVUorbObjCnt].OO_distFrmStar);
               FC3DobjGrp[TDMVUorbObjCnt].Position.X:=cos(LSVUangleRad)*LSVUorbDistUnit;
               FC3DobjGrp[TDMVUorbObjCnt].Position.Y:=0;
               FC3DobjGrp[TDMVUorbObjCnt].Position.Z:=sin(LSVUangleRad)*LSVUorbDistUnit;
               {.set group scale}
               FC3DobjGrp[TDMVUorbObjCnt].CubeSize:=FC3DobjAster[TDMVUorbObjCnt].scale.X*50;
               {.displaying}
               FC3DobjGrp[TDMVUorbObjCnt].Visible:=true;
               FC3DobjPlan[TDMVUorbObjCnt].Visible:=false;
               FC3DobjAster[TDMVUorbObjCnt].Visible:=true;
               {.set orbits}
               FCMoglVM_Orbits_Gen(oglvmotpPlanet, TDMVUorbObjCnt, 0, 0, LSVUorbDistUnit);
               {.space units in orbit of current object}
               FCMoglVM_OObjSpUn_inOrbit(TDMVUorbObjCnt, 0, 0, true);
            end //==END== if (OO_type>=oobtpAster_Metall) and (OO_type<=oobtpAster_Icy) ==//
            {.planet}
            else if (SDB_obobj[TDMVUorbObjCnt].OO_type>=oobtpPlan_Tellu_EarthH0H1)
                    and (SDB_obobj[TDMVUorbObjCnt].OO_type<=oobtpPlan_Supergiant1)
            then
            begin
               {.initialize 3d structure}
               FCMoglVM_OObj_Gen(oglvmootNorm, TDMVUorbObjCnt);
               {.inclination}
               FC3DobjPlan[TDMVUorbObjCnt].RollAngle:=SDB_obobj[TDMVUorbObjCnt].OO_inclAx;
               {.set scale}
               FC3DobjPlan[TDMVUorbObjCnt].scale.X
                  :=FCFcFunc_ScaleConverter(cf3dctKmTo3dViewUnit,SDB_obobj[TDMVUorbObjCnt].OO_diam);
               FC3DobjPlan[TDMVUorbObjCnt].scale.Y:=FC3DobjPlan[TDMVUorbObjCnt].scale.X;
               FC3DobjPlan[TDMVUorbObjCnt].scale.Z:=FC3DobjPlan[TDMVUorbObjCnt].scale.X;
               {.set distance and location}
               LSVUorbDistUnit:=FCFcFunc_ScaleConverter(cf3dctAUto3dViewUnit,SDB_obobj[TDMVUorbObjCnt].OO_distFrmStar);
               FC3DobjGrp[TDMVUorbObjCnt].Position.X:=cos(LSVUangleRad)*LSVUorbDistUnit;
               FC3DobjGrp[TDMVUorbObjCnt].Position.Y:=0;
               FC3DobjGrp[TDMVUorbObjCnt].Position.Z:=sin(LSVUangleRad)*LSVUorbDistUnit;
               {.set group scale}
               FC3DobjGrp[TDMVUorbObjCnt].CubeSize:=FC3DobjPlan[TDMVUorbObjCnt].scale.X*2;
               {.set atmosphere}
               if (
                     ((SDB_obobj[TDMVUorbObjCnt].OO_type in [oobtpPlan_Tellu_EarthH0H1..oobtpPlan_Icy_CallistoH3H4Atm0]))
                     and
                     (SDB_obobj[TDMVUorbObjCnt].OO_atmPress>0)
                  )
                  or (SDB_obobj[TDMVUorbObjCnt].OO_type in [oobtpPlan_Gas_Uranus..oobtpPlan_Supergiant1])
               then
               begin
                  FCMoglVMain_Atmosph_SetCol(TDMVUorbObjCnt, 0, 0);
                  FC3DobjAtmosph[TDMVUorbObjCnt].Sun:=FCWinMain.FCGLSSM_Light;
                  if SDB_obobj[TDMVUorbObjCnt].OO_type<oobtpPlan_Gas_Uranus
                  then FC3DobjAtmosph[TDMVUorbObjCnt].Opacity
                     :=FCFoglVMain_CloudsCov_Conv2AtmOp(SDB_obobj[TDMVUorbObjCnt].OO_cloudsCov)
                  else FC3DobjAtmosph[TDMVUorbObjCnt].Opacity:=FCFoglVMain_CloudsCov_Conv2AtmOp(-1);
                  FC3DobjAtmosph[TDMVUorbObjCnt].Visible:=true;
               end;
               {.texturing}
               FCMoglVMain_MapTex_Assign(TDMVUorbObjCnt, 0, 0);
               {.satellites}
               TDMVUsatTtlInDS:=Length(SDB_obobj[TDMVUorbObjCnt].OO_satList)-1;
               if TDMVUsatTtlInDS>0
               then
               begin
                  TDMVUsatIdx:=1;
                  while TDMVUsatIdx<=TDMVUsatTtlInDS do
                  begin
                     inc(TDMVUsatCnt);
                     {.set the 3d object arrays, if needed}
                     if TDMVUsatCnt >= Length(FC3DobjSatGrp) then
                     begin
                        SetLength(FC3DobjSatGrp, Length(FC3DobjSatGrp)+LSVUblocCnt);
                        SetLength(FC3DobjSat, Length(FC3DobjSat)+LSVUblocCnt);
                        SetLength(FC3DobjSatAtmosph, length(FC3DobjSatAtmosph)+LSVUblocCnt);
                        SetLength(FC3DobjSatAster, Length(FC3DobjSatAster)+LSVUblocCnt);
                        SetLength(FC3DobjSatGrav, Length(FC3DobjSatGrav)+LSVUblocCnt);
                        SetLength(FC3DobjSatOrbit, Length(FC3DobjSatOrbit)+LSVUblocCnt);
                     end;
                     LSVUangleRad:=SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_angle1stDay*FCCdeg2RadM;
                     {.for a satellite asteroid}
                     if SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_type<oobtpSat_Tellu_Lunar
                     then
                     begin
                        {.initialize 3d structure}
                        FCMoglVM_OObj_Gen(oglvmootSatAster, TDMVUsatCnt);
                        {.initialize 3d structure}
                        FC3DobjSatAster[TDMVUsatCnt].Load3DSFileFrom
                           (FCFoglVMain_Aster_Set(TDMVUorbObjCnt, TDMVUsatIdx, true));
                        {.set material}
                        FC3DobjSatAster[TDMVUsatCnt].Material.FrontProperties:=FC3DobjAsterDmp.Material.FrontProperties;
                        {.set axial tilt}
                        FC3DobjSatAster[TDMVUsatCnt].TurnAngle:=SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_inclAx;
                        {.set scale}
                        FC3DobjSatAster[TDMVUsatCnt].scale.X
                           :=FCFcFunc_ScaleConverter
                              (
                                 cf3dctAstDiamKmTo3dViewUnit
                                 , SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx]
                                    .OOS_diam
                              );
                        FC3DobjSatAster[TDMVUsatCnt].scale.Y:=FC3DobjSatAster[TDMVUsatCnt].scale.X;
                        FC3DobjSatAster[TDMVUsatCnt].scale.Z:=FC3DobjSatAster[TDMVUsatCnt].scale.X;
                        {.set distance and location}
                        LSVUsatDistUnit:=FCFcFunc_ScaleConverter
                           (
                              cf3dctKmTo3dViewUnit
                              ,SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx]
                                 .OOS_distFrmOOb*1000
                           );
                        FC3DobjSatGrp[TDMVUsatCnt].Position.X
                           :=FC3DobjGrp[TDMVUorbObjCnt].Position.X+(cos(LSVUangleRad)*LSVUsatDistUnit);
                        FC3DobjSatGrp[TDMVUsatCnt].Position.Y:=0;
                        FC3DobjSatGrp[TDMVUsatCnt].Position.Z
                           :=FC3DobjGrp[TDMVUorbObjCnt].Position.Z+(sin(LSVUangleRad)*LSVUsatDistUnit);
                        {.set group scale}
                        FC3DobjSatGrp[TDMVUsatCnt].CubeSize:=FC3DobjSatAster[TDMVUsatCnt].scale.X*50;
                        {.displaying}
                        FC3DobjSatGrp[TDMVUsatCnt].Visible:=true;
                        FC3DobjSat[TDMVUsatCnt].Visible:=false;
                        FC3DobjSatAster[TDMVUsatCnt].Visible:=true;
                     end //==END== if ...OOS_type<oobtpSat_Tellu_Lunar ==//
                     {.for a satellite planetoid}
                     else if (SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_type>oobtpSat_Aster_Icy)
                        and (SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_type<oobtpRing_Metall)
                     then
                     begin
                        {.initialize 3d structure}
                        FCMoglVM_OObj_Gen(oglvmootSatNorm, TDMVUsatCnt);
                        {.axial tilt}
                        FC3DobjSat[TDMVUsatCnt].RollAngle
                           :=SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_inclAx;
                        {.set scale}
                        FC3DobjSat[TDMVUsatCnt].scale.X
                           :=FCFcFunc_ScaleConverter
                              (
                                 cf3dctKmTo3dViewUnit
                                 ,SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_diam
                              );
                        FC3DobjSat[TDMVUsatCnt].scale.Y:=FC3DobjSat[TDMVUsatCnt].scale.X;
                        FC3DobjSat[TDMVUsatCnt].scale.Z:=FC3DobjSat[TDMVUsatCnt].scale.X;
                        {.set distance and location}
                        LSVUsatDistUnit:=FCFcFunc_ScaleConverter
                           (
                              cf3dctKmTo3dViewUnit
                              ,SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx]
                                 .OOS_distFrmOOb*1000
                           );
                        FC3DobjSatGrp[TDMVUsatCnt].Position.X
                           :=FC3DobjGrp[TDMVUorbObjCnt].Position.X+(cos(LSVUangleRad)*LSVUsatDistUnit);
                        FC3DobjSatGrp[TDMVUsatCnt].Position.Y:=0;
                        FC3DobjSatGrp[TDMVUsatCnt].Position.Z
                           :=FC3DobjGrp[TDMVUorbObjCnt].Position.Z+(sin(LSVUangleRad)*LSVUsatDistUnit);
                        {.set group scale}
                        FC3DobjSatGrp[TDMVUsatCnt].CubeSize:=FC3DobjSat[TDMVUsatCnt].scale.X*2;
                        {.set atmosphere}
                        if (SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_type in [oobtpSat_Tellu_Io..oobtpSat_Icy_Callisto])
                           and (SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_atmPress>0)
                        then
                        begin
                           FCMoglVMain_Atmosph_SetCol(TDMVUorbObjCnt, TDMVUsatIdx, TDMVUsatCnt);
                           FC3DobjSatAtmosph[TDMVUsatCnt].Sun:=FCWinMain.FCGLSSM_Light;
                           FC3DobjSatAtmosph[TDMVUsatCnt].Opacity
                              :=FCFoglVMain_CloudsCov_Conv2AtmOp(SDB_obobj[TDMVUorbObjCnt].OO_satList[TDMVUsatIdx].OOS_cloudsCov);
                           FC3DobjSatAtmosph[TDMVUsatCnt].Visible:=true;
                        end;
                        {.texturing}
                        FCMoglVMain_MapTex_Assign(TDMVUorbObjCnt, TDMVUsatIdx, TDMVUsatCnt);
                        {.displaying}
                        FC3DobjSatGrp[TDMVUsatCnt].Visible:=true;
                        FC3DobjSat[TDMVUsatCnt].Visible:=true;
                     end; //==END== if OOS_type>oobtpSat_Aster_Icy ==//
                     {.set orbits}
                     FCMoglVM_Orbits_Gen(
                        oglvmotpSat
                        ,TDMVUorbObjCnt
                        ,TDMVUsatIdx
                        ,TDMVUsatCnt
                        ,LSVUsatDistUnit
                        );
                     {.space units in orbit of current object}
                     FCMoglVM_OObjSpUn_inOrbit(TDMVUorbObjCnt, TDMVUsatIdx, TDMVUsatCnt,true);
                     {.set tag values}
                           {satellite index #}
                        FC3DobjSatGrp[TDMVUsatCnt].Tag:=TDMVUsatIdx;
                           {central orbital object linked}
                        FC3DobjSatGrp[TDMVUsatCnt].TagFloat:=TDMVUorbObjCnt;
                     {.put index of the first sat object}
                     if TDMVUsatIdx=1
                     then SDB_obobj[TDMVUorbObjCnt].OO_sat1stOb:=TDMVUsatCnt;
                     inc(TDMVUsatIdx);
                  end; //==END== while TDMVUsatIdx<=TDMVUsatTtlInDS ==//
                  FCV3DttlSat:=TDMVUsatCnt;
               end;//==END== if Length(SDB_obobj[LSVUorbObjCnt].OO_satList>1) ==//
               {.displaying}
               FC3DobjGrp[TDMVUorbObjCnt].Visible:=true;
               FC3DobjPlan[TDMVUorbObjCnt].Visible:=true;
               {.set orbits}
               FCMoglVM_Orbits_Gen(oglvmotpPlanet, TDMVUorbObjCnt, 0, 0, LSVUorbDistUnit);
               {.space units in orbit of current object}
               FCMoglVM_OObjSpUn_inOrbit(TDMVUorbObjCnt, 0, 0, true);
            end; //==END== else if (SDB_obobj[LSVUorbObjCnt].OO_type>=oobtpPlan_Tellu...//
            inc(TDMVUorbObjCnt);
         end; //==END== while LSVUorbObjCnt<=LSVUorbObjInTtl ==//
      end; //==END== with FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB] ==//
      FCV3DttlOobj:=TDMVUorbObjCnt-1;
   end; //==END==if Length(FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB].SDB_obobj)>1==//
   SetLength(FC3DobjGrp, TDMVUorbObjCnt+1);
   SetLength(FC3DobjPlan, TDMVUorbObjCnt+1);
   SetLength(FC3DobjAtmosph, TDMVUorbObjCnt+1);
   SetLength(FC3DobjAster, TDMVUorbObjCnt+1);
   SetLength(FC3DobjPlanOrbit, TDMVUorbObjCnt+1);
   SetLength(FC3DobjPlanGrav, TDMVUorbObjCnt+1);
   {.space units display in free space}
   MVUentCnt:=0;
   while MVUentCnt<=FCCfacMax do
   begin
      LSVUspUnFacTtl:=Length(FCentities[MVUentCnt].E_spU)-1;
      if LSVUspUnFacTtl>0
      then
      begin
         LSVUspUnCnt:=1;
         while LSVUspUnCnt<=LSVUspUnFacTtl do
         begin
            if (FCentities[MVUentCnt].E_spU[LSVUspUnCnt].SUO_status=susInFreeSpace)
               and (FCentities[MVUentCnt].E_spU[LSVUspUnCnt].SUO_starLoc=LSVUstarId)
            then FCMoglVM_SpUn_Gen(
               scfInSpace
               ,MVUentCnt
               ,LSVUspUnCnt
               )
            else if (FCentities[MVUentCnt].E_spU[LSVUspUnCnt].SUO_status=susDocked)
               and (FCentities[MVUentCnt].E_spU[LSVUspUnCnt].SUO_starLoc=LSVUstarId)
            then FCMoglVM_SpUn_Gen(
               scfDocked
               ,MVUentCnt
               ,LSVUspUnCnt
               );
            inc(LSVUspUnCnt);
         end;
      end;
      inc(MVUentCnt);
   end;
   {.free the AsterDmp}
   if FC3DobjAsterDmp<>nil
   then FC3DobjAsterDmp.Free;
   {.space unit selection}
   if FCV3DttlSpU>0
   then FCV3DselSpU:=1;
   {.relocate correctly non-dynamic objects}
   {.HUDgameTime and all hud children}
   FCWinMain.FCGLSRootMain.Objects.MoveChildLast(1);
   {.camera for main view}
   FCWinMain.FCGLSRootMain.Objects.MoveChildLast(2);
   {.camera controller for main view}
   FCWinMain.FCGLSRootMain.Objects.Children[3].MoveLast;
   {.3d view post setup}
   FCWinMain.FCGLScadencer.Enabled:=true;
   FCWinMain.FCGLSmainView.Show;
   FCMuiWin_UI_Upd(mwupTextWM3dFrame);
   FCMoglVM_CamMain_Target(FCV3DselOobj, true);
end;

procedure FCMoglVM_Orbits_Gen(
   const OBorbitType: TFCEoglvmOrbitTp;
   const OBobjIdx,
         OBsatIdx,
         OBsatCnt: integer;
   const OBdistInUnit: extended
   );
{:Purpose: generate an orbit display at 1/4 and centered around central scene object for
            planet orbit or full and centered around spacecraft for vessel beacon.
            Thanks to Ivan S. for the base code.
    Additions:
      -2009Dec16- *add: satellite orbits.
      -2009Dec09- *some changes since distance change.
      -2009Sep14- *add gravity well orbit.
}
const
   OBsegments=40;
   OBwdth=90/100;
   OBheight=90/100;
var
   OBcount: integer;

   OBrotAngleCos
   ,OBrotAngleSin
   ,OBxCenter
   ,OByCenter
   ,OBtheta
   ,OBxx
   ,OBxxCen
   ,OByy
   ,OByyCen
   ,OBxRotated
   ,OByRotated
   ,OBrotAngle: extended;
begin
   if OBorbitType=oglvmotpPlanet then
   begin
      {.initialize root orbit}
      FC3DobjPlanOrbit[OBobjIdx]:=TGLLines(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLLines));
      FC3DobjPlanOrbit[OBobjIdx].Name:='FCGLSObObjPlantOrb'+IntToStr(OBobjIdx);
      FC3DobjPlanOrbit[OBobjIdx].AntiAliased:=true;
      FC3DobjPlanOrbit[OBobjIdx].Division:=16;
      FC3DobjPlanOrbit[OBobjIdx].LineColor.Alpha:=1;
      FC3DobjPlanOrbit[OBobjIdx].LineColor.Blue:=0.953;
      FC3DobjPlanOrbit[OBobjIdx].LineColor.Green:=0.576;
      FC3DobjPlanOrbit[OBobjIdx].LineColor.Red:=0.478;
      FC3DobjPlanOrbit[OBobjIdx].LinePattern:=65535;
      FC3DobjPlanOrbit[OBobjIdx].LineWidth:=1.5;
      FC3DobjPlanOrbit[OBobjIdx].NodeColor.Color:=clrBlack;
      FC3DobjPlanOrbit[OBobjIdx].NodesAspect:=lnaInvisible;
      FC3DobjPlanOrbit[OBobjIdx].NodeSize:=0.005;
      FC3DobjPlanOrbit[OBobjIdx].SplineMode:=lsmCubicSpline;
      FC3DobjPlanOrbit[OBobjIdx].Nodes.Clear;
      FC3DobjPlanOrbit[OBobjIdx].Scale.X:=(OBdistInUnit*(1.11105+(power(OBdistInUnit,0.333)*0.000004)));
      FC3DobjPlanOrbit[OBobjIdx].Scale.Y:=FC3DobjPlanOrbit[OBobjIdx].Scale.X;
      FC3DobjPlanOrbit[OBobjIdx].Scale.Z:=FC3DobjPlanOrbit[OBobjIdx].Scale.X;
      FC3DobjPlanOrbit[OBobjIdx].TurnAngle:=-FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_angle1stDay;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3DobjPlanOrbit[OBobjIdx].Visible:=true;
      {.nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=90*(OBcount/OBsegments)*FCCdeg2RadM;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3DobjPlanOrbit[OBobjIdx].Nodes.AddNode(OBxRotated, 0, OByRotated);
         FC3DobjPlanOrbit[OBobjIdx].StructureChanged;
         inc(OBcount);
      end;
      {.initialize gravity well orbit}
      FC3DobjPlanGrav[OBobjIdx]:=TGLLines(FC3DobjGrp[OBobjIdx].AddNewChild(TGLLines));
      FC3DobjPlanGrav[OBobjIdx].Name:='FCGLSObObjPlantGravOrb'+IntToStr(OBobjIdx);
      FC3DobjPlanGrav[OBobjIdx].AntiAliased:=true;
      FC3DobjPlanGrav[OBobjIdx].Division:=8;
      FC3DobjPlanGrav[OBobjIdx].LineColor.Color:=clrYellowGreen;
      FC3DobjPlanGrav[OBobjIdx].LinePattern:=65535;
      FC3DobjPlanGrav[OBobjIdx].LineWidth:=1.5;
      FC3DobjPlanGrav[OBobjIdx].NodeColor.Color:=clrBlack;
      FC3DobjPlanGrav[OBobjIdx].NodesAspect:=lnaInvisible;
      FC3DobjPlanGrav[OBobjIdx].NodeSize:=0.005;
      FC3DobjPlanGrav[OBobjIdx].SplineMode:=lsmCubicSpline;
      FC3DobjPlanGrav[OBobjIdx].Nodes.Clear;
      FC3DobjPlanGrav[OBobjIdx].Scale.X:=
         (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_gravSphRad/(CFC3dUnInKm))*2;
      if FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_type
         in [oobtpAster_Metall..oobtpAster_Icy]
      then FC3DobjPlanGrav[OBobjIdx].Scale.X:=FC3DobjPlanGrav[OBobjIdx].Scale.X*6.42;
      FC3DobjPlanGrav[OBobjIdx].Scale.Y:=FC3DobjPlanGrav[OBobjIdx].Scale.X;
      FC3DobjPlanGrav[OBobjIdx].Scale.Z:=FC3DobjPlanGrav[OBobjIdx].Scale.X;
      FC3DobjPlanGrav[OBobjIdx].TurnAngle:=-FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_angle1stDay-0.25;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3DobjPlanGrav[OBobjIdx].Visible:=true;
      {.gravity well nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=360*(OBcount/OBsegments)*FCCdeg2RadM;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3DobjPlanGrav[OBobjIdx].Nodes.AddNode(
            OBxRotated
            ,0
            ,OByRotated
            );
         FC3DobjPlanGrav[OBobjIdx].StructureChanged;
         inc(OBcount);
      end;
   end //==END== if OBorbitType=oglvmotpPlanet ==//
   else if OBorbitType=oglvmotpSat
   then
   begin
      {.initialize root orbit}
      FC3DobjSatOrbit[OBsatCnt]:=TGLLines(FC3DobjGrp[OBobjIdx].AddNewChild(TGLLines));
      FC3DobjSatOrbit[OBsatCnt].Name:='FCGLSsatOrb'+IntToStr(OBsatCnt);
      FC3DobjSatOrbit[OBsatCnt].AntiAliased:=true;
      FC3DobjSatOrbit[OBsatCnt].Division:=16;
      FC3DobjSatOrbit[OBsatCnt].LineColor.Alpha:=1;
      FC3DobjSatOrbit[OBsatCnt].LineColor.Color:=clrCornflowerBlue;//clrMidnightBlue;
      FC3DobjSatOrbit[OBsatCnt].LinePattern:=65535;
      FC3DobjSatOrbit[OBsatCnt].LineWidth:=1.5;
      FC3DobjSatOrbit[OBsatCnt].NodeColor.Color:=clrBlack;
      FC3DobjSatOrbit[OBsatCnt].NodesAspect:=lnaInvisible;
      FC3DobjSatOrbit[OBsatCnt].NodeSize:=0.005;
      FC3DobjSatOrbit[OBsatCnt].SplineMode:=lsmCubicSpline;
      FC3DobjSatOrbit[OBsatCnt].Nodes.Clear;
      FC3DobjSatOrbit[OBsatCnt].Scale.X:=(OBdistInUnit*(1.11105+(power(OBdistInUnit,0.333)/250000)));
      FC3DobjSatOrbit[OBsatCnt].Scale.Y:=FC3DobjSatOrbit[OBsatCnt].Scale.X;
      FC3DobjSatOrbit[OBsatCnt].Scale.Z:=FC3DobjSatOrbit[OBsatCnt].Scale.X;
      FC3DobjSatOrbit[OBsatCnt].TurnAngle
         :=-FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_satList[OBsatIdx].OOS_angle1stDay;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3DobjSatOrbit[OBsatCnt].Visible:=true;
      {.nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=90*(OBcount/OBsegments)*FCCdeg2RadM;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3DobjSatOrbit[OBsatCnt].Nodes.AddNode(
            OBxRotated
            ,0
            ,OByRotated
            );
         FC3DobjSatOrbit[OBsatCnt].StructureChanged;
         inc(OBcount);
      end;
      {.initialize gravity well orbit}
      FC3DobjSatGrav[OBsatCnt]:=TGLLines(FC3DobjSatGrp[OBsatCnt].AddNewChild(TGLLines));
      FC3DobjSatGrav[OBsatCnt].Name:='FCGLSsatGravOrb'+IntToStr(OBsatCnt);
      FC3DobjSatGrav[OBsatCnt].AntiAliased:=true;
      FC3DobjSatGrav[OBsatCnt].Division:=8;
      FC3DobjSatGrav[OBsatCnt].LineColor.Color:=clrGoldenrod;
      FC3DobjSatGrav[OBsatCnt].LinePattern:=65535;
      FC3DobjSatGrav[OBsatCnt].LineWidth:=1.5;
      FC3DobjSatGrav[OBsatCnt].NodeColor.Color:=clrBlack;
      FC3DobjSatGrav[OBsatCnt].NodesAspect:=lnaInvisible;
      FC3DobjSatGrav[OBsatCnt].NodeSize:=0.005;
      FC3DobjSatGrav[OBsatCnt].SplineMode:=lsmCubicSpline;
      FC3DobjSatGrav[OBsatCnt].Nodes.Clear;
      FC3DobjSatGrav[OBsatCnt].Scale.X:=
         (FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_satList[OBsatIdx].OOS_gravSphRad/(CFC3dUnInKm))*2;
      if FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_satList[OBsatIdx].OOS_type
         in [oobtpSat_Aster_Metall..oobtpSat_Aster_Icy]
      then FC3DobjSatGrav[OBsatCnt].Scale.X:=FC3DobjSatGrav[OBsatCnt].Scale.X*6.42;
      FC3DobjSatGrav[OBsatCnt].Scale.Y:=FC3DobjSatGrav[OBsatCnt].Scale.X;
      FC3DobjSatGrav[OBsatCnt].Scale.Z:=FC3DobjSatGrav[OBsatCnt].Scale.X;
      FC3DobjSatGrav[OBsatCnt].TurnAngle
         :=-FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[OBobjIdx].OO_satList[OBsatIdx].OOS_angle1stDay-0.25;
      OBrotAngleCos:=cos(OBrotAngle);
      OBrotAngleSin:=sin(OBrotAngle);
      FC3DobjSatGrav[OBsatCnt].Visible:=true;
      {.gravity well nodes generation}
      OBxCenter:=0;
      OByCenter:=0;
      OBcount:=0;
      OBrotAngle:=DegToRad(0);
      while OBcount<=OBsegments do
      begin
         OBtheta:=360*(OBcount/OBsegments)*FCCdeg2RadM;
         OBxx:=OBxCenter+OBwdth*cos(OBtheta);
         OByy:=OByCenter+OBheight*sin(OBtheta);
         OBxxCen:=OBxx-OBxCenter;
         OByyCen:=OByy-OByCenter;
         OBxRotated:=OBxCenter+(OBxxCen)*OBrotAngleCos-(OByyCen)*OBrotAngleSin;
         OByRotated:=OByCenter+(OBxxCen)*OBRotAngleSin+(OByyCen)*OBRotAngleCos;
         FC3DobjSatGrav[OBsatCnt].Nodes.AddNode(
            OBxRotated
            ,0
            ,OByRotated
            );
         FC3DobjSatGrav[OBsatCnt].StructureChanged;
         inc(OBcount);
      end;
   end; //==END== if OBorbitType=oglvmotpSat ==//
end;

procedure FCMoglVM_OObj_Gen(
   const OOGobjClass: TFCEoglvmOobTp;
   const OOGobjIdx: integer
   );
{:Purpose: generate a 3d objects row of selected index.
    Additions:
      -2010Dec07- *add: intialize the material of planets, if needed.
      -2009Dec14- *add: complete satellite generation.
      -2009Dec12- *mod: delete the method's boolean and replace it by a switch.
                  *add: generate satellite.
      -2009Dec07- *update atmosphere initialization.
}
begin
   if (OOGobjClass=oglvmootNorm)
      or (OOGobjClass=oglvmootAster)
   then
   begin
      {.the object group}
      FC3DobjGrp[OOGobjIdx]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
      FC3DobjGrp[OOGobjIdx].Name:='FCGLSObObjGroup'+IntToStr(OOGobjIdx);
      FC3DobjGrp[OOGobjIdx].CubeSize:=1;
      FC3DobjGrp[OOGobjIdx].Up.X:=0;
      FC3DobjGrp[OOGobjIdx].Up.Y:=1;
      FC3DobjGrp[OOGobjIdx].Up.Z:=0;
      FC3DobjGrp[OOGobjIdx].VisibleAtRunTime:=false;
      FC3DobjGrp[OOGobjIdx].Visible:=false;
      FC3DobjGrp[OOGobjIdx].ShowAxes:=false;
      {.the planet}
      FC3DobjPlan[OOGobjIdx]:=TGLSphere(FC3DobjGrp[OOGobjIdx].AddNewChild(TGLSphere));
      FC3DobjPlan[OOGobjIdx].Name:='FCGLSObObjPlnt'+IntToStr(OOGobjIdx);
      FC3DobjPlan[OOGobjIdx].Radius:=1;
      FC3DobjPlan[OOGobjIdx].Slices:=64;
      FC3DobjPlan[OOGobjIdx].Stacks:=64;
      FC3DobjPlan[OOGobjIdx].Visible:=false;
      FC3DobjPlan[OOGobjIdx].ShowAxes:=false;
      if OOGobjClass=oglvmootNorm
      then
      begin
         FC3DobjPlan[OOGobjIdx].Material.BackProperties.Ambient.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Ambient.Color;
         FC3DobjPlan[OOGobjIdx].Material.BackProperties.Diffuse.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Diffuse.Color;
         FC3DobjPlan[OOGobjIdx].Material.BackProperties.Emission.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Emission.Color;
         FC3DobjPlan[OOGobjIdx].Material.PolygonMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3DobjPlan[OOGobjIdx].Material.BackProperties.Shininess
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Shininess;
         FC3DobjPlan[OOGobjIdx].Material.BackProperties.Specular.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Specular.Color;
         FC3DobjPlan[OOGobjIdx].Material.BlendingMode:=FC3DmatLibSplanT.Materials.Items[0].Material.BlendingMode;
         FC3DobjPlan[OOGobjIdx].Material.FaceCulling:=FC3DmatLibSplanT.Materials.Items[0].Material.FaceCulling;
         FC3DobjPlan[OOGobjIdx].Material.FrontProperties.Ambient:=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Ambient;
         FC3DobjPlan[OOGobjIdx].Material.FrontProperties.Diffuse:=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Diffuse;
         FC3DobjPlan[OOGobjIdx].Material.FrontProperties.Emission
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Emission;
         FC3DobjPlan[OOGobjIdx].Material.PolygonMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3DobjPlan[OOGobjIdx].Material.FrontProperties.Shininess
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Shininess;
         FC3DobjPlan[OOGobjIdx].Material.FrontProperties.Specular
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Specular;
         FC3DobjPlan[OOGobjIdx].Material.MaterialOptions:=FC3DmatLibSplanT.Materials.Items[0].Material.MaterialOptions;
         FC3DobjPlan[OOGobjIdx].Material.Texture.BorderColor.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.BorderColor.Color;
         FC3DobjPlan[OOGobjIdx].Material.Texture.Compression:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.Compression;
         FC3DobjPlan[OOGobjIdx].Material.Texture.DepthTextureMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.DepthTextureMode;
         FC3DobjPlan[OOGobjIdx].Material.Texture.Disabled:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.Disabled;
         FC3DobjPlan[OOGobjIdx].Material.Texture.EnvColor.Color:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.EnvColor.Color;
         FC3DobjPlan[OOGobjIdx].Material.Texture.FilteringQuality
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.FilteringQuality;
         FC3DobjPlan[OOGobjIdx].Material.Texture.ImageAlpha:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.ImageAlpha;
         FC3DobjPlan[OOGobjIdx].Material.Texture.ImageGamma:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.ImageGamma;
         FC3DobjPlan[OOGobjIdx].Material.Texture.MagFilter:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.MagFilter;
         FC3DobjPlan[OOGobjIdx].Material.Texture.MappingMode:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.MappingMode;
         FC3DobjPlan[OOGobjIdx].Material.Texture.MinFilter:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.MinFilter;
         FC3DobjPlan[OOGobjIdx].Material.Texture.NormalMapScale:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.NormalMapScale;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureCompareFunc
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareFunc;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureCompareMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareMode;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureFormat:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureFormat;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureMode:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureMode;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrap:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrap;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapS:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapS;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapT:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapT;
         FC3DobjPlan[OOGobjIdx].Material.Texture.TextureWrapR:=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapR;
      end //==END== if OOGobjClass=oglvmootNorm ==//
      else if OOGobjClass=oglvmootAster
      then
      begin
         {.the asteroid}
         FC3DobjAster[OOGobjIdx]:=TDGLib3dsStaMesh(FC3DobjGrp[OOGobjIdx].AddNewChild(TDGLib3dsStaMesh));
         FC3DobjAster[OOGobjIdx].Name:='FCGLSObObjAster'+IntToStr(OOGobjIdx);
         FC3DobjAster[OOGobjIdx].UseGLSceneBuildList:=False;
         FC3DobjAster[OOGobjIdx].PitchAngle:=90;
         FC3DobjAster[OOGobjIdx].UseShininessPowerHack:=0;
         FC3DobjAster[OOGobjIdx].UseInvertWidingHack:=False;
         FC3DobjAster[OOGobjIdx].UseNormalsHack:=True;
         FC3DobjAster[OOGobjIdx].Scale.SetVector(0.27,0.27,0.27);
      end;
      {.the atmosphere}
      FC3DobjAtmosph[OOGobjIdx]:=TGLAtmosphere(FC3DobjGrp[OOGobjIdx].AddNewChild(TGLAtmosphere));
      FC3DobjAtmosph[OOGobjIdx].Name:='FCGLSObObjAtmos'+IntToStr(OOGobjIdx);
      FC3DobjAtmosph[OOGobjIdx].AtmosphereRadius:=3.55;//3.75;//3.55;
      FC3DobjAtmosph[OOGobjIdx].BlendingMode:=abmOneMinusSrcAlpha;
      FC3DobjAtmosph[OOGobjIdx].HighAtmColor.Color:=clrBlue;
      FC3DobjAtmosph[OOGobjIdx].LowAtmColor.Color:=clrWhite;
      FC3DobjAtmosph[OOGobjIdx].Opacity:=2.1;
      FC3DobjAtmosph[OOGobjIdx].PlanetRadius:=3.395;
      FC3DobjAtmosph[OOGobjIdx].Slices:=64;
      FC3DobjAtmosph[OOGobjIdx].Visible:=false;
   end
   {.satellites}
   else if (OOGobjClass=oglvmootSatNorm)
      or (OOGobjClass=oglvmootSatAster)
   then
   begin
      {.the object group}
      FC3DobjSatGrp[OOGobjIdx]:=TGLDummyCube(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TGLDummyCube));
      FC3DobjSatGrp[OOGobjIdx].Name:='FCGLSsatGrp'+IntToStr(OOGobjIdx);
      FC3DobjSatGrp[OOGobjIdx].CubeSize:=1;
      FC3DobjSatGrp[OOGobjIdx].Up.X:=0;
      FC3DobjSatGrp[OOGobjIdx].Up.Y:=1;
      FC3DobjSatGrp[OOGobjIdx].Up.Z:=0;
      FC3DobjSatGrp[OOGobjIdx].VisibleAtRunTime:=false;
      FC3DobjSatGrp[OOGobjIdx].Visible:=false;
      FC3DobjSatGrp[OOGobjIdx].ShowAxes:=false;
      {.the planet}
      FC3DobjSat[OOGobjIdx]:=TGLSphere(FC3DobjSatGrp[OOGobjIdx].AddNewChild(TGLSphere));
      FC3DobjSat[OOGobjIdx].Name:='FCGLSsatPlnt'+IntToStr(OOGobjIdx);
      FC3DobjSat[OOGobjIdx].Radius:=1;
      FC3DobjSat[OOGobjIdx].Slices:=64;
      FC3DobjSat[OOGobjIdx].Stacks:=64;
      FC3DobjSat[OOGobjIdx].Visible:=false;
      FC3DobjSat[OOGobjIdx].ShowAxes:=false;
      if OOGobjClass=oglvmootSatNorm
      then
      begin
         FC3DobjSat[OOGobjIdx].Material.BackProperties.Ambient.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Ambient.Color;
         FC3DobjSat[OOGobjIdx].Material.BackProperties.Diffuse.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Diffuse.Color;
         FC3DobjSat[OOGobjIdx].Material.BackProperties.Emission.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Emission.Color;
         FC3DobjSat[OOGobjIdx].Material.PolygonMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3DobjSat[OOGobjIdx].Material.BackProperties.Shininess
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Shininess;
         FC3DobjSat[OOGobjIdx].Material.BackProperties.Specular.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BackProperties.Specular.Color;
         FC3DobjSat[OOGobjIdx].Material.BlendingMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.BlendingMode;
         FC3DobjSat[OOGobjIdx].Material.FaceCulling
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FaceCulling;
         FC3DobjSat[OOGobjIdx].Material.FrontProperties.Ambient
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Ambient;
         FC3DobjSat[OOGobjIdx].Material.FrontProperties.Diffuse
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Diffuse;
         FC3DobjSat[OOGobjIdx].Material.FrontProperties.Emission
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Emission;
         FC3DobjSat[OOGobjIdx].Material.PolygonMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.PolygonMode;
         FC3DobjSat[OOGobjIdx].Material.FrontProperties.Shininess
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Shininess;
         FC3DobjSat[OOGobjIdx].Material.FrontProperties.Specular
            :=FC3DmatLibSplanT.Materials.Items[0].Material.FrontProperties.Specular;
         FC3DobjSat[OOGobjIdx].Material.MaterialOptions
            :=FC3DmatLibSplanT.Materials.Items[0].Material.MaterialOptions;
         FC3DobjSat[OOGobjIdx].Material.Texture.BorderColor.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.BorderColor.Color;
         FC3DobjSat[OOGobjIdx].Material.Texture.Compression
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.Compression;
         FC3DobjSat[OOGobjIdx].Material.Texture.DepthTextureMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.DepthTextureMode;
         FC3DobjSat[OOGobjIdx].Material.Texture.Disabled
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.Disabled;
         FC3DobjSat[OOGobjIdx].Material.Texture.EnvColor.Color
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.EnvColor.Color;
         FC3DobjSat[OOGobjIdx].Material.Texture.FilteringQuality
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.FilteringQuality;
         FC3DobjSat[OOGobjIdx].Material.Texture.ImageAlpha
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.ImageAlpha;
         FC3DobjSat[OOGobjIdx].Material.Texture.ImageGamma
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.ImageGamma;
         FC3DobjSat[OOGobjIdx].Material.Texture.MagFilter
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.MagFilter;
         FC3DobjSat[OOGobjIdx].Material.Texture.MappingMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.MappingMode;
         FC3DobjSat[OOGobjIdx].Material.Texture.MinFilter
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.MinFilter;
         FC3DobjSat[OOGobjIdx].Material.Texture.NormalMapScale
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.NormalMapScale;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureCompareFunc
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareFunc;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureCompareMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureCompareMode;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureFormat
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureFormat;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureMode
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureMode;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrap
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrap;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapS
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapS;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapT
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapT;
         FC3DobjSat[OOGobjIdx].Material.Texture.TextureWrapR
            :=FC3DmatLibSplanT.Materials.Items[0].Material.Texture.TextureWrapR;
      end //==END== if OOGobjClass=oglvmootSatNorm ==//
      else if OOGobjClass=oglvmootSatAster then
      begin
         {.the asteroid}
         FC3DobjSatAster[OOGobjIdx]:=TDGLib3dsStaMesh(FC3DobjSatGrp[OOGobjIdx].AddNewChild(TDGLib3dsStaMesh));
         FC3DobjSatAster[OOGobjIdx].Name:='FCGLSsatAster'+IntToStr(OOGobjIdx);
         FC3DobjSatAster[OOGobjIdx].UseGLSceneBuildList:=False;
         FC3DobjSatAster[OOGobjIdx].PitchAngle:=90;
         FC3DobjSatAster[OOGobjIdx].UseShininessPowerHack:=0;
         FC3DobjSatAster[OOGobjIdx].UseInvertWidingHack:=False;
         FC3DobjSatAster[OOGobjIdx].UseNormalsHack:=True;
         FC3DobjSatAster[OOGobjIdx].Scale.SetVector(0.27,0.27,0.27);
      end;
      {.the atmosphere}
      FC3DobjSatAtmosph[OOGobjIdx]:=TGLAtmosphere(FC3DobjSatGrp[OOGobjIdx].AddNewChild(TGLAtmosphere));
      FC3DobjSatAtmosph[OOGobjIdx].Name:='FCGLSsatAtmos'+IntToStr(OOGobjIdx);
      FC3DobjSatAtmosph[OOGobjIdx].AtmosphereRadius:=3.55;//3.75;//3.55;
      FC3DobjSatAtmosph[OOGobjIdx].BlendingMode:=abmOneMinusSrcAlpha;
      FC3DobjSatAtmosph[OOGobjIdx].HighAtmColor.Color:=clrBlue;
      FC3DobjSatAtmosph[OOGobjIdx].LowAtmColor.Color:=clrWhite;
      FC3DobjSatAtmosph[OOGobjIdx].Opacity:=2.1;
      FC3DobjSatAtmosph[OOGobjIdx].PlanetRadius:=3.395;
      FC3DobjSatAtmosph[OOGobjIdx].Slices:=64;
      FC3DobjSatAtmosph[OOGobjIdx].Visible:=false;
   end; //==END== else if (OOGobjClass=oglvmootSatNorm) or (=oglvmootSatAster) ==//
end;

procedure FCMoglVM_OObjSpUn_ChgeScale(const OOSUCSobjIdx: integer);
{:Purpose: change space unit scale according to it's distance, it's a fast&dirty fix.
    Additions:
      -2009Dec10- *bugfix: don't make a cumulative size change anymore.
}
var
   OOSUCSdmpSize: extended;
begin
   if FC3DobjSpUnit[OOSUCSobjIdx].Hint=''
   then
   begin
      FC3DobjSpUnit[OOSUCSobjIdx].Hint:=floattostr(FC3DobjSpUnit[OOSUCSobjIdx].Scale.X);
      OOSUCSdmpSize:=FC3DobjSpUnit[OOSUCSobjIdx].Scale.X;
   end
   else OOSUCSdmpSize:=StrToFloat(FC3DobjSpUnit[OOSUCSobjIdx].Hint);
   FC3DobjSpUnit[OOSUCSobjIdx].Scale.X
      :=OOSUCSdmpSize*FC3DobjSpUnit[OOSUCSobjIdx].DistanceTo(FCWinMain.FCGLSStarMain)/CFC3dUnInAU*8;
   FC3DobjSpUnit[OOSUCSobjIdx].Scale.Y:=FC3DobjSpUnit[OOSUCSobjIdx].Scale.X;
   FC3DobjSpUnit[OOSUCSobjIdx].Scale.Z:=FC3DobjSpUnit[OOSUCSobjIdx].Scale.X;
end;

procedure FCMoglVM_OObjSpUn_inOrbit(
   const OOSUIOUoobjIdx,
         OOSUIOUsatIdx,
         OOSUIOUsatObjIdx: integer;
   const OOSUIOUmustGen: boolean
   );
{:Purpose: display space units in orbit of a selected orbital object.
    Additions:
      -2010Sep19- *fix: space units in orbits are linked to OO_inOrbitCnt/OOS_inOrbitCnt and not the length-1 which is always equal to 45.
      -2010Sep15- *mod: some refactoring.
                  *add: entities code.
      -2009Dec20- *add: display space units in orbit of satellites too.
      -2009Dec01- *optimization: relative to changes in space unit gen procedure.
}
var
   OOSUIOfac,
   OOSUIOspUinOrb,
   OOSUIOspUnCnt,
   OOSUIOspUntOwnIdx,
   OOSUIOspUnObjIdx: integer;
begin
   with FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar] do
   begin
      if OOSUIOUsatIdx=0
      then
      begin
         OOSUIOspUinOrb:=SDB_obobj[OOSUIOUoobjIdx].OO_inOrbitCnt;
         if OOSUIOspUinOrb>0
         then
         begin
            OOSUIOspUnCnt:=1;
            while OOSUIOspUnCnt<=OOSUIOspUinOrb do
            begin
               OOSUIOfac:=SDB_obobj[OOSUIOUoobjIdx].OO_inOrbitList[OOSUIOspUnCnt].OU_faction;
               OOSUIOspUntOwnIdx:=SDB_obobj[OOSUIOUoobjIdx].OO_inOrbitList[OOSUIOspUnCnt].OU_spUn;
               if OOSUIOUmustGen
               then
               begin
                  FCMoglVM_SpUn_Gen(
                     scfInOrbit
                     ,OOSUIOfac
                     ,OOSUIOspUntOwnIdx
                     );
                  OOSUIOspUnObjIdx:=FCV3DttlSpU;
               end
               else if not OOSUIOUmustGen
               then OOSUIOspUnObjIdx:=FCentities[OOSUIOfac].E_spU[OOSUIOspUntOwnIdx].SUO_3dObjIdx;
               if FC3DobjGrp[OOSUIOUoobjIdx].Position.X>0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.X
                  :=FC3DobjGrp[OOSUIOUoobjIdx].Position.X-(0.9*cos(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjPlanGrav[OOSUIOUoobjIdx].Scale.X)
               else if FC3DobjGrp[OOSUIOUoobjIdx].Position.X<0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.X
                  :=FC3DobjGrp[OOSUIOUoobjIdx].Position.X+(0.9*cos(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjPlanGrav[OOSUIOUoobjIdx].Scale.X);
               if FC3DobjGrp[OOSUIOUoobjIdx].Position.Z>0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.Z
                  :=FC3DobjGrp[OOSUIOUoobjIdx].Position.Z-(0.9*sin(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjPlanGrav[OOSUIOUoobjIdx].Scale.X)
               else if FC3DobjGrp[OOSUIOUoobjIdx].Position.Z<0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.Z
                  :=FC3DobjGrp[OOSUIOUoobjIdx].Position.Z+(0.9*sin(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjPlanGrav[OOSUIOUoobjIdx].Scale.X);
               FC3DobjSpUnit[OOSUIOspUnObjIdx].PointTo(
                  FC3DobjGrp[OOSUIOUoobjIdx]
                  ,FC3DobjGrp[OOSUIOUoobjIdx].Position.AsVector
                  );
               FCentities[OOSUIOfac].E_spU[OOSUIOspUntOwnIdx].SUO_locStarX:=FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.X;
               FCentities[OOSUIOfac].E_spU[OOSUIOspUntOwnIdx].SUO_locStarZ:=FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.Z;
               inc(OOSUIOspUnCnt);
            end; //==END== while OOSUIOUspUnCnt<=OOSUIOUspUinOrb ==//
         end; //==END== if OOSUIOUspUinOrb>0 ==//
      end //==END== if OOSUIOUsatIdx=0 ==//
      else if OOSUIOUsatIdx>0
      then
      begin
         OOSUIOspUinOrb:=SDB_obobj[OOSUIOUoobjIdx].OO_satList[OOSUIOUsatIdx].OOS_inOrbitCnt;
         if OOSUIOspUinOrb>0
         then
         begin
            OOSUIOspUnCnt:=1;
            while OOSUIOspUnCnt<=OOSUIOspUinOrb do
            begin
               OOSUIOfac:=SDB_obobj[OOSUIOUoobjIdx].OO_satList[OOSUIOUsatIdx].OOS_inOrbitList[OOSUIOspUnCnt].OU_faction;
               OOSUIOspUntOwnIdx:=SDB_obobj[OOSUIOUoobjIdx].OO_satList[OOSUIOUsatIdx].OOS_inOrbitList[OOSUIOspUnCnt].OU_spUn;
               if OOSUIOUmustGen
               then
               begin
                  FCMoglVM_SpUn_Gen(
                     scfInOrbit
                     ,OOSUIOfac
                     ,OOSUIOspUntOwnIdx
                     );
                  OOSUIOspUnObjIdx:=FCV3DttlSpU;
               end
               else if not OOSUIOUmustGen
               then OOSUIOspUnObjIdx:=FCentities[OOSUIOfac].E_spU[OOSUIOspUntOwnIdx].SUO_3dObjIdx;
               if FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.X>0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.X
                  :=FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.X-(0.9*cos(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjSatGrav[OOSUIOUsatObjIdx].Scale.X)
               else if FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.X<0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.X
                  :=FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.X+(0.9*cos(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjSatGrav[OOSUIOUsatObjIdx].Scale.X);
               if FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.Z>0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.Z
                  :=FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.Z-(0.9*sin(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjSatGrav[OOSUIOUsatObjIdx].Scale.X)
               else if FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.Z<0
               then FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.Z
                  :=FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.Z+(0.9*sin(8*OOSUIOspUnCnt*FCCdeg2RadM)*FC3DobjSatGrav[OOSUIOUsatObjIdx].Scale.X);
               FC3DobjSpUnit[OOSUIOspUnObjIdx].PointTo(
                  FC3DobjSatGrp[OOSUIOUsatObjIdx]
                  ,FC3DobjSatGrp[OOSUIOUsatObjIdx].Position.AsVector
                  );
               FCentities[OOSUIOfac].E_spU[OOSUIOspUntOwnIdx].SUO_locStarX:=FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.X;
               FCentities[OOSUIOfac].E_spU[OOSUIOspUntOwnIdx].SUO_locStarZ:=FC3DobjSpUnit[OOSUIOspUnObjIdx].Position.Z;
               inc(OOSUIOspUnCnt);
            end; //==END== while OOSUIOUspUnCnt<=OOSUIOUspUnFacTtl ==//
         end; //==END== if OOSUIOUspUnFacTtl>0 ==//
      end; //==END== else if OOSUIOUsatIdx>0 ==//
   end; //==END== with FCDBstarSys[CFVstarSysIdDB].SS_star[CFVstarIdDB] ==//
end;

function FCFoglVM_SatObj_Search(const SOSidxDBoob, SOSidxDBsat: integer): integer;
{:Purpose: return the satellite object index of the choosen satellite in the current view.
    Additions:
}
var
   SOSdmpObjIdx
   ,SOSdmpSatObjIdx
   ,SOScnt
   ,SOSttl: integer;
begin
   SOSdmpObjIdx:=FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SOSidxDBoob].OO_sat1stOb;
   SOScnt:=1;
   SOSttl:=length(FCDBsSys[FCV3DselSsys].SS_star[FCV3DselStar].SDB_obobj[SOSidxDBoob].OO_satList)-1;
   Result:=0;
   while SOScnt<=SOSttl do
   begin
      SOSdmpSatObjIdx:=SOSdmpObjIdx+SOScnt-1;
      if FC3DobjSatGrp[SOSdmpSatObjIdx].Tag=SOSidxDBsat
      then
      begin
         Result:=SOSdmpSatObjIdx;
         Break;
      end;
      inc(SOScnt);
   end;
end;

procedure FCMoglVM_SpUn_Gen(
   const SUGstatus: TFCEoglvmSCfrom;
   const SUGfac
         ,SUGspUnOwnIdx: integer
   );
{:Purpose: generate a space unit.
    Additions:
      -2010Sep14- *add: SUGfac parameter, faction index #.
                  *add: entities code.
      -2010Sep02- *add: use a local variable for the design #.
      -2010Apr25- *add: generate docked space units.
      -2009Dec01- *bugfix: crash with space unit not in orbit (in free space for example).
      -2009Nov15- *change switch behavior w/oglvmscfPlayerInOrbit and oglvmscfPlayer.
      -2009Sep19- *add SUGspUnFacIdx, faction owned space unit index.
                  *add location (when not in orbit).
}
var
   SUGdesgn: integer;
begin
   if (SUGstatus=scfDocked)
      or (SUGstatus=scfInOrbit)
      or (SUGstatus=scfInSpace)
   then
   begin
      inc(FCV3DttlSpU);
      SetLength(FC3DobjSpUnit, FCV3DttlSpU+1);
      SUGdesgn:=FCFspuF_Design_getDB(FCentities[SUGfac].E_spU[SUGspUnOwnIdx].SUO_designId);
      {.create the object and set some basic data}
      FC3DobjSpUnit[FCV3DttlSpU]:=TDGLib3dsStaMesh(FCWinMain.FCGLSRootMain.Objects.AddNewChild(TDGLib3dsStaMesh));
      FC3DobjSpUnit[FCV3DttlSpU].Load3DSFileFrom(FCVpathRsrc+'obj-3ds-scraft\'+FCDBscDesigns[SUGdesgn].SCD_intStrClone.SCIS_token+'.3ds');
      {.set the space unit 3d scales}
      FC3DobjSpUnit[FCV3DttlSpU].Scale.X:=FCFcFunc_ScaleConverter(cf3dctMeterToSpUnitSize, SUGdesgn);
      FC3DobjSpUnit[FCV3DttlSpU].Scale.Y:=FC3DobjSpUnit[FCV3DttlSpU].Scale.X;
      FC3DobjSpUnit[FCV3DttlSpU].Scale.Z:=FC3DobjSpUnit[FCV3DttlSpU].Scale.X;
      {.in case of the space unit is in free space}
      if SUGstatus=scfInSpace
      then
      begin
         FC3DobjSpUnit[FCV3DttlSpU].Position.X:=FCentities[SUGfac].E_spU[SUGspUnOwnIdx].SUO_locStarX;
         FC3DobjSpUnit[FCV3DttlSpU].Position.Z:=FCentities[SUGfac].E_spU[SUGspUnOwnIdx].SUO_locStarZ;
      end;
      {.add faction id#}
      FC3DobjSpUnit[FCV3DttlSpU].Tag:=SUGfac;
      {.add owned space unit index}
      FC3DobjSpUnit[FCV3DttlSpU].TagFloat:=SUGspUnOwnIdx;
      FCentities[SUGfac].E_spU[SUGspUnOwnIdx].SUO_3dObjIdx:=FCV3DttlSpU;
      {.finalization}
      FC3DobjSpUnit[FCV3DttlSpU].Material.Texture.Disabled:=false;
      if (SUGstatus<>scfDocked)
      then FC3DobjSpUnit[FCV3DttlSpU].Visible:=true
      else FC3DobjSpUnit[FCV3DttlSpU].Visible:=false;
   end;
end;

procedure FCMoglVMain_SpUnits_SetInitSize(const SUSIZresetSize: boolean);
{:Purpose: restore the initial size of the targeted space unit.
    Additions:
}
begin
   FC3DobjSpUnit[FCV3DselSpU].Scale.X:=FCV3DspUnSiz;
   FC3DobjSpUnit[FCV3DselSpU].Scale.Y:=FC3DobjSpUnit[FCV3DselSpU].Scale.X;
   FC3DobjSpUnit[FCV3DselSpU].Scale.Z:=FC3DobjSpUnit[FCV3DselSpU].Scale.X;
   if SUSIZresetSize
   then FCV3DspUnSiz:=0;
end;

procedure FCMoglVM_SpUn_SetZoomScale;
{:Purpose: resize the targeted space unit correctly, depending on distance.
    Additions:
}
begin
   FC3DobjSpUnit[FCV3DselSpU].Scale.X
      :=FCV3DspUnSiz*
         (1+
            (
               (1/(fcwinmain.FCGLSCamMainViewGhost.DistanceToTarget/fcwinmain.FCGLSCamMainViewGhost.TargetObject.Scale.X))
               *150
            )
         );
   FC3DobjSpUnit[FCV3DselSpU].Scale.Y:=FC3DobjSpUnit[FCV3DselSpU].Scale.X;
   FC3DobjSpUnit[FCV3DselSpU].Scale.Z:=FC3DobjSpUnit[FCV3DselSpU].Scale.X;
end;

end.
