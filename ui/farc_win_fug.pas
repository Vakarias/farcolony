{=====(C) Copyright Aug.2009-2012 Jean-Francois Baconnet All rights reserved================

        Title:  FAR Colony
        Author: Jean-Francois Baconnet
        Project Started: Aug 16 2009
        Platform: Delphi
        License: GPLv3
        Website: http://farcolony.sourceforge.net/

        Unit: FARC Universe Generator (FUG) window

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

unit farc_win_fug;

interface

uses
   Controls
   ,Forms
   ,Messages
   ,SysUtils
   ,typInfo
   ,Windows, StdCtrls, Classes, AdvMemo, AdvPageControl, ComCtrls, ExtCtrls,

   AdvGlowButton
   ,AdvGroupBox, AdvCombo, htmlbtns, HTMLabel;

type
   TFCWinFUG = class(TForm)
    WF_XMLOutput: TAdvMemo;
    WF_ConfigurationMultiTab: TAdvPageControl;
    CMT_TabStellarStarSystem: TAdvTabSheet;
      TSSS_StellarStarSysGroup: TAdvGroupBox;
         SSSG_StellarSysToken: TLabeledEdit;
         SSSG_LocationX: TLabeledEdit;
         SSSG_LocationY: TLabeledEdit;
         SSSG_LocationZ: TLabeledEdit;
    CMT_TabMainStar: TAdvGroupBox;
      TMS_StarToken: TLabeledEdit;
      TMS_StarDiam: TLabeledEdit;
      TMS_StarMass: TLabeledEdit;
      TMS_StarLum: TLabeledEdit;
      TMS_StarClass: TAdvComboBox;
      TMS_StarClassLabel: TLabel;
      TMS_SystemType: TAdvComboBox;
      TMS_SystemTypeLabel: TLabel;
      TMS_OrbitGeneration: THTMLRadioGroup;
      TMS_OrbitGenerationNumberOrbits: TLabeledEdit;
      TMS_StarTemp: TLabeledEdit;
    CMT_TabCompanion1Star: TAdvGroupBox;
      TC1S_EnableGroupCompanion1: TCheckBox;
      TC1S_StarToken: TLabeledEdit;
      TC1S_StarDiam: TLabeledEdit;
      TC1S_StarMass: TLabeledEdit;
      TC1S_StarLum: TLabeledEdit;
      TC1S_StarClass: TAdvComboBox;
      TC1S_SystemType: TAdvComboBox;
      TC1S_OrbitGeneration: THTMLRadioGroup;
      TC1S_OrbitGenerationNumberOrbits: TLabeledEdit;
      TC1S_StarTemp: TLabeledEdit;
    CMT_TabCompanion2Star: TAdvGroupBox;
      TC2S_EnableGroupCompanion2: TCheckBox;
      TC2S_StarToken: TLabeledEdit;
      TC2S_StarDiam: TLabeledEdit;
      TC2S_StarMass: TLabeledEdit;
      TC2S_StarLum: TLabeledEdit;
      TC2S_StarClass: TAdvComboBox;
      TC2S_SystemType: TAdvComboBox;
      TC2S_OrbitGeneration: THTMLRadioGroup;
      TC2S_OrbitGenerationNumberOrbits: TLabeledEdit;
      TC2S_StarTemp: TLabeledEdit;



    WF_GenerateButton: TAdvGlowButton;






    Label5: TLabel;
    Label6: TLabel;
    TC2S_StarClassLabel: TLabel;
    TC2S_SystemTypeLabel: TLabel;

    AdvGlowButton1: TAdvGlowButton;
    CMT_TabOrbitalObjects: TAdvTabSheet;
    TOO_StarPicker: TRadioGroup;
    COO_Token: TLabeledEdit;
    COO_Distance: TLabeledEdit;
    COO_Diameter: TLabeledEdit;
    COO_Density: TLabeledEdit;
    COO_ObjecType: TAdvComboBox;
    TOO_CurrentOrbitalObject: TAdvGroupBox;
    COO_Mass: TLabeledEdit;
    COO_Gravity: TLabeledEdit;
    TOO_OrbitalObjectPicker: TRadioGroup;
    COO_EscapeVel: TLabeledEdit;
    COO_RotationPeriod: TLabeledEdit;
    COO_InclAxis: TLabeledEdit;
    COO_MagField: TLabeledEdit;
    TOO_Results: TAdvTabSheet;
    AdvGroupBox1: TAdvGroupBox;
    COO_TectonicActivity: TAdvComboBox;
    COO_SatTrigger: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    TOO_SatPicker: TRadioGroup;
    COO_SatNumber: TLabeledEdit;
    COO_AtmosphereEdit: TCheckBox;
    COO_TraceAtmosphereTrigger: TCheckBox;
    COO_GasH2: TAdvComboBox;
    COO_GasHe: TAdvComboBox;
    COO_GasCH4: TAdvComboBox;
    COO_GasNH3: TAdvComboBox;
    COO_GasH2O: TAdvComboBox;
    COO_GasNe: TAdvComboBox;
    COO_GasN2: TAdvComboBox;
    COO_GasCO: TAdvComboBox;
    COO_GasNO: TAdvComboBox;
    COO_GasO2: TAdvComboBox;
    COO_GasH2S: TAdvComboBox;
    COO_GasAr: TAdvComboBox;
    COO_GasCO2: TAdvComboBox;
    COO_GasNO2: TAdvComboBox;
    COO_GasO3: TAdvComboBox;
    COO_GasSO2: TAdvComboBox;
    COO_PrimGasVol: TLabeledEdit;
    Bevel3: TBevel;
    COO_AtmosphericPressure: TLabeledEdit;
    COO_HydroType: TAdvComboBox;
    COO_HydrosphereEdit: TCheckBox;
    Bevel4: TBevel;
    COO_HydroArea: TLabeledEdit;
    TOO_CurrentRegion: TAdvGroupBox;
    Bevel8: TBevel;
    AdvComboBox1: TAdvComboBox;
    AdvComboBox2: TAdvComboBox;
    LabeledEdit12: TLabeledEdit;
    LabeledEdit13: TLabeledEdit;
    CR_CurrentRegion: TAdvComboBox;
    LabeledEdit14: TLabeledEdit;
    CR_MaxRegionsNumber: THTMLabel;
    CR_GridIndexNumber: THTMLabel;
    procedure WF_GenerateButtonClick(Sender: TObject);
    procedure TMS_OrbitGenerationClick(Sender: TObject);
    procedure TC1S_EnableGroupCompanion1Click(Sender: TObject);
    procedure TC2S_EnableGroupCompanion2Click(Sender: TObject);
    procedure TMS_SystemTypeChange(Sender: TObject);
    procedure TC1S_SystemTypeChange(Sender: TObject);
    procedure TC2S_SystemTypeChange(Sender: TObject);
    procedure AdvGlowButton1Click(Sender: TObject);
    procedure TOO_StarPickerClick(Sender: TObject);
    procedure TC1S_OrbitGenerationClick(Sender: TObject);
    procedure TC2S_OrbitGenerationClick(Sender: TObject);
    procedure TOO_OrbitalObjectPickerClick(Sender: TObject);
    procedure TC1S_OrbitGenerationNumberOrbitsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TMS_OrbitGenerationNumberOrbitsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TC2S_OrbitGenerationNumberOrbitsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure COO_TokenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_DistanceKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_ObjecTypeChange(Sender: TObject);
    procedure COO_DiameterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_DensityKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_MassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_GravityKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_EscapeVelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_RotationPeriodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_InclAxisKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_MagFieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_TectonicActivityChange(Sender: TObject);
    procedure COO_SatTriggerClick(Sender: TObject);
    procedure COO_SatNumberKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TOO_SatPickerClick(Sender: TObject);
    procedure COO_AtmosphereEditClick(Sender: TObject);
    procedure COO_TraceAtmosphereTriggerClick(Sender: TObject);
    procedure COO_GasH2Change(Sender: TObject);
    procedure COO_GasHeChange(Sender: TObject);
    procedure COO_GasCH4Change(Sender: TObject);
    procedure COO_GasNH3Change(Sender: TObject);
    procedure COO_GasH2OChange(Sender: TObject);
    procedure COO_GasNeChange(Sender: TObject);
    procedure COO_GasN2Change(Sender: TObject);
    procedure COO_GasCOChange(Sender: TObject);
    procedure COO_GasNOChange(Sender: TObject);
    procedure COO_GasO2Change(Sender: TObject);
    procedure COO_GasH2SChange(Sender: TObject);
    procedure COO_GasArChange(Sender: TObject);
    procedure COO_GasCO2Change(Sender: TObject);
    procedure COO_GasNO2Change(Sender: TObject);
    procedure COO_GasO3Change(Sender: TObject);
    procedure COO_GasSO2Change(Sender: TObject);
    procedure COO_PrimGasVolKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_AtmosphericPressureKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure COO_HydrosphereEditClick(Sender: TObject);
    procedure COO_HydroTypeChange(Sender: TObject);
    procedure COO_HydroAreaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CR_CurrentRegionChange(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
   end;

var
   FCWinFUG: TFCWinFUG;

implementation

uses
   farc_common_func//to remove when FCFcFunc_Star_GetClass is moved
   ,farc_data_univ
   ,farc_fug_com
   ,farc_fug_data
   ,farc_fug_orbits
   ,farc_fug_stars;

//=======================================END OF INIT========================================

{$R *.dfm}

procedure TFCWinFUG.WF_GenerateButtonClick(Sender: TObject);
var
   Count
   ,Count1
   ,Count2
   ,Count3
   ,Count4
   ,Max1
   ,Max2
   ,Max3
   ,Max4: integer;

   DumpString: string;
begin
   FCDduStarSystem:=nil;
   SetLength(FCDduStarSystem, 1);
   if (SSSG_StellarSysToken.Text<>'stelsys')
      and (SSSG_LocationX.Text<>'')
      and (SSSG_LocationY.Text<>'')
      and (SSSG_LocationZ.Text<>'')
      and (TMS_StarToken.Text<>'') then
   begin
      {.FUG start process}
      FCDduStarSystem[0].SS_token:=SSSG_StellarSysToken.Text;
      FCDduStarSystem[0].SS_locationX:=StrToFloat(SSSG_LocationX.Text);
      FCDduStarSystem[0].SS_locationY:=StrToFloat(SSSG_LocationY.Text);
      FCDduStarSystem[0].SS_locationZ:=StrToFloat(SSSG_LocationZ.Text);
      FCRfdStarOrbits[1]:=-1;
      FCRfdStarOrbits[2]:=-1;
      FCRfdStarOrbits[3]:=-1;
      FCRfdSystemType[1]:=0;
      FCRfdSystemType[2]:=0;
      FCRfdSystemType[3]:=0;
      {.stars}
      FCMfS_Data_Load(1);
      if ( TMS_StarToken.Text='' )
         or ( TMS_StarToken.Text='star' ) then
      begin
         DumpString:=FCDduStarSystem[0].SS_token;
         delete( DumpString, 1, 7 );
         FCDduStarSystem[0].SS_stars[1].S_token:='star'+DumpString+'A';
      end
      else FCDduStarSystem[0].SS_stars[1].S_token:=TMS_StarToken.Text;
      FCDduStarSystem[0].SS_stars[1].S_class:=TFCEduStarClasses(TMS_StarClass.ItemIndex);
      if TMS_StarTemp.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_temperature:=FCFfS_Temperature_Calc(1)
      else if TMS_StarTemp.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_temperature:=StrToInt(TMS_StarTemp.Text);
      if TMS_StarMass.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_mass:=FCFfS_Mass_Calc(1)
      else if TMS_StarMass.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_mass:=StrToFloat(TMS_StarMass.Text);
      if TMS_StarDiam.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_diameter:=FCFfS_Diameter_Calc(1)
      else if TMS_StarDiam.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_diameter:=StrToFloat(TMS_StarDiam.Text);
      if TMS_StarLum.Text=''
      then FCDduStarSystem[0].SS_stars[1].S_luminosity:=FCFfS_Luminosity_Calc(1)
      else if TMS_StarLum.Text<>''
      then FCDduStarSystem[0].SS_stars[1].S_luminosity:=StrToFloat(TMS_StarLum.Text);
      FCRfdSystemType[1]:=TMS_SystemType.ItemIndex+1;
      FCRfdStarOrbits[1]:=TMS_OrbitGeneration.ItemIndex-1;
      if FCRfdStarOrbits[1]=1
      then FCRfdStarOrbits[1]:=StrToInt(TMS_OrbitGenerationNumberOrbits.Text);
      if CMT_TabCompanion1Star.Visible then
      begin
         if ( TC1S_StarToken.Text='' )
            or ( TC1S_StarToken.Text='star' )
         then FCDduStarSystem[0].SS_stars[2].S_token:='star'+DumpString+'B'
         else FCDduStarSystem[0].SS_stars[2].S_token:=TC1S_StarToken.Text;
         FCDduStarSystem[0].SS_stars[2].S_class:=TFCEduStarClasses(TC1S_StarClass.ItemIndex);
         if TC1S_StarTemp.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_temperature:=FCFfS_Temperature_Calc(2)
         else if TC1S_StarTemp.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_temperature:=StrToInt(TC1S_StarTemp.Text);
         if TC1S_StarMass.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_mass:=FCFfS_Mass_Calc(2)
         else if TC1S_StarMass.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_mass:=StrToFloat(TC1S_StarMass.Text);
         if TC1S_StarDiam.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_diameter:=FCFfS_Diameter_Calc(2)
         else if TC1S_StarDiam.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_diameter:=StrToFloat(TC1S_StarDiam.Text);
         if TC1S_StarLum.Text=''
         then FCDduStarSystem[0].SS_stars[2].S_luminosity:=FCFfS_Luminosity_Calc(2)
         else if TC1S_StarLum.Text<>''
         then FCDduStarSystem[0].SS_stars[2].S_luminosity:=StrToFloat(TC1S_StarLum.Text);
         FCMfS_CompStar_Calc(2);
         FCRfdSystemType[2]:=TC1S_SystemType.ItemIndex+1;
         FCRfdStarOrbits[2]:=TC1S_OrbitGeneration.ItemIndex-1;
         if FCRfdStarOrbits[2]=1
         then FCRfdStarOrbits[2]:=StrToInt(TC1S_OrbitGenerationNumberOrbits.Text);
         if CMT_TabCompanion2Star.Visible then
         begin
            if ( TC2S_StarToken.Text='' )
               or ( TC2S_StarToken.Text='star' )
            then FCDduStarSystem[0].SS_stars[3].S_token:='star'+DumpString+'C'
            else FCDduStarSystem[0].SS_stars[3].S_token:=TC2S_StarToken.Text;
            FCDduStarSystem[0].SS_stars[3].S_class:=TFCEduStarClasses(TC2S_StarClass.ItemIndex);
            if TC2S_StarTemp.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_temperature:=FCFfS_Temperature_Calc(3)
            else if TC2S_StarTemp.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_temperature:=StrToInt(TC2S_StarTemp.Text);
            if TC2S_StarMass.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_mass:=FCFfS_Mass_Calc(3)
            else if TC2S_StarMass.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_mass:=StrToFloat(TC2S_StarMass.Text);
            if TC2S_StarDiam.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_diameter:=FCFfS_Diameter_Calc(3)
            else if TC2S_StarDiam.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_diameter:=StrToFloat(TC2S_StarDiam.Text);
            if TC2S_StarLum.Text=''
            then FCDduStarSystem[0].SS_stars[3].S_luminosity:=FCFfS_Luminosity_Calc(3)
            else if TC2S_StarLum.Text<>''
            then FCDduStarSystem[0].SS_stars[3].S_luminosity:=StrToFloat(TC2S_StarLum.Text);
            FCMfS_CompStar_Calc(3);
            FCRfdSystemType[3]:=TC2S_SystemType.ItemIndex+1;
            FCRfdStarOrbits[3]:=TC1S_OrbitGeneration.ItemIndex-1;
            if FCRfdStarOrbits[3]=1
            then FCRfdStarOrbits[3]:=StrToInt(TC1S_OrbitGenerationNumberOrbits.Text);

         end;
      end;
      {.generate the orbital objects}
      if ( FCRfdSystemType[1]<4 )
         and ( FCRfdStarOrbits[1]>-1 )
      then FCMfO_Generate(1);
      if (FCDduStarSystem[0].SS_stars[2].S_token<>'')
         and (FCRfdSystemType[2]<4)
         and ( FCRfdStarOrbits[2]>-1 )
      then FCMfO_Generate(2);
      if (FCDduStarSystem[0].SS_stars[3].S_token<>'')
         and (FCRfdSystemType[3]<4)
         and ( FCRfdStarOrbits[3]>-1 )
      then FCMfO_Generate(3);
      {.generate ouput}
      WF_XMLOutput.Lines.Clear;
      WF_XMLOutput.Lines.Add('===============================================');
      WF_XMLOutput.Lines.Add('===============================================');
      {.for stellar system}
      WF_XMLOutput.Lines.Add('<!-- -->');
      WF_XMLOutput.Lines.Add(
         '<starsys token="'+FCDduStarSystem[0].SS_token+'" locationX="'
         +SSSG_LocationX.Text+'" locationY="'+SSSG_LocationY.Text+'" locationZ="'+SSSG_LocationZ.Text+'">'
         );
      {.for stars}
      Count:=1;
      while Count<=3 do
      begin
         if FCDduStarSystem[0].SS_stars[Count].S_token=''
         then break
         else begin
            DumpString:=FCFcFunc_Star_GetClass(cdfRaw, 0, Count);
            WF_XMLOutput.Lines.Add('   <star token="'+FCDduStarSystem[0].SS_stars[Count].S_token+'" class="'+DumpString+'">');
            WF_XMLOutput.Lines.Add(
               '      <physicalData temperature="'+IntToStr(FCDduStarSystem[0].SS_stars[Count].S_temperature)
               +'" mass="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_mass)
               +'" diameter="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_diameter)
               +'" luminosity="'+FloatToStrF(FCDduStarSystem[0].SS_stars[Count].S_luminosity, ffFixed, 15, 5)+'"'
               +'/>'
               );
            if Count=2 then
            begin
               WF_XMLOutput.Lines.Add(
                  '      <companionData mainSeparation="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMeanSeparation)
                  +'" minApproachDistance="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMinApproachDistance)
                  +'" eccentricity="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompEccentricity)
                  +'"/>'
                  );
            end
            else if Count=3 then
            begin
               case FCDduStarSystem[0].SS_stars[Count].S_isCompStar2OrbitType of
                  cotAroundMain_Companion1: DumpString:='cotAroundMain_Companion1';
                  cotAroundCompanion1: DumpString:='cotAroundCompanion1';
                  cotAroundMain_Companion1GravityCenter: DumpString:='cotAroundMain_Companion1GravityCenter';
               end;
               WF_XMLOutput.Lines.Add(
                  '      <companionData mainSeparation="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMeanSeparation)
                  +'" minApproachDistance="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMinApproachDistance)
                  +'" eccentricity="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompEccentricity)
                  +'" orbitType="'+DumpString+'"'
                  +'/>'
                  );
            end;
            {.orbital objects}
            Max1:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects ) - 1;
            Count1:=1;
            while Count1<=Max1 do
            begin
               WF_XMLOutput.Lines.Add( '      <orbobj token="'+FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_dbTokenId+'" ftSeed="">' );
               WF_XMLOutput.Lines.Add(
                  '         <orbitalData distanceFromStar="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_distanceFromStar )
                     +'" eccentricity="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_eccentricity )
                     +'" orbitalZone="'+GetEnumName( TypeInfo( TFCEduHabitableZones ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_orbitalZone ) )
                     +'" revolutionPeriod="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_revolutionPeriod )
                     +'" revPeriodInit="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_revolutionPeriodInit )
                     +'" gravSphereRadius="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_gravitationalSphereRadius )
                     +'" orbitGeosync="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_geosynchOrbit )
                     +'" orbitLow="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_lowOrbit )
                     +'"/>'
                  );
               WF_XMLOutput.Lines.Add(
                  '         <geophysicalData type="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_type ) )
                     {:DEV NOTES: DEBUG ENTRY, TO REMOVE LATER.}
                     +'" oobasictypeDEBUG="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_basicType ) )
                     {:DEV NOTES: END.}
                     +'" diameter="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_diameter )
                     +'" density="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_density )
                     +'" mass="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_mass )
                     +'" gravity="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_gravity )
                     +'" escapeVel="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_escapeVelocity )
                     +'" rotationPeriod="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_rotationPeriod )
                     +'" inclinationAxis="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_axialTilt )
                     +'" magneticField="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_magneticField )
                     +'" tectonicActivity="'+GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_tectonicActivity ) )
                     +'"/>'
                  );
               WF_XMLOutput.Lines.Add(
                  '         <ecosphereData envType="'+GetEnumName( TypeInfo( TFCEduEnvironmentTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_environment ) )
                     +'" atmosphericPressure="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphericPressure )
                     +'" coudsCover="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_cloudsCover )
                     +'" traceAtmosphere="'+BoolToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_traceAtmosphere )
                     +'" primaryGasVolume="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_primaryGasVolumePerc )
                     +'" gasH2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceH2 ) )
                     +'" gasHe="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceHe ) )
                     +'" gasCH4="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceCH4 ) )
                     +'" gasNH3="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceNH3 ) )
                     +'" gasH2O="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceH2O ) )
                     +'" gasNe="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceNe ) )
                     +'" gasN2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceN2 ) )
                     +'" gasCO="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceCO ) )
                     +'" gasNO="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceNO ) )
                     +'" gasO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceO2 ) )
                     +'" gasH2S="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceH2S ) )
                     +'" gasAr="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceAr ) )
                     +'" gasCO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceCO2 ) )
                     +'" gasNO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceNO2 ) )
                     +'" gasO3="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceO3 ) )
                     +'" gasSO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_atmosphere.AC_gasPresenceSO2 ) )
                     +'" hydrosphereType="'+GetEnumName( TypeInfo( TFCEduHydrospheres ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_hydrosphere ) )
                     +'" hydrosphereArea="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_hydrosphereArea )
                     +'" albedo="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_albedo )
                     +'"/>'
                  );
               WF_XMLOutput.Lines.Add( '         <orbitalPeriods>' );
               Count3:=1;
               while Count3 <= 4 do
               begin
                  WF_XMLOutput.Lines.Add(
                     '            <period type="'+GetEnumName( TypeInfo( TFCEduOrbitalPeriodTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_orbitalPeriods[Count3].OOS_orbitalPeriodType ) )
                     +'" dayStart="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_orbitalPeriods[Count3].OOS_dayStart )
                     +'" dayEnd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_orbitalPeriods[Count3].OOS_dayEnd )
                     +'" baseTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_orbitalPeriods[Count3].OOS_baseTemperature )
                     +'" surfaceTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_orbitalPeriods[Count3].OOS_surfaceTemperature )
                     +'"/>'
                     );
                  inc( Count3 );
               end;
               WF_XMLOutput.Lines.Add( '         </orbitalPeriods>' );
               Max3:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions ) - 1;
               if Max3 > 0 then
               begin
                  Count3:=1;
                  WF_XMLOutput.Lines.Add( '         <regions surface="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regionSurface )
                     +'" meanTravelDist="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_meanTravelDistance )+'">' );
                  while Count3 <= Max3 do
                  begin
                     WF_XMLOutput.Lines.Add(
                        '            <region soilType="'+GetEnumName( TypeInfo( TFCEduRegionSoilTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_soilType ) )
                        +'" relief="'+GetEnumName( TypeInfo( TFCEduRegionReliefs ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_relief ) )
                        +'" climate="'+GetEnumName( TypeInfo( TFCEduRegionClimates ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_climate ) )
                        +'" closeTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_meanTemperature )
                        +'" closeWindspd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_windspeed )
                        +'" closeRain="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_rainfall )
                        +'" intermTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_meanTemperature )
                        +'" intermWindspd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_windspeed )
                        +'" intermRain="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_rainfall )
                        +'" farthTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_meanTemperature )
                        +'" farthWindspd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_windspeed )
                        +'" farthRain="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_seasonClosest.OP_rainfall )
                        +'" emoPlanSurveyG="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_planetarySurveyGround )
                        +'" emoPlanSurveyA="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_planetarySurveyAir )
                        +'" emoPlanSurveyAG="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_planetarySurveyAntigrav )
                        +'" emoPlanSurveySAG="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_planetarySurveySwarmAntigrav )
                        +'" emoCAB="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_cab )
                        +'" emoIWC="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_iwc )
                        +'" emoGroundCombat="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_emo.EMO_groundCombat )
                        +'">'
                        );
                     Max4:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_resourceSpot ) - 1;
                     Count4:=1;
                     while Count4 <= Max4 do
                     begin
                        WF_XMLOutput.Lines.Add(
                           '              <resourcespot type="'+GetEnumName( TypeInfo( TFCEduResourceSpotTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_resourceSpot[Count4].RS_type ) )
                           +'" quality="'+GetEnumName( TypeInfo( TFCEduResourceSpotQuality ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_resourceSpot[Count4].RS_quality ) )
                           +'" rarity="'+GetEnumName( TypeInfo( TFCEduResourceSpotRarity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_regions[Count3].OOR_resourceSpot[Count4].RS_rarity ) )
                           +'"/>'
                           );
                        inc( Count4 );
                     end;
                     WF_XMLOutput.Lines.Add( '            </region>' );
                     inc( Count3 );
                  end;
                  WF_XMLOutput.Lines.Add( '         </regions>' );
               end;
               {.satellites}
               Max2:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList ) - 1;
               Count2:=1;
               while Count2<=Max2 do
               begin
                  WF_XMLOutput.Lines.Add( '         <satobj token="'+FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_dbTokenId+'" ftSeed="">' );
                  WF_XMLOutput.Lines.Add(
                     '            <orbitalData distanceFromRoot="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_isSat_distanceFromPlanet )
                        +'" revolutionPeriod="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_revolutionPeriod )
                        +'" revPeriodInit="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_revolutionPeriodInit )
                        +'" gravSphereRadius="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_gravitationalSphereRadius )
                        +'" orbitGeosync="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_geosynchOrbit )
                        +'" orbitLow="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_lowOrbit )
                        +'"/>'
                     );
                  if FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_type<>ootAsteroidsBelt
                  then WF_XMLOutput.Lines.Add(
                     '            <geophysicalData type="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_type ) )
                        {:DEV NOTES: DEBUG ENTRY, TO REMOVE LATER.}
                        +'" satbasictypeDEBUG="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_basicType ) )
                        {:DEV NOTES: END.}
                        +'" diameter="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_diameter )
                        +'" density="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_density )
                        +'" mass="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_mass )
                        +'" gravity="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_gravity )
                        +'" escapeVel="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_escapeVelocity )
                        +'" magneticField="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_magneticField )
                        +'" tectonicActivity="'+GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_tectonicActivity ) )
                        +'"/>'
                     )
                  else WF_XMLOutput.Lines.Add(
                     '            <geophysicalData type="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_type ) )
                        {:DEV NOTES: DEBUG ENTRY, TO REMOVE LATER.}
                        +'" satbasictypeDEBUG="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_basicType ) )
                        {:DEV NOTES: END.}
                        +'" diameter="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_diameter )
                        +'" density="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_density )
                        +'" mass="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_mass )
                        +'" gravity="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_gravity )
                        +'" escapeVel="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_escapeVelocity )
                        +'" rotationPeriod="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_isAsterBelt_rotationPeriod )
                        +'" inclinationAxis="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_isAsterBelt_axialTilt )
                        +'" magneticField="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_magneticField )
                        +'" tectonicActivity="'+GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_tectonicActivity ) )
                        +'"/>'
                     );

                  WF_XMLOutput.Lines.Add(
                     '            <ecosphereData envType="'+GetEnumName( TypeInfo( TFCEduEnvironmentTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_environment ) )
                        +'" atmosphericPressure="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphericPressure )
                        +'" coudsCover="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_cloudsCover )
                        +'" traceAtmosphere="'+BoolToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_traceAtmosphere )
                        +'" primaryGasVolume="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_primaryGasVolumePerc )
                        +'" gasH2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceH2 ) )
                        +'" gasHe="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceHe ) )
                        +'" gasCH4="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceCH4 ) )
                        +'" gasNH3="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceNH3 ) )
                        +'" gasH2O="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceH2O ) )
                        +'" gasNe="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceNe ) )
                        +'" gasN2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceN2 ) )
                        +'" gasCO="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceCO ) )
                        +'" gasNO="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceNO ) )
                        +'" gasO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceO2 ) )
                        +'" gasH2S="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceH2S ) )
                        +'" gasAr="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceAr ) )
                        +'" gasCO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceCO2 ) )
                        +'" gasNO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceNO2 ) )
                        +'" gasO3="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceO3 ) )
                        +'" gasSO2="'+GetEnumName( TypeInfo( TFCEduAtmosphericGasStatus ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_atmosphere.AC_gasPresenceSO2 ) )
                        +'" hydrosphereType="'+GetEnumName( TypeInfo( TFCEduHydrospheres ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_hydrosphere ) )
                        +'" hydrosphereArea="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_hydrosphereArea )
                        +'" albedo="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_albedo )
                        +'"/>'
                     );
                  WF_XMLOutput.Lines.Add( '            <orbitalPeriods>' );
                  Count3:=1;
                  while Count3 <= 4 do
                  begin
                     WF_XMLOutput.Lines.Add(
                        '               <period type="'+GetEnumName( TypeInfo( TFCEduOrbitalPeriodTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_orbitalPeriods[Count3].OOS_orbitalPeriodType ) )
                        +'" dayStart="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_orbitalPeriods[Count3].OOS_dayStart )
                        +'" dayEnd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_orbitalPeriods[Count3].OOS_dayEnd )
                        +'" baseTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_orbitalPeriods[Count3].OOS_baseTemperature )
                        +'" surfaceTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_orbitalPeriods[Count3].OOS_surfaceTemperature )
                        +'"/>'
                        );
                     inc( Count3 );
                  end;
                  WF_XMLOutput.Lines.Add( '            </orbitalPeriods>' );
                  Max3:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions ) - 1;
                  if Max3 > 0 then
                  begin
                     Count3:=1;
                     WF_XMLOutput.Lines.Add( '         <regions surface="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regionSurface )
                        +'" meanTravelDist="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_meanTravelDistance )+'">' );
                     while Count3 <= Max3 do
                     begin
                        WF_XMLOutput.Lines.Add(
                           '            <region soilType="'+GetEnumName( TypeInfo( TFCEduRegionSoilTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_soilType ) )
                           +'" relief="'+GetEnumName( TypeInfo( TFCEduRegionReliefs ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_relief ) )
                           +'" climate="'+GetEnumName( TypeInfo( TFCEduRegionClimates ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_climate ) )
                           +'" closeTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_meanTemperature )
                           +'" closeWindspd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_windspeed )
                           +'" closeRain="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_rainfall )
                           +'" intermTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_meanTemperature )
                           +'" intermWindspd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_windspeed )
                           +'" intermRain="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_rainfall )
                           +'" farthTemp="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_meanTemperature )
                           +'" farthWindspd="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_windspeed )
                           +'" farthRain="'+inttostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_seasonClosest.OP_rainfall )
                           +'" emoPlanSurveyG="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_planetarySurveyGround )
                           +'" emoPlanSurveyA="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_planetarySurveyAir )
                           +'" emoPlanSurveyAG="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_planetarySurveyAntigrav )
                           +'" emoPlanSurveySAG="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_planetarySurveySwarmAntigrav )
                           +'" emoCAB="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_cab )
                           +'" emoIWC="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_iwc )
                           +'" emoGroundCombat="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_emo.EMO_groundCombat )
                           +'">'
                           );
                        Max4:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_resourceSpot ) - 1;
                        Count4:=1;
                        while Count4 <= Max4 do
                        begin
                           WF_XMLOutput.Lines.Add(
                              '              <resourcespot type="'+GetEnumName( TypeInfo( TFCEduResourceSpotTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_resourceSpot[Count4].RS_type ) )
                              +'" quality="'+GetEnumName( TypeInfo( TFCEduResourceSpotQuality ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_resourceSpot[Count4].RS_quality ) )
                              +'" rarity="'+GetEnumName( TypeInfo( TFCEduResourceSpotRarity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_regions[Count3].OOR_resourceSpot[Count4].RS_rarity ) )
                              +'"/>'
                              );
                           inc( Count4 );
                        end;
                        WF_XMLOutput.Lines.Add( '            </region>' );
                        inc( Count3 );
                     end;
                     WF_XMLOutput.Lines.Add( '         </regions>' );
                  end;
                  WF_XMLOutput.Lines.Add( '         </satobj>' );
                  inc( Count2 );
               end;
               WF_XMLOutput.Lines.Add( '      </orbobj>' );
               inc( Count1 );
            end;
            WF_XMLOutput.Lines.Add( '   </star>' );
         end; //==END== else of FCDduStarSystem[0].SS_stars[Count].S_token='' ==//
         inc(Count);
      end; //==END== while Count<=3 ==//
      {.end root}
      WF_XMLOutput.Lines.Add('</starsys>');
   end //==END== if (SSSG_StellarSysToken.Text<>'stelsys') and (SSSG_LocationX.Text<>'') and (SSSG_LocationY.Text<>'') and (SSSG_LocationZ.Text<>'') and (TMS_StarToken.Text<>'') ==//
   else
   begin
      WF_XMLOutput.Lines.Add('===============================================');
      WF_XMLOutput.Lines.Add('!ERROR: DATA INIT!');
      WF_XMLOutput.Lines.Add('===============================================');
   end;
end;

procedure TFCWinFUG.AdvGlowButton1Click(Sender: TObject);
begin
   FCMfC_Initialize( false );
end;

procedure TFCWinFUG.COO_AtmosphereEditClick(Sender: TObject);
begin
   FCmfC_AtmosphereEditTrigger_Update;
end;

procedure TFCWinFUG.COO_AtmosphericPressureKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13
   then FCmfC_AtmosphericPressure_Update;
end;

procedure TFCWinFUG.COO_DensityKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_DensityUpdate;
end;

procedure TFCWinFUG.COO_DiameterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_DiameterUpdate;
end;

procedure TFCWinFUG.COO_DistanceKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_DistanceUpdate;
end;

procedure TFCWinFUG.COO_EscapeVelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_EscapeVelUpdate;
end;

procedure TFCWinFUG.COO_GasArChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_ArUpdate;
end;

procedure TFCWinFUG.COO_GasCH4Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_CH4Update;
end;

procedure TFCWinFUG.COO_GasCOChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_COUpdate;
end;

procedure TFCWinFUG.COO_GasCO2Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_CO2Update;
end;

procedure TFCWinFUG.COO_GasH2Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_H2Update;
end;

procedure TFCWinFUG.COO_GasH2OChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_H2OUpdate;
end;

procedure TFCWinFUG.COO_GasH2SChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_H2SUpdate;
end;

procedure TFCWinFUG.COO_GasHeChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_HeUpdate;
end;

procedure TFCWinFUG.COO_GasN2Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_N2Update;
end;

procedure TFCWinFUG.COO_GasNeChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_NeUpdate;
end;

procedure TFCWinFUG.COO_GasNH3Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_NH3Update;
end;

procedure TFCWinFUG.COO_GasNOChange(Sender: TObject);
begin
   FCmfC_AtmosphereGas_NOUpdate;
end;

procedure TFCWinFUG.COO_GasNO2Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_NO2Update;
end;

procedure TFCWinFUG.COO_GasO2Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_O2Update;
end;

procedure TFCWinFUG.COO_GasO3Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_O3Update;
end;

procedure TFCWinFUG.COO_GasSO2Change(Sender: TObject);
begin
   FCmfC_AtmosphereGas_SO2Update;
end;

procedure TFCWinFUG.COO_GravityKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_GravityUpdate;
end;

procedure TFCWinFUG.COO_HydroAreaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13
   then FCmfC_HydrosphereArea_Update;
end;

procedure TFCWinFUG.COO_HydrosphereEditClick(Sender: TObject);
begin
   FCmfC_HydrosphereEditTrigger_Update;
end;

procedure TFCWinFUG.COO_HydroTypeChange(Sender: TObject);
begin
   FCmfC_HydrosphereType_Update;
end;

procedure TFCWinFUG.COO_InclAxisKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_InclinationAxisUpdate;
end;

procedure TFCWinFUG.COO_MagFieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_MagFieldUpdate;
end;

procedure TFCWinFUG.COO_MassKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_MassUpdate;
end;

procedure TFCWinFUG.COO_ObjecTypeChange(Sender: TObject);
begin
   FCmfC_OrbitPicker_ObjectTypeUpdate;
end;

procedure TFCWinFUG.COO_PrimGasVolKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13
   then FCmfC_PrimaryGasVolume_Update;
end;

procedure TFCWinFUG.COO_RotationPeriodKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_RotationPeriodUpdate;
end;

procedure TFCWinFUG.COO_SatNumberKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13 then
   begin
      if strtoint( COO_SatNumber.Text ) < -1
      then COO_SatNumber.Text:='0'
      else if strtoint( COO_SatNumber.Text ) > 15
      then COO_SatNumber.Text:='15';
      FCmC_SatPicker_Update;
   end;
end;

procedure TFCWinFUG.COO_SatTriggerClick(Sender: TObject);
begin
   FCmfC_SatTrigger_Update;
end;

procedure TFCWinFUG.COO_TectonicActivityChange(Sender: TObject);
begin
   FCmfC_OrbitPicker_TectonicActivityUpdate;
end;

procedure TFCWinFUG.COO_TokenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_TokenUpdate;
end;

procedure TFCWinFUG.COO_TraceAtmosphereTriggerClick(Sender: TObject);
begin
   FCmfC_TraceAtmosphereTrigger_Update;
end;

procedure TFCWinFUG.CR_CurrentRegionChange(Sender: TObject);
begin
   FCmfC_Region_Update;
end;

procedure TFCWinFUG.TC1S_EnableGroupCompanion1Click(Sender: TObject);
begin
   if TC1S_EnableGroupCompanion1.Checked
   then
   begin
      CMT_TabCompanion1Star.Visible:=true;
      TC2S_EnableGroupCompanion2.Enabled:=true;
   end
   else if not TC1S_EnableGroupCompanion1.Checked
   then
   begin
      CMT_TabCompanion1Star.Visible:=false;
      TC2S_EnableGroupCompanion2.Checked:=false;
      TC2S_EnableGroupCompanion2.Enabled:=false;
      CMT_TabCompanion2Star.Visible:=false;
      if TOO_StarPicker.ItemIndex=1
      then TOO_StarPicker.ItemIndex:=0;
   end;
end;

procedure TFCWinFUG.TC1S_OrbitGenerationClick(Sender: TObject);
begin
   if TC1S_OrbitGeneration.ItemIndex<2 then
   begin
      TC1S_OrbitGenerationNumberOrbits.Enabled:=false;
      TC1S_OrbitGenerationNumberOrbits.Text:='';
   end
   else TC1S_OrbitGenerationNumberOrbits.Enabled:=true;
   FCMfC_StarPicker_Update;
   WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
end;

procedure TFCWinFUG.TC1S_OrbitGenerationNumberOrbitsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13 then
   begin
      setlength( FCDfdMainStarObjectsList, strtoint( TC1S_OrbitGenerationNumberOrbits.Text ) + 1 );
      FCMfC_StarPicker_Update;
      WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
   end;
end;

procedure TFCWinFUG.TC1S_SystemTypeChange(Sender: TObject);
begin
   if TC1S_SystemType.ItemIndex=3
   then TC1S_OrbitGeneration.ItemIndex:=0;
   FCMfC_StarPicker_Update;
   WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
end;

procedure TFCWinFUG.TC2S_EnableGroupCompanion2Click(Sender: TObject);
begin
   if TC2S_EnableGroupCompanion2.Checked
   then CMT_TabCompanion2Star.Visible:=true
   else if not TC2S_EnableGroupCompanion2.Checked then
   begin
      CMT_TabCompanion2Star.Visible:=false;
      if TOO_StarPicker.ItemIndex=2
      then TOO_StarPicker.ItemIndex:=1;
   end;
end;

procedure TFCWinFUG.TC2S_OrbitGenerationClick(Sender: TObject);
begin
   if TC2S_OrbitGeneration.ItemIndex<2 then
   begin
      TC2S_OrbitGenerationNumberOrbits.Enabled:=false;
      TC2S_OrbitGenerationNumberOrbits.Text:='';
   end
   else TC2S_OrbitGenerationNumberOrbits.Enabled:=true;
   FCMfC_StarPicker_Update;
   WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
end;

procedure TFCWinFUG.TC2S_OrbitGenerationNumberOrbitsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13 then
   begin
      setlength( FCDfdMainStarObjectsList, strtoint( TC2S_OrbitGenerationNumberOrbits.Text ) + 1 );
      FCMfC_StarPicker_Update;
      WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
   end;
end;

procedure TFCWinFUG.TC2S_SystemTypeChange(Sender: TObject);
begin
   if TC2S_SystemType.ItemIndex=3
   then TC2S_OrbitGeneration.ItemIndex:=0;
   FCMfC_StarPicker_Update;
   WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
end;

procedure TFCWinFUG.TMS_OrbitGenerationClick(Sender: TObject);
begin
   if TMS_OrbitGeneration.ItemIndex<2 then
   begin
      TMS_OrbitGenerationNumberOrbits.Enabled:=false;
      TMS_OrbitGenerationNumberOrbits.Text:='';
   end
   else TMS_OrbitGenerationNumberOrbits.Enabled:=true;
   FCMfC_StarPicker_Update;
   WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
end;

procedure TFCWinFUG.TMS_OrbitGenerationNumberOrbitsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key=13 then
   begin
      setlength( FCDfdMainStarObjectsList, strtoint( TMS_OrbitGenerationNumberOrbits.Text ) + 1 );
      FCMfC_StarPicker_Update;
      WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
   end;
end;

procedure TFCWinFUG.TMS_SystemTypeChange(Sender: TObject);
begin
   if TMS_SystemType.ItemIndex=3
   then TMS_OrbitGeneration.ItemIndex:=0;
   FCMfC_StarPicker_Update;
   WF_ConfigurationMultiTab.ActivePage:=CMT_TabStellarStarSystem;
end;

procedure TFCWinFUG.TOO_OrbitalObjectPickerClick(Sender: TObject);
begin
   if TOO_OrbitalObjectPicker.ItemIndex>-1
   then FCmfC_OrbitPicker_UpdateCurrent( true );
end;

procedure TFCWinFUG.TOO_SatPickerClick(Sender: TObject);
begin
   if TOO_SatPicker.ItemIndex=0
   then FCmfC_OrbitPicker_UpdateCurrent( false )
   else if TOO_SatPicker.ItemIndex>0
   then FCmfC_SatPicker_UpdateCurrent;
end;

procedure TFCWinFUG.TOO_StarPickerClick(Sender: TObject);
begin
   FCMfC_StarPicker_Update;
end;

end.
