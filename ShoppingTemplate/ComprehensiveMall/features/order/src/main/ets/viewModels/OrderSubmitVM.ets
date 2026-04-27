import { AddressManageUtil } from 'address_management';
import { iData, WindowUtil } from 'lib_foundation';
import {
  AddressInfo,
  CartItemKey,
  CartPrice,
  DiscountItem,
  OrderApis,
  OrderCreateReq,
  OrderPosition,
  OrderSkuItem,
  PickupStoreInfo,
  PreOrderInfoReq,
  ShippingOption,
  ShoppingCartApis,
} from 'lib_network';
import { OrderUtil } from '../utils/OrderUtil';

@ObservedV2
export class OrderSubmitVM {
  @Trace
  isLoading: boolean = false;
  @Trace
  shippingIndex: ShippingOption = ShippingOption.EXPRESS;
  @Trace
  customerAddress: string = '请填写收件人地址';
  @Trace
  customerName: string = '请填写收件人信息';
  @Trace
  customerPhone: string = '';
  @Trace
  getPosition: OrderPosition = {
    latitude: 0,
    longitude: 0,
  };
  @Trace
  city: string = '';
  @Trace
  skuList: OrderSkuItem[] = [];
  @Trace
  discountId: string = '';
  @Trace
  discountAmount: number = 0;
  @Trace
  remark: string = '';
  @Trace
  remarkCache: string = '';
  @Trace
  preOrderRequest: PreOrderInfoReq | undefined = undefined;
  @Trace
  cartPrice: CartPrice = {
    finalPrice: 0,
    originalPrice: 0,
    discountList: [],
  };
  @Trace
  defaultPickupStore: PickupStoreInfo | undefined = undefined;

  @Computed
  get SHOP_ADDRESS(): string {
    return this.defaultPickupStore?.address ?? '加载中...';
  }

  @Computed
  get SHOP_PHONE(): string {
    return this.defaultPickupStore?.cellphone ?? '';
  }

  @Computed
  get ShippingLabel() {
    return this.shippingIndex === ShippingOption.EXPRESS
      ? '快递发货'
      : '到店自提';
  }

  @Computed
  get totalProductCount() {
    if (this.skuList.length) {
      return this.skuList.reduce((a, b) => a + b.count, 0);
    }
    return 0;
  }


  async initData(preOrderRequest: PreOrderInfoReq) {
    this.isLoading = true;
    this.preOrderRequest = preOrderRequest;
    AddressManageUtil.getDefaultAddress().then((res) => {
      if (res) {
        this.customerName = res.name;
        this.customerPhone = res.phone;
        this.customerAddress =
          res.province + res.city + res.district + res.street + res.detail;
        this.city = res.city;
        this.getPosition = {
          latitude: res.latitude,
          longitude: res.longitude,
        };
      }
    });
    OrderApis.getDefaultPickupStore().then((res) => {
      if (res.code === 0) {
        this.defaultPickupStore = res.data;
      }
    });
    OrderApis.getPreOrderInfo(preOrderRequest)
      .then((res) => {
        if (res.code === 0) {
          this.skuList = res.skuList;
          ShoppingCartApis.calcCartPrice({
            isMember: iData.global.userInfo.isMember,
            skuList: this.skuList,
          }).then((res) => {
            if (res.code === 0) {
              this.cartPrice = res.data;
              this.cartPrice.discountList.push({
                type: 2,
                label: '优惠券',
                discountPrice: 0,
              });
            }
          });
        }
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  addCouponDiscount(value: number) {
    const discountItem: DiscountItem = {
      type: 2,
      label: '优惠券',
      discountPrice: value,
    };
    const old = this.cartPrice.discountList.find((item) => item.type === 2);
    if (old) {
      old.discountPrice = value;
    } else {
      this.cartPrice.discountList.push(discountItem);
    }
    ShoppingCartApis.calcCartPrice({
      isMember: iData.global.userInfo.isMember,
      skuList: this.skuList,
      extraDiscount: [discountItem],
    }).then((res) => {
      if (res.code === 0) {
        this.cartPrice = res.data;
        const existingCoupon = this.cartPrice.discountList.find(item => item.type === 2);
        if (!existingCoupon) {
          this.cartPrice.discountList.push(discountItem);
        }else {
          existingCoupon.discountPrice = value;
        }
      }
    });
  }

  async onSubmit() {
    if (!this.preOrderRequest) {
      return;
    }
    if (
      this.shippingIndex === ShippingOption.EXPRESS &&
        (!this.customerName || !this.customerAddress)
    ) {
      WindowUtil.toast('请选择地址');
      return;
    }
    if (
      this.shippingIndex === ShippingOption.SELF_PICK_UP &&
        this.defaultPickupStore === undefined
    ) {
      WindowUtil.toast('自提点信息加载中，请稍候');
      return;
    }
    this.createOrder();
  }

  // todo: 创建订单，此处为mock实现
  async createOrder() {
    let addressInfo: AddressInfo;
    if (this.shippingIndex === ShippingOption.EXPRESS) {
      addressInfo = {
        name: this.customerName,
        cellphone: this.customerPhone,
        address: this.customerAddress,
      };
      addressInfo.latitude = this.getPosition.latitude;
      addressInfo.longitude = this.getPosition.longitude;
      addressInfo.city = this.city;
    } else {
      const pickupStore = this.defaultPickupStore;
      if (pickupStore === undefined) {
        return;
      }
      addressInfo = {
        name: pickupStore.storeName,
        cellphone: pickupStore.cellphone,
        address: pickupStore.address,
      };
      addressInfo.latitude = pickupStore.latitude;
      addressInfo.longitude = pickupStore.longitude;
    }
    const data: OrderCreateReq = {
      skuList: this.skuList,
      orderInfo: {
        addressInfo,
        remark: this.remark,
        originalPrice: this.cartPrice.originalPrice,
        finalPrice: this.cartPrice.finalPrice,
        couponId: this.discountId || undefined,
        receivingMethod: this.shippingIndex,
        discounts: this.cartPrice.discountList,
      },
    };
    OrderApis.createOrder(data).then((res) => {
      if (res.code === 0) {
        this.handleOrderCreateSuccess();
        OrderUtil.handleImmediatePayment({
          orderNo: res.orderNo,
          data: res.detail,
        });
      }
    });
  }

  handleOrderCreateSuccess() {
    const codes: CartItemKey[] = [];
    this.preOrderRequest!.items.forEach((item) => {
      codes.push({
        skuCode: item.skuCode,
        priceType: item.priceType,
      });
    });
    OrderUtil.updateCouponStatus(this.discountId, 1)
    ShoppingCartApis.deleteSkuFromCart({
      skuList: codes,
      isRemain: false,
    });
  }
}
