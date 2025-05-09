import { cache } from '@common/cache';
import { router } from '@common/router';
import { client } from '@common/network';

import util from '@ohos.util';

@ObservedV2
export class ProductSearchPageLogic {

  @Trace
  public placeholder: string = '请输入搜索内容';

  @Trace
  public isShowCandidate: boolean = false;

  @Trace
  public candidateWords: string[] = [];

  @Trace
  public keyWord: string = '';

  @Trace
  public submit: string = '';

  public readonly SEARCH_ID: string = util.generateRandomUUID(false);

  public controller: SearchController = new SearchController();

  public onClickBack = (): void => {
    router.pop();
  }

  public onChange = (value: string, _?: PreviewText): void => {
    if (value === '') {
      this.isShowCandidate = false;
    } else {
      client.search.getCandidateWords(value).then((words: string[]) => {
        this.candidateWords = words;
        this.keyWord = value;
        this.isShowCandidate = true;
      });
    }
  }

  public onSubmit = (value: string): void => {
    const key: string = value === '' ? this.placeholder : value;
    if (key !== '请输入搜索内容' && key !== '') {
      cache.search.lastSubmit = key;
      router.pushPathByName('ProductSearchResultsPage', null, false);
    }
  }

  public onShown = (ctx: UIContext): void => {
    this.submit = cache.search.lastSubmit;
    ctx.getFocusController().requestFocus(this.SEARCH_ID);
  }

  constructor() {
    if (cache.search.placeholder !== '') {
      this.placeholder = cache.search.placeholder;
    }
    cache.search.lastSubmit = '';
  }
}
