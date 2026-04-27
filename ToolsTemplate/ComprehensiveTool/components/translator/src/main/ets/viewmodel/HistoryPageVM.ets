import { MyHistory } from '../model/History';
import { PersistenceV2 } from '@kit.ArkUI';

@ObservedV2
export class HistoryPageVM {
  private static _instance: HistoryPageVM
  @Trace history = PersistenceV2.connect(MyHistory, () => new MyHistory())!;
  @Trace expandIndex: number = -1
  @Trace delId: string = ''

  public static get instance() {
    if (!HistoryPageVM._instance) {
      HistoryPageVM._instance = new HistoryPageVM();
    }
    return HistoryPageVM._instance;
  }

  removeHistory() {
    this.history.removeHistory(this.delId)
    this.expandIndex = -1
    this.delId = ''
  }
}
