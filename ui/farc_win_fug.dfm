object FCWinFUG: TFCWinFUG
  Left = 0
  Top = 0
  Caption = 'FARC Universe Generator'
  ClientHeight = 758
  ClientWidth = 1014
  Color = clSilver
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object WF_ConfigurationMultiTab: TAdvPageControl
    Left = 0
    Top = 41
    Width = 1014
    Height = 717
    ActivePage = CMT_TabOrbitalObjects
    ActiveFont.Charset = DEFAULT_CHARSET
    ActiveFont.Color = clWindowText
    ActiveFont.Height = -11
    ActiveFont.Name = 'Tahoma'
    ActiveFont.Style = []
    Align = alClient
    TabBackGroundColor = clBtnFace
    TabMargin.RightMargin = 0
    TabOverlap = 0
    Version = '1.6.2.1'
    TabOrder = 0
    TabStop = False
    object CMT_TabStellarStarSystem: TAdvTabSheet
      Caption = 'Stellar and Star System'
      Color = clSilver
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      object TSSS_StellarStarSysGroup: TAdvGroupBox
        Left = 16
        Top = 3
        Width = 529
        Height = 78
        BorderColor = clBlack
        Caption = 'Stellar System Info'
        Color = clSilver
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 0
        object SSSG_StellarSysToken: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Color = clSilver
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentColor = False
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object SSSG_LocationX: TLabeledEdit
          Left = 143
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'LocX'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 1
        end
        object SSSG_LocationY: TLabeledEdit
          Left = 262
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'LocY'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 2
        end
        object SSSG_LocationZ: TLabeledEdit
          Left = 381
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'LocZ'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 3
        end
      end
      object CMT_TabMainStar: TAdvGroupBox
        Left = 16
        Top = 87
        Width = 529
        Height = 170
        BorderColor = clBlack
        Caption = 'Main Star Info'
        Color = clSilver
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        object TMS_StarClassLabel: TLabel
          Left = 143
          Top = 23
          Width = 25
          Height = 13
          Caption = 'Class'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TMS_SystemTypeLabel: TLabel
          Left = 24
          Top = 63
          Width = 62
          Height = 13
          Caption = 'System Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TMS_StarToken: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object TMS_StarDiam: TLabeledEdit
          Left = 278
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 70
          EditLabel.Height = 13
          EditLabel.Caption = 'Diam. (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 3
        end
        object TMS_StarMass: TLabeledEdit
          Left = 365
          Top = 40
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 4
        end
        object TMS_StarLum: TLabeledEdit
          Left = 452
          Top = 40
          Width = 60
          Height = 19
          Color = clWhite
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Lum. (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 5
        end
        object TMS_StarClass: TAdvComboBox
          Left = 143
          Top = 39
          Width = 50
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          ItemIndex = 0
          ItemHeight = 13
          Items.Strings = (
            'cB5'
            'cB6'
            'cB7'
            'cB8'
            'cB9'
            'cA0'
            'cA1'
            'cA2'
            'cA3'
            'cA4'
            'cA5'
            'cA6'
            'cA7'
            'cA8'
            'cA9'
            'cK0'
            'cK1'
            'cK2'
            'cK3'
            'cK4'
            'cK5'
            'cK6'
            'cK7'
            'cK8'
            'cK9'
            'cM0'
            'cM1'
            'cM2'
            'cM3'
            'cM4'
            'cM5'
            'gF0'
            'gF1'
            'gF2'
            'gF3'
            'gF4'
            'gF5'
            'gF6'
            'gF7'
            'gF8'
            'gF9'
            'gG0'
            'gG1'
            'gG2'
            'gG3'
            'gG4'
            'gG5'
            'gG6'
            'gG7'
            'gG8'
            'gG9'
            'gK0'
            'gK1'
            'gK2'
            'gK3'
            'gK4'
            'gK5'
            'gK6'
            'gK7'
            'gK8'
            'gK9'
            'gM0'
            'gM1'
            'gM2'
            'gM3'
            'gM4'
            'gM5'
            'O5'
            'O6'
            'O7'
            'O8'
            'O9'
            'B0'
            'B1'
            'B2'
            'B3'
            'B4'
            'B5'
            'B6'
            'B7'
            'B8'
            'B9'
            'A0'
            'A1'
            'A2'
            'A3'
            'A4'
            'A5'
            'A6'
            'A7'
            'A8'
            'A9'
            'F0'
            'F1'
            'F2'
            'F3'
            'F4'
            'F5'
            'F6'
            'F7'
            'F8'
            'F9'
            'G0'
            'G1'
            'G2'
            'G3'
            'G4'
            'G5'
            'G6'
            'G7'
            'G8'
            'G9'
            'K0'
            'K1'
            'K2'
            'K3'
            'K4'
            'K5'
            'K6'
            'K7'
            'K8'
            'K9'
            'M0'
            'M1'
            'M2'
            'M3'
            'M4'
            'M5'
            'M6'
            'M7'
            'M8'
            'M9'
            'WD0'
            'WD1'
            'WD2'
            'WD3'
            'WD4'
            'WD5'
            'WD6'
            'WD7'
            'WD8'
            'WD9'
            'PSR'
            'BH')
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          TabOrder = 1
          Text = 'cB5'
        end
        object TMS_SystemType: TAdvComboBox
          Left = 24
          Top = 79
          Width = 89
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'Sol Like'
            'Balanced'
            'ExtraSol Like'
            'None')
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          TabOrder = 6
          Text = 'Sol Like'
          OnChange = TMS_SystemTypeChange
        end
        object TMS_OrbitGeneration: THTMLRadioGroup
          Left = 143
          Top = 80
          Width = 113
          Height = 81
          Ellipsis = False
          Version = '1.5.4.0'
          Caption = 'Orbits Generation'
          ItemIndex = 0
          Items.Strings = (
            'None'
            'Randomized'
            'Fixed')
          TabOrder = 7
          OnClick = TMS_OrbitGenerationClick
        end
        object TMS_OrbitGenerationNumberOrbits: TLabeledEdit
          Left = 262
          Top = 136
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 83
          EditLabel.Height = 13
          EditLabel.Caption = '# Orbits (max15)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 8
          OnKeyDown = TMS_OrbitGenerationNumberOrbitsKeyDown
        end
        object TMS_StarTemp: TLabeledEdit
          Left = 199
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 74
          EditLabel.Height = 13
          EditLabel.Caption = 'Temp. (Kelvins)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 2
        end
      end
      object CMT_TabCompanion1Star: TAdvGroupBox
        Left = 16
        Top = 280
        Width = 529
        Height = 169
        BorderColor = clBlack
        Caption = 'Companion Star 1 Info'
        Color = clSilver
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 2
        Visible = False
        object Label5: TLabel
          Left = 143
          Top = 23
          Width = 25
          Height = 13
          Caption = 'Class'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label6: TLabel
          Left = 24
          Top = 63
          Width = 62
          Height = 13
          Caption = 'System Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TC1S_StarToken: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object TC1S_StarDiam: TLabeledEdit
          Left = 278
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 70
          EditLabel.Height = 13
          EditLabel.Caption = 'Diam. (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 3
        end
        object TC1S_StarMass: TLabeledEdit
          Left = 365
          Top = 40
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 4
        end
        object TC1S_StarLum: TLabeledEdit
          Left = 452
          Top = 40
          Width = 60
          Height = 19
          Color = clWhite
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Lum. (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 5
        end
        object TC1S_StarClass: TAdvComboBox
          Left = 143
          Top = 39
          Width = 50
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          ItemIndex = 0
          ItemHeight = 13
          Items.Strings = (
            'cB5'
            'cB6'
            'cB7'
            'cB8'
            'cB9'
            'cA0'
            'cA1'
            'cA2'
            'cA3'
            'cA4'
            'cA5'
            'cA6'
            'cA7'
            'cA8'
            'cA9'
            'cK0'
            'cK1'
            'cK2'
            'cK3'
            'cK4'
            'cK5'
            'cK6'
            'cK7'
            'cK8'
            'cK9'
            'cM0'
            'cM1'
            'cM2'
            'cM3'
            'cM4'
            'cM5'
            'gF0'
            'gF1'
            'gF2'
            'gF3'
            'gF4'
            'gF5'
            'gF6'
            'gF7'
            'gF8'
            'gF9'
            'gG0'
            'gG1'
            'gG2'
            'gG3'
            'gG4'
            'gG5'
            'gG6'
            'gG7'
            'gG8'
            'gG9'
            'gK0'
            'gK1'
            'gK2'
            'gK3'
            'gK4'
            'gK5'
            'gK6'
            'gK7'
            'gK8'
            'gK9'
            'gM0'
            'gM1'
            'gM2'
            'gM3'
            'gM4'
            'gM5'
            'O5'
            'O6'
            'O7'
            'O8'
            'O9'
            'B0'
            'B1'
            'B2'
            'B3'
            'B4'
            'B5'
            'B6'
            'B7'
            'B8'
            'B9'
            'A0'
            'A1'
            'A2'
            'A3'
            'A4'
            'A5'
            'A6'
            'A7'
            'A8'
            'A9'
            'F0'
            'F1'
            'F2'
            'F3'
            'F4'
            'F5'
            'F6'
            'F7'
            'F8'
            'F9'
            'G0'
            'G1'
            'G2'
            'G3'
            'G4'
            'G5'
            'G6'
            'G7'
            'G8'
            'G9'
            'K0'
            'K1'
            'K2'
            'K3'
            'K4'
            'K5'
            'K6'
            'K7'
            'K8'
            'K9'
            'M0'
            'M1'
            'M2'
            'M3'
            'M4'
            'M5'
            'M6'
            'M7'
            'M8'
            'M9'
            'WD0'
            'WD1'
            'WD2'
            'WD3'
            'WD4'
            'WD5'
            'WD6'
            'WD7'
            'WD8'
            'WD9'
            'PSR'
            'BH')
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          TabOrder = 1
          Text = 'cB5'
        end
        object TC1S_SystemType: TAdvComboBox
          Left = 24
          Top = 79
          Width = 89
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'Sol Like'
            'Balanced'
            'ExtraSol Like'
            'None')
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          TabOrder = 6
          Text = 'Sol Like'
          OnChange = TC1S_SystemTypeChange
        end
        object TC1S_OrbitGeneration: THTMLRadioGroup
          Left = 143
          Top = 85
          Width = 113
          Height = 81
          Ellipsis = False
          Version = '1.5.4.0'
          Caption = 'Orbits Generation'
          ItemIndex = 0
          Items.Strings = (
            'None'
            'Randomized'
            'Fixed')
          TabOrder = 7
          OnClick = TC1S_OrbitGenerationClick
        end
        object TC1S_OrbitGenerationNumberOrbits: TLabeledEdit
          Left = 262
          Top = 136
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 83
          EditLabel.Height = 13
          EditLabel.Caption = '# Orbits (max15)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 8
          OnKeyDown = TC1S_OrbitGenerationNumberOrbitsKeyDown
        end
        object TC1S_StarTemp: TLabeledEdit
          Left = 199
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 74
          EditLabel.Height = 13
          EditLabel.Caption = 'Temp. (Kelvins)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 2
        end
      end
      object TC2S_EnableGroupCompanion2: TCheckBox
        Left = 16
        Top = 455
        Width = 121
        Height = 17
        TabStop = False
        Caption = 'Companion Star 2'
        Color = clSilver
        Enabled = False
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'FrancophilSans'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 3
        OnClick = TC2S_EnableGroupCompanion2Click
      end
      object CMT_TabCompanion2Star: TAdvGroupBox
        Left = 16
        Top = 472
        Width = 529
        Height = 169
        BorderColor = clBlack
        Caption = 'Companion Star 2 Info'
        Color = clSilver
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 4
        Visible = False
        object TC2S_StarClassLabel: TLabel
          Left = 143
          Top = 23
          Width = 25
          Height = 13
          Caption = 'Class'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TC2S_SystemTypeLabel: TLabel
          Left = 24
          Top = 63
          Width = 62
          Height = 13
          Caption = 'System Type'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object TC2S_StarToken: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clMaroon
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'Tahoma'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object TC2S_StarDiam: TLabeledEdit
          Left = 278
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 70
          EditLabel.Height = 13
          EditLabel.Caption = 'Diam. (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 3
        end
        object TC2S_StarMass: TLabeledEdit
          Left = 365
          Top = 40
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 4
        end
        object TC2S_StarLum: TLabeledEdit
          Left = 452
          Top = 40
          Width = 60
          Height = 19
          Color = clWhite
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Lum. (Sun=1)'
          EditLabel.Layout = tlCenter
          TabOrder = 5
        end
        object TC2S_StarClass: TAdvComboBox
          Left = 143
          Top = 39
          Width = 50
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          ItemIndex = 0
          ItemHeight = 13
          Items.Strings = (
            'cB5'
            'cB6'
            'cB7'
            'cB8'
            'cB9'
            'cA0'
            'cA1'
            'cA2'
            'cA3'
            'cA4'
            'cA5'
            'cA6'
            'cA7'
            'cA8'
            'cA9'
            'cK0'
            'cK1'
            'cK2'
            'cK3'
            'cK4'
            'cK5'
            'cK6'
            'cK7'
            'cK8'
            'cK9'
            'cM0'
            'cM1'
            'cM2'
            'cM3'
            'cM4'
            'cM5'
            'gF0'
            'gF1'
            'gF2'
            'gF3'
            'gF4'
            'gF5'
            'gF6'
            'gF7'
            'gF8'
            'gF9'
            'gG0'
            'gG1'
            'gG2'
            'gG3'
            'gG4'
            'gG5'
            'gG6'
            'gG7'
            'gG8'
            'gG9'
            'gK0'
            'gK1'
            'gK2'
            'gK3'
            'gK4'
            'gK5'
            'gK6'
            'gK7'
            'gK8'
            'gK9'
            'gM0'
            'gM1'
            'gM2'
            'gM3'
            'gM4'
            'gM5'
            'O5'
            'O6'
            'O7'
            'O8'
            'O9'
            'B0'
            'B1'
            'B2'
            'B3'
            'B4'
            'B5'
            'B6'
            'B7'
            'B8'
            'B9'
            'A0'
            'A1'
            'A2'
            'A3'
            'A4'
            'A5'
            'A6'
            'A7'
            'A8'
            'A9'
            'F0'
            'F1'
            'F2'
            'F3'
            'F4'
            'F5'
            'F6'
            'F7'
            'F8'
            'F9'
            'G0'
            'G1'
            'G2'
            'G3'
            'G4'
            'G5'
            'G6'
            'G7'
            'G8'
            'G9'
            'K0'
            'K1'
            'K2'
            'K3'
            'K4'
            'K5'
            'K6'
            'K7'
            'K8'
            'K9'
            'M0'
            'M1'
            'M2'
            'M3'
            'M4'
            'M5'
            'M6'
            'M7'
            'M8'
            'M9'
            'WD0'
            'WD1'
            'WD2'
            'WD3'
            'WD4'
            'WD5'
            'WD6'
            'WD7'
            'WD8'
            'WD9'
            'PSR'
            'BH')
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          TabOrder = 1
          Text = 'cB5'
        end
        object TC2S_SystemType: TAdvComboBox
          Left = 24
          Top = 79
          Width = 89
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'Sol Like'
            'Balanced'
            'ExtraSol Like'
            'None')
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          TabOrder = 6
          Text = 'Sol Like'
          OnChange = TC2S_SystemTypeChange
        end
        object TC2S_OrbitGeneration: THTMLRadioGroup
          Left = 143
          Top = 80
          Width = 113
          Height = 81
          Ellipsis = False
          Version = '1.5.4.0'
          Caption = 'Orbits Generation'
          ItemIndex = 0
          Items.Strings = (
            'None'
            'Randomized'
            'Fixed')
          TabOrder = 7
          OnClick = TC2S_OrbitGenerationClick
        end
        object TC2S_OrbitGenerationNumberOrbits: TLabeledEdit
          Left = 262
          Top = 136
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 83
          EditLabel.Height = 13
          EditLabel.Caption = '# Orbits (max15)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 8
          OnKeyDown = TC2S_OrbitGenerationNumberOrbitsKeyDown
        end
        object TC2S_StarTemp: TLabeledEdit
          Left = 199
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 74
          EditLabel.Height = 13
          EditLabel.Caption = 'Temp. (Kelvins)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 2
        end
      end
      object TC1S_EnableGroupCompanion1: TCheckBox
        Left = 16
        Top = 263
        Width = 121
        Height = 17
        TabStop = False
        Caption = 'Companion Star 1'
        Color = clSilver
        Font.Charset = ANSI_CHARSET
        Font.Color = clWhite
        Font.Height = -12
        Font.Name = 'FrancophilSans'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 5
        OnClick = TC1S_EnableGroupCompanion1Click
      end
    end
    object CMT_TabOrbitalObjects: TAdvTabSheet
      Caption = 'Orbital Objects'
      Color = clSilver
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      object TOO_StarPicker: TRadioGroup
        Left = 3
        Top = 3
        Width = 118
        Height = 70
        Caption = 'Star Picker'
        Items.Strings = (
          'Main Star'
          'Companion 1 Star'
          'Companion 2 Star')
        TabOrder = 0
        OnClick = TOO_StarPickerClick
      end
      object TOO_CurrentOrbitalObject: TAdvGroupBox
        Left = 127
        Top = 3
        Width = 546
        Height = 683
        BorderColor = clBlack
        Caption = 'Orbital Object [enter for validate the data in each field]'
        Color = clSilver
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        object Bevel1: TBevel
          Left = 16
          Top = 98
          Width = 417
          Height = 9
        end
        object Bevel2: TBevel
          Left = 16
          Top = 146
          Width = 417
          Height = 9
        end
        object Bevel3: TBevel
          Left = 16
          Top = 316
          Width = 417
          Height = 9
        end
        object Bevel4: TBevel
          Left = 16
          Top = 389
          Width = 417
          Height = 9
        end
        object COO_Density: TLabeledEdit
          Left = 58
          Top = 72
          Width = 55
          Height = 19
          Color = clWhite
          EditLabel.Width = 36
          EditLabel.Height = 13
          EditLabel.Caption = 'Density'
          EditLabel.Layout = tlCenter
          TabOrder = 6
          OnKeyDown = COO_DensityKeyDown
        end
        object COO_Diameter: TLabeledEdit
          Left = 3
          Top = 72
          Width = 54
          Height = 19
          Color = clWhite
          EditLabel.Width = 43
          EditLabel.Height = 13
          EditLabel.Caption = 'Diameter'
          EditLabel.Layout = tlCenter
          TabOrder = 5
          OnKeyDown = COO_DiameterKeyDown
        end
        object COO_Distance: TLabeledEdit
          Left = 101
          Top = 32
          Width = 42
          Height = 19
          Color = clWhite
          EditLabel.Width = 41
          EditLabel.Height = 13
          EditLabel.Caption = 'Distance'
          EditLabel.Layout = tlCenter
          TabOrder = 1
          OnKeyDown = COO_DistanceKeyDown
        end
        object COO_Gravity: TLabeledEdit
          Left = 178
          Top = 72
          Width = 47
          Height = 19
          Color = clWhite
          EditLabel.Width = 35
          EditLabel.Height = 13
          EditLabel.Caption = 'Gravity'
          EditLabel.Layout = tlCenter
          TabOrder = 8
          OnKeyDown = COO_GravityKeyDown
        end
        object COO_Mass: TLabeledEdit
          Left = 114
          Top = 72
          Width = 63
          Height = 19
          Color = clWhite
          EditLabel.Width = 39
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass Eq'
          EditLabel.Layout = tlCenter
          TabOrder = 7
          OnKeyDown = COO_MassKeyDown
        end
        object COO_ObjecType: TAdvComboBox
          Left = 143
          Top = 31
          Width = 130
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'None'
            'Asteroids Belt'
            'Asteroid'
            'Telluric Planet'
            'Gaseous Planet')
          LabelCaption = 'Object Basic Type'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 2
          OnChange = COO_ObjecTypeChange
        end
        object COO_Token: TLabeledEdit
          Left = 3
          Top = 32
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Layout = tlCenter
          TabOrder = 0
          OnKeyDown = COO_TokenKeyDown
        end
        object COO_EscapeVel: TLabeledEdit
          Left = 226
          Top = 72
          Width = 47
          Height = 19
          Color = clWhite
          EditLabel.Width = 51
          EditLabel.Height = 13
          EditLabel.Caption = 'Escape Vel'
          EditLabel.Layout = tlCenter
          TabOrder = 9
          OnKeyDown = COO_EscapeVelKeyDown
        end
        object COO_RotationPeriod: TLabeledEdit
          Left = 279
          Top = 32
          Width = 47
          Height = 19
          Color = clWhite
          EditLabel.Width = 74
          EditLabel.Height = 13
          EditLabel.Caption = 'Rotation Period'
          EditLabel.Layout = tlCenter
          TabOrder = 3
          OnKeyDown = COO_RotationPeriodKeyDown
        end
        object COO_InclAxis: TLabeledEdit
          Left = 362
          Top = 32
          Width = 47
          Height = 19
          Color = clWhite
          EditLabel.Width = 72
          EditLabel.Height = 13
          EditLabel.Caption = 'Inclination Axis'
          EditLabel.Layout = tlCenter
          TabOrder = 4
          OnKeyDown = COO_InclAxisKeyDown
        end
        object COO_MagField: TLabeledEdit
          Left = 279
          Top = 72
          Width = 47
          Height = 19
          Color = clWhite
          EditLabel.Width = 42
          EditLabel.Height = 13
          EditLabel.Caption = 'MagField'
          EditLabel.Layout = tlCenter
          TabOrder = 10
          OnKeyDown = COO_MagFieldKeyDown
        end
        object COO_TectonicActivity: TAdvComboBox
          Left = 332
          Top = 71
          Width = 130
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'Null'
            'Dead'
            'Hot Spot'
            'Plastic'
            'Plate Tectonic'
            'Platelet Tectonic'
            'Extreme')
          LabelCaption = 'Tectonic Activity'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 11
          OnChange = COO_TectonicActivityChange
        end
        object COO_SatTrigger: TCheckBox
          Left = 80
          Top = 123
          Width = 97
          Height = 17
          TabStop = False
          Caption = 'Fixed Satellites'
          Color = clSilver
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -12
          Font.Name = 'FrancophilSans'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 12
          OnClick = COO_SatTriggerClick
        end
        object COO_SatNumber: TLabeledEdit
          Left = 243
          Top = 121
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 150
          EditLabel.Height = 13
          EditLabel.Caption = '# Sat (max15) / 0 FOR NO SAT'
          EditLabel.Layout = tlCenter
          Enabled = False
          TabOrder = 13
          OnKeyDown = COO_SatNumberKeyDown
        end
        object COO_AtmosphereEdit: TCheckBox
          Left = 8
          Top = 165
          Width = 193
          Height = 17
          TabStop = False
          Caption = 'Edit Atmosphere (All must be edited)'
          Color = clSilver
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'FrancophilSans'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 14
          OnClick = COO_AtmosphereEditClick
        end
        object COO_TraceAtmosphereTrigger: TCheckBox
          Left = 270
          Top = 165
          Width = 193
          Height = 17
          TabStop = False
          Caption = 'Trace Atmosphere (no primary)'
          Color = clSilver
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'FrancophilSans'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 15
          OnClick = COO_TraceAtmosphereTriggerClick
        end
        object COO_GasH2: TAdvComboBox
          Left = 3
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'H2'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 16
          OnChange = COO_GasH2Change
        end
        object COO_GasHe: TAdvComboBox
          Left = 58
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'He'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 17
          OnChange = COO_GasHeChange
        end
        object COO_GasCH4: TAdvComboBox
          Left = 113
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'CH4'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 18
          OnChange = COO_GasCH4Change
        end
        object COO_GasNH3: TAdvComboBox
          Left = 168
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'NH3'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 19
          OnChange = COO_GasNH3Change
        end
        object COO_GasH2O: TAdvComboBox
          Left = 223
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'H2O'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 20
          OnChange = COO_GasH2OChange
        end
        object COO_GasNe: TAdvComboBox
          Left = 278
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'Ne'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 21
          OnChange = COO_GasNeChange
        end
        object COO_GasN2: TAdvComboBox
          Left = 332
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'N2'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 22
          OnChange = COO_GasN2Change
        end
        object COO_GasCO: TAdvComboBox
          Left = 387
          Top = 203
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'CO'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 23
          OnChange = COO_GasCOChange
        end
        object COO_GasNO: TAdvComboBox
          Left = 3
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'NO'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 24
          OnChange = COO_GasNOChange
        end
        object COO_GasO2: TAdvComboBox
          Left = 58
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'O2'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 25
          OnChange = COO_GasO2Change
        end
        object COO_GasH2S: TAdvComboBox
          Left = 113
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'H2S'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 26
          OnChange = COO_GasH2SChange
        end
        object COO_GasAr: TAdvComboBox
          Left = 168
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'Ar'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 27
          OnChange = COO_GasArChange
        end
        object COO_GasCO2: TAdvComboBox
          Left = 223
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'CO2'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 28
          OnChange = COO_GasCO2Change
        end
        object COO_GasNO2: TAdvComboBox
          Left = 278
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'NO2'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 29
          OnChange = COO_GasNO2Change
        end
        object COO_GasO3: TAdvComboBox
          Left = 333
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'O3'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 30
          OnChange = COO_GasO3Change
        end
        object COO_GasSO2: TAdvComboBox
          Left = 388
          Top = 250
          Width = 49
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'NP'
            'Trace'
            'Sec'
            'Prim')
          LabelCaption = 'SO2'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 31
          OnChange = COO_GasSO2Change
        end
        object COO_PrimGasVol: TLabeledEdit
          Left = 3
          Top = 291
          Width = 54
          Height = 19
          Color = clWhite
          EditLabel.Width = 74
          EditLabel.Height = 13
          EditLabel.Caption = 'Primary Gas Vol'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 32
          OnKeyDown = COO_PrimGasVolKeyDown
        end
        object COO_AtmosphericPressure: TLabeledEdit
          Left = 101
          Top = 291
          Width = 54
          Height = 19
          Color = clWhite
          EditLabel.Width = 103
          EditLabel.Height = 13
          EditLabel.Caption = 'Atmosphere Pressure'
          EditLabel.Layout = tlCenter
          TabOrder = 33
          OnKeyDown = COO_AtmosphericPressureKeyDown
        end
        object COO_HydroType: TAdvComboBox
          Left = 70
          Top = 362
          Width = 140
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'None'
            'Liquid Water'
            'Water Ice Sheet'
            'Water Ice Crust'
            'Liquid Water-Ammonia'
            'Liquid Methane'
            'Methane Ice Sheet'
            'Methane Ice Crust'
            'Nitrogen Ice Sheet'
            'Nitrogen Ice Crust')
          LabelCaption = 'Hydrosphere Type'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 34
          OnChange = COO_HydroTypeChange
        end
        object COO_HydrosphereEdit: TCheckBox
          Left = 3
          Top = 331
          Width = 193
          Height = 17
          TabStop = False
          Caption = 'Edit Hydropshere (All must be edited)'
          Color = clSilver
          Font.Charset = ANSI_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'FrancophilSans'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 35
          OnClick = COO_HydrosphereEditClick
        end
        object COO_HydroArea: TLabeledEdit
          Left = 243
          Top = 364
          Width = 54
          Height = 19
          Color = clWhite
          EditLabel.Width = 88
          EditLabel.Height = 13
          EditLabel.Caption = 'Hydrosphere Area'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 36
          OnKeyDown = COO_HydroAreaKeyDown
        end
      end
      object TOO_OrbitalObjectPicker: TRadioGroup
        Left = 3
        Top = 75
        Width = 118
        Height = 230
        Caption = 'Orbital Object Pick'
        TabOrder = 2
        OnClick = TOO_OrbitalObjectPickerClick
      end
      object TOO_SatPicker: TRadioGroup
        Left = 3
        Top = 311
        Width = 118
        Height = 230
        Caption = 'Satellite Pick'
        TabOrder = 3
        Visible = False
        OnClick = TOO_SatPickerClick
      end
      object TOO_CurrentRegion: TAdvGroupBox
        Left = 127
        Top = 407
        Width = 546
        Height = 279
        BorderColor = clBlack
        Caption = 'Fractal Terrains Data Linking and Current Region Manual Edition'
        Color = clSilver
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        TabOrder = 4
        Visible = False
        object Bevel8: TBevel
          Left = 13
          Top = 218
          Width = 417
          Height = 9
        end
        object CR_MaxRegionsNumber: THTMLabel
          Left = 3
          Top = 24
          Width = 81
          Height = 17
          HTMLText.Strings = (
            'Max Regions: 30')
          Version = '1.8.1.0'
        end
        object CR_GridIndexNumber: THTMLabel
          Left = 90
          Top = 24
          Width = 76
          Height = 17
          HTMLText.Strings = (
            'Grid Index #: 9')
          Version = '1.8.1.0'
        end
        object CR_SeaArea: THTMLabel
          Left = 114
          Top = 65
          Width = 121
          Height = 17
          HTMLText.Strings = (
            'Sea Area: 100%')
          Version = '1.8.1.0'
        end
        object CR_Hydrosphere: THTMLabel
          Left = 3
          Top = 42
          Width = 163
          Height = 17
          HTMLText.Strings = (
            'Hydro: LWatAm')
          Version = '1.8.1.0'
        end
        object CR_HighestPeak: THTMLabel
          Left = 259
          Top = 104
          Width = 171
          Height = 17
          HTMLText.Strings = (
            'Highest Peak: 99999')
          Version = '1.8.1.0'
        end
        object CR_LowestDepth: THTMLabel
          Left = 259
          Top = 127
          Width = 171
          Height = 17
          HTMLText.Strings = (
            'Lowest Depth: 99999')
          Version = '1.8.1.0'
        end
        object CR_Diameter: THTMLabel
          Left = 436
          Top = 104
          Width = 107
          Height = 17
          HTMLText.Strings = (
            'Diameter: 99999')
          Version = '1.8.1.0'
        end
        object CR_AxialTilt: THTMLabel
          Left = 442
          Top = 127
          Width = 93
          Height = 17
          HTMLText.Strings = (
            'Axial Tilt: 999.99')
          Version = '1.8.1.0'
        end
        object CR_Albedo: THTMLabel
          Left = 259
          Top = 149
          Width = 90
          Height = 17
          HTMLText.Strings = (
            'Albedo: 0.18')
          Version = '1.8.1.0'
        end
        object CR_StarLum: THTMLabel
          Left = 355
          Top = 149
          Width = 107
          Height = 17
          HTMLText.Strings = (
            'Star Lum: 0.00001')
          Version = '1.8.1.0'
        end
        object CR_Greenhouse: THTMLabel
          Left = 254
          Top = 172
          Width = 90
          Height = 17
          HTMLText.Strings = (
            'Greenhouse: 1.1')
          Version = '1.8.1.0'
        end
        object CR_Variance: THTMLabel
          Left = 350
          Top = 172
          Width = 107
          Height = 17
          HTMLText.Strings = (
            'Variance: 10.00')
          Version = '1.8.1.0'
        end
        object CR_Rainfall: THTMLabel
          Left = 16
          Top = 195
          Width = 232
          Height = 17
          HTMLText.Strings = (
            'Rainfall Base Value: 43.5234')
          Version = '1.8.1.0'
        end
        object CR_OObjType: THTMLabel
          Left = 259
          Top = 67
          Width = 232
          Height = 17
          HTMLText.Strings = (
            'OObj Type:')
          Version = '1.8.1.0'
        end
        object CR_SurfTempMean: THTMLabel
          Left = 254
          Top = 195
          Width = 127
          Height = 17
          HTMLText.Strings = (
            'SurfTempMean: -273.15')
          Version = '1.8.1.0'
        end
        object CR_RegionLandType: THTMLabel
          Left = 3
          Top = 108
          Width = 232
          Height = 17
          HTMLText.Strings = (
            'RegionLandType:')
          Version = '1.8.1.0'
        end
        object CR_ReliefAdjustment: TAdvComboBox
          Left = 139
          Top = 158
          Width = 104
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'Plains'
            'Broken'
            'Moutainous')
          LabelCaption = 'Relief Adjustment'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 0
          OnChange = CR_ReliefAdjustmentChange
        end
        object CR_OceanicCoastalAdjustment: TAdvComboBox
          Left = 3
          Top = 157
          Width = 130
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          Items.Strings = (
            'No Adjustment'
            'Coastal'
            'Oceanic'
            'Force RockyDesert'
            'Force Sandy Desert'
            'Force Volcanic'
            'Force Polar'
            'Force Arid'
            'Force Fertile')
          LabelCaption = 'Oceanic/Coastal Adjustment'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 1
          OnChange = CR_OceanicCoastalAdjustmentChange
        end
        object CR_InputSeed: TLabeledEdit
          Left = 10
          Top = 243
          Width = 71
          Height = 19
          Color = clWhite
          EditLabel.Width = 55
          EditLabel.Height = 13
          EditLabel.Caption = 'World Seed'
          EditLabel.Layout = tlCenter
          TabOrder = 2
          OnKeyDown = CR_InputSeedKeyDown
        end
        object CR_CurrentRegion: TAdvComboBox
          Left = 3
          Top = 73
          Width = 81
          Height = 21
          Color = clWhite
          Version = '1.3.1.0'
          Visible = True
          ButtonWidth = 18
          DropWidth = 0
          Enabled = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemIndex = -1
          ItemHeight = 13
          LabelCaption = 'Current Region'
          LabelPosition = lpTopCenter
          LabelFont.Charset = DEFAULT_CHARSET
          LabelFont.Color = clWindowText
          LabelFont.Height = -11
          LabelFont.Name = 'Tahoma'
          LabelFont.Style = []
          ParentFont = False
          TabOrder = 3
          OnChange = CR_CurrentRegionChange
        end
        object CR_InputLightColorFileNumber: TLabeledEdit
          Left = 87
          Top = 243
          Width = 135
          Height = 19
          Color = clWhite
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = 'Light_Color File #'
          EditLabel.Layout = tlCenter
          TabOrder = 4
          OnKeyDown = CR_InputLightColorFileNumberKeyDown
        end
        object CR_InputClimateFileNumber: TLabeledEdit
          Left = 231
          Top = 243
          Width = 135
          Height = 19
          Color = clWhite
          EditLabel.Width = 65
          EditLabel.Height = 13
          EditLabel.Caption = 'Climate File #'
          EditLabel.Layout = tlCenter
          TabOrder = 5
          OnKeyDown = CR_InputClimateFileNumberKeyDown
        end
        object CR_ObjToken: TLabeledEdit
          Left = 259
          Top = 33
          Width = 190
          Height = 19
          Color = clWhite
          EditLabel.Width = 64
          EditLabel.Height = 13
          EditLabel.Caption = 'Object Token'
          EditLabel.Layout = tlCenter
          TabOrder = 6
          OnKeyDown = CR_InputClimateFileNumberKeyDown
        end
      end
    end
    object TOO_Results: TAdvTabSheet
      Caption = 'Results'
      Color = clSilver
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      object WF_XMLOutput: TAdvMemo
        Left = 0
        Top = 0
        Width = 1006
        Height = 689
        Cursor = crIBeam
        ActiveLineSettings.ShowActiveLine = False
        ActiveLineSettings.ShowActiveLineIndicator = False
        Align = alClient
        AutoCompletion.Active = False
        AutoCompletion.AutoDisplay = False
        AutoCompletion.Font.Charset = DEFAULT_CHARSET
        AutoCompletion.Font.Color = clWindowText
        AutoCompletion.Font.Height = -11
        AutoCompletion.Font.Name = 'Tahoma'
        AutoCompletion.Font.Style = []
        AutoCorrect.Active = False
        AutoCorrect.OldValue.Strings = (
          '')
        AutoCorrect.NewValue.Strings = (
          '')
        AutoHintParameterPosition = hpBelowCode
        AutoIndent = False
        AutoExpand = False
        BorderStyle = bsSingle
        CodeFolding.Enabled = False
        CodeFolding.LineColor = clGray
        Ctl3D = False
        DelErase = False
        EnhancedHomeKey = False
        Gutter.DigitCount = 4
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -13
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.GutterWidth = 30
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'COURIER NEW'
        Font.Style = []
        HiddenCaret = False
        Lines.Strings = (
          '')
        MarkerList.UseDefaultMarkerImageIndex = False
        MarkerList.DefaultMarkerImageIndex = -1
        MarkerList.ImageTransparentColor = 33554432
        PrintOptions.MarginLeft = 0
        PrintOptions.MarginRight = 0
        PrintOptions.MarginTop = 0
        PrintOptions.MarginBottom = 0
        PrintOptions.PageNr = False
        PrintOptions.PrintLineNumbers = False
        ReadOnly = True
        RightMarginColor = 14869218
        ScrollHint = False
        SelColor = clWhite
        SelBkColor = clNavy
        ShowRightMargin = True
        SmartTabs = False
        TabOrder = 0
        TabSize = 4
        TabStop = True
        TrimTrailingSpaces = False
        UndoLimit = 1
        UrlAware = False
        UrlStyle.TextColor = clBlue
        UrlStyle.BkColor = clWhite
        UrlStyle.Style = [fsUnderline]
        UseStyler = False
        Version = '2.2.3.1'
        WordWrap = wwNone
      end
    end
  end
  object AdvGroupBox1: TAdvGroupBox
    Left = 0
    Top = 0
    Width = 1014
    Height = 41
    Align = alTop
    Caption = 'AdvGroupBox1'
    TabOrder = 1
    object WF_ResetButton: TAdvGlowButton
      Left = 1
      Top = 0
      Width = 105
      Height = 33
      Caption = 'Reset'
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -11
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 0
      OnClick = WF_ResetButtonClick
      Appearance.ColorChecked = 16111818
      Appearance.ColorCheckedTo = 16367008
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 16111818
      Appearance.ColorDownTo = 16367008
      Appearance.ColorHot = 16117985
      Appearance.ColorHotTo = 16372402
      Appearance.ColorMirrorHot = 16107693
      Appearance.ColorMirrorHotTo = 16775412
      Appearance.ColorMirrorDown = 16102556
      Appearance.ColorMirrorDownTo = 16768988
      Appearance.ColorMirrorChecked = 16102556
      Appearance.ColorMirrorCheckedTo = 16768988
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
    end
    object WF_GenerateButton: TAdvGlowButton
      Left = 497
      Top = 0
      Width = 105
      Height = 33
      Caption = 'Generate'
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -11
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 1
      OnClick = WF_GenerateButtonClick
      Appearance.ColorChecked = 16111818
      Appearance.ColorCheckedTo = 16367008
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 16111818
      Appearance.ColorDownTo = 16367008
      Appearance.ColorHot = 16117985
      Appearance.ColorHotTo = 16372402
      Appearance.ColorMirrorHot = 16107693
      Appearance.ColorMirrorHotTo = 16775412
      Appearance.ColorMirrorDown = 16102556
      Appearance.ColorMirrorDownTo = 16768988
      Appearance.ColorMirrorChecked = 16102556
      Appearance.ColorMirrorCheckedTo = 16768988
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
    end
    object WF_PopulateDefault: TAdvGlowButton
      Left = 244
      Top = 2
      Width = 105
      Height = 33
      Caption = 'Populate Default'
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -11
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 2
      OnClick = WF_PopulateDefaultClick
      Appearance.ColorChecked = 16111818
      Appearance.ColorCheckedTo = 16367008
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 16111818
      Appearance.ColorDownTo = 16367008
      Appearance.ColorHot = 16117985
      Appearance.ColorHotTo = 16372402
      Appearance.ColorMirrorHot = 16107693
      Appearance.ColorMirrorHotTo = 16775412
      Appearance.ColorMirrorDown = 16102556
      Appearance.ColorMirrorDownTo = 16768988
      Appearance.ColorMirrorChecked = 16102556
      Appearance.ColorMirrorCheckedTo = 16768988
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
    end
    object WF_ContinueButton: TAdvGlowButton
      Left = 355
      Top = 3
      Width = 105
      Height = 33
      Caption = 'Continue'
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -11
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 3
      Visible = False
      OnClick = WF_ContinueButtonClick
      Appearance.ColorChecked = 16111818
      Appearance.ColorCheckedTo = 16367008
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 16111818
      Appearance.ColorDownTo = 16367008
      Appearance.ColorHot = 16117985
      Appearance.ColorHotTo = 16372402
      Appearance.ColorMirrorHot = 16107693
      Appearance.ColorMirrorHotTo = 16775412
      Appearance.ColorMirrorDown = 16102556
      Appearance.ColorMirrorDownTo = 16768988
      Appearance.ColorMirrorChecked = 16102556
      Appearance.ColorMirrorCheckedTo = 16768988
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
    end
  end
end
