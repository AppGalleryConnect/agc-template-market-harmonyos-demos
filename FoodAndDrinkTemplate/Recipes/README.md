# 美食（菜谱）行业模板快速入门

## 目录
- [功能介绍](#功能介绍)
- [环境要求](#环境要求)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [权限要求](#权限要求)
- [开源许可协议](#开源许可协议)

## 功能介绍
本模板为美食菜谱类应用提供了常用功能的开发样例，模板主要分首页、分类和我的三大模块：
- 首页：展示菜谱信息、按名称搜索、按类别搜索。
- 分类：按分类展示菜谱，支持查看详情、收藏菜谱、加入菜篮子和管理菜篮子。
- 我的：展示账号相关信息，展示我的菜谱和上传菜谱，展示我的收藏菜谱，展示浏览记录，以及设置等功能。

本模板已集成华为账号服务，只需做少量配置和定制即可快速实现华为账号的登录等功能。

| 首页                                     | 分类                                                                   | 我的                                                               |
|----------------------------------------|----------------------------------------------------------------------|------------------------------------------------------------------|
| <img src="screenshots/Screenshot_home.png" alt="首页" width="300"> | <img src="screenshots/Screenshot_category.png" alt="分类" width="300"> | <img src="screenshots/Screenshot_mine.png" alt="我的" width="300"> |


本模板主要页面及核心功能清单如下所示：
```ts
美食菜谱模板
 |-- 首页
 |    |-- banner
 |    |-- 搜索
 |    |-- 分类搜索
 |    |    |-- 综合搜索
 |    |    |-- 收藏最多
 |    |    └-- 浏览最多
 |    └-- 菜谱瀑布流
 |-- 分类
 |    |-- 分类列表
 |    |-- 菜谱详情
 |    |    |-- 收藏
 |    |    └-- 加入菜篮子
 |    └-- 菜篮子
 |         |-- 全部用料
 |         |-- 菜谱用料
 |         |-- 菜谱新增用料
 |         └-- 删除菜谱
 └-- 我的
      |-- 用户信息
      |    |-- 登录
      |    └-- 用户信息
      |-- 菜篮子
      |-- 我的菜谱
      |    |-- 新增菜谱
      |-- 我的收藏
      |-- 浏览记录
      └-- 设置
           |-- 个人信息管理
           |-- 隐私协议
           |-- 用户协议
           |-- 清除缓存
           └-- 退出登录
```

本模板工程代码结构如下所示：
```
Recipes
  ├─commons/commonlib/src/main
  │  ├─ets
  │  │  ├─constants
  │  │  │      CommonContants.ets             // 公共常量
  │  │  │      CommonEnums.ets                // 公共枚举值
  │  │  ├─types
  │  │  │      Types.ets                      // 公共抽象类
  │  │  └─utils
  │  │         AccountUtil.ets                // 账号工具类
  │  │         FormatUtil.ets                 // 格式化工具类
  │  │         Logger.ets                     // 日志工具类
  │  │         PermissionUtil.ets             // 权限获取工具类
  │  │         RouterModule.ets               // 路由工具类
  │  │         WindowUtil.ets                 // 窗口管理工具类
  │  └─resources
  ├─commons/network/src/main
  │  ├─ets
  │  │  ├─apis
  │  │  │      APIList.ets                    // 网络请求API
  │  │  │      HttpRequest.ets                // 网络请求
  │  │  ├─mocks
  │  │  │  └─MockData
  │  │  │         Mine.ets                    // 我的mock数据
  │  │  │         RecipeList.ets              // 菜谱mock数据
  │  │  │      AxiosMock.ets                  // mock请求
  │  │  │      RequestMock.ets                // mock API
  │  │  └─types
  │  │         Recipe.ets                     // 菜谱抽象类
  │  └─resources
  │─features/classification/src/main   
  │  ├─ets
  │  │  ├─components
  │  │  │      IngredientsComp.ets            // 用料组件
  │  │  ├─constants
  │  │  │      Enums.ets                      // 枚举数据
  │  │  ├─pages
  │  │  │      ClassificationPage.ets         // 分类页面
  │  │  │      DishesPage.ets                 // 菜谱详情页面
  │  │  │      ShoppingBasketPage.ets         // 菜篮子页面
  │  │  ├─types
  │  │  │      Index.ets                      // 菜谱数据对象
  │  │  └─viewModels
  │  │         ClassificationVM.ets           // 分类页面数据
  │  │         DishesVM.ets                   // 菜谱详情页面数据
  │  │         ShoppingBasketPageVM.ets       // 菜篮子页面数据
  │─features/home/src/main   
  │  ├─ets
  │  │  ├─components
  │  │  │      Banner.ets                     // Banner组件
  │  │  ├─pages
  │  │  │      HomePage.ets                   // 首页页面
  │  │  ├─types
  │  │  │      Index.ets                      // 首页数据对象
  │  │  └─viewModels
  │  │         HomePageVM.ets                 // 首页页面数据
  │─features/mine/src/main   
  │  ├─ets
  │  │  ├─components
  │  │  │      AgreementDialog.ets            // 协议弹窗组件
  │  │  │      ConfirmDialogComponent.ets     // 确认弹窗组件
  │  │  │      Recipes.ets                    // 菜谱卡片组件
  │  │  ├─mapper
  │  │  │      Index.ets                      // 数据映射
  │  │  ├─model
  │  │  │      Index.ets                      // 数据类型
  │  │  ├─pages
  │  │  │      BrowsingHistory.ets            // 浏览历史页面
  │  │  │      MinePage.ets                   // 我的页面
  │  │  │      MyCollection.ets               // 我的收藏页面
  │  │  │      MyRecipe.ets                   // 我的菜谱页面
  │  │  │      PersonalInfo.ets               // 个人信息页面
  │  │  │      PrivacyPolicyPage.ets          // 用户协议页面
  │  │  │      QuickLoginPage.ets             // 一键登录页面
  │  │  │      SettingsPage.ets               // 设置页面
  │  │  │      TermsOfServicePage.ets         // 隐私政策页面
  │  │  │      UploadRecipe.ets               // 上传菜谱页面
  │  │  ├─types
  │  │  │      Index.ets                      // 抽象类
  │  │  └─viewModels
  │  │         BrowsingHistoryVM.ets          // 浏览历史页面数据
  │  │         MinePageVM.ets                 // 我的页面数据
  │  │         MyCollectionVM.ets             // 我的收藏页面数据
  │  │         MyRecipeVM.ets                 // 我的菜谱页面数据
  │  │         SettingsPageVM.ets             // 设置页面数据
  │  │         UploadRecipeVM.ets             // 上传菜谱页面数据
  │  └─resources
  │─features/search/src/main   
  │  ├─ets
  │  │  ├─pages
  │  │  │      ResultPage.ets                 // 搜索结果页面
  │  │  │      SearchPage.ets                 // 搜索页面
  │  │  ├─types
  │  │  │      Index.ets                      // 抽象类
  │  │  └─viewModels
  │  │         SearchPageVM.ets               // 搜索页面数据
  │  └─resources
  └─products/entry/src/main   
     ├─ets
     │  ├─entryability
     │  │      EntryAbility.ets               // 应用程序入口
     │  ├─entryformability
     │  │      EntryFormAbility.ets           // 卡片程序入口
     │  ├─pages
     │  │      MainEntry.ets                  // 入口页面
     │  ├─types
     │  │      Index.ets                      // 抽象类
     │  ├─viewModels
     │  │      MainEntryVM.ets               // 入口页面数据
     │  └─widget/pages
     │         WidgetCard.ets                 // 卡片页面
     └─resources
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

   a. 将应用的client ID配置到entry模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

   c. 如需使用华为账号一键登录，需要申请quickLoginMobilePhone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。在端侧使用“华为账号登录”按钮完成[用户登录](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-unionid-login-button)。

### 运行调试工程

1. 连接调试手机和PC。

2. 对应用[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)。

3. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。


## 示例效果
1. 主要功能  
[主要功能展示](screenshots/ScreenRecord_1.mp4) 


## 权限要求
- 网络权限：ohos.permission.INTERNET

## 开源许可协议
该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
