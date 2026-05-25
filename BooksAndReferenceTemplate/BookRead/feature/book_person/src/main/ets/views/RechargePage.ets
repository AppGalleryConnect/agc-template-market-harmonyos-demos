import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants, NavHeaderBar, TCRouter } from 'common';
import { UserInfo } from 'base_common';
import { RechargePackage, RechargeRecord } from 'common/src/main/ets/model/Member';
import { AggregatedPaymentPicker, ChannelType, MockApi } from 'aggregated_payment';
import { emitter } from '@kit.BasicServicesKit';
import { RechargeVM } from 'common/src/main/ets/viewmodel/RechargeVM';
import { RechargeRecordVM } from 'common/src/main/ets/viewmodel/RechargeRecordVM';

@Preview
@ComponentV2
export struct RechargePage {
  vm: RechargeVM = new RechargeVM();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  private promptAction = this.getUIContext().getPromptAction();

  aboutToAppear(): void {
    this.vm.getRechargePackages();
  }

  updateBookCoins(amount: number) {
    try {
      // 更新用户书币余额
      const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
      if (userInfoFromStorage) {
        const currentCoins = typeof userInfoFromStorage.bookCoins === 'number' ? userInfoFromStorage.bookCoins : 100;
        userInfoFromStorage.bookCoins = currentCoins + amount;
        AppStorage.setOrCreate('userInfo', userInfoFromStorage);
        AppStorage.setOrCreate('bookCoins', userInfoFromStorage.bookCoins);
      }
      // 触发事件通知其他页面更新余额
      emitter.emit(Constants.LOGIN_CHANGE);
    } catch (e) {
      console.error('Failed to emitter emit login change. Cause: ' + JSON.stringify(e));
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Image($r('app.media.welfare_bg'))
          .width(Constants.FULL_SIZE)

        Column() {
          NavHeaderBar({
            title: '充值',
            hasBackButton: true,
            hasBgColor: false,
            isMainPage: false,
          })

          Scroll() {
            Column() {
              Column({ space: 12 }) {
                Row() {
                  Text('选择充值套餐')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.font_primary'))

                  Text('充值记录')
                    .fontSize(14)
                    .fontColor('#E39331')
                    .onClick(() => {
                      TCRouter.push(Constants.RECHARGE_RECORD_ROUTE);
                    })
                }
                .width(Constants.FULL_SIZE)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)

                Grid() {
                  ForEach(this.vm.rechargePackages, (item: RechargePackage) => {
                    GridItem() {
                      Column({ space: 8 }) {
                        Column({ space: 4 }) {
                          Text(`${item.coins}`)
                            .fontSize(24)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(this.vm.selectId === item.id ? '#E39331' : $r('sys.color.font_primary'))

                          Text('书币')
                            .fontSize(12)
                            .fontColor($r('sys.color.font_secondary'))

                          if (item.bonus && item.bonus > 0) {
                            Text(`送${item.bonus}`)
                              .fontSize(10)
                              .fontColor('#E39331')
                          }

                          Text() {
                            Span('￥').fontSize(12)
                            Span(item.price.toString()).fontWeight(FontWeight.Bold)
                          }
                          .fontSize(16)
                          .fontColor(this.vm.selectId === item.id ? '#E39331' : $r('sys.color.font_primary'))
                          .margin({ top: 8 })
                        }
                        .padding({ top: item.isRecommended ? 16 : 20, bottom: 16 })
                        .width(Constants.FULL_SIZE)
                      }
                      .width(Constants.FULL_SIZE)
                      .height(130)
                      .backgroundColor(this.vm.selectId === item.id ? $r('sys.color.comp_background_tertiary') :
                        $r('sys.color.background_primary'))
                      .border({
                        width: this.vm.selectId === item.id ? 2 : 1,
                        color: this.vm.selectId === item.id ? '#E39331' : '#E5E5E5',
                        radius: 12,
                      })
                      .onClick(() => {
                        this.vm.selectId = item.id;
                      })
                    }
                  }, (item: RechargePackage) => item.id.toString())
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsTemplate('1fr 1fr')
                .columnsGap(12)
                .rowsGap(12)
                .height(292)
                .alignSelf(ItemAlign.Center)
                .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)
              }
              .width(Constants.FULL_SIZE)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius({
                topLeft: 16,
                topRight: 16,
                bottomLeft: 0,
                bottomRight: 0
              })
              .padding({
                left: 16,
                right: 16,
                top: 20,
                bottom: 10
              })
              .alignItems(HorizontalAlign.Start)

              Column({ space: 16 }) {
                Text('充值说明')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .alignSelf(ItemAlign.Start)

                Column({ space: 8 }) {
                  Text('• 书币可用于购买付费图书和章节')
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .alignSelf(ItemAlign.Start)

                  Text('• 充值成功后书币将立即到账')
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .alignSelf(ItemAlign.Start)

                  Text('• 书币不可提现，仅限在本应用内使用')
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .alignSelf(ItemAlign.Start)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .alignItems(HorizontalAlign.Start)

              Column().height(140)
            }
            .backgroundColor($r('sys.color.background_primary'))
            .width('100%')
            .layoutWeight(1)

          }
          .borderRadius(12)
          .margin({ top: 120 })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)
          .layoutWeight(1)
        }
        .padding({ left: 0, right: 0 })
        .justifyContent(FlexAlign.Start)

        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Checkbox({ name: `recharge_agreement`, group: `rechargeAgreement` })
              .select($$this.vm.selectCheckbox)
              .height(24)
              .width(24)
              .shape(CheckBoxShape.CIRCLE)

            Row({ space: 4 }) {
              Text('我已阅读并同意')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))

              Text('充值协议')
                .fontSize(12)
                .fontColor('#E39331')
                .onClick(() => {
                  // 可以跳转到充值协议页面
                  this.promptAction.showToast({ message: '充值协议页面' });
                })
            }
          }

          Button('立即充值')
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#E39331')
            .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : Constants.FULL_SIZE)
            .height(48)
            .bindSheet($$this.vm.isShow, this.paymentChannelSheet(), {
              preferType: SheetType.CENTER,
              showClose: false,
              height: '45%',
              onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
                if (dismissSheetAction.reason === DismissReason.TOUCH_OUTSIDE) {
                  dismissSheetAction.dismiss()
                }
              }
            })
            .onClick(() => {
              if (!this.vm.selectCheckbox) {
                this.promptAction.showToast({ message: '请先同意充值协议' });
                return;
              }

              // 获取各支付方式的预下单信息
              this.vm.wxOrderReq = MockApi.getWxPreOrderInfo();
              this.vm.hwOrderStr = MockApi.getHuaweiOrderInfo();
              MockApi.getAliPreOrderInfo().then((res) => {
                this.vm.aliOrderStr = res;
                this.vm.isShow = true;
              });
            })
        }
        .backgroundColor($r('sys.color.background_primary'))
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 34
        })
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -126 })
        .width(Constants.FULL_SIZE)
      }
      .alignContent(Alignment.Top)
    }
    .hideTitleBar(true)
  }

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      amount: this.vm.rechargePackages.find(pkg => pkg.id === this.vm.selectId)?.price || 0.01,
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: this.vm.hwOrderStr,
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: this.vm.wxOrderReq,
        appId: MockApi.WX_APP_ID,
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          this.vm.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.vm.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        // 支付成功后更新书币余额
        const selectedPackage = this.vm.rechargePackages.find(pkg => pkg.id === this.vm.selectId);
        if (selectedPackage) {
          const totalCoins = selectedPackage.coins + (selectedPackage.bonus || 0);
          this.updateBookCoins(totalCoins);

          // 保存充值记录
          const timestamp = Date.now();
          const rechargeRecord: RechargeRecord = {
            id: `${timestamp}_${selectedPackage.id}`,
            orderId: RechargeRecordVM.generateOrderId(),
            coins: selectedPackage.coins,
            bonus: selectedPackage.bonus || 0,
            totalCoins: totalCoins,
            amount: selectedPackage.price,
            timestamp: timestamp,
            date: RechargeRecordVM.formatDateTime(timestamp)
          };

          RechargeRecordVM.saveRechargeRecord(rechargeRecord);

          this.promptAction.showToast({
            message: `充值成功！获得${totalCoins}书币`,
            duration: 2000,
          });
        }

        TCRouter.pop();
        this.vm.isShow = false;
      },
    });
  }
} 