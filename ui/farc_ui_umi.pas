{======(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved==============

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: August 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: Unified Management Interface (UMI) - core unit

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
unit farc_ui_umi;

interface

uses
   SysUtils;

//==END PUBLIC ENUM=========================================================================

//==END PUBLIC RECORDS======================================================================

   //==========subsection===================================================================
//var
//==END PUBLIC VAR==========================================================================

//const
//==END PUBLIC CONST========================================================================

//===========================END FUNCTIONS SECTION==========================================

///<summary>
///   update, if necessary, the UMI
///</summary>
procedure FCMuiUMI_CurrentTab_Update( const SetConstraints, Resize: boolean );

implementation

uses
   farc_data_init
   ,farc_data_textfiles
   ,farc_main
   ,farc_ui_umifaction
   ,farc_win_debug;

//==END PRIVATE ENUM========================================================================

//==END PRIVATE RECORDS=====================================================================

//==END PRIVATE VAR=========================================================================

//const
//==END PRIVATE CONST=======================================================================

//===================================================END OF INIT============================
//===========================END FUNCTIONS SECTION==========================================

procedure FCMuiUMI_MainPanel_SetConstraints;
{:Purpose: set default/min UMI size regarding the selected section.
    Additions:
      -2012Aug28- *code audit:
                     (-)var formatting + refactoring     (-)if..then reformatting   (x)function/procedure refactoring
                     (-)parameters refactoring           (-) ()reformatting         (o)code optimizations
                     (-)float local variables=> extended (-)case..of reformatting   (-)local methods
                     (-)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (-)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (-)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2010Nov28- *fix: correctly resize the UMI by puting the constraints before width and height loading.
                  *add: only resize the panel if it's dimensions are < to the minimal values.
      -2010Nov15- *add: min size constraints.
      -2010Oct25- *add: include also height.
}
begin
   FCWinMain.FCWM_UMI.Constraints.MinWidth:=FCVdiUMIconstraintWidth;
   if FCWinMain.FCWM_UMI.Width<FCVdiUMIconstraintWidth
   then FCWinMain.FCWM_UMI.Width:=FCVdiUMIconstraintWidth;
   FCWinMain.FCWM_UMI.Constraints.MinHeight:=FCVdiUMIconstraintHeight;
   if FCWinMain.FCWM_UMI.Height<FCVdiUMIconstraintHeight
   then FCWinMain.FCWM_UMI.Height:=FCVdiUMIconstraintHeight;
end;

procedure FCMuiUMI_CurrentTab_Update( const SetConstraints, Resize: boolean );
{:Purpose: update, if necessary, the UMI.
    Additions:
      -2012Aug28- *code audit:
                     (-)var formatting + refactoring     (-)if..then reformatting   (x)function/procedure refactoring
                     (x)parameters refactoring           (-) ()reformatting         (-)code optimizations
                     (-)float local variables=> extended (-)case..of reformatting   (-)local methods
                     (-)summary completion               (-)protect all float add/sub w/ FCFcFunc_Rnd
                     (-)standardize internal data + commenting them at each use as a result (like Count1 / Count2 ...)
                     (-)put [format x.xx ] in returns of summary, if required and if the function do formatting
                     (-)use of enumindex                 (-)use of StrToFloat( x, FCVdiFormat ) for all float data
                     (-)if the procedure reset the same record's data or external data put:
                        ///   <remarks>the procedure/function reset the /data/</remarks>
      -2012Aug21- *add: faction tab - the dependence status are updated.
                  *add: faction tab - page 0 - the government details are also updated.
      -2010Dec16- *add: update the enforcement list only if it's enabled.
      -2010Dec02- *add: enable the Policy Enforcement update for the faction tab.
      -2010Nov16- *add: enable the SPMi settings update for the faction tab.
}
begin
   if FCWinMain.FCWM_UMI.Visible then
   begin
      case FCWinMain.FCWM_UMI_TabSh.ActivePageIndex of
         {.universe}
         0:
         begin
            if SetConstraints then
            begin
               FCVdiUMIconstraintWidth:=810;
               FCVdiUMIconstraintHeight:=540;
               FCMuiUMI_MainPanel_SetConstraints;
            end;
//            if Resize
//            then FCMuiUMI_FactionComponents_SetSize;
         end;

         {.faction}
         1:
         begin
            if SetConstraints then
            begin
               FCVdiUMIconstraintWidth:=901;
               FCVdiUMIconstraintHeight:=580;
               FCMuiUMI_MainPanel_SetConstraints;
            end;
            if Resize
            then FCMuiUMIF_Components_SetSize;

            FCMuiUMIF_DependenceStatus_UpdateAll;
            case FCWinMain.FCWM_UMIFac_TabSh.ActivePageIndex of
               0:
               begin
                  FCMuiUMIF_PoliticalStructure_Update( paPoliticalStructureAll );
                  FCMuiUMIF_Colonies_Update( 0 );
               end;

               1: FCMuiUMIF_SPMSettings_Update;

               2:
               begin
//                  if FCWinMain.FCWM_UMIFSh_AFlist.Enabled
//                  then FCMumi_Faction_Upd(uiwSPMpolEnfList, false);
               end;
            end;
         end;

         2:
         begin
            if SetConstraints then
            begin
               FCVdiUMIconstraintWidth:=810;
               FCVdiUMIconstraintHeight:=540;
               FCMuiUMI_MainPanel_SetConstraints;
            end;
//            if Resize
//            then FCMuiUMI_FactionComponents_SetSize;
         end;

         3:
         begin
            if SetConstraints then
            begin
               FCVdiUMIconstraintWidth:=810;
               FCVdiUMIconstraintHeight:=540;
               FCMuiUMI_MainPanel_SetConstraints;
            end;
//            if Resize
//            then FCMuiUMI_FactionComponents_SetSize;
         end;

         4:
         begin
            if SetConstraints then
            begin
               FCVdiUMIconstraintWidth:=1000;
               FCVdiUMIconstraintHeight:=540;
               FCMuiUMI_MainPanel_SetConstraints;
            end;
//            if Resize
//            then FCMuiUMI_FactionComponents_SetSize;
         end;
      end; //==END== case FCWinMain.FCWM_UMI_TabSh.ActivePageIndex of ==//
   end; //==END== if FCWinMain.FCWM_UMI.Visible  ==//
end;

end.
