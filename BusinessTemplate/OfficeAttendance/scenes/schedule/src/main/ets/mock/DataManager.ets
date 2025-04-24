// PreferencesManager.ets（数据存储）
import preferences from '@ohos.data.preferences';
import { ScheduleInfo } from '../types/Types';

export class DataManager {
  private static DATA_MAP: Map<string, ScheduleInfo[]> = new Map();
  private static ID: number = 1000;
  private static readonly KEY: string = 'schedule';

  static init() {
  }

  static getId() {
    return '' + DataManager.ID++;
  }

  static saveOne(item: ScheduleInfo) {
    let items: ScheduleInfo[] = DataManager.loadAll();
    if (item.id) {
      const newTaskItems: ScheduleInfo[] = [];
      newTaskItems.push(item);
      items.forEach(t => {
        if (item.id !== t.id) {
          newTaskItems.push(t);
        }
      });
      DataManager.save(newTaskItems);
    } else {
      item.id = DataManager.getId();
      items.push(item);
      DataManager.save(items);
    }
  }


  static queryByDate(date: string): ScheduleInfo[] {
    let items: ScheduleInfo[] = DataManager.loadAll();
    return items.filter(t => {
      if (t.startTime) {
        return t.startTime.startsWith(date);
      }
      return false;
    });
  }

  static queryScheduleDates(fromDate: string, toDate: string): Array<string> {
    let items: ScheduleInfo[] = DataManager.loadAll();
    let dates: Array<string> = [];
    items.forEach(t => {
      if (t.startTime) {
        dates.push(t.startTime)
      }
    });
    return dates;
  }


  static queryById(id: string): ScheduleInfo | undefined {
    let items: ScheduleInfo[] = DataManager.loadAll();
    let target: ScheduleInfo[] = items.filter(t => {
      return t.id === id
    });
    if (target?.length > 0) {
      return target[0]
    }
    return undefined;
  }

  static queryByName(name: string): ScheduleInfo[] {
    let items: ScheduleInfo[] = DataManager.loadAll();
    return items.filter(t => {
      if (t.title) {
        return t.title?.indexOf(name) >= 0;
      }
      return -1;
    });
  }

  static deleteById(id: string) {
    const newItems: ScheduleInfo[] = [];
    let items: ScheduleInfo[] = DataManager.loadAll();
    items.forEach(t => {
      if (id !== t.id) {
        newItems.push(t);
      }
    });
    DataManager.save(newItems);
  }

  static async save(todos: ScheduleInfo[]) {
    DataManager.DATA_MAP.set(DataManager.KEY, todos)
  }

  static loadAll(): ScheduleInfo[] {
    let data = DataManager.DATA_MAP.get(DataManager.KEY) as ScheduleInfo[];
    if (data) {
      return data;
    }
    return [];
  }
}