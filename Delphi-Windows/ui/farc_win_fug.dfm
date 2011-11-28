object FCWinFUG: TFCWinFUG
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'FARC Universe Generator'
  ClientHeight = 768
  ClientWidth = 1024
  Color = clSilver
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 792
    Top = 23
    Width = 74
    Height = 16
    Caption = 'XML Output'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Existence Light'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 176
    Top = 23
    Width = 288
    Height = 16
    Caption = 'Stellar System / Orbital Objects Configuration'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Existence Light'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object FCWFoutput: TAdvMemo
    Left = 615
    Top = 0
    Width = 409
    Height = 768
    Cursor = crIBeam
    ActiveLineSettings.ShowActiveLine = False
    ActiveLineSettings.ShowActiveLineIndicator = False
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
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
    Font.Height = -13
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
  object AdvPageControl1: TAdvPageControl
    Left = 25
    Top = 39
    Width = 577
    Height = 721
    ActivePage = AdvTabSheet1
    ActiveFont.Charset = DEFAULT_CHARSET
    ActiveFont.Color = clWindowText
    ActiveFont.Height = -11
    ActiveFont.Name = 'Tahoma'
    ActiveFont.Style = []
    TabBackGroundColor = clBtnFace
    TabMargin.RightMargin = 0
    TabOverlap = 0
    Version = '1.6.2.1'
    TabOrder = 1
    object AdvTabSheet1: TAdvTabSheet
      Caption = 'Stellar and Star System'
      Color = clSilver
      ColorTo = clNone
      TabColor = clBtnFace
      TabColorTo = clNone
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object AdvGroupBox1: TAdvGroupBox
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
        object FCWFssysToken: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object FCWFlocX: TLabeledEdit
          Left = 143
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'LocX'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 1
        end
        object FCWFlocY: TLabeledEdit
          Left = 262
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'LocY'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 2
        end
        object FCWFlocZ: TLabeledEdit
          Left = 381
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'LocZ'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 3
        end
      end
      object AdvGroupBox2: TAdvGroupBox
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
        object Label3: TLabel
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
        object Label4: TLabel
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
        object FUGmStartoken: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object FUGmStarDiam: TLabeledEdit
          Left = 278
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 70
          EditLabel.Height = 13
          EditLabel.Caption = 'Diam. (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 3
        end
        object FUGmStarMass: TLabeledEdit
          Left = 365
          Top = 40
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 4
        end
        object FUGmStarLum: TLabeledEdit
          Left = 452
          Top = 40
          Width = 60
          Height = 19
          Color = clWhite
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Lum. (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 5
        end
        object FUGmStarClass: TAdvComboBox
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
        object FUGmSType: TAdvComboBox
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
          OnChange = FUGmSTypeChange
        end
        object FUGmStarOG: THTMLRadioGroup
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
          OnClick = FUGmStarOGClick
        end
        object FUGmStarNumOrb: TLabeledEdit
          Left = 262
          Top = 136
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 53
          EditLabel.Height = 13
          EditLabel.Caption = '# of Orbits'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 8
        end
        object FUGmStarTemp: TLabeledEdit
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
      object AdvGroupBox3: TAdvGroupBox
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
        object FUGcs1token: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object FUGcs1Diam: TLabeledEdit
          Left = 278
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 70
          EditLabel.Height = 13
          EditLabel.Caption = 'Diam. (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 3
        end
        object FUGcs1Mass: TLabeledEdit
          Left = 365
          Top = 40
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 4
        end
        object FUGcs1Lum: TLabeledEdit
          Left = 452
          Top = 40
          Width = 60
          Height = 19
          Color = clWhite
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Lum. (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 5
        end
        object FUGcs1Class: TAdvComboBox
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
        object FUGcs1Type: TAdvComboBox
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
          OnChange = FUGcs1TypeChange
        end
        object FUGcs1OG: THTMLRadioGroup
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
          OnClick = FUGmStarOGClick
        end
        object FUGcs1NumOrb: TLabeledEdit
          Left = 262
          Top = 136
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 53
          EditLabel.Height = 13
          EditLabel.Caption = '# of Orbits'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 8
        end
        object FUGcs1Temp: TLabeledEdit
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
      object FUGcs2Check: TCheckBox
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
        OnClick = FUGcs2CheckClick
      end
      object AdvGroupBox4: TAdvGroupBox
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
        object Label7: TLabel
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
        object Label8: TLabel
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
        object FUGcs2token: TLabeledEdit
          Left = 24
          Top = 40
          Width = 97
          Height = 19
          Color = clWhite
          EditLabel.Width = 29
          EditLabel.Height = 13
          EditLabel.Caption = 'Token'
          EditLabel.Layout = tlCenter
          TabOrder = 0
        end
        object FUGcs2Diam: TLabeledEdit
          Left = 278
          Top = 40
          Width = 58
          Height = 19
          Color = clWhite
          EditLabel.Width = 70
          EditLabel.Height = 13
          EditLabel.Caption = 'Diam. (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 3
        end
        object FUGcs2Mass: TLabeledEdit
          Left = 365
          Top = 40
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Mass (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 4
        end
        object FUGcs2Lum: TLabeledEdit
          Left = 452
          Top = 40
          Width = 60
          Height = 19
          Color = clWhite
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Lum. (Sun=1)'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 5
        end
        object FUGcs2Class: TAdvComboBox
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
        object FUGcs2Type: TAdvComboBox
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
          OnChange = FUGcs2TypeChange
        end
        object FUGcs2OG: THTMLRadioGroup
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
          OnClick = FUGmStarOGClick
        end
        object FUGcs2NumOrb: TLabeledEdit
          Left = 262
          Top = 136
          Width = 59
          Height = 19
          Color = clWhite
          EditLabel.Width = 53
          EditLabel.Height = 13
          EditLabel.Caption = '# of Orbits'
          EditLabel.Layout = tlCenter
          NumbersOnly = True
          TabOrder = 8
        end
        object FUGcs2Temp: TLabeledEdit
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
    end
  end
  object FCWFgenerate: TAdvGlowButton
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
    TabOrder = 2
    OnClick = FCWFgenerateClick
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
  object FUGcs1Check: TCheckBox
    Left = 45
    Top = 326
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
    TabOrder = 3
    OnClick = FUGcs1CheckClick
  end
end
