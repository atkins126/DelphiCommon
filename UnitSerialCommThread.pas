unit UnitSerialCommThread;

interface

uses Windows, classes, Forms, SysUtils, Dialogs, Messages,
  mormot.core.variants, mormot.core.os,
  MyKernelObject4GpSharedMem, CPort,
  UnitCopyData;

const
  WM_RECEIVESTRINGFROMCOMM = WM_USER + 100;

Type
  TCommMode = (cmChar, cmBin);
  TFunctionMode = (CM_DATA_READ, CM_CONFIG_READ, CM_DATA_WRITE, CM_CONFIG_WRITE, CM_CONFIG_WRITE_CONFIRM);

  TSerialCommThread = class(TThread)
    FOwnerFormHandle: THandle;
    FComPort: TComPort;
    FQueryInterval: integer;//Query ����(mSec)
    FSuspendCommThread: Boolean;//��� �Ͻ� ���� = True
    FTimeOut: integer;//��� Send�� ���� Send���� Timeout �ð�(mSec) - INFINITE
    FCommMode: TCommMode;
    FSendBuf: array[0..255] of byte;//cmBin Mode���� ����ϴ� �۽� ����
    FBufStr: String;//cmChar Mode���� ���Ǵ� ���Ź���
    FRepeatCount: integer;//�ݺ�ȸ��

    FSendEvent, //Send�ϴ� Event
    FReceiveEvent: TEvent;//Send�� �� Receive�Ҷ����� Wait�ϴ� Event
    FSendCommandList: TStringList;//�ݺ������� ������ ��� ����Ʈ
    FWriteCommandList: TStringList;//Write ��� ����Ʈ
    FSendCommandOnce: string;//�ѹ��� ������ ���
    FConfigFileName: string;
    FIsCommportInitialized: Boolean;//Commport �ʱ�ȭ �Ϸ�Ǹ� True
    FUseSendEvent: Boolean;

    procedure OnReceiveComm(Sender: TObject; Count: Integer);
    procedure SetSuspendCommThread(Value: Boolean);
    procedure SetTimeOut(Value: integer);
    procedure SetQueryInterval(Value: integer);
  protected
    procedure Execute; override;
  public
    FIsConfirmAfterWrite: Boolean;//write function ���� �� return�� Ȯ���� ���  true
    FFunctionMode: TFunctionMode;

    constructor Create(AFormHandle: THandle=0; AQureyInterval: integer=1000; ATimeOut: integer=3000);
    destructor Destroy; override;
//    function LoadCommPortFromFile(AIniFileName: string=''): Boolean;
//    procedure SaveComPortToFile(AIniFileName: string);
    procedure SaveSerialCommConfig2File(AFileName: string);
    function LoadSerialCommConfigFromFile(AFileName: string): Boolean;

    function InitCommPort(APortName: string; ABaudRate: string='9600';
      ADataBit: string='8'; AStopBit: string='1'; AParity: String='None'): Boolean;
    function InitCommPortFromPort(AComPort: TComPort): Boolean;
    procedure SetCommPort2Dest(ADestComPort: TComPort);
    function ResetCommport: Boolean;

    procedure SendQuery;
    procedure SendString(AString: string);
    procedure SendBufClear;

    procedure SetMainFormHandle(AHandle: THandle);
  published
    property ConfigFileName: string read FConfigFileName write FConfigFileName;
    property CommPort: TComPort read FComPort write FComPort;
    property SuspendCommThread: Boolean read FSuspendCommThread write SetSuspendCommThread;
    property IsCommportInitialized: Boolean read FIsCommportInitialized write FIsCommportInitialized;
    property UseSendEvent: Boolean read FUseSendEvent write FUseSendEvent;
    property TimeOut: integer read FTimeOut write SetTimeOut;
    property QueryInterval: integer read FQueryInterval write SetQueryInterval;
    property RepeatCount: integer read FRepeatCount write FRepeatCount;
    property CommMode: TCommMode read FCommMode write FCommMode;
  end;

implementation

{ TSerialCommThread }

constructor TSerialCommThread.Create(AFormHandle: THandle;
  AQureyInterval: integer; ATimeOut: integer);
begin
  inherited Create(True);

  FreeOnTerminate := True;

  FOwnerFormHandle := AOwner;
  FSuspendCommThread := False;
  FTimeOut := ATimeOut; //3�� ��ٸ� �Ŀ� ��� ����� ������(Default = INFINITE)
  FComport := TComport.Create(nil);
  FComport.OnRxChar := OnReceiveComm;

  FSendEvent := TEvent.Create('',False);
  FReceiveEvent := TEvent.Create('',False);
  FSendCommandList := TStringList.Create;
  FWriteCommandList := TStringList.Create;
  FUseSendEvent := True;

//  Resume;
end;

destructor TSerialCommThread.Destroy;
begin
  if Assigned(FComport) then
    FComport.Free;

  FSendEvent.Free;
  FReceiveEvent.Free;
  FWriteCommandList.Free;
  FSendCommandList.Free;

  inherited;
end;

procedure TSerialCommThread.Execute;
begin
  while not terminated do
  begin
    if FSuspendCommThread then
      Suspend;

    if FUseSendEvent then
    begin
      if FSendEvent.Wait(FTimeOut) then
        SendQuery();
    end
    else
      SendQuery();
  end;
end;

function TSerialCommThread.InitCommPort(APortName, ABaudRate: string;
  ADataBit: string; AStopBit: string; AParity: String): Boolean;
begin
  Result := False;

  if Assigned(FComport) then
  begin
    FComport.Close;
  end
  else
  begin
    FComport := TComport.Create(nil);
    FComport.OnRxChar := OnReceiveComm;
  end;

  with FComport do
  begin
    FlowControl.ControlDTR := dtrEnable;
    Port := APortName;
    BaudRate := StrToBaudRate(ABaudRate);
    StopBits := StrToStopBits(AStopBit);
    DataBits := StrToDataBits(ADataBit);
    Parity.Bits := StrToParity(AParity);
  end;

  FIsCommportInitialized := True;
  Result := True;
end;

function TSerialCommThread.InitCommPortFromPort(AComPort: TComPort): Boolean;
begin
  InitCommPort(AComport.Port,
               BaudRateToStr(AComport.BaudRate),
               DataBitsToStr(AComport.DataBits),
               StopBitsToStr(AComport.StopBits));
end;

//function TSerialCommThread.LoadCommPortFromFile(AIniFileName: string): Boolean;
//begin
//  Result := False;
//
//  if not Assigned(FComport) then
//  begin
//    FComport.Create(nil);
//    FComport.OnRxChar := OnReceiveComm;
//  end;
//
//  if AIniFileName = '' then
//    AIniFileName := ChangeFileExt(Application.ExeName, '.ini');
//
//  if FileExists(AIniFileName) then
//  begin
//    FComport.LoadSettings(stIniFile, AIniFileName);
//    Result := True;
//  end
//  else
//    ShowMessage('File not found : ' + AIniFIleName);
//end;

function TSerialCommThread.LoadSerialCommConfigFromFile(
  AFileName: string): Boolean;
var
  LDoc: TDocvariantData;
  LRawString: RawbyteString;
begin
  Result := False;

  if not FileExists(AFileName) then
    exit;

  LRawString := StringFromFile(AFileName);

  if LRawString <> '' then
  begin
    LDoc.InitJson(LRawString);

    FComPort.Port := LDoc.Value['PORT'];
    FComPort.BaudRate := TBaudRate(LDoc.Value['BAUDRATE']);
    FComPort.DataBits := TDataBits(LDoc.Value['DATABIT']);
    FComPort.StopBits := TStopBits(LDoc.Value['STOPBIT']);
    FComPort.Parity.Bits := TParityBits(LDoc.Value['PARITY']);
    FComPort.FlowControl.FlowControl := TFlowControl(LDoc.Value['FLOWCONTROL']);

    FIsCommportInitialized := True;
  end;

  Result := True;
end;

procedure TSerialCommThread.OnReceiveComm(Sender: TObject; Count: Integer);
var
  TmpBufStr: String;
  LBufByte: Array[0..255] of Byte;
begin
  try
    SendCopyData2(FOwnerFormHandle, 'RxTrue', 0);

    if FCommMode = cmChar then
    begin
      //���� �ʱ�ȭ
      TmpBufStr := '';
      //���ۿ� ���ڿ��� ������
      FComPort.ReadStr(TmpBufStr, Count);
      FBufStr := FBufStr + TmpBufStr;

      //CRLF�� ������ ���� �ϼ����� ���� ��Ŷ��
      if System.Pos(#13#10, FBufStr) = 0 then
        exit;

      FOwnerFormHandle.Hint := FBufStr;
      FBufStr := '';
      PostMessage(FOwnerFormHandle, WM_RECEIVESTRINGFROMCOMM, 0, 0);
    end
    else
    if FCommMode = cmBin then
    begin
      //���� �ʱ�ȭ
      FillChar(LBufByte, SizeOf(LBufByte),0);
      //���ۿ� ��簪�� ������
      FComPort.Read(LBufByte, Count);

    end;
  finally
    SendCopyData2(FOwnerFormHandle, 'RxFalse', 0);
  end;
end;

function TSerialCommThread.ResetCommport: Boolean;
begin
  with FComport do
  begin
    if Connected then
      Close;

    //�����Ʈ�� �����Ѵ�
    Open;
    Sleep(100);
    ClearBuffer(True,True);
  end;//with
end;

//procedure TSerialCommThread.SaveComPortToFile(AIniFileName: string);
//begin
//  FComport.StoreSettings(stIniFile, AIniFileName);
//end;

procedure TSerialCommThread.SaveSerialCommConfig2File(AFileName: string);
var
  LDoc: TDocvariantdata;
begin
  LDoc.Init();

  LDoc.AddValue('PORT',  FComPort.Port);
  LDoc.AddValue('BAUDRATE',  Ord(FComPort.BaudRate));
  LDoc.AddValue('DATABIT',  Ord(FComPort.DataBits));
  LDoc.AddValue('STOPBIT',  Ord(FComPort.StopBits));
  LDoc.AddValue('PARITY',  Ord(FComPort.Parity.Bits));
  LDoc.AddValue('FLOWCONTROL',  Ord(FComPort.FlowControl.FlowControl));

  FileFromString(LDoc.ToJson, AFileName);
end;

procedure TSerialCommThread.SendBufClear;
begin
  FillChar(FSendBuf, Length(FSendBuf), #0);
end;

procedure TSerialCommThread.SendQuery;
var
  i: integer;

  procedure InternalSendQuery(ACommand: string; Aindex: integer);
  var
    Li: integer;
  begin
    if SuspendCommThread then
      exit;

    SendCopyData2(FOwnerFormHandle.Handle, ' ', 1);
    //SystemBase���� �����Ϳ����� Send�ÿ� RTS�� High�� �ؾ���
//    FComport.SetRTS(True);
    //Char Mode�� ���
    if FCommMode = cmChar then
    begin
      FComPort.Writestr(ACommand);
      SendCopyData2(FOwnerFormHandle, ACommand, 1);
    end
    else if FCommMode = cmBin then// Bin Mode�� ���
    begin
//      SendLength := String2HexByteAry(tmpStr, FSendBuf);
//      FReqByteCount := FSendBuf[5];

//      FComport.Write(FSendBuf[0], SendLength);
//      SendBufClear();
//      SendCopyData2(FOwnerFormHandle.Handle, tmpStr, 1);
    end;

    FOwnerFormHandle.Tag := Aindex;
//    FComport.SetRTS(False);
    Sleep(FQueryInterval);

//    if FEventHandle.Wait(FTimeOut) then
//    begin
//      if terminated then
//        exit;
//    end;
  end;
begin
  //Thread�� Suspend�Ǹ� ����ÿ� Resume�� �ѹ� �� �ֹǷ�
  //����ÿ� �� ��ƾ�� ������� �ʰ� �ϱ� ����
  if FSuspendCommThread then
    exit;

  if FWriteCommandList.Count > 0 then
  begin
    if FIsConfirmAfterWrite then
    begin
      FFunctionMode := CM_CONFIG_WRITE_CONFIRM;
      FIsConfirmAfterWrite := False;
    end
    else
      FFunctionMode := CM_CONFIG_WRITE;

    try
      i := 0;

      while i < FWriteCommandList.Count do
      begin
        SendCopyData2(FOwnerFormHandle, '=== Write Command ===', 1);
        InternalSendQuery(FWriteCommandList.Strings[i],i);
        Inc(i);

//        FWriteCommandList.Delete(0);
      end;
    finally
      if FRepeatCount = 0 then
        FWriteCommandList.Clear;
    end;
  end;

  if FSendCommandOnce <> '' then
  begin
    FFunctionMode := CM_CONFIG_READ;
    SendCopyData2(FOwnerFormHandle, '=== Once Read Command ===', 1);
    InternalSendQuery(FSendCommandOnce, -1);
    FSendCommandOnce := '';
  end;

  for i := 0 to FSendCommandList.Count - 1 do
  begin
    FFunctionMode := CM_DATA_READ;

    InternalSendQuery(FSendCommandList.Strings[i],i);
  end;//for
end;

procedure TSerialCommThread.SendString(AString: string);
begin
  FSendCommandOnce := AString+#10;

  if FUseSendEvent then
    FSendEvent.Signal;
end;

procedure TSerialCommThread.SetCommPort2Dest(ADestComPort: TComPort);
begin
  with ADestComPort do
  begin
    FlowControl.ControlDTR := dtrEnable;
    Port := FComPort.Port;
    BaudRate := FComPort.BaudRate;
    StopBits := FComPort.StopBits;
    DataBits := FComPort.DataBits;
    Parity.Bits := FComPort.Parity.Bits;
  end;
end;

procedure TSerialCommThread.SetMainFormHandle(AHandle: THandle);
begin
  FOwnerFormHandle := AHandle;
end;

procedure TSerialCommThread.SetQueryInterval(Value: integer);
begin
  if FQueryInterval <> Value then
    FQueryInterval := Value;
end;

procedure TSerialCommThread.SetSuspendCommThread(Value: Boolean);
begin
  if FSuspendCommThread <> Value then
  begin
    FSuspendCommThread := Value;

    if FSuspendCommThread then
      //Suspend
    else
      if Suspended then
        Resume;
  end;
end;

procedure TSerialCommThread.SetTimeOut(Value: integer);
begin
  if FTimeOut <> Value then
    FTimeOUt := Value;
end;

end.
