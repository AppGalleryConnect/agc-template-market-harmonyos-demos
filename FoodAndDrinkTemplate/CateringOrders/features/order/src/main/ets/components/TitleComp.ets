import { CommonUrl, Constants, GetTableInfoResp, StoreInfo, StoreType } from 'common/Index'

@Preview
@Component
export struct TitleComp {
  @StorageProp('storeType') storeType: number = 1
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('storeInfo') storeInfo: StoreInfo
  @Consume('tableInfo') tableInfo: GetTableInfoResp
  @State windowTopHeight: number = AppStorage.get('windowTopHeight') as number ?? 38.77

  build() {
    Column() {
      if (this.storeType === StoreType.SCAN_TYPE) {
        Row() {
          Image($r('app.media.order_list')).width(12).height(12).fillColor($r('sys.color.background_primary'))
          if (this.tableInfo?.tableName) {
            Row() {
              Text(`${this.tableInfo?.typeName}`).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.comp_background_list_card'))
              Text('|').margin({ left: 4, right: 4 }).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.comp_background_list_card'))
              Text(this.tableInfo?.tableName).fontSize($r('sys.float.Caption_M')).fontColor($r('sys.color.comp_background_list_card'))
            }.margin({ left: 4 }).height(20)
          }
        }
        .height(28)
        .justifyContent(FlexAlign.Start)
        .padding({
          left: 8,
          right: 8,
          top: 4,
          bottom: 4
        })
        .backgroundColor($r('sys.color.multi_color_09'))
        .borderRadius(20)
        .margin({ bottom: 12 })
      }
      Row() {
        Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.storeInfo.logo}`).width(40).height(40).borderRadius(20)
        Column() {
          Row() {
            Text(this.storeInfo.name)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(20)
            Image($r('app.media.right')).width(14).margin({ left: 2 })
          }

          Row() {
            Image($r('app.media.news')).width(12)
            Text(this.storeInfo.announcement)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(16)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 4 })
          }.layoutWeight(1)
        }
        .height(40)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ left: 8 })
        .layoutWeight(1)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.pageStack.pushPath({ name: 'MerchantDetailPage' })
      })
    }
    .padding({
      left: 12,
      right: 12,
      bottom: 12
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.End)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .height(142)
    .backgroundImage($r('app.media.background'))
    .backgroundImageSize(ImageSize.Cover)
  }
}