# 运动健康（健康管理）应用模板快速入门

## 目录

- [功能介绍](#功能介绍)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [开源许可协议](#开源许可协议)

## 功能介绍

您可以基于此模板直接定制应用，也可以挑选此模板中提供的多种组件使用，从而降低您的开发难度，提高您的开发效率。

本模板提供如下组件，所有组件存放在工程根目录的components下，如果您仅需使用组件，可参考对应组件的指导链接；如果您使用此模板，请参考本文档。

| 组件                                  | 描述                                                                                | 使用指导                                                  |
|:------------------------------------|:----------------------------------------------------------------------------------|:------------------------------------------------------|
| 数据看板组件（data_dashboard）            | 提供健康数据可视化展示，支持步数、心率、血压、血糖、睡眠等数据的图表展示和历史记录查看                                  | [使用指导](components/data_dashboard/README.md)       |
| 通用登录组件（aggregated_login）          | 提供华为账号一键登录及其他方式登录（微信、手机号登录），开发者可以根据业务需要快速实现应用登录                          | [使用指导](components/aggregated_login/README.md)     |
| 消息管理组件（message_manager）           | 提供消息展示、已读、未读、删除查看等功能                                                            | [使用指导](components/message_manager/README.md)      |
| 通用问题反馈组件（feedback）                | 提供通用的问题反馈功能                                                                       | [使用指导](components/feedback/README.md)             |
| 检测应用更新组件（check_app_update）        | 提供检测应用是否存在新版本功能                                                                   | [使用指导](components/check_app_update/README.md)     |
| 通用个人信息组件（collect_personal_info） | 支持编辑头像、昵称、姓名、性别、手机号、生日、个人简介等                                                    | [使用指导](components/collect_personal_info/README.md) |

本模板为健康管理类应用提供了完整的开发框架，模板主要分健康、设备和个人三大模块。

本模板主要功能模块：

* 健康：提供运动数据追踪、BMI与体脂率计算、多项健康指标监测（血糖、心率、血压、睡眠）、健康知识、数据可视化分析等功能。

* 设备：提供蓝牙设备连接管理、智能设备数据同步等功能。

* 个人：提供个人信息管理、隐私设置、账号登录、意见反馈等功能。


本模板已集成华为账号、微信登录、应用更新、消息推送等服务，采用模块化架构设计，支持多设备适配，提供完整的状态管理和路由导航解决方案，只需做少量配置和定制即可快速实现健康管理应用的核心功能。

| 健康 | 设备 | 个人 |
|:---:|:---:|:---:|
| <img src="screenshot/health.jpg" alt="健康" width="300"> | <img src="screenshot/device.jpg" alt="设备" width="300"> | <img src="screenshot/person.jpg" alt="个人" width="300"> |

本模板主要页面及核心功能如下所示：

```text
健康管理模板
  ├──健康模块                           
  │   ├──运动数据追踪  
  │   │   ├── 步数统计                          
  │   │   ├── 卡路里消耗                      
  │   │   └── 运动时长                      
  │   │         
  │   ├──健康指标                          
  │   │   ├── 血糖监测（3.9-7.8mmol/L正常范围）
  │   │   ├── 心率监测（60-100次/分正常范围）
  │   │   ├── 血压监测（80-120mmHg正常范围）
  │   │   ├── 睡眠监测（目标8小时，质量评估）
  │   │   └── 健康评估与异常提醒    
  │   │
  │   ├──数据可视化    
  │   │   ├── 图表展示                                             
  │   │   ├── 趋势分析                         
  │   │   └── 历史记录 
  │   │
  │   └──健康知识    
  │       ├── 健康资讯                                             
  │       ├── 运动指导                         
  │       └── 饮食建议
  │
  ├──设备模块                           
  │   ├──设备管理  
  │   │   ├── 蓝牙设备扫描 
  │   │   ├── 设备连接
  │   │   ├── 设备绑定 
  │   │   └── 设备解绑                      
  │   │         
  │   └──数据同步         
  │       ├── 实时数据同步
  │       ├── 历史数据导入
  │       └── 设备状态监控                            
  │                        
  └──个人中心                           
      ├──登录  
      │   ├── 华为账号登录                          
      │   ├── 微信登录                                                   
      │   └── 用户隐私协议同意                       
      │         
      ├──个人信息         
      │   ├── 头像、昵称
      │   └── 个人资料编辑               
      │
      └──常用服务    
          ├── 意见反馈                                                         
          └── 设置
               ├── 个人信息             
               ├── 隐私设置
               ├── 清除缓存           
               ├── 关于我们 
               └── 退出登录                               
```

本模板工程代码结构如下所示：

```text
健康管理模板
├──commons                                                // 公共模块
│  ├──common                                              // 基础模块             
│  │    ├──basic                                          // 基础类（BaseViewModel、GlobalContext、Logger等）
│  │    ├──constant                                       // 通用常量（Constants、RouterMap等）
│  │    ├──model                                          // 数据模型（UserInfo、DisplayModel等）
│  │    ├──ui                                             // 通用UI组件（Header、WebView等）
│  │    └──util                                           // 通用工具方法（权限、缓存、文件、时间等工具类）
│  │
│  ├──widgets                                             // 通用UI组件模块（避让区域、断点、视图模型等）
│  │
│  └──OHRouter                                            // 路由模块（页面管理、路由跳转）
│
├──components                                             // 组件模块
│  ├──aggregated_login                                    // 通用登录组件
│  ├──message_manager                                     // 消息管理组件
│  ├──feedback                                            // 通用问题反馈组件
│  ├──check_app_update                                    // 检测应用更新组件
│  ├──data_dashboard                                      // 数据看板组件
│  └──collect_personal_info                               // 通用个人信息组件
│      
├──features                                               // 功能模块
│  ├──health                                              // 健康模块             
│  │    ├──comp                                           // 组件（健康数据展示、图表、弹窗等）
│  │    ├──views                                          // 视图页面
│  │    │   ├──HealthPage.ets                             // 健康首页
│  │    │   ├──HealthDataInputPage.ets                    // 健康数据输入页
│  │    │   ├──HealthReportPage.ets                       // 健康报告页面
│  │    │   ├──HealthHistoryPage.ets                      // 健康历史记录
│  │    │   ├──WeeklyReportPage.ets                       // 周报告页面
│  │    │   ├──MonthlyReportPage.ets                      // 月报告页面
│  │    │   └──HealthKnowledgeListPage.ets                // 健康知识列表
│  │    ├──types                                          // 类型定义
│  │    └──constants                                      // 常量配置
│  │
│  ├──device                                              // 设备模块             
│  │    ├──comp                                           // 组件（设备连接、信息展示等）
│  │    ├──viewmodel                                      // 视图模型
│  │    ├──views                                          // 视图页面
│  │    │   ├──DevicePage.ets                             // 设备主页
│  │    │   ├──DeviceInfoPage.ets                         // 设备信息页
│  │    │   ├──ScanningDevicePage.ets                     // 设备扫描页
│  │    │   └──PairHelpPage.ets                           // 配对帮助页
│  │    └──constants                                      // 设备常量
│  │
│  └──person                                              // 个人中心模块             
│       ├──comp                                           // 组件（用户信息行等）
│       ├──viewmodel                                      // 视图模型
│       ├──views                                          // 视图页面
│       │   ├──MinePage.ets                               // 我的页面
│       │   ├──SetupPage.ets                              // 设置页面
│       │   ├──EditPersonalCenterPage.ets                 // 编辑个人中心页面
│       │   ├──MessageCenterPage.ets                      // 消息中心页面
│       │   ├──PrivacySettingsPage.ets                    // 隐私设置页面
│       │   ├──PrivacyAgreementPage.ets                   // 隐私协议页面
│       │   ├──PrivacyInfoCollectPage.ets                 // 隐私信息收集页面
│       │   └──Privacy3rdPartySharePage.ets               // 第三方隐私共享页面
│       ├──utils                                          // 工具类
│       └──constants                                      // 个人模块常量
│
└──products                                               // 产品模块
   ├──Demo                                                // 演示模块
   └──entry/src/main/ets                                  // 入口模块
        ├──entryability                                   // 入口能力
        │   └──EntryAbility.ets                           // 应用入口
        ├──pages                                          // 页面
        │   ├──HomePage.ets                               // 主页
        │   └──Index.ets                                  // 首页
        └──constants                                      // 业务常量
 
```

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3(15) Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3及以上

### 权限

- 网络权限: ohos.permission.INTERNET
- 网络信息权限: ohos.permission.GET_NETWORK_INFO
- 蓝牙访问权限: ohos.permission.ACCESS_BLUETOOTH

### 调试

1. 蓝牙设备连接功能需获取用户蓝牙授权，并开启蓝牙，该功能不支持使用模拟器调试，请使用真机。


## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建HarmonyOS应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-create-app-0000002247955506)为应用创建APP ID，并将APP ID与应用进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将模板工程根目录下AppScope/app.json5文件中的bundleName替换为创建应用的包名。

2. 配置华为账号服务。

   a. 将应用的Client ID配置到products/entry/src/main路径下的module.json5文件中，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 申请华为账号登录所需权限，详细参考：[申请账号权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

3. 接入微信SDK（可选）。

   前往微信开放平台申请AppID并配置鸿蒙应用信息，详情参考：[鸿蒙接入指南](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/ohos.html)。

4. 对应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

5. 添加手工签名所用证书对应的公钥指纹，详细参考：[配置公钥指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-cert-fingerprint-0000002278002933)。

### 运行调试工程

1. 连接调试手机和PC。

2. 菜单选择"Run > Run 'entry' "或者"Run > Debug 'entry' "，运行或调试模板工程。

## 示例效果
### 健康模块

|                   健康首页                   |                   健康数据录入页                   |                    健康报告页                    |
|:----------------------------------------:|:----------------------------------------:|:----------------------------------------:|
| <img src="screenshot/health.jpg" alt="健康首页" width="300"> | <img src="screenshot/health/HealthDataInput.jpg" alt="健康数据录入页" width="300"> | <img src="screenshot/health/HeathReportEmpty.jpg" alt="健康报告页" width="300"> |

|                   健康知识列表页                   |                   健康知识详情页                   |                    消息中心页                    |
|:----------------------------------------:|:----------------------------------------:|:----------------------------------------:|
| <img src="screenshot/health/HealthKnowledgeList.jpg" alt="健康知识列表页" width="300"> | <img src="screenshot/health/HealthKnowledgeDetail.jpg" alt="健康知识详情页" width="300"> | <img src="screenshot/health/MessageCenter.jpg" alt="消息中心页" width="300"> |

|                   步数详情页                   |                   血糖详情页                   |                    血压详情页                    |
|:----------------------------------------:|:----------------------------------------:|:----------------------------------------:|
| <img src="screenshot/health/StepCount.jpg" alt="步数详情页" width="300"> | <img src="screenshot/health/BloodGlucose.jpg" alt="血糖详情页" width="300"> | <img src="screenshot/health/BloodPressure.jpg" alt="血压详情页" width="300"> |

|                   心率详情页                   |                   睡眠详情页                   |
|:----------------------------------------:|:----------------------------------------:|
| <img src="screenshot/health/HeartRate.jpg" alt="心率详情页" width="300"> | <img src="screenshot/health/Sleep.jpg" alt="睡眠详情页" width="300"> |

### 设备模块

|                   设备首页                   |                   设备扫描页                   |                    设备信息页                    |
|:----------------------------------------:|:----------------------------------------:|:----------------------------------------:|
| <img src="screenshot/device.jpg" alt="设备首页" width="300"> | <img src="screenshot/device/ScanningDevice.jpg" alt="设备扫描页" width="300"> | <img src="screenshot/device/DeviceInfo.jpg" alt="设备信息页" width="300"> |

### 个人中心模块

|                   个人信息                   |                   问题反馈                   |                    设置                    |
|:----------------------------------------:|:----------------------------------------:|:----------------------------------------:|
| <img src="screenshot/person/EditPersonalCenter.jpg" alt="个人信息" width="300"> | <img src="screenshot/person/FeedbackSubmit.jpg" alt="问题反馈" width="300"> | <img src="screenshot/person/Setup.jpg" alt="设置" width="300"> |

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。