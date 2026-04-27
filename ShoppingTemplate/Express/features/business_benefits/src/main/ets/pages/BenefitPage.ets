import { AppStorageV2, PersistenceV2, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import {
  BreakpointModel,
  CommonTitle,
  CommonUtil,
  HttpApi,
  Logger,
  PageStatus,
  RouterMap,
  RouterModule,
  ToastLoading,
  UserInfoModel,
  WindowInfo,
} from 'lib_foundation';
import { SignStatus } from '../commons/Enum';
import { CouponListSection } from '../components/CouponListSection';
import { TaskListSection } from '../components/TaskListSection';


@ComponentV2
export struct BenefitPage {
  @Param isTabPage: boolean = true;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local windowModel: WindowInfo = AppStorageV2.connect(WindowInfo, () => new WindowInfo())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local signMask: number = 0;
  @Local todayIdx: number = 0;
  @Local rewards: number[] = [5, 5, 5, 5, 5, 5, 10];
  // 页面状态
  @Local pageStatus: PageStatus = PageStatus.IDLE;
  @Local curTabBtnIndex: number = 0;
  // scroll方向
  @Local scrollDir: ScrollDirection = ScrollDirection.None;

  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  @Computed
  get countSigned() {
    return this.signMask.toString(2).split('1').length - 1;
  }

  @Computed
  get isTodaySigned() {
    return (this.signMask & (1 << this.todayIdx)) !== 0;
  }

  aboutToAppear(): void {
    this.pageStatus = PageStatus.LOADING;
    ToastLoading.open();
    this.todayIdx = (new Date().getDay() || 7) - 1;
    this.loadData();
    this.handleSplitScreen();
  }

  async loadData() {
    const monday = CommonUtil.getMondayTimestamp();
    const data = await HttpApi.queryWeeklyData(this.userInfoModel.id, monday);
    this.signMask = Number(data.signMask);
    this.pageStatus = PageStatus.SUCCESS;
    ToastLoading.close();
  }

  handleSplitScreen() {
    const windowStage = AppStorage.get('windowStage') as window.WindowStage;
    try {
      const windowClass = windowStage.getMainWindowSync();
      let customerWindowStatusType: WindowStatusType = windowClass.getWindowStatus();
      if (customerWindowStatusType === 5) {
        this.scrollDir = ScrollDirection.Vertical;
      } else {
        this.scrollDir = ScrollDirection.None;
      }
      windowClass.on('windowStatusChange', (windowStatusType) => {
        if (windowStatusType === 5) {
          this.scrollDir = ScrollDirection.Vertical;
        } else {
          this.scrollDir = ScrollDirection.None;
        }
      });
    } catch (error) {
      Logger.error(`handleSplitScreen failed. error: ${JSON.stringify(error)}`)
    }
  }

  getSignBg(index: number) {
    if ((this.signMask & (1 << index)) !== 0) {
      return $r('app.media.ic_checked');
    }
    if (index < this.todayIdx) {
      return $r('app.media.ic_expired');
    }
    return $r('app.media.ic_no_checked');
  }

  // 判断状态：已签到、已过期、普通
  signStatus(index: number) {
    if ((this.signMask & (1 << index)) !== 0) {
      return SignStatus.SIGNED
    }
    if (index < this.todayIdx) {
      return SignStatus.EXPIRED;
    }
    return SignStatus.NORMAL;
  }

  // 签到
  async handleSign() {
    ToastLoading.open();
    const monday = CommonUtil.getMondayTimestamp();
    const userId = this.userInfoModel.id;
    const points = this.rewards[this.todayIdx]
    const success = await HttpApi.doSign(userId, this.todayIdx, points, monday);

    if (success) {
      this.loadData();
      // 查询用户积分
      this.getUserPoints();
    }
  }

  // 查询用户积分
  getUserPoints() {
    HttpApi.queryUserInfo(this.userInfoModel.phone).then((resp) => {
      if (resp) {
        this.userInfoModel.points = resp.points;
      }
    })
  }

  build() {
    Column() {
      CommonTitle({
        title: '福利',
        showBackBtn: !this.isTabPage,
        fontSize: this.isTabPage ? 26 : 20
      })

      if (this.pageStatus === PageStatus.SUCCESS) {
        Scroll() {
          Column() {
            // 积分总览
            this.pointsOverview()

            Text(this.isTodaySigned ? '今日积分已领取，每100积分可抵扣快递费5元' :
              '今天还没有签到，快点击签到领取积分吧~')
              .fontSize(12)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(16)
              .margin({ top: 2 })

            // 签到
            this.signCardView()

            // 优惠券和日常任务tab
            this.tabBtnBuilder()

            // 内容区域
            Tabs({ barPosition: BarPosition.Start, index: this.curTabBtnIndex }) {
              TabContent() {
                // 优惠券列表组件
                CouponListSection()
              }
              TabContent() {
                // 日常任务列表组件
                TaskListSection()
              }
            }
            .width('100%')
            .layoutWeight(this.scrollDir === ScrollDirection.None ? 1 : 0)
            .height(this.scrollDir === ScrollDirection.None ? 'auto' : '100%')
            .margin({ top: 12 })
            .barHeight(0)
            .scrollable(false)
            .onChange((index: number) => {
              this.curTabBtnIndex = index;
            })
          }
          .width('100%')
          .padding({
            left: this.breakPointModel.pagePadding,
            right: this.breakPointModel.pagePadding,
            top: 12,
          })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .align(Alignment.Top)
        .scrollable(this.scrollDir)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.bg_benefit'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .backgroundImageResizable({
      slice: {
        left: '10px',
        top: `${this.windowModel.windowWidth * 0.60}px`,
        right: `${this.windowModel.windowWidth * 0.45}px`,
        bottom: '20px',
      },
    })
    .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding) {
        this.getUserPoints();
      }
    })
  }

  @Builder
  pointsOverview() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_points'))
        .width(16)
        .height(16)

      Text('积分余额')
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(500)
        .lineHeight(21)

      Text(`${this.userInfoModel.points}`)
        .fontSize(24)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(500)
        .lineHeight(32)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(24)
        .fontColor([$r('sys.color.icon_primary')])
    }
    .onClick(() => {
      RouterModule.push({ url: RouterMap.POINTS_HISTORY_PAGE })
    })
  }

  @Builder
  signCardView() {
    Column({ space: 16 }) {
      Row() {
        Text('签到7天 赚积分')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))

        Text() {
          Span('已打卡')
          Span(`${this.countSigned}`).fontColor('#EC6E45')
          Span('/7天')
        }
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(16)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        ForEach(this.rewards, (item: number, index: number) => {
          Column({ space: 8 }) {
            Stack() {
              Image(this.getSignBg(index))
                .width(34)
                .autoResize(true)
              Row() {
                Text(item + '')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(Color.White)
                  .margin({ bottom: 2 })
              }
              .width(34)
              .height(40)
              .alignItems(VerticalAlign.Bottom)
              .justifyContent(FlexAlign.Center)
            }

            Text(this.signStatus(index) === SignStatus.EXPIRED ? '已过期' : `第${index + 1}天`)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor(
                this.signStatus(index) === SignStatus.EXPIRED ?
                  $r('sys.color.font_secondary') : $r('sys.color.font_primary'),
              )
          }
        }, (item: number) => JSON.stringify(item))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)

      Button(this.isTodaySigned ? '已签到' : '立即签到')
        .width('100%')
        .enabled(!this.isTodaySigned)
        .backgroundColor(this.isTodaySigned ? '#999' : $r('sys.color.font_emphasize'))
        .onClick(() => {
          this.handleSign()
        })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      top: 16,
      bottom: 12,
      left: 12,
      right: 12,
    })
    .margin({ top: 12 })
  }

  @Builder
  tabBtnBuilder() {
    Row({ space: 12 }) {
      TabBtnItem({
        label: '优惠券',
        index: 0,
        curIndex: this.curTabBtnIndex,
        onChange: (idx: number) => {
          this.curTabBtnIndex = idx;
        },
      })
      TabBtnItem({
        label: '日常任务',
        index: 1,
        curIndex: this.curTabBtnIndex,
        onChange: (idx: number) => {
          this.curTabBtnIndex = idx;
        },
      })
    }
    .width('100%')
    .margin({ top: 12 })
  }
}

@ComponentV2
struct TabBtnItem {
  @Param label: string = '';
  @Param index: number = 0;
  @Param curIndex: number = 0;
  @Event onChange: (index: number) => void;

  build() {
    Button() {
      Text(this.label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(this.index === this.curIndex ? 500 : 400)
        .lineHeight(19)
        .fontColor(this.index === this.curIndex ? $r('sys.color.white') : $r('sys.color.font_primary'))
    }
    .width(72)
    .height(28)
    .backgroundColor(this.index === this.curIndex ?
      $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.onChange(this.index)
    })
  }
}