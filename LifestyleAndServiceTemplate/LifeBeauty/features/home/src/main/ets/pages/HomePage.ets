import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  StoreInfo,
  GoodListInfo,
  GoodInfo,
  getStoreInfo,
  getGoodList,
  Logger,
  PopViewUtils,
  CommonConstants,
  CommonUtils,
  SystemSceneUtils,
  GetUserInfoResp,
  GoodCard,
} from 'utils';
import { DialogCallBuilder, Params } from '../components/DialogCall';
import { LIST_RULE, RuleID, STORE_STATUS } from '../common/Constant';
import { BusinessParams, DialogBusinessBuilder } from '../components/DialogBusiness';
import { ActiveMember } from '../components/ActiveMemberModule';
import { SingleVisitList } from '../components/SingleVisitModule';
import { GroupBuyList } from '../components/GroupModule';
import { AppStorageV2 } from '@kit.ArkUI';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@Styles
function subTextContainer() {
  .padding({
    left: 4,
    right: 4,
    top: 2,
    bottom: 2,
  })
  .backgroundColor($r('app.color.common_page_bg'))
  .borderRadius(4)
}

@Extend(Text)
function subText() {
  .fontSize(10)
  .fontColor($r('app.color.common_grey'))
}

@ComponentV2
export struct Home {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  @Local storeInfo: StoreInfo = new StoreInfo();
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local goodList: GoodListInfo[] = [];
  @Local distance: string = '0m';
  @Local titleBgOpacity: number = 0;
  @Local isGranted: boolean = false;
  @Local isRefreshing: boolean = false;
  scroller: Scroller = new Scroller();

  async aboutToAppear(): Promise<void> {
    await this.getStoreInfo();
    this.getGoodList();
    await this.homeVM.init();
    const isGranted = await SystemSceneUtils.applyLocationPermission();
    if (isGranted) {
      this.calcDistance();
    }
  }

  getStoreInfo() {
    return getStoreInfo().then((resp) => {
      this.storeInfo = resp as StoreInfo;
      Logger.info('get store info response = ' + JSON.stringify(resp));
    }).catch((e: BusinessError) => {
      Logger.error('get store info error = ' + JSON.stringify(e));
    })
  }

  getGoodList() {
    getGoodList().then((resp) => {
      this.goodList = resp as GoodListInfo[];
      setTimeout(() => {
        this.isRefreshing = false;
      }, 100)
    })
  }

  calcDistance() {
    SystemSceneUtils.getDistance(this.storeInfo.coords).then((resp) => {
      this.distance = resp;
    });
    this.homeVM.storeList.forEach((item) => {
      SystemSceneUtils.getDistance(item.coords).then((resp) => {
        item.distance = resp;
      });
    })
  }

  @Computed
  get starList() {
    const list: number[] = [];
    try {
      if (this.storeInfo.score) {
        const scoreNum = Math.round(Number(this.storeInfo.score));
        while (list.length < scoreNum) {
          list.push(list.length + 1);
        }
        return list;
      }
      return [1, 2, 3, 4, 5];
    } catch (e) {
      return [1, 2, 3, 4, 5];
    }
  }

  openPhoneDialog() {
    PopViewUtils.showPopView<Params>(wrapBuilder(DialogCallBuilder), new Params(this.storeInfo.mobile.split(',')),
      { alignment: DialogAlignment.Bottom, autoCancel: true });
  }

  @Builder
  StoreInfoCard() {
    // 卡片
    Column({ space: 8 }) {
      // 店铺的图文等介绍
      Row({ space: 10 }) {
        Image(CommonUtils.handleImgUrl(this.storeInfo.logoUrl)).width(70).height(70).borderRadius(8)
        Column({ space: 6 }) {
          Text(this.storeInfo.storeName).fontSize(16).fontWeight(FontWeight.Bold)
          Row({ space: 2 }) {
            ForEach(this.starList, (v: number) => {
              Image($r('app.media.icon_star')).width(11).height(11).fillColor($r('app.color.common_theme_color'))
            }, (item: number) => item.toString())
            Text(`${this.storeInfo.score}分`)
              .fontSize(10)
              .fontColor($r('app.color.common_theme_color'))
            Text(this.storeInfo.businessStatus === STORE_STATUS.IN ? $r('app.string.business_in') :
            $r('app.string.business_out')).fontSize(10).fontColor($r('app.color.common_grey'))
            Text(this.storeInfo.businessTimes).fontSize(10).fontColor($r('app.color.common_grey'))
          }

          Row({ space: 4 }) {
            Text($r('app.string.home_tag_no_other_price')).subTextContainer().subText()
            Text($r('app.string.home_tag_refund')).subTextContainer().subText()
            Text($r('app.string.home_tag_security')).subTextContainer().subText()
            if (this.storeInfo.businessLicense) {
              Row({ space: 4 }) {
                Text($r('app.string.home_tag_auth')).subText()
                Image($r('app.media.ic_public_arrow_right')).height(10).fillColor($r('app.color.common_grey'))
              }
              .subTextContainer()
              .onClick(() => {
                PopViewUtils.showPopView<BusinessParams>(wrapBuilder(DialogBusinessBuilder),
                  new BusinessParams(this.storeInfo.businessLicense),
                  { alignment: DialogAlignment.TopEnd });
              })
            }
          }
        }.alignItems(HorizontalAlign.Start)
      }.width(CommonConstants.FULL_PERCENT).alignItems(VerticalAlign.Center)

      // 位置、导航、电话
      Row() {
        Image($r('app.media.ic_location')).width(10).height(10)
        Column({ space: 4 }) {
          Text(this.storeInfo.address || $r('app.string.empty_location')).fontSize(12)
          Text(this.distance).fontSize(11).fontColor('#878787')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 6 })
        .layoutWeight(1)

        Column() {
          Image($r('app.media.ic_navigation')).width(22).height(22)
          Text($r('app.string.home_label_navi')).fontSize(8).fontColor('#656565')
        }
        .margin({ left: 20 })
        .onClick(() => {
          const context = getContext(this) as common.UIAbilityContext;
          SystemSceneUtils.jumpPetalMap(context, this.storeInfo.address, this.storeInfo.coords.split(','))
        })

        Column() {
          Image($r('app.media.ic_call')).width(22).height(22)
          Text($r('app.string.home_label_call')).fontSize(8).fontColor('#656565')
        }
        .margin({ left: 10 })
        .onClick(() => {
          this.openPhoneDialog();
        })

      }.width(CommonConstants.FULL_PERCENT).alignItems(VerticalAlign.Top)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(10)
    .borderRadius(8)

    if (this.userInfo.mobile && !this.userInfo.memberId) {
      ActiveMember().margin({ top: 14 })
    }
  }

  @Builder
  GoodList(v: GoodListInfo) {
    Row() {
      Text() {
        Span('— ')
        Span(v.title)
        Span(' —')
      }.fontSize(12).fontColor($r('app.color.common_grey'))
    }.width(CommonConstants.FULL_PERCENT).justifyContent(FlexAlign.Center)

    WaterFlow() {
      ForEach(v.goods, (good: GoodInfo) => {
        FlowItem() {
          GoodCard({ goodInfo: good })
        }
        .width(CommonConstants.FULL_PERCENT)
      }, (v: GoodInfo) => JSON.stringify(v))
    }
    .cachedCount(10)
    .columnsTemplate('1fr 1fr')
    .columnsGap(10)
    .rowsGap(6)
    .width(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('首页').fontSize(16).fontWeight(700).padding({ left: 16 }).height(56)
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.titleBgOpacity)
  }

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            RelativeContainer() {
              Image(CommonUtils.handleImgUrl(this.storeInfo.storeBanner))
                .width(CommonConstants.FULL_PERCENT)
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
                .id(RuleID.BANNER_ID)

              Refresh({ refreshing: $$this.isRefreshing }) {
                Scroll() {
                  Column({ space: 10 }) {
                    this.StoreInfoCard()
                    SingleVisitList()
                    GroupBuyList()
                    ForEach(this.goodList, (v: GoodListInfo) => {
                      this.GoodList(v)
                    }, (item: GoodListInfo) => JSON.stringify(item))
                  }

                  .padding({
                    left: 10,
                    right: 10,
                    top: 40,
                    bottom: 10,
                  })
                }
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST,
                })
              }
              .id(RuleID.GOOD_LIST_ID)
              .alignRules(LIST_RULE)
              .onRefreshing(() => {
                this.getGoodList();
              })
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .height('auto')
            .width('auto')
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .onDidScroll(() => {
          this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
        })

        this.titleBuilder()
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Top)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
