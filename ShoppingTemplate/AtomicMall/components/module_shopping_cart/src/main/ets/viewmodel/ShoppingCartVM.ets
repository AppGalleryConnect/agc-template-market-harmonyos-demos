import { iData, WindowUtil } from 'lib_foundation';
import { CartItemKey, CartPrice, ShoppingCartApis } from 'lib_network';
import { LoadingStatus } from '../commons/Constants';
import { ProductModel } from '../commons/Model';

@ObservedV2
export class CartPageVM {
  // 是否登录
  @Trace isLogin: boolean = false;
  // 是否是会员
  @Trace isMember: boolean = false;
  /* 是否是编辑态 */
  @Trace isEdit: boolean = false;
  // 页面加载loading
  @Trace loading: LoadingStatus = LoadingStatus.OFF;
  // 下拉刷新
  @Trace isRefreshing: boolean = false;
  // 跟手滑动系数
  @Trace ratio: number = 1;
  // 下拉最到高度
  @Trace maxRefreshingHeight: number = 160.0;
  // 下拉刷新组件的状态
  @Trace refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  // 购物车的数据
  @Trace cartCards: ProductModel[] = [];
  // 选择的商品个数
  @Trace quantity: number = 0;
  // 购物车金额
  @Trace cartPrice: CartPrice = {
    originalPrice: 0,
    finalPrice: 0,
    discountList: [],
  };
    // 购物车版本
  @Trace cartVersion:string = '';

  // 初始化
  init() {
    if(this.cartVersion === iData.global.cartVersion){
      return;
    }
    this.loading = LoadingStatus.LOADING;

    ShoppingCartApis.getCartList()
      .then((resp) => {
        // 1. 校验接口状态码
        if (resp.code === 0 && resp.data) {
          const serverList = resp.data; // 获取实际的商品列表

          if (serverList.length > 0) {

            // --- 第一步：更新现有本地商品数量 ---
            // 必须同时匹配 skuCode 和 priceType
            this.cartCards.forEach((localItem: ProductModel) => {
              const serverItem = serverList.find(
                (s) => s.skuCode === localItem.skuCode && s.priceType === localItem.priceType,
              );
              if (serverItem) {
                localItem.count = serverItem.count;
                localItem.price = serverItem.price;
              }
            });

            // --- 第二步：移除本地存在但服务端已删除的商品 ---
            // 倒序遍历以安全删除
            for (let i = this.cartCards.length - 1; i >= 0; i--) {
              const localItem = this.cartCards[i];
              const existsInServer = serverList.some(
                (s) => s.skuCode === localItem.skuCode && s.priceType === localItem.priceType,
              );

              if (!existsInServer) {
                this.cartCards.splice(i, 1);
              }
            }

            // --- 第三步：添加服务端新增的商品 ---
            const newCartList: ProductModel[] = [];
            serverList.forEach((serverItem) => {
              // 查找本地是否存在该商品（组合键查找）
              const existsLocally = this.cartCards.some(
                (local) => local.skuCode === serverItem.skuCode && local.priceType === serverItem.priceType,
              );

              if (!existsLocally) {
                newCartList.push(new ProductModel(serverItem));
              }
            });

            if (newCartList.length > 0) {
              // 将新商品加到头部
              this.cartCards.unshift(...newCartList);
            }
          } else {
            // 服务端列表为空，清空本地
            this.cartCards = [];
          }
          this.cartVersion = iData.global.cartVersion;
        }
      })
      .catch((err: Error) => {
        // 异常处理
        console.error('Get cart list failed:', err);
      })
      .finally(() => {
        this.loading = LoadingStatus.SUCCESS;
      });

  }

  // 下拉刷新
  onRefreshStateChange(state: RefreshStatus) {
    this.refreshStatus = state;
  }

  // 更新购物车商品的数量
  updateProductCount(skuCode: string) {
    let data = this.cartCards.find((item: ProductModel) => item.skuCode === skuCode);
    if (data) {
      ShoppingCartApis.updateProductSkuCount({
        skuCode: skuCode,
        count: data?.count ?? 1,
        priceType: data.priceType,
      }).then(() => {
        // 计算总价
        this.calcTotalPrice();
      });
    }

  }

  // 计算总价
  calcTotalPrice() {
    let selectedGoodList: ProductModel[] = this.cartCards.filter(
      (good: ProductModel) => good.isSelected,
    );
    ShoppingCartApis.calcCartPrice({
      isMember: this.isMember,
      skuList: selectedGoodList,
    }).then((res) => {
      if (res.code === 0) {
        this.cartPrice = res.data;
      }
    });
  }

  // 计算选择的商品个数
  calcQuantity() {
    let selectedGoodList: ProductModel[] = this.cartCards.filter(
      (good) => good.isSelected,
    );
    this.quantity = selectedGoodList.length;
  }

  // 删除商品
  onDeleteProduct(skuCode: string = '') {
    // 侧滑删除商品
    if (skuCode) {
      let idx = this.cartCards.findIndex(
        (good: ProductModel) => good.skuCode === skuCode,
      );
      this.cartCards.splice(idx, 1);
    } else {
      // 删除已选的商品
      this.cartCards = this.cartCards.filter(
        (good: ProductModel) => !good.isSelected,
      );
    }
    let list: CartItemKey[] = this.cartCards.map((item: ProductModel) => ({
        skuCode: item.skuCode,
        priceType: item.priceType,
      } as CartItemKey));

    ShoppingCartApis.deleteSkuFromCart({
      skuList: list,
      isRemain: true,
    }).then(() => {
      WindowUtil.toast('删除成功！');
    });
  }

  // 商品结算
  public onCheckout(): ProductModel[] {
    // 已选的购物车商品
    const selectedGoodList: ProductModel[] = this.cartCards.filter(
      (good: ProductModel) => good.isSelected,
    );
    return selectedGoodList;
  }
}
