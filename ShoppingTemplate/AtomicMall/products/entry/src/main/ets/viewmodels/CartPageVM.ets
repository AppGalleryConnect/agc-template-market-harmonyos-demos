import { HashSet } from '@kit.ArkTS';
import { GlobalStateMgr, iData } from 'lib_foundation';
import { ShoppingCartApis } from 'lib_network';
import { CartCardModel } from '../models/CartCardModel';

export enum CartStatus {
  NOT_LOGGED_IN, // 未登录
  EMPTY, // 购物车为空
  NOT_EMPTY, // 购物车不为空
  LOADING, // 加载中
}

@ObservedV2
export class ShoppingCartVM {
  public readonly global: GlobalStateMgr = iData.global;
  private selectedSkuCodes: HashSet<string> = new HashSet();
  @Trace
  public isSubPage: boolean = false;
  @Trace
  public cartCards: CartCardModel[] = [];
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
    if (this.isSubPage) {
      // class 很可能没有被垃圾回收，因此多个 Class 持续触发监听, 影响 Index 页的购物车逻辑
      return;
    }
    let needRefresh: boolean = false;

    class Temp {
      now: boolean | string = '';
    }

    for (let k of iMonitor.dirty) {
      const v: IMonitorValue<Temp> | undefined =
        iMonitor.value<Temp>(k);
      if (v) {
        switch (k) {
          case 'global.rootPageActiveTabId':
            if (typeof v.now === 'string') {
              if (v.now === 'CartPage') {
                needRefresh = true;
              }
            }

            break;
          case 'global.isNavPathStackEmpty':
            if (typeof v.now === 'boolean') {
              if (v.now && iData.global.rootPageActiveTabId === 'CartPage') {
                needRefresh = true;
              }
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
    // 每次来到购物车页面时，如果处于手机号未关联状态，还原所有状态
    if (!iData.global.isLogin) {
      this.version = '';
      this.status = CartStatus.NOT_LOGGED_IN;
      this.isDownRefreshing = false;
      this.isShowLoadingLogo = false;
      return;
    }
    if (!needVerifyVersion) {
      // 下拉刷新触发的更新不需要额外显示加载LOGO
      this.update();
    } else if (
      this.version === '' ||
        this.version !== iData.global.cartVersion
    ) {
      if (this.status === CartStatus.NOT_LOGGED_IN) {
        this.status = CartStatus.LOADING;
      }
      this.isShowLoadingLogo = true;
      this.update();
    }
  };
  private update = async (): Promise<void> => {
    const globalVersion: string = iData.global.cartVersion;
    const cartCards: CartCardModel[] = [];
    let v: string = '';
    let total: number = 0;
    try {
      const res = await ShoppingCartApis.getCartData();
      if (res.code === 0) {
        const cartDto = res.data;
        v = cartDto.version;
        total = cartDto.total;
        for (let card of cartDto.cards) {
          const vm: CartCardModel = new CartCardModel();
          vm.productId = card.productId;
          vm.skuCode = card.skuCode;
          vm.controller = new ListScroller();
          vm.skuDesc = card.skuDesc;
          vm.stock = card.stock;
          vm.count = card.count;
          vm.banner = card.banner;
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
    this.status =
      cartCards.length > 0 ? CartStatus.NOT_EMPTY : CartStatus.EMPTY;
    if (this.status !== CartStatus.NOT_EMPTY) {
      this.isEditingMode = false;
    }
  };
  private readonly calcTotalPrice = (): void => {
    let totalPrice: number = 0;
    for (let sku of this.cartCards) {
      if (this.selectedSkuCodes.has(sku.skuCode)) {
        totalPrice = totalPrice + sku.price * sku.count;
      }
    }
    this.totalPrice = Number(totalPrice.toFixed(2));
  };
}
