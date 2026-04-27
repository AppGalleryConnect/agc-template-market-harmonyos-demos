import { RemoteApi } from '../http/Api';
import { BrandGroupItem } from '../model/Index';

@ObservedV2
export class BrandPageVM {
  @Trace brandList: BrandGroupItem[] = [];
  @Trace alphabetArr: string[] = ['A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z'];
  @Trace selectIndex: number = 0;
  @Trace groupIndex: number = 0;
  @Trace keyWord: string = '';
  @Trace totalBrand:number = 0
  private static _instance: BrandPageVM;

  public static get instance() {
    if (!BrandPageVM._instance) {
      BrandPageVM._instance = new BrandPageVM();
    }
    return BrandPageVM._instance;
  }

  public async getBrandList() {
    this.totalBrand = 0
    this.brandList = await RemoteApi.getBrandList();
    this.brandList.forEach((item)=>{
      this.totalBrand = this.totalBrand + item.group.length
    })
  }

  // 搜索逻辑
  public async search() {
    const res: BrandGroupItem[] = await RemoteApi.getBrandList();
    this.totalBrand = 0
    this.brandList = res.map((item) => {
      item.group =
        item.group.filter((val) => val.name.includes(this.keyWord) || val.translation.includes(this.keyWord));
      this.totalBrand = this.totalBrand + item.group.length
      return item;
    });

  }
}