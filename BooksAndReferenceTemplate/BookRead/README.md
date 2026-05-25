# 阅读与工具书（电子书）应用模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍
您可以基于此[模板](#模板)直接定制应用，也可以挑选此模板中提供的多种[组件](#组件)使用，从而降低您的开发难度，提高您的开发效率。

本模板中提供了多种组件，您可以按需选择合适的组件进行使用，所有组件存放在工程根目录的components下。

| 组件                            | 描述                                           | 使用指导                                       |
|-------------------------------|----------------------------------------------|--------------------------------------------|
| 广告组件（aggregated_ads）          | 提供了华为广告平台展示开屏广告的能力。                          | [使用指导](./components/aggregated_ads/README.md)|
| 通用分享组件（aggregated_share）      | 支持分享到微信好友、朋友圈、QQ、微博等方式，支持碰一碰分享、生成海报、系统分享等功能  | [使用指导](components/aggregated_share/README.md)    |
| 推送组件（custom_push）             | 本组件提供了推送组件功能。                                | [使用指导](components/custom_push/README.md)      |
| 通用客服组件（customer_service_chat） | 提供了原生的聊天交互界面，支持完整的客服对话功能，包括文字、表情、图片、地址等基础交互。 | [使用指导](components/customer_service_chat/README.md)  |
| 通用拨号组件（dial_panel）               | 提供拨号能力的组件                                    | [使用指导](components/dial_panel/README.md)        |
| 通用图片预览组件（image_preview）   | 提供了图片预览相关功能                                  | [使用指导](components/image_preview/README.md)|
| 激励广告组件（incentive_ad）      | 展示激励广告的相关功能。                                 | [使用指导](components/incentive_ad/README.md)  |
| 通用会员组件（membership）        | 支持应用内支付实现会员开通的能力                             | [使用指导](components/membership/README.md)|
| 申请权限许可组件（module_privacy_agreement） | 可以在应用首启需要用户同意隐私政策和其他协议时使用。                   | [使用指导](components/module_privacy_agreement/README.md)   |
| 阅读器工具栏组件（reader_tool_bar）     | 支持在阅读器工具展示常用功能，例如目录选择、字体、字号、行间距、背景设置等。       | [使用指导](components/reader_tool_bar/README.md) |
| 滑动卡片组件（swiper_card）           | 展示可滑动图片组。                                    | [使用指导](components/swiper_card/README.md)   |

本模板为电子书类应用提供了常用功能实现案例，涵盖了从书籍获取、阅读体验到个性化管理的核心环节，模板主要分阅读、书架、书城、分类和我的五大模块：

- 阅读：支持电子书阅读功能及阅读工具（目录导航、字体调整、屏幕亮度调节与深色模式等功能）。
- 书架：提供书籍列表浏览、阅读历史追踪、阅读进度保存、搜索及书籍管理功能。
- 书城：支持历史搜索、热门搜索，并支持“今日力荐”和“猜你喜欢”两种内容推荐功能。
- 分类：支持按男频/女频等大类划分，并支持细分类别的探索，便于找到感兴趣的特定类型作品。
- 我的：支持华为账号登录、个性化阅读偏好设置、账户内资产（书币、会员权益）、活动中心以及问题与反馈等功能。

| 阅读                               | 书架                               | 书城                                  | 分类                              | 我的                               |
|----------------------------------|----------------------------------|-------------------------------------|---------------------------------|----------------------------------|
| ![book_read](docs/book_read.jpg) | ![book_shelf](docs/book_shelf.jpeg) | ![book_store](docs/book_store.jpeg) | ![category](docs/category.jpeg) | ![book_person](docs/person.jpeg) |

本模板主要页面涉核心功能清单如下所示：

```ts
阅读听书模板
|--  阅读
 |    |-- 阅读界面
 |    |-- 章节目录
 |    |-- 亮度调整
 |    |-- 深色模式
 |    └-- 阅读设置
 |-- 书架
 |    |-- 书籍列表
 |    |-- 浏览历史
 |    |-- 阅读时长记录
 |    |-- 搜索
 |    └-- 书籍管理
 |-- 书城
 |    |-- 今日力荐
 |    └-- 猜你喜欢
 |-- 分类
 |    |-- 男频/女频分类
 |    └-- 热门、都市、玄幻等分类
 └-- 我的
    |-- 用户登录
    |-- 会员中心
    |     └-- 选择套餐并开通会员
    |-- 我的账户
    |     └-- 选择套餐并充值书币
    |-- 福利中心
    |-- 活动中心
    |-- 阅读记录
    |-- 阅读偏好设置
    |     |-- 男频/女频偏好
    |     └-- 热门、都市、玄幻等偏好
    |-- 联系客服
    |-- 问题与反馈
    |     |-- 反馈问题
    |     └-- 反馈记录
    └-- 设置
       |-- 个人信息
       |     └-- 修改头像/昵称/电话
       |-- 阅读设置
       |-- 隐私设置
       |-- 关于
       |-- 清理缓存
       └-- 退出登录
```

本模板工程核心代码结构如下所示：

```
BookRead
├─BookRead/entry/src/main/ets
│ ├─entryability
│ │ └─EntryAbility.ets                     // 应用主入口能力
│ ├─entrybackupability
│ │ └─EntryBackupAbility.ets               // 应用备份恢复能力配置
│ └─pages
│ ├─BookHomePage.ets                       // 应用主页框架
│ └─Index.ets                              // 应用入口默认首页
│
├─BookRead/commons/common/src/main/ets
│ ├─api
│ │ └─BookApi.ets                          // 图书API调用
│ ├─comp
│ │ ├─AggregatedPaymentPicker.ets          // 集成支付选择器组件
│ │ ├─GlobalContext.ets                    // 全局上下文管理类
│ │ ├─TCInvoke.ets                         // 终端云服务调用封装
│ │ ├─TCLogger.ets                         // 终端云日志记录工具
│ │ ├─TCRouter.ets                         // 终端云路由导航管理
│ │ └─Toast.ets                            // 提示消息显示
│ ├─constant
│ │ └─Constants.ets                        // 常量定义文件
│ ├─model
│ │ ├─Book.ets                             // 图书数据模型
│ │ ├─BookSortInfo.ets                     // 图书排序信息模型
│ │ ├─BorrowInfo.ets                       // 借阅信息模型
│ │ ├─FeedbackRecordModel.ets              // 反馈记录模型
│ │ ├─Member.ets                           // 会员信息模型
│ │ ├─PaymentModels.ets                    // 支付相关信息模型
│ │ ├─PreferenceInfo.ets                   // 用户偏好设置模型
│ │ ├─ReadSet.ets                          // 阅读模型
│ │ └─UserInfoModel.ets                    // 用户信息模型
│ ├─ui
│ │ ├─BookCard.ets                         // 图书卡片组件
│ │ ├─CommonUI.ets                         // 基础UI组件
│ │ └─TSearch.ets                          // 搜索功能相关组件
│ ├─utils
│ │ ├─DialogUtil.ets                       // 全局弹窗工具类
│ │ ├─EpubUtils.ets                        // Epub格式相关工具方法
│ │ ├─FileUtils.ets                        // 文件操作工具类
│ │ ├─MathUtil.ets                         // 数学计算工具类
│ │ ├─TimeUtils.ets                        // 时间处理工具类
│ │ ├─UserInfoUtil.ets                     // 用户信息处理工具类
│ │ └─WindowUtils.ets                      // 窗口或界面尺寸相关工具
│ └─viewmodel
│   ├─MemberCenterVM.ets                   // 会员中心逻辑模型
│   ├─RechargeRecordVM.ets                 // 充值记录逻辑模型
│   └─RechargeVM.ets                       // 充值功能业务逻辑模型
│
├─BookRead/feature/book_home/src/main/ets
│ ├─comps
│ │ ├─BookListCard.ets                     // 图书列表卡片式展示组件
│ │ ├─BookSwiperCard.ets                   // 图书轮播图展示卡片
│ │ ├─BookViewCard.ets                     // 图书详情视图卡片
│ │ ├─BookWaterFlowCard.ets                // 图书瀑布流布局组件
│ │ └─HotRankCard.ets                      // 热门排行榜卡片
│ ├─viewModels
│ │ └─SearchViewModels.ets                 // 搜索功能逻辑模型
│ └─views
│   ├─BookListPage.ets                     // 图书列表页面
│   ├─BookViewListPage.ets                 // 带分类的图书列表视图页
│   └─SearchPage.ets                       // 全站搜索功能主页面
│
├─BookRead/feature/book_person/src/main/ets
│ ├─comp
│ │ ├─AccountCard.ets                      // 用户账户余额信息卡片
│ │ ├─ActivityCard.ets                     // 活动信息展示卡片
│ │ ├─CenterToolCard.ets                   // 个人中心工具卡片集
│ │ ├─FileSelect.ets                       // 文件选择器组件
│ │ ├─MembershipCard.ets                   // 会员身份展示卡片
│ │ ├─MyBalanceCard.ets                    // 余额信息展示卡片
│ │ ├─MyInfoCard.ets                       // 个人基本信息展示卡片
│ │ ├─OptionView.ets                       // 选项卡片组件
│ │ ├─SelectAvatarCard.ets                 // 头像选择器组件
│ │ ├─ServiceCard.ets                      // 服务入口卡片
│ │ ├─SignComp.ets                         // 签到卡片
│ │ └─UsrMsgCard.ets                       // 用户信息卡片
│ └─views
│   ├─AboutPage.ets                        // 关于我们信息页
│   ├─AccountPage.ets                      // 账户管理主页面
│   ├─ActivityPage.ets                     // 活动信息列表页
│   ├─DataCollectionPage.ets               // 用户数据采集页
│   ├─DataSharingPage.ets                  // 数据共享协议页
│   ├─FeedbackPage.ets                     // 意见反馈表单页
│   ├─FeedbackRecordPage.ets               // 反馈记录列表页
│   ├─IssueAndFeedbackPage.ets             // 问题反馈页面
│   ├─LibraryPage.ets                      // 我的书馆页面
│   ├─LoginPage.ets                        // 用户登录页
│   ├─MemberAgreementPage.ets              // 会员协议展示页
│   ├─MemberCenterPage.ets                 // 会员中心主界面
│   ├─PersonPage.ets                       // 个人中心主页
│   ├─PreferencePage.ets                   // 偏好设置页面
│   ├─PrivacyPage.ets                      // 隐私设置界面
│   ├─PrivacyPolicyPage.ets                // 隐私政策声明页
│   ├─ReadSettingPage.ets                  // 阅读设置页
│   ├─RechargePage.ets                     // 充值中心主界面
│   ├─RechargeRecordPage.ets               // 充值记录查询页
│   ├─WelfareCenter.ets                    // 福利中心页面
│   └─SettingPage.ets                      // 系统设置综合页面
│
├─BookRead/feature/book_read_kit/src/main/ets
│ ├─components
│ │ ├─BookCoverCard.ets                    // 图书封面展示组件
│ │ ├─ExpandableText.ets                   // 书评展示组件
│ │ ├─ReaderPage.ets                       // 阅读器核心页面
│ │ ├─ReaderTopCard.ets                    // 阅读器顶部控制栏
│ │ └─ShareBookCard.ets                    // 图书分享功能组件
│ ├─model
│ │ └─ReviewModels.ets                     // 图书数据模型
│ ├─pages
│ │ ├─MyReviewPage.ets                     // 我的评价页面
│ │ ├─WonderfulReviewPage.ets              // 精彩书评页面
│ │ ├─WriteCommentPage.ets                 // 写评论页面
│ │ └─WriteReviewPage.ets                  // 全部书评页面
│ ├─utils
│ │ └─ReviewdataUtil.ets                   // 书籍评论工具类
│ └─viewmodel
│   └─WriteReviewVM.ets                    // 书籍评论数据模型
│
├─BookRead/feature/book_shelf/src/main/ets
│ ├─comps
│ │ ├─DeleteBottomCard.ets                 // 书籍删除确认底部弹窗
│ │ └─ManageGroupBottomCard.ets            // 管理分组底部卡片
│ └─views
│   ├─BookGroupContent.ets                 // 书籍分组页
│   └─BookShelfPage.ets                    // 我的书架主界面
│
├─BookRead/feature/book_sort/src/main/ets
│ └─pages
│   └─BookSortPage.ets                     // 图书分类导航页面
│
├─BookRead/components/aggregated_payment/src/main/ets
│ ├─components
│ │ └─AggregatedPaymentPicker.ets          // 集成支付选择器组件
│ ├─model
│ │ └─PaymentModels.ets                    // 支付相关信息模型
│ └─views
│   ├─AggregatedPaymentVM.ets              // 支付组件数据模型
│   ├─MockApi.ets                          // 支付mock数据
│   ├─OrderInfoUtil.ets                    // 支付mock参数工具
│   └─SignUtils.ets                        // 支付mock签名工具
│
├─BookRead/components/base_common/src/main/ets
│ └─components
│   ├─ActionSheet.ets                      // 阅读器底部工具栏
│   └─UserInfo.ets                         // 阅读器用户信息
│
├─BookRead/components/incentive_ad/src/main/ets
│ ├─components
│ │ └─IncentiveAdvertising.ets             // 广告位广告类
│ └─viewmodel
│   └─RewardAdStatusHandler.ets            // 事件订阅
│
├─BookRead/components/reader_tool_bar/src/main/ets
│ └─components
│   └─PushKit.ets                          // 推送组件
│
├─BookRead/components/reader_tool_bar/src/main/ets
│ └─components
│   ├─ReaderToolBar.ets                    // 阅读器底部工具栏
│   └─SelectState.ets                      // 文本选择状态组件
│
└─BookRead/components/swiper_card/src/main/ets
  ├─components
  │ ├─BookSingleSwiper.ets                 // 单图书滑动展示组件
  │ ├─example.ets                          // 组件使用示例
  │ └─TUISwiper.ets                        // 通用滑动卡片组件
  └─model
    ├─Book.ets                             // 图书数据模型定义
    └─LazyDataVM.ets                       // 数据逻辑模型
```


## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 6.0.2 Release及以上
* HarmonyOS SDK版本：HarmonyOS 6.0.2 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* HarmonyOS版本：HarmonyOS 6.0.0(20)及以上

### 权限

- 网络权限：ohos.permission.INTERNET
- 数据网络权限：ohos.permission.GET_NETWORK_INFO
- 允许应用读取开放匿名设备标识符权限：ohos.permission.APP_TRACKING_CONSENT

### 调试

本模板不支持使用模拟器调试，请使用真机进行调试

## 快速入门

###  配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的client ID配置到entry/src/main路径下的[module.json5](./entry/src/main/module.json5)文件中，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号一键登录所需的quickLoginMobilePhone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

3. 配置支付服务。

   华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开发服务等相关配置，本模板仅提供了端侧集成的示例。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)。

4. 对应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

5. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置应用签名证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)。

6. 配置推送服务。

   a. [开启推送服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-config-setting)。
   
   b. 按照需要的权益[申请通知消息自分类权益](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-apply-right)。
   
7. 模拟服务端发送Push消息。

   a. 获取Push Token。
   
   在entry\src\main\ets\entryability\EntryAbility.ets的onCreate()生命周期中通过pushService.getToken()获取Push Token。
   
   可在此上报Push Token到服务端， 调试状态可在控制台打印出pushToken后手动放入components\push_kit\src\main\ets\pushKitForJava\messageBody.json的token中。
   ```json5
   "target": {
      "token": ["xxx"]
   }
   ```
   b. 获取服务账号密钥文件。
   
   获取服务账号密钥文件(components\push_kit\src\main\ets\pushKitForJava\serviceAccountPrivateKey.json)，可参考[获取服务账号密钥文件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-jwt-token)中的开发步骤1。
   
   将获取到的服务账号密钥文件命名为serviceAccountPrivateKey.json替换原有文件。
   
   获取服务账号密钥文件后手动去除"private_key"字段的"'-----BEGIN PRIVATE KEY-----\n'和 '\n-----END PRIVATE KEY-----\n'或在JsonWebTokenFactory.java中去除。
   
   c. 将pushKitForJava所有文件放入java项目中，项目结构如图显示。
   
   <img src="./docs/struct.png" width="300">
   
   检查JsonWebTokenFactory.java中的路径并将String url中的项目id替换为serviceAccountPrivateKey.json的project_id。
   
   运行JsonWebTokenFactory.java即可收到推送。
   
   d. 运行JsonWebTokenFactory.java。
   

### 运行调试工程

1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

|阅读                                | 书架                               | 书城                                  | 分类                              | 我的                               |
|----------------------------------|----------------------------------|-------------------------------------|---------------------------------|----------------------------------|
| ![book_read](docs/book_read.jpg) | ![book_shelf](docs/book_shelf.jpeg) | ![book_store](docs/book_store.jpeg) | ![category](docs/category.jpeg) | ![book_person](docs/person.jpeg) |

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。