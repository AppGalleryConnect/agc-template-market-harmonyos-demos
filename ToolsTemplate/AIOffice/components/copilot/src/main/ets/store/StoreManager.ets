import { Message } from '../model/Messages'
import { relationalStore } from '@kit.ArkData';
import { jsonToMessages, messagesToJson } from '../utils/utils';

// 数据库配置
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'CopilotStore.db',
  securityLevel: relationalStore.SecurityLevel.S1,
  encrypt: false,
};

// 数据库表结构 - 简化为单表设计
const CREATE_THREADS_TABLE = `CREATE TABLE IF NOT EXISTS threads (
  thread_id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  create_time INTEGER NOT NULL,
  store_id TEXT NOT NULL,
  messages TEXT DEFAULT '[]'
)`;

export class StoreManager {
  private static storeMap : Map<string, CopilotStore> = new Map();

  static getStore(storeId: string = 'chat') : CopilotStore {
    let store = StoreManager.storeMap.get(storeId);
    if (store) {
      return store;
    }
    let newStore = new CopilotStore(storeId);
    StoreManager.storeMap.set(storeId, newStore);
    return newStore;
  }
}

export interface StoreInfo {
  threadId: string;
  title?: string;
  createTime: number;
  messages?:Message[];
}

export class CopilotStore {
  private storeId: string;
  private rdbStore: relationalStore.RdbStore | null = null;

  constructor(storeId: string) {
    this.storeId = storeId;
    this.initDatabase();
  }

  private async initDatabase(): Promise<void> {
    try {
      this.rdbStore = await relationalStore.getRdbStore(getContext(), STORE_CONFIG);
      
      // 创建表
      await this.rdbStore.executeSql(CREATE_THREADS_TABLE);
    } catch (error) {
      console.error('初始化数据库失败:', error);
    }
  }

  private async ensureDatabase(): Promise<relationalStore.RdbStore> {
    if (!this.rdbStore) {
      await this.initDatabase();
    }
    if (!this.rdbStore) {
      throw new Error('数据库初始化失败');
    }
    return this.rdbStore;
  }

  async loadMessages(threadId: string): Promise<StoreInfo> {
    try {
      const rdbStore = await this.ensureDatabase();

      // 查询会话信息和消息
      const threadPredicates = new relationalStore.RdbPredicates('threads');
      threadPredicates.equalTo('thread_id', threadId).and().equalTo('store_id', this.storeId);
      const threadResultSet = await rdbStore.query(threadPredicates);
      
      if (!threadResultSet.goToFirstRow()) {
        threadResultSet.close();
        throw new Error(`会话 ${threadId} 不存在`);
      }

      const storeInfo: StoreInfo = {
        threadId: threadResultSet.getString(threadResultSet.getColumnIndex('thread_id')),
        title: threadResultSet.getString(threadResultSet.getColumnIndex('title')),
        createTime: threadResultSet.getLong(threadResultSet.getColumnIndex('create_time')),
        messages: []
      };

      // 从JSON字段解析消息
      const messagesJson = threadResultSet.getString(threadResultSet.getColumnIndex('messages'));
      storeInfo.messages = jsonToMessages(messagesJson || '[]');
      
      threadResultSet.close();
      return storeInfo;
    } catch (error) {
      console.error('加载消息失败:', error);
      throw new Error('加载消息失败');
    }
  }

  async saveMessages(info: StoreInfo): Promise<void> {
    try {
      const rdbStore = await this.ensureDatabase();
      
      // 序列化消息为JSON
      const messagesJson = messagesToJson(info.messages ?? []);
      
      // 准备会话记录
      const threadRecord: relationalStore.ValuesBucket = {
        thread_id: info.threadId,
        title: info.title || `会话 ${new Date().toLocaleString()}`,
        create_time: info.createTime ?? Date.now(),
        store_id: this.storeId,
        messages: messagesJson
      };

      // 检查会话是否已存在
      const threadPredicates = new relationalStore.RdbPredicates('threads');
      threadPredicates.equalTo('thread_id', info.threadId).and().equalTo('store_id', this.storeId);
      const existingThread = await rdbStore.query(threadPredicates);
      
      if (existingThread.goToFirstRow()) {
        // 会话已存在，更新
        const updatePredicates = new relationalStore.RdbPredicates('threads');
        updatePredicates.equalTo('thread_id', info.threadId).and().equalTo('store_id', this.storeId);
        await rdbStore.update({
          title: threadRecord.title,
          messages: messagesJson
        }, updatePredicates);
        existingThread.close();
      } else {
        // 会话不存在，插入新记录
        await rdbStore.insert('threads', threadRecord);
        existingThread.close();
      }
    } catch (error) {
      console.error('保存消息失败:', error);
      throw new Error('保存消息失败');
    }
  }

  async getAll(): Promise<StoreInfo[]> {
    try {
      const rdbStore = await this.ensureDatabase();
      
      // 查询所有会话
      const threadPredicates = new relationalStore.RdbPredicates('threads');
      threadPredicates.equalTo('store_id', this.storeId).orderByDesc('create_time');
      const threadResultSet = await rdbStore.query(threadPredicates);

      const storeInfos: StoreInfo[] = [];
      
      if (threadResultSet.goToFirstRow()) {
        do {
          const storeInfo: StoreInfo = {
            threadId: threadResultSet.getString(threadResultSet.getColumnIndex('thread_id')),
            title: threadResultSet.getString(threadResultSet.getColumnIndex('title')),
            createTime: threadResultSet.getLong(threadResultSet.getColumnIndex('create_time')),
            messages: [] // 不加载消息内容，只返回会话基本信息
          };
          storeInfos.push(storeInfo);
        } while (threadResultSet.goToNextRow());
      }
      threadResultSet.close();

      return storeInfos;
    } catch (error) {
      console.error('获取所有会话失败:', error);
      throw new Error('获取所有会话失败');
    }
  }

  async deleteMessages(threadId?: string): Promise<void> {
    try {
      const rdbStore = await this.ensureDatabase();
      
      if (!threadId) {
        throw new Error('必须提供threadId');
      }

      // 删除会话（包含消息）
      const threadPredicates = new relationalStore.RdbPredicates('threads');
      threadPredicates.equalTo('thread_id', threadId).and().equalTo('store_id', this.storeId);
      const deletedRows = await rdbStore.delete(threadPredicates);

      if (deletedRows === 0) {
        throw new Error(`会话 ${threadId} 不存在或不属于当前store`);
      }
    } catch (error) {
      console.error('删除消息失败:', error);
      throw new Error('删除消息失败');
    }
  }
}