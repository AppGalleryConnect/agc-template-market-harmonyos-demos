// 导出翻译服务相关类和接口
export { TranslationFactory, TranslationType } from './src/main/ets/control/TranslationFactory';

export { TranslationBase } from './src/main/ets/control/TranslationBase';

export { BaiduTranslation } from './src/main/ets/control/BaiduTranslation';

export { BaiduImageTranslation } from './src/main/ets/control/BaiduImageTranslation';

export { BaiduDocumentTranslation } from './src/main/ets/control/BaiduDocumentTranslation';

export {
  TranslationConfig,
  TranslationParam,
  TranslationResult,
  TranslationResponse,
  ImageTranslationParam,
  ImageTranslationData,
  ImageTranslationResponse,
  DocumentTranslationInput,
  DocumentTranslationOutput,
  DocumentTranslationRequest,
  DocumentTranslationResponseData,
  DocumentTranslationResponse,
  TranslationProgressResponseData,
  TranslationProgressResponse
} from './src/main/ets/viewmodels/TranslationModel';

// 导出工具类
export { MD5Util } from './src/main/ets/utils/md5';

export {
  http,
  createDefaultHttpClient,
  HttpPromise,
  FileUploadConfig,
  AxiosRequestHeaders,
  AxiosError,
  AxiosHeaders
} from './src/main/ets/utils/axiosClient';