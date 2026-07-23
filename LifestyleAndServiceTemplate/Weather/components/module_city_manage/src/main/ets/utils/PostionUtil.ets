import { preferences } from '@kit.ArkData';
import { IPosition } from '../types/Types';
import { UIContext } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Utils';

const TAG = '[PositionUtl]';

export class PositionUtl {
  private static readonly _fileName: string = 'weather_file';
  private static readonly _positionKey: string = 'weather_position_key';

  public static getPostionList() {
    try {
      const store = PositionUtl._getStore();
      return store.getSync(PositionUtl._positionKey, []) as IPosition[];
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get position list. Code: ${err.code}, message: ${err.message}`);
      return [];
    }
  }

  private static _getStore() {
    let uiContext = AppStorage.get('city_manage_uiContext') as UIContext
    try {
      return preferences.getPreferencesSync(uiContext.getHostContext(), { name: PositionUtl._fileName });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get preferences. Code: ${err.code}, message: ${err.message}`);
      throw new Error(`Failed to get preferences. Code: ${err.code}, message: ${err.message}`);
    }
  }

  public static async add(postion: IPosition) {
    const list = PositionUtl.getPostionList();
    if (!list.some(item => postion.code === item.code)) {
      list.push(postion);
      try {
        const store = PositionUtl._getStore();
        store.putSync(PositionUtl._positionKey, list);
        await store.flush();
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to add position. Code: ${err.code}, message: ${err.message}`);
      }
    }
  }

  public static async delete(code: string) {
    const list = PositionUtl.getPostionList();
    const index = list.findIndex(item => item.code === code);
    if (index !== -1) {
      list.splice(index, 1);
      try {
        const store = PositionUtl._getStore();
        store.putSync(PositionUtl._positionKey, list);
        await store.flush();
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to delete position. Code: ${err.code}, message: ${err.message}`);
      }
    }
  }

  public static async update(list: IPosition[]) {
    try {
      const store = PositionUtl._getStore();
      store.putSync(PositionUtl._positionKey, list);
      await store.flush();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to update positions. Code: ${err.code}, message: ${err.message}`);
    }
  }
}