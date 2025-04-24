import { Logger } from '@ohos_agcit/postpartum_care_center_utils';
import { StoreModel } from './StoreModel';

const TAG: string = '[StoreListClass]';

@ObservedV2
export class StoreListClass {

  @Trace needSortStore: boolean = true;

  @Trace storeList: StoreModel[] = [];

  @Monitor('storeList')
  onStoreListChange() {
    this.sortStoreList();
    Logger.info(TAG, 'store list sort finished');
  }

  private sortStoreList() {
    Logger.info(TAG, 'store list start sort');
    if (this.needSortStore && this.storeList.every(store => store.distance !== null)) {
      this.storeList.sort((a, b) => a.distance! - b.distance!);
      Logger.debug(TAG, 'request location sort');
    }
  }
}