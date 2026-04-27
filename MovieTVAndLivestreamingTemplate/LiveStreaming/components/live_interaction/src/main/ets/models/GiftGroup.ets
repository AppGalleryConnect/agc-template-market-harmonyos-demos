export class GiftModel {
  name: string;
  icon: ResourceStr;
  price: number;
  id: number

  constructor(name: string, icon: ResourceStr, price: number, id: number) {
    this.name = name
    this.icon = icon
    this.price = price
    this.id = id
  }
}