unit FrmSelectCheckBox;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AdvGroupBox,
  AdvOfficeButtons, Vcl.ExtCtrls, Vcl.Buttons,
  ArrayHelper, UnitCheckGrpAdvUtil;

type
  TSelectChcekBoxF = class(TForm)
    Panel1: TPanel;
    CheckBoxGrp: TAdvOfficeCheckGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel2: TPanel;
    Label1: TLabel;
  private
    { Private declarations }
  public
    //AEnum: String Array�� CheckBox ������
    //ACommaStr: Comma(,)�� �з��� String list -> Checked = True�� ������
    procedure LoadCheckItems2CheckGrpFromCSV(AEnum: TArrayRecord<string>; ACommaStr: string);
    procedure LoadCheckItems2CheckGrpFromInt(AEnum: TArrayRecord<string>; ACheckValueSet: integer; ALabelName: string='');
    //GroupBox���� Checked = True�� �׸���� Comma�� �з��Ͽ� ��ȯ��
    function GetCSVFromCheckGrp : string;
    //GroupBox���� Checked = True�� �׸���� Bitwise�� ��ȯ��(��: 00101 => 1�� True�� �ǹ�)
//    function GetSetsFromCheckGrp: integer;
    procedure FillCheckGrpByArrayString(AEnum: TArrayRecord<string>);
  end;

//ACheckValueList: Comma�� �з��� String
//Result: Checked = True�� Item List�� Comma�� �з��Ͽ� ��ȯ��
function EditCheckBoxGrp(AEnum: TArrayRecord<string>; ACheckValueList: string): string;
//Result : Set Type ��(Bitwise)
function GetSetFromCheckBoxGrp(AEnum: TArrayRecord<string>; ACheckValueList: string): integer; overload;
//ACheckValueList: Set Type ��: 1�̸� True, 0�̸� False�� ���� ��
function GetSetFromCheckBoxGrp(AEnum: TArrayRecord<string>; ACheckValueList: integer; ALabelName: string=''): integer; overload;
function GetSetFromCheckBoxGrp(AEnum: TStringList; ACheckValueList: integer; ALabelName: string=''): integer; overload;

var
  SelectChcekBoxF: TSelectChcekBoxF;

implementation

uses JHP.Util.Bit32Helper;

{$R *.dfm}

function EditCheckBoxGrp(AEnum: TArrayRecord<string>; ACheckValueList: string): string;
var
  LSelectChcekBoxF: TSelectChcekBoxF;
begin//ACkeckBoxList: �޸��� �и��� Item list��
  Result := '';

  LSelectChcekBoxF := TSelectChcekBoxF.Create(nil);
  try
    with LSelectChcekBoxF do
    begin
      LoadCheckItems2CheckGrpFromCSV(AEnum, ACheckValueList);

      if ShowModal = mrOK then
      begin
        Result := GetCSVFromCheckGrp;
      end
      else
        Result := 'No Change';
    end;
  finally
    LSelectChcekBoxF.Free;
  end;
end;

function GetSetFromCheckBoxGrp(AEnum: TArrayRecord<string>; ACheckValueList: string): integer;
var
  LSelectChcekBoxF: TSelectChcekBoxF;
begin//ACheckValueList: �޸��� �и��� Item list��
  Result := -1;

  LSelectChcekBoxF := TSelectChcekBoxF.Create(nil);
  try
    with LSelectChcekBoxF do
    begin
      LoadCheckItems2CheckGrpFromCSV(AEnum, ACheckValueList);

      if ShowModal = mrOK then
      begin
        Result := GetSetsFromCheckGrp(CheckBoxGrp);
      end;
    end;
  finally
    LSelectChcekBoxF.Free;
  end;
end;

function GetSetFromCheckBoxGrp(AEnum: TArrayRecord<string>; ACheckValueList: integer; ALabelName: string=''): integer;
var
  LSelectChcekBoxF: TSelectChcekBoxF;
begin//ACheckValueList: Bitwise value list��
  Result := ACheckValueList;

  LSelectChcekBoxF := TSelectChcekBoxF.Create(nil);
  try
    with LSelectChcekBoxF do
    begin
      Label1.Caption := ALabelName;

      LoadCheckItems2CheckGrpFromIntSet(AEnum, ACheckValueList, LSelectChcekBoxF.CheckBoxGrp);

      if ShowModal = mrOK then
      begin
        Result := GetSetsFromCheckGrp(CheckBoxGrp);
      end;
    end;
  finally
    LSelectChcekBoxF.Free;
  end;
end;

function GetSetFromCheckBoxGrp(AEnum: TStringList; ACheckValueList: integer; ALabelName: string): integer;
var
  LArray: TArrayRecord<String>;
  LStr: string;
begin
  for LStr in AEnum do
  begin
    if LStr <> '' then
    begin
      LArray.Add(LStr);
    end;
  end;

  Result := GetSetFromCheckBoxGrp(LArray, ACheckValueList, ALabelName);
end;

procedure TSelectChcekBoxF.FillCheckGrpByArrayString(AEnum: TArrayRecord<string>);
begin
  FillInCheckGrpByArrayString(AEnum, CheckBoxGrp);
end;

function TSelectChcekBoxF.GetCSVFromCheckGrp: string;
var
  i: integer;
begin
  Result := GetCommaStrFromCheckGrp(CheckBoxGrp);
end;

//function TSelectChcekBoxF.GetSetsFromCheckGrp: integer;
//var
//  i: integer;
//begin
//  Result := 0;
//
//  for i := 0 to CheckBoxGrp.Items.Count - 1  do
//  begin
//    if CheckBoxGrp.Checked[i] then
//    begin
//      TpjhBit32(Result).Bit[i] := True;
//    end;
//  end;
//end;

procedure TSelectChcekBoxF.LoadCheckItems2CheckGrpFromCSV(
  AEnum: TArrayRecord<string>; ACommaStr: string);
var
  LStrList: TStringList;
  i,j: integer;
begin
  FillCheckGrpByArrayString(AEnum);

  LStrList := TStringList.Create;
  try
    LStrList.CommaText := ACommaStr;

    for i := 0 to LStrList.Count - 1 do
    begin
      for j := 0 to CheckBoxGrp.Items.Count - 1  do
      begin
        if CheckBoxGrp.Items.Strings[j] = LStrList.Strings[i] then
        begin
          CheckBoxGrp.Checked[j] := True;
          break;
        end;
      end;
    end;
  finally
    LStrList.Free;
  end;
end;

procedure TSelectChcekBoxF.LoadCheckItems2CheckGrpFromInt(
  AEnum: TArrayRecord<string>; ACheckValueSet: integer; ALabelName: string='');
var
  j: integer;
  LpjhBit32: TpjhBit32;
begin
  Label1.Caption := ALabelName;

  FillCheckGrpByArrayString(AEnum);

  LpjhBit32 := ACheckValueSet;

  for j := 0 to CheckBoxGrp.Items.Count - 1  do
    CheckBoxGrp.Checked[j] := LpjhBit32.Bit[j];
end;

end.
