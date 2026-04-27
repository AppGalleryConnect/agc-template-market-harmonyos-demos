# 通用会员组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了通过应用内支付实现会员开通的能力（自动续期订阅会员及非续期订阅会员），开发者可以根据业务需要快速实现应用会员开通。

<div style='overflow-x:auto'>
  <table style='min-width:800px'>
    <tr>
      <th></th>
      <th>直板机</th>
      <th>折叠屏</th>
      <th>平板</th>
    </tr>
    <tr>
      <th scope='row'>会员开通（页面）</th>
      <td valign='top'><img src='screenshots/member_page.png' style='max-height:350px;object-fit:contain'></td>
      <td valign='top'><img src='screenshots/member_foldable_page.png' style='max-height:350px;object-fit:contain'></td>
      <td valign='top'><img src='screenshots/member_tablet_page.png' style='max-height:350px;object-fit:contain'></td>
    </tr>
   <tr>
      <th scope='row'>会员开通（半模态）</th>
      <td valign='top'><img src='screenshots/member_sheet.png' style='max-height:350px;object-fit:contain'></td>
      <td valign='top'><img src='screenshots/member_foldable_sheet.png' style='max-height:350px;object-fit:contain'></td>
      <td valign='top'><img src='screenshots/member_tablet_sheet.png' style='max-height:350px;object-fit:contain'></td>
    </tr>
  </table>
</div>

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、华为平板
- 系统版本：HarmonyOS 5.0.0(12) 及以上

### 权限

- 网络权限：ohos.permission.INTERNET

### 限制
本组件中的会员开通功能不支持模拟器

### 注意事项
- 由于真实支付需依赖应用及其关联的会员商品上架，故建议在接入华为应用内支付调测过程中，您可以使用[沙盒测试](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/iap-sandbox)对订单进行虚拟支付。
- 由于在沙盒场景下，已发货状态的非消耗型商品订单信息将不返回，开发者须将应用上架后在真实支付环境下进行调测开发。
- 如需对接真实支付场景，您需将应用及其关联的商品上架后方可测试。

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加membership模块。

    ```
    // 在项目根目录build-profile.json5填写membership路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "membership",
        "srcPath": "./XXX/membership",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```
    // XXX为组件存放的目录名称
    "dependencies": {
      "membership": "file:./XXX/membership"
    }
    ```

2. 配置应用身份及签名信息。

   a. 将应用的client ID配置到entry模块的src/main/module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

    ```
      "metadata": [
         {
           "name": "client_id",
           "value": "*****"
           // 配置为获取的Client ID
         },
       ],
    ```
   b. [配置签名和指纹](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-sign-fingerprints)。

3. 配置应用内支付服务。

   a. 您需[开通商户服务](https://developer.huawei.com/consumer/cn/doc/start/merchant-service-0000001053025967)才能开启应用内购买服务。商户服务里配置的银行卡账号、币种，用于接收华为分成收益。

   b. 使用应用内购买服务前，需要打开应用内购买服务(HarmonyOS NEXT) 开关，此开关是应用级别的，即所有使用IAP Kit功能的应用均需执行此步骤，详情请参考[打开应用内购买服务API开关](https://developer.huawei.com/consumer/cn/doc/app/switch-0000001958955097)。

   c. 开启应用内购买服务(HarmonyOS NEXT) 开关后，开发者需进一步激活应用内购买服务 (HarmonyOS NEXT)，具体请参见[激活服务和配置事件通知](https://developer.huawei.com/consumer/cn/doc/app/parameters-0000001931995692)。

4. （可选）用户购买商品后，IAP服务器会在订单（消耗型/非消耗型商品）和订阅场景的某些关键事件发生时发送通知至开发者配置的订单/订阅通知接收地址，您可以根据关键事件的通知进行服务端的开发，详情请参考[激活服务和配置事件通知](https://developer.huawei.com/consumer/cn/doc/app/parameters-0000001931995692)。

5. 配置商品信息，详情请参考[配置商品信息](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/iap-config-product)。

6. 调用组件，详细参数配置说明参见[API参考](#API参考)。

7. （可选）可参考以下方法查询当前用户的会员订购状态。
   ```
   queryMemberStatus() {
    MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
      let autoRenewPurchasedList = res.renewList;
      let nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.getUIContext().getPromptAction().showToast({ message: '您已开通会员' });
      } else {
        MemberSheetUtils.open(this.productsInfo, this.getUIContext());
      }
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
    });
   }
   ```

## API参考

### 子组件

无

### 接口

MemberShipPage(options: ProductsInfoOptions)

会员组件。

**参数：**

| 参数名     | 类型                                        | 是否必填 | 说明     |
|:--------|:------------------------------------------|:-----|:-------|
| options | [ProductsInfoOptions](#ProductsInfoOptions对象说明) | 是    | 会员组件参数 |

### ProductsInfoOptions对象说明

| 参数名             | 类型                                                                                                                                                                         | 是否必填 | 说明                                                    |
|:----------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----|:------------------------------------------------------|
| routerModule         | [NavPathStack](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-basic-components-navigation#navpathstack10)                                            | 否    | 页面登录时需要传入当前组件所在路由栈 ，半模态登录时不需要传入参数                     |
| themeColor      | [ResourceColor](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcecolor)                                                                  | 否    | 会员页面主题色                                               |
| linearColors      | Array<[ResourceColor,number]>                                                                                                                                              | 否    | 会员页面背景渐变色数组                                           |
| isSheet         | boolean                                                                                                                                                                    | 是    | 会员组件使用状态，设置true为以半模态使用会员组件，设置false为以页面使用会员组件，默认为false |
| productsInfo            | [ProductInfo](#ProductInfo对象说明)[]                                                                                                                                          | 是    | 购买的会员商品的详细信息。                                         |
| privacyContent      | string                                                                                                                                                                     | 是    | 会员服务协议内容                                              |
| lastPurchaseProductExpireTime    | string                                                                                                                                                                     | 是    | 购买非周期订阅商品的到期时间，一般由开发者服务器返回。                           |
| subscribeCallBack       | (params: [MemberParams](#MemberParams对象说明)) => Promise<void>                                                                                                               | 是    | 购买会员商品结果回调函数                                          |
| queryExpireTime   | (productId: string, time?: number) => Promise<void>                                                                                                                        | 是    | 购买非周期订阅商品后从开发者服务器查询商品到期时间                             |
| ownedMemberCallBack   | (list: [MemberList](#MemberList对象说明)) => Promise<void>                                                                                                                     | 是    | 查询用户开通的会员种类列表，沙盒场景下，已发货状态的非消耗型商品订单信息不返回               |

### ProductInfo对象说明

| 名称        | 类型                          | 是否必填 | 说明              |
|:----------|:----------------------------|:-----|:----------------|
| type      | [iap.ProductType](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-iap#section59035422210) | 是    | 商品类型            |
| productId      | string                      | 是    | 商品ID            |
| privileges      | [MemberShipPrivilege](#MemberShipPrivilege对象说明)    | 是    | 会员商品权益          |
| privacyName      | string    | 否    | 自动续期订阅商品的服务协议名称 |
| privacyContent      | string  | 否    | 自动续期订阅商品的服务协议内容 |

### MemberParams对象说明

| 名称           | 类型                                                                                                              | 是否必填 | 说明            |
|:-------------|:----------------------------------------------------------------------------------------------------------------|:-----|:--------------|
| productId    | string                                                                                                          | 是    | 商品ID          |
| type         | [iap.ProductType](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-iap#section59035422210) | 是    | 商品类型          |
| status       | [FinishStatus](#FinishStatus枚举说明)                                                                               | 是    | 商品开通状态        |
| purchaseTime | number                                                                                                          | 是    | 商品购买时间戳，单位：ms |
| errCode      | number                                                                                                          | 否    | 商品购买错误码       |
| errMsg       | string                                                                                                          | 否    | 商品购买错误信息      |

### MemberShipPrivilege对象说明

| 名称           | 类型                                                                                                              | 是否必填 | 说明   |
|:-------------|:----------------------------------------------------------------------------------------------------------------|:-----|:-----|
| id           | string                                                                                                          | 是    | 权益ID |
| icon         | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr) | 是    | 权益图标 |
| title       |  string                                                                              | 是    | 权益标题 |
| des | string                                                                                                          | 是    | 权益描述 |

### MemberList对象说明
| 名称           | 类型                                                                                                    | 是否必填 | 说明            |
|:-------------|:------------------------------------------------------------------------------------------------------|:-----|:--------------|
| renewList           |  string[]                                                                                               | 是    | 已购买自动续期订阅商品列表 |
| nonRenewList         | string[] | 是    | 非续期订阅商品       |
| nonConsumeList         | string[] | 是    | 非消耗型商品        |

### FinishStatus枚举说明

| 名称     | 值   | 说明   |
|:-------|:----|:-----|
| FINISHED | '1' | 开通完成 |
| UNFINISHED | '2' | 开通失败 |

## 示例代码

### 示例1（会员开通页面）

```
import { iap } from '@kit.IAPKit';
import { FinishStatus, MemberList, MemberParams, MemberShipPage, ProductInfo } from 'membership';

@Entry
@ComponentV2
export struct MemberShipSample1 {
  navPathStack: NavPathStack = new NavPathStack();
  @Local lastPurchaseProductExpireTime: string = '';
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.getUIContext().getPromptAction().showToast({ message: `您已拥有会员` });
    }
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
    });
  };

  getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
    } else if (param.status === FinishStatus.UNFINISHED) {
      message = `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`;
    }
    return message;
  }

  build() {
    NavDestination() {
      MemberShipPage({
        routerModule: this.navPathStack,
        themeColor: $r('sys.color.background_emphasize'),
        linearColors: [['#FFFFFF', 0.0], ['#E5EDF5', 0.5], ['#0A59F7', 1.0]],
        isSheet: false,
        lastPurchaseProductExpireTime: this.lastPurchaseProductExpireTime,
        productsInfo: PRODUCTS_INFO,
        privacyContent: PRIVACY_CONTENT,
        subscribeCallBack: this.subscribeEvent,
        queryExpireTime: this.queryExpireTime,
        ownedMemberCallBack: this.ownedMemberEvent,
      });
    }.hideTitleBar(true).onReady((ctx) => {
      this.navPathStack = ctx.pathStack;
    });
  }
}

@Builder
export function MemberShipSample1Builder() {
  MemberShipSample1();
}

export const PRIVACY_CONTENT =
  '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
    '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
    '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
    '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';

// todo: 替换为您配置的商品ID及对应的权益
export const PRODUCTS_INFO: ProductInfo[] =
  [{
    type: iap?.ProductType?.AUTORENEWABLE,
    productId: 'F0001',
    privileges: [
      {
        id: 'privilege_1',
        icon: $r('app.media.privilege'),
        title: '权益1-1',
        des: '简介1-1',
      },
      {
        id: 'privilege_2',
        icon: $r('app.media.privilege'),
        title: '权益1-2',
        des: '简介1-2',
      },
    ],
    privacyName: '连续包周服务协议',
    privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
      '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
      '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
      '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
  },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: 'F0002',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益2-1',
          des: '简介2-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益2-2',
          des: '简介2-2',
        },
      ],
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: 'F0003',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益3-1',
          des: '简介3-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益3-2',
          des: '简介3-2',
        },
        {
          id: 'privilege_3',
          icon: $r('app.media.privilege'),
          title: '权益3-3',
          des: '简介3-3',
        },
        {
          id: 'privilege_4',
          icon: $r('app.media.privilege'),
          title: '权益3-4',
          des: '简介3-4',
        },
        {
          id: 'privilege_5',
          icon: $r('app.media.privilege'),
          title: '权益3-5',
          des: '简介3-5',
        },
        {
          id: 'privilege_6',
          icon: $r('app.media.privilege'),
          title: '权益3-6',
          des: '简介3-6',
        },
        {
          id: 'privilege_7',
          icon: $r('app.media.privilege'),
          title: '权益3-7',
          des: '简介3-7',
        },
      ],
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: 'F0004',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益4-1',
          des: '简介4-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益4-2',
          des: '简介4-2',
        },
      ],
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: 'F0005',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益5-1',
          des: '简介5-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益5-2',
          des: '简介5-2',
        },
      ],
    },
    {
      type: iap?.ProductType?.AUTORENEWABLE,
      productId: 'F0006',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益6-1',
          des: '简介6-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益16-2',
          des: '简介6-2',
        },
      ],
      privacyName: '连续包月服务协议',
      privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
        '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
        '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
        '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
    },
    {
      type: iap?.ProductType?.AUTORENEWABLE,
      productId: 'F0007',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益7-1',
          des: '简介7-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益7-2',
          des: '简介7-2',
        },
      ],
      privacyName: '连续包季服务协议',
      privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
        '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
        '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
        '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
    },
    {
      type: iap?.ProductType?.NONCONSUMABLE,
      productId: 'F0008',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益8-1',
          des: '简介8-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益8-2',
          des: '简介8-2',
        },
      ],
    },
  ];
```

### 示例2（会员开通半模态弹窗）

```
import { iap } from '@kit.IAPKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import {
  FinishStatus,
  MemberSheetUtils,
  MemberParams,
  ProductsInfoOptions,
  MemberStatusUtil,
  MemberList,
} from 'membership';

@Entry
@ComponentV2
export struct MemberShipSample2 {
  @Local lastPurchaseProductExpireTime: string = '';
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: '会员订阅成功' });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.getUIContext().getPromptAction().showToast({ message: `您已拥有会员` });
    }
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
    });
  };
  productsInfo: ProductsInfoOptions = {
    isSheet: true,
    themeColor: $r('sys.color.background_emphasize'),
    linearColors: [['#FFFFFF', 0.0], ['#E5EDF5', 0.5], ['#0A59F7', 1.0]],
    // todo: 替换为您配置的商品ID及对应的权益
    productsInfo: [{
      type: iap.ProductType.AUTORENEWABLE,
      productId: 'F0001',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '商品1-权益1',
          des: '商品1-权益介绍1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '商品1-权益2',
          des: '商品1-权益介绍2',
        },
      ],
      privacyName: '连续包周服务协议',
      privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
        '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
        '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
        '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
    },
      {
        type: iap.ProductType.AUTORENEWABLE,
        productId: 'F0006',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品2-权益1',
            des: '商品2-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品2-权益2',
            des: '商品2-权益介绍2',
          },
        ],
        privacyName: '连续包月服务协议',
        privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
          '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
          '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
          '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
      },
      {
        type: iap.ProductType.AUTORENEWABLE,
        productId: 'F0007',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品3-权益1',
            des: '商品3-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品3-权益2',
            des: '商品3-权益介绍2',
          },
        ],
        privacyName: '连续包季服务协议',
        privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
          '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
          '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
          '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
      },
      {
        type: iap.ProductType.NONRENEWABLE,
        productId: 'F0003',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品4-权益1',
            des: '商品4-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品4-权益2',
            des: '商品4-权益介绍2',
          },
        ],
      },
      {
        type: iap.ProductType.NONRENEWABLE,
        productId: 'F0002',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品5-权益1',
            des: '商品5-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品5-权益2',
            des: '商品5-权益介绍2',
          },
        ],
      },
      {
        type: iap.ProductType.NONRENEWABLE,
        productId: 'F0005',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品6-权益1',
            des: '商品6-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品6-权益2',
            des: '商品6-权益介绍2',
          },
        ],
      },
      {
        type: iap.ProductType.NONCONSUMABLE,
        productId: 'F0008',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品8-权益1',
            des: '商品8-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品8-权益2',
            des: '商品8-权益介绍2',
          },
        ],
      }],
    privacyContent: '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。',
    lastPurchaseProductExpireTime: '',
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
  };

  queryMemberStatus() {
    MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
      let autoRenewPurchasedList = res.renewList;
      let nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.getUIContext().getPromptAction().showToast({ message: '您已开通会员' });
      } else {
        MemberSheetUtils.open(this.productsInfo, this.getUIContext());
      }
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
    });
  }

  build() {
    NavDestination() {
      Button('点击订阅会员')
        .onClick(() => {
          this.queryMemberStatus();
        });
    }.hideTitleBar(true);
  }
}

@Builder
export function MemberShipSample2Builder() {
  MemberShipSample2();
}
```