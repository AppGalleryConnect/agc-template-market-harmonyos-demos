import {
  CommonConstants,
  CommonUtils,
  GetUserInfoResp,
  IntroItem,
  IntroType,
  LoginButtonType5,
  OrderType,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
  SingleCardInfo,
  UIBackBtn,
} from 'utils'
import { RuleID, ALIGN_RULE_CATEGORY, ALIGN_RULE_COUNT, ALIGN_RULE_DIVIDER } from '../common/Constant'
import { StoreList } from '../components/StoreList';
import { AppStorageV2 } from '@kit.ArkUI';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@Builder
export function SingleCardDetailBuilder() {
  SingleCardDetail()
}

@Extend(Column)
function cardContainer() {
  .width('100%')
  .padding({
    top: 14,
    bottom: 15,
    left: 10,
    right: 10,
  })
  .borderRadius(8)
  .backgroundColor(Color.White)
  .alignItems(HorizontalAlign.Start)
}

@ComponentV2
export struct SingleCardDetail {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  @Local cardInfo: SingleCardInfo = new SingleCardInfo();
  @Local isShowStoreSheet: boolean = false;
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const paramList: Array<SingleCardInfo> = RouterModule.getNavParam({ url: RouterMap.SINGLE_CARD_DETAIL });
    if (paramList.length) {
      this.cardInfo = paramList[paramList.length - 1];
    }
  }

  @Builder
  TopBanner() {
    Image(CommonUtils.handleImgUrl(this.cardInfo.image))
      .width(CommonConstants.FULL_PERCENT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Computed
  get storeDesc() {
    return `门店：${this.homeVM.storeList[0].storeName}等${this.homeVM.storeList.length}家门店适用`;
  }

  @Builder
  TitleCard() {
    Column() {
      // 价格
      Row({ space: 10 }) {
        Text('￥' + CommonUtils.handleCash(this.cardInfo.vipPrice)).fontColor('#E84026').fontSize(20).fontWeight(500)
        Text('￥' + CommonUtils.handleCash(this.cardInfo.price))
          .fontSize(12)
          .decoration({ type: TextDecorationType.LineThrough })
        Blank()
        Text(`年售${this.cardInfo.sales}+`).fontSize(12)
      }
      .width('100%')

      Text(this.cardInfo.title).fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start).margin({ top: 10 })
      // 项目次数
      Row() {
        RelativeContainer() {
          Column({ space: 5 }) {
            Text('项目次数').fontSize(10)
            Text(this.cardInfo.availableNum + '次').fontSize(10)
          }
          .alignItems(HorizontalAlign.Start)
          .alignRules(ALIGN_RULE_COUNT)

          Divider()
            .vertical(true)
            .id(RuleID.DIVIDER_ID)
            .alignRules(ALIGN_RULE_DIVIDER)

          Column({ space: 5 }) {
            Text('项目种类').fontSize(10)
            Text(this.cardInfo.projectNum + '种').fontSize(10)
          }
          .alignItems(HorizontalAlign.Start)
          .offset({ x: 10 })
          .alignRules(ALIGN_RULE_CATEGORY)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height(48)
      .padding({
        top: 8,
        bottom: 8,
        left: 10,
        right: 10,
      })
      .borderRadius(8)
      .backgroundColor('#F1F3F5')
      .margin({ top: 5 })

      // 门店
      Row({ space: 12 }) {
        Text(this.storeDesc)
          .fontSize(12)
          .fontColor($r('app.color.common_grey'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
        Blank()
        Image($r('app.media.ic_public_arrow_right'))
          .height(14)
          .fillColor($r('app.color.common_grey'))
      }
      .width('100%')
      .margin({ top: 10 })
      .onClick(() => {
        this.isShowStoreSheet = true;
      })
      .bindSheet($$this.isShowStoreSheet, this.StoreBuilder(), {
        title: { title: '适用门店' },
        showClose: true,
        height: SheetSize.MEDIUM,
      })
    }
    .width('100%')
    .padding({
      left: 11,
      right: 11,
      top: 10,
      bottom: 13,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  PurchaseNotice() {
    Column() {
      Text('购买须知').fontSize(14).fontWeight(500)
      Column({ space: 4 }) {
        Text('服务说明').fontSize(12).margin({ top: 7, bottom: 6 })
        Text('1、次卡可在购买以下项目时直接抵扣').fontSize(12)
        Text('2、次卡一经售出，不退卡、不换卡').fontSize(12)
        Text('3、您可以在“我的”-“次卡”中查看卡片详情').fontSize(12)
        Text('4、您到店消费时，需要将次卡的二维码展示给商户').fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text('服务详情').fontSize(12).margin({ top: 13, bottom: 6 })
        Text('可用日期：自购买日即可使用').fontSize(12)
        Text('有效期至：' +
          (this.cardInfo.availablePeriod === -1 ? '永久有效' :
          CommonUtils.formatDateTime(this.cardInfo.availablePeriod)))
          .fontSize(12)
        Text(`服务项目：${this.cardInfo.projectNum}个`).fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)
    }.cardContainer()

  }

  @Builder
  DetailCard() {
    Column({ space: 10 }) {
      Text('项目详情').fontSize(14).fontWeight(500)
      Column() {
        Text(this.cardInfo.title).fontSize(12)
        Text(`服务项目：${this.cardInfo.projectNum}个`).fontSize(12)
        Text(`服务次数：${this.cardInfo.availableNum}次`).fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)

      ForEach(this.cardInfo.intro, (item: IntroItem) => {
        if (item.type === IntroType.IMAGE) {
          Image(CommonUtils.handleImgUrl(item.value)).width('100%')
        }
        if (item.type === IntroType.TEXT) {
          Text(item.value).fontSize(12)
        }
      }, (v: IntroItem) => JSON.stringify(v))
    }.cardContainer()
  }

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.SINGLE_CARD;
    param.id = this.cardInfo.id;
    param.title = this.cardInfo.title;
    param.subTitle = this.cardInfo.subTitle;
    param.vipPrice = this.cardInfo.vipPrice;
    param.image = this.cardInfo.image;
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  @Builder
  BottomOperate() {
    Row() {
      Text('￥' + CommonUtils.handleCash(this.cardInfo.vipPrice)).fontColor('#E84026').fontSize(20).fontWeight(500)
      Text('￥' + CommonUtils.handleCash(this.cardInfo.price))
        .fontSize(12)
        .decoration({ type: TextDecorationType.LineThrough })
        .margin({ left: 10 })
      Blank()
      if (this.userInfo.mobile) {
        Button() {
          Text('立即抢购')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(500)
            .width(88)
            .height(21)
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r('app.color.common_theme_color'))
        .padding({
          top: 9,
          bottom: 9,
          left: 16,
          right: 16,
        })
        .onClick(() => {
          this.jumpOrder();
        })
      } else {
        LoginButtonType5({
          onBind: () => {
            this.jumpOrder();
          },
        })
          .onClick(() => {
          })
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 10 })
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  StoreBuilder() {
    StoreList()
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
        Text('次卡详情')
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
        Column({ space: 10 }) {
          Scroll(this.scroller) {
            Column() {
              this.TopBanner()
              Column({ space: 10 }) {
                // 标题卡片
                this.TitleCard()
                // 项目详情
                this.DetailCard()
                // 购买须知
                this.PurchaseNotice()
              }
              .padding({
                left: 10,
                right: 10,
                top: 16,
                bottom: 16,
              })
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .edgeEffect(EdgeEffect.Spring)
          .onDidScroll(() => {
            this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
          })

          this.BottomOperate()

        }
        .width('100%')
        .height('100%')

        this.titleBuilder()
      }
      .alignContent(Alignment.Top)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
