unit UnitToDoList;

interface

uses System.Classes, DateUtils, TodoList,
  mormot.rest.client, mormot.core.base, mormot.core.data, mormot.core.variants,
  mormot.core.text, mormot.core.datetime, mormot.core.collections,
  UnitEnumHelper
  ;

type
  TTodoQueryDateType = (tdqdtNull, tdqdtCreation, tdqdtDuedate, tdqdtCompletion,
    tdqdtModDate, tdqdtAlarmTime, tdqdtFinal);

  TTodoCategory = (tdcSE, tdcMatPOR, tdcMatReclaim, tdcFinal);

  TpjhTodoItemRec = packed record
    RowID: TID; //DB ID
    TaskID: TID;
    ClaimServiceKind,
    OLObjectKind,//UnitOutLookDataType.TOLObjectKind
    ImageIndex: Integer;
    EntryId,
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
    Categories: string;

    Plan_Code,
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

  //key = UniqueID
  TpjhToDoList = IKeyValue<string, TpjhTodoItemRec>;//IList<TpjhTodoItemRec>;

const
  R_TodoQueryDateType : array[Low(TTodoQueryDateType)..High(TTodoQueryDateType)] of string =
    ('',
      '�����������ڱ���', '�����ϱ���', '�Ϸ��ϱ���', '�����������ڱ���', '�˶��߻��ð�����',
    '');

  R_TodoCategory : array[Low(TTodoCategory)..High(TTodoCategory)] of string =
    (
    'SE�漱', '����-POR', '����-ReClaim',
    '');

var
  g_TodoQueryDateType: TLabelledEnum<TTodoQueryDateType>;
  g_TodoCategory: TLabelledEnum<TTodoCategory>;

implementation

initialization
//  g_TodoQueryDateType.InitArrayRecord(R_TodoQueryDateType);
//  g_TodoCategory.InitArrayRecord(R_TodoCategory);

end.
