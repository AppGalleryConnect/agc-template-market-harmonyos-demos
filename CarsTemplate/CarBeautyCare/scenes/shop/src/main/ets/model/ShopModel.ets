// 店铺信息属性

@ObservedV2
export class ShopCardModel {
  coverImg: Resource;      //店铺图片
  name: string;            //店铺名称
  serviceTimes: number;   //店铺订单数量
  address: string;         //店铺地址
  phone: string;          //店铺号码
  location: number[];     //店铺经纬度
  mark: string[];        //店铺标签
  id: string;            //店铺唯一id号码
  @Trace distance: string = '0';      //店铺与当前位置的距离

  constructor(coverImg:Resource,name:string,serviceTimes:number,
    address:string,phone:string,location:number[],mark:string[], id:string) {
    this.coverImg = coverImg;
    this.name = name;
    this.serviceTimes = serviceTimes;
    this.address = address;
    this.phone = phone;
    this.location = location;
    this.mark = mark;
    this.id = id;
  }
}

// 按城市维度把店铺放到一个数组
export class ShopModel {
  city: string;
  shops: ShopCardModel [];

  constructor(city: string, shops: ShopCardModel[]) {
    this.city = city;
    this.shops = shops;
  }
}

export const SHOP_NANJING: ShopCardModel[] = [
  new ShopCardModel($r('app.media.banner1'),
    '养车南京1号店',
    1000,
    '南京市软件大道001号',
    '18000000000',
    [32.04163,118.7672],
    ['美容','维修','保养','钣金','改装','轮胎'],
    '0001',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '养车南京2号店',
    1000,
    '南京市软件大道002号',
    '18000000000',
    [32.0412,118.7673],
    ['美容','维修','保养','钣金','改装','车品','轮胎'],
    '0002',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '养车南京3号店',
    1000,
    '南京市软件大道003号',
    '18000000000',
    [32.041574,118.767499],
    ['美容','维修','保养','改装','车品','轮胎'],
    '0003',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '养车南京4号店',
    1000,
    '南京市软件大道004号',
    '18000000000',
    [32.041522,118.767456],
    ['美容','维修','保养','钣金','车品','轮胎'],
    '0004',
  ),
]

export const SHOP_BEIJING: ShopCardModel[] = [
  new ShopCardModel($r('app.media.banner1'),
    '养车北京1号店',
    1000,
    '北京市大栅栏001号',
    '18000000000',
    [39.44,116.2377],
    ['美容','保养','钣金','改装','车品','轮胎'],
    '0005',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '养车北京2号店',
    1000,
    '北京市大栅栏002号',
    '18000000000',
    [39.57,116.2388],
    ['美容','维修','保养','改装','车品','轮胎'],
    '0006',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '养车北京3号店',
    1000,
    '北京市大栅栏003号',
    '18000000000',
    [39.57,116.2329],
    ['美容','维修','保养','钣金','改装','轮胎'],
    '0007',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '养车北京4号店',
    1000,
    '北京市大栅栏004号',
    '18000000000',
    [39.44,116.2328],
    ['美容','保养','钣金','改装','车品','轮胎'],
    '0008',
  ),
]

// 南京市所有店铺集合
export  const SHOP_DEFAULT: ShopCardModel[] = [
  new ShopCardModel($r('app.media.banner1'),
    '南京养车通用1店',
    1000,
    '南京市软件大道通用街001号',
    '18000000000',
    [32.04156,118.7679],
    ['美容','维修','保养','钣金','改装','车品','轮胎'],
    '0009',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '南京养车通用2店',
    1000,
    '南京市软件大道通用街002号',
    '18000000000',
    [32.041542,118.76745],
    ['美容','维修','保养','钣金','改装','车品','轮胎'],
    '0010',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '南京养车通用3店',
    1000,
    '南京市软件大道通用街003号',
    '18000000000',
    [32.041,118.767],
    ['美容','维修','保养','钣金','改装','车品','轮胎'],
    '0011',
  ),
  new ShopCardModel($r('app.media.banner1'),
    '南京养车通用4店',
    1000,
    '南京市软件大道通用街004号',
    '18000000000',
    [32.0415,118.7674],
    ['美容','维修','保养','钣金','改装','车品','轮胎'],
    '0012',
  ),
]

export const SHOP_DATA: ShopModel[] = [
  new ShopModel('南京', SHOP_NANJING),
  new ShopModel('北京', SHOP_BEIJING),
  new ShopModel('上海', SHOP_DEFAULT),
]