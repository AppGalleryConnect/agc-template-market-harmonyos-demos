export interface TicketListItem {
  ticketId: number
  ticketName: string
  basicTicketTypeId: number
  banner: ResourceStr
  labels: string[]
  ticketType: TicketType[]
}

export interface TicketType {
  ticketTypeId: number,
  ticketTypeName: string,
  originalPrice: number,
  discountPrice: number,
  instruction: string
}

export interface GetTicketListResp extends Array<TicketListItem> {}