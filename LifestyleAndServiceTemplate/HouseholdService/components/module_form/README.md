# 表单组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供以表单形式录入信息的功能。

<img src="screenshots/form.jpg" width="300">

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.0.0 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.0 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* 系统版本：HarmonyOS 5.0.0(12)及以上

### 权限

* 无

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_form模块。

   ```
   // 项目根目录下build-profile.json5填写module_form路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_form",
       "srcPath": "./XXX/module_form"
     }
   ]
   ```

   c. 在项目根目录oh-package.json5添加依赖。
   ```
   // XXX为组件存放的目录名称
   "dependencies": {
     "module_form": "file:./XXX/module_form"
   }
   ```

2. 引入组件。

    ```
    import { FormItem, FormType } from 'module_form';
    ```

3. 配置华为账号服务。如需使用选择头像功能，将Client ID配置到entry模块下的src/main/module.json5文件，详细参考：[配置签名和指纹](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-sign-fingerprints)和[配置Client ID](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/account-client-id)

4. 如需使用选择地点功能，请[开通地图服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/map-config-agc)。

5. 调用组件，详细参数配置说明参见[API参考](#API参考)。

## API参考

### 接口

FormItem(option: [FormItemOptions](#FormItemOptions对象说明))

表单组件

**参数：**

| 参数名     | 类型                                      | 是否必填 | 说明         |
|:--------|:----------------------------------------|:-----|:-----------|
| options | [FormItemOptions](#FormItemOptions对象说明) | 是    | 配置表单组件的参数。 |

### FormItemOptions对象说明

| 参数名         | 类型                          | 是否必填 | 说明         |
|:------------|:----------------------------|:-----|:-----------|
| param       | [IFormItem](#IFormItem类型说明) | 是    | 表单单元基本参数   |
| value       | ResourceStr                 | 否    | 文本值，支持双向绑定 |
| numberV     | number                      | 否    | 数字值，支持双向绑定 |
| dateV       | Date\|null                  | 否    | 日期值，支持双向绑定 |
| formContent | () => void                  | 否    | 自定义内容区     |

### IFormItem类型说明

| 参数名       | 类型                        | 是否必填 | 说明    |
|:----------|:--------------------------|:-----|:------|
| type      | [FormType](#FormType枚举说明) | 是    | 表单类型  |
| label     | string                    | 是    | 标签文本  |
| required  | boolean                   | 否    | 是否必填项 |
| last      | boolean                   | 否    | 是否末尾项 |
| inputType | InputType                 | 否    | 输入框类型 |

### FormType枚举说明

| 名称      | 说明    |
|:--------|:------|
| INPUT   | 基础输入框 |
| GENDER  | 性别选择  |
| DATE    | 日期选择  |
| AVATAR  | 头像    |
| ADDRESS | 地点选择  |
| TEXT    | 文本只读  |
| OTHER   | 其他    |

## 示例代码

```
import { FormItem, FormType } from 'module_form'

@Entry
@ComponentV2
struct FormSample {
  @Local avatarUrl: string = '';
  @Local name: string = '';
  @Local gender: number = 0;
  @Local phone: string = '';
  @Local birthDate: Date | null = null;
  @Local addr: string = '';

  build() {
    NavDestination() {
      Column() {
        Column() {
          FormItem({
            param: {
              type: FormType.AVATAR,
              label: '头像',
            },
            value: this.avatarUrl!!,
          })
          FormItem({
            param: {
              type: FormType.INPUT,
              label: '昵称',
            },
            value: this.name!!,
          })
          FormItem({
            param: {
              type: FormType.GENDER,
              label: '性别',
            },
            numberV: this.gender!!,
          })
          FormItem({
            param: {
              type: FormType.INPUT,
              inputType: InputType.PhoneNumber,
              label: '手机号',
            },
            value: this.phone!!,
          })
          FormItem({
            param: {
              type: FormType.DATE,
              label: '生日',
            },
            dateV: this.birthDate!!,
          })

          FormItem({
            param: {
              type: FormType.ADDRESS,
              label: '所在地区',
              last: true,
            },
            value: this.addr!!,
          })
        }
        .padding(10)
        .backgroundColor(Color.White)
        .borderRadius(4)
      }
      .width('100%')
      .height('100%')
    }
    .title('表单组件')
    .backgroundColor('#F1F3F5')
  }
}
```
