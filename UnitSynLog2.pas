unit UnitSynLog2;

interface

uses System.SysUtils,
  mormot.core.log, mormot.core.base, mormot.core.os;

procedure InitSynLog(ALogFile: string='');
procedure DoLog(Amsg: string; ALogDate: Boolean = False;
  AMsgLevel: TSynLogInfo = sllEnter);

implementation

{����:
var
  ILog: ISynLog;

  ILog := TSynLog.Enter;
  ILog.Log(sllInfo,LStr);
}
procedure InitSynLog(ALogFile: string);
begin
  with TSynLog.Family do begin
//    Level := LOG_VERBOSE;
//    Level := [sllException,sllExceptionOS];
    Level := [sllInfo,sllError,sllException,sllExceptionOS];//sllEnter
//    EchoToConsole := LOG_VERBOSE; // log all events to the console
//    PerThreadLog := true;
//    PerThreadLog := ptOneFilePerThread; //ptIdentifiedInOnFile
//    HighResolutionTimeStamp := true;
//    AutoFlushTimeOut := 5;
//    CustomFileName := ExeVersion.ProgramName;
    NoEnvironmentVariable := True;
//    OnArchive := EventArchiveSynLZ; EventArchiveZip;
    ArchiveAfterDays := 1; // archive after one day
//    ArchivePath := '\\Remote\WKS2302\Archive\Logs'; // or any path
    if ALogFile = '' then
      ALogFile := 'C:\Temp\Logs\' + Executable.ProgramName;

    DestinationPath := ExtractFilePath(ALogFile);//ExeVersion.ProgramFilePath+'log'
    EnsureDirectoryExists(DestinationPath);
//    EchoCustom := aMyClass.Echo; // register third-party logger
//    NoFile := true; // ensure TSynLog won't use the default log file
    RotateFileCount := 5;    // will maintain a set of up to 5 files
    RotateFileSizeKB := 1024;//20*1024; // rotate by 20 MB logs
    RotateFileDailyAtHour := 0; //23;  rotate at 11:00 PM
//    FileExistsAction := acAppend;
  end;
end;

{
�Ʒ� �Լ��� Family.EchoCustom := aMyClass.Echo�� �����Ͽ� Customizing �� �� ����
procedur TMyClass.Echo(Sender: TTextWriter; Level: TSynLogLevel; const Text: RawUTF8);
begin
  if Level in LOG_STACKTRACE then //filter error
   writeln(Text);
end;
}
procedure DoLog(Amsg: string; ALogDate: Boolean = False;
  AMsgLevel: TSynLogInfo = sllEnter);
var
  ILog: ISynLog;
begin
  if ALogDate then
    AMsg := DateTimeToStr(now) + ':: ' + AMsg;

  ILog := TSynLog.Enter;

  if AMsgLevel in TSynLog.Family.Level then
    ILog.Log(AMsgLevel, Amsg);
end;

end.
