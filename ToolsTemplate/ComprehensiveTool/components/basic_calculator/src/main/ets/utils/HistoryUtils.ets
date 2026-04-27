import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageMap } from '../common/Constant';

export class HistoryItem {
  id: number = 0;
  value: string = '';

  constructor(id: number, value: string) {
    this.id = id;
    this.value = value;
  }
}

@ObservedV2
export class HistoryModel {
  @Trace result?: Array<HistoryItem> = [];
}

@ObservedV2
export class HistoryUtils {
  private static _index: number = 0;
  private static _historyResult: HistoryModel = AppStorageV2.connect(
    HistoryModel,
    AppStorageMap.HISTORY_RESULT,
    () => new HistoryModel(),
  )!;

  public static getHistoryResult(): Array<HistoryItem> {
    return HistoryUtils._historyResult.result ?? [];
  }

  public static updateHistoryResult(result: string) {

    HistoryUtils._historyResult.result?.push(new HistoryItem(HistoryUtils._index, result));
    HistoryUtils._index++;
  }

  public static clearHistoryResult() {
    HistoryUtils._historyResult.result = [];
  }

  public static getLatestRecord(): string {
    if (HistoryUtils._historyResult.result?.length) {
      return HistoryUtils._historyResult.result[HistoryUtils._historyResult.result.length - 1].value;
    }
    return '';
  }
}