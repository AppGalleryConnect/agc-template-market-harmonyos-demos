import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import {
  AppointmentInfo,
  AppointState,
  CommonConstants,
  getGoodList,
  GetUserInfoResp,
  GoodCard,
  GoodInfo,
  GoodListInfo,
  CommonUtils,
  Logger,
  LoginButton,
  PopViewUtils,
  RouterMap,
  RouterModule,
  unbindPhone,
} from 'utils';
import { common, Configuration, EnvironmentCallback } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { DialogQRCodeBuilder, QRCodeParams } from '../components/DialogQRCode';

@ComponentV2
struct MineIconLabel {
  @Param icon: ResourceStr = '';
  @Param label: ResourceStr = '';

  build() {
    Column({ space: 6 }) {
      Image(this.icon).width(24).height(24)
      Text(this.label).fontSize(12).height(16)
    }
  }
}

@ComponentV2
export struct Mine {
  @Local goodList: GoodListInfo[] = [];
  @Local isRefreshing: boolean = false;
  @Local userInfo: GetUserInfoResp = AppStorageV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local titleBgOpacity: number = 0;
  scroller: Scroller = new Scroller();
  private context = getContext(this) as common.UIAbilityContext;
  // 注册订阅系统环境变化的ID
  private callbackId: number = 0;
  // 系统语言
  @Local systemLanguage: string = '';

  subscribeConfigurationUpdate(): void {
    // 获取系统当前语言
    this.systemLanguage = this.context.config.language || i18n.System.getFirstPreferredLanguage();

    // 1.获取ApplicationContext
    let applicationContext = this.context.getApplicationContext();

    // 2.通过applicationContext订阅环境变量变化
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated: (newConfig: Configuration) => {
        if (this.systemLanguage !== newConfig.language) {
          this.systemLanguage = newConfig.language || '';
        }
      },
      onMemoryLevel: (level) => {
      },
    }
    try {
      this.callbackId = applicationContext.on('environment', environmentCallback);
    } catch (err) {
      Logger.error('applicationContext.on(environment error: ' + JSON.stringify(err));
    }
  }

  unsubscribeConfigurationUpdate() {
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.off('environment', this.callbackId);
    } catch (err) {
      Logger.error('applicationContext.off(environment error: ' + JSON.stringify(err));
    }
  }

  aboutToAppear(): void {
    this.getGoodList();
  }

  getGoodList() {
    getGoodList().then((resp) => {
      this.goodList = resp as GoodListInfo[];
    })
  }

  isBindPhone() {
    return this.userInfo?.mobile !== '';
  }

  @Computed
  get userName() {
    return this.userInfo.nickName || $r('app.string.default_user_name');
  }

  @Builder
  titleBuilder() {
    Row() {
      Text('个人中心').fontSize(16).fontWeight(700).padding({ left: 16 }).height(56)
    }
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(Color.White)
    .opacity(this.titleBgOpacity)
  }

  @Builder
  titleInside() {
    Text('个人中心')
      .fontSize(16)
      .fontWeight(700)
      .padding({ left: 16 })
      .height(56)
      .alignSelf(ItemAlign.Start)
      .opacity(1 - 2 * this.titleBgOpacity)
  }

  @Builder
  UserBar() {
    Row({ space: 8 }) {
      Image(CommonUtils.handleImgUrl(this.userInfo.avatar) || $r('app.media.ic_user_default'))
        .width(56)
        .height(56)
        .clipShape(new CircleShape({ width: 56, height: 56 }))
      if (this.isBindPhone()) {
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            Text(this.userName)
              .fontSize(18)
              .fontWeight(500)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: 150 })

            if (this.userInfo.memberId) {
              Row({ space: 4 }) {
                Image($r('app.media.ic_member')).width(10)
                Text('高级会员').fontSize(10).fontColor($r('app.color.common_member'))
              }
              .backgroundColor('#1F1F20')
              .borderRadius(20)
              .height(20)
              .padding({ left: 4, right: 4 })
            }
          }

          Text($r('app.string.btn_cancel_bind_phone'))
            .fontSize(12)
            .decoration({ type: TextDecorationType.Underline })
            .onClick(() => {
              unbindPhone();
            })
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      } else {
        Column({ space: 4 }) {
          Text($r('app.string.default_user_name')).fontSize(18).fontWeight(500)
          LoginButton()
        }.alignItems(HorizontalAlign.Start)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 15,
    })
  }

  @Computed
  get pointLabel() {
    if (this.userInfo.points) {
      return this.userInfo.points.toString();
    }
    return '0';
  }

  @Computed
  get memberLabel() {
    if (this.userInfo.memberId) {
      return '1';
    }
    return '0';
  }

  @Builder
  MoreUserInfo() {
    Row({ space: 20 }) {
      Column({ space: 7 }) {
        Text(this.pointLabel).fontWeight(500).fontSize(16)
        Text('积分').fontSize(12)
      }

      Column({ space: 7 }) {
        Text(this.memberLabel).fontWeight(500).fontSize(16)
        Text('会员卡').fontSize(12)
      }.onClick(() => {
        if (!this.userInfo.memberId) {
          return;
        }
        PopViewUtils.showPopView<QRCodeParams>(wrapBuilder(DialogQRCodeBuilder),
          new QRCodeParams(this.userInfo.memberId),
          { alignment: DialogAlignment.Center, autoCancel: true });
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .margin({ bottom: 20 })
  }

  @Builder
  ServiceBar() {
    Grid() {
      GridItem() {
        Column() {
          Text('我的订单').fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start).margin({ bottom: 10 })
          Row() {
            MineIconLabel({ icon: $r('app.media.ic_bar_appointed'), label: '已预约' })
              .onClick(() => {
                RouterModule.push({ url: RouterMap.MY_APPOINTMENT_LIST, param: AppointState.NEW });
              })

            MineIconLabel({ icon: $r('app.media.ic_bar_appoint_done'), label: '已完成' })
              .onClick(() => {
                RouterModule.push({ url: RouterMap.MY_APPOINTMENT_LIST, param: AppointState.FINISH });
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
        .padding(10)
        .backgroundColor(Color.White)
        .borderRadius(8)
      }

      GridItem() {
        Column() {
          Text('服务与工具').fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start).margin({ bottom: 10 })
          Row() {
            MineIconLabel({ icon: $r('app.media.ic_bar_single_card'), label: '次卡' })
              .onClick(() => {
                RouterModule.push({ url: RouterMap.MY_SINGLE_VISIT_LIST });
              })

            MineIconLabel({ icon: $r('app.media.ic_bar_group'), label: '团购' })
              .onClick(() => {
                RouterModule.push({ url: RouterMap.MY_GROUP_LIST });
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
        .padding(10)
        .backgroundColor(Color.White)
        .borderRadius(8)
      }
    }
    .columnsGap(10)
    .columnsTemplate('1fr 1fr')
  }

  @Builder
  WaterFlowBuilder() {
    WaterFlow() {
      ForEach(this.goodList[0].goods, (good: GoodInfo) => {
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

  build() {
    NavDestination() {
      Stack() {
        Scroll(this.scroller) {
          Column() {
            Column() {
              this.titleInside()
              this.UserBar()
              this.MoreUserInfo()
            }
            .backgroundImage($r('app.media.mine_top_bg'))
            .backgroundImageSize(ImageSize.Cover)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

            Column({ space: 16 }) {
              this.ServiceBar()
              if (this.goodList.length) {
                this.WaterFlowBuilder()
              }
            }
            .padding({
              left: 10,
              right: 10,
              top: 17,
              bottom: 17,
            })
          }
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .onDidScroll(() => {
          this.titleBgOpacity = this.scroller.currentOffset().yOffset / 56;
        })

        this.titleBuilder()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .alignContent(Alignment.Top)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
