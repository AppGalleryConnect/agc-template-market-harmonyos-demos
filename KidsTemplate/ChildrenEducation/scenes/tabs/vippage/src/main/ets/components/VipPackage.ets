import { CustomContentDialog, promptAction } from '@kit.ArkUI';
import { User, vipPageData } from '@ohos_agcit/children_education_datasource';
import { VipModel } from '@ohos_agcit/children_education_datasource/src/main/ets/model/Vip';
import {
  CommonConstants,
  DateConstants,
  DateUtil,
  GlobalContext,
  QuickLogin,
} from '@ohos_agcit/children_education_utils';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct VipPackage {
  @Param isVip: boolean = false;
  @Param validTime: string = '';
  @Event changeVipState: () => void;
  @Local selectedIndex: number = 0;
  @Local vipDataIndex: number = 0;
  private vipData: Array<VipModel> = vipPageData;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

  @Builder
  buildContent(): void {
    Column() {
      Text('请确认您的选择');
    }
    .width(CommonConstants.FULL_PERCENT);
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '开通会员',
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            console.info('Callback when the button is clicked');
          },
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            let validTimeTmp = this.validTime;
            if (this.validTime === '' || this.validTime === null) {
              validTimeTmp = DateUtil.getTodayStr(DateConstants.DATE_FORMAT4);
            }
            if (this.vipDataIndex === 0) {
              validTimeTmp = DateUtil.getAmountDayStr(validTimeTmp, 365, DateConstants.DATE_FORMAT4);
            } else if (this.vipDataIndex === 1) {
              validTimeTmp = DateUtil.getAmountDayStr(validTimeTmp, 92, DateConstants.DATE_FORMAT4);
            } else {
              validTimeTmp = DateUtil.getAmountDayStr(validTimeTmp, 31, DateConstants.DATE_FORMAT4);
            }
            GlobalContext.getContext().setObject(CommonConstants.IS_VIP, true);
            GlobalContext.getContext().setObject(CommonConstants.VALID_TIME, validTimeTmp);
            let vipInfo: emitter.EventData = {
              data: {
                'isVip': true,
                'validTime': validTimeTmp,
              },
            };
            console.log('开始使用emitter发送VIP消息');
            emitter.emit(CommonConstants.IS_VIP, vipInfo);
            this.changeVipState();
          },
        },
      ],
    }),
  });

  build() {
    Row() {
      Column() {
        Text('会员套餐')
          .textAlign(TextAlign.Start)
          .padding({ left: 16, bottom: 15, top: 18 })
          .fontSize(18)
          .fontColor('#191919')
          .fontWeight(FontWeight.Bold)
          .fontFamily('鸿蒙黑体');

        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.vipData, (item: VipModel, index: number) => {
            Column() {
              RelativeContainer() {
                Column()
                  .width('32%')
                  .height(150)
                  .borderRadius(8)
                  .backgroundColor(this.selectedIndex === index ? '#F8E6CE' : '#F1F3F5')
                  .id('backgroundImage');

                Column() {
                  Text(item.category)
                    .fontSize(18)
                    .fontWeight(FontWeight.Medium)
                    .margin({
                      top: '20%',
                    });

                  Row() {
                    Text('￥')
                      .alignSelf(ItemAlign.End)
                      .fontColor(this.selectedIndex === index ? '#7E4D12' : Color.Black)
                      .fontWeight(FontWeight.Bold)
                      .margin({
                        bottom: '3%',
                      });
                    Text(item.price)
                      .fontSize(26)
                      .fontColor(this.selectedIndex === index ? '#7E4D12' : Color.Black)
                      .fontWeight(FontWeight.Bold)
                      .margin({
                        top: '20%',
                      });
                  };
                }
                .border({
                  radius: { topLeft: 8, topRight: 8 },
                })
                .width('31%')
                .height(120)
                .backgroundColor(this.selectedIndex === index ? '#FFFCF2' : Color.White)
                .alignRules({
                  top: { anchor: 'backgroundImage', align: VerticalAlign.Top },
                })
                .margin({
                  left: '0.5%',
                  right: '0.5%',
                  top: '0.5%',
                })
                .id('price');

                Row() {
                  Text(item.describe)
                    .fontSize(12)
                    .fontColor(this.selectedIndex === index ? '#562E15' : Color.Black)
                    .fontWeight(FontWeight.Regular);
                }
                .justifyContent(FlexAlign.Center)
                .width('32%')
                .margin({
                  top: '2%',
                })
                .alignRules({
                  top: { anchor: 'price', align: VerticalAlign.Bottom },
                });

              }.width('auto').height('auto');
            }
            .onClick(() => {
              this.selectedIndex = index;
              this.vipDataIndex = item.index;
            });
          });
        }
        .margin({
          left: '12vp',
          right: '12vp',
          bottom: 30,
        });

        Row() {
          Button(this.isVip ? $r('app.string.upgrade_vip') : $r('app.string.purchase'))
            .borderRadius(20)
            .backgroundColor('#FFD15D')
            .width(CommonConstants.FULL_PERCENT)
            .fontColor('#333333')
            .fontSize('16')
            .fontWeight('medium')
            .fontFamily('鸿蒙黑体')
            .onClick(() => {
              if (this.user.isLogin === false) {
                GlobalContext.getContext().setObject(CommonConstants.APP_PATH_STACK, this.appPathStack);
                QuickLogin.getQuickLoginAnonymousPhone();
                return;
              } else {
                this.dialogController.open();
              }
            });
        }.padding({ left: 16, right: 16, bottom: 8 });

        Row() {
          Text($r('app.string.read_before_purchase'));
          Text($r('app.string.vip_agreement'))
            .fontColor('#FFD15D').onClick(() => {
            this.appPathStack.pushPathByName('PrivacyAgreement', undefined);
          });
        }.justifyContent(FlexAlign.Center).width(CommonConstants.FULL_PERCENT).padding({ bottom: 16 });
      }.alignItems(HorizontalAlign.Start);
    }
    .border({
      radius: { topLeft: 16, topRight: 16 },
    })
    .backgroundColor($r('sys.color.comp_background_list_card'));
  }
}