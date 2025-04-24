import { OrderTypeComp } from '../components/OrderTypeComp'
import { PaymentDetailsComp } from '../components/PaymentDetailsComp'
import {
  CardManager,
  FormDataClass,
  GetMyOrderResp,
  GoodsComp,
  HttpRequestApi,
  NavHeaderBar,
  OrderDetailRouter,
  StoreInfo,
  StoreType,
} from 'common/Index'
import { BusinessError } from '@kit.BasicServicesKit'
import dataPreferences from '@ohos.data.preferences'
import { ReductionCard } from '../components/ReductionCardComp'
import { StoreInfoCard } from '../components/StoreInfoCardComp'
import { promptAction } from '@kit.ArkUI'


@Component
export struct OrderDetailPage {
  @StorageLink('storeType') storeType: number = 1
  @Consume('pageStack') pageStack: NavPathStack
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28
  @State orderId: string = ''
  @State isOrderJump: boolean = false
  scroller: Scroller = new Scroller();
  @State orderDetailInfo?: GetMyOrderResp = undefined

  getRouteParams() {
    let paramsArr: OrderDetailRouter[] = this.pageStack.getParamByName('OrderDetailPage') as OrderDetailRouter[]
    if (paramsArr.length) {
      this.orderId = paramsArr[paramsArr.length - 1].orderId
      this.isOrderJump = paramsArr[paramsArr.length - 1].isOrderJump
    }
  }

  async aboutToAppear() {
    this.getRouteParams()
    this.getOrderInfo()
  }

  getOrderInfo() {
    HttpRequestApi.getOrderInfo(this.orderId).then((resp: GetMyOrderResp) => {
      if (resp) {
        console.info(`getOrderInfo resp:${JSON.stringify(resp)}.`);
        this.orderDetailInfo = resp
        if (this.isOrderJump) {
          this.updateFormCard()
        }
      } else {
        console.error(`getOrderInfo error: ${JSON.stringify(resp)}.`);
        promptAction.showToast({ message: $r('app.string.order_not_exist') })
        this.pageStack.popToName('HomePage', 0)
      }
    }).catch((e: BusinessError) => {
      console.error(`getOrderInfo error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.order_not_exist') })
      this.pageStack.popToName('HomePage', 0)
    })
  }

  updateFormCard() {
    dataPreferences.removePreferencesFromCacheSync(getContext(this), { name: CardManager.KEY_CARD_ID })
    let pref = dataPreferences.getPreferencesSync(getContext(this), { name: CardManager.KEY_CARD_INFO })
    let dataClass = new FormDataClass()
    let storeInfo = AppStorage.get('storeInfo') as StoreInfo
    dataClass.storeName = storeInfo.name || ''
    dataClass.storeType = this.storeType.toString()
    dataClass.orderState = true
    dataClass.orderId = this.orderId
    dataClass.storeTable =
      this.storeType === StoreType.SCAN_TYPE ?
        `${this.orderDetailInfo?.table?.typeName} | ${this.orderDetailInfo?.table?.name}` : ''
    dataClass.orderPickNum =
      this.storeType === StoreType.PICK_NUM_TYPE ? `${this.orderDetailInfo?.order?.oid}` : ''
    pref.putSync(CardManager.KEY_CARD_INFO, dataClass)
    pref.flush()
    CardManager.get().updateCard(getContext(this), '', dataClass)
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.order_detail'), hasBackButton: true })
      Scroll(this.scroller) {
        Column({ space: 12 }) {
          OrderTypeComp({
            orderDetail: this.orderDetailInfo,
            tableInfo: this.orderDetailInfo?.table,
            getOrderInfo: () => {
              this.getOrderInfo()
            },
          })
          StoreInfoCard()
          GoodsComp({ goodList: this.orderDetailInfo?.good })
          ReductionCard({ orderInfo: this.orderDetailInfo?.order })
          PaymentDetailsComp({ orderDetail: this.orderDetailInfo }).margin({ top: 8 })
        }.margin({ left: 12, right: 12, top: 12 })
      }.layoutWeight(1).padding({ bottom: this.windowBottomHeight }).scrollBar(BarState.Off).align(Alignment.Top)
    }
    .hideTitleBar(true)
    .backgroundColor('#FFF1F3F5')
  }
}

