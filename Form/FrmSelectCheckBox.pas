unit FrmSelectCheckBox;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AdvGroupBox,
  AdvOfficeButtons, Vcl.ExtCtrls, Vcl.Buttons,
  ArrayHelper;

type
  TSelectChcekBoxF = class(TForm)
    Panel1: TPanel;
    ProductTypesGrp: TAdvOfficeCheckGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel2: TPanel;
    Label1: TLabel;
  private
    { Private declarations }
  public
    //AEnum: String Array�� CheckBox ������
    //ACommaStr: Comma(,)�� �з��� String list -> Checked = True�� ������
    procedure LoadCheckItems2CheckGrpFromCommaStr(AEnum: TArrayRecord<string>; ACommaStr: string);
    //GroupBox���� Checked = True�� �׸���� Comma�� �з��Ͽ� ��ȯ��
    function GetCommaStrFromCheckGrp : string;
    //GroupBox���� Checked = True�� �׸���� Bitwise�� ��ȯ��(��: 00101 => 1�� True�� �ǹ�)
    function GetSetsFromCheckGrp: integer;
    procedure FillInCheckGrpByArrayString(AEnum: TArrayRecord<string>);
  end;

//ACkeckBoxList: Comma�� �з��� String
//Result: Checked = True�� Item List�� Comma�� �з��Ͽ� ��ȯ��
function EditCheckBoxGrp(AEnum: TArrayRecord<string>; ACkeckBoxList: string): string;
//Result : Set Type ��(Bitwise)
function GetSetFromCheckBoxGrp(AEnum: TArrayRecord<string>; ACkeckBoxList: string): integer;

var
  SelectChcekBoxF: TSelectChcekBoxF;

implementation

uses JHP.Util.Bit32Helper;

{$R *.dfm}

function EditCheckBoxGrp(AEnum: TArrayRecord<string>; ACkeckBoxList: string): string;
var
  LSelectChcekBoxF: TSelectChcekBoxF;
begin//ACkeckBoxList: �޸��� �и��� Item list��
  Result := '';

  LSelectChcekBoxF := TSelectChcekBoxF.Create(nil);
  try
    with LSelectChcekBoxF do
    begin
      LoadCheckItems2CheckGrpFromCommaStr(AEnum, ACkeckBoxList);

      if ShowModal = mrOK then
      begin
        Result := GetCommaStrFromCheckGrp;
      end
      else
        Result := 'No Change';
    end;
  finally
    LSelectChcekBoxF.Free;
  end;
end;

function GetSetFromCheckBoxGrp(AEnum: TArrayRecord<string>; ACkeckBoxList: string): integer;
var
  LSelectChcekBoxF: TSelectChcekBoxF;
begin//ACkeckBoxList: �޸��� �и��� Item list��
  Result := -1;

  LSelectChcekBoxF := TSelectChcekBoxF.Create(nil);
  try
    with LSelectChcekBoxF do
    begin
      LoadCheckItems2CheckGrpFromCommaStr(AEnum, ACkeckBoxList);

      if ShowModal = mrOK then
      begin
        Result := GetSetsFromCheckGrp;
      end;
    end;
  finally
    LSelectChcekBoxF.Free;
  end;
end;

procedure TSelectChcekBoxF.FillInCheckGrpByArrayString(AEnum: TArrayRecord<string>);
var
  LStr: string;
begin
  ProductTypesGrp.Items.Clear;

  for LStr in AEnum do
    ProductTypesGrp.Items.Add(LStr);
end;

function TSelectChcekBoxF.GetCommaStrFromCheckGrp: string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to ProductTypesGrp.Items.Count - 1  do
  begin
    if ProductTypesGrp.Checked[i] then
    begin
      Result := Result + ProductTypesGrp.Items.Strings[i] + ',';
    end;
  end;

  Delete(Result, Length(Result), 1); //������ ',' ����
end;

function TSelectChcekBoxF.GetSetsFromCheckGrp: integer;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to ProductTypesGrp.Items.Count - 1  do
  begin
    if ProductTypesGrp.Checked[i] then
    begin
      TpjhBit32(Result).Bit[i] := True;
    end;
  end;
end;

procedure TSelectChcekBoxF.LoadCheckItems2CheckGrpFromCommaStr(
  AEnum: TArrayRecord<string>; ACommaStr: string);
var
  LStrList: TStringList;
  i,j: integer;
begin
  FillInCheckGrpByArrayString(AEnum);

  LStrList := TStringList.Create;
  try
    LStrList.CommaText := ACommaStr;

    for i := 0 to LStrList.Count - 1 do
    begin
      for j := 0 to ProductTypesGrp.Items.Count - 1  do
      begin
        if ProductTypesGrp.Items.Strings[j] = LStrList.Strings[i] then
        begin
          ProductTypesGrp.Checked[j] := True;
          break;
        end;
      end;
    end;
  finally
    LStrList.Free;
  end;
end;

end.
