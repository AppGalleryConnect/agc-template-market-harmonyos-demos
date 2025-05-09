@Observed
export class PayMethod{
  imageDefault:Resource
  text:string
  authorised:boolean = false
  backgroundColor: Resource
  url?:Resource

  constructor(imageDefault: Resource, text: string, authorised: boolean,
    backgroundColor: Resource, url?: Resource) {
    this.imageDefault = imageDefault
    this.text = text
    this.authorised = authorised
    this.backgroundColor = backgroundColor
    this.url = url
  }
}
@Observed
export class UserPayMethod{
  defaultPayMethod:PayMethod
  authorisedPayMethod:PayMethod[]
  unauthorizedPayMethod:PayMethod[]

  constructor(defaultPayMethod: PayMethod, authorisedPayMethod: PayMethod[],
    unauthorizedPayMethod: PayMethod[]) {
    this.defaultPayMethod = defaultPayMethod
    this.authorisedPayMethod = authorisedPayMethod
    this.unauthorizedPayMethod = unauthorizedPayMethod
  }
}

export const wechatPay:PayMethod = new PayMethod($r('app.media.wechat_pay'),'微信支付',true,$r('app.color.wechat_pay'),)
export const huaweiPay:PayMethod = new PayMethod($r('app.media.huawei_pay'),'华为支付',true,$r('app.color.huawei_pay'),)
export const aliPay:PayMethod = new PayMethod($r('app.media.ali_pay'),'支付宝支付',false,$r('app.color.ali_pay'),$r('app.string.alipayAddress'))
export const defaultPayMethod:PayMethod = huaweiPay
export const authorisedPayMethod:PayMethod[] = [huaweiPay]
export const unauthorizedPayMethod:PayMethod[] = [aliPay]
export const userPayMethod:UserPayMethod = new UserPayMethod(defaultPayMethod,authorisedPayMethod,unauthorizedPayMethod)
export const allPayMethod:PayMethod[] = [aliPay,huaweiPay]

export class ETickets{
  days:number
  title:string
  content1:Resource
  content2:Resource
  content3:Resource
  content4:Resource
  content5:Resource
  price:string
  image:Resource
  url?:string

  constructor(days: number, title: string, content1: Resource, content2: Resource, content3: Resource,
    content4: Resource, content5: Resource, price: string, image: Resource, url?: string) {
    this.days = days
    this.title = title
    this.content1 = content1
    this.content2 = content2
    this.content3 = content3
    this.content4 = content4
    this.content5 = content5
    this.price = price
    this.image = image
    this.url = url
  }
}

export const eTicketsOneDay:ETickets = new ETickets(
  1,
  '地铁一日票',
  $r('app.string.e_tickets_unlimited'),
  $r('app.string.e_tickets_immediately'),
  $r('app.string.e_tickets_return'),
  $r('app.string.e_tickets_high_cost_performance'),
  $r('app.string.e_tickets_first_choice'),
  '15',
  $r('app.media.e_tickets_one_day'))
export const eTicketsThreeDays:ETickets = new ETickets(
  3,
  '地铁三日票',
  $r('app.string.e_tickets_unlimited'),
  $r('app.string.e_tickets_immediately'),
  $r('app.string.e_tickets_return'),
  $r('app.string.e_tickets_high_cost_performance'),
  $r('app.string.e_tickets_first_choice'),
  '35',
  $r('app.media.e_tickets_three_day'))
export const eTicketsTotal:ETickets[] = [eTicketsOneDay,eTicketsThreeDays]