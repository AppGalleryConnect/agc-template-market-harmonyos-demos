export interface TicketTypeData {
  title: TicketTypeInfoItem
  component: WrappedBuilder<[]>
}

enum TicketTypeInfoItem {
  RESERVE = '产品预订',
  BRIEF = '简介须知'
}