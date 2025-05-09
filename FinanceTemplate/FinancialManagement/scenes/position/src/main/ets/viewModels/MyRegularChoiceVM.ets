import { https } from 'network';
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp';

const TAG = '[MyRegularChoiceVM]';

@ObservedV2
export class MyRegularChoiceVM {
  private static _instance: MyRegularChoiceVM;
  @Trace public myRegularChoiceList: IProductItem[] = []

  public static get instance() {
    if (!MyRegularChoiceVM._instance) {
      MyRegularChoiceVM._instance = new MyRegularChoiceVM();
    }
    return MyRegularChoiceVM._instance;
  }

  init() {
    this.getMyRegularChoiceList(1)
  }

  public async getMyRegularChoiceList(userId: number) {
    const res = await https.getMyRegularChoiceList(userId);
    if (res.code === 0) {
      this.myRegularChoiceList = res.data;
    }
  }
}
