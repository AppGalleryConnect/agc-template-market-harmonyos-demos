import { iData, GlobalStateMgr } from '@common/data';
import { Any, CartCardVM, CartDto, PreOrderItem,
  PreOrderRequest } from '@common/customtypes';
import { Card, GuessLike } from '@common/customtypes';
import { ComponentEntry, ComponentEntryProxy } from '@common/customtypes';
import { IWaterFlowLogic } from '@components/iwaterflow';
import { client } from '@common/network';
import { router } from '@common/router';
import { cache } from '@common/cache';
import { buildProductCard, ProductCardModel, ProductCardLogic } from '@guis/cards';
import { iResourceMgr } from '@common/resource';
import { HashSet } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';

export enum CartStatus {
  NOT_LOGGED_IN, // 未登录
  EMPTY,         // 购物车为空
  NOT_EMPTY,     // 购物车不为空
  LOADING        // 加载中
}

@ObservedV2
export class CartPageLogic {

  public readonly iWaterFlowLogic: IWaterFlowLogic = new IWaterFlowLogic();

  public readonly global: GlobalStateMgr = iData.global;

  private selectedSkuCodes: HashSet<string> = new HashSet();

  private nextGuessLikeIndex: number = 0; // 按照索引请求商品推荐列表

  @Trace
  public isSubPage: boolean = false;

  @Trace
  public cartCards: CartCardVM[] = [];

  @Trace
  public status: CartStatus = CartStatus.LOADING;

  @Trace
  public isShowLoadingLogo: boolean = false;

  @Trace
  public isDownRefreshing: boolean = false;

  @Trace
  public downRefreshStatus: RefreshStatus = RefreshStatus.Inactive;

  @Trace
  public isEditingMode: boolean = false;

  @Trace
  public skuSelectorId: string = '';

  @Trace
  public totalPrice: number = 0;

  @Monitor('global.rootPageActiveTabId', 'global.isNavPathStackEmpty')
  public onGlobalStateChange(iMonitor: IMonitor): void {
    if (this.isSubPage) { // class 很可能没有被垃圾回收，因此多个 Class 持续触发监听, 影响 Index 页的购物车逻辑
      return;
    }
    let needRefresh: boolean = false;
    for (let k of iMonitor.dirty) {
      const v: IMonitorValue<Any> | undefined = iMonitor.value<Any>(k);
      if (v) {
        switch (k) {
          case 'global.rootPageActiveTabId':
            const id: string = v.now as string;
            if (id === 'CartPage') {
              needRefresh = true;
            }
            break;
          case 'global.isNavPathStackEmpty':
            const isEmpty: boolean = v.now as boolean;
            if (isEmpty && iData.global.rootPageActiveTabId === 'CartPage') {
              needRefresh = true;
            }
            break;
        }
      }
    }
    if (needRefresh) {
      this.refresh(true);
    }
  }

  @Trace
  private version: string = '';

  public readonly refresh = (needVerifyVersion: boolean): void => {
    // 每次来到购物车页面时，如果处于未登录状态，还原所有状态
    if (!iData.global.isLogin) {
      this.version = '';
      this.status = CartStatus.NOT_LOGGED_IN;
      this.isDownRefreshing = false;
      this.isShowLoadingLogo = false;
      return;
    }
    if (!needVerifyVersion) { // 下拉刷新触发的更新不需要额外显示加载LOGO
      this.update();
    } else if (this.version === '' || this.version !== iData.global.cartVersion) {
      if (this.status === CartStatus.NOT_LOGGED_IN) {
        this.status = CartStatus.LOADING;
      }
      this.isShowLoadingLogo = true;
      this.update();
    }
  }

  public readonly onDownRefreshStateChange = (state: RefreshStatus): void => {
    this.downRefreshStatus = state;
    if (state === RefreshStatus.Refresh) {
      this.refresh(false);
    }
  }

  public readonly onLoginButtonFinish = (): void => {
    this.refresh(true);
  }

  private update = async (): Promise<void> => {
    const globalVersion: string = iData.global.cartVersion;
    // 推荐商品列表无需在意是否成功，以及何时成功
    client.cardList.getGuessLike(0).then((guessLike: GuessLike) => {
      this.updateWaterFlowBrowser(guessLike.cards, true);
      this.nextGuessLikeIndex = 1;
      this.iWaterFlowLogic.isEnd = guessLike.isFinalData;
    });
    const cartCards: CartCardVM[] = [];
    let v: string = '';
    let total: number = 0;
    try {
      const cartDto = await client.cart.getCartData();
      if (cartDto) {
        v = cartDto.version;
        total = cartDto.total;
        for (let card of cartDto.cards) {
          const vm: CartCardVM = new CartCardVM();
          vm.productId = card.productId;
          vm.skuCode = card.skuCode;
          vm.controller = new ListScroller();
          vm.skuDesc = card.skuDesc;
          vm.stock = card.stock;
          vm.count = card.count;
          vm.banner = iResourceMgr.resolveUri(card.banner);
          vm.title = card.title;
          vm.serviceDesc = card.serviceDesc;
          vm.price = card.price;
          if (this.selectedSkuCodes.has(vm.skuCode)) {
            vm.isSelected = true;
          }
          cartCards.push(vm);
        }
      } else {
        throw new Error();
      }
    } catch (e) {
    }
    this.isShowLoadingLogo = false;
    this.isDownRefreshing = false;
    // 得到购物车数据后再次校验登录状态
    if (!iData.global.isLogin) {
      this.status = CartStatus.NOT_LOGGED_IN;
      return;
    }
    // 得到数据后，如果全局版本号已经改变了，则放弃本批次数据，再刷新一次
    if (globalVersion !== iData.global.cartVersion) {
      this.refresh(true);
      return;
    }
    this.version = v;
    iData.global.cartVersion = v;
    iData.global.cartTotal = total;
    this.cartCards = cartCards;
    this.calcTotalPrice();
    this.status = cartCards.length > 0 ? CartStatus.NOT_EMPTY : CartStatus.EMPTY;
    if (this.status !== CartStatus.NOT_EMPTY) {
      this.isEditingMode = false;
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

  public onSkuDelete = (skuCodes: string[]): void => {
    if (this.isDownRefreshing) {
      return;
    }
    if (skuCodes.length === 0) {
      for (let code of this.selectedSkuCodes) {
        skuCodes.push(code);
      }
    }
    this.isShowLoadingLogo = true;
    client.cart.deleteSkuFromCart(skuCodes)
      .then((cartDto: CartDto) => {
        const cartCards: CartCardVM[] = [];
        for (let card of cartDto.cards) {
          const vm: CartCardVM = new CartCardVM();
          vm.productId = card.productId;
          vm.skuCode = card.skuCode;
          vm.controller = new ListScroller();
          vm.skuDesc = card.skuDesc;
          vm.stock = card.stock;
          vm.count = card.count;
          vm.banner = iResourceMgr.resolveUri(card.banner);
          vm.title = card.title;
          vm.serviceDesc = card.serviceDesc;
          vm.price = card.price;
          if (this.selectedSkuCodes.has(vm.skuCode)) {
            vm.isSelected = true;
          }
          cartCards.push(vm);
        }
        this.version = cartDto.version;
        iData.global.cartVersion = cartDto.version;
        iData.global.cartTotal = cartDto.total;
        this.cartCards = cartCards;
        this.status = cartCards.length > 0 ? CartStatus.NOT_EMPTY : CartStatus.EMPTY;
        if (this.status !== CartStatus.NOT_EMPTY) {
          this.isEditingMode = false;
        }
        this.calcTotalPrice();
      })
      .finally(() => {
        this.isShowLoadingLogo = false;
      })
  }

  public readonly onCheckBoxChange = (skuCodes: string[]): void => {
    let selectedSkuCodes: HashSet<string> = new HashSet();
    for (let code of skuCodes) {
      selectedSkuCodes.add(code);
    }
    this.selectedSkuCodes = selectedSkuCodes;
    this.calcTotalPrice();
  }

  private readonly calcTotalPrice = (): void => {
    let totalPrice: number = 0;
    for (let sku of this.cartCards) {
      if (this.selectedSkuCodes.has(sku.skuCode)) {
        totalPrice = totalPrice + sku.price * sku.count;
      }
    }
    this.totalPrice = totalPrice;
  }

  public readonly onSkuCountChange = (card: CartCardVM, value: number): void => {
    let target: number = card.count + value;
    if (target < 1) {
      promptAction.showToast({ message: '已经是最小购买数量' });
    } else if (target > card.stock) {
      promptAction.showToast({ message: '数量超出范围' });
    } else {
      client.cart.changeSkuCount(card.skuCode, target);
      for (let sku of this.cartCards) {
        if (sku.skuCode === card.skuCode) {
          sku.count = target;
        }
      }
      card.count = target;
      this.calcTotalPrice();
    }
  }

  public readonly onSettlement = (): void => {
    if (this.selectedSkuCodes.isEmpty()) {
      promptAction.showToast({ message: '您还没有选择商品' });
      return;
    }
    const items: PreOrderItem[] = [];
    for (let sku of this.cartCards) {
      if (this.selectedSkuCodes.has(sku.skuCode)) {
        const preOrderItem: PreOrderItem = {
          skuCode: sku.skuCode,
          quantity: sku.count
        };
        items.push(preOrderItem);
      }
    }
    const preOrderRequest: PreOrderRequest = {
      items: items,
      removeFromCart: true
    };
    router.pushPathByName('OrderSubmitPage', preOrderRequest);
  }

  constructor() {
    this.initIWaterFlow();
  }
}
