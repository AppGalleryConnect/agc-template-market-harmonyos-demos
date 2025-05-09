import { Home, LoadingStatus, Category, Card, GuessLike } from '@common/customtypes';
import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';
import { client } from '@common/network';
import { router } from '@common/router';
import { iResourceMgr } from '@common/resource';
import { cache } from '@common/cache';
import { IWaterFlowLogic } from '@components/iwaterflow';
import { CategoryBrowserLogic, Category as CategoryModel } from '@guis/browser'
import { SearchSuggestionCarouselLogic } from '@guis/search';
import { buildProductCard, ProductCardModel, ProductCardLogic } from '@guis/cards';

@ObservedV2
export class HomePageLogic {

  public readonly categoryBrowserLogic: CategoryBrowserLogic = new CategoryBrowserLogic();

  public readonly iWaterFlowLogic: IWaterFlowLogic = new IWaterFlowLogic();

  public readonly searchSuggestionCarouselLogic: SearchSuggestionCarouselLogic = new SearchSuggestionCarouselLogic();

  @Trace
  public loadingStatus: LoadingStatus = LoadingStatus.LOADING;

  @Trace
  public refreshStatus: RefreshStatus = RefreshStatus.Inactive;

  @Trace
  public isRefreshing: boolean = false;

  private nextGuessLikeIndex: number = 0;

  public onReloading = (): void => {
    if (this.loadingStatus === LoadingStatus.FAIL) {
      this.loadingStatus = LoadingStatus.RELOADING;
      this.loadHomePage('load');
    }
  }

  public onRefreshStateChange = (state: RefreshStatus): void => {
    this.refreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.loadHomePage('refresh');
    }
  }

  private initSearchSuggestionCarousel = (): void => {
    this.searchSuggestionCarouselLogic.modifyCurrentDisplay('请输入搜索内容');
    this.searchSuggestionCarouselLogic.setSelectEventCallback((key: string) => {
      cache.search.placeholder = key;
      router.pushPathByName('ProductSearchPage', null);
    });
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

  private loadHomePage = async (intent: 'load' | 'refresh'): Promise<void> => {
    try {
      const result = await Promise.all([
        client.search.getSuggestions(),
        client.homepage.getHomeCoreData(),
        client.cardList.getGuessLike(0)
      ]);
      const suggestions: string[] | null = result[0];
      const home: Home | null = result[1];
      const guessLike: GuessLike | null = result[2];
      if (suggestions && home && guessLike) {
        this.updateSearchSuggestionCarousel(suggestions);
        this.updateCategoryBrowser(home.categoryList);
        this.updateWaterFlowBrowser(home.activityCards, true);
        this.updateWaterFlowBrowser(guessLike.cards, false);
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

  private updateSearchSuggestionCarousel(suggestions: string[]): void {
    this.searchSuggestionCarouselLogic.setSuggestionData(suggestions, true);
    this.searchSuggestionCarouselLogic.start();
  };

  private updateCategoryBrowser(categoryList: Category[]): void {
    const models: CategoryModel[] = [];
    for (let item of categoryList) {
      const model: CategoryModel = new CategoryModel();
      model.id = item.id;
      model.label = item.label;
      model.icon = iResourceMgr.resolveUri(item.iconUrl);
      models.push(model);
    }
    this.categoryBrowserLogic.setData(models);
  }

  private updateWaterFlowBrowser(cards: Card[], needRefresh: boolean): void {
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
    this.initSearchSuggestionCarousel();
    this.initIWaterFlow();
    this.loadHomePage('load');
    this.categoryBrowserLogic.setSelectEventCallback((id: string) => {
      router.pushPathByName('SubCategoryPage', id);
    });
  }
}
