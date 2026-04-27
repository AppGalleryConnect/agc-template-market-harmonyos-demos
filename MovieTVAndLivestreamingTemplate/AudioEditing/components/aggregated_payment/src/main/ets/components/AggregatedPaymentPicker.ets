import { Channel, ChannelType, PAYMENT_CHANNEL, PickerType, WxExtraInfo } from '../common/Constant';
import { OnWXResp, wxEventHandler } from '../model/WXApiWrap';
import { AggregatedPaymentVM } from '../viewmodel/AggregatedPaymentVM';
import { common } from '@kit.AbilityKit';
import { ChannelInfo } from '../model/Index';

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
