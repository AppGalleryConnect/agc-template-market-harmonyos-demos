import { CommonPageVM } from './CommonPageVM';

@ObservedV2
export class MainPageVM {
  private static _rootInstance: MainPageVM;

  public static get rootInstance(): MainPageVM {
    if (MainPageVM._rootInstance === undefined) {
      MainPageVM._rootInstance = new MainPageVM()
    }
    return MainPageVM._rootInstance;
  }

  // 文件类型索引
  @Trace fileTypeIndex: number = 0;
  // 文件分类数据
  private _fileTypeTitles: string[] = ['全部', '手机', '平板', '笔记本', '手表', '智能穿戴', '拍照摄像', '无人机'];

  public get fileTypeTitles(): string[] {
    return this._fileTypeTitles;
  }

  // 使用公用VM
  @Trace commonVMs: CommonPageVM[] = [];
  // 回收流程数组
  @Trace recycleProcessArr: RecycleProcessInfo[] = [
    new RecycleProcessInfo($r('app.media.icon_submit_order'), '提交订单', '选好商品，提交订单，预约上门取件', true),
    new RecycleProcessInfo($r('app.media.icon_transmit_order'), '邮寄寄出', '物流师傅上门取件，商品寄出', true),
    new RecycleProcessInfo($r('app.media.icon_quality'), '平台质检', '商品到达指定质检机构，进行质检', true),
    new RecycleProcessInfo($r('app.media.icon_signture'), '确认收款', '质检合格，确认收款/不合格或取消订单商品寄回',
      false),
  ]
  // 回收流程显示变量
  @Trace showRecycleProcess: boolean = false;
  // 资讯热线显示
  @Trace showHotline: boolean = false;
}

/**
 * 筛选元素类
 */
@ObservedV2
export class FilterItem {
  // 筛选项名称
  @Trace name: string = ''
  // 筛选项是否被选中
  @Trace index: number = 0
  // 筛选项选中的图标
  @Trace selectedIcon: ResourceStr = ''
  // 筛选项未选中的图标
  @Trace unselectedIcon: ResourceStr = ''
  // 已有筛选项的图标
  @Trace existSelectedIcon: ResourceStr = ''
  // 筛选项选中的文本颜色
  @Trace selectedTextColor: string = 'rgba(255, 75, 75, 1)'
  // 筛选项未选中的文本颜色
  @Trace unselectedTextColor: string = 'rgba(0, 0, 0, 0.6)'
  // 筛选项目数组
  @Trace selectArr: string[] = []

  constructor(name: string, index: number, selectedIcon: ResourceStr, unselectedIcon: ResourceStr,
    existSelectedIcon: ResourceStr,
    selectArr: string[]) {
    this.name = name
    this.index = index
    this.selectedIcon = selectedIcon
    this.unselectedIcon = unselectedIcon
    this.existSelectedIcon = existSelectedIcon
    this.selectArr = selectArr
  }
}

/**
 * 品牌元素类
 */
export interface BrandViewProps {
  // 品牌图标
  icon: ResourceStr,

  // 品牌名称
  name: string,
}

/**
 * 商品元素类
 */
export interface ProductInfo {
  // 产品名称
  name: string;

  // 产品标签
  labels: string;

  // 产品图片
  image: ResourceStr;

  // 产品价格
  price: number;

  // 产品价格描述
  priceDes: string;

  // 产品评价描述
  evaluateDes: string;

  // 产品崭新度描述
  newDes: string;

  // 产品满减描述
  discountDes: string;

  // 商品图片集合
  imagesList: ResourceStr[];
}

/**
 * 回收流程类
 */
@ObservedV2
export class RecycleProcessInfo {
  // 流程图标
  @Trace icon: ResourceStr = ''
  // 流程名称
  @Trace name: string = ''
  // 流程描述
  @Trace des: string = ''
  // 是否有下一步
  @Trace hasNext: boolean = true

  constructor(icon: ResourceStr, name: string, des: string, hasNext: boolean) {
    this.icon = icon
    this.name = name
    this.des = des
    this.hasNext = hasNext
  }
}