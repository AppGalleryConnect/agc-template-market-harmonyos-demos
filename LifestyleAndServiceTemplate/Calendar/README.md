# 日历模板

## 目录

- [功能介绍](#功能介绍)
- [环境要求](#环境要求)
- [快速入门](#快速入门)
- [示例效果](#示例效果)
- [权限要求](#权限要求)
- [开源许可协议](#开源许可协议)

## 功能介绍

本模板为日历应用提供了常用功能的开发样例，模板主要分为万年历、黄历、和我的三大模块：

* 万年历：主要提供日历服务查询、吉日工具查询、日期查询、节日节气查询等工具。

* 黄历：根据选择日历展示黄历内容，支持切换日期查看今日宜以及今日忌。

* 我的：展示个人信息、华为账号一键登录、切换主题等。

| 万年历                                                   | 黄历                                                      | 我的                           
|-------------------------------------------------------|---------------------------------------------------------|------------------------------ 
| <img src="screenshot/home.png" alt="万年历" width="300"> | <img src="screenshot/huangli.png" alt="黄历" width="300"> | <img src="screenshot/mine.png" alt="我的" width="300">  

本模板主要页面及核心功能如下所示：

```ts
日历模板
 |-- 万年历
 |    |-- 日历选择
 |    |-- 吉日查询
 |    |-- 日期计算
 |    |-- 节日节气
 |    └-- 宜忌展示
 |-- 黄历
 |    |-- 日期切换
 |    |-- 宜忌展示
 |    |-- 五行、冲煞 
 |    |-- 彭祖百忌
 └-- 我的
 |     |-- 个人信息
 |     └-- 设置
 |       └-- 主题切换
 |       └-- 隐私协议
 |       └-- 用户协议  
```

本模板工程代码结构如下所示：

```ts
Application
├──├──commons
│   ├──common                                // 公共能力层
│     ├──src/main/ets                        // 基础能力
│     │  └──components                       // 公共组件
│     │  └──dividerTmp                       // 下划线公共组件
│     │  └──https                            // 网络请求库
│     │  └──models                           // 公共接口常量
│     │  └──quickLogin                       // 华为账号一键登录
│     │  └──style                            // 公共样式
│     │  └──utils                            // 工具类
│     │  └──viewmodels                       // 接口层
│     └──Index.ets                           // 对外接口类
├──features                                  // 基础特性层
│  ├──almanac/src/main/ets                   // 黄历
│  │  ├──pages                               // 首页入口
│     │  ├──AlmanacView                      // 黄历入口
│  ├──almanac/src/main/resources             // 资源文件目录
│  ├──almanac/Index.ets                      // 对外接口类
│  ├──perpetual/src/main/ets                 // 万年历
│  │  ├──components                          // 万年历组件
│  │  ├──pages                               
│     │  ├──PerpetualCalendar                // 万年历组件入口
│  ├──perpetual/src/main/resources           // 资源文件目录
│  ├──perpetual/Index.ets                    // 对外接口类
│  ├──mine/src/main/ets                      // 我的（包含一键登录）
│  │  └──pages                               // 我的入口页
│     │  ├──MinePage                         // 登录
│  │  └──components                          // 我的页面入口
│  └──mine/src/main/resources                // 资源文件目录
└─products/entry/src/main   
   ├─ets
   │  ├─entrybackupability
   │  │      ├──EntryBackupAbility            
   │  ├─entryability
   │  │      ├──EntryAbility.ets             // 应用程序入口
   │  ├─pages
   │  │  ├──MainPage                         // 入口
   └─resources
```

## 注意事项

* 本模版均提供的是模拟数据，所有服务跳转到的页面均为本地mock页面或者lunar三方库提供的数据，实际开发中请以具体业务为准！
* 本模版登录中获取验证码获取场景为模拟场景，真实场景以业务实际场景为准
* 本模版在未配置华为账号一键登录的情况下为保证正常使用本模版，均采用模拟用户信息登录，实际开发中请按照业务为准！

## 环境要求

### 软件

* DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上

### 硬件

* 设备类型：华为手机（直板机）
* HarmonyOS版本：HarmonyOS 5.0.4 Release及以上

## 快速入门

### 配置工程

在运行此模板前，需要完成以下配置：

1. 在DevEco Studio中打开此模板。

2. 在AppGallery Connect创建应用，将包名配置到模板中。

   a. 参考[创建HarmonyOS应用](https://developer.huawei.com/consumer/cn/doc/app/agc-help-createharmonyapp-0000001945392297)为应用创建APPID，并进行关联。

   b. 返回应用列表页面，查看应用的包名。

   c. 将Application/AppScope/app.json5文件中的bundleName替换为创建应用的包名。

3. 配置签名。

   a. 为应用进行[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

   c. 本项目也可采用自动签名方式进行项目预览

4. 配置华为账号服务。

   a. 将应用的client
   ID配置到Application/product/entry模块的module.json5文件，详细参考：[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)。

   b. 添加公钥指纹，详细参考：[配置应用证书指纹](https://developer.huawei.com/consumer/cn/doc/app/agc-help-signature-info-0000001628566748#section5181019153511)。

   c. 配置scope权限：[配置scope权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-config-permissions)。

### 运行调试工程

1. 连接调试手机和PC。

2. 对应用[手工签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing#section297715173233)。

3. 菜单选择“Run > Run 'entry' ”或者“Run > Debug 'entry' ”，运行或调试模板工程。

## 示例效果

1. [万年历]([home.mp4](screenshot%2Fhome.mp4))

2. [黄历]([huangli.mp4](screenshot%2Fhuangli.mp4))

3. [我的]([mine.mp4](screenshot%2Fmine.mp4))

## 权限要求

* 网络权限：ohos.permission.INTERNET

## 开源许可协议

该代码经过[Apache 2.0 授权许可](http://www.apache.org/licenses/LICENSE-2.0)。

