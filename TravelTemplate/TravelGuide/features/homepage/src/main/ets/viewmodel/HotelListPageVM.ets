import { HotelDateModel, HotelModel } from 'common_travel_guide'
import { HotelPageVM } from './HotelPageVM'

@ObservedV2
export class HotelListPageVM {
  @Trace mockHotelList: HotelModel[] = []
  @Trace hotelList: HotelModel[] = []
  //智能排序
  @Trace hotelListNum: number = 0
  @Trace searchList: HotelModel[] = []
  @Trace isShow: boolean = false
  intelligentTypes: string[] = ['智能排序', '低价优先', '高价优先', '高星优先'];
  locationTypes: string[] = ['热门', '商业区', '行政区', '热门景点', '机场车站', '地铁线路', '大学周边', '医院周边'];
  filterTypes: string[] = ['住宿类型', '品牌', '设施'];
  @Trace filterOptions: FilterItem[] = [
    new FilterItem('智能排序', 0, $r('app.media.ic_filter_up'), $r('app.media.ic_filter_down'), this.intelligentTypes),
    new FilterItem('位置距离', 1, $r('app.media.ic_filter_up'), $r('app.media.ic_filter_down'), this.locationTypes),
    new FilterItem('价格/星级', 2, $r('app.media.ic_filter_up'), $r('app.media.ic_filter_down'), this.filterTypes),
    new FilterItem('筛选', 3, $r('app.media.ic_filter_up'), $r('app.media.ic_filter_down'), this.filterTypes),
  ];
  @Trace selectName: string = ''
  @Trace isDrawOpen: boolean = false
  @Trace selectIntelligentIndex: number = 0
  @Trace searchContent: string = ''
  @Trace hotelPageVM: HotelPageVM = Object()
  @Trace hotelDate: HotelDateModel = Object()
  // 筛选数据
  @Trace selectedItems: Set<string> = new Set()
  // 价格星级筛选数据
  @Trace currentPriceIndex: number = -1
  @Trace currentStarIndex: number = -1
  @Trace priceMinString: string = ''
  @Trace priceMaxString: string = ''
  // 位置距离筛选数据
  @Trace currentIndex: number = 0
  @Trace currentSubIndex: number = -1
  //根据不同字段对列表数据进行排序
  sortHotelList(hotelList: HotelModel[], index: number) {
    this.selectIntelligentIndex = index
    this.filterOptions[0].name = this.intelligentTypes[index]
    if (index === 0) {
      this.hotelList = hotelList.sort((a, b) => a.reviewCount - b.reviewCount)
    } else if (index === 1) {
      this.hotelList = hotelList.sort((a, b) => a.price - b.price);
    } else if (index === 2) {
      this.hotelList = hotelList.sort((a, b) => b.price - a.price);
    } else {
      this.hotelList = hotelList.sort((a, b) => b.rating - a.rating);
    }
  }

  // 根据地理位置过滤列表数据
  addressSearchList(data: string) {
    let hotelList: HotelModel[] =
      this.mockHotelList.filter(item => item.address === data)
        .sort((a, b) => Number(a.distance.replace(/[^\d.]/g, '')) - Number(b.distance.replace(/[^\d.]/g, '')));
    return hotelList;
  }

  //根据价格和星级搜索列表数据
  starPriceSearchList(minPrice: string, maxPrice: string, star: string) {
    if (star && minPrice !== '') {
      this.hotelList = this.mockHotelList.filter(item => item.star === star)
      if (minPrice === '1000' && maxPrice === '') {
        this.hotelList = this.hotelList.filter(item => item.price >= Number(minPrice))
      } else {
        this.hotelList = this.hotelList.filter(item => item.price >= Number(minPrice) &&
          item.price <= Number(maxPrice))
      }
    }
    if (star && minPrice === '') {
      this.hotelList = this.mockHotelList.filter(item => item.star === star)
    }
    if (!star && minPrice !== '') {
      if (minPrice === '1000' && maxPrice === '') {
        this.hotelList = this.mockHotelList.filter(item => item.price >= Number(minPrice))
      } else {
        this.hotelList = this.mockHotelList.filter(item => item.price >= Number(minPrice) &&
          item.price <= Number(maxPrice))
      }
    }
  }

  //筛选弹框搜索列表
  dialogSearchList(data: Set<string>) {
    const searchOption: string[] = Array.from(data);

    // 解析各类筛选条件
    const accommodationList = searchOption
      .filter(item => item.startsWith('住宿'))
      .map(item => item.replace('住宿类型_', ''));

    const brandList = searchOption
      .filter(item => item.startsWith('品牌'))
      .map(item => item.replace('品牌_', ''));

    const facilityList = searchOption
      .filter(item => item.startsWith('设施'))
      .map(item => item.replace('设施_', ''));

    // 使用链式过滤，只有存在条件时才应用过滤
    this.hotelList = this.mockHotelList.filter(hotel => {
      // 住宿类型检查
      const accommodationMatch = accommodationList.length === 0 ||
        (hotel?.accommodationType && accommodationList.includes(hotel.accommodationType));

      // 品牌检查（模糊匹配）
      const brandMatch = brandList.length === 0 ||
      brandList.some(brand => hotel.name?.includes(brand));

      // 设施检查（需要包含所有选中的设施）
      const facilityMatch = facilityList.length === 0 ||
        (hotel.facility && facilityList.every(facility =>
        hotel.facility.includes(facility)
        ));

      return accommodationMatch && brandMatch && facilityMatch;
    });
  }
}

/**
 * 筛选元素类
 */
@ObservedV2
export class FilterItem {
  // 筛选项名称
  @Trace name: string = ''
  // 选中index
  @Trace index: number = 0
  // 筛选项选中的图标
  @Trace selectedIcon: ResourceStr = ''
  // 筛选项未选中的图标
  @Trace unselectedIcon: ResourceStr = ''
  // 筛选项选中的文本颜色
  @Trace selectedTextColor: string = 'rgba(255, 75, 75, 1)'
  // 筛选项未选中的文本颜色
  @Trace unselectedTextColor: string = 'rgba(0, 0, 0, 0.6)'
  // 筛选项目数组
  @Trace selectArr: string[] = []

  constructor(name: string, index: number, selectedIcon: ResourceStr, unselectedIcon: ResourceStr,
    selectArr: string[]) {
    this.name = name
    this.index = index
    this.selectedIcon = selectedIcon
    this.unselectedIcon = unselectedIcon
    this.selectArr = selectArr
  }
}
