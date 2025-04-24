import {
  Constants,
  DishesType,
  getDishesListUtil,
  GetMyCarResp,
  GetTableInfoResp,
  getTableInfoUtil,
  StoreType,
  TabBarType,
  TableTitle,
} from 'common/Index';
import { TitleComp } from '../components/TitleComp';
import { ContainerComp } from '../components/ContainerComp';
import { MyCarListComp } from '../components/MyCarListComp';
import { MyCarComp } from '../components/MyCarComp';
import { MustGoodsController } from '../models/MustGoodsController';
import { ShopDiscountComp } from '../components/ShopDiscountComp';
import { CustomSelectSheetBuilder } from '../components/CustomSelectDialog';


@Component
export struct OrderPage {
  @StorageProp('myCar') myCar: GetMyCarResp = new GetMyCarResp()
  @StorageProp('tableList') tableList: Array<TableTitle> = [];
  @StorageLink('tableId') tableId: string = '';
  @StorageLink('dinerNum') dinerNum: ResourceStr = '';
  @StorageProp('storeType') storeType: number = 1;
  @StorageLink('isRest') isRest: boolean = false;
  // 原始商品列表
  @Provide('dishesListOri') dishesListOri: Array<DishesType> = []
  // 展示的商品列表
  @Provide('dishesList') dishesList: Array<DishesType> = []
  @Consume('currentIndex') @Watch('currentIndexChange') currentIndex: number
  @Consume('tableInfo') tableInfo?: GetTableInfoResp
  @Consume('showShopDiscount') showShopDiscount: boolean
  @Consume('mustGoodsCtrl') mustGoodsCtrl: MustGoodsController
  @State showCarList: boolean = false
  @State tableSheetShow: boolean = false;
  @State dinerSheetShow: boolean = false;

  aboutToAppear() {
    getDishesListUtil().then(res => {
      this.dishesList = res
      this.dishesListOri = JSON.parse(JSON.stringify(res))
      this.dishesList.forEach(item => {
        item.good.forEach(i => {
          if (i.isMust === Constants.GOODS_MUST) {
            this.mustGoodsCtrl.changeShopIsMustGoods()
          }
        })

      })
    })
    this.chooseRefresh()
  }

  chooseRefresh() {
    if (!this.isRest) {
      if (this.storeType === StoreType.SCAN_TYPE && !this.tableId) {
        this.tableInfo = undefined
        this.tableSheetShow = true
      } else if (!this.dinerNum) {
        this.dinerSheetShow = true
      }
    }
  }

  currentIndexChange() {
    if (this.currentIndex === TabBarType.HOMEPAGE) {
      this.chooseRefresh()
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          TitleComp()
          ContainerComp().layoutWeight(1)
        }
        .height(Constants.FULL_SIZE)
        .width(Constants.FULL_SIZE)
        .bindSheet($$this.tableSheetShow,
          CustomSelectSheetBuilder($r('app.string.pick_table'), this.tableList.map((item) => {
            return item.name ?? '';
          }), (select: ResourceStr) => {
            this.confirmTable(select);
          }), {
            height: 408,
            blurStyle: BlurStyle.Thick,
            showClose: false,
          });

        MyCarListComp({
          close: () => {
            this.showCarList = false
          },
        }).visibility(this.showCarList ? Visibility.Visible : Visibility.Hidden)
        // 购物车
        MyCarComp({ showCarList: this.showCarList })
          .visibility(this.myCar.res?.length ? Visibility.Visible : Visibility.Hidden)
        // 优惠活动
        ShopDiscountComp().visibility(this.showShopDiscount ? Visibility.Visible : Visibility.Hidden)

      }.alignContent(Alignment.Bottom)
      .bindSheet($$this.dinerSheetShow,
        CustomSelectSheetBuilder($r('app.string.pick_dinner_num'), $r('app.strarray.diner_num'),
          (select: ResourceStr) => {
            this.confirmDiner(select);
          }), {
          height: 408,
          blurStyle: BlurStyle.Thick,
          showClose: false,
        });
    }
    .hideTitleBar(true)
  }

  confirmTable(select: ResourceStr) {
    if (select) {
      let table = this.tableList.find(item => item.name === select)
      this.tableId = table?.id ?? '';
      getTableInfoUtil(this.tableId).then((res) => {
        this.tableInfo = res;
      });
    }
    this.tableSheetShow = false
    if (!this.dinerNum) {
      this.dinerSheetShow = true
    }
  }

  confirmDiner(select: ResourceStr) {
    if (select) {
      this.dinerNum = select;
    } else {
      this.dinerNum = this.dinerNum || $r('app.string.diner_num_default');
    }
    this.dinerSheetShow = false
  }
}
