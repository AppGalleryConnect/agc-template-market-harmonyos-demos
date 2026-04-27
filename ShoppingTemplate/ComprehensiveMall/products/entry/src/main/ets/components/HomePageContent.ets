import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  iData,
  RouterMap,
  routerStack,
} from 'lib_foundation';
import { CategoryItem } from 'lib_network';
import { ProductWaterFlow } from 'product';
import { LengthMetrics } from '@kit.ArkUI';

enum ActivityType {
  CHECKIN = '签到',
  SECKILL = '秒杀'
}

@ComponentV2
export struct HomePageContent {
  @Param
  bannerList: ResourceStr[] = [];
  @Param
  categoryList: CategoryItem[] = [];
  @Param
  scroller: Scroller = new Scroller();
  @Event
  handleClickCategory: (id: string) => void;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  @Computed
  get bannerAspectRatio() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return 4 / 3
    }
    if (this.curBreakpoint.value === BreakpointTypeEnum.MD) {
      return 2.5
    }
    return 5
  }

  build() {
    Column({ space: 12 }) {
      Blank().height(0)
      this.bannerBuilder();
      this.buildCategory();
      ProductWaterFlow({
        openSwiper: true,
        handleProductClick: (id) => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: id,
          });
        },
        handleBack: () => {
          this.scroller.scrollEdge(Edge.Top);
        },
      })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  bannerBuilder() {
    Swiper() {
      ForEach(this.bannerList, (item: string) => {
        Image(item)
          .objectFit(ImageFit.Cover)
          .draggable(false);
      }, (item: ResourceStr, index: number) => index + JSON.stringify(item));
    }
    .width('100%')
    .indicator(false)
    .autoPlay(true)
    .aspectRatio(this.bannerAspectRatio)
    .clip(true)
    .borderRadius($r('app.float.border_radius_l'));
  }

  @Builder
  buildCategory() {
    Column({ space: 12 }) {
      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.categoryList, (category: CategoryItem) => {
            Column() {
              Image(category.iconUrl)
                .width(48)
                .height(48)
                .margin({ bottom: 4 });
              Text(category.label)
                .fontSize(12)
                .fontColor($r('app.color.font_color_level3'));
            }
            .width(60)
            .onClick(() => {
              this.handleClickCategory?.(category.id)
            })
          }, (category: CategoryItem) => category.id)
        }
        .constraintSize({ minWidth: '100%' })
        .padding($r('app.float.space_l'))
        .justifyContent(BreakpointSystem.isTablet ? FlexAlign.SpaceBetween : FlexAlign.Start)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .backgroundColor($r('app.color.background_color_primary'))
    .borderRadius($r('app.float.border_radius_l'))

    Flex({ space: { main: LengthMetrics.vp(12) } }) {
      this.buildActivityCard($r('app.media.ic_checkin'), ActivityType.CHECKIN)
      this.buildActivityCard($r('app.media.ic_seckill'), ActivityType.SECKILL)
    }
  }

  @Builder
  buildActivityCard(icon: ResourceStr, type: ActivityType) {
    Row() {
      Image(icon)
        .width(40)
        .margin({ right: $r('app.float.space_s') })
      Text(type)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
    }
    .padding($r('app.float.space_m'))
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.background_color_primary'))
    .borderRadius($r('app.float.border_radius_l'))
    .onClick(() => {
      if (type === ActivityType.CHECKIN) {
        routerStack.pushPath({ name: iData.global.isLogin ? RouterMap.POINTS_MALL : RouterMap.USER_LOGIN })
      } else {
        routerStack.pushPath({ name: RouterMap.PRODUCT_SECKILL })
      }
    })
    .flexGrow(1)
  }
}