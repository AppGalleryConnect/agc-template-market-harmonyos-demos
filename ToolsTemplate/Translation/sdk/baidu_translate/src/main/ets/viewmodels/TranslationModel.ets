export interface TranslationConfig {
  appId: string;
  secretKey: string;
  apiKey?: string;
}

export interface TranslationParam {
  query: string;
  from?: string;
  to: string;
}

export interface TranslationResult {
  src: string;
  dst: string;
}

export interface TranslationResponse {
  from: string;
  to: string;
  transResult: TranslationResult[];
  errorCode?: string;
  errorMsg?: string;
}

/**
 * 图片翻译请求参数
 */
export interface ImageTranslationParam {
  // 图片数据
  imageData: ArrayBuffer;

  // 图片路径
  imagePath?: string;

  // 源语言
  from: string;

  // 目标语言
  to: string;

  // 图片贴合类型：0-关闭 1-整图贴合 2-块区贴合
  paste?: number;

  // 是否使用自定义术语库：0-否 1-是
  needIntervene?: number;
}

/**
 * 图片翻译数据
 */
export interface ImageTranslationData {
  // 翻译后的图片（base64）
  image?: string;

  // 识别的文本内容
  content?: string;

  // 源文本摘要
  sumSrc?: string;

  // 译文摘要
  sumDst?: string;

  // 贴合后的图片
  pasteImg?: string;

  // 实际检测到的源语言
  from?: string;
}

/**
 * 图片翻译响应
 */
export interface ImageTranslationResponse {
  errorCode?: string;
  errorMsg?: string;
  data?: ImageTranslationData;
}

/**
 * 文档翻译输入参数
 */
export interface DocumentTranslationInput {
  content: string; // base64编码的文件内容
  format: string; // 文件格式：txt、pdf、doc、docx等
  filename: string; // 文件名
  transImage?: string; // 是否翻译图片：0-否 1-是
  modelType?: string; // 模型类型：llm-大模型，nmt-机器翻译（默认）
}

/**
 * 文档翻译输出参数
 */
export interface DocumentTranslationOutput {
  format?: string; // 输出格式
  mode?: number; // 1-单语译文，2-双语对照
}

/**
 * 文档翻译请求参数
 */
export interface DocumentTranslationRequest {
  from: string;
  to: string;
  input: DocumentTranslationInput;
  output?: DocumentTranslationOutput;
}

/**
 * 文档翻译响应数据
 */
export interface DocumentTranslationResponseData {
  requestId: number;
}

/**
 * 文档翻译响应
 */
export interface DocumentTranslationResponse {
  code: number;
  msg: string;
  data?: DocumentTranslationResponseData;
}

/**
 * 翻译进度响应数据
 */
export interface TranslationProgressResponseData {
  requestId: number;
  status: number; // 0-翻译中，1-翻译成功，2-翻译失败
  reason?: string;
  fileSrcUrl?: string; // 译文下载URL
  outPutDocType?: string;
  from?: string;
  to?: string;
  name?: string;
  charCount?: number;
  amount?: number;
}

/**
 * 查询翻译进度响应
 */
export interface TranslationProgressResponse {
  code: number;
  msg: string;
  data?: TranslationProgressResponseData;
}
