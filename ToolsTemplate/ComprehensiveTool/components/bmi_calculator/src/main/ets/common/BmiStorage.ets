import { PersistenceV2, Type } from '@kit.ArkUI';
import { RecordItem } from './RecordItem';

@ObservedV2
export class RecordsModel {
  @Type(RecordItem)
  @Trace items: RecordItem[] = [];
}

PersistenceV2.notifyOnError((key: string, reason: string, msg: string) => {
  console.error(`error key: ${key}, reason: ${reason}, message: ${msg}`);
});

export function loadRecords(): RecordsModel {
  return PersistenceV2.connect(RecordsModel, 'bmi_records', () => {
    const model = new RecordsModel();
    model.items = [];
    return model;
  })!;
}

export function saveRecords(records: RecordsModel): void {
  PersistenceV2.save('bmi_records');
}

export function deleteRecord(id: string, records: RecordsModel): void {
  const index = records.items.findIndex(item => item.id === id);
  if (index !== -1) {
    records.items.splice(index, 1);
    PersistenceV2.save('bmi_records');
  }
}

export function addRecord(record: RecordItem, records: RecordsModel): void {
  records.items.unshift(record);
  if (records.items.length > 50) {
    records.items.splice(50);
  }
  PersistenceV2.save('bmi_records');
}

export function createRecordItem(height: number, weight: number, bmiValue: number, evaluation: string): RecordItem {
  return new RecordItem(height, weight, bmiValue, evaluation);
}

export function getLatestRecord(records: RecordsModel): RecordItem | null {
  return records.items.length > 0 ? records.items[0] : null;
}

export function getRecordById(id: string, records: RecordsModel): RecordItem | null {
  return records.items.find(item => item.id === id) || null;
}

