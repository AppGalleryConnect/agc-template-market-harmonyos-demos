import { ValuationStore, ValuationStoreAPI } from 'common';

@ObservedV2
export class MyBankCardPageVM {
  private static _instance: MyBankCardPageVM;

  public static get instance() {
    if (!MyBankCardPageVM._instance) {
      MyBankCardPageVM._instance = new MyBankCardPageVM();
    }
    return MyBankCardPageVM._instance;
  }
  // 银行卡数组
  @Trace bankCardTool: ValuationStore = ValuationStoreAPI.get()

  // 解绑银行卡对话框id
  @Trace closeUnbindId: number = -1
}