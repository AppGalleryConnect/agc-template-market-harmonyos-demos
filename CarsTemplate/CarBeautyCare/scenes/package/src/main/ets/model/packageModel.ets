export class PackageCardModel {
  coverImg: Resource;
  packageContent: string;
  buyTimes: number;
  introduction: string;
  markedPrice: string;
  discountedPrice: string;
  shopId: string;

  constructor(coverImg:Resource,packageContent:string,buyTimes:number,
    introduction:string,markedPrice:string,discountedPrice:string, shopId:string) {
    this.coverImg = coverImg;
    this.packageContent = packageContent;
    this.buyTimes = buyTimes;
    this.introduction = introduction;
    this.markedPrice = markedPrice;
    this.discountedPrice = discountedPrice;
    this.shopId = shopId
  }
}

export const PACKAGE_DATA:PackageCardModel[] = [
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油1',
    10,
    '会员暖冬专享',
    '1000',
    '100',
    '0001'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油2',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0002'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油3',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0003'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油4',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0004'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油5',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0005'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油6',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0006'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油7',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0007'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油8',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0008'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油9',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0009'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油10',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0010'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油11',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0011'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油12',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0012'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油13',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0001'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油14',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0002'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油15',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0003'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油16',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0004'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油17',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0005'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油18',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0006'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油19',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0007'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油20',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0008'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油21',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0009'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油22',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0010'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油23',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0011'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油24',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0012'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油25',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0001'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油26',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0002'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油27',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0003'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油28',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0004'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油29',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0005'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油30',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0006'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油31',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0007'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油32',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0008'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油33',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0009'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油34',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0010'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油35',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0011'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油36',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0012'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油37',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0001'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油38',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0002'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油39',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0003'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油40',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0004'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油41',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0005'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油42',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0006'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油43',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0007'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油44',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0008'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油45',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0009'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油46',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0010'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油47',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0011'
  ),
  new PackageCardModel(
    $r('app.media.package'),
    '(会员日)前挡风玻璃去油48',
    1000,
    '会员暖冬专享',
    '1000',
    '100',
    '0012'
  ),
]