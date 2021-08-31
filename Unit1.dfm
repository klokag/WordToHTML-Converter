object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 467
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object OpenFile_B1: TButton
    Left = 216
    Top = 54
    Width = 75
    Height = 25
    Caption = '...'
    TabOrder = 0
    OnClick = OpenFile_B1Click
  end
  object FileName1: TEdit
    Left = 8
    Top = 56
    Width = 202
    Height = 21
    TabOrder = 1
  end
  object CreateHTML_B: TButton
    Left = 311
    Top = 54
    Width = 75
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100' '
    TabOrder = 2
    OnClick = CreateHTML_BClick
  end
  object PreView_WB: TWebBrowser
    Left = 8
    Top = 96
    Width = 657
    Height = 361
    TabOrder = 3
    ControlData = {
      4C000000E74300004F2500000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Memo1: TMemo
    Left = 448
    Top = 8
    Width = 233
    Height = 73
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object OD: TOpenDialog
    Left = 384
    Top = 8
  end
end
