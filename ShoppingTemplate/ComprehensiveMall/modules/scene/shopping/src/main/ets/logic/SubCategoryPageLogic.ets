import { Category, Card, CardDataDto } from '@common/customtypes';
import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';
import { client } from '@common/network';
import { router } from '@common/router';
import { cache } from '@common/cache';
import { IWaterFlowLogic } from '@components/iwaterflow';
import { buildProductCard, ProductCardModel, ProductCardLogic } from '@guis/cards';

@ObservedV2
export class SubCategoryPageLogic {

  @Trace
  public tabs: CategoryTabVM[] = [];

  @Trace
  public isLoading: boolean = true;

  @Trace
  public controller: SwiperController = new SwiperController();

  public currentSelectIndex: number = -1;

  public readonly init = (categoryId: string): void => {
    client.cardList.getCategoryList()
      .then((categoryList: Category[]) => {
        const tabs: CategoryTabVM[] = [];
        let i: number = 0;
        let target: number = 0;
        for (let category of categoryList) {
          if (category.id === categoryId) {
            target = i;
          }
          const tab: CategoryTabVM = new CategoryTabVM();
          tab.id = category.id;
          tab.label = category.label;
          tab.iWaterFlowLogic.setOnReachEndEventCallback(() => {
            if (tab.iWaterFlowLogic.isEnd || tab.iWaterFlowLogic.isLoading) {
              return;
            }
            tab.iWaterFlowLogic.isLoading = true;
            client.cardList.getCardsByCategoryId(tab.id, tab.nextIndex)
              .then((cardDataDto: CardDataDto) => {
                this.updateWaterFlowBrowser(tab, cardDataDto.cards, false);
                tab.nextIndex++;
                tab.iWaterFlowLogic.isEnd = cardDataDto.isFinalData;
              })
              .finally(() => {
                tab.iWaterFlowLogic.isLoading = false;
              })
          });
          tabs.push(tab);
          i++;
        }
        if (tabs.length > 0) {
          this.tabs = tabs;
          this.isLoading = false;
          this.onChange(target);
        }
      })
  }

  public readonly onChange = (selectIndex: number): void => {
    if (selectIndex === this.currentSelectIndex) {
      return;
    }
    this.currentSelectIndex = selectIndex;
    this.controller.changeIndex(selectIndex, false);
    for (let i: number = 0; i < this.tabs.length; i++) {
      if (i === selectIndex) {
        this.tabs[i].isSelect = true;
        this.tabs[i].iWaterFlowLogic.viewData = [];
        client.cardList.getCardsByCategoryId(this.tabs[i].id, 0)
          .then((cardDataDto: CardDataDto) => {
            this.updateWaterFlowBrowser(this.tabs[i], cardDataDto.cards, true);
            this.tabs[i].nextIndex = 1;
            this.tabs[i].iWaterFlowLogic.isEnd = cardDataDto.isFinalData;
          })
      } else {
        this.tabs[i].isSelect = false;
      }
    }
  }

  private updateWaterFlowBrowser = (tab: CategoryTabVM, cards: Card[], needRefresh: boolean): void => {
    const data: ComponentEntryProxy[] = [];
    for (let card of cards) {
      try {
        if (card.type === 'ProductCard') {
          const logic: ProductCardLogic = new ProductCardLogic();
          logic.isVertical = false;
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
    tab.iWaterFlowLogic.setData(data, needRefresh);
  }
}

@ObservedV2
export class CategoryTabVM {

  @Trace
  public id: string = '';

  @Trace
  public label: string = '';

  @Trace
  public isSelect: boolean = false;

  @Trace
  public iWaterFlowLogic: IWaterFlowLogic = new IWaterFlowLogic();

  public nextIndex: number = 0;
}
