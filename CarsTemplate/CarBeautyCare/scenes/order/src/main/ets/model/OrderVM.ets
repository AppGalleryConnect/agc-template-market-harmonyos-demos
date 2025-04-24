import { ShopCardModel } from '@ohos_agcit/car_beauty_care_shop'
import { ProductCard } from '@ohos_agcit/car_beauty_care_product'
import { CouponModel, CouponVM } from '@ohos_agcit/car_beauty_care_coupon'
import { VehicleVM, VehicleModel  } from '@ohos_agcit/car_beauty_care_garage'
import { ContactModel } from '@ohos_agcit/car_beauty_care_contact'
export enum ORDER_STATUS {
  PENDING_PAYMENT = '待支付',
  CANCELLED = '已取消',
}

@ObservedV2
export class Order {
  @Trace shop:ShopCardModel;
  @Trace product: ProductCard[];
  @Trace coupon: CouponModel | null;
  @Trace vehicle: VehicleModel | null;
  @Trace contact: ContactModel| undefined;
  id: string;
  @Trace status: ORDER_STATUS;
  constructor(shop:ShopCardModel, product: ProductCard[], id:string, status: ORDER_STATUS,
    coupon: CouponModel | null , vehicle: VehicleModel | null, contact:ContactModel | undefined) {
    this.shop = shop;
    this.product = product;
    this.id = id;
    this.status = status;
    this.coupon = coupon;
    this.vehicle = vehicle;
    this.contact = contact;
  }

  updateStatus(status: ORDER_STATUS) {
    this.status = status;
  }
}

@ObservedV2
export class OrderVM {
  couponVM: CouponVM = CouponVM.instance;
  @Trace orderList: Order [] = [];
  private static _instance:OrderVM;
  public static get instance() {
    if(!OrderVM._instance) {
      OrderVM._instance = new OrderVM();
    }
    return OrderVM._instance;
  }

  // 提交订单
  public submitOrder(shopData: ShopCardModel, productData: ProductCard[], couponData:CouponModel | null,
    vehicelData:VehicleModel | null, contactData: ContactModel | undefined) {
    const id = String(new Date().getTime());
    const status = ORDER_STATUS.PENDING_PAYMENT
    this.orderList.push(new Order(JSON.parse(JSON.stringify(shopData)), JSON.parse(JSON.stringify(productData)),
      id, status, JSON.parse(JSON.stringify(couponData)), JSON.parse(JSON.stringify(vehicelData)),
      JSON.parse(JSON.stringify(contactData))))
    if (this.couponVM.willUserCoupon !== null) {
      this.couponVM.willUserCoupon.used = true;
      this.couponVM.willUserCoupon = null;
    }
  }

  // 删除订单
  public deleteOrder(id:string) {
    const index = this.orderList.findIndex((item: Order) => {
      item.id === id;
    })
    this.orderList.splice(index, 1)
  }

  // 取消订单
  public cancelOrder(id:string) {
    const order = this.orderList.find((item:Order) => {
      return item.id === id;
    })
    if (order) {
      order.status = ORDER_STATUS.CANCELLED
    }
  }

  // 根据状态查询订单
  public getOrderByStatus(status: ORDER_STATUS): Order[] {
    const orders = this.orderList.filter((item: Order) => {
      return item.status === status;
    })
    return orders;
  }

}