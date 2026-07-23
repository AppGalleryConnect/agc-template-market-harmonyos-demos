import { BreakpointSystem } from 'lib_foundation';
import { SeckillProductInfo, SeckillSession, SeckillStatus, SeckillTimeSlot } from 'lib_network';
import { NavTitleBar, ProductListSkeleton } from 'lib_widget';
import { SeckillProductStyle, SeckillUtil } from '../utils/SeckillUtil';
import { SeckillListVM } from '../viewmodel/SeckillListVM'

@Builder
export function buildSeckillListPage() {
  SeckillListPage()
}

@ComponentV2
struct SeckillListPage {
  @Local
  isRefreshing: boolean = false
  vm: SeckillListVM = new SeckillListVM()
  private controller: TabsController = new TabsController();

  build() {
    NavDestination() {
      this.buildHeader()
      Refresh({ refreshing: $$this.isRefreshing }) {
        this.buildTabs()
      }
      .backgroundColor($r('app.color.background_color_grey'))
      .layoutWeight(1)
      .onRefreshing(async () => {
        await this.vm.initData()
        this.isRefreshing = false;
      })
      .expandSafeArea()
    }
    .hideTitleBar(true)
    .onHidden(() => {
      this.vm.countdown?.stopCountdownTimer()
    })
    .onShown(() => {
      this.vm.initData()
      this.vm.countdown?.startCountdownTimer()
    })
  }

  @Builder
  buildHeader() {
    NavTitleBar({ showBackBtn: true }) {
      Row() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontColor([$r('app.color.font_color_level2')])
          .margin({
            right: $r('app.float.space_l'),
          })
        Text('搜索秒杀商品')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
      }
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)
      .layoutWeight(1)
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
      .margin({ right: $r('app.float.space_s') })
      .id('search')
      .onClick(() => {
        this.vm.jumpToSearch()
      })
    }
  }

  @Builder
  buildTabs() {
    Tabs({
      barPosition: BarPosition.Start,
      index: this.vm.curIndex,
      controller: this.controller,
    }) {
      ForEach(this.vm.seckillTimeSlotList, (item: SeckillSession, index: number) => {
        TabContent() {
          this.buildProductList(item.productList, item.timeSlot)
        }
        .align(Alignment.Top)
        .padding($r('app.float.space_l'))
        .tabBar(this.buildSeckillTabBar(item, index))
        .backgroundColor($r('app.color.background_color_grey'))
        .expandSafeArea()
        .clip(false)
      }, (item: SeckillSession, index: number) => index + '__' + item.timeSlot.slotId);
    }
    .scrollable(true)
    .layoutWeight(1)
    .animationDuration(0)
    .divider({ strokeWidth: 0.5, color: $r('app.color.background_color_grey') })
    .barMode(BarMode.Fixed)
    .barBackgroundColor($r('app.color.background_color_primary'))
    .barWidth('100%')
    .expandSafeArea()
    .onChange((index: number) => {
      this.vm.curIndex = index;
    })
  }

  @Builder
  buildSeckillTabBar(item: SeckillSession, index: number) {
    Column() {
      if (item.timeSlot.status === SeckillStatus.ONGOING && this.vm.countdown) {
        if (this.vm.countdown.countdownLabelArr.length === 3) {
          Row() {
            ForEach(this.vm.countdown.countdownLabelArr, (str: string, idx: number) => {
              Text(str)
                .backgroundColor(this.vm.curIndex === index ? $r('app.color.theme_color') :
                  $r('app.color.font_color_level2'))
                .padding(2)
                .fontSize($r('app.float.font_size_12'))
                .borderRadius($r('app.float.border_radius_xs'))
                .fontColor($r('app.color.font_color_level1_invert'))
              if (idx !== 2) {
                Text(':')
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor(this.vm.curIndex === index ? $r('app.color.theme_color') :
                    $r('app.color.font_color_level2'))
                  .margin({ left: 2, right: 2 })
              }
            }, (str: string, index: number) => index + str)
          }
        }

      } else {
        Text(item.timeSlot.startTime)
          .fontSize($r('app.float.font_size_12'))
          .fontColor(this.vm.curIndex === index ? $r('app.color.theme_color') : $r('app.color.font_color_level2'))
      }
      Text(this.vm.getSeckillTabLabel(item.timeSlot))
        .fontColor(this.vm.curIndex === index ? $r('app.color.theme_color') : $r('app.color.font_color_level2'))
        .fontSize($r('app.float.font_size_14'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: $r('app.float.space_s') })
    }
    .width($r('app.string.size_percent_full'))
  }

  @Builder
  buildProductList(list: SeckillProductInfo[], timeslot: SeckillTimeSlot) {
    if (this.vm.isLoading) {
      ProductListSkeleton()
    } else {
      List({ space: 12 }) {
        Repeat<SeckillProductInfo>(list)
          .each((ri: RepeatItem<SeckillProductInfo>) => {
            ListItem() {
              this.buildSeckillListCard(
                ri.item,
                timeslot,
                SeckillUtil.getSeckillProductStyle(ri.item, timeslot.status),
              )
            }
          })
      }
      .lanes(BreakpointSystem.isTablet ? 2 : 1, 12)
      .layoutWeight(1)
      .expandSafeArea()
      .scrollBar(BarState.Off)
      .align(Alignment.Start)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
  }

  /** 秒杀商品卡片 */
  @Builder
  buildSeckillListCard(product: SeckillProductInfo, timeslot: SeckillTimeSlot, style: SeckillProductStyle) {
    Row({ space: 8 }) {
      Stack() {
        Image(product.banner)
          .width(100)
          .height(100)
          .backgroundColor($r('app.color.background_color_theme'))
          .borderRadius($r('app.float.border_radius_s'))
        if (timeslot.status === SeckillStatus.ONGOING && product.remainStock === 0) {
          Row() {
            Text('已抢光')
              .fontSize($r('app.float.font_size_14'))
              .fontColor($r('app.color.font_color_level1_invert'))
          }
          .width(60)
          .height(60)
          .borderRadius(30)
          .backgroundColor('#80000000')
          .justifyContent(FlexAlign.Center)
        }
      }

      Column({ space: 8 }) {
        Row({ space: 4 }) {
          Text('限时秒杀')
            .fontSize($r('app.float.font_size_10'))
            .fontColor($r('app.color.font_color_level1_invert'))
            .backgroundColor($r('app.color.theme_color'))
            .padding(2)
            .borderRadius(2)
          Text(product.title)
            .layoutWeight(1)
            .maxLines(1)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }

        if (timeslot.status === SeckillStatus.ONGOING) {
          Row({ space: 8 }) {
            Progress({
              value: product.totalStock - product.remainStock,
              total: product.totalStock,
            })
              .layoutWeight(1)
              .contentModifier(new MyProgressModifier(product, style))
            Text(SeckillUtil.getSoldLabel(product))
              .fontSize($r('app.float.font_size_10'))
              .fontColor(style.soldLabelFontColor)
          }
        } else if (timeslot.status === SeckillStatus.WAITING) {
          Text() {
            Span(`限量${product.totalStock}件`)
            Span(' ')
            Span(' | ')
            Span(' ')
            Span(timeslot.startTime + '开抢')
          }
          .fontSize($r('app.float.font_size_10'))
          .fontColor(style.soldLabelFontColor)
        }

        Blank()
        Row({ space: 4 }) {
          Column() {
            Text('优惠前 \n ' + '¥' + product.dashPrice.toString())
              .fontSize($r('app.float.font_size_10'))
              .fontColor(style.originalPriceFontColor)
              .lineHeight(14)
          }.labelContainerStyle(style.originalPriceBgColor)

          Column() {
            Text() {
              Span('¥')
              Span(product.seckillPrice.toString())
                .fontSize($r('app.float.font_size_16'))
                .fontWeight(FontWeight.Bold)
              Span(' ')
              Span('秒杀价')
            }
            .fontColor(style.seckillPriceFontColor)
            .fontSize($r('app.float.font_size_10'))
          }
          .labelContainerStyle(style.seckillPriceBgColor)
          .layoutWeight(1)

          Column() {
            Text(this.vm.getProductCardButtonLabel(product, timeslot))
              .fontColor(style.buttonFontColor)
              .fontWeight(FontWeight.Bold)
              .fontSize($r('app.float.font_size_14'))
          }
          .labelContainerStyle(style.buttonBgColor)
          .opacity(this.vm.isProductReserved(product, timeslot) ? 0.6 : 1)
          .constraintSize({ minWidth: 40 })
          .onClick(() => {
            this.vm.handleClickButton(product, timeslot)
          })
        }
        .width('100%')
      }
      .height('100%')
      .padding({
        top: $r('app.float.space_xs'),
        bottom: $r('app.float.space_xs'),
      })
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(100)
    .onClick(() => {
      this.vm.handleClickCard(product)
    })
  }
}

/** 秒杀商品自定义进度条 */
class MyProgressModifier implements ContentModifier<ProgressConfiguration> {
  product: SeckillProductInfo
  style: SeckillProductStyle

  constructor(product: SeckillProductInfo, style: SeckillProductStyle) {
    this.product = product
    this.style = style
  }

  applyContent(): WrappedBuilder<[ProgressConfiguration]> {
    return wrapBuilder(myProgress);
  }
}

@Builder
function myProgress(config: ProgressConfiguration) {
  Stack({ alignContent: Alignment.Start }) {
    Row() {
      if (((config.contentModifier as MyProgressModifier).style.progressBgColor as LinearGradientOptions).colors) {
        Row()
          .width((config.value / config.total) * 100 + '%')
          .constraintSize({ minWidth: '30%' })
          .height(14)
          .borderRadius(7)
          .linearGradient((config.contentModifier as MyProgressModifier).style.progressBgColor as LinearGradientOptions)
      } else {
        Row()
          .width((config.value / config.total) * 100 + '%')
          .constraintSize({ minWidth: '30%' })
          .height(14)
          .borderRadius(7)
          .backgroundColor((config.contentModifier as MyProgressModifier).style.progressBgColor as ResourceColor)
      }

    }
    .height(14)
    .borderRadius(7)
    .clip(true)
    .backgroundColor($r('sys.color.interactive_click'))
    .width('100%')
    .justifyContent(FlexAlign.Start)

    Text(SeckillUtil.getPercentLabel((config.contentModifier as MyProgressModifier).product))
      .fontSize(8)
      .fontColor($r('app.color.font_color_level1_invert'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .textIndent(8)
  }
}


@Extend(Column)
function labelContainerStyle(bgColor: ResourceColor) {
  .backgroundColor(bgColor)
  .borderRadius($r('app.float.border_radius_s'))
  .padding(8)
  .height(40)
  .justifyContent(FlexAlign.Center)
}