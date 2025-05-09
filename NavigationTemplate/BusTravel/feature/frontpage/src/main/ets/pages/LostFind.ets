import { RouteEntryVM } from 'common'
import { SearchInput } from 'common'
import { lostFindPiece } from '../mock/MockData';
import { LostFindSegmentInterface } from '../model/Interface';

@Builder
export function LostFindBuilder() {
  LostFind()
}

@Component
export struct LostFind {
  @State searchPlaceholder: string = '搜索公交线路、站点'
  vm: RouteEntryVM = RouteEntryVM.instance;

  build() {
    NavDestination() {
      Column() {

        this.lostFoundList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(false)
    .title('失物招领')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  lostFoundList() {
    List({ space: 15 }) {
      ForEach(lostFindPiece, (item: LostFindSegmentInterface) => {
        lostFindItem(item)
      },(item:LostFindSegmentInterface)=>item.id)
    }
    .alignListItem(ListItemAlign.Center)
    .margin({top:15})
  }
}

@Builder
export function lostFindItem(item: LostFindSegmentInterface) {
  Column() {
    Row() {
      Row() {
        Text($r('app.string.lost_find_transportItemNumber'))
          .fontSize(14)
          .fontColor('#D94838')
          .fontWeight(FontWeight.Medium)
        Text(item.id)
          .fontSize(14)
          .fontColor('#D94838')
          .fontWeight(FontWeight.Medium)
      }

      Row() {
        Text($r('app.string.lost_find_transportLossTime'))
          .fontSize(10)
          .fontColor($r('sys.color.mask_secondary'))
          .fontWeight(FontWeight.Regular)
        Text(item.time)
          .fontSize(10)
          .fontColor($r('sys.color.mask_secondary'))
          .fontWeight(FontWeight.Regular)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)

    Divider()
      .margin({ top: '12vp'})
      .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

    Row() {
      Text($r('app.string.lost_find_transportItemType'))
        .fontSize(12)
        .fontWeight(FontWeight.Regular)

      Text(item.type)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
    }
    .margin({top:12,bottom:8})

    Row() {
      Text($r('app.string.lost_find_transportRoute'))
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
      Text(item.line)
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
    }

    Divider()
      .margin({ top: '12vp' })
      .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

    Text($r('app.string.lost_find_transportItemDescription'))
      .fontSize(12)
      .fontWeight(FontWeight.Regular)
      .margin({ top: 9, bottom: 4 })
    Text(item.description)
      .fontSize(10)
      .fontWeight(FontWeight.Regular)
    Image(item.image)
      .height(80)
      .width(120)
      .margin({ top: 13 })
  }
  // .align(Alignment.Start)
  .alignItems(HorizontalAlign.Start)
  .width('90%')
  .padding(12)
  .borderRadius(16)
  .backgroundColor($r('sys.color.white'))
}