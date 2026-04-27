export interface IVip {
  id: number,
  name: string,
  originalPrice: number,
  discountPrice: number,
  instructions?: string,
}

export interface IParam {
  orderId?: number,
  templateId?: number,
}