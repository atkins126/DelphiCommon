unit UnitSerialCommWorker;

interface

uses Windows, Winapi.Messages, System.SysUtils, System.SyncObjs, System.Classes,
  OtlComm, OtlCommon, GpSharedEvents, UnitWorker4OmniMsgQ,
  mormot.core.collections, mormot.core.json,
  JHP.Util.gpSharedMemType, JHP.Util.gpSharedMem,
  UnitSerialCommThread;

type
  TSerialCommWorker = class(TWorker2)
  private
    FSerialCommThread: TSerialCommThread;
    FOwnerFormHandle: THandle;

    procedure CustomCreate; override;
  protected
    procedure ProcessCommandProc(AMsg: TOmniMessage); override;
  public
    destructor Destroy(); override;
    procedure InitVar();
    procedure DestroyVar();

    procedure SetMainFormHandle(AHandle: THandle);
  end;

implementation

{ TSerialCommWorker }

procedure TSerialCommWorker.CustomCreate;
begin
  InitVar();
end;

destructor TSerialCommWorker.Destroy;
begin
  DestroyVar();

  inherited;
end;

procedure TSerialCommWorker.DestroyVar;
begin

end;

procedure TSerialCommWorker.InitVar;
begin
//  FSerialCommThread := TSerialCommThread.Create();
end;

procedure TSerialCommWorker.ProcessCommandProc(AMsg: TOmniMessage);
begin
  case TFunctionMode(AMsg.MsgID) of
    CM_DATA_READ: begin
//      ProcessUserInfoRespond(AMsg);
    end;
  end;//case
end;

procedure TSerialCommWorker.SetMainFormHandle(AHandle: THandle);
begin
  FOwnerFormHandle := AHandle;
end;

end.
