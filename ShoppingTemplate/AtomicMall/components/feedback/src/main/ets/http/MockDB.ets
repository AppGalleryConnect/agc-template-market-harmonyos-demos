import { FeedbackRecordDTO } from '../models/FeedbackRecordDTO';
import { FileUtils } from '../utils/FileUtils';

export interface MockData {
  feedbacks: FeedbackRecordDTO[];
}

const DB_FILE = 'feedback_database.json';

class MockDB {
  private data: MockData | null = null;

  public async save(): Promise<void> {
    if (this.data) {
      await FileUtils.saveJsonToCache(this.data, DB_FILE);
    }
  }

  public async getData(): Promise<MockData> {
    if (this.data) {
      return this.data;
    }
    return FileUtils.readJsonFromCache(DB_FILE).then((res:MockData)=>{
      this.data = res;
      return this.data;
    }).catch(async ()=>{
      this.data = { feedbacks: [] };
      await this.save();
      return this.data;
    });
  }
}

export const db: MockDB = new MockDB();
