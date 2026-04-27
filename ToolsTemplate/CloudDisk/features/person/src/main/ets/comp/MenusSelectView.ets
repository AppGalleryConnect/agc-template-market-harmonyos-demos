import { Constants } from 'common'
import { MineItem } from '../viewmodel/MineModel'

@ComponentV2
export struct MenusSelectView {
  @Param menusArray: MineItem[] = []
  @Event blockClickItem: (item: MineItem) => void

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider'))
  }

  build() {
    Column() {
      Column() {
        ForEach(this.menusArray, (item: MineItem, index: number) => {
          RowItem({ title: item.titleName })
            .onClick(() => {
              if (this.blockClickItem) {
                this.blockClickItem(item)
              }
            })
          if (index < this.menusArray.length - 1) {
            this.line()
          }
        }, (item: MineItem, idx: number) => JSON.stringify(item) + idx)
      }
      .width(Constants.FULL_SIZE)
      .borderRadius($r('app.float.vp_16'))

    }
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_primary_contrary'))
    .width(Constants.FULL_SIZE)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16')
    })
  }
}

@ComponentV2
struct RowItem {
  @Param title: string = ''

  build() {
    Row() {
      Text(this.title)
        .font({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Medium
        })
        .fontColor($r('app.color.dark_color_FF000000'))
        .textAlign(TextAlign.Start)
      Blank()
      Image($r('app.media.iconRight'))
        .width($r('app.float.vp_20'))
        .height($r('app.float.vp_20'))
    }
    .width(Constants.FULL_SIZE)
    .height($r('app.float.vp_60'))
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}