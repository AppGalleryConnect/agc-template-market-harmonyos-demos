import relationalStore from '@ohos.data.relationalStore';
import dayjs from 'dayjs';
import { DBOperator } from '../commons/Enum';
import { DiaryTableData, DiaryTablePredicate, TableSchema } from '../commons/Interface';
import { Diary } from '../models/Diary';
import { BaseDB } from './BaseDB';

const TAG = '[DiaryDB]';

class DiaryDB extends BaseDB {
  protected dbConfig: relationalStore.StoreConfig = {
    name: 'Diary.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };
  protected tableSchemas: TableSchema[] = [
    {
      tableName: 'diaries',
      createSQL: `CREATE TABLE IF NOT EXISTS diaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        htmlContent TEXT NOT NULL,
        textContent TEXT NOT NULL,
        moodText TEXT,
        moodIcon TEXT,
        weatherText TEXT,
        weatherIcon TEXT,
        firstImage TEXT,
        yearMonth TEXT NOT NULL,
        createTime TEXT NOT NULL,
        updateTime TEXT NOT NULL,
        isPrivacy BOOLEAN DEFAULT false
      )`,
      indexes: ['CREATE INDEX IF NOT EXISTS index_updateTime ON diaries(updateTime)'],
    },
  ];

  public async initDB(context: Context) {
    await super.initDB(context);
  }

  // 查询日记列表
  public async queryDiaryList(date: string = ''): Promise<DiaryTableData[]> {
    const sql = `SELECT * FROM diaries
      WHERE (:yearMonth = '' OR yearMonth = :yearMonth)
      ORDER BY updateTime DESC
    `;
    const diaryList = await this.querySql<DiaryTableData>(sql, date);
    return diaryList;
  }

  // 根据id查询日记
  public async queryDiaryById(id: string): Promise<DiaryTableData> {
    const sql = 'SELECT * FROM diaries WHERE id = :id';
    const diary = await this.querySql<DiaryTableData>(sql, id);
    return diary[0];
  }

  // 添加日记
  public async insertDiary(diary: Diary) {
    const data = {
      htmlContent: diary.htmlContent,
      textContent: diary.textContent,
      moodText: diary.moodText,
      moodIcon: diary.moodIcon,
      weatherText: diary.weatherText,
      weatherIcon: diary.weatherIcon,
      createTime: diary.createTime,
      updateTime: diary.updateTime,
      yearMonth: dayjs(new Date(Number(diary.updateTime))).format('YYYY-MM'),
      firstImage: diary.firstImage,
      isPrivacy: diary.isPrivacy,
    } as DiaryTableData;
    return await this.insert('diaries', data);
  }

  // 删除日记
  public async deleteDiary(id: string) {
    const condition = {
      field: 'id',
      value: id,
      operator: DBOperator.EQUAL
    } as DiaryTablePredicate

    await this.delete('diaries', [condition]);
  }

  // 更新日记
  public async updateDiary(diary: Diary) {
    const data = {
      htmlContent: diary.htmlContent,
      textContent: diary.textContent,
      moodText: diary.moodText,
      moodIcon: diary.moodIcon,
      weatherText: diary.weatherText,
      weatherIcon: diary.weatherIcon,
      createTime: diary.createTime,
      updateTime: diary.updateTime,
      yearMonth: dayjs(new Date(Number(diary.updateTime))).format('YYYY-MM'),
      firstImage: diary.firstImage,
      isPrivacy: diary.isPrivacy,
    } as DiaryTableData;

    const condition = {
      field: 'id',
      value: diary.id,
      operator: DBOperator.EQUAL
    } as DiaryTablePredicate
    await this.update('diaries', data, [condition]);
  }
}

const diaryDB = new DiaryDB();

export { diaryDB as DiaryDB };