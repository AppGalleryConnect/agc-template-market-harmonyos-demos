import {
  BookJumpSearch,
  BreakpointModel,
  BreakpointNameEnum,
  CardInfo,
  ConsumeType,
  CourseDetailModel,
  DateUtil,
  EmitterConstant,
  MockService,
  UserCard,
  GridSettingInfo,
  ScreenPropStorage,
  JumpLogin,
  LoginState,
  Logger} from 'external_interactions';
import { AppStorageV2 } from '@kit.ArkUI';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { display } from '@kit.ArkUI';
import { DialPanel } from 'dial_panel';
import { BusinessError, emitter } from '@kit.BasicServicesKit';

const TAG = '[CardDetail]';

@ComponentV2
export struct CardDetail {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () =>new LoginState())!
  @Local bookJumpSearchStorage : BookJumpSearch = AppStorageV2.connect(BookJumpSearch, 'BookJumpSearch', () =>new BookJumpSearch())!
  @Local jumpLoginStorge : JumpLogin = AppStorageV2.connect(JumpLogin, 'JumpLogin', () =>new JumpLogin())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Param @Once cardInfo: CardInfo | undefined = undefined;
  courseDetail?: CourseDetailModel = undefined
  @Local purchased: boolean = false;
  @Local loginState: boolean = this.loginStateStorage.loginState;
  @Local jumpLogin: boolean = this.jumpLoginStorge.jumpLogin
  userCard: UserCard[] = []
  @Local windowWidth: number = 0;
  @Local windowHeight: number = 0;
  @Local orientation: window.Orientation = window.Orientation.PORTRAIT;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Monitor('screenPropStorage.topRectHeight', 'screenPropStorage.bottomRectHeight')
  onScreenPropStorage(mon: IMonitor) {
    this.topRectHeight = this.screenPropStorage.topRectHeight;
    this.bottomRectHeight = this.screenPropStorage.bottomRectHeight
  }

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
      // 获取窗口实例
      window.getLastWindow(this.context).then((win: window.Window) => {
        // 监听窗口尺寸变化
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
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr'
    }
    return gridSettingInfo
  }

  getImageWidth() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      return this.windowWidth/2
    }
    return this.windowWidth
  }

  @Builder
  cardBasicInfoBuilder() {
    Column() {
      if(this.cardInfo){
        Column(){
          Stack(){
            Image($r(this.cardInfo.advImage))
              .width(this.getImageWidth() - 42)
              .borderRadius(16)
              .padding({left: 5, right: 5})
            Row() {
              Text(this.cardInfo.name)
                .fontSize(20)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
            }
            .position({x: 0, y: '15%'})
            Row(){
              Text() {
                Span('¥' + this.cardInfo.price + '/')
                  .fontSize(20)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
                Span(this.cardInfo.consumeType === ConsumeType.TIMES ? this.cardInfo.quota + '次' : '不限次')
                  .fontSize(14)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Medium)
              }
            }
            .position({x: 0, y: '45%'})
            .width('100%')
            Row() {
              Text('预计可省¥' + this.cardInfo.saveMoney)
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
            }
            .position({x: 0, y: '80%'})
            Row(){
              Text('永久有效')
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
                .visibility(this.cardInfo.consumeType === ConsumeType.TIMES ? Visibility.Visible : Visibility.None)
            }
            .position({x:'100%', y: '80%'})
            .translate({x:'-100%', y:0})
          }
          .width(this.windowWidth - 20)
          .aspectRatio(1.8)
          .margin({bottom: 16})
        }
        .width('100%')

        Text(this.cardInfo.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 16 })

        Text(this.cardInfo.shortName)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 16 })
          .opacity(0.4)

        Text('¥' + this.cardInfo.price)
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 11 })

        Divider()
          .margin({ bottom: 11 })

        Text('卡项权益')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        if (this.purchased) {
          ForEach(this.userCard, (item: UserCard) => {
            Row() {
              if(this.cardInfo){
                Image($r(this.cardInfo.advImage))
                  .width(80)
                  .height(80)
                  .borderRadius(8)
                Column() {
                  Text(this.cardInfo.shortName)
                    .textAlign(TextAlign.Start)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                  this.purchasedCardRightsBuilder(item)
                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.SpaceEvenly)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 16 })
                .height('100%')
              }
            }.justifyContent(FlexAlign.Start)
            .width('100%')
            .height(80)
            .margin({ bottom: 10 })
          }, (item: UserCard) => JSON.stringify(item))
        } else {
          Row() {
            Image($r(this.cardInfo.advImage))
              .width(80)
              .height(80)
              .borderRadius(8)
            Column() {
              Text(this.cardInfo.shortName)
                .textAlign(TextAlign.Start)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
              this.notPurchasedCardRightsBuilder()
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceEvenly)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
            .height('100%')
          }.justifyContent(FlexAlign.Start)
          .width('100%')
          .height(80)
          .margin({ bottom: 10 })
        }
      }


    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(16)
  }

  @Builder
  purchasedCardRightsBuilder(userCard: UserCard) {
    if(this.cardInfo){
      Row() {
        Text(this.cardInfo.consumeType === ConsumeType.TIMES ? this.cardInfo.quota + '次' :
          MockService.getQuotaDurationDesc(this.cardInfo.quota) + '卡')
          .fontSize(14)
        Text() {
          if (this.cardInfo.consumeType === ConsumeType.TIMES) {
            Span('剩余次数:')
            Span(MockService.getUserCardById(userCard.id).restQuota.toString())
              .fontColor('#FF9019')
          } else {
            Span('到期时间:')
            Span(DateUtil.formatDate(MockService.getCardExpireDate(MockService.getUserCardById(userCard.id))))
              .fontColor('#FF9019')
          }
        }
        .fontSize(14)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder
  notPurchasedCardRightsBuilder() {
    if(this.cardInfo){
      Row() {
        Text(this.cardInfo.consumeType === ConsumeType.TIMES ?
          '¥' + (this.cardInfo.price / this.cardInfo.quota).toFixed(1) + '/次' :
          '¥' + this.cardInfo.price + '/' + MockService.getQuotaDurationDesc(this.cardInfo.quota))
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        Text('原价¥' + this.cardInfo.originPrice + '/次')
          .fontSize(12)
          .margin({ left: 12 })
      }
      .width('100%')
    }
  }

  @Builder
  courseShowBuilder() {
    Column() {
      Text('卡项课程')
        .textAlign(TextAlign.Start)
        .fontSize(14)
        .width('100%')
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 8 })
      Column() {
        Image($r(this.courseDetail?.advImage))
          .width('100%')
          .aspectRatio(2.8)
          .borderRadius({ topLeft: 8, topRight: 8 })
        Column() {
          Text(this.courseDetail?.courseName)
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 5 })
          Text('¥' + this.courseDetail?.price)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 5 })
        }
        .borderRadius({ bottomLeft: 8, bottomRight: 8 })
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(HorizontalAlign.Start)
        .shadow({
          radius: 2,
          color: '#ECECEC',
          offsetY: 5,
        })
        .width('100%')
        .height(50)
      }
      .width('50%')
      .onClick(() => {
        let cardIndex = this.pathStack.getIndexByName('course/CourseDetail')
        // 防止课程和卡项互相跳转导致路由路径过长，查找是否路由已存在，存在删除之前的页面
        if (cardIndex.length > 0) {
          this.pathStack.removeByName('course/CourseDetail')
          this.pathStack.pushPath({ name: 'course/CourseDetail', param: this.courseDetail })
        } else {
          this.pathStack.pushPath({ name: 'course/CourseDetail', param: this.courseDetail })
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(16)
  }

  @Builder
  useInstructionBuilder() {
    if(this.cardInfo){
      Column() {
        Text('使用说明')
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .width('100%')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        Text(this.cardInfo.useInstruction)
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
      .margin({ bottom: 16 })
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({ title: '卡项详情',
          onBackClick: ()=>{
            this.pathStack.pop()
          }
        })
        .margin({ left: 16, right: 16 })

        Scroll() {
          Column({ space: 16 }) {
            Grid() {
              GridItem() {
                this.cardBasicInfoBuilder()
              }
              GridItem() {
                Column({ space: 12 }) {
                  this.courseShowBuilder()
                  this.useInstructionBuilder()
                }
              }
            }
            .columnsTemplate(this.gridSetting.template)
            .columnsGap(this.gridSetting.colGap)
            .rowsGap(this.gridSetting.rowGap)
          }
          .margin({ left: 16, right: 16 })
          .justifyContent(FlexAlign.Start)
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

          Button('立即购买', { type: ButtonType.Capsule, stateEffect: true })
            .width('70%')
            .height('60%')
            .margin({ right: 24 })
            .fontColor($r('sys.color.comp_background_list_card'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_M'))
            .backgroundColor('#FF9019')
            .onClick(() => {
              if (this.loginStateStorage.loginState) {
                this.pathStack.pushPath({ name: 'card/buyCard', param: this.cardInfo })
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
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .height(75)
        .width('100%')
        .padding({ bottom: 10 })
        .backgroundColor(Color.White)
      }
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
      this.cardInfo = ctx?.pathInfo?.param as CardInfo;
      MockService.userCardList.forEach((item: UserCard) => {
        if (this.cardInfo && item.cardId === this.cardInfo.id && MockService.userCardCanUse(item)) {
          this.purchased = true
          this.userCard.push(item)
        }
      })
      this.getCourseDetail()
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  getCourseDetail() {
    if(this.cardInfo){
      this.courseDetail = MockService.getCourseById(this.cardInfo.avaiCourse)
    }
  }
}
