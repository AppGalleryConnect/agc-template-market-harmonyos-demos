export interface OrderItem {
  orderNo: string;
  orderStatus: string;
  createTime: string;
  id: number;

  // userId: number;
  actualPaidPrice: string;

  // currency: string;
  shopName: string;
  goodsName: string;
  orderType: string;

  // shopId: number | null;
  // goodsId: number | null;
  // orderDetailId: number | null;
  goodsQty: number;

  // goodsPrice: number;
  // icon?: ResourceStr;
  shopLogo: ResourceStr;
  displayImg: ResourceStr;
}

export type GetOrderListResp = OrderItem[];
