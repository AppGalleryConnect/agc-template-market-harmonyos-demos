import { ProductInfoManager } from '../utils/ProductInfoManager';
import { CommonPageVM } from './CommonPageVM';

@ObservedV2
export class SearchProductPageVM {
  private static _instance: SearchProductPageVM;

  public static get instance() {
    if (!SearchProductPageVM._instance) {
      SearchProductPageVM._instance = new SearchProductPageVM();
    }
    return SearchProductPageVM._instance;
  }

  @Trace searchCondition: string = '';
  @Trace searchResult: ProductInfoManager = new ProductInfoManager('', []);
  @Trace isShowResult: boolean = false;
  // 热门搜索
  @Trace hotSearch: Array<string> = ['手机', '华为手机', '苹果手机', '笔记本', '相机', '手表', '平板', '无人机'];
  // 搜索历史
  @Trace historySearch: Array<string> = [];

  updateHistorySearch(content: string){
    let index: number = this.historySearch.indexOf(content);
    if (index === -1) {
      this.historySearch.unshift(content);
      return;
    }
    this.historySearch.splice(index, 1);
    this.historySearch.unshift(content);
    return;
  }

  // 使用公用VM
  @Trace commonVM: CommonPageVM = new CommonPageVM();

  // 可关闭的删除弹窗id
  deleteDialogId: number = -1;

  // 手机数码
  phoneSelectDevices: Array<PhoneMediaType> = [
    new PhoneMediaType('手机热销榜', $r('app.media.image_demo_phone2')),
    new PhoneMediaType('平板热销榜', $r('app.media.image_demo_phone3')),
    new PhoneMediaType('笔记本热榜', $r('app.media.image_demo_phone2')),
    new PhoneMediaType('耳机热销榜', $r('app.media.image_demo_phone3')),
    new PhoneMediaType('手机保护套', $r('app.media.image_demo_phone2')),
  ]

  // 摄影摄像
  photoSelectDevices: Array<PhoneMediaType> = [
    new PhoneMediaType('相机热销榜', $r('app.media.img_demo_cameraA')),
    new PhoneMediaType('无人机热榜', $r('app.media.img_demo_cameraB')),
    new PhoneMediaType('运动相机热榜', $r('app.media.img_demo_cameraA')),
    new PhoneMediaType('镜头热销榜', $r('app.media.img_demo_cameraB')),
    new PhoneMediaType('镜头保护套', $r('app.media.img_demo_cameraA')),
  ]

  // 腕表
  watchSelectDevices: Array<PhoneMediaType> = [
    new PhoneMediaType('劳力士手表', $r('app.media.img_demo_watchA')),
    new PhoneMediaType('浪琴手表', $r('app.media.img_demo_watchB')),
    new PhoneMediaType('法拉利手表', $r('app.media.img_demo_watchA')),
  ]
  // 文件类型索引
  @Trace fileTypeIndex: number = 0;
  // 文件分类数据
  private _fileTypeTitles: string[] = ['全部', '手机', '平板', '笔记本', '手表', '智能穿戴', '拍照摄像', '无人机'];

  public get fileTypeTitles(): string[] {
    return this._fileTypeTitles;
  }
}

/**
 * 搜索页手机数码类
 */
export class PhoneMediaType {
  // 手机名称
  name: string = '';
  // 手机图片
  image: ResourceStr = '';

  constructor(name: string, image: ResourceStr) {
    this.name = name;
    this.image = image;
  }
}