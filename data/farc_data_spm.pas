{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: SPM - data unit

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
unit farc_data_spm;

interface

//use

{.SPM areas list}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMarea=(
      {.Administration (or ADMIN)}
      dgADMIN
      {.Economy (ECON)}
      ,dgECON
      {.Medical Care (MEDCA)}
      ,dgMEDCA
      {.Society (SOC)}
      ,dgSOC
      {.Space Politics (SPOL)}
      ,dgSPOL
      {.Spirituality (SPI)}
      ,dgSPI
      );

       {.SPMi requirements}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMiReq=(
      dgBuilding
      ,dgFacData
      ,dgTechSci
      ,dgUC
      );

       {.SPMi requirement types for faction data requirement}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMiReqFDat=(
      rfdFacLv1
      ,rfdFacLv2
      ,rfdFacLv3
      ,rfdFacLv4
      ,rfdFacLv5
      ,rfdFacLv6
      ,rfdFacLv7
      ,rfdFacLv8
      ,rfdFacLv9
      ,rfdFacStab
      ,rfdInstrLv
      ,rfdLifeQ
      ,rfdEquil
      );

      {.SPMi requirement types for UC requirement}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMiReqUC=(
      {.fixed value}
      dgFixed
      ,dgFixed_yr
      {.calculation - population}
      ,dgCalcPop
      ,dgCalcPop_yr
      {.calculation - colonies}
      ,dgCalcCol
      ,dgCalcCol_yr
      );

      {:REFERENCES LIST
   - spmdb.xml
   - TFCRdgCustomEffect
}
///<summary>
///   SPMi custom effects
///</summary>
type TFCEdgSPMiCustomEffects=(
   sceEIOUT
   ,sceREVTX
   );

//==END PUBLIC ENUM=========================================================================

{.SPMi influences sub-data structure}
   type TFCRdgSPMiInfl= record
      {.token of the SPMi}
      SPMII_token: string[20];
      {.influence factor}
      SPMII_influence: integer;
   end;

{.SPMi requirements sub-data structure}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCRdgSPMiReq= record
      case SPMIR_type: TFCEdgSPMiReq of
         {.building requirement}
         dgBuilding:
            {.infrastructure token}
            (SPMIR_infToken: string[20];
            {.percent of colonies which have one}
            SPMIR_percCol: integer);
         {.faction data requirement}
         dgFacData:
            (SPMIR_datTp: TFCEdgSPMiReqFDat;
            SPMIR_datValue: integer);
         {.technoscience requirement}
         dgTechSci:
            {.technoscience token}
            (SPMIR_tsToken: string[20];
            {.mastered level}
            SPMIR_masterLvl: integer);
         {.UC requirement}
         dgUC:
            {.technoscience token}
            (SPMIR_ucMethod: TFCEdgSPMiReqUC;
            {.mastered level}
            SPMIR_ucVal: extended);
   end;
   {.SPMi custom effects data structure}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read + FCMgSPMCFX_Core_Setup and related subroutines}
   type TFCRdgCustomEffect= record
      case CFX_code: TFCEdgSPMiCustomEffects of
         sceEIOUT: (
            CFX_eioutMod: integer;
            CFX_eioutIsBurMod: boolean
            );
         sceREVTX: (CFX_revtxCoef: extended);
   end;

    {.SPM HQ structures}
   {:DEV NOTES: update spmdb.xml + FCMdF_DBSPMi_Read.}
   type TFCEdgSPMhqStr=(
      {.centralized}
      dgCentral
      {.clustered}
      ,dgClust
      {.corporative}
      ,dgCorpo
      {.federative}
      ,dgFed
      );
   {.SPM items}
   {:DEV NOTES: update FCMdF_DBSPMi_Read.}
   type TFCRdgSPMi= record
      {.unique token}
      SPMI_token: string[20];
      {.area in which the item is linked to}
      SPMI_area: TFCEdgSPMarea;
      {.true= unique: only one of this kind can be set in the area}
      SPMI_isUnique2set: boolean;
      {.requirements}
      SPMI_req: array of TFCRdgSPMiReq;
      {.influences}
      SPMI_infl: array of TFCRdgSPMiInfl;
      {.mod-cohesion}
      SPMI_modCohes: integer;
      {.mod-tension}
      SPMI_modTens: integer;
      {.mod-security}
      SPMI_modSec: integer;
      {.mod-education}
      SPMI_modEdu: integer;
      {.mod-natality}
      SPMI_modNat: integer;
      {.mod-health}
      SPMI_modHeal: integer;
      {.mod-bureaucracy}
      SPMI_modBur: integer;
      {.mod-corruption}
      SPMI_modCorr: integer;
      {.custom effects}
      SPMI_customFxList: array of TFCRdgCustomEffect;
      {.policy sub datastructure}
      case SPMI_isPolicy: boolean of
         true:
            {.HQ structure}
            (SPMI_hqStruc: TFCEdgSPMhqStr;
            SPMI_hqRTM: integer);
   end;
      {.SPMi dynamic array}
      TFCDdgSPMi = array of TFCRdgSPMi;

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

implementation

//uses

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

   //==========subsection===================================================================
//var
//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

end.
