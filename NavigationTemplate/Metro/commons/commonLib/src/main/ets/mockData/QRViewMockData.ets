export interface QRViewFunction{
  image:Resource
  title:string
  uri:string
}

export const qrViewFunction:QRViewFunction[] = [
  {
    image:$r('app.media.ic_public_recording'),
    title:'乘车记录',
    uri:'RecordingPage'
  },
  {
    image:$r('app.media.ic_public_metro_map'),
    title:'线网图',
    uri:'LineMapPage'
  },
  {
    image:$r('app.media.ic_public_invoice'),
    title:'开发票',
    uri:'InvoicePage'
  },
  {
    image:$r('app.media.ic_public_wallet'),
    title:'票卡包',
    uri:'MyTicketsPage'
  },
]