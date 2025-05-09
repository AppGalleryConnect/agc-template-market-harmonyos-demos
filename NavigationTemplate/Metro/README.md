# 出行导航（地铁）元服务模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [环境要求](#环境要求)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [权限要求](#权限要求)
- [开源许可协议](#开源许可协议)

## 功能介绍

本模板为出行类元服务提供了常用功能的开发样例，模板主要分首页，出行导航，乘车码，和我的四大模块：

- 首页：提供展示站点信息、优惠购票，联系客服的功能，以及新闻公告的展示。
- 出行导航：提供出行地点的定位，以及前往地点的地铁路径规划功能。
- 乘车码：提供扫码乘车、日票、乘车记录展示，线网图的展示，开发票，以及卡包管理功能。
- 我的：展示账号相关信息，以及查看用户协议和隐私政策。

本模板已集成华为账号、定位服务，只需做少量配置和定制即可快速实现华为账号的登录、基于位置导航等功能。

| 首页                                         | 出行导航                                         | 乘车码                                         | 我的                                           |
|--------------------------------------------|----------------------------------------------|---------------------------------------------|----------------------------------------------|
| <img src="doc\1.png" alt="首页" width="300"> | <img src="doc\5.png" alt="出行导航" width="300"> | <img src="doc\3.png" alt="乘车码" width="300"> | <img src="doc\6.png" alt="我的" width="300"> |

功能清单如下：

```ts
地铁出行
 |-- 首页
 |    |-- 展示栏
 |    |-- 功能展示卡片
 |    |    |-- 站点信息
 |    |    └-- 优惠购票
 |    |    └-- 禁携物品
 |    |    └-- 联系客服
 |    |-- 新闻公告
 |    |    └-- 更多
 |    |    └-- 新闻详情页
 
 |-- 出行导航
 |    └-- 地图定位
 |    └-- 搜索地点
 |    |    └-- 导航
 
 |-- 乘车码
 |    └-- 扫码乘车
 |    |    |-- 支付二维码
 |    └-- 一日票
 |    |    |-- 支付二维码
 |    └-- 三日票
 |    |    |-- 支付二维码
 |    └-- 支付切换
 |    |    |-- 选择支付方式
 |    └-- 乘车记录
 |    |    |-- 记录时间切换
 |    └-- 线网图
 |    └-- 开发票
 |    └-- 票卡包
 |    |    |-- 票状态
 
 |-- 我的
 |    └-- 登录
 |    └-- 用户协议
 |    └-- 隐私协议

```

工程目录结构如下：

```ts
Metro
  ├─commons/commonLib/src/main
  │  ├───ets
  │  │   ├───constants
  │  │   │       CommonContants.ets // 公共常量
  │  │   │       CommonEnums.ets    // 公共枚举
  │  │   │
  │  │   ├───mockData
  │  │   │       BuyTicketsPageMockData.ets  // 购票模拟数据
  │  │   │       HomePageMockData.ets        // 首页模拟数据
  │  │   │       InvoicePageMockData.ets     // 发票模拟数据
  │  │   │       MyTicketsPageMockData.ets   // 卡包票模拟数据
  │  │   │       newNaviMockData.ets         // 地铁站和线路模拟数据
  │  │   │       QRViewMockData.ets          // 乘车码模拟数据
  │  │   │       RecordingPageMockData.ets   // 历史票模拟数据  
  │  │   │
  │  │   │
  │  │   └───utils
  │  │           AccountUtil.ets             // 账号工具类
  │  │           FormatUtil.ets              // 日期格式化工具类
  │  │           Logger.ets                  // 日志工具类
  │  │           MainEntryVM.ets             // 路由实例工具类
  │  │           PermissionUtil.ets          // 权限工具类
  │  │           RequestPaymentPromise.ets   // 支付工具类
  │  │           RouterModule.ets            // 路由工具类
  │  └─resources
  ├─commons/componentLib/src/main
  │   ├───ets
  │   │   ├───dialog
  │   │   │       BindPhoneDialog.ets               // 绑定手机模态
  │   └─resources
  ├─commons/network/src/main
  │   ├───ets
  │   │   ├───apis
  │   │   │       HttpApis.ets     // HttpApi 
  │   │   │
  │   │   ├───constants
  │   │   │       NetworkEnums.ets  // 网络常量
  │   │   │
  │   │   ├───mocks
  │   │   │       HttpApisMock.ets     // Mock数据
  │   │   │       MockRequestMap.ets   // Mock数据
  │   │   │
  │   │   ├───models
  │   │   │   │   AxiosHttpModel.ets   // 网络请求
  │   │   │   │   AxiosRequest.ets     // 网络请求
  │   │   │
  │   │   └───types
  │   │           ResponseTypes.ets    // 公共网络响应类
  │   │           RequestTypes.ets    // 公共网络请求类
  │   └─resources
  │─entry/src/main   
  │   ├───ets
  │   │   ├───constants
  │   │   │       Constants.ets   // tab组件常量
  │   │   │
  │   │   ├───pages
  │   │   │       MainEntry.ets   // 入口
  │   │   │  
  │   │   ├───entryability
  │   │   │       EntryAbility.ets   // 页面生命周期
  │   │   │
  │   │   ├───types
  │   │   │       Types.ets       // tab组件类型
  │   │    
  │   └─resources
  │─features/Home/src/main   
  │   └───ets
  │       ├───components
  │       │       HomeView.ets                 // 首页
  │       │       newsComponent.ets            // 新闻公告列表组件
  │       │       StationsInformationTabs.ets  // 站点信息详情组件
  │       ├───constants
  │       │       HomeViewConstants.ets        // 首页颜色常量
  │       └───page
  │       │       BuyTicketsPage.ets           // 优惠购票页面
  │       │       CheckOutPage.ets             // 安全收银台页面
  │       │       moreNewsPage.ets             // 更多新闻页面
  │       │       newsDetailPage.ets           // 新闻详情页面
  │       │       ProhibitArticlePage.ets      // 禁携物品页面
  │       │       StationsInformationPage.ets  // 站点信息页面
  │       │       StationsSearchPage.ets       // 站点搜索页面  
  │       │       TicketsDetailPage.ets        // 购票详情页面
  │       └───types
  │       │       Types.ets                    // 站点详情类型  
  │─features/Mine/src/main
  │   └───ets
  │       ├───components
  │       │       MineView.ets                 // 我的组件
  │       ├───page
  │       │       PrivacyAgreementPage.ets     // 隐私协议页面
  │       │       UserAgreementPage.ets        // 用户协议页面  
  │
  │─features/QRCode/src/main
  │   └───ets
  │       ├───components
  │       │       defaultPayMethod.ets         // 选择默认支付方式组件
  │       │       QRView.ets                   // 我的
  │       │       recordingComponent.ets       // 支付记录组件
  │       │       tabBarBuilder.ets            // 扫码乘车组件
  │       ├───constants
  │       │       Constants.ets                // 扫码乘车类型常量
  │       ├───page
  │       │       InvoicePage.ets              // 开发票页面
  │       │       LineMapPage.ets              // 线网图页面
  │       │       MyTicketsPage.ets            // 票卡包页面
  │       │       PayMethodsPage.ets           // 支付方式页面  
  │       │       RecordingPage.ets            // 乘车记录页面  
  │─features/Trip/src/main 
  │   └───ets
  │       ├───components
  │       │       TripView.ets                  // 出行导航组件

```

## 环境要求

### 软件

- DevEco Studio版本：DevEco Studio 5.0.1 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.1 Release及以上

### 硬件

* 设备类型：华为手机（直板机）
* HarmonyOS版本：HarmonyOS 5.0.1 Release及以上


## 快速入门

###  配置工程

在运行此模板前，需要完成以下配置：

1. 在DevEco Studio中打开此模板。

2. 在AppGallery Connect创建元服务，将包名配置到模板中。

   a. 参考[创建元服务](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为元服务创建APPID，并进行关联。

   b. 返回应用列表页面，查看元服务的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建元服务的包名。

3. 配置华为账号服务。

   a. 将元服务的client ID配置到entry模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-atomic-client-id)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

   c. 如需获取用户真实手机号，需要申请phone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-permissions)，并在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-get-phonenumber)。

4. 配置定位服务。

   a. 将元服务的client ID配置到entry模块的module.json5文件，如果华为账号服务已配置，可跳过此步骤。

   b. 添加公钥指纹，如果华为账号服务已配置，可跳过此步骤。

   c. [开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。


###  运行调试工程

1. 连接调试手机和PC。

2. 对元服务签名：由于模板中集成了华为账号、地图等服务，所以需要采用[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)。

3. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

界面展示

[站点搜索录屏](doc/7.mp4)  [路线规划录屏](doc/8.mp4)  [发票功能录屏](doc/9.mp4)  [卡包功能录屏](doc/10.mp4)

## 权限要求

- 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION、ohos.permission.LOCATION
- 网络权限：ohos.permission.INTERNET

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。