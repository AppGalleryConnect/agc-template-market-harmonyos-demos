# 旅游（民宿）应用模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍

您可以基于此模板直接定制应用，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

本模板提供如下组件，所有组件存放在工程根目录的components下，如果您仅需使用组件，可参考对应组件的指导链接；如果您使用此模板，请参考本文档。

| 组件                              | 描述                                | 使用指导                                               |
|---------------------------------|-----------------------------------|----------------------------------------------------|
| 日历组件（calendar_select）           | 提供入住、离开日期选择的功能。                   | [使用指导](components/calendar_select/README.md)       |
| 游记组件（travel_discovery）          | 提供游记浏览搜索、详情查看及评论等功能。              | [使用指导](components/travel_discovery/README.md)      |
| 地图（点位选点）组件（travel_map）          | 提供地图展示能力，并支持地图定位和选点定制功能。          | [使用指导](components/travel_map/README.md)            |
| 通用搜索组件（search）                  | 提供搜索栏、历史搜索、热门搜索、搜索自动补全、搜索结果展示等功能。 | [使用指导](components/search/README.md)                |
| 通用登录组件（aggregated_login）        | 提供华为账号一键登录、微信登录及其他登录方式的聚合能力。      | [使用指导](components/aggregated_login/README.md)      |
| 通用支付组件（aggregated_payment）      | 提供华为支付、支付宝、微信支付的聚合收银台能力。          | [使用指导](components/aggregated_payment/README.md)    |
| 广告组件（aggregated_ads）            | 提供华为开屏广告展示能力。                     | [使用指导](components/aggregated_ads/README.md)        |
| 通用分享组件（aggregated_share）        | 提供系统分享、QQ分享等聚合分享能力。               | [使用指导](components/aggregated_share/README.md)      |
| 通用客服组件（customer_service_chat）   | 提供在线客服即时聊天功能。                     | [使用指导](components/customer_service_chat/README.md) |
| 通用问题反馈组件（feedback）              | 提供意见反馈提交和反馈历史查看功能。                | [使用指导](components/feedback/README.md)              |
| 通用应用内设置组件（app_setting）          | 提供关于、字体大小、隐私设置、退出登录等应用设置功能。       | [使用指导](components/app_setting/README.md)           |
| 通用个人信息组件（collect_personal_info） | 提供表单化的个人信息采集与编辑功能。                | [使用指导](components/collect_personal_info/README.md) |
| 通用地址管理组件（address_management）    | 提供收货地址列表展示、新增编辑及默认地址选择功能。         | [使用指导](components/address_management/README.md)    |
| 通用拨号组件（dial_panel）              | 提供电话客服拨号面板功能。                     | [使用指导](components/dial_panel/README.md)            |
| 通用图片预览组件（image_preview）         | 提供图片预览功能，支持手势缩放和动态照片播放。           | [使用指导](components/image_preview/README.md)         |

本模板为民宿住宿类应用提供了常用功能的开发样例，模板主要分首页、发现、地图、商城和我的五大模块：

* 首页：提供民宿轮播展示、民宿信息查看、入住时间选择、热门房型选择。
* 发现：展示发现列表，展示发现详情。
* 地图：提供民宿地理位置展示、民宿导航。
* 商城：展示商城商品列表、商品详情和商品购买。
* 我的：提供订单入口，支持旅客信息、投诉建议、客服列表、关于我们。

本模板已集成华为账号、通话、地图、华为支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、一键拨打服务电话、民宿位置定位导航、订房下单、购买商品等功能。

| 首页                             | 发现                            | 地图                                       | 商城                                       | 我的                                      |
|--------------------------------|-------------------------------|------------------------------------------|------------------------------------------|-----------------------------------------|
| ![image](screenshots/home.jpg) | ![image](screenshots/discovery.jpg) | ![image](screenshots/map.jpg) | ![image](screenshots/shop.jpg) | ![image](screenshots/mine.jpg) |


本模板主要页面及核心功能如下所示：

```ts
民宿旅游
 |-- 首页
 |    |-- 民宿横幅展示
 |    |-- 民宿信息
 |    |    └-- 民宿基本信息/简介/基础设施/周边信息
 |    |-- 入离时间
 |    |    └-- 入离时间选择
 |    |-- 房型推荐
 |    |    └-- 房型详情
 |    |         └-- 房型预订
 |-- 发现
 |    └-- 游记瀑布流
 |         └-- 游记详情
 |         └-- 游记搜索
 |-- 地图
 |    └-- 民宿位置展示
 |    └-- 民宿导航
 |-- 商城
 |    └-- 商品瀑布流
 |         └-- 商品详情
 |              └-- 商品购买
 └-- 我的
      |-- 快速登录
      |-- 个人信息
      |-- 我的订单
      |    └-- 住宿订单
      |    └-- 商品订单
      |-- 我的收藏
      |-- 浏览历史
      |-- 常用旅客
      |    └-- 旅客列表
      |         └-- 新增/编辑旅客
      |-- 在线客服
      |-- 意见反馈
      |-- 应用设置
      └-- 地址管理
```

本模板工程代码结构如下所示：

```ts
HomeStay
  |- common                                       // 公共层                                      
  |  |- component/src/main/ets/pages              // 公共组件模块(har)
  |  |    |- AgreementDialog.ets                  // 用户协议弹窗 
  |  |    |- CommonBlank.ets                      // 公共空白组件 
  |  |    |- PaySuccess.ets                       // 支付成功组件
  |  |    └- TitleBar.ets                         // 标题组件
  |  |    └- ConfirmDialog.ets                    // 公共确认弹窗
  |  |- constant/src/main/ets                     // 公共模块(har)
  |  |     |- common 
  |  |          Constants.ets                     // 公共常量             
  |  └- type/src/main/ets                         // 类型定义模块(har)
  |  |      |- models                             // 公共类型   
  |  └- util/src/main/ets                         // 工具模块(har) 
  |        |- utils                               // 工具类
  |  |          Index.ets                         // 公共方法类
  |  |          LazyDataSource.ets                // 懒加载公共类 
  |  |          Logger.ets                        // 日志类 
  |  |          ObservedArray.ets                 // 懒加载公共类 
  |  |          Storage.ets                       // 本地状态管理类 
  |
  |- main                                         // 主包(hap) 
  |  └- main/src/main/ets                                                                             
  |        |- entryability                                                                                                                            
  |        |- pages                              
  |        |    Main.ets                          // 主页面
  |        |    CustomTabBar.ets                  // 导航栏自定义页面
  |        |- model                               // 类型定义
  |        |- viewmodel                           // 与页面一一对应的vm层          
  |      
  |- components                                   // 可分可合组件层
  |   |- calendar_select/src/main/ets             // 日历组件(har)
  |   |    |- components                          // 组件页面
  |   |    |    CustomCalendarPickerDialog.ets    // 日历弹窗
  |   |    |    DateInfo.ets                      // 日历组件 
  |   |    |- constant                            // 日历组件常量
  |   |    |- model                               // 日历组件模型  
  |   |    |- utils                               // 日历组件工具类             
  |   |    
  |   |- travel_discovery/src/main/ets            // 游记组件(har)
  |   |    |- components                          // 组件
  |   |    |    ContentCard.ets                   // 游记卡片  
  |   |    |- constant                            // 游记组件常量
  |   |    |- model                               // 游记组件模型     
  |   |    |- pages                              
  |   |    |    PageDetail.ets                    // 游记详情页面
  |   |    |    PageSearch.ets                    // 游记搜索页面
  |   |    |    PageWaterFlow.ets                 // 游记瀑布流页面
  |   |    └- utils                               // 日历工具类 
  |   |- travel_map/src/main/ets                  // 地图组件(har)
  |   |    |- components                          // 组件页面
  |   |    |    Map.ets                           // 地图  
  |   |    |- model                               // 地图组件模型
  |                                           
  |- function                                     // 特性层
  |   |- account/src/main/ets                     // 账号维护模块(hsp)
  |   |    |- AccountUtil                         // 账号信息维护类                  
  |   |
  |   |- network/src/main/ets                     // 网络请求模块(hsp)
  |   |    |- api                                 // 接口请求方法类   
  |   |    |- mock                                 
  |   |    |    Mock.ets                          // mock数据
  |   |    |- models                              // class类型定义    
  |   |    |- types                               // 接口类型定义      
  |   |
  |- tab                                          // tab特性层
  |   |- discovery/src/main/ets                   // 发现模块(har)
  |   |    |- components                          // 抽离组件
  |   |    |    ContentCard.ets                   // 发现卡片组件
  |   |    |- constant                              
  |   |    |    Index.ets                         // 常量
  |   |    |- model      
  |   |    |    Index.ets                         // 模型
  |   |    |    IRequest.ets                      // 请求模型
  |   |    |    IResponse.ets                     // 返回模型
  |   |    |- pages                              
  |   |    |    PageSearch.ets                    // 发现搜索页
  |   |    |    PageDetail.ets                    // 发现详情页
  |   |    |    PageWaterFlow.ets                 // 发现列表页
  |   |    └- util                                // 请求工具
  |   |- home/src/main/ets                        // 首页模块(hsp)
  |   |    |- components                          // 抽离组件 
  |   |    |- model                               // class类型定义 
  |   |    |- mapper                              // 类型映射
  |   |    |- pages                              
  |   |    |    Home.ets                          // 首页
  |   |    |    Hotel.ets                         // 民宿信息页
  |   |    |    HotelDetail.ets                   // 民宿详情页
  |   |    |    Reserve.ets                       // 民宿预订页
  |   |    |    Rooms.ets                         // 房型列表页
  |   |    └- viewmodel                           // 与页面一一对应的vm层   
  |   |- map/src/main/ets                         // 地图模块(hsp)
  |   |    |- pages                              
  |   |    |    MapPage.ets                       // 地图展示页
  |   |- personal/src/main/ets                    // 我的模块(hsp)
  |   |    |- components                          // 抽离组件 
  |   |    |- model                               // class类型定义 
  |   |    |- pages                              
  |   |    |    About.ets                         // 关于我们页
  |   |    |    AddGuest.ets                      // 添加旅客页
  |   |    |    CommodityOrderDetail.ets          // 商品订单详情页
  |   |    |    Complaint.ets                     // 反馈建议页
  |   |    |    Customer.ets                      // 客服页
  |   |    |    Guests.ets                        // 旅客列表页
  |   |    |    OrderList.ets                     // 订单列表页
  |   |    |    OtherService.ets                  // 其他服务页
  |   |    |    Personal.ets                      // 我的页
  |   |    |    PersonalInfo.ets                  // 个人信息页
  |   |    |    RoomOrderDetail.ets               // 住宿订单页
  |   |    |    PrivacyPolicyPage.ets             // 隐私政策页
  |   |    |    QuickLoginPage.ets                // 住宿订单页
  |   |    |    TermsOfServicePage.ets            // 用户协议页
  |   |    └- viewmodel                           // 与页面一一对应的vm层    
  |   |- shop/src/main/ets                        // 商城模块(hsp)
  |   |    |- components                          // 抽离组件 
  |   |    |- model                               // class类型定义 
  |   |    |- mapper                              // 接口数据到页面数据类型映射
  |   |    |- pages                              
  |   |    |    CommodityDetail.ets               // 商品详情页
  |   |    |    CommodityList.ets                 // 商品列表页
  |   |    |    Purchase.ets                      // 商品购买页
  |   |    |    Shop.ets                          // 商城页
  |   |    └- viewmodel                           // 与页面一一对应的vm层           
```

## 约束与限制

### 环境
* DevEco Studio版本：DevEco Studio 6.1.1 Release及以上
* HarmonyOS SDK版本：HarmonyOS 6.1.1 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.1.0(18)及以上

### 权限
- 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION、ohos.permission.LOCATION。
- 网络权限：ohos.permission.INTERNET

## 快速入门

###  配置工程
在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的client ID配置到main模块的src/main/module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号一键登录所需的quickLoginMobilePhone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

3. 开通并[配置地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

4. 配置支付服务。

   华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开发服务等相关配置，本模板仅提供了端侧集成的示例。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)。

5. 对应用进行[手动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

6. 添加手工签名所用证书对应的公钥证书。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

###  运行调试工程
1. 连接调试手机和PC。

2. 配置多模块调试：由于本模板存在多个模块，运行时需确保所有模块安装至调试设备。

   a. 在DevEco Studio菜单选择“Run > Edit Configurations”，进入“Run/Debug Configurations”界面。

   b. 左侧导航选择“main”模块，选择“Deploy Multi Hap”页签，勾选上模板中所有模块。

   c. 点击"Run"，运行模板工程。


## 示例效果

1. 住宿预订

   [住宿预订展示](./screenshots/reserve.mp4)

2. 商品购买

   [商品购买展示](./screenshots/purchase.mp4)

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。

