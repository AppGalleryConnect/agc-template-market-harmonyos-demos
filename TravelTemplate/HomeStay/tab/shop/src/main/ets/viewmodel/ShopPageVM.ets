import { CarouselImagesResp, CommodityCarouselImagesResp, CommodityResp, https } from 'network';
import { mapCommodityInfoResponse } from '../mapper/CommodityInfoMapper';
import { CarouselImage, Commodity } from 'type';
import { LazyDataSource } from 'util';

@ObservedV2
export class ShopPageVM {
  @Trace commodityList: Commodity[] = [];
  @Trace carouselImageList: CarouselImage[] = [];
  @Trace list: LazyDataSource<Commodity> = new LazyDataSource();
  @Trace imageList: LazyDataSource<CarouselImage> = new LazyDataSource();
  private static _instance: ShopPageVM;

  private constructor() {
    this.getCommodityList();
    this.getCarouselImages();
  }

  async getCarouselImages() {
    const res: CommodityCarouselImagesResp = await https.getCommodityCarouselImages() as CommodityCarouselImagesResp;

    if (res.code === 200) {
      let carouselImageList: CarouselImagesResp[] = res.data.filter((item: CarouselImagesResp) => item.type === 'SHOP');
      carouselImageList.forEach((item: CarouselImagesResp) => {
        const carouselImageItem: CarouselImage = {
          id: item.id,
          image: item.image,
        };
        this.carouselImageList.push(carouselImageItem);
      });
      this.imageList.pushArrayData(this.carouselImageList);
    }
  }

  async getCommodityList() {
    const res: CommodityResp = await https.getCommodityList() as CommodityResp;

    if (res.code === 200) {
      this.commodityList = mapCommodityInfoResponse(res);
      this.list.pushArrayData(this.commodityList);
    }
  }

  public static get instance() {
    if (!ShopPageVM._instance) {
      ShopPageVM._instance = new ShopPageVM();
    }
    return ShopPageVM._instance;
  }
}
