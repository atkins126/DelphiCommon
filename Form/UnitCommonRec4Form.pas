unit UnitCommonRec4Form;

interface

uses
  mormot.core.json, mormot.core.collections;

type
  TRGValueRec = packed record
    Idx, //Radio Group Item Index
    Value: integer; //���� �Ҵ�� ��(��: kospi = 10 ������ radio group ���� ù��°�� ǥ�õ�=> Idx=0)
    //�ֽ��� ��� TrCode List�� �����:
    //��: Name = "�����ڵ�"�� ��� OPT10008������ 000:��ü, 001:�ڽ���, 101:�ڽ��� �̰�
    //�ٸ� TrCode������ ȸ���ڵ带 �ǹ���)
    Desc, //Name�� �ߺ��� ��� ������ �߰� ��Ģ
    Name  //RG�� ǥ���� Item Name
    : string;
  end;

  //key: RadioGroup Item Index(���� Index�� Value�� �����)
  TRGValueDict = IKeyValue<integer, TRGValueRec>;
  //key: Desc(Parameter �̸�)
  TRGValueOptionDict = IKeyValue<string, TRGValueDict>;

implementation

end.
