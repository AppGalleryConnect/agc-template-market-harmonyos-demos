
# 支付组件快速入门

## 目录

- [简介](#简介)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了通过华为支付、支付宝支付和微信支付方式进行订单支付的能力，开发者可以根据自己的选择实现移动支付的目的。

<img src="./screenshot/PayChoose.png" width="300" height="800">

## 使用

1. 开发者完成华为支付服务器侧预下单开发，配置[ChannelInfo](#ChannelInfo对象说明)中华为支付的preOrderInfo字段为预下单orderStr，详情参考[商户基础支付场景](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-payment-process#section126982401468)
   
   ```typescript
   // 预下单orderStr示例
   let orderStr = "{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}"

   ```
2. 开发者完成微信支付相关的商户权限申请及微信权限开通，并完成App下单相关服务器开发，配置[WxExtraInfo](#WxExtraInfo对象说明)中的相关字段为支付参数，详情请参考[微信App支付](https://pay.weixin.qq.com/doc/v3/merchant/4013070158)
   ```typescript
   // WxExtraInfo对象示例
    {
      partnerId: '****',
      appId: '****',
      packageValue: 'Sign=WXPay',
      prepayId: '****',
      nonceStr: '****',
      timeStamp:'****',
      sign : '****',
      extData: '****'
    }
   ```

3. 引入支付组件句柄。
   ```typescript
   import { AggregatedPaymentPicker, ChannelType, WxExtraInfo } from 'aggregated_payment';
   ```

4. 调用组件，详细参数配置说明参见[API参考](#API参考)

   ```typescript
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
          this.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        promptAction.showToast({
          message: type.toString(),
          duration: 2000,
        });
        this.pageInfos.pushPathByName('NavSample', null);
        this.isShow = false;
      },
    });
   ```

## API参考

### 子组件

无

###  接口

AggregatedPaymentPicker(channelType:ChannelType,adId:string,adType:AdType,appId:string,appName:string,closeCallBack:() => void)

支付组件。

**参数：**

| 参数名  | 类型                                                | 必填 | 说明                 |
| :------ | :-------------------------------------------------- | :--- | :------------------- |
| channelType | [ChannelType](#ChannelType枚举说明) | 是 | 广告渠道信息数组 |
| adId | string | 是 | 广告位ID |
| adType | AdType | 是 | 广告类型 |
| appId | string | 否 | 应用ID，除华为广告必填 |
| appName | string | 否 | 应用名称，除华为广告必填 |
| closeCallBack | () => void | 是 | 关闭广告回调函数 |

#### ChannelType枚举说明
| 名称    | 值       | 说明       |
| :------ | :-------- |:-------- |
| HUAWEI_AD     |  0     |    华为广告          |
| CSJ_AD     |  1     |    穿山甲广告          |


### 事件

支持以下事件：

#### closeCallBack

closeCallBack: () => void = () => {}

广告关闭时的回调函数。

## 示例代码

### 示例1（支付宝支付、华为支付和微信支付）

本示例展示

```typescript
// 拉起组件
Button('立即支付').width('60%').onClick(async () => {
  this.wxOrderReq = MockApi.getWxPreOrderInfo();
  this.hwOrderStr = MockApi.getHuaweiOrderInfo();
  MockApi.getAliPreOrderInfo().then((res) => {
    this.aliOrderStr = res;
    this.isShow = true;
  });
}).bindSheet($$this.isShow, this.paymentChannelSheet(),
```

```typescript
// 组件使用
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
        this.isShow = false;
      },
    }, {
      channelType: ChannelType.ALI_PAY,
      name: '支付宝支付',
      icon: $r('app.media.alipay'),
      preOrderInfo: this.aliOrderStr,
    }],
    paySuccessEvent: (type: ChannelType) => {
      promptAction.showToast({
        message: type.toString(),
        duration: 2000,
      });
      this.pageInfos.pushPathByName('NavSample', null);
      this.isShow = false;
    },
  });
}
```

<img src="./screenshot/AlipayResult.png" width="300" height="600">
