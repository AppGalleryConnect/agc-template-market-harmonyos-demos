

export interface PreOrderRequest {
  items: PreOrderItem[];
  removeFromCart: boolean;
}

export interface PreOrderItem {
  skuCode: string;
  quantity: number;
}

export interface OrderListRequest  {
  type:number
}
