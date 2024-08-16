unit UnitCheckGrpAdvUtil;

interface

uses System.Classes, AdvOfficeButtons, AdvGroupBox, ArrayHelper;

//AEnum: String Array�� CheckBox ������
//ACommaStr: Comma(,)�� �з��� String list -> Checked = True�� ������
procedure FillInCheckGrpByArrayString(AEnum: TArrayRecord<string>; ACheckGrp: TAdvOfficeCheckGroup);
procedure LoadCheckItems2CheckGrpFromCommaStr(AEnum: TArrayRecord<string>; ACommaStr: string; ACheckGrp: TAdvOfficeCheckGroup);
procedure LoadCheckItems2CheckGrpFromIntSet(AEnum: TArrayRecord<string>; ACheckValueSet: integer; ACheckGrp: TAdvOfficeCheckGroup);

//GroupBox���� Checked = True�� �׸���� Comma�� �з��Ͽ� ��ȯ��
function GetCommaStrFromCheckGrp(ACheckGrp: TAdvOfficeCheckGroup): string;
//GroupBox���� Checked = True�� �׸���� Bitwise�� ��ȯ��(��: 00101 => 1�� True�� �ǹ�)
function GetSetsFromCheckGrp(ACheckGrp: TAdvOfficeCheckGroup): integer;

implementation

uses JHP.Util.Bit32Helper;

procedure FillInCheckGrpByArrayString(AEnum: TArrayRecord<string>; ACheckGrp: TAdvOfficeCheckGroup);
var
  LStr: string;
begin
  ACheckGrp.Items.Clear;

  for LStr in AEnum do
    ACheckGrp.Items.Add(LStr);
end;

procedure LoadCheckItems2CheckGrpFromCommaStr(AEnum: TArrayRecord<string>; ACommaStr: string; ACheckGrp: TAdvOfficeCheckGroup);
var
  LStrList: TStringList;
  i,j: integer;
begin
  FillInCheckGrpByArrayString(AEnum, ACheckGrp);

  LStrList := TStringList.Create;
  try
    LStrList.CommaText := ACommaStr;

    for i := 0 to LStrList.Count - 1 do
    begin
      for j := 0 to ACheckGrp.Items.Count - 1  do
      begin
        if ACheckGrp.Items.Strings[j] = LStrList.Strings[i] then
        begin
          ACheckGrp.Checked[j] := True;
          break;
        end;
      end;
    end;
  finally
    LStrList.Free;
  end;
end;

procedure LoadCheckItems2CheckGrpFromIntSet(AEnum: TArrayRecord<string>; ACheckValueSet: integer;
  ACheckGrp: TAdvOfficeCheckGroup);
var
  j: integer;
  LpjhBit32: TpjhBit32;
begin
  FillInCheckGrpByArrayString(AEnum, ACheckGrp);

  LpjhBit32 := ACheckValueSet;

  for j := 0 to ACheckGrp.Items.Count - 1  do
    ACheckGrp.Checked[j] := LpjhBit32.Bit[j];
end;

function GetCommaStrFromCheckGrp(ACheckGrp: TAdvOfficeCheckGroup) : string;
var
  i: integer;
begin
  Result := '';

  for i := 0 to ACheckGrp.Items.Count - 1  do
  begin
    if ACheckGrp.Checked[i] then
    begin
      Result := Result + ACheckGrp.Items.Strings[i] + ',';
    end;
  end;

  Delete(Result, Length(Result), 1); //������ ',' ����
end;

function GetSetsFromCheckGrp(ACheckGrp: TAdvOfficeCheckGroup): integer;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to ACheckGrp.Items.Count - 1  do
  begin
    if ACheckGrp.Checked[i] then
    begin
      TpjhBit32(Result).Bit[i] := True;
    end;
  end;
end;

end.
