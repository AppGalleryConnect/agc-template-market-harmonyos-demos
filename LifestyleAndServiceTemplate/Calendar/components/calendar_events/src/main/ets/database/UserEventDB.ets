import { relationalStore } from '@kit.ArkData';
import { UtilLog } from '@hw-agconnect/util-log';
import { DBOperator, TablePredicate, TableSchema } from './DBConstants';
import { EVENT_TYPE } from '../constants/Constants';
import { UserEventItem } from '../model/UserEventModel';
import { rdbHelper } from './RdbHelper';

const TAG = '[UserEventDB]';
const DOMAIN = 0x0001;
const TABLE_NAME = 'user_event';

class UserEventDBClass {
  protected tableSchema: TableSchema = {
    tableName: TABLE_NAME,
    createSQL: `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
      id TEXT PRIMARY KEY,
      event_type TEXT,
      event_id INTEGER DEFAULT 0,
      content TEXT,
      start_date INTEGER,
      start_lunar_date TEXT,
      start_time TEXT,
      start_is_lunar INTEGER DEFAULT 0,
      end_date INTEGER,
      end_lunar_date TEXT,
      end_time TEXT,
      end_is_lunar INTEGER DEFAULT 0,
      repeat_type TEXT,
      remind_list TEXT,
      remarks TEXT,
      is_done INTEGER DEFAULT 0,
      created_at INTEGER DEFAULT 0
    )`,
    indexes: [
      `CREATE INDEX IF NOT EXISTS idx_event_type ON ${TABLE_NAME}(event_type)`,
      `CREATE INDEX IF NOT EXISTS idx_start_date ON ${TABLE_NAME}(start_date)`,
    ],
  };

  public async createTable(): Promise<void> {
    try {
      await rdbHelper.createTables(this.tableSchema);
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `create table failed. error: ${JSON.stringify(err)}`);
    }
  }

  public async insertEvent(item: UserEventItem): Promise<number> {
    const values = this._toValuesBucket(item);
    values.created_at = Date.now();
    return await rdbHelper.insert(TABLE_NAME, values);
  }

  public async batchInsertEvents(items: UserEventItem[]): Promise<number> {
    if (!items || items.length === 0) {
      return 0;
    }
    const valuesList = items.map(item => {
      const values = this._toValuesBucket(item);
      values.created_at = Date.now();
      return values;
    });
    return await rdbHelper.batchInsert(TABLE_NAME, valuesList);
  }

  public async updateEvent(item: UserEventItem): Promise<number> {
    const values = this._toValuesBucket(item);
    const conditions: TablePredicate[] = [
      { field: 'id', value: item.id, operator: DBOperator.EQUAL },
    ];
    return await rdbHelper.update(TABLE_NAME, values, conditions);
  }

  public async deleteEvent(id: string): Promise<number> {
    const conditions: TablePredicate[] = [
      { field: 'id', value: id, operator: DBOperator.EQUAL },
    ];
    return await rdbHelper.delete(TABLE_NAME, conditions);
  }

  public async queryAllEvents(): Promise<UserEventItem[]> {
    const conditions: TablePredicate[] = [
      { field: 'created_at', value: 0, operator: DBOperator.ORDER_BY_DESC },
    ];
    return await this._queryEvents(TABLE_NAME, conditions);
  }

  public async queryEventsByType(eventType: EVENT_TYPE): Promise<UserEventItem[]> {
    const conditions: TablePredicate[] = [
      { field: 'event_type', value: eventType, operator: DBOperator.EQUAL },
      { field: 'created_at', value: 0, operator: DBOperator.ORDER_BY_DESC },
    ];
    return await this._queryEvents(TABLE_NAME, conditions);
  }

  public async queryEventsByDateRange(startTime: number, endTime: number): Promise<UserEventItem[]> {
    const conditions: TablePredicate[] = [
      { field: 'start_date', value: startTime, operator: DBOperator.GREATER_OR_EQUAL },
      { field: 'end_date', value: endTime, operator: DBOperator.LESS_OR_EQUAL },
      { field: 'created_at', value: 0, operator: DBOperator.ORDER_BY_DESC },
    ];
    return await this._queryEvents(TABLE_NAME, conditions);
  }

  public async queryEventById(id: string): Promise<UserEventItem | undefined> {
    const conditions: TablePredicate[] = [
      { field: 'id', value: id, operator: DBOperator.EQUAL },
    ];
    const items = await this._queryEvents(TABLE_NAME, conditions);
    return items.length > 0 ? items[0] : undefined;
  }

  private async _queryEvents(tableName: string, conditions: TablePredicate[]): Promise<UserEventItem[]> {
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    const items: UserEventItem[] = [];
    try {
      resultSet = await rdbHelper.query(tableName, conditions);
      if (resultSet) {
        while (resultSet.goToNextRow()) {
          items.push(this._fromResultSet(resultSet));
        }
      }
    } catch (err) {
      UtilLog.error(DOMAIN, TAG, `_queryEvents failed. error: ${JSON.stringify(err)}`);
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    return items;
  }

  private _toValuesBucket(item: UserEventItem): relationalStore.ValuesBucket {
    return {
      'id': item.id,
      'event_type': item.eventType,
      'event_id': item.eventId,
      'content': item.content,
      'start_date': item.date[0].date.getTime(),
      'start_lunar_date': item.date[0].lunarDate,
      'start_time': item.date[0].time,
      'start_is_lunar': item.date[0].isLunar ? 1 : 0,
      'end_date': item.date[1].date.getTime(),
      'end_lunar_date': item.date[1].lunarDate,
      'end_time': item.date[1].time,
      'end_is_lunar': item.date[1].isLunar ? 1 : 0,
      'repeat_type': item.repeatType,
      'remind_list': JSON.stringify(item.remindList),
      'remarks': item.remarks,
      'is_done': item.isDone ? 1 : 0,
    };
  }

  private _fromResultSet(resultSet: relationalStore.ResultSet): UserEventItem {
    const colIndex = (colName: string) => resultSet.getColumnIndex(colName);
    const getString = (colName: string): string => resultSet.getString(colIndex(colName));
    const getLong = (colName: string): number => resultSet.getLong(colIndex(colName));
    const getNullableString = (colName: string): string | undefined => {
      const idx = colIndex(colName);
      return resultSet.isColumnNull(idx) ? undefined : resultSet.getString(idx);
    };

    const item = new UserEventItem();
    item.id = getString('id');
    item.eventType = getString('event_type') as EVENT_TYPE;
    item.eventId = getLong('event_id');
    item.content = getString('content');

    item.date[0].date = new Date(getLong('start_date'));
    item.date[0].lunarDate = getNullableString('start_lunar_date') ?? '';
    item.date[0].time = getNullableString('start_time') ?? '';
    item.date[0].isLunar = getLong('start_is_lunar') === 1;

    item.date[1].date = new Date(getLong('end_date'));
    item.date[1].lunarDate = getNullableString('end_lunar_date') ?? '';
    item.date[1].time = getNullableString('end_time') ?? '';
    item.date[1].isLunar = getLong('end_is_lunar') === 1;

    item.repeatType = getString('repeat_type');

    const remindListStr = getString('remind_list');
    try {
      item.remindList = JSON.parse(remindListStr) as string[];
    } catch (e) {
      item.remindList = [remindListStr];
    }
    item.remarks = getNullableString('remarks') ?? '';
    item.isDone = getLong('is_done') === 1;
    return item;
  }
}

const userEventDB = new UserEventDBClass();

export { userEventDB as UserEventDB };
