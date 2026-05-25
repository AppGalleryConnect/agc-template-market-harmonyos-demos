# 运动健康（健身房）元服务行业模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)


## 功能介绍

您可以基于此模板直接定制元服务，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

此模板提供如下组件，所有组件存放在工程根目录的components下，如果您仅需使用组件，可参考对应组件的指导链接；如果您使用此模板，请参考本文档。

| 组件                               | 描述             | 使用指导                                             |
|:---------------------------------|:---------------|:-------------------------------------------------|
| 通用元服务关联账号组件（atomicservice_login） | 提供元服务关联账号能力的组件 | [使用指导](components/atomicservice_login/README.md) |
| 通用城市选择组件（city_select）            | 提供城市选择能力的组件    | [使用指导](components/city_select/README.md)         |
| 通用拨号组件（dial_panel）               | 提供拨号能力的组件      | [使用指导](components/dial_panel/README.md)          |
| 通用问题反馈组件（feedback）               | 提供问题反馈能力的组件    | [使用指导](components/feedback/README.md)            |
| 通用搜索组件（search）                   | 提供搜索能力的组件    | [使用指导](components/search/README.md)              |

本模板为健身房会员平台的元服务提供了常用功能的开发样例，提供了健身房信息展示、选择门店、选择城市、课程展示、卡项展示、课程预定、卡项购买、会员中心等能力。模板主要分首页、预约、我的三大模块：

* 首页：展示健身房内容，包含运动项目、卡项、课程、环境等，支持选择城市。

* 预约：展示可预约的课程时间信息，支持选择城市、选择门店。

* 我的：提供账号管理、预约记录、订单记录、会员充值、问题反馈等功能。

本模板已集成华为账号、通话等服务，只需做少量配置和定制即可快速实现关联华为账号、一键拨号等功能。

| 首页                                                          | 预约                                                           | 我的                              |
|-------------------------------------------------------------|--------------------------------------------------------------|---------------------------------|
| <img src="screenshots/homePage.png" alt="首页" width="300"> | <img src="screenshots/bookingPage.png" alt="预约" width="300"> | <img src="screenshots/minePage.png" alt="我的" width="300"> |

本模板主要页面及核心功能如下所示：

```ts
健身房
 ├─ 首页
 │    ├─ 城市选择
 │    ├─ 运动详情
 │    │    ├─ 运动对应卡项列表
 │    │    └─ 远动对应课程列表
 │    ├─ 本店卡项
 │    │    ├─ 卡项名称搜索
 │    │    └─ 本店卡项列表
 │    │         └─ 卡项详情
 │    │              ├─ 咨询
 │    │              └─ 提交订单
 │    ├─ 课程列表
 │    │    ├─ 课程名称搜索
 │    │    └─ 课程列表
 │    │         └─ 课程详情
 │    │              ├─ 咨询
 │    │              └─ 立即预约
 │    └─ 俱乐部环境
 │    
 ├─ 预约
 │    ├─ 课程预约
 │    │    ├─ 课程搜索
 │    │    └─ 新增预约
 │    ├─ 城市选择
 │    └─ 门店选择
 └─ 我的
      ├─ 会员卡
      │    ├─ 个人信息编辑-头像、昵称、手机号
      │    └─ 会员卡展示-卡号、会员码、余额
      ├─ 卡项
      │    └─ 会员已购卡项列表
      ├─ 预约记录
      │    ├─ 状态分类
      │    │    ├─ 全部
      │    │    ├─ 待使用
      │    │    ├─ 已完成
      │    │    ├─ 已过期
      │    │    └─ 已取消
      │    ├─ 预约记录列表
      │    └─ 预约记录详情
      ├─ 课程
      │    └─ 已购课程列表
      ├─ 我的订单
      │    ├─ 状态分类
      │    │    ├─ 全部
      │    │    ├─ 已完成
      │    │    └─ 待支付
      │    ├─ 订单列表
      │    └─ 订单详情
      │    
      ├─ 会员充值
      └─ 问题反馈
```

本模板工程代码结构如下所示：

```ts
FitnessCenter  
├─common
│  └─external_interactions
│     └─src
│         └─main
│            └─ets
│               ├─constant
│               │     ClassConstant.ets                           // 类常量
│               │     GridRowColSetting.ets                       // 行列设置
│               │     EmitterConstant.ets                         // 数据通信常量
│               │     CommonConstants.ets                         // 视图模型通用常量
│               │      
│               ├─model
│               │     BaseViewModel.ets                           // UI动态观测模型基类
│               │     MockModel.ets                               // 公共数据模型，包含模板用到的所有数据类
│               │     BreakpointModel.ets                         // 断点模型
│               │     BreakpointUtils.ets                         // 断点类
│               │     TabModel.ets                                // 应用Tab模型
│               │      
│               ├─Service
│               │     DateUtil.ets                                // 日期时间工具
│               │     MockService.ets                             // 模拟数据服务类
│               │      
│               └─utils                                           // 通用方法
│
├─components
│  ├─atomicservice_login                                         // 通用元服务关联账号组件
│  ├─category_list                                               // 通用分类列表组件
│  ├─city_select                                                 // 通用城市选择组件
│  ├─dial_panel                                                  // 通用拨号组件
│  ├─feedback                                                    // 通用问题反馈组件
│  ├─module_recharge
│  │     └─src
│  │       └─main
│  │          └─ets
│  │             ├─components
│  │             │     Recharge.ets                              // 会员充值公共组件
│  │             │     TitleBar.ets                              // 标题栏
│  │             │
│  │             ├─constant
│  │             │     Constant.ets                              // 定义会员充值组件相关的数据结构
│  │             │  
│  │             └─utils
│  │                   BasicDataSource.ets                       // 会员充值组件数据源抽象基类
│  │                   VipRechargeDataSource.ets                 // 会员充值组件实现具体充值逻辑的工具类  
│  │                   VipRechargeItem.ets                       // 会员充值组件充值项数据模型工具类 
│  │
│  ├─module_search_filter
│  │     └─src
│  │       └─main
│  │          └─ets
│  │             ├─components
│  │             │     SearchFilterContent.ets                   // 搜索过滤组件
│  │             │
│  │             └─constant 
│  │                   Constant.ets                              // 定义过滤筛选条件数据结构
│  ├─payment
│  │     └─src
│  │       └─main
│  │          └─ets
│  │             ├─components
│  │             │     Amount.ets                                // 字体
│  │             │     CashierBindSheetContainer.ets             // 收银台半模态容器
│  │             │     CashierComponent.ets                      // 收银台组件
│  │             │     ConfirmButton.ets                         // 确认按钮
│  │             │     PaymentItemComp.ets                       // 支付组件
│  │             │     PaymentOrderComp.ets                      // 支付订单组件
│  │             │
│  │             ├─data 
│  │             │     CustPayType.ets                           // 自定义支付类型
│  │             │     PaymentType.ets                           // 支付类型
│  │             │     TestData.ets                              // 测试数据
│  │             └─util 
│  │                   PaymentUtil.ets                           // 支付工具类
│  └─search                                                      // 通用搜索组件
│  
│                              
├─features
│  ├─card
│  │  └─src
│  │      └─main
│  │         └─ets
│  │            ├─components
│  │            │      CardContent.ets                           // 卡片内容展示组件
│  │            │      OrderContent.ets                          // 订单内容展示组件
│  │            │
│  │            ├─generated
│  │            │      RouterBuilder.ets                         // 路由构建类
│  │            │      
│  │            └─pages
│  │                   BuyCard.ets                                // 卡项购买页
│  │                   CardDetail.ets                             // 卡项详情页
│  │                   Order.ets                                  // 订单列表页
│  │                   OrderDetail.ets                            // 订单详情页
│  │                   ShowAllCards.ets                           // 本店卡项页
│  │                   UserCards.ets                              // 已购卡项列表页
│  ├─course      
│  │  └─src
│  │      └─main
│  │         └─ets
│  │            ├─book
│  │            │    AddBooking.ets                            // 新增预约页
│  │            │    BookingDetail.ets                         // 预约详情页
│  │            │    BookingRecord.ets                         // 预约记录列表页
│  │            │    BookMain.ets                              // 课程预约入口页
│  │            │    ConfirmBooking.ets                        // 确认预约页
│  │            │
│  │            ├─components  
│  │            │    Consulting                                // 咨询组件
│  │            │    CourseContent.ets                         // 课程内容展示组件 
│  │            │    RecordContent.ets                         // 课程预约记录展示组件
│  │            │    StoreData.ets                             // 门店数据 
│  │            │    StoreSelect.ets                           // 门店选择
│  │            │
│  │            ├─course
│  │            │    UserCourses.ets                           // 已购课程列表页
│  │            │    CourseDetail.ets                          // 课程详情页
│  │            │    ShowAllCourse.ets                         // 本店所有课程列表页
│  │            │         
│  │            ├─generated
│  │            │    RouterBuilder.ets                         // 路由构建类      
│  │            └─util 
│  │                 SystemSceneUtils.ets                      // 系统场景工具类   
│  └─vip
│      └─src
│          └─main
│             └─ets
│                ├─components
│                │      QrCodeDialog.ets                          // 会员码弹窗
│                │      UserInfoCard.ets                          // 用户会员卡片     
│                │      
│                ├─generated
│                │      RouterBuilder.ets                         // 路由构建类
│                │      
│                └─pages
│                       MineInfoPage.ets                          // 个人信息页
│          	            SettingPage.ets                           // 设置页面
│                      
└─products
   └─phone
       └─src
           └─main
              └─ets
           	     ├─common
          	     │      TabConstants.ets                          // 应用Tab常量
           	     │      
           	     ├─entryability
          	     │      EntryAbility.ets                          // 应用主窗口
           	     │      
           	     ├─generated
           	     │      RouterBuilder.ets                         // 路由构建类
           	     │      
           	     ├─pages
          	     │      CitySelect.ets                            // 城市选择
          	     │      ClubEnvironmentDetail.ets                 // 俱乐部环境页
           	     │      Home.ets                                  // 首页
           	     │      Index.ets                                 // 主页面
           	     │      Mine.ets                                  // 我的
           	     │      SettingPage.ets                           // 设置页面
           	     │      SportDetail.ets                           // 运动详情页
           	     │
           	     ├─phoneformability
           	     │      PhoneFormAbility.ets                      // 服务卡片窗口
           	     │      
           	     ├─viewmodels                                     // 视图模型
           	     │      
           	     └─widget
           	            WidgetCard.ets                            // 服务卡片页面入口
           	            WidgetMidCard.ets                         // 2*4服务卡片页面
           	            WidgetSmallCard.ets                       // 2*2服务卡片页面
```

## 约束与限制

### 环境
* DevEco Studio版本：DevEco Studio 6.0.2 Release及以上
* HarmonyOS SDK版本：HarmonyOS 6.0.2 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* 系统版本：HarmonyOS 5.0.5(17)及以上

### 权限
* 网络权限：ohos.permission.INTERNET
* 读取日历信息权限：ohos.permission.READ_CALENDAR
* 更改日历信息权限：ohos.permission.WRITE_CALENDAR


## 快速入门

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建元服务，将包名配置到模板中。

   a. 参考[创建元服务](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为元服务创建APP ID，并将APP ID与元服务进行关联。

   b. 返回应用列表页面，查看元服务的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建元服务的包名。

2. 配置华为账号服务。

   a. 将元服务的client ID配置到products/phone/src/main模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-atomic-client-id)。

   b. 如需获取用户真实手机号，需要申请phone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-permissions)，并在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-get-phonenumber)。

3. 配置推送服务。

   a. [开通推送服务](https://developer.huawei.com/consumer/cn/doc/atomic-guides/push-as-prepare)。

   b. 开通服务并选择订阅模板，获取模板ID，详细参考：[开通服务通知并选择订阅模板](https://developer.huawei.com/consumer/cn/doc/atomic-guides/push-as-service-noti)。

   c. 将模板ID填充到features/course/src/main/ets/book/BookingDetail.ets中。

   ```
   @Local entityIds: string = 'xxx';// todo 推送服务通知模板ID
   ```
   
   d. 将模板ID填充到features/course/src/main/ets/components/RecordContent.ets中。

   ```
   @Local entityIds: string = 'xxx';// todo 推送服务通知模板ID
   ```
   
   [说明]
   本模板只包含客户端侧代码的实现，如需完整体验推送能力，还需要补充服务端开发。详细参考：[推送基于账号的订阅消息](https://developer.huawei.com/consumer/cn/doc/atomic-guides/push-as-send-sub-noti)。

4. 对元服务进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)

5. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)

###  运行调试工程

1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'phone' ”或者“Run > Debug 'phone' ”，运行或调试模板工程。

## 示例效果

[功能展示录屏](./screenshots/sample.gif)

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。

