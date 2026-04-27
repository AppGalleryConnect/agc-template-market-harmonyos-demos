import { preferences } from '@kit.ArkData';
import { fileIo as fs } from '@kit.CoreFileKit';
import { loading } from '../components/CommonLoading';
import { MarkOptions } from '../types/Types';
import { PopViewUtils } from './PopViewUtils';
import { contextUtil } from './ContextUtil'

export class HistoryUtil {
  private static readonly _fileName: string = 'history_file';
  private static readonly _formIdKey: string = 'mark_id_key';

  public static getRecords() {
    const store = HistoryUtil._getStore();
    return store.getSync(HistoryUtil._formIdKey, []) as MarkOptions[];
  }

  public static async addOrUpdateRecord(options: MarkOptions) {
    const list = HistoryUtil.getRecords();
    const index = list.findIndex(info => info.file === options.file);
    if (index !== -1) {
      list.splice(index, 1);
    }
    list.unshift(options);
    const store = HistoryUtil._getStore();
    store.putSync(HistoryUtil._formIdKey, list);
    await store.flush();
  }

  public static async deleteRecord(fileNames: string[]) {
    PopViewUtils.showPopView(wrapBuilder(loading), { alignment: DialogAlignment.Center }, '正在删除...');
    const promises = fileNames.map(fileName => fs.unlink(contextUtil.getContext()?.filesDir + '/' + fileName));
    await Promise.all(promises);
    let list = HistoryUtil.getRecords();
    list = list.filter(item => fileNames.findIndex(fileName => fileName === item.file) === -1);
    const store = HistoryUtil._getStore();
    store.putSync(HistoryUtil._formIdKey, list);
    await store.flush();
    PopViewUtils.closePopView();
  }

  public static async clearRecords() {
    PopViewUtils.showPopView(wrapBuilder(loading), { alignment: DialogAlignment.Center }, '正在清空...');
    const list = HistoryUtil.getRecords();
    const promises = list.map(info => fs.unlink(contextUtil.getContext()?.filesDir + '/' + info.file));
    await Promise.all(promises);
    const store = HistoryUtil._getStore();
    store.putSync(HistoryUtil._formIdKey, []);
    await store.flush();
    PopViewUtils.closePopView();
  }

  private static _getStore() {
    return preferences.getPreferencesSync(contextUtil.getContext(), { name: HistoryUtil._fileName });
  }
}