import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ChatContentSingleModel } from 'chat_base';

const TAG = 'PreferenceUtil';
const MSG_COLLECT: string = 'MsgCollect';

/**
 * 收藏组件的数据保存和数据获取工具类
 */
export class CollectDataManager {
  private static instance: CollectDataManager;
  private dataManager: preferences.Preferences | null = null;

  private constructor() {
    try {
      preferences.removePreferencesFromCacheSync(getContext(), 'default');
      this.dataManager = preferences.getPreferencesSync(getContext(), { name: 'default' });
    } catch (err) {
    }
  }

  public static getInstance() {
    if (!CollectDataManager.instance) {
      CollectDataManager.instance = new CollectDataManager();
    }
    return CollectDataManager.instance;
  }

  public setCollectData(value: string) {
    if (!this.dataManager) {
      hilog.error(0, TAG, 'dataManager is null');
    }
    try {
      this.dataManager?.putSync(MSG_COLLECT, value);
      this.dataManager?.flush();
    } catch (e) {
      hilog.error(0, TAG, `put error: ${JSON.stringify(e)}`);
    }
  }

  public getCollectData() {
    let msgCollectList: ChatContentSingleModel[] = [];
    try {
      let data = this.dataManager?.getSync(MSG_COLLECT, '') as string;
      if (data.length > 0) {
        msgCollectList = JSON.parse(data) as ChatContentSingleModel[];
      }
    } catch (e) {
      hilog.error(0, TAG, `get error: ${JSON.stringify(e)}`);
      msgCollectList = [];
    }
    return msgCollectList;
  }


  public addCollectMsg(chatMsg: ChatContentSingleModel) {
    if (chatMsg) {
      this.addCollectMsgToPref(chatMsg).then(() => {
      });
    }
  }

  private async addCollectMsgToPref(collectMsg: ChatContentSingleModel): Promise<void> {
    let addResult = false;
    let msgCollectList: ChatContentSingleModel[] = this.getCollectData();
    let chatMsgCollectModel: ChatContentSingleModel = collectMsg as ChatContentSingleModel;
    if (chatMsgCollectModel) {
      msgCollectList = msgCollectList.filter((item) => item.chatId !== chatMsgCollectModel.chatId)
      msgCollectList = [chatMsgCollectModel].concat(msgCollectList);
      addResult = true;
    } else {
      addResult = false;
    }
    return new Promise<void>((resolve, reject) => {
      setTimeout(() => {
        if (addResult) {
          CollectDataManager.getInstance()
            .setCollectData(msgCollectList ? JSON.stringify(msgCollectList).replaceAll('__ob_', '') : '');
          resolve();
        } else {
          reject()
        }
      }, 1000)
    });
  }
}