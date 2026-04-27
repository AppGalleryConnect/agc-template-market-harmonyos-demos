import { RecipeCategory } from 'link_category';
import { BrandViewProps, FilterItem, ProductInfo } from './MainPageVM';
import { MockData } from '../data/MockData';

/**
 * 通用的页面VM，存放公用的页面变量
 */
@ObservedV2
export class CommonPageVM {
  // 显示上拉框
  @Trace showBottomWindow: boolean = false;
  // 显示下拉框
  @Trace showPopupWindow: boolean = false;
  // 上拉框或者下拉框样式：价格降序、价格、型号、筛选
  @Trace popupWindowStyle: string = '价格降序';
  // 价格降序选中的索引
  @Trace priceSortingSelected: string = '综合'
  // 价格选中的价格范围
  @Trace priceSelected: number[] = [0, 100000];
  // 手机选中的型号
  @Trace modelSelected: string = '不限型号';
  // 相机选中的型号
  @Trace cameraModelSelected: string = '不限型号'
  // 选中的筛选条件标题
  @Trace currentFilterIndex: number = 0
  // 选中的筛选条件
  @Trace filterSelected: Map<string, string> = new Map();
  // 筛选条件是否展开状态
  @Trace isExpanded: boolean = false
  // 是否需要固定列表和筛选条件
  @Trace isFixed: boolean = false
  // 手势滑动的x坐标值
  @Trace gestureX: number = 0
  // 手势滑动的y坐标值
  @Trace gestureY: number = 0
  // 滚动布局的高度
  @Trace scrollLayoutHeight: number = 0
  // 容器的实际高度
  @Trace containerHeight: number = 0
  // 固定筛选条件后的布局高度
  @Trace fixedLayoutHeight: number = 0
  // 固定筛选条件后的列表实际高度
  @Trace fixedListHeight: number = 0
  // 筛选条件列表
  filterList: Array<FilterItem> = [
    new FilterItem('价格降序', 0, $r('app.media.ic_up_icon'), $r('app.media.ic_down_icon'),
      $r('app.media.ic_down_selected_icon'),
      ['综合', '价格降序', '价格升序']),
    new FilterItem('价格', 1, $r('app.media.ic_up_icon'), $r('app.media.ic_down_icon'),
      $r('app.media.ic_down_selected_icon'),
      ['0-499', '500-999', '1000-1499', '1500-1999', '2000-2999', '3000以上']),
    new FilterItem('型号', 2, $r('app.media.ic_model_selected'), $r('app.media.ic_model_select'),
      $r('app.media.ic_model_selected'), []),
    new FilterItem('筛选', 3, $r('app.media.ic_selected_icon'), $r('app.media.ic_select_icon'),
      $r('app.media.ic_selected_icon'), [])
  ]
  // 品牌
  brandList: Array<BrandViewProps> = MockData.brandList
  // 商品
  productList: Array<ProductInfo> = MockData.homePageProductList
  // 筛选条件
  recipeCategoryList: RecipeCategory[] = MockData.recipeCategoryList

  // 全部筛选条件
  allFilter(productList: Array<ProductInfo>): Array<ProductInfo> {
    // 品牌型号
    if (this.filterSelected.has('品牌型号')) {
      const brandModel = this.filterSelected.get('品牌型号') as string
      productList = productList.filter(item => brandModel === '不限型号' || brandModel === '')
    }

    // 整体成色
    if (this.filterSelected.has('整体成色')) {
      const overModel = this.filterSelected.get('整体成色') as string
      productList = productList.filter(item => overModel.indexOf(item.newDes) >= 0 || overModel === '')
    }

    // 容量
    if (this.filterSelected.has('容量')) {
      const capacity = this.filterSelected.get('容量') as string
      productList = productList.filter(item => capacity.length > 0 || capacity === '')
    }

    // 保修时间
    if (this.filterSelected.has('保修时间')) {
      const warrantyTime = this.filterSelected.get('保修时间') as string
      productList = productList.filter(item => warrantyTime.length > 0 || warrantyTime === '')
    }

    // 版本
    if (this.filterSelected.has('版本')) {
      const version = this.filterSelected.get('版本') as string
      productList = productList.filter(item => version.length > 0 || version === '')
    }

    // 上市时间
    if (this.filterSelected.has('上市时间')) {
      const releaseTime = this.filterSelected.get('上市时间') as string
      productList = productList.filter(item => releaseTime.length > 0 || releaseTime === '')
    }

    // 精选机况
    if (this.filterSelected.has('精选机况')) {
      const condition = this.filterSelected.get('精选机况') as string
      productList = productList.filter(item => condition.length > 0 || condition === '')
    }

    // 电池健康度
    if (this.filterSelected.has('电池健康度')) {
      const batteryHealth = this.filterSelected.get('电池健康度') as string
      productList = productList.filter(item => batteryHealth.length > 0 || batteryHealth === '')
    }

    // 商品来源
    if (this.filterSelected.has('商品来源')) {
      const source = this.filterSelected.get('商品来源') as string
      productList = productList.filter(item => source.length > 0 || source === '')
    }

    return productList
  }

  // 获取手机筛选条件之后的列表
  getSelectProductList(): Array<ProductInfo> {
    let productList: Array<ProductInfo> = this.productList.filter((item) => true)
    // 排序
    if (this.priceSortingSelected === '价格降序') {
      productList = productList.sort((a, b) => b.price - a.price)
    } else if (this.priceSortingSelected === '价格升序') {
      productList = productList.sort((a, b) => a.price - b.price)
    }
    // 价格区间
    if (this.priceSelected[0] === 0 && this.priceSelected[1] === 0) {
      productList = productList.filter(item => true)
    } else if (this.priceSelected[0] === 0) {
      productList =
        productList.filter(item => item.price <= this.priceSelected[1])
    } else if (this.priceSelected[1] === 0) {
      productList =
        productList.filter(item => item.price >= this.priceSelected[0])
    } else {
      productList =
        productList.filter(item => item.price >= this.priceSelected[0] && item.price <= this.priceSelected[1])
    }
    // 手机型号
    if (this.modelSelected !== '不限型号') {
      productList =
        productList.filter(item => item.name.indexOf(this.modelSelected) >= 0)
    }
    if (this.cameraModelSelected.split('-')[0] !== '不限型号') {
      productList =
        productList.filter(item => item.name.indexOf(this.cameraModelSelected.split('-')[0]) >= 0)
    }
    // 手机筛选条件
    return this.allFilter(productList)
  }

  // 是否页面支持滚动
  @Computed
  get isScrollable(): boolean {
    if (this.isFixed) {
      return this.fixedLayoutHeight > this.fixedListHeight
    } else {
      return this.containerHeight > this.scrollLayoutHeight
    }

  }
}