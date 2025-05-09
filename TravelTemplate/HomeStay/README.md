# 旅游（民宿）行业模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [环境要求](#环境要求)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [权限要求](#权限要求)
- [开源许可协议](#开源许可协议)

## 功能介绍

本模板为民宿住宿类应用提供了常用功能的开发样例，模板主要分首页、发现、地图、商城和我的五大模块：
* 首页：提供民宿轮播展示、民宿信息查看、入住时间选择、热门房型选择。
* 发现：展示发现列表，展示发现详情。
* 地图：提供民宿地理位置展示、民宿导航。
* 商城：展示商城商品列表、商品详情和商品购买。
* 我的：提供订单入口，支持旅客信息、投诉建议、客服列表、关于我们。

本模板已集成华为账号、通话、地图、华为支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、一键拨打服务电话、民宿位置定位导航、订房下单、购买商品等功能。

| 首页                             | 发现                                        | 地图                                       | 商城                                       | 我的                                      |
|--------------------------------|-------------------------------------------|------------------------------------------|------------------------------------------|-----------------------------------------|
| ![image](screenshots/home.jpg) | ![image](screenshots/discovery.jpg) | ![image](screenshots/map.jpg) | ![image](screenshots/shop.jpg) | ![image](screenshots/mine.jpg) |


本模板主要页面及核心功能如下所示：

```ts
民宿旅游
 |-- 首页
 |    |-- 顶部轮播
 |    |-- 民宿信息
 |    |    └-- 民宿基本信息
 |    |-- 入离时间
 |    |    └-- 入离时间选择
 |    |-- 热门房型
 |    |    |-- 热门房型详情
 |    |         └-- 热门房型下单
 |    |    |-- 全部房型
 |    |         └-- 房型详情
 |    |              └-- 房型下单
 |-- 发现
 |    └-- 发现列表
 |         └-- 发现详情
 |-- 地图
 |    └-- 民宿信息
 |    └-- 民宿导航
 |-- 商城
 |    └-- 商品列表
 |         └-- 商品详情
 |              └-- 商品下单
 └-- 我的
      |-- 我的订单
      |    └-- 住宿订单
      |    └-- 商品订单
      |-- 常用旅客
      |    └-- 游客列表
      |         └-- 新增游客 
      |-- 客服
      |    └-- 常见问题列表
      └-- 投诉建议
           └-- 新增投诉建议
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
  |- function                                     // 特性层
  |   |- account/src/main/ets                     // 账号维护模块(hsp)
  |   |    |- AccountUtil                         // 账号信息维护类                
  |   |    
  |   |- calendar/src/main/ets                    // 日历模块(hsp)
  |   |    |- component                           // 抽离组件   
  |   |    |- data                                // 懒加载数据 
  |   |    |- model                               // class类型定义     
  |   |    |- pages                              
  |   |    |    CustomCalendarPickerDialog.ets    // 日历选择页面
  |   |    └- utils                               // 日历工具类 
  |   | 
  |   |- mapview/src/main/ets                     // 地图模块(hsp)   
  |   |    |- pages                              
  |   |    |    Map.ets                           // 地图组件页面 
  |   |
  |   |- network/src/main/ets                     // 网络请求模块(hsp)
  |   |    |- api                                 // 接口请求方法类   
  |   |    |- mock                                 
  |   |    |    Mock.ets                          // mock数据
  |   |    |- models                              // class类型定义    
  |   |    |- types                               // 接口类型定义      
  |   |
  |- tab                                          // tab特性层
  |   |- discovery/src/main/ets                   // 发现模块(hsp)
  |   |    |- components                          // 抽离组件 
  |   |    |- pages                              
  |   |    |    Discovery.ets                     // 发现列表页
  |   |    |    PageDetail.ets                    // 发现详情页
  |   |    └- viewmodel                           // 与页面一一对应的vm层
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

2. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为应用创建APPID，并进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

3. 配置华为账号服务。

   a. 将应用的client ID配置到main模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。
   
4. 配置地图服务。

   a. 将应用的client ID配置到main模块的module.json5文件，如果华为账号服务已配置，可跳过此步骤。

   b. 添加公钥指纹，如果华为账号服务已配置，可跳过此步骤。
   
   c. [开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

5. 配置支付服务。

   华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开发服务等相关配置，本模板仅提供了端侧集成的示例。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)。

###  运行调试工程
1. 连接调试手机和PC。

2. 对应用签名：由于模板中集成了华为账号、地图等服务，所以需要采用[手动签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

3. 配置多模块调试：由于本模板存在多个模块，运行时需确保所有模块安装至调试设备。
   
   a. 在DevEco Studio菜单选择“Run > Edit Configurations”，进入“Run/Debug Configurations”界面。
   
   b. 左侧导航选择“main”模块，选择“Deploy Multi Hap”页签，勾选上模板中所有模块。
   
   c. 点击"Run"，运行模板工程。


## 示例效果

1. 住宿预订

   [住宿预订展示](./screenshots/reserve.mp4)

2. 商品购买

   [商品购买展示](./screenshots/purchase.mp4)

## 权限要求

- 获取位置权限：ohos.permission.APPROXIMATELY_LOCATION、ohos.permission.LOCATION。
- 网络权限：ohos.permission.INTERNET

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。

