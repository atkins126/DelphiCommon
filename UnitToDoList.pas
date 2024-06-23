unit UnitToDoList;

interface

uses System.Classes, DateUtils, TodoList,
  mormot.rest.client, mormot.core.base, mormot.core.data, mormot.core.variants,
  mormot.core.text, mormot.core.datetime, mormot.core.collections
  ;

type
  TpjhTodoItemRec = packed record
    RowID: TID; //DB ID
    TaskID: TID;
    ImageIndex: Integer;
    UniqueID: string;
    Notes: string;
    Tag: Integer;
    TotalTime: double;
    Subject: string;
    Completion: integer;//TCompletion;
    DueDate: TTimeLog;//��������
    Priority: integer;//TTodoPriority;
    Status: integer;//TTodoStatus;
    OnChange: TNotifyEvent;
    Complete: Boolean;
    CreationDate: TTimeLog;//��������
    BeginDate, //��������(��ȹ)
    BeginTime, //���۽ð�(��ȹ)
    EndDate,   //��������(��ȹ)
    EndTime,   //����ð�(��ȹ)
    CompletionDate: TTimeLog; //�Ϸ��� ����
    Resource: string;
    Project: string;
    Category: string;

    PlanCode,
    ModId: string;

    AlarmType,  //�̸��˸�����
    AlarmTime2, //AlarmType�� 2�� ���(��)
    AlarmFlag
    : integer;
    Alarm2Msg,   //���ڷ� �˸�
    Alarm2Note,  //������ �˸�
    Alarm2Email, //�̸��Ϸ� �˸�
    Alarm2Popup //�ʾ�â���� �˸�
    : Boolean;

    AlarmTime1, //AlarmType�� 1�� ��� �ð�
    ModDate: TTimeLog;

    AlarmTime: TTimeLog; //Alarm�� �߻� ���Ѿ��� �ð�
  end;

  TpjhToDoList = IList<TpjhTodoItemRec>;

implementation

end.
