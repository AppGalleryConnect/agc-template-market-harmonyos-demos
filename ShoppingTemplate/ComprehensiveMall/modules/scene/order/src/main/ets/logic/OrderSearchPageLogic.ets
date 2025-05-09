import { router } from '@common/router';

import util from '@ohos.util';

@ObservedV2
export class OrderSearchPageLogic {

  @Trace
  public placeholder: string = '输入商品名称/订单编号';

  @Trace
  public isShowCandidate: boolean = false;

  @Trace
  public candidateWords: string[] = [];

  @Trace
  public keyWord: string = '';

  @Trace
  public submit: string = '';

  public readonly SEARCH_ID: string = util.generateRandomUUID(false);

  public controller: SearchController = new SearchController();

  public onClickBack = (): void => {
    router.pop();
  }

  public onSubmit = (value: string): void => {
    const key: string = value === '' ? this.placeholder : value;
    if (key !== '输入商品名称/订单编号' && key !== '') {
      // router.pop(false);
      // router.pushPathByName('ProductSearchResultsPage', null, false);
    }
  }

  public onShown = (ctx: UIContext): void => {
    ctx.getFocusController().requestFocus(this.SEARCH_ID);
  }
}
