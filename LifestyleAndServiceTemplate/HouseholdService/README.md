# 生活服务(家政)行业模板

## 目录

- [功能介绍](#功能介绍)
- [环境要求](#环境要求)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [权限要求](#权限要求)
- [开源许可协议](#开源许可协议)

## 功能介绍

本模板为家政类元服务提供了常用功能的开发样例，模板主要分首页、全部服务和我的三大模块：

* 首页：提供主要商品轮播图、常用类别菜单和精选服务列表，支持城市切换、商品搜索、商品价格咨询以及商品购买。

* 全部服务：展示全部品类的商品列表，支持切换城市、搜索商品。

* 我的：展示个人信息、我的订单、服务和工具以及部分商品列表，支持修改个人信息、管理订单、管理地址等。

本模板已集成华为账号、支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、购买商品等功能。

| 首页                          | 全部服务                            | 我的                          |
|-----------------------------|---------------------------------|-----------------------------|
| ![首页](./screenshots/首页.jpg) | ![全部服务](./screenshots/全部服务.jpg) | ![我的](./screenshots/我的.jpg) |


本模板主要页面及核心功能如下所示：

```ts
家政模板
 |-- 首页
 |    |-- 切换城市
 |    |-- 搜索
 |    |-- 轮播图
 |    |-- 品类菜单
 |    |     |-- 日常保洁
 |    |     |-- 家电维修
 |    |     |-- 保姆月嫂
 |    |     └-- 管道疏通
 |    └-- 精选服务
 |          |-- 服务列表
 |          |-- 服务详情
 |          |-- 下单页面
 |          |-- 待支付
 |          └-- 支付成功
 |-- 全部服务
 |    |-- 切换城市
 |    |-- 全部分类
 |    └-- 搜索
 |
 └-- 我的
      |-- 用户信息
      |     |-- 个人信息
      |     └-- 编辑资料
      |-- 我的订单
      |     |-- 全部订单
      |     |-- 待付款
      |     |-- 待使用
      |     └-- 退款售后
      |-- 服务与工具
      |     |-- 地址管理
      |     └-- 公共服务
      └-- 服务列表
```

本模板工程代码结构如下所示：
```ts
HouseholdService
├─commons
│  ├─address_manage/src/main/ets                       // 地址管理模块
│  │  ├─common
│  │  │  └─Constant.ets                                // 常量定义
│  │  │
│  │  ├─pages
│  │  │  ├─AddressManage.ets                           // 地址管理页面
│  │  │  └─EditAddress.ets                             // 编辑/新增地址
│  │  │
│  │  └─viewmodel
│  │     └─AddressVM.ets                               // 地址viewmodel
│  │
│  ├─city_select/src/main/ets                          // 城市选择模块
│  │  ├─common
│  │  │  ├─Constant.ets                                // 常量定义
│  │  │  ├─Model.ets                                   // 模型定义
│  │  │  └─Utils.ets                                   // 工具方法
│  │  │
│  │  ├─components
│  │  │      └─SingleBtn.ets                           // 按钮组件
│  │  │
│  │  └─pages
│  │     └─Index.ets                                   // 城市选择组件
│  │
│  └─utils/src/main/ets                                // 公共utils模块
│     ├─common
│     │  ├─Constant.ets                                // 常量定义
│     │  ├─GoodDataSource.ets                          // 商品datasource定义
│     │  ├─Logger.ets                                  // 日志打印
│     │  ├─PopViewUtils.ets                            // 公共弹窗
│     │  └─Utils.ets                                   // 公共方法
│     │
│     ├─http
│     │  ├─ApiManage.ets                               // 服务端接口定义
│     │  ├─AxiosBase.ets                               // 接口调用基础类
│     │  ├─HttpMockMap.ets                             // mock接口映射
│     │  ├─MockApi.ets                                 // mock接口
│     │  └─MockData.ets                                // mock数据
│     │
│     ├─login
│     │  └─LoginUtil.ets                               // 登录工具类
│     │
│     ├─model
│     │  ├─IRequest.ets                                // 接口请求定义
│     │  ├─IResponse.ets                               // 接口响应定义
│     │  └─ObserveModel.ets                            // 状态管理类
│     │
│     ├─router
│     │  └─RouterModule.ets                            // 路由管理
│     │
│     └─uicomponent
│        ├─CommonCard.ets                              // 卡片组件
│        ├─DialogCall.ets                              // 拨号弹窗
│        ├─FormItem.ets                                // 表单组件
│        ├─GoodCard.ets                                // 商品卡片
│        ├─NoticeDialog.ets                            // 通知弹窗
│        ├─UIBackBtn.ets                               // 返回按钮
│        ├─UIEmpty.ets                                 // 空白组件
│        ├─UILoading.ets                               // loading组件
│        ├─UIOrderPart.ets                             // 订购组件
│        └─formcontent
│           ├─FormAddress.ets                          // 表单-地址填写
│           ├─FormAvatar.ets                           // 表单-头像编辑
│           ├─FormDate.ets                             // 表单-日期选择
│           ├─FormGender.ets                           // 表单-性别选择
│           ├─FormInput.ets                            // 表单-输入框
│           └─FormTextReadOnly.ets                     // 表单-只读文本
│
├─features
│  ├─category/src/main/ets/pages
│  │  └─AllCategory.ets                                // 全部服务模块
│  │
│  ├─home/src/main/ets
│  │  ├─common
│  │  │  ├─Constant.ets                                // 常量定义
│  │  │  ├─Model.ets                                   // 模型定义
│  │  │  └─Utils.ets                                   // 方法定义
│  │  │
│  │  ├─components
│  │  │  └─ServiceText.ets                             // 价格文本组件
│  │  │
│  │  ├─pages
│  │  │  ├─CityList.ets                                // 服务地址页面
│  │  │  ├─GoodDetail.ets                              // 商品详情页面
│  │  │  ├─HomePage.ets                                // 首页
│  │  │  ├─OrderPage.ets                               // 下单页面
│  │  │  ├─SearchPage.ets                              // 搜索页面
│  │  │  ├─SuccessPay.ets                              // 支付成功页面
│  │  │  └─ToPay.ets                                   // 待支付页面
│  │  │
│  │  └─viewmodel
│  │     ├─HomeVM.ets                                  // 首页viewmodel
│  │     └─OrderVM.ets                                 // 下单viewmodel
│  │
│  └─mine/src/main/ets
│     ├─components
│     │  └─OrderCard.ets                               // 订单卡片组件
│     │
│     ├─pages
│     │  ├─CommonService.ets                           // 公共服务页面
│     │  ├─EditPersonal.ets                            // 编辑个人资料页面
│     │  ├─Mine.ets                                    // 我的页面
│     │  ├─MyOrderDetail.ets                           // 订单详情
│     │  ├─MyOrderList.ets                             // 订单列表
│     │  └─OfficialWeb.ets                             // 官网H5
│     │
│     └─viewmodel
│        ├─MineVM.ets                                  // 我的viewmodel
│        ├─MyOrderDetailVM.ets                         // 订单详情viewmodel
│        └─MyOrderVM.ets                               // 订单列表viewmodel
│
└─products/entry/src/main/ets
   ├─entryability
   │  └─EntryAbility.ets                               // UIAbility生命周期
   │
   ├─entryformability
   │  └─EntryFormAbility.ets                           // FormExtensionAbility生命周期
   │
   ├─pages
   │  ├─Index.ets                                      // 入口页面
   │  └─Main.ets                                       // 主页面
   │
   └─widget/pages
      └─WidgetCard.ets                                 // 元服务卡片

```

## 环境要求
### 软件
* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
### 硬件
* 设备类型：华为手机（直板机）
* HarmonyOS版本：HarmonyOS 5.0.0 Release及以上

## 快速入门
###  配置工程
在运行此模板前，需要完成以下配置：

1. 在DevEco Studio中打开此模板。

2. 在AppGallery Connect创建元服务，将包名配置到模板中。

   a. 参考[创建元服务](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为元服务创建APPID，并进行关联。

   b. 返回应用列表页面，查看元服务的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建元服务的包名。

3. 配置服务器域名。

   本模板接口均采用mock数据，由于元服务包体大小有限制，部分图片资源将从云端拉取，所以需为模板项目[配置服务器域名](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/agc-help-harmonyos-server-domain-V5)，“httpRequest合法域名”需要配置为：`https://agc-storage-drcn.platform.dbankcloud.cn`

4. 配置华为账号服务。

   a. 将元服务的client ID配置到entry模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/account-atomic-client-id-V5)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

   c. 如需获取用户真实手机号，需要申请phone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/account-guide-atomic-permissions-V5)，并在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/account-guide-atomic-get-phonenumber-V5)。

5. 配置支付服务。

   a. 华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开通服务等相关配置。

   b. 当前模板仅提供端侧集成示例，修改端侧文件：features/home/src/main/ets/viewmodel/OrderVM.ets，主要修改点如下：

   ```
   // 付款
   payOrder() {
      CommonUtils.showLoading();
      const jumpParam = this.buildJumpParam();
      // 传入false，不走mock
      SystemSceneUtils.requestPaymentPromise(false, this.uiAbilityContext).then(() => {
         payOrder(this._orderId).then(() => {
            CommonUtils.hideLoading();
            RouterModule.push({ url: RouterMap.SUCCESS_PAY, param: jumpParam });
         })
      })
   }

   // 调用华为支付
   static requestPaymentPromise(ignoreRequestPayment: boolean, context: common.UIAbilityContext): Promise<void> {
      if (ignoreRequestPayment) {
         return new Promise((resolve) => resolve());
      }
      const orderStr = '{}';// 补充信息
      return paymentService.requestPayment(context, orderStr)
      .then(() => {
         Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
         Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
         promptAction.showToast({ message: '拉起支付失败' });
      });
   }
   ```
   更多详细内容参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/payment-preparations-V5)。

###  运行调试工程
1. 连接调试手机和PC。

2. 对元服务签名：由于模板中集成了华为账号、地图等服务，所以需要采用[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-signing-V5#section297715173233)。

3. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

1. [首页](./screenshots/首页.mp4)

2. [购买流程](./screenshots/购买&咨询.mp4)

3. [全部服务](./screenshots/全部服务.mp4)

4. [我的-编辑资料](./screenshots/我的编辑资料.mp4)

5. [我的-订单管理](./screenshots/我的订单管理.mp4)

6. [我的-服务与工具等](./screenshots/我的服务与工具.mp4)

## 权限要求
* 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION
* 网络权限：ohos.permission.INTERNET

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
