# 语音播报组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供了语音包列表组件，可以进行语言包的下载与切换。提供接口实现对文本的语音播报功能。

<img src="./screenshots/Broadcast.jpeg" width="300">

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 5.1.1 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.1.1 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* 系统版本：HarmonyOS 5.0.5(17)及以上

说明：系统版本 5.1.1(19) 以上支持音色下载与切换。

### 权限

无

### 调试

本组件不支持使用模拟器调试，请使用真机进行调试。

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_voice_broadcast模块。

   ```
   // 项目根目录下build-profile.json5填写module_voice_broadcast路径。其中XXX为组件存放的目录名
   "modules": [
      {
      "name": "module_voice_broadcast",
      "srcPath": "./XXX/module_voice_broadcast"
      }
   ]
   ```

   c. 在项目根目录oh-package.json5中添加依赖。
   ```
   // XXX为组件存放的目录名
   "dependencies": {
      "module_voice_broadcast": "file:./XXX/module_voice_broadcast"
   }
   ```

2. 引入组件句柄。
   ```
   import { BroadCastUtil, VoiceList } from 'module_voice_broadcast';
   ```

3. 使用语音包列表组件。详细参数配置说明参见[API参考](#API参考)。
   ```
   VoiceList()
   ```

4. 接口播放文本。详细参数配置说明参见[API参考](#API参考)。
   ```
   BroadCastUtil.speak(this.text);
   ```

## API参考

### 子组件

无

### 接口

VoiceList(options?: VoiceListOptions)

语音包列表组件。

**参数：**

| 参数名     | 类型                                        | 是否必填 | 说明            |
|---------|-------------------------------------------|------|---------------|
| options | [VoiceListOptions](#VoiceListOptions对象说明) | 否    | 配置语音包列表组件的参数。 |

### VoiceListOptions对象说明

| 名称    | 类型               | 是否必填 | 说明   |
|-------|------------------|------|------|
| space | string \| number | 是    | 列表间隙 |

### BroadCastUtil对象说明

语音播报控制器。

#### getVoiceList

BroadCastUtil.getVoiceList():Promise<[VoicePackage](#VoicePackage对象说明)[]>

获取所有语音包列表详情。

#### getCurVoiceType

BroadCastUtil.getCurVoiceType():Promise<[VoiceType](#VoiceType类型说明)>

获取选择的语音包类型。

#### speak

BroadCastUtil.speak(text:string):void

根据已选择的语音包进行文本播报。支持播放英文段落。

#### stop

BroadCastUtil.stop():void

停止语音播报。

#### change

BroadCastUtil.change(type:[VoiceType](#VoiceType类型说明)):void

切换当前语音包类型。

#### downloadVoice

BroadCastUtil.downloadVoice(type:[VoiceType](#VoiceType类型说明), startCallBack:() => void, progressCallback:(progress:
string) => void, completeCallback:() => void):void

下载指定语音包。

**参数：**

| 参数名              | 类型                          | 说明     |
|------------------|-----------------------------|--------|
| type             | [VoiceType](#VoiceType类型说明) | 语音包类型  |
| startCallBack    | function                    | 下载开始回调 |
| progressCallback | function                    | 下载进度回调 |
| completeCallback | function                    | 下载完成回调 |

#### VoicePackage对象说明

**字段：**

| 名称        | 类型                                                                                                    | 是否必填 | 说明        |
|-----------|:------------------------------------------------------------------------------------------------------|------|-----------|
| pic       | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr) | 是    | 语音包图片     |
| type      | [VoiceType](#VoiceType类型说明)                                                                           | 是    | 语音包类型     |
| desc      | string                                                                                                | 是    | 语音包描述     |
| used      | number                                                                                                | 是    | 使用人数，单位万人 |
| rate      | number                                                                                                | 是    | 评分，总分5分   |
| installed | boolean                                                                                               | 是    | 当前设备是否下载  |

#### VoiceType类型说明

同系统[VoiceInfo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/hms-ai-texttospeech#section85771521101910)
的person字段保持一致。根据不同设备获取对应支持音色。

**枚举：**

| 名称                | 数值 | 说明                       |
|-------------------|----|--------------------------|
| CN_FEMALE_DEFAULT | 0  | 聆小珊女声                    |
| CN_FEMALE         | 13 | 聆小珊女声                    |
| CN_MALE           | 21 | 凌飞哲男声                    |
| US_FEMALE         | 8  | 劳拉女声<br>【注意】劳拉女声无法播放中文文本 |

## 示例代码

本示例通过VoiceList实现语音包列表的展示以及切换，并通过speak方法实现文本播报。

```
import { BroadCastUtil, VoiceList } from 'module_voice_broadcast';

@Entry
@ComponentV2
struct Broadcast {
  textCn: string = '这是一段文本';
  textUs: string = 'This is a piece of text';

  build() {
    Column({ space: 30 }) {
      Row({ space: 20 }) {
        TextInput({ text: this.textCn }).layoutWeight(1).enabled(false)
        SymbolGlyph($r('sys.symbol.speaker')).fontSize(20).fontWeight(FontWeight.Medium).onClick(() => {
          BroadCastUtil.speak(this.textCn);
        })
      }.width('calc(100% - 32vp)').justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 20 }) {
        TextInput({ text: this.textUs }).layoutWeight(1).enabled(false)
        SymbolGlyph($r('sys.symbol.speaker')).fontSize(20).fontWeight(FontWeight.Medium).onClick(() => {
          // 劳拉音色下无法播放中文文本
          BroadCastUtil.speak(this.textUs);
        })
      }.width('calc(100% - 32vp)').justifyContent(FlexAlign.SpaceBetween)

      Blank().layoutWeight(1)

      VoiceList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ top: 20 })
  }
}
```