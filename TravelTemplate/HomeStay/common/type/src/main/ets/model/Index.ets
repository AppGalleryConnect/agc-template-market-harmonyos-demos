export interface OrderParam {
  orderStatus: number,
  orderType: number
}

export interface Instructions {
  foundations: Array<Tag>;
  reservation: Array<Tag>;
  checkOut: Array<Tag>
}

export interface Tag {
  tag: string,
  subTags: string[]
}
