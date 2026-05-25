import { GridRowColSetting, Logger, MockService } from 'external_interactions';
import { VipRechargeItem } from '../utils/VipRechargeItem';
import { VipRechargeDataSource } from '../utils/VipRechargeDataSource';
import { promptAction } from '@kit.ArkUI';
import { RechargeConfig } from '../constant/Constant'
import { RechargeRouteParam } from '../constant/Constant'
import { TitleBar } from './TitleBar';

const TAG: string = '[Recharge]';

@ComponentV2
export struct Recharge {
  @Local topRectHeight: number = 100;
  @Local bottomRectHeight: number = 0;
  @Local stackAnimated: boolean = true
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  private swiperController: SwiperController = new SwiperController()
  private data: VipRechargeDataSource = new VipRechargeDataSource()
  @Local pay: number = 0;
  @Local swiperReset: boolean = false;
  @Local selectedIndex: number = -1;
  @Local balance: number = 0
  discount: number = 1
  @Param @Once rechargeConfigs: RechargeConfig[] = []
  private fromCard: boolean = false
  handleBack: (balance: number) => void = (balance: number) =>{}
  @Local confirm: boolean = false
  // 密码数组（6位）
  @Local private passwordArr: string[] = ['', '', '', '', '', ''];
  // 当前聚焦的格子索引
  @Local private focusIndex: number = -1;
  @Local password: string = '';
  private keyBoardData: string[][] = [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['', '0', '删除']];
  // 阴影样式常量
  private buttonShadow: ShadowOptions = {
    color: '#000000', // 浅黑色半透明（阴影颜色，1A为透明度）
    offsetX: 0,         // 水平偏移：0（仅向下偏移）
    offsetY: 2,         // 垂直偏移：2vp（下阴影）
    radius: 1,      // 模糊半径：4vp（阴影柔和度）
  };

  aboutToAppear(): void {
    if(this.rechargeConfigs.length === 0){
      this.rechargeConfigs = [
        {payNumber: 500, discounts: 50},
        {payNumber: 1000, discounts: 150},
        {payNumber: 2000, discounts: 350},
        {payNumber: 3000, discounts: 550},
        {payNumber: 4000, discounts: 750},
        {payNumber: 5000, discounts: 1000},
      ]
    }
  }

  /**
   * 处理TextInput输入变化
   * @param value 输入的完整字符串
   */
  private handleInputChange(value: string): void {
    // 删除键逻辑
    if (value === '删除') {
      this.passwordArr[this.focusIndex] = '';
      // 从当前聚焦位向前删除
      if (this.focusIndex >= 0) {
        this.focusIndex--;
      }
      return;
    }

    this.focusIndex++;
    // 数字键逻辑（仅当前聚焦位未输入时赋值）
    if (this.focusIndex < 6 && this.passwordArr[this.focusIndex] === '') {
      this.passwordArr[this.focusIndex] = value;
      if(this.focusIndex === 5) {
        // 6位密码输入完成，触发回调
        const fullPassword = this.passwordArr.join('');
        this.password = fullPassword
      }
    } else {
      this.focusIndex = 5;
    }
  }

  @Builder
  sheetTitleBuilder() {
    Text('健身模板')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
  }

  @Builder
  huaweiIAP() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.icon_vip'))
            .width(44)
            .margin({ right: 16 })
          Text('会员充值')
            .fontSize(16)
            .fontWeight(500)
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Divider()
          .margin({ top: 10, bottom: 10 })

        Row() {
          Text('￥')
            .fontColor($r('sys.color.font_primary'))
            .fontSize(24)
            .fontWeight(700)
            .textAlign(TextAlign.Start)
          Text(this.pay.toFixed(2).toString())
            .fontColor($r('sys.color.font_primary'))
            .fontSize(36)
            .fontWeight(700)
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Divider()
          .margin({ top: 10, bottom: 10 })

        Row() {
          Text('账号: ')
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize(12)

          Text(MockService.account.phone)
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize(12)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('90%')
      .height(182)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .margin({ left: 16, right: 16 })
      .padding({ top: 16, bottom: 16, left: 12, right: 12 })

      Column() {
        // 标题
        Text('输入数字密码完成购买')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Medium)
          .margin({ top: 24, bottom: 12 });

        // 密码格子区域
        Row({ space: 12 }) {
          ForEach(this.passwordArr, (item: string, index: number) => {
            // 单个密码格子
            Stack() {
              // 密码圆点（输入后显示）
              if (item) {
                Circle()
                  .fill(Color.Black)
                  .size({ width: 16, height: 16 });
              }
            }
            .width(40)
            .height(40)
            .border({
              width: 2,
              color: this.focusIndex === index ? '#007DFF' : Color.Transparent,
              radius: 8
            })
            .backgroundColor($r('sys.color.background_secondary'))
          }, (item: string) => item)
        }
        .margin({ bottom: 10 });
      }
      .height(119)
      .width('100%')
      .backgroundColor($r('sys.color.background_primary'))

        // 自定义数字键盘区域
      Column() {
        ForEach(this.keyBoardData, (row: string[]) => {
          Row({ space: 5 }) {
            ForEach(row, (key: string) => {
              // 数字键/删除键按钮
              Button(key)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .width('33%')
                .height(48)
                .borderRadius(8)
                .shadow(this.buttonShadow)
                .onClick(() => {
                  if (key !== '') {
                    this.handleInputChange(key)
                    if (this.password.length === 6) {
                      this.confirm = false
                      this.balance += this.fromCard ? this.getTotalMoneyFromCard() : this.getTotalMoney()
                      this.handleBack(this.balance)
                      this.pathStack.pop()
                      this.fromCard = false
                    }
                  }
                })
                // 删除键样式区分
                .backgroundColor((key === '删除' || key === '') ? 'rgba(188, 192, 199, 1)'
                  : $r('sys.color.comp_background_primary'))
                .fontSize(16);
            }, (key: string) => key)
          }
          .margin({top: 10})
        }, (row: string[]) => JSON.stringify(row))
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 16
      })
      .backgroundColor($r('sys.color.comp_background_gray'))
      .width('100%')
      .justifyContent(FlexAlign.Center);
    }
    .margin({ bottom: 28 })
    .backgroundColor($r('sys.color.background_primary'))
  }

  build() {
    NavDestination() {
      TitleBar({ title: '会员充值',
        onBackClick: ()=>{
          this.handleBack(this.balance)
          this.pathStack.pop()
        }
      })
        .margin({ left: 16, right: 16 })

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          Column() {
            Stack() {
              Scroll() {
                Column({ space: 16 }) {
                  Row() {
                    Image($r('app.media.ic_vipIcon'))
                      .width(44)
                      .height(38)
                    Text('会员余额：' + this.balance + '元')
                      .fontSize(14)
                      .margin({ left: 16 })
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                  .borderRadius(16)
                  .backgroundColor($r('sys.color.comp_background_list_card'))
                  .padding(16)

                  Column() {
                    Text('充值金额')
                      .fontWeight(FontWeight.Bold)
                      .fontSize(14)
                      .alignSelf(ItemAlign.Start)
                    Row() {
                      Image($r('app.media.chevron_left'))
                        .width(13)
                        .height(13)
                        .onClick(() => {
                          this.swiperController.showPrevious()
                        })
                      Swiper(this.swiperController) {
                        LazyForEach(this.data, (item: VipRechargeItem, index: number) => {
                          ListItem() {
                            Column() {
                              Text(item.getPayNumber() + '元')
                                .fontSize(14)
                                .fontWeight(FontWeight.Bold)
                              Text('立赠' + item.getDiscounts())
                                .fontSize(14)
                                .fontWeight(FontWeight.Bold)
                            }
                            .justifyContent(FlexAlign.SpaceAround)
                            .width(item.getPayNumber() >= 5000 ? 70 : 62)
                            .height(80)
                            .border(this.selectedIndex === index ? { width: 1, color: '#ED6F21', radius: 4 } : { width: 0 })
                            .backgroundImage($r('app.media.ic_recharge_bg'))
                            .backgroundImageSize({ width: '90%', height: '90%' })
                            .backgroundImagePosition(Alignment.Center)
                            .onClick(() => {
                              this.selectedIndex = index;
                              this.pay = item.getPayNumber();
                              this.fromCard = true;
                            })
                          }
                        })
                      }
                      .cachedCount(3)
                      .autoPlay(false)
                      .loop(false)
                      .itemSpace(0)
                      .displayCount(3)
                      .effectMode(EdgeEffect.Spring)
                      .indicator(false)
                      .onChange((index: number) => {
                        Logger.info(TAG, `onChange current index: ${JSON.stringify(index)}`)
                        this.swiperController.changeIndex(index)
                      })
                      .onGestureSwipe(() => {
                        this.swiperReset = false;
                      })
                      .onAnimationStart((index: number, targetIndex: number) => {
                        if (index !== targetIndex) {
                          this.swiperReset = true;
                        }
                      })
                      .curve(Curve.Smooth)
                      .layoutWeight(1)

                      Image($r('app.media.chevron_right'))
                        .width(13)
                        .height(13)
                        .onClick(() => {
                          this.swiperController.showNext()
                        })
                    }
                    .width('100%')
                    .height(80)
                    .margin({ top: 16, bottom: 20 })
                    .justifyContent(FlexAlign.SpaceBetween)
                    Row() {
                      Image($r('app.media.ic_rmb'))
                        .height(32)
                        .width(15)
                        .objectFit(ImageFit.Auto)
                      TextInput({ placeholder: '请输入充值金额', text: this.pay === 0 ? '' : this.pay.toString() })
                        .type(InputType.Number)
                        .placeholderFont({ size: $r('sys.float.Body_L') })
                        .placeholderColor($r('sys.color.font_secondary'))
                        .width('60%')
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .backgroundColor(Color.White)
                        .maxLength(4)
                        .onChange((value) => {
                          if (value) {
                            let numValue = Number.parseInt(value);
                            if (numValue > 5000) {
                              this.pay = 5000;
                            } else {
                              this.pay = numValue;
                            }
                          } else {
                            this.pay = 0;
                          }
                        })
                        .onWillInsert((info: InsertValue) => {
                          let numValue = Number.parseInt(this.pay + info.insertValue)
                          if (numValue > 5000) {
                            this.pay = 5000;
                            this.getUIContext().getPromptAction().showToast({ message: '单次充值不超过5000元' })
                          }
                          return true;
                        })
                    }
                    .alignItems(VerticalAlign.Center)
                    .width('100%')
                    Divider()
                    Row() {
                      Text('支付' + this.pay + '元')
                        .fontSize(14)
                      Text('实际到账' + (this.fromCard ? this.getTotalMoneyFromCard() : this.getTotalMoney()) + '元')
                        .fontSize(14)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .visibility(this.pay > 0 ? Visibility.Visible : Visibility.None)
                    .margin({ top: 16 })
                  }
                  .width('100%')
                  .borderRadius(16)
                  .backgroundColor($r('sys.color.comp_background_list_card'))
                  .padding(16)

                  Row() {
                    Row() {
                      Image($r('app.media.HUAWEI_pay'))
                        .width(48)
                        .height(48)
                      Text('华为支付')
                        .fontSize(16)
                        .margin({ left: 16 })
                        .fontWeight(FontWeight.Bold)
                    }

                    Checkbox({ name: 'HUAWEI_pay' })
                      .select(this.pay > 0)
                  }
                  .justifyContent(FlexAlign.SpaceBetween)
                  .width('100%')
                  .borderRadius(20)
                  .backgroundColor($r('sys.color.comp_background_list_card'))
                  .padding(12)
                }
              }
              .scrollBar(BarState.Off)
              .margin({ left: 16, right: 16 })
            }
            .layoutWeight(1)
            .alignContent(Alignment.Top)

            Row() {
              Text('需支付：' + this.pay + '元')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .width('40%')
                .height('60%')
                .textAlign(TextAlign.Start)
                .margin({ left: 16 })
              Button('确认充值')
                .width('50%')
                .height('60%')
                .fontColor($r('sys.color.comp_background_list_card'))
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_M'))
                .backgroundColor('#FF9019')
                .onClick(() => {
                  this.confirm = this.pay > 0
                })
                .bindSheet($$this.confirm, this.huaweiIAP(), {
                  preferType: SheetType.CENTER,
                  title: this.sheetTitleBuilder(),
                  height: SheetSize.FIT_CONTENT,
                  showClose: true,
                  enableOutsideInteractive: false,
                  backgroundColor: $r('sys.color.background_primary'),
                  blurStyle: BlurStyle.COMPONENT_THICK,
                  onWillDismiss: ((action: DismissSheetAction) => {
                    // exit event listener
                    // 传入一个回调函数 ， 成功充值后，调用父组件的回调函数更新用户余额
                    if (this.pay > 0) {
                      this.confirm = false
                    } else {
                      this.getUIContext().getPromptAction().showToast({ message: '请输入金额' })
                    }
                  }),
                })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .height(75)
            .width('100%')
            .padding({ bottom: 10 })
            // .backgroundColor(Color.White)
            .margin({ bottom: 60 })
          }
        }
      }
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
        this.pathStack = ctx.pathStack;
        const param = ctx.pathInfo.param as RechargeRouteParam
        this.balance = param?.balance ?? 0
        if(param?.rechargeConfigs !== undefined){
          this.rechargeConfigs = param?.rechargeConfigs
        }
        this.balance = param?.balance
        this.data.initData(this.rechargeConfigs)
        if(param?.handleBack !== undefined) {
          this.handleBack = param?.handleBack
        }
    })

    .onBackPressed(() => {
      this.pathStack.pop(this.stackAnimated)
      if (!this.stackAnimated) {
        this.stackAnimated = true
      }
      return true;
    })
    .backgroundColor('#F1F3F5')
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }

  getTotalMoney(): number {
    if (this.pay >= 5000) {
      return Math.floor((this.pay + 1000) / this.discount)
    } else if (this.pay >= 4000) {
      return Math.floor((this.pay + 750) / this.discount)
    } else if (this.pay >= 3000) {
      return Math.floor((this.pay + 550) / this.discount)
    } else if (this.pay >= 2000) {
      return Math.floor((this.pay + 350) / this.discount)
    } else if (this.pay >= 1000) {
      return Math.floor((this.pay + 150) / this.discount)
    } else if (this.pay >= 500) {
      return Math.floor((this.pay + 50) / this.discount)
    } else {
      return Math.floor(this.pay / this.discount)
    }
  }

  getTotalMoneyFromCard(): number{
    return this.rechargeConfigs[this.selectedIndex].discounts + this.pay
  }
}


