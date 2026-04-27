import { ToastDialog } from '@hw-agconnect/ui-toast';
import { BaseViewModel, HttpApi, IGoods, RouterMap, RouterModule } from 'lib_foundation';

@ObservedV2
export class GoodsPageVM extends BaseViewModel {
  @Trace goodsList: IGoods[] = []
  @Trace selectedGoods: IGoods | undefined;
  @Trace curGoodsName: string = '';
  @Trace weight: number = 1;
  @Trace volume: number = 0;
  @Trace length: string = '';
  @Trace width: string = '';
  @Trace height: string = '';
  @Trace count: number = 1;
  @Trace showVolume: boolean = false;

  init() {
    // 处理参数
    const params = RouterModule.getNavParam({ url: RouterMap.GOODS_PAGE }) as IGoods;
    if (params) {
      this.curGoodsName = params.name;
      this.weight = params.weight;
      if (params.count) {
        this.count = params.count;
      }
      if (params.volume) {
        this.volume = params.volume;
        this.showVolume = true;
      }
    }
    this.getGoodsList();
  }

  async getGoodsList() {
    const resp = await HttpApi.queryGoodsList();
    if (resp.length) {
      this.goodsList = resp as IGoods[];

      const currentGoods = this.goodsList.find((item) => item.name === this.curGoodsName)
      this.selectedGoods = currentGoods;
    }
  }
  public calcVolume() {
    if (this.length && this.width && this.height) {
      const length = parseInt(this.length) / 100
      const width = parseInt(this.width) / 100
      const height = parseInt(this.height) / 100
      this.volume = parseFloat((length * width * height).toPrecision(12))
    } else {
      this.volume = 0
    }
  }

  public check(): boolean {
    if (!this.selectedGoods) {
      ToastDialog.showToast({ message: '请选择物品类型！' });
      return false
    }
    if (!this.weight || this.weight === 0) {
      ToastDialog.showToast({ message: '请选填写重量！' });
      return false
    }
    if (!this.count || this.count === 0) {
      ToastDialog.showToast({ message: '请选填写件数！' });
      return false
    }
    return true
  }

  public save() {
    if (!this.check()) {
      return
    }
    if (!this.selectedGoods) {
      return
    }
    const goodsData: IGoods = {
      id: this.selectedGoods.id,
      name: this.selectedGoods.name,
      weight: this.weight,
      volume: this.volume,
    }
    RouterModule.pop(goodsData);
  }
}
