import { TranslationBase } from './TranslationBase';
import { BaiduTranslation } from './BaiduTranslation';
import { TranslationConfig } from '../viewmodels/TranslationModel';

export enum TranslationType {
  BAIDU = 'baidu'
}

export class TranslationFactory {
  /**
   * 获取翻译服务实例
   * @param config 翻译配置
   * @param type 翻译服务类型，默认为百度翻译
   * @returns 翻译服务实例
   */
  static getTranslationService(config: TranslationConfig,
    type: TranslationType = TranslationType.BAIDU): TranslationBase {
    switch (type) {
      case TranslationType.BAIDU:
        return new BaiduTranslation(config);
      default:
        return new BaiduTranslation(config);
    }
  }
}
