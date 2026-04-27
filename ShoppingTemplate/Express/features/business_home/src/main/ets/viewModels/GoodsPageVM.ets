import { getGoodsList, IGoods, RouterModule } from 'lib_foundation';
import { emitter } from '@kit.BasicServicesKit';
import { toastUtil } from 'module_base';

@ObservedV2
export class GoodsPageVM {
  private static _instance: GoodsPageVM;
  @Trace public goodsList: IGoods[] = []
  @Trace public selectedGoods: IGoods | undefined
  @Trace public weight: number = 1
  @Trace public volume: number = 0
  @Trace public length: string = ''
  @Trace public width: string = ''
  @Trace public height: string = ''
  @Trace public count: number = 1
  @Trace public showVolume: boolean = true

  public static get instance() {
    if (!GoodsPageVM._instance) {
      GoodsPageVM._instance = new GoodsPageVM();
    }
    return GoodsPageVM._instance;
  }

  public async init() {
    this.getGoodsList()
  }


  public async getGoodsList() {
    const res = await getGoodsList()
    this.goodsList = res
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
      toastUtil.showToast('请选择物品类型！');
      return false
    }
    if (!this.weight || this.weight === 0) {
      toastUtil.showToast('请选填写重量！');
      return false
    }
    if (!this.count || this.count === 0) {
      toastUtil.showToast('请选填写件数！');
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
    toastUtil.showToast('保存成功！');
    RouterModule.pop()
    let goods: emitter.EventData = {
      data: goodsData,
    };
    try {
      emitter.emit('goods', goods);
    } catch (e) {
      JSON.stringify(e)
    }
  }
}
