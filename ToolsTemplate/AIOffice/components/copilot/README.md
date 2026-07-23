# Copilot智能聊天组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)
- [补充说明](#补充说明)

## 简介

Copilot是基于HarmonyOS开发的智能聊天组件，可以对接大模型（如DeepSeek、Qwen等）的聊天功能，支持Agent模式，可以注册function事件、卡片等。该组件提供完整的聊天界面和交互体验，支持文本消息、动作执行等多种消息类型，适用于构建智能助手、客服机器人等应用场景。

### 核心特性

- **多模型支持**：支持DeepSeek、Qwen等主流大语言模型接入
- **Agent模式**：支持智能代理模式，可注册自定义function和动作
- **实时对话**：支持流式响应，提供实时对话体验
- **消息管理**：内置消息存储和管理机制，支持对话历史
- **可定制UI**：支持自定义Markdown渲染、主题样式等
- **语音识别**：集成语音输入功能(需要HarmonyOS 5.1.0(18)及以上版本)

## 约束与限制

### 环境

* DevEco Studio版本：DevEco Studio 6.0.2 Release及以上
* HarmonyOS SDK版本：HarmonyOS 6.0.2 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）、平板
* HarmonyOS版本：HarmonyOS 5.0.5(17) 及以上

### 权限

* 网络权限：`ohos.permission.INTERNET`（必需）
* [麦克风权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/permissions-for-all-user#ohospermissionmicrophone)：`ohos.permission.MICROPHONE`（语音输入功能需要）

麦克风权限需要用户授权的权限，需要在[声明权限](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/declare-permissions)时配置使用场景
```json5
{
  "name": "ohos.permission.MICROPHONE",
  "reason": "$string:microphone_reason",
  "usedScene": {
    "abilities": [
      "EntryAbility"
    ],
    "when": "always"
  }
}
```


## 使用

### 安装

```shell
ohpm install @hw-agconnect/copilot
```

### 基础使用

```typescript
// 在页面中使用Copilot组件
import { CopilotChat, CopilotController } from '@hw-agconnect/copilot';

@Entry
@ComponentV2
export struct ChatPage {
  controller: CopilotController = new CopilotController({
    llm: {
      baseUrl: 'https://api.deepseek.com/v1',
      apiKey: 'your-api-key',
      model: 'deepseek-chat'
    },
    systemPrompt: '你是一个AI办公写作助手，可以帮助用户解决写作类的问题'
  });

  build() {
    Column() {
      CopilotChat({
        controller: this.controller,
        options: {
          labels: {
            introduce: '嗨！我是AI办公写作助手',
            initial: '你好，我是你的智能助手，有什么需要帮助的',
            suggestions: [
              '北京的天气怎么样',
              '给我几个城市选项',
              '如何生成一篇800字的作文'
            ],
            placeholder: '请输入你的问题'
          },
          icons: {
            assistant: $r('app.media.icon_flip_foreground')
          }
        }
      }).layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
```

<img src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-qxx9w/image%2Fscreenshot_1.jpg?token=2ed37140-bb01-4bb6-b9fd-8c5c4ac4ed50" width="300" />


## API参考

### CopilotChat 组件

主要的聊天界面组件。

```typescript
CopilotChat({
  controller: CopilotController,
  options?: CopilotChatOptions,
  markdownRender?: (message: TextMessage) => void
})
```

**参数说明**

| 参数名 | 类型                                          | 是否必填 | 说明 |
|:------|:--------------------------------------------|:-----|:-----|
| controller | [CopilotController](#CopilotController对象说明) | 是    | 聊天控制器实例 |
| options | [CopilotChatOptions](#CopilotControllerOptions对象说明)                     | 否    | 聊天组件配置选项 |
| markdownRender | (message: [TextMessage](#TextMessage对象说明)) => void                   | 否    | 自定义Markdown渲染函数 |

### CopilotController对象说明

聊天控制器，负责管理对话逻辑和状态。

#### 构造函数

```typescript
new CopilotController(options: CopilotControllerOptions)
```

#### 主要方法

| 方法名 | 参数                                                       | 返回值 | 说明 |
|:------|:---------------------------------------------------------|:-------|:-----|
| addMessage | message: [Message](#Message对象说明)                         | void | 添加消息到对话中 |
| retry | message: [TextMessage](#TextMessage对象说明)                 | void | 重试发送消息 |
| reset | -                                                        | void | 重置对话状态，清空消息历史 |
| reload | threadId: string                                         | void | 重新加载指定线程的对话历史 |
| registerAction | action: [FrontendAction](#FrontendAction对象说明)            | void | 注册自定义动作 |

### CopilotControllerOptions对象说明

控制器配置选项。

| 属性名 | 类型                          | 是否必填 | 说明 |
|:------|:----------------------------|:-----|:-----|
| llm | [LLMConfig](#LLMConfig对象说明) | 是    | 大语言模型配置 |
| storeId | string                      | 否    | 存储标识符，用于区分不同的对话存储 |
| threadId | string                      | 否    | 对话线程ID，用于恢复历史对话 |
| systemPrompt | string                      | 否    | 系统提示词，定义AI助手的角色和行为 |

### CopilotChatOptions对象说明

聊天组件配置选项。

| 属性名 | 类型                                  | 是否必填 | 说明 |
|:------|:------------------------------------|:-----|:-----|
| labels | [CopilotLabels](#CopilotLabels对象说明) | 否    | 界面文本标签配置 |
| icons | [CopilotIcons](#CopilotIcons对象说明)   | 否    | 图标配置 |
| isShowDefaultActionCard | boolean                             | 否    | 是否显示默认动作卡片，默认false |

### CopilotLabels对象说明

界面文本标签配置。

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| introduce | string | 否    | 介绍文本 |
| initial | string | 否    | 初始欢迎消息 |
| suggestions | string[] | 否    | 建议问题列表 |
| placeholder | string | 否    | 输入框占位符文本 |

### CopilotIcons对象说明

图标配置。

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| assistant | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr) | 否    | 助手头像图标 |

### LLMConfig对象说明

大语言模型配置。

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| apiKey | string | 是    | API密钥 |
| baseUrl | string | 是    | API基础URL |
| model | string | 是    | 模型名称，如'deepseek-chat'等 |
| temperature | number | 否    | 温度参数，控制回答的随机性 |
| maxTokens | number | 否    | 最大token数 |

### FrontendAction对象说明

自定义动作定义。

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| name | string | 是    | 动作名称 |
| description | string | 否    | 动作描述 |
| parameters | [Parameter](#Parameter对象说明)[] | 否    | 参数定义 |
| handler | (props: Record<string, ESObject>) => Promise<ESObject> | 否    | 动作处理函数 |
| render | WrappedBuilder<[[ActionRenderProps](#ActionRenderProps对象说明)]> | 否    | 自定义渲染组件 |
| renderAndWaitForResponse | WrappedBuilder<[[ActionWaitRenderProps](#ActionWaitRenderProps对象说明)]> | 否    | 自定义渲染组件，并支持交互 |
| available | 'disabled' \| 'enabled' | 否    | 是否可用，默认enabled |
| followUp | boolean | 否    | 是否需要后续处理，默认false |

### ActionRenderProps对象说明

动作渲染属性，用于自定义动作的渲染组件。

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| status | 'inProgress' \| 'executing' \| 'complete' | 是    | 动作执行状态：inProgress-进行中，executing-执行中，complete-已完成 |
| args | Record<string, ESObject> | 是    | 动作参数对象 |
| result | ESObject | 否    | 动作执行结果 |

### ActionWaitRenderProps对象说明

交互式动作渲染属性，继承自[ActionRenderProps](#ActionRenderProps对象说明)，用于需要用户交互的动作组件。

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| status | 'inProgress' \| 'executing' \| 'complete' | 是    | 动作执行状态：inProgress-进行中，executing-执行中，complete-已完成 |
| args | Record<string, ESObject> | 是    | 动作参数对象 |
| result | ESObject | 否    | 动作执行结果 |
| respond | (result: string) => void | 是    | 响应函数，用于向AI返回用户操作结果 |
| reject | (error: Error) => void | 是    | 拒绝函数，用于向AI返回错误信息 |

### Parameter对象说明

动作参数定义，支持多种数据类型和嵌套结构。

**基础参数类型**

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| name | string | 是    | 参数名称 |
| type | 'string' \| 'number' \| 'boolean' \| 'object' \| 'string[]' \| 'number[]' \| 'boolean[]' \| 'object[]' | 否    | 参数类型，默认为string |
| description | string | 否    | 参数描述 |
| required | boolean | 否    | 是否必填，默认false |

**字符串参数扩展属性**

当`type`为`'string'`时，支持以下额外属性：

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| enum | string[] | 否    | 枚举值列表，限制参数只能取列表中的值 |

**对象参数扩展属性**

当`type`为`'object'`或`'object[]'`时，支持以下额外属性：

| 属性名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| attributes | [Parameter](#Parameter对象说明)[] | 否    | 对象的属性定义列表，支持嵌套 |

**参数类型示例**

```typescript
// 字符串参数
{
  name: 'location',
  type: 'string',
  description: '城市名称',
  required: true
}

// 枚举参数
{
  name: 'unit',
  type: 'string',
  description: '温度单位',
  enum: ['celsius', 'fahrenheit'],
  required: false
}

// 对象参数
{
  name: 'config',
  type: 'object',
  description: '配置对象',
  attributes: [
    {
      name: 'timeout',
      type: 'number',
      description: '超时时间（毫秒）'
    },
    {
      name: 'retries',
      type: 'number',
      description: '重试次数'
    }
  ]
}

// 对象数组参数
{
  name: 'options',
  type: 'object[]',
  description: '选项列表',
  required: true,
  attributes: [
    {
      name: 'label',
      type: 'string',
      description: '选项展示文本',
      required: true
    },
    {
      name: 'value',
      type: 'string',
      description: '选项值',
      required: true
    }
  ]
}
```

### Message对象说明

消息对象是聊天系统中的基础数据结构，所有消息类型都继承自基础Message类。

#### 消息类型

| 类型 | 说明 |
|:------|:-----|
| [TextMessage](#TextMessage对象说明) | 文本消息，包含用户或助手的文本内容 |
| [ActionExecutionMessage](#ActionExecutionMessage对象说明) | 动作执行消息，表示正在执行或已执行的动作 |
| [ResultMessage](#ResultMessage对象说明) | 结果消息，包含动作执行的结果 |

#### 基础消息属性

所有消息类型都包含以下基础属性：

| 属性名 | 类型 | 说明 |
|:------|:-----|:-----|
| id | string | 消息唯一标识符 |
| createdAt | number | 消息创建时间戳 |
| status | [MessageStatus](#MessageStatus对象说明) | 消息状态 |

### TextMessage对象说明

文本消息类，用于表示用户或助手的文本内容。

**构造参数**

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| role | 'system' \| 'user' \| 'assistant' \| 'tool' | 是    | 消息角色 |
| content | string | 是    | 文本内容 |
| id | string | 否    | 消息ID，不提供则自动生成 |
| status | [MessageStatus](#MessageStatus对象说明) | 否    | 消息状态 |
| createdAt | number | 否    | 创建时间戳，不提供则使用当前时间 |

### ActionExecutionMessage对象说明

动作执行消息类，表示正在执行或已执行的动作。

**构造参数**

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| name | string | 是    | 动作名称 |
| callId | string | 是    | 调用ID，用于关联动作和结果 |
| args | Record<string, ESObject> | 是    | 动作参数 |
| argumentsDelta | string | 否    | 参数增量数据（流式） |
| id | string | 否    | 消息ID，不提供则自动生成 |
| status | [MessageStatus](#MessageStatus对象说明) | 否    | 消息状态 |
| createdAt | number | 否    | 创建时间戳，不提供则使用当前时间 |

### ResultMessage对象说明

结果消息类，包含动作执行的结果。

**构造参数**

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| result | ESObject | 是    | 动作执行结果 |
| actionCallId | string | 是    | 对应的动作调用ID |
| actionName | string | 是    | 对应的动作名称 |
| id | string | 否    | 消息ID，不提供则自动生成 |
| status | [MessageStatus](#MessageStatus对象说明) | 否    | 消息状态 |
| createdAt | number | 否    | 创建时间戳，不提供则使用当前时间 |

### MessageStatus对象说明

消息状态对象。

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-----|:-----|
| code | 'Failed' \| 'Pending' \| 'Success' | 是 | 状态码：Failed-失败，Pending-处理中，Success-成功 |
| reason | string  | 否 | 状态原因说明 |

## 示例代码

### Agent模式使用

```typescript
import { CopilotChat, CopilotController, FrontendAction, ActionRenderProps } from '@hw-agconnect/copilot';

// 定义天气查询动作
export const weatherAction: FrontendAction = {
  name: 'get_weather',
  description: 'Get the weather for a given location.',
  available: 'enabled',
  parameters: [{
    name: 'location',
    type: 'string',
    description: '城市名称',
    required: true,
  }],
  handler: async (args) => {
    console.log('handle action : ' + args.location)
    return `{'temperature': '15', 'unit': 'celsius', 'description': '晴朗'}`;
  },
}

@Entry
@ComponentV2
export struct ChatPage {
  controller: CopilotController = new CopilotController({
    llm: {
      baseUrl: 'https://api.deepseek.com/v1',
      apiKey: 'your-api-key',
      model: 'deepseek-chat'
    },
    systemPrompt: '你是一个AI办公写作助手，可以帮助用户解决写作类的问题'
  });

  aboutToAppear(): void {
    // 注册自定义动作
    this.controller.registerAction(weatherAction)
  }

  build() {
    Column() {
      CopilotChat({
        controller: this.controller,
        options: {
          labels: {
            suggestions: [
              '北京的天气怎么样',
              '上海今天天气如何？'
            ]
          }
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
```

<img src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-qxx9w/image%2Fscreenshot_2.jpg?token=756155d2-89b6-4f4c-9436-d8e0211e38b1" width="300" />

### 交互式动作示例

1. 基于如下代码中的选项卡片动作，展示如何创建需要用户交互的动作，此代码可单独放置到一个ets文件中导出一个`selectOptionAction`动作。

```typescript
import { ActionWaitRenderProps, FrontendAction } from '@hw-agconnect/copilot';

// 定义选项卡片动作
export const selectOptionAction: FrontendAction = {
  name: 'select_option_card',
  description: '展示选项卡片并等待用户选择（最多四个选项）',
  available: 'enabled',
  parameters: [
    {
      name: 'title',
      type: 'string',
      description: '卡片标题',
      required: true,
    },
    {
      name: 'options',
      type: 'object[]',
      description: '选项列表（每项包含label与value），最多四个',
      required: true,
      attributes: [
        {
          name: 'label',
          type: 'string',
          description: '选项展示文本',
          required: true,
        },
        {
          name: 'value',
          type: 'string',
          description: '选项值',
          required: true,
        }
      ]
    },
  ],
  renderAndWaitForResponse: wrapBuilder(selectOptionWaitCard)
};

// 选项卡片组件
interface SelectOptionItem {
  label: string
  value: string
}

@Builder
function selectOptionWaitCard(props: ActionWaitRenderProps) {
  if (props.status !== 'inProgress') {
    SelectOptionWaitCard({
      props: props
    })
  }
}

@ComponentV2
struct SelectOptionWaitCard {
  @Param @Require props: ActionWaitRenderProps;
  @Local selectedItem?: SelectOptionItem;
  @Local isConfirm: boolean = false;

  build() {
    Column({ space: 8 }) {
      if (this.props.args?.title) {
        Text(this.props.args.title)
          .fontSize($r('sys.float.Title_M'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 8 })
      }

      if (this.isConfirm && this.selectedItem) {
        this.checkItemBuilder(this.selectedItem)
      } else {
        ForEach(this.props.args?.options, (item: SelectOptionItem) => {
          this.checkItemBuilder(item);
        })

        Button('确定')
          .onClick(() => {
            this.props.respond(`用户选择了${this.selectedItem?.label},值为:${this.selectedItem?.value}`);
            this.isConfirm = true;
          })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .borderRadius(8)
    .padding(12)
    .backgroundColor('#ffe1fffb')
  }

  @Builder
  checkItemBuilder(item: SelectOptionItem) {
    Row() {
      Radio({
        value: item.label,
        group: 'select_radio_group'
      }).onChange((isChecked) => {
        if (isChecked) {
          this.selectedItem = item;
        }
      })
        .checked(this.selectedItem === item)
      Text(item.label)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .padding(8)
    }.onClick(() => {
      this.selectedItem = item;
    })
  }
}
```

2. 动作定义完后需要注册到[CopilotController](#CopilotController对象说明)中使用

```typescript
aboutToAppear(): void {
  // 注册自定义动作
  this.controller.registerAction(selectOptionAction)
}
```

<img src="https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-qxx9w/image%2Fscreenshot_3.jpg?token=ab7d2710-9516-4926-b639-e5fc153bbe8a" width="300" />

## 补充说明

1. **控制器生命周期管理**：在页面销毁时调用`controller.destroy()`释放资源
2. **API密钥安全**：不要在代码中硬编码API密钥，建议通过安全的配置方式管理
3. **键盘避让**：当弹出键盘需要压缩组件时，需要设置[避让模式](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-expand-safe-area#setkeyboardavoidmode11)为`RESIZE`。
