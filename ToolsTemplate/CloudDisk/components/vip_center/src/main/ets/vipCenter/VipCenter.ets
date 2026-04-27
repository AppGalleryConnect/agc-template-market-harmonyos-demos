import { baseActionSheet, DividerTmp } from 'base_apis';
import { VipPackage } from '../components/VipPackage';
import { VipBenefits } from '../components/VipBenefits';
import { VipOperation } from '../components/VipOperation';
import { VipOpen } from '../components/VipOpen';
import { VipNavTitle } from '../components/VipNavTitle';
import { VipPackageItem } from '../model/Model';
import { getVipDuration } from '../utils/Utils';
import { AggregatedPaymentPicker, ChannelType, WxExtraInfo } from 'aggregated_payment';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { MockApi } from '../utils/MockApi';
import { UserInfo } from 'common';

/**
 * @usage: 用于展示VIP会员中心页面。提供VIP会员信息展示、套餐选择、权益介绍、支付开通等核心功能。
 * 关键数据结构包括VipPackageItem（VIP套餐项模型）、WxExtraInfo（微信支付额外信息）、ChannelType（支付渠道类型枚举）、
 * userName（用户名称）、avatar（用户头像）、isVip（是否为VIP）、vipType（VIP类型）、hwOrderStr（华为支付订单字符串）、
 * aliOrderStr（支付宝支付订单字符串）。包含if逻辑：根据isVip判断显示"已开通"或"未开通"，根据isVip判断是否显示到期时间。
 * @layout: 页面采用Column垂直布局。顶部是VipNavTitle导航标题组件（标题"会员中心"），
 * 主体是List列表（占满剩余空间、滚动条隐藏），包含4个ListItem：第一个是用户信息Row（头像48x48圆形、用户名、VIP状态标签、
 * 到期时间，左右内边距16vp、上下边距16vp），第二个是VipPackage套餐选择组件，第三个是VipBenefits权益介绍组件，
 * 第四个是VipOperation操作组件和VipOpen开通组件。页面背景图为vip_img，底部内边距为bottomRectHeight。
 * @constraints: 支付宝订单信息通过MockApi.getAliPreOrderInfo()获取不可修改；
 * 支付渠道列表固定为华为支付、微信支付、支付宝支付三种；支付成功后调用onVipOpen回调并显示"开通成功"提示；
 * VIP到期时间通过getVipDuration(vipType)计算；支付弹窗通过baseActionSheet.show显示，高度300vp。
 * @isGen: true
 * @fileType: page
 * @zhName: VIP会员中心页面
 * @component: VipNavTitle,VipPackage,VipBenefits,VipOperation,VipOpen,AggregatedPaymentPicker
 */

@ComponentV2
export struct VipCenter {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  private wxOrderReq: WxExtraInfo = new WxExtraInfo();
  @Local egDivider: DividerTmp = new DividerTmp(1, 10, 10, '#ffe9f0f0')
  @Param userName: string = ''
  @Param avatar: ResourceStr = ''
  @Local isVip: boolean = false
  @Param vipType: string = ''
  @Param routerModule: NavPathStack = new NavPathStack()
  hwOrderStr: string = '';
  @Local aliOrderStr: string = '';
  @Event onVerifyNow: () => void = () => {
    this.isVip = this.userInfo.isVip
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
        this.userInfo.isVip = true
        this.isVip = true
        promptAction.showToast({ message: '开通成功' })
        this.onVipOpen()
        baseActionSheet.close('VipOpen')
      },
    });
  }

  aboutToAppear(): void {
    this.isVip = this.userInfo.isVip
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