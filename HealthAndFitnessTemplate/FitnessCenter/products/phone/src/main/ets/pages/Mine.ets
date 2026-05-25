import { RechargeRouteParam } from 'module_recharge'
import { MockService,
  UserCard,
  BreakpointNameEnum,
  BreakpointModel,
  GridSettingInfo,
  ScreenPropStorage,
  AccountUpdate,
  LoginState,
  GlobalBalance,
  CardManager,
  Logger} from 'external_interactions';
import { AppStorageV2 } from '@kit.ArkUI';
import { MineVM } from '../viewmodels/MineVM';
import { AtomicserviceLogin, ApiController, UserInfo } from 'atomicservice_login';

@ComponentV2
export struct Mine {
  @Local userInfo: UserInfo = new UserInfo()
  @Local isLink: boolean = false
  @Local controller: ApiController = new ApiController()
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local accountUpdateStorage : AccountUpdate = AppStorageV2.connect(AccountUpdate, 'AccountUpdate', () =>new AccountUpdate())!
  @Local loginStateStorage : LoginState = AppStorageV2.connect(LoginState, 'LoginState', () => new LoginState())!
  @Local globalBalance : GlobalBalance = AppStorageV2.connect(GlobalBalance, 'GlobalBalance', () => new GlobalBalance())!
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  @Local navPathStack: NavPathStack = new NavPathStack();
  @Local cardCount: number = 0
  @Local currentBalance: number = 0
  @Local update: boolean = false
  @Local cardNumber: string = '';
  vm: MineVM = MineVM.instance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.refreshUserInfo()
    this.getUIContext().getHostContext()?.eventHub.on('refreshUserInfo', () => {
      this.userInfo.avatar = MockService.account.avatar
      this.userInfo.phoneNumber = MockService.account.phone
      this.userInfo.userName = MockService.account.nickname
    })
    let userCard: UserCard[] = MockService.userCardList
    let cnt: number = 0;
    for(let i = 0; i < userCard.length; i++){
      if(MockService?.userCardCanUse(userCard[i]) === true){
        cnt += 1;
      }
    }
    this.cardCount = cnt;
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()?.eventHub.off('refreshUserInfo')
  }

  @Monitor('accountUpdate', 'this.loginStateStorage.loginState')
  refreshUserInfo() {
    this.accountUpdateStorage.accountUpdate = !this.accountUpdateStorage.accountUpdate
    this.userInfo.avatar = MockService.account.avatar
    this.userInfo.phoneNumber = MockService.account.phone
    this.userInfo.userName = MockService.account.nickname
    this.cardCount =
      this.loginStateStorage.loginState ?
        MockService.userCardList.filter
        ((item) => MockService.userCardCanUse(item)).length : 0
  }

  @Computed
  get gridSetting() {
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 12,
      rowGap: 12,
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 16
    }
    return gridSettingInfo
  }

  @Computed
  get listLanes() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint as BreakpointNameEnum)) {
      return 1;
    }
    return 2;
  }

  unBindPhone = async (): Promise<void> => {
    this.isLink = false
    this.loginStateStorage.loginState = false
    this.userInfo = new UserInfo()
  }

  @Builder
  entryBuilder(imgStr: string, text: string, pagePath: string) {
    Column() {
      Image($r(imgStr))
        .width(40)
        .width(40)
        .margin({ bottom: 4 })
      Text(text)
        .fontSize(12)
        .opacity(0.9)
    }.onClick(() => {
      if(this.loginStateStorage.loginState === false){
        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
      } else {
        if(pagePath === 'vip/VipRecharge'){
          this.pathStack.pushPath({
            name: 'vip/VipRecharge',
            param: {
              balance: MockService.account.balance,
              handleBack: (balance: number) => {
                MockService.account.balance = balance;
                MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account));
                MockService.dataPreferences.flush();
                this.globalBalance.globalBalance = balance
                this.accountUpdateStorage.accountUpdate = !this.accountUpdateStorage.accountUpdate
                this.update = !this.update
              }
            } as RechargeRouteParam
          });
        }else{
          if (this.loginStateStorage.loginState) {
            this.pathStack.pushPath({name: pagePath})
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
          }
        }
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .width('100%')
      }
      .justifyContent(FlexAlign.Start)
      .height(40)
      .margin({
        top: 8,
        bottom: 8,
        left: 16,
        right: 16
      })

        Scroll() {
          Column({ space: 16 }) {
            // 登录 & vip
            Grid() {
              GridItem() {
                Column() {
                  AtomicserviceLogin({
                    userInfo: this.userInfo,
                    isLink: this.isLink,
                    controller: this.controller,
                    bindPhone: (code: string | undefined) => {
                      this.isLink = true
                      this.userInfo.userName = '大王'
                      this.userInfo.avatar = $r('app.media.avatar_login')  // todo 替换为开发者需要的资源
                      MockService.saveAccountInfo(this.userInfo.userName, '', '', '', this.userInfo.avatar);
                      this.getUIContext().getPromptAction().showToast({message: '请通过临时关联账号凭证获取真实手机号'})
                    },
                    onGetPhoneError: (err) => {
                      if (err.code) {
                        Logger.info('MockLogin', `GetPhoneError. error code: ${JSON.stringify(err.code)}`)
                        this.getUIContext().getPromptAction().showToast({message: '元服务未获取phone权限或用户授权，此为模拟关联。'})
                        this.isLink = true
                        this.loginStateStorage.loginState = true
                        this.userInfo.phoneNumber = '130****0000'
                        this.userInfo.userName = '大王'
                        this.userInfo.avatar = $r('app.media.avatar_login')  // todo 替换为开发者需要的资源
                        MockService.saveAccountInfo(this.userInfo.userName, this.userInfo.phoneNumber, '', '',
                          this.userInfo.avatar);
                        CardManager.get().updateCard()
                      }
                    },
                    unBindPhone: this.unBindPhone,
                  })
                }
                .backgroundColor(Color.White)
                .borderRadius(16)
              }

              GridItem() {
                Row() {
                  Row() {
                    Text('卡号: ' + (this.loginStateStorage.loginState ? '0897' : '无'))
                      .fontSize(18)
                      .margin({ left: 12, right: 12 })

                    Image($r('app.media.qr_icon'))
                      .width(24)
                      .height(24)
                      .visibility(this.loginStateStorage.loginState ? Visibility.Visible : Visibility.None)
                      .onClick(() => {
                        if (this.loginStateStorage.loginState) {
                          this.pathStack.pushPath({name: 'userInfo/qrCode'})
                        }
                      })
                  }

                  Column() {
                    Button() {
                      Row() {
                        Text('前往充值')
                          .fontColor($r('sys.color.font_on_primary'))
                          .fontSize($r('sys.float.Body_M'))
                          .fontWeight(FontWeight.Medium)
                      }
                      .onClick(() => {
                        if(this.loginStateStorage.loginState === false){
                          this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                        } else {
                          this.pathStack.pushPath({
                            name: 'vip/VipRecharge',
                            param: {
                              balance: MockService.account.balance,
                              handleBack: (balance: number) => {
                                MockService.account.balance = balance;
                                MockService.dataPreferences.putSync('account', JSON.stringify(MockService.account));
                                MockService.dataPreferences.flush();
                                this.globalBalance.globalBalance = balance
                                this.accountUpdateStorage.accountUpdate = !this.accountUpdateStorage.accountUpdate
                                this.update = !this.update
                              }
                            } as RechargeRouteParam
                          });
                        }
                      })
                    }
                    .width(72)
                    .height(28)
                    .borderRadius($r('sys.float.corner_radius_level8'))
                    .backgroundColor('#FF9019')
                  }
                  .margin({ right: 12 })
                }
                .width('100%')
                .height(80)
                .borderRadius(16)
                .backgroundImage(this.vm.gridCount === 2 ? $r('app.media.vip_background') :
                  $r('app.media.vip_large_background'))
                .backgroundImageSize(ImageSize.FILL)
                .justifyContent(FlexAlign.SpaceBetween)
              }
            }
            .columnsTemplate(this.gridSetting.template)
            .columnsGap(this.gridSetting.colGap)
            .rowsGap(this.gridSetting.rowGap)

            Column() {
              List() {
                ListItem() {
                  CardItem({
                    img: $r('app.media.creditcard'),
                    label: '我的卡项',
                    onClickEvent: () => {
                      if (this.loginStateStorage.loginState) {
                        this.pathStack.pushPath({ name: 'card/userCards' })
                      } else {
                        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                      }
                    }
                  })
                }
                ListItem() {
                  CardItem({
                    img: $r('app.media.arrow_counterclockwise_clock'),
                    label: '预约记录',
                    onClickEvent: () => {
                      if (this.loginStateStorage.loginState) {
                        this.pathStack.pushPath({name: 'course/BookingRecord'})
                      } else {
                        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                      }
                    }
                  })
                }
                ListItem() {
                  CardItem({
                    img: $r('app.media.course'),
                    label: '我的课程',
                    onClickEvent: () => {
                      if (this.loginStateStorage.loginState) {
                        this.pathStack.pushPath({name: 'course/UserCourses'})
                      } else {
                        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                      }
                    }
                  })
                }
                ListItem() {
                  CardItem({
                    img: $r('app.media.text_clipboard'),
                    label: '我的订单',
                    onClickEvent: () => {
                      if (this.loginStateStorage.loginState) {
                        this.pathStack.pushPath({name: 'card/order'})
                      } else {
                        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                      }
                    }
                  })
                }
              }
              .lanes(this.listLanes)
              .divider({
                strokeWidth: '1px',
                color: $r('sys.color.comp_divider'),
                startMargin: 28,
                endMargin: 28,
              })
            }
            .borderRadius(20)
            .backgroundColor(Color.White)

            Column() {
              List() {
                ListItem() {
                  CardItem({
                    img: $r('app.media.doc_plaintext_and_pencil'),
                    label: '意见反馈',
                    onClickEvent: () => {
                      if (this.loginStateStorage.loginState) {
                        this.pathStack.pushPath({name: 'FeedbackSubmitPage'})
                      } else {
                        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                      }
                    }
                  })
                }

                ListItem() {
                  CardItem({
                    img: $r('app.media.gearshape'),
                    label: '设置',
                    onClickEvent: () => {
                      if (this.loginStateStorage.loginState) {
                        this.pathStack.pushPath({ name: 'SettingPage', param: this.pathStack })
                      } else {
                        this.getUIContext().getPromptAction().showToast({ message: '请先关联账号' })
                      }
                    }
                  })
                }
              }
              .lanes(this.listLanes)
              .divider({
                strokeWidth: '1px',
                color: $r('sys.color.comp_divider'),
                startMargin: 28,
                endMargin: 28,
              })
            }
            .borderRadius(20)
            .backgroundColor(Color.White)
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
        .margin({ left: 16, right: 16 })
    }
    .padding({ top: this.getUIContext().px2vp(this.screenPropStorage.topRectHeight) })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}

@ComponentV2
struct CardItem {
  @Param @Require label: ResourceStr
  @Param @Require img: ResourceStr
  @Event onClickEvent: () => void = () => {}

  build() {
    Row() {
      Row() {
        Image(this.img)
          .width(24)
          .height(24)
          .margin({ left: 12 })
        Text(this.label)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 12 })
      }
      Image($r('app.media.right_arrow'))
        .width(16)
        .height(16)
        .fillColor($r('sys.color.icon_primary'))
        .margin({ right: 12 })
    }
    .width('100%')
    .height(56)
    .padding({ top:14, bottom:14})
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.onClickEvent?.()
    })
  }
}