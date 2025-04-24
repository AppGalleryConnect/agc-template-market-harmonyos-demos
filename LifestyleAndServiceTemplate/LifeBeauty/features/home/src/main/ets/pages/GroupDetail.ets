import {
  CommonConstants,
  GetUserInfoResp,
  GroupContentItem,
  GroupInfo,
  CommonUtils,
  IntroItem,
  IntroType,
  LoginButtonType5,
  OrderType,
  RouterMap,
  RouterModule,
  SimpleGoodInfo,
  UIEmpty,
  UIBackBtn,
} from 'utils';
import { StoreList } from '../components/StoreList';
import { AppStorageV2 } from '@kit.ArkUI';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@Builder
export function GroupDetailBuilder() {
  GroupDetail()
}

@Extend(Column)
function cardContainer() {
  .width('100%')
  .padding(10)
  .borderRadius(8)
  .backgroundColor(Color.White)
  .alignItems(HorizontalAlign.Start)
}

@ComponentV2
struct CardContainer {
  @Param title: string = '';
  @BuilderParam buildParam: () => void;

  build() {
    Column() {
      Text(this.title).fontWeight(500).margin({ bottom: 10 })
      if (this.buildParam) {
        this.buildParam()
      }
    }
    .cardContainer()
  }
}

@ComponentV2
export struct GroupDetail {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  @Local groupInfo: GroupInfo = new GroupInfo();
  @Local isShowStoreSheet: boolean = false;
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const paramList: Array<GroupInfo> = RouterModule.getNavParam({ url: RouterMap.GROUP_DETAIL });
    if (paramList.length) {
      this.groupInfo = paramList[paramList.length - 1];
    }
  }

  @Builder
  Banner() {
    Image(CommonUtils.handleImgUrl(this.groupInfo.images[0]))
      .width(CommonConstants.FULL_PERCENT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  StoreBuilder() {
    StoreList()
  }

  @Computed
  get storeDesc() {
    return `门店：${this.homeVM.storeList[0].storeName}等${this.homeVM.storeList.length}家门店适用`;
  }

  @Builder
  TitleCard() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 4 }) {
          Text('￥' + CommonUtils.handleCash(this.groupInfo.vipPrice)).fontColor('#E84026').fontSize(20).fontWeight(500)
          Text('￥' + CommonUtils.handleCash(this.groupInfo.price))
            .fontSize(12)
            .decoration({ type: TextDecorationType.LineThrough })
        }

        Blank()
        Text(`年售${this.groupInfo.soldNum}+`).fontSize(12)
      }.width('100%').alignItems(VerticalAlign.Bottom)

      Text(this.groupInfo.title).fontSize(16).fontWeight(500)

      Row({ space: 12 }) {
        Text(this.storeDesc)
          .fontSize(12)
          .fontColor($r('app.color.common_grey'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
        Image($r('app.media.ic_public_arrow_right'))
          .height(14)
          .fillColor($r('app.color.common_grey'))
      }
      .width('100%')
      .onClick(() => {
        this.isShowStoreSheet = true;
      })
      .bindSheet($$this.isShowStoreSheet, this.StoreBuilder(), {
        title: { title: '适用门店' },
        showClose: true,
        height: SheetSize.MEDIUM,
      })

    }.cardContainer()
  }

  @Builder
  ContentCard() {
    CardContainer({ title: '套餐内容' }) {
      Column({ space: 10 }) {
        Row({ space: 30 }) {
          Text('适用部位').fontSize(12)
          Text(this.groupInfo.groupContent.location).fontSize(12)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('包含项目').fontSize(12)
          Text(this.groupInfo.groupContent.including).fontSize(12).layoutWeight(1).textAlign(TextAlign.Start)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('附赠项目').fontSize(12)
          Text(this.groupInfo.groupContent.present).fontSize(12)
        }.width('100%').alignItems(VerticalAlign.Top)

        Text('团购详情').fontSize(12)
        Column({ space: 4 }) {
          ForEach(this.groupInfo.groupContent.detail, (item: GroupContentItem) => {
            Row() {
              Text('·').fontSize(12)
              Text(item.title).fontSize(12)
              Blank()
              Row() {
                Text(`(${item.numbers} 份)`).fontColor($r('app.color.common_grey')).fontSize(12)
                Text('￥' + CommonUtils.handleCash(item.price)).fontSize(12)
              }.width('30%').justifyContent(FlexAlign.SpaceBetween)
            }.width('100%')
          }, (v: GroupContentItem) => JSON.stringify(v))
        }

      }.alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  NoticeCard() {
    Column({ space: 10 }) {
      Text('购买须知').fontSize(14).fontWeight(500)
      Column({ space: 4 }) {
        Text('服务说明').fontSize(12).margin({ top: 7, bottom: 6 })
        Text('1、此券可在购买以下项目时直接抵扣').fontSize(12)
        Text('2、您可以在“我的”-“团购”中查看卡片详情').fontSize(12)
        Text('3、您到店消费时，需要将团购的二维码展示给商户').fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text('服务详情').fontSize(12).margin({ top: 13, bottom: 6 })
        Text('可用日期：自购买日即可使用').fontSize(12)
        Text('有效期至：' +
          (this.groupInfo.availablePeriod === -1 ? '永久有效' :
          CommonUtils.formatDateTime(this.groupInfo.availablePeriod)))
          .fontSize(12)
        Text(`服务项目：${this.groupInfo.projectNum}个`).fontSize(12)
      }
      .alignItems(HorizontalAlign.Start)
    }.cardContainer()
  }

  @Builder
  MoreDetail() {
    if (this.groupInfo.intro.length) {
      Column({ space: 8 }) {
        ForEach(this.groupInfo.intro, (item: IntroItem) => {
          if (item.type === IntroType.IMAGE) {
            Image(CommonUtils.handleImgUrl(item.value)).width('100%').height('auto')
          }
          if (item.type === IntroType.TEXT) {
            Text(item.value).fontSize(14)
          }
        }, (v: IntroItem) => JSON.stringify(v))
      }
      .padding({ bottom: 10 })
    } else {
      UIEmpty({ emptyDesc: $r('app.string.good_detail_more_empty'), fg: 12 }).margin({ top: 60, bottom: 60 })
    }

  }

  buildRouteParam() {
    const param = new SimpleGoodInfo();
    param.type = OrderType.GROUP;
    param.id = this.groupInfo.id;
    param.title = this.groupInfo.title;
    param.subTitle = this.groupInfo.subTitle;
    param.vipPrice = this.groupInfo.vipPrice;
    param.image = this.groupInfo.images[0] ?? '';
    return param;
  }

  jumpOrder() {
    const param = this.buildRouteParam();
    RouterModule.push({ url: RouterMap.SUBMIT_ORDER, param: param });
  }

  @Builder
  BottomOperate() {
    Row() {
      Text('￥' + CommonUtils.handleCash(this.groupInfo.vipPrice)).fontSize(20).fontColor('#E84026').fontWeight(500)
      Text('￥' + CommonUtils.handleCash(this.groupInfo.price))
        .decoration({ type: TextDecorationType.LineThrough })
        .fontSize(12)
        .fontColor($r('app.color.common_grey'))
        .margin({ left: 10 })

      Blank()
      if (this.userInfo.mobile) {
        Button() {
          Text('立即抢购')
            .width(88)
            .height(21)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
        }
        .backgroundColor($r('app.color.common_theme_color'))
        .padding({
          left: 16,
          right: 16,
          top: 9,
          bottom: 9,
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
    .padding({
      left: 10,
      right: 10,
      top: 15,
      bottom: 10,
    })
    .backgroundColor(Color.White)
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
        Text('团购详情')
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
              Column({ space: 10 }) {
                this.TitleCard()
                this.ContentCard()
                this.NoticeCard()
              }
              .padding({
                left: 10,
                right: 10,
                top: 6,
                bottom: 6,
              })

              Text('—— 图文详情 ——').fontSize(12).fontColor($r('app.color.common_grey'))
              this.MoreDetail()
            }
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
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


