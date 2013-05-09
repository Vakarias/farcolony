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
   ,AdvGroupBox, AdvCombo, htmlbtns;

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
    WF_ConfigurationMainTitle: TLabel;



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
    COO_Albedo: TLabeledEdit;
    TOO_Results: TAdvTabSheet;
    AdvGroupBox1: TAdvGroupBox;
    COO_TectonicActivity: TAdvComboBox;
    COO_SatTrigger: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    TOO_SatPicker: TRadioGroup;
    COO_SatNumber: TLabeledEdit;
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
    procedure COO_AlbedoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure COO_TectonicActivityChange(Sender: TObject);
    procedure COO_SatTriggerClick(Sender: TObject);
    procedure COO_SatNumberKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TOO_SatPickerClick(Sender: TObject);
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
   ,Max1
   ,Max2: integer;

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
         '<starsys sstoken="'+FCDduStarSystem[0].SS_token+'" steslocx="'
         +SSSG_LocationX.Text+'" steslocy="'+SSSG_LocationY.Text+'" steslocz="'+SSSG_LocationZ.Text+'">'
         );
      {.for stars}
      Count:=1;
      while Count<=3 do
      begin
         if FCDduStarSystem[0].SS_stars[Count].S_token=''
         then break
         else begin
            DumpString:=FCFcFunc_Star_GetClass(cdfRaw, 0, Count);
            WF_XMLOutput.Lines.Add('   <star startoken="'+FCDduStarSystem[0].SS_stars[Count].S_token+'" starclass="'+DumpString+'">');
            WF_XMLOutput.Lines.Add(
               '      <starphysdata startemp="'+IntToStr(FCDduStarSystem[0].SS_stars[Count].S_temperature)
               +'" starmass="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_mass)
               +'" stardiam="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_diameter)
               +'" starlum="'+FloatToStrF(FCDduStarSystem[0].SS_stars[Count].S_luminosity, ffFixed, 15, 5)+'"'
               +'/>'
               );
            if Count=2 then
            begin
               WF_XMLOutput.Lines.Add(
                  '      <starcompdata compmsep="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMeanSeparation)
                  +'" compminapd="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMinApproachDistance)
                  +'" compecc="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompEccentricity)
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
                  '      <starcompdata compmsep="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMeanSeparation)
                  +'" compminapd="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompMinApproachDistance)
                  +'" compecc="'+FloatToStr(FCDduStarSystem[0].SS_stars[Count].S_isCompEccentricity)
                  +'" comporb="'+DumpString+'"'
                  +'/>'
                  );
            end;
            {.orbital objects}
            Max1:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects ) - 1;
            Count1:=1;
            while Count1<=Max1 do
            begin
               WF_XMLOutput.Lines.Add( '      <orbobj ootoken="'+FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_dbTokenId+'" ftSeed="">' );
               WF_XMLOutput.Lines.Add(
                  '         <orbobjorbdata oodist="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_distanceFromStar )
                     +'" ooecc="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_eccentricity )
                     +'" ooorbzne="'+GetEnumName( TypeInfo( TFCEduHabitableZones ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_orbitalZone ) )
                     +'" oorevol="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_revolutionPeriod )
                     +'" oorevevinit="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_revolutionPeriodInit )
                     +'" oogravsphrad="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_gravitationalSphereRadius )
                     +'" orbitGeosync="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_geosynchOrbit )
                     +'" orbitLow="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_lowOrbit )
                     +'"/>'
                  );
               WF_XMLOutput.Lines.Add(
                  '         <orbobjgeophysdata ootype="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_type ) )
                     {:DEV NOTES: DEBUG ENTRY, TO REMOVE LATER.}
                     +'" oobasictypeDEBUG="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_basicType ) )
                     {:DEV NOTES: END.}
                     +'" oodiam="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_diameter )
                     +'" oodens="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_density )
                     +'" oomass="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_mass )
                     +'" oograv="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_gravity )
                     +'" ooescvel="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_escapeVelocity )
                     +'" oorotper="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_rotationPeriod )
                     +'" ooinclax="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_isNotSat_inclinationAxis )
                     +'" oomagfld="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_magneticField )
                     +'" ootectonicactivity="'+GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_tectonicActivity ) )
                     +'"/>'
                  );
               {.satellites}
               Max2:=length( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList ) - 1;
               Count2:=1;
               while Count2<=Max2 do
               begin
                  WF_XMLOutput.Lines.Add( '         <satobj sattoken="'+FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_dbTokenId+'">' );
                  WF_XMLOutput.Lines.Add(
                     '            <satorbdata satdist="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_isSat_distanceFromPlanet )
                        +'" satrevol="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_revolutionPeriod )
                        +'" satrevinit="'+IntToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_revolutionPeriodInit )
                        +'" satgravsphrad="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_gravitationalSphereRadius )
                        +'" orbitGeosync="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_geosynchOrbit )
                        +'" orbitLow="'+FloatToStr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1]. OO_satellitesList[Count2].OO_lowOrbit )
                        +'"/>'
                     );
                  WF_XMLOutput.Lines.Add(
                     '            <satgeophysdata sattype="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_type ) )
                        {:DEV NOTES: DEBUG ENTRY, TO REMOVE LATER.}
                        +'" satbasictypeDEBUG="'+GetEnumName( TypeInfo( TFCEduOrbitalObjectBasicTypes ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_basicType ) )
                        {:DEV NOTES: END.}
                        +'" satdiam="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_diameter )
                        +'" satdens="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_density )
                        +'" satmass="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_mass )
                        +'" satgrav="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_gravity )
                        +'" satescvel="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_escapeVelocity )
                        +'" satmagfld="'+floattostr( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_magneticField )
                        +'" sattectonicactivity="'+GetEnumName( TypeInfo( TFCEduTectonicActivity ), Integer( FCDduStarSystem[0].SS_stars[Count].S_orbitalObjects[Count1].OO_satellitesList[Count2].OO_tectonicActivity ) )
                        +'"/>'
                     );
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

procedure TFCWinFUG.COO_AlbedoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_AlbedoUpdate;
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

procedure TFCWinFUG.COO_GravityKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key=13
   then FCmfC_OrbitPicker_GravityUpdate;
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
      if ( strtoint( COO_SatNumber.Text ) < -1 )
         or ( strtoint( COO_SatNumber.Text ) = 0 )
      then COO_SatNumber.Text:='1'
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
