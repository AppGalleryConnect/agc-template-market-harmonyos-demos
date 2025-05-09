import { CommonConstants } from 'commonlib'
import { CommonHeader } from 'componentlib'

@ComponentV2
struct HomePage {
  build() {
    Column() {
      CommonHeader({ title: '首页' }).margin({ left: 16 })
      Scroll() {
        Column() {
          Image($r('app.media.ic_home_banner'))
            .width('100%')
            .height(170)
            .borderRadius($r('app.string.border_radius_16'))
          Text('为你推荐').titleStyle()
          this.goodShowBuilder()
          Text('新品上市').titleStyle()
          this.goodShowBuilder()
          Text('时尚秋装').titleStyle()
          this.goodShowBuilder()
        }.padding({ top: $r('app.string.padding_12') })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width(CommonConstants.FULL_WIDTH)
      .backgroundColor($r('app.color.sys_background_gary'))
      .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
    }
  }

  @Builder
  goodShowBuilder() {
    Row({ space: 10 }) {
      this.goodsItemBuilder($r('app.media.ic_goods_1'))
      this.goodsItemBuilder($r('app.media.ic_goods_2'))
    }
  }

  @Builder
  goodsItemBuilder(pic: ResourceStr) {
    Column() {
      Image(pic).width(CommonConstants.FULL_WIDTH).height(170)
      Column({ space: 8 }) {
        Text('秋季经典大气抗皱保暖舒适碎花连衣裙白色西装')
          .fontSize($r('app.string.font_size_12'))
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0, 0, 0, 0.9)')

        Text() {
          Span('¥').fontSize($r('app.string.font_size_12'))
          Span('25')
        }
        .fontColor($r('app.color.remind_orange'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .padding({ left: $r('app.string.padding_12'), right: $r('app.string.padding_14') })
    }
    .backgroundColor($r('app.color.sys_background_white'))
    .borderRadius($r('app.string.border_radius_8'))
    .clip(true)
    .layoutWeight(1)
    .height(246)
  }
}

@Extend(Text)
function titleStyle() {
  .fontSize($r('app.string.font_size_20'))
  .fontColor('rgba(0, 0, 0, 0.9)')
  .fontWeight(FontWeight.Medium)
  .width(CommonConstants.FULL_WIDTH)
  .margin({ top: $r('app.string.padding_16'), bottom: $r('app.string.padding_10') })
}

@Builder
export function HomePageBuilder() {
  HomePage()
}
