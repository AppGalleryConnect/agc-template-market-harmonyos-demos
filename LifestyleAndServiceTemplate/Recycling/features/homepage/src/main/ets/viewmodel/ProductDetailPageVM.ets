@ObservedV2
export class ProductDetailPageVM {
  // 选中的轮播图索引
  @Trace selectedImageIndex: number = 0

  swiperController: SwiperController = new SwiperController();
  // 服务项
  serviceItems: Array<string> = ['退货包运费', '一年质保', '7天无理由', '极速退款', '送货上门']
}