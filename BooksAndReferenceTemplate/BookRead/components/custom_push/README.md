# 推送组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了推送组件功能，**其中消息中心数据均为mock数据，实际开发中可以做借鉴使用，具体推送请对接实际业务**

<img src="./screenshot/custom_push.jpeg" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* HarmonyOS版本：HarmonyOS 5.0.4(16)及以上

### 权限

- 网络权限：ohos.permission.INTERNET

### 调试

本组件不支持使用模拟器调试，请使用真机进行调试

## 使用

1. 安装组件。 

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。
   
   如果是从生态市场下载组件，请参考以下步骤安装组件。 
   
   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的xxx目录下。 
   
   b. 在项目根目录build-profile.json5中添加custom_push模块。
   
   ```typescript
   // 在项目根目录的build-profile.json5填写custom_push路径。其中xxx为组件存在的目录名
   "modules": [
     {
       "name": "custom_push",
       "srcPath": "./xxx/custom_push"
     },
     {
        "name": "base_common",
        "srcPath": "./xxx/base_common",
     }
   ]
   ```
   c. 在项目根目录oh-package.json5中添加依赖
   ```typescript
   // xxx为组件存放的目录名称
    "dependencies": {
     "custom_push": "file:./xxx/custom_push",
     "base_common": "file:./xxx/base_common"
   }
   ```
   
2. 引入组件。

   ```typescript
   import { PushKit } from 'custom_push';
   ```

3. 开通推送服务和申请通知消息自分类权益。

   a. [开启推送服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-config-setting)。
   
   b. 按照需要的权益开通消息自分类权益。详细参考[申请通知消息自分类权益](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-apply-right)。
   
   c. 更改主模块的module.json5的client_id后需重新从步骤a申请推送服务。

4. 弹出提醒和获取Push Token。

   a. 应用发送通知前需[调用requestEnableNotification()](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-send-alert#section1792616175914)方法弹出提醒，可以在主模块入口(entry)的src\main\ets\entryability\EntryAbility.ets的onWindowStageCreate()生命周期中弹出。
   
   ```typescript
   notificationManager.requestEnableNotification(this.context).then(() => {
   hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
   }).catch((err: BusinessError) => {
   hilog.error(0x0000, 'testTag', `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
   });
   ```
   
   b. 在主模块入口的src\main\ets\entryability\EntryAbility.ets的onCreate()生命周期中通过pushService.getToken()获取Push Token。
   
   ```typescript
   try {
      const pushToken = await pushService.getToken();
      AppStorage.setOrCreate('PushToken',pushToken)
      hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', e.code, e.message);
    }
   ```
   可在此上报Push Token到服务端，调试状态可打印出pushToken后手动放入custom_push\src\main\ets\pushKitForJava\messageBody.json的token中，详细参考[获取Push Token](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-get-token)。
   ```json5
   "target": {
      "token": ["xxx"]
   }
   ```
   
5. 配置skills标签。

   在主模块入口(src\main\ets\entryability\module.json5)的中查看不同的能力：
   - "actions": "action.system.home"进入应用首页
   - "actions": "com.test.action"进入应用首页

   为module.json5文件中skills-->actions新增action。
   ```json5
   "skills": [
          {
            "actions": [
              "com.test.action"
            ]
          }
        ]
   ```
   custom_push\src\main\ets\pushKitForJava\messageBody.json中的action赋相同值。
   
   ```json5
   "clickAction": {
        "action": "com.test.action",
      },
   ```
  
6. 获取服务账号密钥文件(custom_push\src\main\ets\pushKitForJava\serviceAccountPrivateKey.json)，详细参考[获取服务账号密钥文件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-jwt-token)中的开发步骤1。

   将获取到的服务账号密钥文件命名为serviceAccountPrivateKey.json替换原有文件。
   
   获取服务账号密钥文件后手动去除"private_key"字段的"'-----BEGIN PRIVATE KEY-----\n'和 '\n-----END PRIVATE KEY-----\n'或在JsonWebTokenFactory.java中去除。

7. 将pushKitForJava所有文件放入java项目中，项目结构如图显示。

   <img src="./screenshot/struct.png" width="300">
   
   检查JsonWebTokenFactory.java中的路径并将String url中的项目id替换为为serviceAccountPrivateKey.json的project_id。
   
   运行JsonWebTokenFactory.java即可收到推送。
   
8. 修改推送内容(custom_push\src\main\ets\pushKitForJava\messageBody.json)，详细参考[发送通知消息](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/push-send-alert)开发步骤4请求示例。

   推送内容示例，本示例通过title、body、actionType实现打开应用首页并设置标题为BookReadTitle，内容为BookReadContent。

```json5
   {
   "payload": {
      "notification": {
         "category": "EXPRESS",
         "title": "BookReadTitle",
         "body": "内容为BookReadContent",
         "badge": {
            "addNum": 1,
            "setNum": 1
         },
         "clickAction": {
            "actionType": 0,
            "action": "com.test.action",
            "pushData": {
               "pushContent": "亲爱的用户您好~2025.06.26 24:00:00-02:00进行安全升级，部分评价功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！",
               "time": "2小时前"
            }
         },
         "foregroundShow": true
      }
   },
   "target": {
      "token": ["xxx"]
   }
}
```

9. 推送流程。

   a. 后端发送推送消息。
   
   b. 主模块入口的src\main\module.json5通过skill添加actions字段。
   
   在onCreate方法中获得推送消息内容并全局存储，可打印want.parameters查看具体结构。

   ```typescript
   const pushData:PushData = {
      pushContent:want.parameters?.content as string,
      time:want.parameters?.time as string,
      read:false
    }
   AppStorage.setOrCreate('pushData',data)
   ```
   c. 在onCreate方法中标记为此次应用拉起方式为内页拉起，后在主模块入口的src\main\ets\pages\Index.ets中路由至消息中心页面。
   
   ```typescript
   AppStorage.setOrCreate('takeMessage',1)
   ```
   ```typescript
   aboutToAppear(): void {
    if (AppStorage.get('takeMessage')===1) {
      TCRouter.push(Constants.MESSAGE_PAGE_ROUTE)
   }
   ```

## API参考
详细API请参考[push kit api](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-arkts)。

## 示例代码

```typescript
import { PushKit } from 'custom_push';
@Entry
@ComponentV2
struct Index{
  
  build() {
    NavDestination(){
      PushKit({
        // 传入路由栈
      })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
```