import {
  BreakpointModel,
  BreakpointNameEnum,
  CardInfo, ConsumeType, CourseDetailModel, DateUtil,
  JumpLogin,
  LoginState,
  MockService,
  OrderState,
  UserCard,
  GridSettingInfo,
  ScreenPropStorage,
  AccountUpdate,
  BookJumpSearch,
  EmitterConstant,
  Logger} from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { display } from '@kit.ArkUI';
import { DialPanel } from 'dial_panel';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

const TAG: string = '[CourseDetail]';

@ComponentV2
export struct CourseDetail {
  @Local screenPropStorage: ScreenPropStorage =
    AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () => new ScreenPropStorage())!
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () =>new LoginState())!
  @Local loginState: boolean = this.loginStateStorage.loginState;
  @Local jumpLoginStorge : JumpLogin = AppStorageV2.connect(JumpLogin, 'JumpLogin', () =>new JumpLogin())!
  @Local jumpLogin: boolean = this.jumpLoginStorge.jumpLogin
  @Local bookJumpSearchStorage : BookJumpSearch = AppStorageV2.connect(BookJumpSearch, 'BookJumpSearch', () =>new BookJumpSearch())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Param @Once courseDetail: CourseDetailModel | undefined = undefined;
  listScroller: ListScroller = new ListScroller()
  @Local cardList: CardInfo[] = []
  @Local userCardList: UserCard[] = []
  @Local hasBuyCard: boolean = false
  @Local windowWidth: number = 0;
  @Local selectedCardId: string = '';
  @Local selectedCardIndex: number = -1;
  @Local selectedCard: CardInfo = new CardInfo('', 0, '', '', '', '', [], '', '', 1, 0, 0, 0 )
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  private uiContext: UIContext = this.getUIContext();

  private dialPanel: DialPanel = new DialPanel(this.uiContext)
    .onMakeCall((e: BusinessError<void>): void => {
      if (e.code) {
        this.showToast(`拨号页面跳转失败 -> code: ${e.code}, msg: ${e.message}`);
      }
    })
    .onWillDismiss((reason: DismissReason): void => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else if (reason === DismissReason.SLIDE_DOWN) {
        this.showToast('已拦截下拉模态窗进行关闭的交互方式');
      } else {
        this.dialPanel.close();
      }
    });

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

  isMDorLGorXL() {
    return [BreakpointNameEnum.MD, BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(
      this.breakPointModel.currentBreakpoint)
  }

  isLGorXL() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)
  }

  @Builder
  courseBasicBuilder() {
    if (this.courseDetail) {
      Column() {
        Image($r(this.courseDetail.advImage))
          .width('100%')
          .height(this.isMDorLGorXL() ? 248 : 132)
          .borderRadius(16)
          .margin({ bottom: this.isLGorXL() ? 100 : 16 })
        Column() {
          Text(this.courseDetail.courseName)
            .textAlign(TextAlign.Start)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ bottom: 16 })
          Text('¥' + this.courseDetail.price.toString())
            .textAlign(TextAlign.Start)
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .width('100%')
        }
      }
      .justifyContent(FlexAlign.End)
      .height(this.isLGorXL() ? '100%' : '')
      .width('100%')
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding(16)
    }
  }

  @Builder
  cardShowBuilder() {
    Column() {
      // 已购卡项或推荐卡项，根据是否已买卡展示不同内容
      if (this.hasBuyCard) {
        Text('已购卡项')
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .width('100%')
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })
        ForEach(this.userCardList, (userCard: UserCard, index: number) => {
          Divider()
            .margin({ bottom: 10 })
            .visibility(index !== 0 ? Visibility.Visible : Visibility.None)
          this.hasBuyCardBuilder(userCard, MockService.getCardById(userCard.cardId), index)
        }, (item: CardInfo) => JSON.stringify(item))
      } else {
        Text('推荐卡项')
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .width('100%')
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })
        ForEach(this.cardList, (userCard: CardInfo, index: number) => {
          Divider()
            .margin({ bottom: 10 })
            .visibility(index !== 0 ? Visibility.Visible : Visibility.None)
          this.recommendCardBuilder(MockService.getCardById(userCard.id), index)
        }, (item: CardInfo) => JSON.stringify(item))
      }
    }
    .visibility(this.userCardList.length !== 0 || this.cardList.length !== 0 ? Visibility.Visible : Visibility.None)
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(16)
  }

  @Builder
  recommendCardBuilder(userCard: CardInfo, index: number) {
    Row() {
      // 添加单选框组件
      Checkbox({ name: userCard?.id })
        .select(this.selectedCardId === userCard?.id)
        .onChange((checked: boolean) => {
          if (checked) {
            this.selectedCardId = userCard?.id; // 更新选中状态
            this.selectedCard = JSON.parse(JSON.stringify(userCard)) as CardInfo
            this.selectedCardIndex = index;
          } else {
            if (this.selectedCardId === userCard?.id) {
              this.selectedCardId = '';
              this.selectedCardIndex = -1;
              if (this.courseDetail) {
                this.selectedCard.id = ''
                this.selectedCard.price = this.courseDetail?.price as number
                this.selectedCard.advImage = this.courseDetail?.advImage as string
                this.selectedCard.name = this.courseDetail?.courseName as string
                this.selectedCard.avaiCourse = this.courseDetail?.id as string
              }
            }
          }
        })
        .margin({ right: 12 })
      Image($r(userCard?.advImage))
        .width(80)
        .height(80)
        .borderRadius(8)
      Column() {
        Text(userCard?.name)
          .fontSize(14)
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Bold)
        Row() {
          Text(userCard?.consumeType === ConsumeType.TIMES ? userCard?.quota + '次' :
            MockService.getQuotaDurationDesc(userCard?.quota) + '卡')
            .fontSize(14)
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Medium)
          Text('¥' + userCard?.price.toString())
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.End)
            .fontSize(14)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height('100%')
      .layoutWeight(1)
      .margin({ left: 16 })
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.jumpToCard(userCard)
      })
    }
    .height(80)
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .margin({ bottom: (index !== this.cardList.length - 1) ? 10 : 0 })
  }

  @Builder
  hasBuyCardBuilder(userCard: UserCard, card: CardInfo, index: number) {
    Row() {
      Image($r(card.advImage))
        .width(80)
        .height(80)
        .borderRadius(8)
      Column() {
        Text(card.name)
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Row() {
          Text(card.consumeType === ConsumeType.TIMES ? card.quota + '次' :
            MockService.getQuotaDurationDesc(card.quota) + '卡')
            .textAlign(TextAlign.Start)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          Text(card.consumeType === ConsumeType.TIMES ? '剩余' + userCard.restQuota + '次' :
            '到期时间:' + DateUtil.formatDate(MockService.getCardExpireDate(userCard)))
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })
      .height('100%')
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height(80)
    .margin({ bottom: (index !== this.cardList.length - 1) ? 10 : 0 })
    .onClick(() => {
      this.jumpToCard(card)
    })
  }

  @Builder
  serviceDetailBuilder() {
    if (this.courseDetail) {
      Column() {
        Text('服务详情')
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .width('100%')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })
        Text(this.courseDetail.serviceDetail)
          .textAlign(TextAlign.Start)
          .align(Alignment.Top)
          .fontSize(12)
          .width('100%')
          .fontColor(Color.Black)
          .opacity(0.6)
          .fontWeight(FontWeight.Regular)
      }
      .width('100%')
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .padding(16)
      .margin({ bottom: 10 })
    }
  }

  aboutToAppear(): void {
    this.registerWindowChangeListener();
    try {
      this.windowWidth = this.getUIContext().px2vp(display.getDefaultDisplaySync().width)
    } catch (error) {
      Logger.info(TAG, `get display class false ${JSON.stringify(error)}`);
    }
  }

  registerWindowChangeListener() {
    try {
      window.getLastWindow(this.context).then((win: window.Window) => {
        win.on('windowSizeChange', (data: window.Size) => {
          Logger.info(TAG, `Window size changed: ${JSON.stringify(data.width)}, ${JSON.stringify(data.height)}`);
          this.windowWidth = this.getUIContext().px2vp(data.width);
        });

      })
    } finally {

    }
  }

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 16,
    }
    if (this.isLGorXL()) {
      gridSettingInfo.template = '1fr 1fr'
    }
    return gridSettingInfo
  }

  build() {
    NavDestination() {
      TitleBar({
        title: '课程详情', onBackClick: () => {
          this.pathStack.pop()
        }
      })
        .margin({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 16 }) {
          Grid() {
            GridItem() {
              // 课程图片轮播，价格展示
              this.courseBasicBuilder()
            }
            GridItem() {
              Column({ space: 12 }) {
                // 展示卡项
                this.cardShowBuilder()
                // 服务详情
                this.serviceDetailBuilder()
              }
            }
          }
          .columnsTemplate(this.gridSetting.template)
          .columnsGap(this.gridSetting.colGap)
          .rowsGap(this.gridSetting.rowGap)
        }
        .justifyContent(FlexAlign.Start)
        .margin({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)

      // 下方咨询和跳转预约
      Row() {
        Row() {
          Column() {
            Image($r('app.media.consult'))
              .height(24)
              .width(24)
              .objectFit(ImageFit.Cover)
            Text($r('app.string.Consultation'))
              .fontSize(10)
              .fontWeight(FontWeight.Medium)
              .opacity(0.6)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.dialPanel
              .setTitle('联系客服')
              .setPhoneNumber('0000-00000000')
              .setAutoClosePanel(false) // 成功跳转后不自动关闭模态窗
              .open();
          })
        }
        .margin({ left: 24 })
        .width('20%')
        .height('60%')

        Button(this.hasBuyCard ? '立即预约' : '立即购买', { type: ButtonType.Capsule, stateEffect: true })
          .width('70%')
          .height('60%')
          .margin({ right: 24 })
          .fontColor($r('sys.color.comp_background_list_card'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .backgroundColor('#FF9019')
          .borderRadius(8)
          .onClick(() => {
            if (this.hasBuyCard) {
              // 单击立即预约，清空路由栈，回到Index.ets页，通过全局状态存储，跳到 预约 页
              this.pathStack.clear(false)
              if (this.courseDetail) {
                AppStorage.setOrCreate<number>('selectedCardIndex', this.selectedCardIndex)
                try {
                  emitter.emit(EmitterConstant.CLICK_BOOK_DETAIL)
                } catch (e) {
                  Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                }
                this.bookJumpSearchStorage.bookJumpSearch = this.courseDetail.courseName
              }
            } else {
              if (this.loginStateStorage.loginState) {
                // todo 同步编辑倒计时时间
                let list = MockService.getOrderListByState(OrderState.TO_BE_PAY)?.filter(item =>
                MockService.getCourseById(item.bookingId!)?.courseName === this.selectedCard?.name &&
                Date.now() - DateUtil.parseDateString(item.createTime).getTime() < 20 * 60 * 1000)
                if (list.length !== 0) {
                  this.pathStack.pushPath({ name: 'card/orderDetail', param: list[0] })
                  this.getUIContext().getPromptAction().showToast({ message: '请支付已存在的订单' })
                } else {
                  if (this.selectedCardId === '') {
                    this.selectedCard.id = ''
                    this.selectedCard.price = this.courseDetail?.price as number
                    this.selectedCard.advImage = this.courseDetail?.advImage as string
                    this.selectedCard.name = this.courseDetail?.courseName as string
                    this.selectedCard.avaiCourse = this.courseDetail?.id as string
                  } else {
                    this.selectedCard = JSON.parse(JSON.stringify(MockService
                      .getCardById(this.selectedCardId))) as CardInfo
                  }
                  this.pathStack.pushPath({ name: 'card/buyCard', param: this.selectedCard })
                }
              } else {
                this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                this.jumpLogin = !this.jumpLogin
                this.pathStack.clear(false)
                if (this.courseDetail) {
                  try {
                    emitter.emit(EmitterConstant.CLICK_BOOK_DETAIL)
                  } catch (e) {
                    Logger.error(TAG, `emitter emit failed. error: ${JSON.stringify(e)}`)
                  }
                  this.bookJumpSearchStorage.bookJumpSearch = this.courseDetail.courseName
                }
              }
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .height(75)
      .width('100%')
      .padding({ bottom: 10 })
      .backgroundColor(Color.White)
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
      this.courseDetail = ctx?.pathInfo?.param as CourseDetailModel;
      this.selectedCardId = '';
      if (this.courseDetail) {
        this.selectedCard.price = this.courseDetail?.price as number
        this.selectedCard.advImage = this.courseDetail?.advImage as string
        this.selectedCard.name = this.courseDetail?.courseName as string
        this.selectedCard.avaiCourse = this.courseDetail?.id as string
      }
      this.getCardList()
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  getCardList() {
    // 用户已购卡项包含课程卡项，显示已购卡项
    MockService.userCardList.forEach((item: UserCard) => {
      if (this.courseDetail && this.courseDetail.avaiCard.includes(item.cardId) && MockService.userCardCanUse(item)) {
        this.hasBuyCard = true
        this.userCardList.push(item)
      }
    })
    // 用户未购卡项但已购课程，依然可以预约
    if (AppStorage.get(this.courseDetail?.id)) {
      this.hasBuyCard = true
    }
    // 没有可用已购卡项，显示推荐卡项
    if (!this.hasBuyCard && this.courseDetail) {
      this.courseDetail.avaiCard.forEach((item: string) => {
        this.cardList.push(MockService.getCardById(item))
      })
    }
  }

  jumpToCard(card: CardInfo) {
    let cardIndex = this.pathStack.getIndexByName('card/cardDetail')
    // 防止课程和卡项互相跳转导致路由路径过长，查找是否路由已存在，存在删除之前的页面
    if (cardIndex.length > 0) {
      this.pathStack.removeByName('card/cardDetail')
      this.pathStack.pushPath({ name: 'card/cardDetail', param: card })
    } else {
      this.pathStack.pushPath({ name: 'card/cardDetail', param: card })
    }
  }
}


