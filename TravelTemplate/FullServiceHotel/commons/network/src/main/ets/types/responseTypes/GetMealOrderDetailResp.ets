export interface GetMealOrderDetailResp {
  updateTime: string;
  orderNo: string;
  status: string;
  actualPaidPrice: string;
  totalCount: number;
  payTime: null | string;
  payExpireTime: null | string;
  prepayResult: string;
  usageRule: string;
  packageName: string;
  images: string;
}
