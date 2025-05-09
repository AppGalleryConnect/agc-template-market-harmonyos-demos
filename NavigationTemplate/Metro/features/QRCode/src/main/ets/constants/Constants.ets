export interface TabListItem{
  label:string
}

export const TAB_LIST: TabListItem[] = [
  {
    label: '扫码乘车',
  },
  {
    label: '一日票',
  },
  {
    label: '三日票',
  },
];

export const TICKET_WALLET: TabListItem[] = [
  {
    label: '可使用',
  },
  {
    label: '待支付',
  },
  {
    label: '失效票',
  },
];