unit UnitNextGridUtil2;

interface

uses SysUtils, StdCtrls,Classes, Graphics, Grids, ComObj, StrUtils, System.Types,
    Variants, Dialogs, Forms, Excel2010,
    NxColumnClasses, NxColumns, NxGrid, NxCells, ArrayHelper,
    mormot.core.base, mormot.core.data, mormot.core.variants, mormot.core.unicode,
    mormot.core.text, mormot.core.datetime;

procedure NextGridToCsv(AFileName: string; ANextGrid: TNextGrid; ASkipHideRow: Boolean=True);
procedure AddNextGridColumnFromVariant(AGrid: TNextGrid; ADoc: Variant;
  AIsFromValue: Boolean=false; AIsIgnoreSaveFile: Boolean=false; AAddIncCol: Boolean=False);
//ADoc Name�� Grid�� Column Name��
//AIsFromValue : False = Json�� Key ���� Value�� ������
//               True = Json�� Value ���� Value�� ������
function AddNextGridRowFromVariant(AGrid: TNextGrid; ADoc: Variant; AIsFromValue: Boolean=false; ARow: integer=-1): integer;
//ADoc Name�� Grid�� Cell Data ��
procedure AddNextGridRowFromVariant2(AGrid: TNextGrid; ADoc: Variant; AIsFromValue: Boolean=false);
//ù���� ���� Grid�� Column Name ��
procedure AddNextGridRowsFromVariant(AGrid: TNextGrid; ADynAry: TRawUTF8DynArray; AIsAddColumn: Boolean=false);
procedure AddNextGridRowsFromVariant2(AGrid: TNextGrid; ADoc: Variant; AIsAddColumn: Boolean=false);
function GetListFromVariant2NextGrid(AGrid: TNextGrid; ADoc: Variant;
  AIsAdd: Boolean; AIsArray: Boolean = False; AIsUsePosFunc: Boolean = False;
  AIsClearRow: Boolean=False): integer;
function NextGrid2Variant(AGrid: TNextGrid; ARemoveUnderBar: Boolean=False): variant;
//ARow ���� �����͸� Variant�� ��ȯ�� : '{ColumnName=Value}'
function GetNxGridRow2Variant(AGrid: TNextGrid; ARow: integer): variant;
//ARow�� Variant�� Cell�� ǥ����
procedure SetNxGridRowFromVar(AGrid: TNextGrid; var ARow: integer; AVar: variant);
//Variant -> Grid :
procedure SetNxGridCellValueFromVar(AColumn: TnxCustomColumn; ACell: TCell; AVar: variant);
//Grid -> Variant :
procedure SetNxGridCellValue2Var(AColumn: TnxCustomColumn; ACell: TCell; var AVar: variant);

procedure NextGrid2JsonFile(AGrid: TNextGrid; ASaveFileName: string);
procedure NextGridFromJsonFile(AGrid: TNextGrid; AFileName: string; AIsClearRow: Boolean=False);
function NextGrid2VariantFromColIndexAry(AGrid: TNextGrid; AColIndexAry: TArrayRecord<integer>): variant;
function GetJsonFromSelectedRow(AGrid: TNextGrid; ARemoveUnderBar: Boolean=False): string;
procedure NextGridScrollToRow(AGrid: TNextGrid; ARow: integer=-1);
procedure DeleteSelectedRow(ANextGrid: TNextGrid);
procedure DeleteCurrentRow(ANextGrid: TNextGrid);
procedure MoveRowDown(ANextGrid: TNextGrid);
procedure MoveRowUp(ANextGrid: TNextGrid);
procedure ShowOrHideAllColumn4NextGrid(ANextGrid: TNextGrid; AIsShow: Boolean);
function GetRowFromMouseDown(ANextGrid: TNextGrid; APoint: TPoint): integer;
//AFindFromRow���� �˻� ����, Column[AColIdx]�� ���� �߿� AFindText�� ������ RowNo ��ȯ
//AColIdx: -1 �̸� AColName�� ����Ͽ� Column �˻���
function GetRowIndexFromFindNext(const ANextGrid: TNextGrid; AFindText: string;
  AColIdx: integer; var AFindFromRow: integer; AIgnoreCase: Boolean=false; AColName: string=''): integer;
function GetSelectedIndexFromNextGrid(ANextGrid: TNextGrid): integer;

implementation

uses UnitStringUtil, UnitVariantUtil;

procedure NextGridToCsv(AFileName: string; ANextGrid: TNextGrid; ASkipHideRow: Boolean);
var
  LColCount, i, j: integer;
  LCsv, LHeader: string;
  LStrList: TStringList;
begin
  LStrList := TStringList.Create;
  try
    for j := 0 to ANextGrid.RowCount - 1 do
    begin
      if ASkipHideRow and (not ANextGrid.Row[j].Visible) then
      begin
        continue;
      end;

      for i := 0 to ANextGrid.Columns.Count - 1 do
      begin
        if j = 0 then
          LHeader := LHeader + ANextGrid.Columns.Item[i].Header.Caption + ',';

        LCsv := LCsv + ANextGrid.Cells[i,j] + ',';
      end;

      if j = 0 then
      begin
        LHeader := LHeader.Remove(LHeader.Length-1);
        LStrList.Add(LHeader);
      end;

      LCsv := LCsv.Remove(LCsv.Length-1);
      LStrList.Add(LCsv);
      LCsv := '';
    end;

    LStrList.SaveToFile(AFileName);
  finally
    LStrList.Free;
  end;
end;

procedure AddNextGridColumnFromVariant(AGrid: TNextGrid; ADoc: Variant;
  AIsFromValue: Boolean; AIsIgnoreSaveFile: Boolean; AAddIncCol: Boolean);
var
  LnxTextColumn: TnxTextColumn;
  LNxComboBoxColumn: TNxComboBoxColumn;
  LnxIncrementColumn: TnxCustomColumn;
  i: integer;
  LTitle, LCompName: string;
  LStrList: TStringList;

  procedure SetTextColumn(ATitle, AName: string);
  begin
    LnxTextColumn := TnxTextColumn(AGrid.Columns.Add(TnxTextColumn, ATitle));
    LnxTextColumn.Name := RemoveSpaceBetweenStrings(AName);
    LnxTextColumn.Editing := True;
    LnxTextColumn.Header.Alignment := taCenter;
    LnxTextColumn.Alignment := taCenter;
    LnxTextColumn.Options := [coCanClick,coCanInput,coDisableMoving,coEditorAutoSelect,coPublicUsing,coShowTextFitHint];//,coEditing

    LStrList.Add(AName + ':' + 'TnxTextColumn;');
  end;
begin
//
  LStrList := TStringList.Create;
  try
    with AGrid do
    begin
      ClearRows;
      Columns.Clear;

      if AAddIncCol then
      begin
        LnxIncrementColumn := Columns.Add(TnxIncrementColumn,'No');
        LnxIncrementColumn.Alignment := taCenter;
        LnxIncrementColumn.Header.Alignment := taCenter;
        LnxIncrementColumn.Width := 30;
      end;

  //    with TDocVariantData(ADoc) do
  //    begin
        for i := 0 to TDocVariantData(ADoc).Count - 1 do
        begin
          LCompName := TDocVariantData(ADoc).Names[i];

          if AIsFromValue then
            LTitle := TDocVariantData(ADoc).Values[i]
          else
            LTitle := LCompName;

          SetTextColumn(LTitle, LCompName);
        end;
  //    end;
    end;//with
  finally
    //NextGrid Column�� �߰��ϸ� TForm ����ο� ColumnName: ColumnType �� �߰� �ǹǷ�
    //Column �ڵ� ���� �� �Ʒ� ���� ������ �����Ͽ� TForm�� �߰��� �־�� ��
    if not AIsIgnoreSaveFile then
    begin
      LStrList.SaveToFile('c:\temp\NextGridTextColumnList.txt');
      ShowMessage('c:\temp\NextGridTextColumnList.txt is saved.' + #13#10 +
        'NextGrid Column�� �߰��ϸ� TForm ����ο� ColumnName: ColumnType �� �߰� �ǹǷ�' + #13#10 +
        'Column �ڵ� ���� �� �Ʒ� ���� ������ �����Ͽ� TForm�� �߰��� �־�� ��.');
    end;

    LStrList.Free;
  end;
end;

function AddNextGridRowFromVariant(AGrid: TNextGrid; ADoc: Variant;
  AIsFromValue: Boolean; ARow: integer): integer;
var
  i: integer;
  LColName: string;
  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  with AGrid do
  begin
//    BeginUpdate;
    try
      if ARow = -1 then
        ARow := AddRow();

      for i := 0 to TDocVariantData(ADoc).Count - 1 do
      begin
        LColName := TDocVariantData(ADoc).Names[i];

        if AIsFromValue then
          LCellValue := TDocVariantData(ADoc).Values[i]
        else
          LCellValue := StringToVariant(LColName);

        LColumn := ColumnByName[LColName];

        if Columns.IndexOf(LColumn) > -1 then
        begin
          LCell := CellByName[LColName, ARow];
          SetNxGridCellValueFromVar(LColumn, LCell, LCellValue);
        end;
      end;//for

    finally
//      EndUpdate;
    end;
  end;//with

  Result := ARow;
end;

procedure AddNextGridRowFromVariant2(AGrid: TNextGrid; ADoc: Variant; AIsFromValue: Boolean=false);
var
  i, j: integer;
  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  with AGrid do
  begin
    j := AddRow;

    for i := 0 to TDocVariantData(ADoc).Count - 1 do
    begin
      if AIsFromValue then
        LCellValue := TDocVariantData(ADoc).Values[i]
      else
        LCellValue := TDocVariantData(ADoc).Names[i];

      LColumn := AGrid.Columns.Item[i];
      LCell := Cell[i, j];

      SetNxGridCellValueFromVar(LColumn, LCell, LCellValue);
    end;
  end;
end;

procedure AddNextGridRowsFromVariant(AGrid: TNextGrid; ADynAry: TRawUTF8DynArray; AIsAddColumn: Boolean);
var
  i: integer;
  LDoc: variant;
begin
  AGrid.BeginUpdate;
  try
    for i := Low(ADynAry) to High(ADynAry) do
    begin
      LDoc := _JSON(ADynAry[i]);

      if AIsAddColumn then
      begin
        if i = Low(ADynAry) then
          AddNextGridColumnFromVariant(AGrid, LDoc, False);
      end;

      AddNextGridRowFromVariant(AGrid, LDoc, True);
    end;//for

  finally
    AGrid.EndUpdate();
  end;
end;

//ADoc�� TRawUTF8DynArray�� ���� Json ��
//ADoc Name�� Grid�� Column Name��
//AIsUsePosFunc : True = Pos�Լ��� ����Ͽ� LCompName�� Column Name�� ���ԵǾ� ������ ó��
procedure AddNextGridRowsFromVariant2(AGrid: TNextGrid; ADoc: Variant; AIsAddColumn: Boolean);
var
  LUtf8: RawUTF8;
//  LDynUtf8: TRawUTF8DynArray;
//  LDynArr: TDynArray;
  LDocList: IDocList;
//  LDocDict: IDocDict;
  LVar: variant;
begin
  if ADoc = null then
    exit;

  LUtf8 := ADoc;
  LDocList := DocList(LUtf8);

  AGrid.BeginUpdate;
  try
    if AIsAddColumn then
    begin
      if LDocList.Value^.Count > 0 then
      begin
        LVar := LDocList.Item[0];
        AddNextGridColumnFromVariant(AGrid, LVar, False, True);
      end;
    end;

    for LVar in LDocList do
    begin
      AddNextGridRowFromVariant(AGrid, LVar, True);
    end;
  finally
    AGrid.EndUpdate();
  end;

//  LDynArr.Init(TypeInfo(TRawUTF8DynArray), LDynUtf8);

//  if LDynArr.LoadFromJSON(LUtf8) then//PUTF8Char(LUtf8));
//  begin
//    if LDynArr.Count = 0 then
//      exit;

//    AddNextGridRowsFromVariant(AGrid, LDynUtf8, AIsAddColumn);
//  end;
end;

//ADoc�� �������� ���ڵ忡 ���� Json ��
//AIsUsePosFunc : True = Pos�Լ��� ����Ͽ� LCompName�� Column Name�� ���ԵǾ� ������ ó��
function GetListFromVariant2NextGrid(AGrid: TNextGrid; ADoc: Variant;
  AIsAdd: Boolean; AIsArray: Boolean; AIsUsePosFunc: Boolean; AIsClearRow: Boolean): integer;
var
  i, j, LRow, LCount: integer;
  LColName: string;
//  LDynUtf8: TRawUTF8DynArray;
//  LDynArr: TDynArray;
  LDocList: IDocList;
  LUtf8: RawUTF8;
  LVar: variant;

  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;

  //AJson�� �Ѱ��� ���ڵ忡 ���� Json��
  procedure AddRowFromVar(AJson: variant);
  var
    Li, Lj: integer;
  begin
    with AGrid do
    begin
      if AIsAdd then
        LRow := AddRow()
      else
        LRow := SelectedRow;

      //�ѱ� ������ Count = 0
      for Li := 0 to TDocVariantData(AJson).Count - 1 do
      begin
        LColName := TDocVariantData(AJson).Names[Li];

        if AIsUsePosFunc then
        begin
          for Lj := 0 to Columns.Count - 1 do
          begin
            //Grid�� Column Name�� �����ϸ�
            if POS(LColName, Columns[Lj].Name) > 0 then
            begin
              LColumn := ColumnByName[LColName];
              LCell := CellByName[LColName, LRow];
              LCellValue := TDocVariantData(AJson).Values[Li];

              SetNxGridCellValueFromVar(LColumn, LCell, LCellValue);
            end;
          end;
        end
        else if Columns.IndexOf(ColumnByName[LColName]) > -1 then
        begin
          LColumn := ColumnByName[LColName];
          LCell := CellByName[LColName, LRow];
          LCellValue := TDocVariantData(AJson).Values[Li];

          SetNxGridCellValueFromVar(LColumn, LCell, LCellValue);
        end;
      end;
    end;//with
  end;
begin
  AGrid.BeginUpdate;

  if AIsClearRow then
    AGrid.ClearRows;

  try
    if AIsArray then
    begin
      LUtf8 := ADoc;
      LDocList := DocList(LUtf8);

      for LVar in LDocList do
      begin
        //LVar�� �ѱ� ����
        LUtf8 := VariantToUTF8(LVar);
        ADoc := _JSON(LUtf8);
        AddRowFromVar(ADoc);
      end;

    end
    else
    begin
      AddRowFromVar(ADoc);
    end;
  finally
    AGrid.EndUpdate;

    if AIsArray then
      Result :=  LDocList.Len
    else
      Result :=  TDocVariantData(ADoc).Count;
  end;
end;

//Result�� [{"NextGrid.ColumnName": NextGrid.CelsByName}] Array �������� �����
function NextGrid2Variant(AGrid: TNextGrid; ARemoveUnderBar: Boolean): variant;
var
  i, j: integer;
  LColName: string;
  LUtf8: RawUTF8;
  LDocList: IDocList;

  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  TDocVariant.New(Result);
  TDocVariant.New(LCellValue);
  LDocList := DocList('[]');

  with AGrid do
  begin
    for i := 0 to RowCount - 1 do
    begin
      for j := 0 to Columns.Count - 1 do
      begin
        LColName := Columns.Item[j].Name;

        if ARemoveUnderBar then
          LColName := strToken(LColName, '_');

        LColumn := ColumnByName[LColName];
        LCell := CellByName[LColName, i];

        SetNxGridCellValue2Var(LColumn, LCell, LCellValue);
      end;

      LDocList.Append(LCellValue);
    end;
  end;//with

  Result := LDocList.Json;
end;

function GetNxGridRow2Variant(AGrid: TNextGrid; ARow: integer): variant;
var
  i: integer;
  LColName: string;
  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
//  TDocVariant.New(Result);

  with AGrid do
  begin
    for i := 0 to Columns.Count - 1 do
    begin
      LColName := Columns.Item[i].Name;

      LColumn := ColumnByName[LColName];
      LCell := CellByName[LColName, ARow];

      SetNxGridCellValue2Var(LColumn, LCell, Result);
    end;//for
  end;//with
end;

procedure SetNxGridRowFromVar(AGrid: TNextGrid; var ARow: integer; AVar: variant);
var
  i: integer;
  LColName: string;

  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  with AGrid do
  begin
    if ARow = -1 then
      ARow := AGrid.AddRow();

    for i := 0 to TDocVariantData(AVar).Count - 1 do
    begin
      LColName := TDocVariantData(AVar).Names[i];
      LColumn := ColumnByName[LColName];

      //Grid�� Column�� �����ϸ�
      if Columns.IndexOf(LColumn) > -1 then
      begin
        LCell := CellByName[LColName, ARow];
        LCellValue := TDocVariantData(AVar).Values[i];

        SetNxGridCellValueFromVar(LColumn, LCell, LCellValue);
      end;
    end;//for
  end;//with
end;

procedure SetNxGridCellValueFromVar(AColumn: TnxCustomColumn; ACell: TCell; AVar: variant);
var
  LBool: Boolean;
begin
  if AColumn.ColumnType = ctDate then
    ACell.AsDateTime := VarToDateWithTimeLog(AVar)//TimelogToDateTime(StrToInt64(TDocVariantData(AJson).Values[Li]))
  else
  if AColumn.ColumnType = ctBoolean then //CheckBox Type
  begin
    VariantToBoolean(AVar, LBool);
    ACell.AsBoolean := LBool;
  end
  else //�ݵ�� String Type�� ���� �� ��
    ACell.AsString := VariantToString(AVar);
end;

procedure SetNxGridCellValue2Var(AColumn: TnxCustomColumn; ACell: TCell; var AVar: variant);
var
  LColName: string;
begin
  LColName := AColumn.Name;

  if AColumn.ColumnType = ctDate then
    TDocVariantData(AVar).Value[LColName] := VarFromDateWithTimeLog(ACell.AsDateTime) //TimeLogFromDateTime(AGrid.CellByName[LColumnName, ARow].AsDateTime)
  else
  if AColumn.ColumnType = ctBoolean then
    TDocVariantData(AVar).Value[LColName] := ACell.AsBoolean
  else
    TDocVariantData(AVar).Value[LColName] := ACell.AsString;
end;

procedure NextGrid2JsonFile(AGrid: TNextGrid; ASaveFileName: string);
var
  LStrList: TStringList;
  i, j: integer;
  LColName: string;
  LUtf8: RawUTF8;
  LDocList: IDocList;

  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  if ASaveFileName = '' then
    exit;

  LStrList := TStringList.Create;
  try
    TDocVariant.New(LCellValue);
    LDocList := DocList('[]');

    with AGrid do
    begin
      for i := 0 to RowCount - 1 do
      begin
        for j := 0 to Columns.Count - 1 do
        begin
          LColName := AGrid.Columns.Item[j].Name;
          LColumn := ColumnByName[LColName];
          LCell := CellByName[LColName, i];

          SetNxGridCellValue2Var(LColumn, LCell, LCellValue);
        end;

        LDocList.Append(LCellValue);
      end;
    end;

    LCellValue := LDocList.Json;
    LStrList.Text := VariantToUtf8(LCellValue);
    LStrList.SaveToFile(ASaveFileName, TEncoding.UTF8);
  finally
    LStrList.Free;
  end;
end;

procedure NextGridFromJsonFile(AGrid: TNextGrid; AFileName: string; AIsClearRow: Boolean);
var
  LStrList: TStringList;
  LStr: string;
  LDocList: IDocList;
  LUtf8: RawUTF8;
  LVar: variant;
  i: integer;
begin
  LStrList := TStringList.Create;
  try
    LStrList.LoadFromFile(AFileName, TEncoding.UTF8);

    LStr := LStrList.Text;
    LUtf8 := StringToUtf8(LStr);

    LDocList := DocList(LUtf8);

    for LVar in LDocList do
      GetListFromVariant2NextGrid(AGrid, LVar, True);

  finally
    LStrList.Free;
  end;
end;

//{ColumnName: Cell Value} �������� �����
function NextGrid2VariantFromColIndexAry(AGrid: TNextGrid; AColIndexAry: TArrayRecord<integer>): variant;
var
  i, j: integer;
  LColumnName: string;
  LUtf8: RawUTF8;
  LDocList: IDocList;
  LVar: variant;

  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  TDocVariant.New(Result);
  TDocVariant.New(LVar);

  for i := 0 to AGrid.RowCount - 1 do
  begin
    for j := 0 to AColIndexAry.Count - 1 do
    begin
      LColumnName := AGrid.Columns.Item[AColIndexAry[j]].Name;

      TDocVariantData(LVar).Value[LColumnName] := AGrid.CellsByName[LColumnName, i];
    end;

    LDocList.Append(LVar);
  end;

  Result := LDocList.Json;
end;

function GetJsonFromSelectedRow(AGrid: TNextGrid; ARemoveUnderBar: Boolean): string;
var
  i, j: integer;
  LColumnName: string;
  LV, LValue: variant;

  LCellValue: variant;
  LColumn: TnxCustomColumn;
  LCell: TCell;
begin
  TDocVariant.New(LV);

  for j := 0 to AGrid.Columns.Count - 1 do
  begin
    LColumnName := AGrid.Columns.Item[j].Name;

    if ARemoveUnderBar then
      LColumnName := strToken(LColumnName, '_');

    LValue := AGrid.Cells[j, AGrid.SelectedRow];
    TDocVariantData(LV).AddValue(LColumnName, LValue);
  end;//for

  Result := LV;
end;

procedure NextGridScrollToRow(AGrid: TNextGrid; ARow: integer);
begin
  if ARow = -1 then
    ARow := AGrid.SelectedRow;

  if ARow = -1 then
    exit;

  AGrid.ScrollToRow(ARow);
  AGrid.Row[ARow].Selected := True;
end;

procedure DeleteSelectedRow(ANextGrid: TNextGrid);
var
  i: Integer;
begin
  i := 0;
  while i < ANextGrid.RowCount do
  begin
    if ANextGrid.CellByName['check', i].AsBoolean then
    begin
      ANextGrid.DeleteRow(i);
    end else Inc(i);
  end;
end;

procedure DeleteCurrentRow(ANextGrid: TNextGrid);
begin
  ANextGrid.DeleteRow(ANextGrid.SelectedRow);
end;

procedure MoveRowDown(ANextGrid: TNextGrid);
begin
  ANextGrid.MoveRow(ANextGrid.SelectedRow, ANextGrid.SelectedRow + 1);
  ANextGrid.SelectedRow := ANextGrid.SelectedRow + 1;
end;

procedure MoveRowUp(ANextGrid: TNextGrid);
begin
  ANextGrid.MoveRow(ANextGrid.SelectedRow, ANextGrid.SelectedRow - 1);
  ANextGrid.SelectedRow := ANextGrid.SelectedRow - 1;
end;

procedure ShowOrHideAllColumn4NextGrid(ANextGrid: TNextGrid; AIsShow: Boolean);
var
  j: integer;
  LColumnName: string;
begin
  for j := 0 to ANextGrid.Columns.Count - 1 do
  begin
    ANextGrid.Columns.Item[j].Visible := AIsShow;
  end;//for
end;

function GetRowFromMouseDown(ANextGrid: TNextGrid; APoint: TPoint): integer;
var
  LRowNo,
  LRowY,
  LRowWithHeight: integer;
  LRowRect: TRect;
  i: integer;
begin
  Result := -1;

  with ANextGrid do
  begin
    LRowNo := 0;

    for i := 0 to RowCount - 1 do
    begin
      LRowRect := GetRowRect(LRowNo);

      if PtInRect(LRowRect, APoint) then
      begin
         Result := LRowNo;
         Break;
      end
      else
      begin
        LRowY := GetRowTop(LRowNo);//Row Top Point = Y

        if LRowY > APoint.Y then //���� row ���� ������ Ŭ���� ��� (Row Top Point > Mouse Point)
          Break;

        LRowWithHeight := (APoint.Y - LRowY) div RowSize;
        LRowNo := LRowNo + LRowWithHeight;
      end;
    end;

  end;
end;

function GetRowIndexFromFindNext(const ANextGrid: TNextGrid; AFindText: string;
  AColIdx: integer; var AFindFromRow: integer; AIgnoreCase: Boolean;
  AColName: string): integer;
var
  i: integer;
  LStr: string;
begin
  Result := -1;

  if AIgnoreCase then
    AFindText := UpperCase(AFindText);

  if AFindFromRow > ANextGrid.RowCount - 1 then
    AFindFromRow := 0;

  if AColIdx = -1 then
  begin
    for i := 0 to ANextGrid.Columns.Count - 1 do
    begin
      LStr := ANextGrid.Columns.Item[i].Name;

      if LStr = AColName then
      begin
        AColIdx := i;
        Break;
      end;
    end;
  end;

  if AColIdx = -1 then
    exit;

  for i := AFindFromRow to ANextGrid.RowCount - 1 do
  begin
    LStr := ANextGrid.Cell[AColIdx, i].AsString;

    if AIgnoreCase then
      LStr := UpperCase(LStr);

    if PosEx(AFindText, LStr) > 0 then
    begin
      Result := i;
      AFindFromRow := i + 1;
      Exit;
    end
    else
      AFindFromRow := 0;
  end;//for
end;

function GetSelectedIndexFromNextGrid(ANextGrid: TNextGrid): integer;
begin
  for Result := 0 to ANextGrid.RowCount - 1 do
  begin
    if ANextGrid.Selected[Result] then
      Break;
  end;
end;

end.
