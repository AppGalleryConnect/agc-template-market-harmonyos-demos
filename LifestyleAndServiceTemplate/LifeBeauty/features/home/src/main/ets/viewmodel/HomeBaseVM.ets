import { getStoreList, IBaseStore } from 'utils';
import { StoreDataSource } from '../common/StoreDataSource';

@ObservedV2
export class HomeBaseVM {
  dataSource: StoreDataSource = new StoreDataSource();
  storeList: IBaseStore[] = [];
  private static _instance: HomeBaseVM;

  static get instance() {
    if (HomeBaseVM._instance) {
      return HomeBaseVM._instance;
    }
    HomeBaseVM._instance = new HomeBaseVM();
    return HomeBaseVM._instance;
  }

  async init() {
    await this.getStoreList();
  }

  getStoreList() {
    return getStoreList().then((resp: IBaseStore[]) => {
      this.storeList = resp;
      this.dataSource.batchPushData(this.storeList);
    });
  }
}