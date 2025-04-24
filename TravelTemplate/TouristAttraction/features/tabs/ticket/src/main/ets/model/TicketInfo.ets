export class TicketInfo {
  ticketId: number = 0
  ticketName: string = ''
  basicTicketTypeId: number = 0
  banner: ResourceStr = ''
  labels: string[] = []
  toKnow: string = ''
  phone: string = ''
  description: string = ''
  ticketType: TicketType[] = []
}

export class TicketType {
  ticketTypeId: number = 0
  ticketTypeName: string = ''
  originalPrice: number = 0
  discountPrice: number = 0
  instruction: string = ''
}

export interface TouristManagementMap {
  index: number
  wrapper: WrappedBuilder<[]>
}

