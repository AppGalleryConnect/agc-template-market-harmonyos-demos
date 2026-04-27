import { Channel, ChannelType, PAYMENT_CHANNEL, PickerType, WxExtraInfo } from '../common/Constant';
import { OnWXResp, wxEventHandler } from '../model/WXApiWrap';
import { AggregatedPaymentVM } from '../viewmodel/AggregatedPaymentVM';
import { common } from '@kit.AbilityKit';
import { ChannelInfo } from '../model/Index';

/**
 * @usage: 用于聚合支付渠道选择场景。提供支付宝、微信、华为支付等多种支付方式选择和支付功能。
 * 关键数据结构：ChannelInfo（支付渠道信息，包含channelType渠道类型、icon图标、name名称、
 * preOrderInfo预下单信息、appId应用ID、event事件回调）、ChannelType（渠道类型枚举，包含ALI_PAY支付宝、
 * WECHAT_PAY微信、HUAWEI_PAY华为支付）、AggregatedPaymentVM（聚合支付视图模型）、
 * paySuccessEvent（支付成功回调函数，参数为渠道类型）。
 * 包含if逻辑：根据checkedType判断选中的支付渠道（支付宝调用aliPay、微信调用weChatPay、
 * 华为调用huaweiPay）。
 * @layout: 垂直布局。顶部为支付渠道列表（每行包含支付图标、名称和单选框，横向排列），
 * 底部为"确定付款"按钮（红色背景，全宽）。
 * @constraints: channelInfo支付渠道信息数组不能为空，paySuccessEvent回调函数必须正确处理支付成功，
 * 微信支付需要正确配置appId，各支付渠道的preOrderInfo必须有效
 * @isGen: true
 * @fileType: component
 * @zhName: 聚合支付选择器组件
 */
@ComponentV2
export struct AggregatedPaymentPicker {
  vm: AggregatedPaymentVM = AggregatedPaymentVM.instance;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local isShow: boolean = false;
  @Local checkedType: number = 0;
  @Local wxPayResultText: string = '';
  @Local preOrderInfo: string | WxExtraInfo = '';
  @Local appId: string = '';
  /**
   * 支付渠道及支付渠道信息
   */
  @Param channelInfo: ChannelInfo[] = [];
  /**
   * 支付宝支付成功跳转页面Name
   */
  @Param paySuccessEvent: (type: ChannelType) => void = () => {
  };
  private wxEventHandler = wxEventHandler;
  private onWXResp: OnWXResp = (resp) => {
    this.wxPayResultText = JSON.stringify(resp ?? {}, null, 2);
  };

  aboutToAppear(): void {
    this.wxEventHandler.registerOnWXRespCallback(this.onWXResp);
    this.checkedType = this.channelInfo[0].channelType;
  }

  aboutToDisappear(): void {
    this.wxEventHandler.unregisterOnWXRespCallback(this.onWXResp);
  }

  @Builder
  paymentChannelPicker() {
    Column() {
      ForEach(this.channelInfo, (item: ChannelInfo) => {
        Row() {
          Row({ space: 16 }) {
            Image(item.icon).size({ width: 24, height: 24 });
            Text(item.name).fontWeight(500);
          };

          Checkbox({ name: 'channelCheckBox', group: 'checkboxGroup' })
            .select(this.checkedType === item.channelType)
            .selectedColor(0xed6f21)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              if (value) {
                this.checkedType = item.channelType;
                this.preOrderInfo = item.preOrderInfo;
                if (item.appId) {
                  this.appId = item.appId;
                }
              }
            });
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(12);
      },(item: ChannelInfo) => JSON.stringify(item));
      Button('确定付款').width('100%').backgroundColor(Color.Red).onClick(() => {
        if (this.checkedType === ChannelType.ALI_PAY) {
          this.vm.aliPay(this.paySuccessEvent, this.preOrderInfo);
        } else if (this.checkedType === ChannelType.WECHAT_PAY) {
          let channel = this.channelInfo.find((item) => item.channelType === ChannelType.WECHAT_PAY);
          if (channel?.event) {
            channel.event();
          }
          this.vm.weChatPay(this.preOrderInfo, this.appId);
        } else {
          this.vm.huaweiPay(this.context, this.preOrderInfo, this.paySuccessEvent);
        }
      });
    }.padding(12);
  }

  build() {
    this.paymentChannelPicker();
  }
}
