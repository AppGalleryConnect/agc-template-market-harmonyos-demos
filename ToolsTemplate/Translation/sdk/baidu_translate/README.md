# 百度翻译SDK集成快速入门

## 目录

- [简介](#简介)
- [获取API密钥](#获取API密钥)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本SDK提供百度翻译API的封装能力，支持文本翻译、图片翻译和文档翻译三种翻译服务。

主要功能：
- **文本翻译**：支持多语言文本互译，支持批量翻译
- **图片翻译**：识别图片中的文字并翻译，支持译文贴合原图
- **文档翻译**：支持doc、docx、pdf等格式文档翻译，支持双语对照输出

## 获取API密钥

使用本SDK前，需要先在百度翻译开放平台注册账号并获取API密钥。

### 注册步骤

1. **访问百度翻译开放平台**
   - 打开浏览器，访问 [百度翻译开放平台](https://fanyi-api.baidu.com/)

2. **注册/登录账号**
   - 点击右上角「登录」按钮
   - 如果没有百度账号，点击「立即注册」创建账号
   - 使用百度账号登录

3. **开通翻译服务**
   - 登录后，点击「产品服务」
   - 选择需要的翻译服务：
      - **通用文本翻译**：用于文本翻译功能
      - **图片翻译**：用于图片翻译功能
      - **文档翻译**：用于文档翻译功能
   - 点击「立即使用」开通服务

4. **获取API密钥**
   - 进入「管理控制台」
   - 在「开发者信息」中可以看到：
      - **APP ID**：应用唯一标识
      - **密钥**：用于API签名验证
   - 复制保存这两个值，在SDK中使用

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.5 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.3(15) Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.3及以上

### 权限

本SDK需要以下权限：

| 权限名称 | 权限说明 | 授权方式 |
|:--------|:--------|:--------|
| ohos.permission.INTERNET | 网络访问权限，用于调用翻译API | system_grant（安装时自动授权） |

### 其他限制

- 需要有效的百度翻译API AppID和SecretKey
- 图片翻译支持jpg、png等常见图片格式，图片大小不超过4MB
- 文档翻译支持txt、pdf、doc、docx格式，文档大小不超过10MB

## 使用

1. 安装SDK。
   a. 在项目根目录build-profile.json5添加baidu_translate模块。
   ```json
   "modules": [
     {
       "name": "baidu_translate",
       "srcPath": "./sdk/baidu_translate"
     }
   ]
   ```
   b. 在项目根目录oh-package.json5添加依赖。
   ```json
   "dependencies": {
     "baidu_translate": "file:./sdk/baidu_translate"
   }
   ```
   c. 在entry模块的module.json5中声明网络权限。
   ```json
   {
     "module": {
       "requestPermissions": [
         {
           "name": "ohos.permission.INTERNET"
         }
       ]
     }
   }
   ```
   d. 在resources/base/element/string.json中配置API地址。
   ```json
   {
     "string": [
       {
         "name": "baidu_translate_api_url",
         "value": "https://fanyi-api.baidu.com/api/trans/vip/translate"
       },
       {
         "name": "baidu_image_translate_api_url",
         "value": "https://fanyi-api.baidu.com/api/trans/sdk/picture"
       },
       {
         "name": "baidu_document_translate_api_url",
         "value": "https://fanyi-api.baidu.com/api/trans/vip/doctrans"
       },
       {
         "name": "baidu_document_query_api_url",
         "value": "https://fanyi-api.baidu.com/api/trans/vip/doctrans/query"
       }
     ]
   }
   ```

2. 引入SDK。
   ```typescript
   import {
     BaiduTranslation,
     BaiduImageTranslation,
     BaiduDocumentTranslation,
     TranslationConfig,
     TranslationParam,
     ImageTranslationParam,
     DocumentTranslationRequest
   } from 'baidu_translate';
   ```

3. 调用SDK，详细参数配置说明参见[API参考](#API参考)。

## API参考

### 接口

#### BaiduTranslation

文本翻译服务类。

**构造函数：**

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-------|:-----|
| config | [TranslationConfig](#TranslationConfig对象说明) | 是 | 翻译服务配置 |

**方法：**

| 方法名 | 参数 | 返回值 | 说明 |
|:------|:-----|:------|:-----|
| translate | param: [TranslationParam](#TranslationParam对象说明) | Promise\<[TranslationResponse](#TranslationResponse对象说明)\> | 翻译文本 |
| batchTranslate | queries: string[], from?: string, to?: string | Promise\<string[]\> | 批量翻译文本 |

#### BaiduImageTranslation

图片翻译服务类。

**构造函数：**

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-------|:-----|
| config | [TranslationConfig](#TranslationConfig对象说明) | 是 | 翻译服务配置 |

**方法：**

| 方法名 | 参数 | 返回值 | 说明 |
|:------|:-----|:------|:-----|
| translateImage | param: [ImageTranslationParam](#ImageTranslationParam对象说明) | Promise\<[ImageTranslationResponse](#ImageTranslationResponse对象说明)\> | 翻译图片中的文字 |

#### BaiduDocumentTranslation

文档翻译服务类。

**构造函数：**

| 参数名 | 类型 | 是否必填 | 说明 |
|:------|:-----|:-------|:-----|
| config | [TranslationConfig](#TranslationConfig对象说明) | 是 | 翻译服务配置 |

**方法：**

| 方法名 | 参数 | 返回值 | 说明 |
|:------|:-----|:------|:-----|
| submitTranslation | request: [DocumentTranslationRequest](#DocumentTranslationRequest对象说明) | Promise\<[DocumentTranslationResponse](#DocumentTranslationResponse对象说明)\> | 提交文档翻译任务 |
| queryProgress | requestId: number | Promise\<[TranslationProgressResponse](#TranslationProgressResponse对象说明)\> | 查询翻译进度 |
| pollTranslationResult | requestId: number, maxAttempts?: number, interval?: number | Promise\<[TranslationProgressResponse](#TranslationProgressResponse对象说明)\> | 轮询查询翻译结果 |

### TranslationConfig对象说明

| 名称 | 类型 | 是否必填 | 说明 |
|:-----|:-----|:-------|:-----|
| appId | string | 是 | 百度翻译API AppID |
| secretKey | string | 是 | 百度翻译API SecretKey |
| apiKey | string | 否 | API Key（可选） |

### TranslationParam对象说明

| 名称 | 类型 | 是否必填 | 说明 |
|:-----|:-----|:-------|:-----|
| query | string | 是 | 待翻译文本 |
| from | string | 否 | 源语言，默认auto自动检测 |
| to | string | 是 | 目标语言 |

### TranslationResponse对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| from | string | 源语言 |
| to | string | 目标语言 |
| transResult | TranslationResult[] | 翻译结果数组 |
| errorCode | string | 错误码 |
| errorMsg | string | 错误信息 |

### TranslationResult对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| src | string | 原文 |
| dst | string | 译文 |

### ImageTranslationParam对象说明

| 名称 | 类型 | 是否必填 | 说明 |
|:-----|:-----|:-------|:-----|
| imageData | ArrayBuffer | 是 | 图片二进制数据 |
| imagePath | string | 否 | 图片路径 |
| from | string | 是 | 源语言 |
| to | string | 是 | 目标语言 |
| paste | number | 否 | 图片贴合类型：0-关闭 1-整图贴合 2-块区贴合 |
| needIntervene | number | 否 | 是否使用自定义术语库：0-否 1-是 |

### ImageTranslationResponse对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| errorCode | string | 错误码 |
| errorMsg | string | 错误信息 |
| data | [ImageTranslationData](#ImageTranslationData对象说明) | 翻译结果数据 |

### ImageTranslationData对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| image | string | 翻译后的图片（base64） |
| content | string | 识别的文本内容 |
| sumSrc | string | 源文本摘要 |
| sumDst | string | 译文摘要 |
| pasteImg | string | 贴合后的图片（base64） |
| from | string | 实际检测到的源语言 |

### DocumentTranslationRequest对象说明

| 名称 | 类型 | 是否必填 | 说明 |
|:-----|:-----|:-------|:-----|
| from | string | 是 | 源语言 |
| to | string | 是 | 目标语言 |
| input | [DocumentTranslationInput](#DocumentTranslationInput对象说明) | 是 | 输入文档配置 |
| output | [DocumentTranslationOutput](#DocumentTranslationOutput对象说明) | 否 | 输出配置 |

### DocumentTranslationInput对象说明

| 名称 | 类型 | 是否必填 | 说明 |
|:-----|:-----|:-------|:-----|
| content | string | 是 | base64编码的文件内容 |
| format | string | 是 | 文件格式：txt、pdf、doc、docx等 |
| filename | string | 是 | 文件名 |
| transImage | string | 否 | 是否翻译图片：0-否 1-是 |
| modelType | string | 否 | 模型类型：llm-大模型，nmt-机器翻译（默认） |

### DocumentTranslationOutput对象说明

| 名称 | 类型 | 是否必填 | 说明 |
|:-----|:-----|:-------|:-----|
| format | string | 否 | 输出格式 |
| mode | number | 否 | 1-单语译文，2-双语对照 |

### DocumentTranslationResponse对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | number | 状态码，0表示成功 |
| msg | string | 状态信息 |
| data | { requestId: number } | 响应数据，包含任务ID |

### TranslationProgressResponse对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| code | number | 状态码 |
| msg | string | 状态信息 |
| data | [TranslationProgressData](#TranslationProgressData对象说明) | 进度数据 |

### TranslationProgressData对象说明

| 名称 | 类型 | 说明 |
|:-----|:-----|:-----|
| requestId | number | 任务ID |
| status | number | 状态：0-翻译中，1-翻译成功，2-翻译失败 |
| reason | string | 失败原因 |
| fileSrcUrl | string | 译文下载URL |
| outPutDocType | string | 输出文档类型 |
| from | string | 源语言 |
| to | string | 目标语言 |
| name | string | 文件名 |
| charCount | number | 字符数 |
| amount | number | 消费金额 |

### 支持的语言

| 语言代码 | 名称 |
|:--------|:-----|
| auto | 自动检测 |
| zh | 中文 |
| en | 英文 |
| jp | 日文 |
| kor | 韩文 |
| fra | 法文 |
| de | 德文 |
| ru | 俄文 |
| spa | 西班牙文 |
| pt | 葡萄牙文 |
| it | 意大利文 |
| ara | 阿拉伯文 |
| th | 泰文 |
| vie | 越南文 |

## 示例代码

### 文本翻译

```typescript
import { BaiduTranslation, TranslationConfig, TranslationParam } from 'baidu_translate';

@Entry
@ComponentV2
struct TextTranslateSample {
  @Local resultText: string = '';
  @Local inputText: string = 'Hello World';

  // 配置
  private config: TranslationConfig = {
    appId: 'your_app_id',
    secretKey: 'your_secret_key'
  };

  // 创建翻译实例
  private translator: BaiduTranslation = new BaiduTranslation(this.config);

  build() {
    Column({ space: 20 }) {
      Text('文本翻译示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({ text: this.inputText })
        .width('90%')
        .height(48)
        .onChange((value) => {
          this.inputText = value;
        })

      Button('翻译')
        .width('80%')
        .height(48)
        .onClick(async () => {
          const param: TranslationParam = {
            query: this.inputText,
            from: 'en',
            to: 'zh'
          };
          const result = await this.translator.translate(param);
          if (result.transResult?.length > 0) {
            this.resultText = result.transResult[0].dst;
          }
        })

      if (this.resultText) {
        Text(`翻译结果：${this.resultText}`)
          .fontSize(16)
          .padding(16)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .width('90%')
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 60 })
  }
}
```

### 图片翻译

```typescript
import { BaiduImageTranslation, TranslationConfig, ImageTranslationParam } from 'baidu_translate';
import { fileIo } from '@kit.CoreFileKit';

// 配置
const config: TranslationConfig = {
  appId: 'your_app_id',
  secretKey: 'your_secret_key'
};

// 创建图片翻译实例
const imageTranslator = new BaiduImageTranslation(config);

// 读取图片数据
const file = fileIo.openSync(imagePath, fileIo.OpenMode.READ_ONLY);
const stat = fileIo.statSync(file.fd);
const imageBuffer = new ArrayBuffer(stat.size);
fileIo.readSync(file.fd, imageBuffer);
fileIo.closeSync(file);

// 翻译图片
const param: ImageTranslationParam = {
  imageData: imageBuffer,
  from: 'en',
  to: 'zh',
  paste: 1 // 整图贴合
};

const result = await imageTranslator.translateImage(param);
```

### 文档翻译

```typescript
import { BaiduDocumentTranslation, TranslationConfig, DocumentTranslationRequest } from 'baidu_translate';
import { util } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';

// 配置
const config: TranslationConfig = {
  appId: 'your_app_id',
  secretKey: 'your_secret_key'
};

// 创建文档翻译实例
const docTranslator = new BaiduDocumentTranslation(config);

// 读取文档并转为base64
const file = fileIo.openSync(docPath, fileIo.OpenMode.READ_ONLY);
const stat = fileIo.statSync(file.fd);
const docBuffer = new ArrayBuffer(stat.size);
fileIo.readSync(file.fd, docBuffer);
fileIo.closeSync(file);

const base64Helper = new util.Base64Helper();
const fileContent = base64Helper.encodeToStringSync(new Uint8Array(docBuffer));

// 提交翻译任务
const request: DocumentTranslationRequest = {
  from: 'en',
  to: 'zh',
  input: {
    content: fileContent,
    format: 'docx',
    filename: 'document.docx'
  },
  output: {
    mode: 2 // 双语对照
  }
};

const submitResult = await docTranslator.submitTranslation(request);
const requestId = submitResult.data?.requestId;

// 轮询查询结果
const finalResult = await docTranslator.pollTranslationResult(requestId!, 60, 2000);
```

## 注意事项

1. **API密钥安全**：AppID和SecretKey属于敏感信息，请勿硬编码在代码中，建议通过安全方式存储和获取。
2. **网络权限**：使用前需确保已在module.json5中声明网络权限。
3. **API地址配置**：需要在resources/base/element/string.json中配置百度翻译API地址。
4. **语言代码格式**：本SDK使用百度翻译API的语言代码格式（如zh、en、jp），与标准语言代码格式（如zh-CN、en-US）不同。
5. **文档翻译异步**：文档翻译为异步任务，提交后需要轮询查询结果，建议使用pollTranslationResult方法。
6. **错误处理**：调用翻译接口时建议使用try-catch捕获异常，处理网络错误和API错误。
