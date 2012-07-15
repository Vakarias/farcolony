{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: space units - data unit

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
unit farc_data_spu;

interface

//uses

{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   - FCFdTFiles_UIStr_Get
   - FCMgMCore_Mission_Setup
   - FCFspuF_DockedSpU_GetNum
   - FCMuiW_FocusPopup_Upd
}
///<summary>
///   list of architectures
///</summary>
type TFCEdsuArchitectures=(
   ///<summary>
   ///   for internal use only, do no put this entry in the XML file
   ///</summary>
   aNone
   ///<summary>
   ///   Deep-Space Vehicle
   ///</summary>
   ,aDSV
   ///<summary>
   ///   Heavy-Lift Vehicle
   ///</summary>
   ,aHLV
   ///<summary>
   ///   Lander Vehicle
   ///</summary>
   ,aLV
   ///<summary>
   ///   Lander/Ascent Vehicle
   ///</summary>
   ,aLAV
   ///<summary>
   ///   Orbital Multipurpose Vehicle
   ///</summary>
   ,aOMV
   ///<summary>
   ///   Stabilized Space Infrastructure
   ///</summary>
   ,aSSI
   ///<summary>
   ///   Transatmospheric Vehicle
   ///</summary>
   ,aTAV
   ///<summary>
   ///   Beam Sail Vehicle
   ///</summary>
   ,aBSV
   );

{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   -
   -
   -
   -
}
///<summary>
///   types of control module
///</summary>
type TFCEdsuControlModules=(
   cmCockpit
   ,cmBridge
   ,cmUnmanned
   );

{:REFERENCES LIST
   - FCMdFiles_DBSpaceCrafts_Read
   - TFCRdsuEquipmentModule case
   -
   -
   -
}
///<summary>
///   equipment module classes
///</summary>
type TFCEdsuEquipmentModuleClasses=(
   emcCompartment
   ,emcControl
   ,emcHullModification
   ,emcPowerGrid
   ,emcSpaceDrive
   ,emcSubSystem
   ,emcWeaponSystem
   );

{:REFERENCES LIST
   - scintstrucdb.xml
   - FCMdFiles_DBSpaceCrafts_Read
   -
   -
   -
   -
}
///<summary>
///   internal structure shapes
///</summary>
type TFCEdsuInternalStructureShapes=(
   issAssembled
   ,issModular
   ,issSpherical
   ,issCylindrical
   ,issStreamlinedCylindrical
   ,issStreamlinedDelta
   ,issBox
   ,issToroidal
   );

//==END PUBLIC ENUM=========================================================================

{:REFERENCES LIST
   - FCMdFiles_DBSpaceCrafts_Read
   -
   -
   -
   -
   -
}
///<summary>
///   equipment module
///</summary>
type TFCRdsuEquipmentModule = record
   ///<summary>
   ///   db token id
   ///</summary>
   EM_token: string[20];
   ///<summary>
   ///   class (basic function categorization)
   ///</summary>
   case EM_class: TFCEdsuEquipmentModuleClasses of
      emcCompartment:();

      emcControl:();

      emcHullModification:();

      emcPowerGrid:();

      emcSpaceDrive:(
         //EM_cSDsubDriveData: Tlink to sub datastructure
         //       EM_cSDthrPerf: double; //rto-1 thrust / cubicmeter of volume of drive
                          {DEV NOTE: will be replaced later by a more
                          expanded structure (for taking in account R&D)}
         );

      emcSubSystem:();

      emcWeaponSystem:();
end;
   ///<summary>
   ///   equipment modules dynamic array
   ///</summary>
   TFCDdsuEquipmentModules = array of TFCRdsuEquipmentModule;

{:REFERENCES LIST
   - FCMdFiles_DBSpaceCrafts_Read
   - FCMoglVM_SpUn_Gen
   - FCMuiWin_SpUnDck_Upd
   -
   -
   -
   -
}
///<summary>
///   space unit's internal structure
///</summary>
type TFCRdsuInternalStructure = record
   ///<summary>
   ///   db token id
   ///</summary>
   IS_token: string[20];
   ///<summary>
   ///   overall shape of the structure
   ///</summary>
   IS_shape: TFCEdsuInternalStructureShapes;
   ///<summary>
   ///   type of architecture
   ///</summary>
   IS_architecture: TFCEdsuArchitectures;
   ///<summary>
   ///   type of control module allowed
   ///</summary>
   IS_controlModuleAllowed: TFCEdsuControlModules;
   ///<summary>
   ///   overall length in meters [RTO-1]
   ///</summary>
   IS_length: extended;
   ///<summary>
   ///   overall wingspan in meters [RTO-1]
   ///</summary>
   IS_wingspan: extended;
   ///<summary>
   ///   overall height in meters [RTO-1]
   ///</summary>
   IS_height: extended;
   ///<summary>
   ///   available volume in cubic meters [RTO-1]
   ///</summary>
   IS_availableVolume: extended;
   ///<summary>
   ///   available surface in square meters [RTO-1]
   ///</summary>
   IS_availableSurface: extended;
   ///<summary>
   ///   max volume, of total available, that can be occupied by the spacedrive [RTO-1]
   ///</summary>
   IS_spaceDriveMaxVolume: extended;
   ///<summary>
   ///   max surface, of total available, that can be occupied by the spacedrive [RTO-1]
   ///</summary>
   IS_spaceDriveMaxSurface: extended;
end;
   ///<summary>
   ///   space unit's internal structures dynamic array
   ///</summary>
   TFCDdsuInternalStructures = array of TFCRdsuInternalStructure;

{:REFERENCES LIST
   - FCFcFunc_ScaleConverter
   - FCMdFiles_DBSpaceCrafts_Read
   - FCMgMCore_Mission_Setup
   - FCMgMiT_ITransit_Setup
   - FCFgMl_Land_Calc
   - FCMgNG_ColMode_Upd
   - FCMoglVM_SpUn_Gen
   - FCFspuF_Design_getDB
   - FCMuiWin_SpUnDck_Upd
}
///<summary>
///   space unit's design
///</summary>
type TFCRdsuSpaceUnitDesign = record
   ///<summary>
   ///   db token id
   ///</summary>
   SUD_token: string[20];
   ///<summary>
   ///   clone of the internal structure
   ///</summary>
   SUD_internalStructureClone: TFCRdsuInternalStructure;
   ///<summary>
   ///   used volume out the available volume, in cubic meters [RTO-1]
   ///</summary>
   SUD_usedVolume: extended;
   ///<summary>
   ///   used surface out the available surface, in square meters [RTO-1]
   ///</summary>
   SUD_usedSurface: extended;
   ///<summary>
   ///   empty mass of the spacecraft, w/o payload & crew [RTO-2]
   ///</summary>
   SUD_massEmpty: extended;
   ///<summary>
   ///   list of installed equipment modules
   ///</summary>
   SUD_equimentModules: array of TFCRdsuEquipmentModule;
   ///<summary>
   ///   ISP of installed space drive
   ///</summary>
   SUD_spaceDriveISP: integer;
   ///<summary>
   ///   maximum reaction mass volume the spacecraft can carry
   ///</summary>
   SUD_spaceDriveReactionMassMaxVolume: extended;
   ///<summary>
   ///   capabilities. when updated, update too: farc_spu_functions/TFCEsufCapab
   ///</summary>
   SUD_capabilityInterstellarTransit: boolean;
   SUD_capabilityColonization: boolean;
   SUD_capabilityPassengers: boolean;
   SUD_capabilityCombat: boolean;
   {DEV NOTE:
      total mass
      drive cloned: token / perf thr/vol of drive / rmass type product token
      total drive thr
   }
end;
   ///<summary>
   ///   space unit's design dynamic array
   ///</summary>
   TFCDdsuSpaceUnitDesigns = array of TFCRdsuSpaceUnitDesign;

//==END PUBLIC RECORDS======================================================================

   //==========databases and other data structures pre-init=================================
var
   FCDdsuEquipmentModules: TFCDdsuEquipmentModules;
   FCDdsuInternalStructures: TFCDdsuInternalStructures;
   FCDdsuSpaceUnitDesigns: TFCDdsuSpaceUnitDesigns;

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
