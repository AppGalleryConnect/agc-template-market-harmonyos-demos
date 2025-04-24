import { CallTelDialogBuilder, CommonUrl, Constants, HwMapModel, StoreInfo } from 'common/Index'
import { promptAction } from '@kit.ArkUI'

/*
 * 购买商品列表
 * */
@Component
export struct StoreInfoCard {
  @Consume('storeInfo') storeInfo: StoreInfo
  @Consume('pageStack') pageStack: NavPathStack
  @State tel: string = ''
  @State callTelSheet: boolean = false

  aboutToAppear(): void {
    this.tel = this.storeInfo?.tel ?? ''
  }

  build() {
    Row() {
      Row() {
        Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo.logo}`).width(40).height(40)
        Column() {
          Text(`${this.storeInfo.name}`)
            .fontSize(18)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${this.storeInfo.address}`)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(400)
            .margin({ top: 5 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 8 })
      }.layoutWeight(1)

      Text() {
        ImageSpan($r('app.media.phone_icon')).width(24).height(24).margin({ right: 12 }).onClick(() => {
          // 拨打商家电话
          this.callTelSheet = true
        })
        ImageSpan($r('app.media.position_icon')).width(24).height(24).onClick(() => {
          let coordinates = this.storeInfo?.coordinates?.split(',')
          if (coordinates?.length === 2) {
            let latitude: number = Number(coordinates[0])
            let longitude: number = Number(coordinates[1])
            this.pageStack.pushPath({
              name: 'HwMap',
              param: { latitude, longitude, storeInfo: this.storeInfo } as HwMapModel,
            })
          } else {
            promptAction.showToast({ message: $r('app.string.store_address_error') })
          }
        })
      }.margin({ left: 8 })
      .bindSheet($$this.callTelSheet, CallTelDialogBuilder(this.tel, () => {
        this.callTelSheet = false
      }), {
        height: 309,
        blurStyle: BlurStyle.Thick,
        showClose: false,
      });
    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
  }
}