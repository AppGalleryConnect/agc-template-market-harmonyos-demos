export class UserInfo {
  id: string = ''
  nickName: string = ''
  avatarUrl?: string
  birthday?: string
  telephone?: string
  borrowCardStart?: number
  borrowCardEnd?: number
  totalReading: number = 0
  totalListening: number = 0
  isLogin?: boolean
  level?:number
  bio?:string = ''
  gender?:boolean
  isMembership: boolean = false
  bookCoins: number = 100
  continuousBuy: boolean = false
  reminderTime: number = 0
  fullScreen: boolean = false
  noTimeBattery: boolean = false
}