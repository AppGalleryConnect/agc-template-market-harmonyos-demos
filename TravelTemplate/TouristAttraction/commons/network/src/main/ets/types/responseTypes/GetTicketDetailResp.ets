export interface GetTicketDetailResp {
  ticketId: number
  ticketName: string
  basicTicketTypeId: number
  banner: ResourceStr
  labels: string[]
  toKnow: string
  phone: string
  description: string
  ticketType: TicketType[]
}

export interface TicketType {
  ticketTypeId: number,
  ticketTypeName: string,
  originalPrice: number,
  discountPrice: number,
  instruction: string
}

export interface GetTicketDetailsResp extends Array<GetTicketDetailResp> {}