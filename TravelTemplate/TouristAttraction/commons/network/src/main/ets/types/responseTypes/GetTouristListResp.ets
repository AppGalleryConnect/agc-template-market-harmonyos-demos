export interface TouristListItem {
  id: string
  name: string
  phone: string
  cardType: number
  cardNo: string
  isChecked: boolean
}

export class GetTouristListResp extends Array<TouristListItem> {}