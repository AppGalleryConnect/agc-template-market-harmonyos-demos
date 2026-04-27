import { UISkeleton, SkeletonType, SkeletonTheme } from '@hw-agconnect/ui-skeleton'
import { iData } from 'lib_foundation';
import { ProductDetailLabel, ProductDetailInfo, ProductReviewItem, SeckillProductInfo } from 'lib_network';
import { ProductSwiperStyleConfig } from '../commons/StyleConfig';
import { ProductInfoVM } from '../viewmodels/ProductInfoVM';
import { ProductReviewCard } from './ProductReviewCard';

/** 商品详情页加载骨架屏 */
@Builder
export function buildLoadingPlaceholder() {
  Column() {
    UISkeleton({
      options: [
        { width: '100%', height: 320, type: SkeletonType.RECT },
        { width: 180, height: 20, type: SkeletonType.TEXT },
        { width: '100%', height: 20, type: SkeletonType.TEXT },
      ],
    })
      .height(420)
    UISkeleton({ theme: SkeletonTheme.PARAGRAPH })
  }
  .padding(16)
  .layoutWeight(1)
}

/** 空搜索状态 */
@Builder
export function buildEmptySearch() {
  Column() {
    Image($r('app.media.ic_search_empty'))
      .width(120)
      .height(120);
    Text('暂无搜索结果')
      .fontSize(14)
      .fontColor($r('app.color.font_color_level2'));
  }
  .layoutWeight(1)
  .justifyContent(FlexAlign.Center)
}

/** 商品详情顶部轮播 */
@Builder
export function buildProductSwiper(imgList: ResourceStr[]) {
  Swiper() {
    ForEach(imgList, (item: ResourceStr) => {
      Image(item)
        .height('100%')
        .constraintSize({
          maxHeight: ProductSwiperStyleConfig.imageMaxHeight,
        })
        .aspectRatio(ProductSwiperStyleConfig.imageAspectRatio)
        .objectFit(ImageFit.Cover)
        .padding(ProductSwiperStyleConfig.imagePadding)
    }, (item: ResourceStr) => JSON.stringify(item));
  }
  .width('100%')
  .padding({ left: ProductSwiperStyleConfig.swiperPadding, right: ProductSwiperStyleConfig.swiperPadding })
  .prevMargin(ProductSwiperStyleConfig.outImageDisplayWidth, true)
  .nextMargin(ProductSwiperStyleConfig.outImageDisplayWidth, true)
  .indicatorInteractive(true)
  .backgroundColor($r('app.color.background_color_grey'))
  .indicator(
    new DotIndicator()
      .selectedItemWidth(12)
      .selectedItemHeight(6)
      .selectedColor($r('app.color.theme_color'))
      .itemWidth(6)
      .itemHeight(6)
      .color($r('sys.color.comp_background_secondary')),
  );
}

/** 商品详情页商品信息 */
@Builder
export function buildProductInfoCard(productInfo: ProductDetailInfo, seckillInfo?: SeckillProductInfo) {
  Column({ space: 8 }) {
    // 价格、销量
    Row() {
      if (seckillInfo) {
        Text('限时秒杀')
          .fontColor($r('app.color.font_color_level1_invert'))
          .backgroundColor($r('app.color.theme_color'))
          .padding(2)
          .fontSize($r('app.float.font_size_10'))
          .borderRadius($r('app.float.border_radius_xs'))
          .margin({ right: $r('app.float.space_xs'), bottom: $r('app.float.space_xs') })
      }
      Text() {
        Span('¥').priceTextStyle();
        Span((seckillInfo?.seckillPrice ? seckillInfo.seckillPrice : productInfo.price).toString())
          .priceTextStyle()
          .fontSize(24);
        Span(' ').letterSpacing(4);
        Span('¥').dashPriceTextStyle();
        Span(productInfo.dashPrice?.toString()).dashPriceTextStyle();
      }
      .margin({ right: 4 });

      Blank();
      Text(getSoldLabel(productInfo, seckillInfo))
        .infoTextStyle()
        .fontColor($r('app.color.font_color_level2'));
    }
    .width('100%')
    .alignItems(VerticalAlign.Bottom);

    // 标题
    Text(productInfo.title)
      .width('100%')
      .fontWeight(FontWeight.Medium)
      .fontSize(18)
      .lineHeight(24)
      .fontColor($r('app.color.font_color_level1'))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis });

    // 标签
    Row({ space: 4 }) {
      ForEach(productInfo.tags, (item: string) => {
        Row() {
          Text(item)
            .fontSize(10)
            .fontColor($r('app.color.theme_color'))
            .fontWeight(FontWeight.Medium);
        }
        .padding({
          left: 8,
          right: 8,
          top: 2,
          bottom: 2,
        })
        .borderRadius($r('app.float.border_radius_xs'))
        .backgroundColor($r('app.color.background_color_theme'));
      }, (item: string) => item);
    }
    .width('100%')
    .justifyContent(FlexAlign.Start);


    //发货信息
    buildServiceInfo(productInfo.logistics);

    // 服务信息
    buildServiceInfo(productInfo.service);

  }
  .width('100%')
  .padding({
    left: 16,
    right: 16,
    top: 12,
    bottom: 12,
  })
  .backgroundColor($r('app.color.background_color_primary'));
}

function getSoldLabel(productInfo: ProductDetailInfo, seckillInfo?: SeckillProductInfo) {
  let sold: number = 0
  if (!seckillInfo) {
    sold = productInfo.sales
  } else {
    sold = seckillInfo.totalStock - seckillInfo.remainStock
  }
  let soldLabel: string = ''
  if (sold < 100) {
    soldLabel = sold.toString()
  } else if (sold < 1000) {
    soldLabel = Math.floor(sold / 100) + '00'
  } else if (sold < 10000) {
    soldLabel = Math.floor(sold / 1000) + '000'
  } else {
    soldLabel = Math.floor(sold / 10000) + 'w'
  }
  if (!soldLabel) {
    return ''
  }
  return '已售' + soldLabel + '+'
}

/** 开通会员卡片 */
@Builder
export function buildMemberCard(vm: ProductInfoVM) {
  if (!iData.global.userInfo.isMember) {
    Column() {
      Row() {
        SymbolGlyph($r('sys.symbol.bell_fill'))
          .fontSize(24)
          .fontColor([$r('app.color.font_color_level1_invert')])
          .margin({ right: $r('app.float.space_xs') })
        Text('开通会员，享9折优惠！')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_level1_invert'))

        Blank()
        Button('立即查看')
          .backgroundColor(Color.White)
          .fontColor($r('app.color.theme_color'))
          .controlSize(ControlSize.SMALL)
      }
      .width('100%')
      .padding($r('app.float.space_m'))
      .borderRadius($r('app.float.border_radius_s'))
      .backgroundColor($r('app.color.theme_color'))
      .onClick(() => {
        vm.handleClickMemberLink()
      })
    }
    .padding($r('app.float.space_m'))
  }
}

/** 用户评价卡片 */
@Builder
export function buildReviewOverview(vm: ProductInfoVM) {
  Column({ space: 16 }) {
    Row() {
      Text() {
        Span('商品评价')
        Span(`(${vm.reviewNum})`)
      }
      .fontWeight(FontWeight.Bold)
      .layoutWeight(1)

      Text('更多')
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level3'))
        .margin({ right: $r('app.float.space_xs') })
      Image($r('app.media.ic_arrow_right'))
        .height(16)
        .fillColor($r('app.color.font_color_level3'))
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)

    if (vm.reviewList.length) {
      Column({ space: 16 }) {
        ForEach(vm.reviewList, (reviewItem: ProductReviewItem) => {
          ProductReviewCard({ reviewItem })
        }, (item: ProductReviewItem, index: number) => index + '_' + item.date)
      }
      .hitTestBehavior(HitTestMode.BLOCK_DESCENDANTS)
    } else {
      Text('暂无商品评价')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
        .height(36)
    }
  }
  .padding($r('app.float.space_l'))
  .margin({ bottom: 8 })
  .backgroundColor($r('app.color.background_color_primary'))
  .onClick(() => {
    vm.handleClickReview()
  })
}

/** 商品详情介绍 */
@Builder
export function buildProductDesc(productInfo: ProductDetailInfo) {
  Column() {
    Text('商品详情').chapterTitleStyle();
    if (productInfo?.pictures) {
      ForEach(productInfo.pictures, (item: string) => {
        Image(item)
          .width('100%')
          .objectFit(ImageFit.Contain)
          .draggable(false);
      }, (item: string) => JSON.stringify(item));
    }
  }
  .width('100%')
  .alignItems(HorizontalAlign.Start)
  .backgroundColor($r('app.color.background_color_primary'))
  .padding({ top: 12, bottom: 12 });
}

/** 分隔符 */
@Builder
export function buildDivider() {
  Row()
    .height($r('app.float.space_s'))
    .width($r('app.string.size_percent_full'))
    .backgroundColor($r('app.color.background_color_grey'))
}

@Builder
function buildServiceInfo(services: ProductDetailLabel[]) {
  Column() {
    ForEach(services, (service: ProductDetailLabel) => {
      Row() {
        Image(service.icon)
          .width(14)
          .height(10)
          .fillColor($r('app.color.font_color_level2'))
          .margin({ right: 8 });
        Text(service.content)
          .infoTextStyle();
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);
    }, (item: ProductDetailLabel) => item.content);
  }
  .alignItems(HorizontalAlign.Start);
}

@Extend(Span)
function priceTextStyle() {
  .fontSize(12)
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.theme_color'));
}

@Extend(Span)
function dashPriceTextStyle() {
  .fontSize(12)
  .fontWeight(FontWeight.Regular)
  .fontColor($r('app.color.font_color_level3'))
  .decoration({
    type: TextDecorationType.LineThrough,
    color: $r('app.color.font_color_level3'),
  });
}

@Extend(Text)
function infoTextStyle() {
  .fontSize(12)
  .lineHeight(18)
  .fontWeight(FontWeight.Regular)
  .fontColor($r('app.color.font_color_level3'));
}

@Extend(Text)
function chapterTitleStyle() {
  .textIndent(16)
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Bold)
  .margin({ bottom: 16 });
}