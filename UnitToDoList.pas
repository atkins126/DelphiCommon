unit UnitToDoList;

interface

uses System.Classes, DateUtils, TodoList,
  mormot.rest.client, mormot.core.base, mormot.core.data, mormot.core.variants,
  mormot.core.text, mormot.core.datetime, mormot.core.collections
  ;

type
  TpjhTodoItemRec = packed record
    TaskID: TID;
    ImageIndex: Integer;
    Notes: TStringList;
    Tag: Integer;
    TotalTime: double;
    Subject: string;
    Completion: integer;//TCompletion;
    DueDate: TTimeLog;
    Priority: integer;//TTodoPriority;
    Status: integer;//TTodoStatus;
    OnChange: TNotifyEvent;
    Complete: Boolean;
    CreationDate: TTimeLog;
    CompletionDate: TTimeLog;
    Resource: string;
    DBKey: string;
    Project: string;
    Category: string;

    TodoCode,
    PlanCode,
    ModId: string;

    AlarmType,
    AlarmTime2, //AlarmType�� 2�� ���(��)
    AlarmFlag
    : integer;
    Alarm2Msg,   //���ڷ� �˸� = 1
    Alarm2Note,  //������ �˸� = 1
    Alarm2Email, //�̸��Ϸ� �˸� = 1
    Alarm2Popup //�ʾ�â���� �˸� = 1
    : Boolean;

    AlarmTime1, //AlarmType�� 1�� ��� �ð�
    ModDate: TTimeLog;

    AlarmTime: TTimeLog; //Alarm�� �߻� ���Ѿ��� �ð�
  end;

  TpjhToDoList = IList<TpjhTodoItemRec>;

implementation

end.
