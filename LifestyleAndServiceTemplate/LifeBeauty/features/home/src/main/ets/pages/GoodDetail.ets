import { AppStorageV2 } from '@kit.ArkUI';
import {
  CommonConstants,
  GetUserInfoResp,
  GoodInfo,
  CommonUtils,
  LoginButtonType3,
  RouterMap,
  RouterModule,
  IntroType,
  UIEmpty,
  UIBackBtn,
  AppointState,
  IntroItem,
} from 'utils';
import { TAG_CONSTANT_LIST, ImgDesc } from '../common/Constant';

@Builder
export function GoodDetailBuilder() {
  GoodDetail()
}

@ComponentV2
export struct GoodDetail {
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local goodInfo: GoodInfo = new GoodInfo();
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const paramList: Array<GoodInfo> = RouterModule.getNavParam({ url: RouterMap.GOOD_DETAIL });
    if (paramList.length) {
      this.goodInfo = paramList[paramList.length - 1];
    }
  }

  @Computed
  get isBindPhone() {
    return Boolean(this.userInfo.mobile);
  }

  @Builder
  Banner() {
    Image(CommonUtils.handleImgUrl(this.goodInfo.images[0]))
      .width(CommonConstants.FULL_PERCENT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  GoodSimpleInfo() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Text($r('app.string.good_card_money_symbol', this.goodInfo.price.toFixed(2)))
          .fontSize(21)
          .fontColor($r('app.color.common_theme_color'))
        Text() {
          Span($r('app.string.good_detail_member_price')).fontSize(14)
          Span(this.goodInfo.vipPrice.toFixed(2)).fontSize(18)
        }
        .padding({
          top: 4,
          bottom: 4,
          left: 8,
          right: 8,
        })
        .fontSize(12)
        .fontColor($r('app.color.common_fg_white'))
        .textAlign(TextAlign.Center)
        .backgroundColor($r('app.color.common_theme_color'))
        .borderRadius(12)
      }.justifyContent(FlexAlign.Start)

      Text(this.goodInfo.title).fontSize(16).fontColor('#212121').maxLines(2).fontWeight(FontWeight.Bold)

      Row() {
        ForEach(TAG_CONSTANT_LIST, (v: ImgDesc) => {
          Row({ space: 4 }) {
            Image(v.src).width(12).height(12)
            Text(v.desc).fontSize(10).fontColor('#BEBEBE')
          }
        }, (item: ImgDesc) => JSON.stringify(item))
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 18,
      bottom: 18,
      left: 15,
      right: 15,
    })
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(8)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  GoodDetailInfo() {
    Column() {
      Text($r('app.string.good_detail_more_title')).fontSize(13).fontColor('#C1C1C1')

      if (this.goodInfo.intro.length) {
        // 富文本容器显示html
        this.RichContent()
      } else {
        UIEmpty({ emptyDesc: $r('app.string.good_detail_more_empty'), fg: 12 }).margin({ top: 60, bottom: 60 })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 18,
      bottom: 18,
      left: 15,
      right: 15,
    })
    .backgroundColor($r('app.color.common_card_bg'))
    .borderRadius(8)
  }

  @Builder
  RichContent() {
    Column({ space: 8 }) {
      ForEach(this.goodInfo.intro, (v: IntroItem) => {
        if (v.type === IntroType.IMAGE && v.value) {
          Image(CommonUtils.handleImgUrl(v.value)).width(CommonConstants.FULL_PERCENT).objectFit(ImageFit.Contain)
        } else if (v.type === IntroType.TEXT && v.value) {
          Text(v.value).fontSize(16)
        }
      }, (item: IntroItem) => JSON.stringify(item))

    }.width(CommonConstants.FULL_PERCENT).padding({ top: 18 })

  }

  @Builder
  bottomBar() {
    Row({ space: 16 }) {
      Column({ space: 4 }) {
        Image($r('app.media.icon_record')).width(17).height(17)
        Text($r('app.string.appoint_record_btn')).fontColor('#212121').fontSize(10)
      }
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MY_APPOINTMENT_LIST, param: AppointState.NEW });
      })

      if (this.isBindPhone) {
        Button($r('app.string.book_good_btn'))
          .fontSize(14)
          .fontColor($r('app.color.common_fg_white'))
          .backgroundColor($r('app.color.common_theme_color'))
          .layoutWeight(1)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.BOOK_GOOD, param: this.goodInfo });
          })
      } else {
        LoginButtonType3({
          onBind: () => {
            RouterModule.push({ url: RouterMap.BOOK_GOOD, param: this.goodInfo });
          },
        }).layoutWeight(1)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.common_card_bg'))
    .padding({
      left: 10,
      right: 10,
      top: 10,
      bottom: 10,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  titleBuilder() {
    Stack() {
      Row() {
        Text().height(56)
      }
      .opacity(this.titleBgOpacity)
      .backgroundColor(Color.White)
      .width('100%').expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      Row({ space: 10 }) {
        UIBackBtn()
        Text('服务详情')
          .fontSize(16)
          .fontWeight(700)
          .height(56)
          .opacity(this.titleBgOpacity)
      }
      .width('100%')

    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Scroll(this.scroller) {
            Column({ space: 10 }) {
              this.Banner()
              Column() {
                // 商品标题卡片
                this.GoodSimpleInfo()
              }.padding({ left: 10, right: 10 })

              Column() {
                // 图文详情卡片
                this.GoodDetailInfo();
              }.padding({ left: 10, right: 10 })
            }
            .padding({ bottom: 20 })
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .width(CommonConstants.FULL_PERCENT)
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onDidScroll(() => {
            this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
          })

          this.bottomBar()
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)

        this.titleBuilder()
      }.alignContent(Alignment.Top)
    }
    .backgroundColor($r('app.color.common_page_bg'))
    .hideTitleBar(true)
  }
}
