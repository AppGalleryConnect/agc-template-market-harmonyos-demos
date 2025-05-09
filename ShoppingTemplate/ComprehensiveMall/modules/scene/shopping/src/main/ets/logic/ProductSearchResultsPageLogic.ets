import { LoadingStatus, Card, GuessLike } from '@common/customtypes';
import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';
import { client } from '@common/network';
import { router } from '@common/router';
import { cache } from '@common/cache';
import { IWaterFlowLogic } from '@components/iwaterflow';
import { buildProductCard, ProductCardModel, ProductCardLogic } from '@guis/cards';

@ObservedV2
export class ProductSearchResultsPageLogic {

  public readonly iWaterFlowLogic: IWaterFlowLogic = new IWaterFlowLogic();

  @Trace
  public currentActiveType: 'default' | 'priceDown' | 'priceUp' | 'sale' = 'default';

  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;

  @Trace
  public refreshStatus: RefreshStatus = RefreshStatus.Inactive;

  @Trace
  public isRefreshing: boolean = false;

  private nextGuessLikeIndex: number = 0;

  public readonly onActive = (type: number): void => {
    let needRefresh: boolean = false;
    if (type === 0 && this.currentActiveType !== 'default') {
      needRefresh = true;
      this.currentActiveType = 'default';
    } else if (type === 1) {
      needRefresh = true;
      if (this.currentActiveType === 'default' || this.currentActiveType === 'sale') {
        this.currentActiveType = 'priceUp';
      } else if (this.currentActiveType === 'priceUp') {
        this.currentActiveType = 'priceDown';
      } else {
        this.currentActiveType = 'priceUp';
      }
    } else if (type === 2 && this.currentActiveType !== 'sale') {
      needRefresh = true;
      this.currentActiveType = 'sale';
    }
    if (needRefresh) {
      this.load('refresh');
    }
  }

  public onReloading = (): void => {
    if (this.loadingStatus === LoadingStatus.FAIL) {
      this.loadingStatus = LoadingStatus.RELOADING;
      this.load('load');
    }
  }

  public onRefreshStateChange = (state: RefreshStatus): void => {
    this.refreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.load('refresh');
    }
  }

  private initIWaterFlow = (): void => {
    this.iWaterFlowLogic.setOnReachEndEventCallback(() => {
      if (this.iWaterFlowLogic.isEnd) {
        return;
      }
      this.iWaterFlowLogic.isLoading = true;
      client.cardList.getGuessLike(this.nextGuessLikeIndex)
        .then((guessLike: GuessLike) => {
          this.updateWaterFlowBrowser(guessLike.cards, false);
          this.nextGuessLikeIndex++;
          this.iWaterFlowLogic.isEnd = guessLike.isFinalData;
        })
        .finally(() => {
          this.iWaterFlowLogic.isLoading = false;
        })
    });
  }

  private load = async (intent: 'load' | 'refresh'): Promise<void> => {
    try {
      const guessLike: GuessLike | null = await client.cardList.getGuessLike(0);
      if (guessLike) {
        this.updateWaterFlowBrowser(guessLike.cards, intent === 'refresh');
        this.nextGuessLikeIndex = 1;
        this.iWaterFlowLogic.isEnd = guessLike.isFinalData;
        this.loadingStatus = LoadingStatus.SUCCESS;
      } else {
        throw new Error();
      }
    } catch (e) {
      if (intent === 'load') {
        this.loadingStatus = LoadingStatus.FAIL;
      }
    }
    this.isRefreshing = false;
  }

  private updateWaterFlowBrowser(cards: Card[], needRefresh: boolean): void {
    if (needRefresh) {
      this.iWaterFlowLogic.up();
    }
    const data: ComponentEntryProxy[] = [];
    for (let card of cards) {
      try {
        if (card.type === 'ProductCard') {
          const logic: ProductCardLogic = new ProductCardLogic();
          logic.setData(card.model as ProductCardModel);
          logic.setOnClickCallback((productId: string) => {
            cache.product.id = productId;
            router.pushPathByName('ProductInfoPage', productId);
          });
          data.push(new ComponentEntry(wrapBuilder(buildProductCard), [logic]));
        }
      } catch (e) {
        return;
      }
    }
    this.iWaterFlowLogic.setData(data, needRefresh);
  }

  constructor() {
    this.initIWaterFlow();
    this.load('load');
  }
}
