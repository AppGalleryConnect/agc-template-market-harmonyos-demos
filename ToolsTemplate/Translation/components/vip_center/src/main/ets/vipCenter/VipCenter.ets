import { baseActionSheet, DividerTmp } from 'base_apis'
import { VipPackage } from '../components/VipPackage';
import { VipBenefits } from '../components/VipBenefits';
import { VipOperation } from '../components/VipOperation';
import { VipOpen } from '../components/VipOpen';
import { VipNavTitle } from '../components/VipNavTitle';
import { VipPackageItem } from '../model/Model';
import { getVipDuration } from '../utils/Utils';
import { AggregatedPaymentPicker, ChannelType, WxExtraInfo } from 'aggregated_payment'
import { promptAction } from '@kit.ArkUI';
import { MockApi } from '../utils/MockApi'

@ComponentV2
export struct VipCenter {
  private wxOrderReq: WxExtraInfo = new WxExtraInfo();
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Param userName: string = ''
  @Param avatar: ResourceStr = ''
  @Param isVip: boolean = false
  @Param vipType: string = ''
  @Param statusBarHeight: number = 0
  @Param routerModule: NavPathStack = new NavPathStack()
  hwOrderStr: string = '';
  @Local aliOrderStr: string = '';
  @Event onVerifyNow: () => void = () => {
  }
  @Event onVipOpen: () => void = () => {
  }
  @Event packageChange: (vipPackage: VipPackageItem) => void = () => {
  }

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: this.hwOrderStr,
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: this.wxOrderReq,
        appId: MockApi.WX_APP_ID,
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          // this.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        promptAction.showToast({ message: '开通成功' })
        this.onVipOpen()
        baseActionSheet.close('VipOpen')
      },
    });
  }

  aboutToAppear(): void {
    MockApi.getAliPreOrderInfo().then((res) => {
      this.aliOrderStr = res;
    });
  }

  build() {
    Column() {
      Column() {
        VipNavTitle({
          title: '会员中心',
          routerModule: this.routerModule,
        })
      }
      .padding({ top: this.statusBarHeight })

      List() {
        ListItem() {
          Column() {
            Row({ space: 12 }) {
              Image(this.avatar || $r('app.media.avatar')).width(48).height(48).borderRadius('50%').clip(true)
              Column({ space: 5 }) {
                Row({ space: 8 }) {
                  Text(this.userName)
                    .fontWeight(FontWeight.Medium)
                  Row({ space: 5 }) {
                    Image($r('app.media.vip')).width(12).height(12)
                    Text(this.isVip ? '已开通' : '未开通')
                      .fontSize(10)
                  }
                }

                Column() {
                  Text(`${getVipDuration(this.vipType)}到期`)
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                }.visibility(this.isVip ? Visibility.Visible : Visibility.None)
              }
              .alignItems(HorizontalAlign.Start)
            }
          }
          .width('100%')
          .margin({ bottom: 16, top: 16 })
          .padding({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)
        }

        ListItem() {
          VipPackage({
            userName: this.userName,
            avatar: this.avatar,
            isVip: this.isVip,
            packageChange: (vipPackage: VipPackageItem) => {
              this.packageChange(vipPackage)
            },
          })
        }

        ListItem() {
          VipBenefits()
        }
        ListItem() {
          Column() {
            VipOperation({
              onVerifyNow: () => this.onVerifyNow(),
            })
            VipOpen({
              pageInfo: this.routerModule,
              onVipOpen: () => {
                baseActionSheet.show({
                  id: 'VipOpen',
                  title: {
                    title: '立即开通',
                  },
                  height: 300,
                  customContent: () => {
                    this.paymentChannelSheet()
                  },
                })
              },
            })
          }
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
    .layoutWeight(1)
    .padding({ bottom: Number(AppStorage.get('bottomRectHeight')) })
    .backgroundImage($r('app.media.vip_img'))
    .backgroundImageSize(ImageSize.Contain)
  }
}