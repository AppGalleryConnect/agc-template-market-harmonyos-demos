export interface IMainService {
  type: number,
  name: string,
  image: ResourceStr,
  index: number,
}

export interface IRouterPurchase {
  id: number,
  isPurchase: boolean,
}

export interface IButtonMoney {
  index: number,
  text: string,
}