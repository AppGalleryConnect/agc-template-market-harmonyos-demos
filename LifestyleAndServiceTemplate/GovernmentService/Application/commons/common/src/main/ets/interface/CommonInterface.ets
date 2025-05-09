import { Type } from '@kit.ArkUI'

export class PushParams {
  'payload': Record<string, Notification | string>
  'target': Record<string, Array<string>>
  'pushOptions'?: Record<string, boolean>
}


export class Notification {
  'category': string = ''
  'title': string = ''
  'body': string = ''
  'clickAction': Record<string, number>
  'notifyId': number = 0
}

export class UserInfo {
  avatar: ResourceStr = ''
  idToken: string = ''
  userName: string = ''
  openID?: string = ''
  unionID?: string = ''
  phoneNumber: string = ''
}

export class NavigationParams {
  title: ResourceStr = ''
  loadUrl?: string = ''
  interception?: boolean = true
  isHospital?: boolean = false

  constructor(title: ResourceStr, loadUrl?: string, interception?: boolean, isHospital?: boolean) {
    this.title = title
    this.loadUrl = loadUrl
    this.interception = interception
    this.isHospital = isHospital
  }
}

export class TabsInfo {
  icon: string = ''
  iconSel: string = ''
  title: string = ''
}

export interface questionAnswer {
  answer: string
  question: string
  isExpand: boolean
}

export interface CardInfo {
  icon: string
  name: string
  buttonName: string
  color: string
}

export interface SettingItem {
  icon?: string
  name: string
  moreIcon: string
}

export interface MessageInfo {
  title: string;
  icon: string;
  message: string[];
}

export interface ExtendSettingItem {
  settingItem: SettingItem;
  isFirst: boolean;
}

export interface CityJson {
  code: string
  name: string
}

export interface LeftTab {
  leftTabName: string
  leftTabContentList: Array<LeftTabContent>
}

export interface LeftTabContent {
  title: string
  list: SubTabContent[]
}

export interface ProvincesJson {
  name: string
  code: string
  children: CityJson[]
}

export interface SubTabContent {
  text: string
  icon: string
}

export interface TabData {
  tabName: string;
  tabIndex: number;
  leftTabList: Array<LeftTab>;
}

export interface SwiperInfo {
  title: string
  footer: string
  thumbnailsJson: Array<string>
}

export class ParamsObj {
  title?: string = ''
  loadUrl?: string = ''
  interception?: boolean
  isHospital: boolean = false

  constructor(title?: string) {
    this.title = title
  }
}

export class ServiceList {
  serviceId?: string = ''
  text: string = ''
  icon: string = ''
}

export class Suggestion {
  date: Date = new Date()
  title: string = ''
  image?: string[] = []
}

export class ScanCodeRect {
  left: number = 0
  top: number = 0
  bottom: number = 0
  right: number = 0
}

export class ScanCodeRectArray {
  scanCodeRect: ScanCodeRect = new ScanCodeRect()
}
