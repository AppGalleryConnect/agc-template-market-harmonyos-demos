# 教育（备考）应用模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍

您可以基于此模板直接定制应用，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

| 组件                   | 描述                | 使用指导                                             |
|----------------------|-------------------|--------------------------------------------------|
| 一键登录组件（login_info）   | 支持华为一键登录          | [使用指导](components/login_info/README.md)    |
| 多功能答题组件（answer_questions） | 展示题库样式            | [使用指导](components/answer_questions/README.md)             |
| 多级分栏组件（select_category） | 多级别选项样式           | [使用指导](components/select_category/README.md)    |
| 搜索组件（search）         | 本组件提供了搜索的相关功能     | [使用指导](components/search/README.md)         |
| 一键搜题组件（search_question） | 多功能搜题组件           | [使用指导](components/search_question/README.md)       |
| 通用问题反馈组件（feedback）    | 问题反馈组件            | [使用指导](components/feedback/README.md)       |
| 通用支付组件（aggregated_payment） | 支持华为支付，微信支付，支付宝支付 | [使用指导](components/aggregated_payment/README.md)  |
| 广告组件（aggregated_ads）        | 支持展示开屏广告         | [使用指导](components/aggregated_ads/README.md)        |
| 通用分享组件（aggregated_share）    | 支持分享到微信好友、朋友圈、QQ、微博等方式，支持碰一碰分享、生成海报、系统分享等功能    | [使用指导](components/aggregated_share/README.md)      |
| 通用会员组件（membership）            | 支持应用内支付实现会员开通的能力 | [使用指导](components/membership/README.md)            |
| 通用应用内设置组件（app_setting）      | 支持设置基础设置项        | [使用指导](components/app_setting/README.md)           |


本模板为备考类应用提供了常用功能的开发样例，模板主要分练习、课程和我的三大模块：

- 练习：展示类别分栏选项、搜索课程、练习模式、刷题进度
- 课程：按类别展示精选课程与已购课程
- 我的：账号相关信息，展示订单、错题、收藏、浏览记录，以及设置等功能。

本模板已集成华为账号服务，只需做少量配置和定制即可快速实现华为账号的登录等功能。

| 练习                                                   | 课程                                                   | 我的                                                   |
|------------------------------------------------------|------------------------------------------------------|------------------------------------------------------|
| <img src="screenshots/001.jpg" alt="练习" width="300"> | <img src="screenshots/002.jpg" alt="课程" width="300"> | <img src="screenshots/003.jpg" alt="练习" width="300"> |

本模板主要页面及核心功能清单如下所示：

```ts
题库模板
 |-- 开屏页
 |-- 练习
 |    |-- banner
 |    |-- 搜索
 |    └-- 答题练习
 |-- 课程
 |    |-- 分类列表
 |    |-- 精选课程
 |    |    |-- 课程详情
 |    |    └-- 支付购买
 |    └-- 已购我的课程
 |         |-- 练习模式
 |         |-- 考试模式
 |         |-- 错题记录
 |         └-- 收藏记录
 |         └-- 笔记记录
 └-- 我的
      |-- 用户信息
      |    |-- 登录
      |    |-- 用户信息
      |-- 我的订单
      |-- 我的错题
      |-- 我的收藏
      |-- 练习记录
      |-- 浏览记录
      |-- 意见反馈
      └-- 设置
           |-- 个人信息
           |-- 夜间模式
           |-- 隐私协议
           |-- 关于
           |-- 清除缓存
           └-- 退出登录
    
           
```

本模板工程代码结构如下所示：

```
Exam
  ├─commons/commonLib/src/main
  │  ├─ets
  │  │  ├─components
  │  │  │      CommonHeader.ets                 // 一级页面标题组件
  │  │  │      TopBar.ets                       // 标题菜单内容组件
  │  │  │      Banner.ets                       // banner组件
  │  │  ├─constants
  │  │  │      RouterMap.ets                    // 路由
  │  │  │      CommonConstants.ets              // 公共常量  
  │  │  ├─models
  │  │  │      BaseViewModel.ets                // base模型  
  │  │  │      BreakpointModel.ets              // 断点模型    
  │  │  ├─utils
  │  │  │      BreakpointUtils.ets              // 断点工具
  │  │  │      ContextUtils.ets                 // 上下文
  │  │  │      RouterModule.ets                 // 路由工具
  │  │  │      Logger.ets                       // 日志
  │  │  │      PreferenceUtil.ets               // 首选项
  │  │  │      SystemBarOperation.ets           // 顶部状态栏颜色设置  
  │  │  ├─viewModel
  │  │  │      BrowsingHistoryModel.ets         // 记录模块数据模型
  │  │  │      OrderInfo.ets                    // 订单数据模型
  │  │  │      PracticeRecordModel.ets          // 练习数据模型
  │  └─resources
  │─components 
  │  ├─aggregated_ads
  │  ├─aggregated_payment
  │  ├─aggregated_share
  │  ├─answer_questions
  │  ├─app_setting  
  │  ├─base_select
  │  ├─customer_service_chat
  │  ├─feedback
  │  ├─feed_back
  │  ├─image_preview
  │  ├─login_info
  │  ├─membership      
  │  ├─search
  │  ├─search_question
  │  └─select_category  
  │─features/homePage/src/main   
  │  ├─ets
  │  │  ├─components                             // 封装组件
  │  │  │      CourseBookComponent.ets           // 资料卡片组件        
  │  │  │      CourseComponent.ets               // 课程卡片
  │  │  │      SearchQuestionPage.ets            // 问题搜索组件
  │  │  │      TopTabsBuilder.ets                // 顶部搜索组件          
  │  │  ├─model
  │  │  │     ChapterPractice.ets                // 分类页面数据模型
  │  │  │     CommonTopic.ets                    // 分类数据模型
  │  │  │     Course.ets                         // 课程数据模型  
  │  │  │     CourseArray.ets                    // 课程数组模型
  │  │  │     CourseBook.ets                     // 资料模型
  │  │  │     CourseQuestions.ets                // 科目数据模型
  │  │  │     MaterialModel.ets                  // 下载资料数据模型  
  │  │  │     PracticeMode.ets                   // 业务类型数据模型  
  │  │  │     TopicItemModel.ets                 // 答题类型数据模型  
  │  │  │     TopicModel.ets                     // 分类数据源  
  │  │  ├─pages
  │  │  │      ChapterPractice.ets               // 科目页面
  │  │  │      FeaturedCourses.ets               // 精选课程页面
  │  │  │      MainPage.ets                      // 练习首页面
  │  │  │      MaterialDownload.ets              // 资料页面
  │  │  │      SearchIndexPage.ets               // 搜索页面
  │  │  │      SearchInputPage.ets               // 搜索输入框页面  
  │  │  │      SecondListPage.ets                // 2级分类
  │  │  │      ThirdListPage.ets                 // 3级分类
  │  │  │      TopicHomePage.ets                 // 1级分类  
  │  │  ├─utils
  │  │  │      FileViewUtil.ets                  // 文件预览工具类    
  │  │  ├─viewmodels
  │  │  │      HomeVM.ets                        // 数据模型   
  │  └─resources
  │─features/topicPage/src/main   
  │  ├─ets
  │  │  ├─views
  │  │  │      AnswerQuestionsPage.ets           // 答题模式一页面
  │  │  │      AnswerQuestionsTwoPage.ets        // 答题模式二页面
  │  │  │      CourseHomePage.ets                // 课程页面
  │  │  │      CourseIntroductionPage.ets        // 课程详情页面
  │  │  │      ExamResultPage.ets                // 答题结果页面
  │  │  │      GoodCourseDetailPage.ets          // 精选课程页面
  │  │  │      MockTestPage.ets                  // 科目练习页面
  │  │  │      MyCollectionPage.ets              // 收藏页面
  │  │  │      MyNotesPage.ets                   // 笔记页面
  │  │  │      MyWrongPage.ets                   // 错题页面
  │  │  │      TestReportPage.ets                // 测试报告页面
  │  │  │      ViewNotePage.ets                  // 笔记组件
  │  │  └─viewModel
  │  │  │      CourseHomeModel.ets               // 课程页面数据模型
  │  │  │      PracticeMode.ets                  // 科目数据模型
  │  │  │      SecondListModel.ets               // 选项类型数据模型
  │  │  │      TopicVM.ets                       // 数据模型 
  │─features/minePage/src/main   
  │  ├─ets
  │  │  ├─components
  │  │  │      Header.ets                        // Header组件
  │  │  │      DarkColorDialog.ets               // 深色模式弹框
  │  │  │      MainArea.ets                      // 表格组件内容区
  │  │  │      ScrollComponent.ets               // 表格组件滚动区
  │  │  │      TableRow.ets                      // 表格表头组件        
  │  │  ├─viewModel                              
  │  │  │      MessageModel.ets             
  │  │  │      setUpModel.ets                    // 设置相关模型数据模型
  │  │  │      MineModel.ets                     // 用户资料信息数据模型
  │  │  │      SettingSelectPop.ets              // pop弹框  
  │  │  │      MineVM.ets                        // 数据模型  
  │  │  ├─views
  │  │  │      AboutPage.ets                     // 关于页面
  │  │  │      AuthenticationPage.ets            // 用户认证协议页面
  │  │  │      BrowsingHistoryPage.ets           // 浏览页面
  │  │  │      CollectionPage.ets                // 课程收藏页面
  │  │  │      CoursePage.ets                    // 课程精选页面
  │  │  │      EditPersonalCenterPage.ets        // 个人信息详情页面
  │  │  │      MessageCenterPage.ets             // 消息页面
  │  │  │      MinePage.ets                      // 我的页面
  │  │  │      MyOrderPage.ets                   // 订单首页页面
  │  │  │      OneDayPracticeRecordsPage.ets     // 单个练习记录页面
  │  │  │      OrderDetailPage.ets               // 订单详情页面
  │  │  │      OrderListPage.ets                 // 订单页面
  │  │  │      PracticeDetailsPage.ets           // 反馈页面
  │  │  │      PracticeRecordsPage.ets           // 练习记录页面
  │  │  │      PrivacyAgreementPage.ets          // 同意
  │  │  │      PrivacyPage.ets                   // 协议
  │  │  │      PrivacyStatementPage.ets          // 隐私页面
  │  │  │      SetupPage.ets                     // 设置页面
  │  │  │      TermsOfServicePage.ets            // 用户服务页面
  └─products/entry/src/main   
     ├─ets
     │  ├─entryability
     │  │      EntryAbility.ets                  // 应用程序入口
     │  ├─entrybackupability
     │  │      EntryBackupAbility.ets            // Backup配置入口
     │  ├─entryformAbility
     │  │      EntryFormAbility.ets              // 卡片配置入口 
     │  ├─pages
     │  │      Index.ets                         // 入口页面
     │  │      LaunchAdPage.ets                  // 开屏广告页面
     │  │      LoginPage.ets                     // login页面
     │  │      MainEntry.ets                     // 主页面
     │  ├─model
     │  │      TabListItem.ets                   // tab数据声明
     │  │      RouterTable.ets                   // 路由表
     │  ├─viewmodels
     │  │      MainVM.ets                        // 页面数据模型
     └─resources
```


## 约束与限制

### 环境

* DevEco Studio版本：DevEco  Studio 6.1.1 Release及以上
* HarmonyOS SDK版本：HarmonyOS 6.1.1 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* 系统版本：HarmonyOS 5.0.5(17)及以上


### 权限

- 网络权限：ohos.permission.INTERNET

### 调试
由于当前模拟器无法兼容支付宝SDK，若您需要在模拟器环境下进行相关测试，请参考支付组件中的[使用说明](components/aggregated_payment/README.md)

## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建HarmonyOS应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

   d. 创建桌面快捷方式需要将模板工程product目录下entry/src/main/resources/base/profile/shortcuts_config.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的client ID配置到product/entry/src/main路径下的module.json5文件中，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号一键登录权限，详细参考：[申请账号权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

3. 配置支付服务。

   华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开发服务等相关配置，本模板仅提供了端侧集成的示例。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)。

4. 配置App Linking服务。

   a. [开通App Linking服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/applinking-enable-applinking)

   b. [在开发者网站上关联应用](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-linking-startupapp#section6903241628)

   c. [在AGC为应用创建关联的网址域名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-linking-startupapp#section1101111611317)

   d. 在products/entry/src/main路径下的module.json5中配置关联的网址域名，详细参考：[在module.json5中配置关联的网址域名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/app-linking-startupapp#section13808113610362)

5. 配置广告服务。

   a. 如果仅调测广告，可使用测试广告位ID：开屏广告：testd7c5cewoj6。

   b. 申请正式的广告位ID。 登录[鲸鸿动能媒体服务平台](https://developer.huawei.com/consumer/cn/service/ads/publisher/html/index.html?lang=zh) 进行申请，具体操作详情请参见[展示位创建](https://developer.huawei.com/consumer/cn/doc/distribution/monetize/zhanshiweichuangjian-0000001132700049)。

6. 对应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

7. 添加手工签名所用证书对应的公钥指纹。详细参考：[配置公钥指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)

### 运行调试工程

1. 连接调试手机和PC。

2. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

| 订单                                                       | 答题                                                       | 支付                                                       |
|----------------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------|
| <img src="screenshots/exam_01.jpg" alt="订单" width="300"> | <img src="screenshots/exam_02.jpg" alt="答题" width="300"> | <img src="screenshots/exam_03.jpg" alt="支付" width="300"> |


## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
