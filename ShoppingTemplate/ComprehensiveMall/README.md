# 购物（商城）模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [环境要求](#环境要求)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [权限要求](#权限要求)
- [开源许可协议](#开源许可协议)

## 功能介绍

本模板为综合商城元服务提供了常用功能的开发样例，模板主要分首页、分类、购物车、和我的四大模块：

* 首页：主要提供商品搜索、卡片轮播、分类选择、商品浏览等功能。

* 分类：按照类别展示商品列表和购买商品。

* 购物车：展示已添加的商品，支持商品数量的修改，商品删除、结算等操作。

* 我的：展示个人信息、订单管理入口以及联系客服功能。

本模板已集成华为账号、通话、华为支付等服务，只需做少量配置和定制即可快速实现华为账号的登录、一键拨打服务电话、商品购买等功能。

| 首页                               | 分类                               | 购物车                           | 我的                              |
|----------------------------------|----------------------------------|-------------------------------|---------------------------------|
| ![首页](./screenshot/home.jpg)     | ![分类](./screenshot/category.jpg) | ![购物车](./screenshot/cart.jpg) | ![我的](./screenshot/profile.jpg) |

本模板主要页面及核心功能如下所示：

```ts
综合商城模板
 |-- 首页
 |    |-- 搜索建议轮播
 |         |-- 搜索页
 |              |-- 搜索键入
 |              |-- 搜索候选词展示
 |              |-- 搜索结果展示
 |    |-- 图片轮播
 |    |-- 分类项展示
 |         |-- 分类浏览页
 |    |-- 商品卡片瀑布流
 |         |-- 商品详情页
 |              |-- 商品轮播图
 |              |-- 商品信息展示
 |              |-- 购物车入口
 |              |-- 商品规格选择器
 |                   |-- 库存状态展示
 |                   |-- 可选状态展示
 |                   |-- 规格信息展示
 |                   |-- 数量修改
 |                   |-- 加入购物车
 |                   |-- 发起预下单
 |-- 分类
 |    |-- 商品搜索
 |    |-- 商品分类浏览
 |-- 购物车
 |    |-- 购物车管理
 |         |-- 批量删除选中商品
 |    |-- 购物车结算
 |         |-- 批量结算选中商品
 |    |-- 删除单一商品
 |    |-- 修改商品购买数量
 |    |-- 展示选中商品总价
 |    |-- 展示商品推荐列表
 └-- 我的
      |-- 账号关联
      |-- 个人信息展示
      |-- 订单管理
      |    |-- 全部
      |    |-- 待发货
      |    |-- 已发货
      |    |-- 退款/售后
      └-- 联系客服
```

本模板工程代码结构如下所示：

```
├──modules
│  ├──common
│  │  ├──cache
│  │  │  └──src/main
│  │  │     ├──ets/model
│  │  │     │      Product.ets                         // 商品相关缓存
│  │  │     │      Search.ets                          // 搜索相关缓存
│  │  │     └──ets
│  │  │            Cache.ets                           // 缓存管理类
│  │  ├──const
│  │  │  └──src/main
│  │  │     └──ets
│  │  │            Config.ets                          // 全局配置常量定义
│  │  │            Style.ets                           // 全局样式常量定义
│  │  ├──customtypes
│  │  │  └──src/main
│  │  │     ├──ets/api
│  │  │     │      ProductInfo.ets                     // 商品信息接口类型
│  │  │     ├──ets/viewmodel
│  │  │     │      CartCardVM.ets                      // 购物车卡片模型 (ViewModel)
│  │  │     │      OrderCardVM.ets                     // 订单卡片模型 (ViewModel)
│  │  │     │      OrderSkuVM.ets                      // 订单 Sku 模型 (ViewModel)
│  │  │     └──ets
│  │  │            ApiRequest.ets                      // Api 请求类型
│  │  │            ApiResponse.ets                     // Api 响应类型
│  │  │            ComponentEntry.ets                  // 组件实体类型
│  │  │            CustomType.ets                      // 自定义类型
│  │  │            EnumType.ets                        // 枚举类型
│  │  ├──data
│  │  │  └──src/main
│  │  │     ├──ets/model
│  │  │     │      GlobalStateMgr.ets                  // 全局状态数据管理类
│  │  │     │      Persistence.ets                     // 持久化数据管理类
│  │  │     └──ets
│  │  │            IData.ets                           // 数据处理中心
│  │  ├──network
│  │  │  └──src/main
│  │  │     ├──ets/api
│  │  │     │      CardList.ets                        // 卡片列表相关请求封装
│  │  │     │      Cart.ets                            // 购物车相关请求封装
│  │  │     │      Homepage.ets                        // 首页相关请求封装
│  │  │     │      Order.ets                           // 订单相关请求封装
│  │  │     │      Product.ets                         // 商品相关请求封装
│  │  │     │      Search.ets                          // 搜索相关请求封装
│  │  │     │      User.ets                            // 用户相关请求封装
│  │  │     ├──ets/mock
│  │  │     │      MockDatabase.ets                    // Mock 模拟数据库
│  │  │     │      MockDataMgr.ets                     // Mock 数据管理类
│  │  │     ├──ets/utils
│  │  │     │      MathUtil.ets                        // 数学工具类
│  │  │     │      MockUtil.ets                        // Mock 工具类
│  │  │     └──ets
│  │  │            HttpClient.ets                      // Http 客户端
│  │  │            MockServer.ets                      // Mock 服务器
│  │  ├──resource
│  │  │  ├──src/main
│  │  │  │  └──ets
│  │  │  │         IResourceMgr.ets                    // 资源管理类
│  │  │  └──src/main/resources
│  │  └──router/Index.ets                              // 单例路由模块
│  ├──components
│  │  ├──callbutton
│  │  │  ├──src/main
│  │  │  │  └──ets
│  │  │  │         CallButton.ets                      // 拨号按钮业务组件
│  │  │  └──src/main/resources
│  │  ├──igrid
│  │  │  └──src/main
│  │  │     └──ets
│  │  │            IGrid.ets                           // 自定义网格组件
│  │  ├──irow
│  │  │  └──src/main
│  │  │     └──ets
│  │  │            IRow.ets                            // 自定义行组件
│  │  ├──iwaterflow
│  │  │  └──src/main
│  │  │     ├──ets/logic
│  │  │     │      IWaterFlowLogic.ets                 // 自定义瀑布流组件逻辑层
│  │  │     └──ets
│  │  │            IWaterFlow.ets                      // 自定义瀑布流组件
│  │  ├──loginbutton
│  │  │  └──src/main
│  │  │     └──ets
│  │  │            LoginButton.ets                     // 登录按钮业务组件
│  │  ├──tabswiper
│  │  │  └──src/main
│  │  │     ├──ets/common
│  │  │     │      Const.ets                           // TabSwiper 常量定义
│  │  │     ├──ets/model
│  │  │     │      TabSwiperAttribute.ets              // TabSwiper 属性定义
│  │  │     │      TabSwiperContext.ets                // TabSwiper 上下文
│  │  │     │      TabSwiperTypes.ets                  // TabSwiper 类型定义
│  │  │     ├──ets/nodes
│  │  │     │      TabsNodeController.ets              // 页签节点控制层
│  │  │     │      TrackNodeController.ets             // 轨道节点控制层
│  │  │     ├──ets/nodes/builder
│  │  │     │      TabsContainer.ets                   // 页签容器
│  │  │     │      Track.ets                           // 页签容器所处轨道
│  │  │     └──ets
│  │  │            TabSwiper.ets                       // TabSwiper 组件
│  │  └──titlebar
│  │     ├──src/main
│  │     │  └──ets
│  │     │         TitleBar.ets                        // 标题栏组件
│  │     └──src/main/resources
│  ├──guis
│  │  ├──browser
│  │  │  └──src/main
│  │  │     ├──ets/config
│  │  │     │      CategoryBrowserConfig.ets           // 分类浏览组件配置类
│  │  │     ├──ets/logic
│  │  │     │      CategoryBrowserLogic.ets            // 分类浏览组件逻辑层
│  │  │     ├──ets/model
│  │  │     │      Category.ets                        // 分类浏览组件分类项建模
│  │  │     │      CategoryIndicatorDot.ets            // 分类浏览组件指示器建模
│  │  │     │      CategoryTypes.ets                   // 分类浏览组件类型定义
│  │  │     ├──ets/utils
│  │  │     │      CategoryUtils.ets                   // 分类浏览工具类
│  │  │     └──ets
│  │  │            CategoryBrowser.ets                 // 分类浏览组件
│  │  ├──cards
│  │  │  └──src/main
│  │  │     ├──ets/logic
│  │  │     │      ProductCardLogic.ets                // 商品卡片逻辑层
│  │  │     ├──ets/model
│  │  │     │      ProductCardModel.ets                // 商品卡片建模
│  │  │     ├──ets/wrapper
│  │  │     │      ImageContentWrapper.ets             // 图片内容封装器
│  │  │     │      TagContentWrapper.ets               // 标签内容封装器
│  │  │     │      TextContentWrapper.ets              // 文本内容封装器
│  │  │     └──ets
│  │  │            ProductCard.ets                     // 商品卡片组件
│  │  ├──search
│  │  │  ├──src/main
│  │  │  │  ├──ets/logic
│  │  │  │  │      SearchSuggestionCarouselLogic.ets   // 搜索建议轮播逻辑层
│  │  │  │  └──ets
│  │  │  │         ProductGhostSearchBar.ets           // 幽灵搜索栏(不负责实际键入功能的搜索栏)
│  │  │  │         SearchSuggestionCarousel.ets        // 搜索建议轮播组件
│  │  │  └──src/main/resources
│  │  └──tabs
│  │  │  ├──src/main
│  │  │  │  ├──ets/logic
│  │  │  │  │      IconTextTabLogic.ets                // 图文页签逻辑层
│  │  │  │  │      OrderTabLogic.ets                   // 订单页签逻辑层
│  │  │  │  ├──ets/model
│  │  │  │  │      IconTextTabModel.ets                // 图文页签模型
│  │  │  │  └──ets
│  │  │  │         IconTextTab.ets                     // 图文页签组件
│  │  │  │         OrderTab.ets                        // 订单页签组件
│  │  │  └──src/main/resources
│  └──scene
│     ├──order
│     │  ├──src/main
│     │  │  ├──ets/logic
│     │  │  │      OrderBrowsingPageLogic.ets          // 订单浏览页逻辑层
│     │  │  │      OrderListPageLogic.ets              // 订单列表页逻辑层
│     │  │  │      OrderSearchPageLogic.ets            // 订单搜索页逻辑层
│     │  │  └──ets/pages
│     │  │         OrderBrowsingPage.ets               // 订单浏览页
│     │  │         OrderListPage.ets                   // 订单列表页
│     │  │         OrderSearchPage.ets                 // 订单搜索页
│     │  └──src/main/resources
│     └──shopping
│        ├──src/main
│        │  ├──ets/dialog
│        │  │      SkuSelector.ets                     // 商品规格选择器
│        │  ├──ets/logic
│        │  │      CartPageLogic.ets                   // 购物车页面逻辑层
│        │  │      OrderSubmitPageLogic.ets            // 订单提交页逻辑层
│        │  │      ProductInfoPageLogic.ets            // 商品信息页逻辑层
│        │  │      ProductSearchPageLogic.ets          // 商品搜索页逻辑层
│        │  │      ProductSearchResultsPageLogic.ets   // 商品搜索结果页逻辑层
│        │  │      SkuSelectorLogic.ets                // 商品规格选择器逻辑层
│        │  │      SubCategoryPageLogic.ets            // 子分类页逻辑层
│        │  ├──ets/model
│        │  │      ProductInfo.ets                     // 商品详情建模
│        │  │      ProductSelectionInfo.ets            // 商品规格信息建模
│        │  ├──ets/pages
│        │  │      CartPage.ets                        // 购物车页面
│        │  │      OrderSubmitPage.ets                 // 订单提交页面
│        │  │      ProductInfoPage.ets                 // 商品详情页面
│        │  │      ProductSearchPage.ets               // 商品搜索页面
│        │  │      ProductSearchResultsPage.ets        // 商品搜索结果页面
│        │  │      SubCategoryPage.ets                 // 子分类页面
│        │  └──ets/viewmodel
│        │         SpecItemVM.ets                      // 商品规格项建模 (ViewModel)
│        └──src/main/resources
└──products
   └──entry
      ├──src/main
      │  ├──ets/datas
      │  │      IndexData.ets                          // 索引页静态数据
      │  ├──ets/entryability
      │  │      EntryAbility.ets                       // 应用程序入口
      │  ├──ets/logic
      │  │      CategoryPageLogic.ets                  // 分类页逻辑层
      │  │      HomePageLogic.ets                      // 首页逻辑层
      │  │      IndexLogic.ets                         // 索引页逻辑层
      │  │      ProfilePageLogic.ets                   // 我的页逻辑层
      │  └──ets/pages
      │         CategoryPage.ets                       // 分类页
      │         HomePage.ets                           // 首页
      │         Index.ets                              // 索引页
      │         ProfilePage.ets                        // 我的页
      └──src/main/resources
```

## 环境要求

### 软件

* DevEco Studio版本：DevEco Studio 5.0.1 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.1 Release SDK及以上

### 硬件

* 设备类型：华为手机（直板机）
* HarmonyOS版本：HarmonyOS 5.0.1 Release及以上

## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在DevEco Studio中打开此模板。

2. 在AppGallery Connect创建元服务，将包名配置到模板中。

   a. 参考[创建元服务](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为元服务创建APPID，并进行关联。

   b. 返回应用列表页面，查看元服务的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建元服务的包名。

3. 配置华为账号服务。

   a. 将元服务的client ID配置到模板工程根目录下products/entry模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-atomic-client-id)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

   c. 如需获取用户真实手机号，需要申请phone权限，详细参考：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-permissions)，并在端侧使用快速验证手机号码Button进行[验证获取手机号码](https://developer.huawei.com/consumer/cn/doc/atomic-guides/account-guide-atomic-get-phonenumber)。

4. 配置支付服务。

   华为支付当前仅支持商户接入，在使用服务前，需要完成商户入网、开发服务等相关配置，本模板仅提供了端侧集成的示例。详细参考：[支付服务接入准备](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/payment-preparations)。

### 运行调试工程

1. 连接调试手机和PC。

2. 对元服务[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)。

3. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

1. 购物场景

   [购物场景展示](./screenshot/shopping.mp4)

2. 购物车

   [购物车功能展示](./screenshot/cart.mp4)

## 权限要求

* 网络权限：ohos.permission.INTERNET

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。
