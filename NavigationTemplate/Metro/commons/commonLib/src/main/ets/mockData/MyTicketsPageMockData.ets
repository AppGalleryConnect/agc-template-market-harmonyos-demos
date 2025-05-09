export class MyTickets {
  image:Resource
  title:string
  totalTime:number
  totalCount:number
  lastPayTime:string

  constructor(image: Resource, title: string, totalTime: number, totalCount: number, lastPayTime:string ) {
    this.image = image
    this.title = title
    this.totalTime = totalTime
    this.totalCount = totalCount
    this.lastPayTime = lastPayTime
  }
}

export const myTicketsOneDay:MyTickets = new MyTickets($r('app.media.e_tickets_one_day'), '地铁一日票', 24, 1,'0')
export const myTicketsThreeDays:MyTickets = new MyTickets($r('app.media.e_tickets_three_day'), '地铁三日票', 72, 1,'0')

export const availableTickets:MyTickets[] = [myTicketsOneDay,myTicketsThreeDays]
export const waitingForPayTickets:MyTickets[] = [myTicketsOneDay]
export const notAvailableTickets:MyTickets[] = [myTicketsOneDay,myTicketsThreeDays]