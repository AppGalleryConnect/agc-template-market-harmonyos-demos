import {
  BusinessTimeDialog,
  Constants,
  DishesType,
  HttpRequest,
  IndexPageRouter,
  MyCarModel,
  PermissionUtil,
  RouterMap,
  StoreInfoModel,
  TabBarType,
  Utils,
} from 'common/Index';
import { CouponComp } from '../components/CouponComp';
import { GoodsListComp } from '../components/GoodsListComp';
import { TitleComp } from '../components/TitleComp';
import { AppStorageV2 } from '@kit.ArkUI';
import { MyCarListComp } from '../components/MyCarListComp';
import { MyCarComp } from '../components/MyCarComp';

@Builder
export function OrderPageBuilder() {
  OrderPage()
}

@ComponentV2
struct OrderPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Consumer('currentIndex') currentIndex?: TabBarType
  // 原始商品列表
  @Provider('dishesListOri') dishesListOri: Array<DishesType> = [];
  // 展示的商品列表
  @Provider('dishesList') dishesList: Array<DishesType> = [];
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local showCarList: boolean = false;
  @Local isRest: boolean = false;
  businessHoursAM: string = ''
  businessHoursPM: string = ''
  businessController: CustomDialogController = new CustomDialogController({
    builder: BusinessTimeDialog({
      businessHoursAM: this.businessHoursAM,
      businessHoursPM: this.businessHoursPM,
    }),
    width: 296,
    height: 348,
  });

  aboutToAppear() {
    if (this.storeModel.storeId) {
      this.init()
    } else {
      this.pageStack?.pushPathByName(RouterMap.SELECT_STORE_PAGE, null, (popInfo: PopInfo) => {
        let result = popInfo.result as IndexPageRouter
        if (result.storeId) {
          this.storeModel.storeId = result.storeId;
          this.init()
        }
      })
    }
  }

  init() {
    this.getDishesList()
    this.getStoreInfo()
    HttpRequest.getMyCar()
  }

  @Monitor('currentIndex','storeModel.storeId')
  indexChange(monitor: IMonitor) {
    if (monitor.value('currentIndex')?.now === TabBarType.ORDER) {
      if (monitor.value('storeModel.storeId')?.now !== monitor.value('storeModel.storeId')?.before) {
        this.init()
      } else {
        if (this.storeModel.storeId) {
          this.isShowRest()
        } else {
          this.pageStack?.pushPathByName(RouterMap.SELECT_STORE_PAGE, null, (popInfo: PopInfo) => {
            let result = popInfo.result as IndexPageRouter
            if (result.storeId) {
              this.storeModel.storeId = result.storeId;
              this.init()
            }
          })
        }
      }
    }

  }

  changeCarPanel(value = false): void {
    this.showCarList = value
  }

  getStoreInfo() {
    HttpRequest.getStoreInfo().then(res => {
      this.storeModel.storeInfo = res;
      PermissionUtil.getLocation().then(location => {
        this.storeModel.storeInfo.distance = Utils.getDistanceWithLocation(location, res.coordinates);
        this.storeModel.storeInfo.distanceStr = Utils.getFmtDistWithLocation(location, res.coordinates);
      })
      this.isShowRest()
    });
  }

  getDishesList() {
    HttpRequest.getDishesList().then(res => {
      this.dishesList = res
      this.dishesListOri = JSON.parse(JSON.stringify(res))
    })
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          TitleComp()
          CouponComp()
          GoodsListComp().layoutWeight(1)
        }
        .height(Constants.FULL_SIZE)
        .width(Constants.FULL_SIZE);

        MyCarListComp({
          changeCarPanel: () => this.changeCarPanel(),
        }).visibility(this.showCarList ? Visibility.Visible : Visibility.Hidden)
        // 购物车
        MyCarComp({
          isRest: this.storeModel.storeInfo.isRest || this.isRest,
          showCarList: this.showCarList,
          changeCarPanel: (value: boolean) => this.changeCarPanel(value),
        }).visibility(this.myCarModel.myCar.carGoods?.length ? Visibility.Visible : Visibility.Hidden)

      }.alignContent(Alignment.Bottom);
    }
    .hideTitleBar(true);
  }

  isShowRest() {
    if (this.storeModel.storeInfo.isRest === Constants.STORE_REST ||
      new Date().getTime() < this.getTimeByHour(this.storeModel.storeInfo.time1) ||
      new Date().getTime() > this.getTimeByHour(this.storeModel.storeInfo.time2)) {
      this.businessHoursAM = `AM ${this.storeModel.storeInfo?.time1}-${Constants.MID_DAY_TIME}`
      this.businessHoursPM = `PM ${Constants.MID_DAY_TIME}-${this.storeModel.storeInfo?.time2}`
      if (!this.isRest) {
        this.businessController?.open();
      }
      this.isRest = true
    } else {
      this.isRest = false
    }
  }

  getTimeByHour(time: string = '') {
    let date = new Date(`${new Date().toLocaleDateString()} ${time}`)
    return date.getTime()
  }
}
