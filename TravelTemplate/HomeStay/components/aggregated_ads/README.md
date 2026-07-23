# 广告组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了通过华为广告平台展示开屏广告的能力，开发者可以根据业务需要实现通过开屏广告变现。

<img src="screenshot/HwSplashAd.jpeg" alt="开屏广告" width="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）、华为平板
- 系统版本：HarmonyOS 5.0.4(16)及以上

### 权限

- 网络权限：ohos.permission.INTERNET

### 调试

如需使用模拟器调试组件，请将DevEco Studio升级至6.0.0 Release及以上版本，模拟器新建设备选择HarmonyOs 6.0.0(20)及以上版本。

## 使用

1. 开发者需要前往[鲸鸿动能媒体服务平台](https://developer.huawei.com/consumer/cn/doc/monetize/zhucerenzheng-0000001132395957)注册开发者账号并认证，并参考[展示位创建](https://developer.huawei.com/consumer/cn/doc/monetize/zhanshiweichuangjian-0000001132700049)创建广告展示位用于开发调试。
2. 安装组件。  
   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   如果是从生态市场下载组件，请参考以下步骤安装组件。  
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。  
   b. 在项目根目录build-profile.json5并添加aggregated_ads模块。
   ```typescript
   // 在项目根目录的build-profile.json5填写aggregated_ads路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "aggregated_ads",
       "srcPath": "./xxx/aggregated_ads",
     }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
   "dependencies": {
     "aggregated_ads": "file:./xxx/aggregated_ads"
   }
   ```
   
3. 引入广告组件句柄。
   ```typescript
   import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
   ```

4. 调用组件，详细参数配置说明参见[API参考。](#API参考)

   ```typescript
   // 华为广告使用
   AdServicePage({
       channelType: ChannelType.HUAWEI_AD,
       adId: 'testq6zq98hecj',
       adType: AdType.SPLASH_AD,
       closeCallBack: () => {
         // 广告结束跳转页面
       },
     });
   ```

## API参考

### 子组件

无

### 接口

AdServicePage(channelType:ChannelType,adId:string,adType:AdType,appId:string,appName:string,closeCallBack:() => void)

广告组件。

**参数：**

| 参数名           | 类型                              | 必填 | 说明       |
|:--------------|:--------------------------------|:---|:---------|
| channelType   | [ChannelType](#ChannelType枚举说明) | 是  | 广告渠道信息数组 |
| adId          | string                          | 是  | 广告位ID    |
| adType        | [AdType](#AdType枚举说明)           | 是  | 广告类型     |
| appId         | string                          | 否  | 应用ID     |
| appName       | string                          | 否  | 应用名称     |
| closeCallBack | () => void                      | 是  | 关闭广告回调函数 |

#### ChannelType枚举说明

| 名称        | 值 | 说明   |
|:----------|:--|:-----|
| HUAWEI_AD | 0 | 华为广告 |

#### AdType枚举说明

| 名称        | 值 | 说明   |
|:----------|:--|:-----|
| SPLASH_AD | 1 | 开屏广告 |

### 事件

支持以下事件：

#### closeCallBack

closeCallBack: () => void = () => {}

广告关闭时的回调函数。

## 示例代码

使用华为广告

```typescript
import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
import { promptAction } from '@kit.ArkUI';

@Entry
@ComponentV2
struct Index {
   build() {
      RelativeContainer() {
         AdServicePage({
            channelType: ChannelType.HUAWEI_AD,
            adId: 'testq6zq98hecj',
            adType: AdType.SPLASH_AD,
            closeCallBack: () => {
              // todo 这里需要自行编写路由到其他页面的代码
              promptAction.showToast({ message: '跳转页面' })
            },
         })
      }
      .width('100%')
      .height('100%')
   }
}
```