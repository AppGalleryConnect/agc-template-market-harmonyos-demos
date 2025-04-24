export interface BtnType {
  text: ResourceStr
  color: ResourceStr
  backgroundColor: ResourceStr
  callback: (orderId: string) => void
}