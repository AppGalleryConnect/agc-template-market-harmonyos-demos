import { TranslationParam, TranslationResponse } from '../viewmodels/TranslationModel';

export abstract class TranslationBase {
  abstract translate(param: TranslationParam): Promise<TranslationResponse>;
  abstract batchTranslate(queries: string[], from?: string, to?: string): Promise<string[]>;
}
