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

@ObservedV2
export class UserInfo {
  authCode: string = ''
  @Trace avatar: string = ''
  idToken: string = ''
  @Trace phoneNumber: string = ''
  @Trace userName: string = ''

  constructor(userInfo?: UserInfo) {
    this.authCode = userInfo?.authCode || ''
    this.avatar = userInfo?.avatar || ''
    this.idToken = userInfo?.idToken || ''
    this.phoneNumber = userInfo?.phoneNumber || ''
    this.userName = userInfo?.userName || ''
  }
}

export class GridBanner {
  serviceId: string = ''
  pic: string = ''
  name: string = ''
}

export class HotService {
  serviceId: string = ''
  icon: ResourceStr = ''
  pic?: ResourceStr = ''
  olderPic?: ResourceStr = ''
  name: ResourceStr = ''
}

export class TabsInfo {
  icon: string = ''
  iconSel: string = ''
  title: string = ''
}

export class ParamsObj {
  title?: string = ''
  loadUrl?: string = ''
  recordList?: ReservationRecord[]
  interception?: boolean
  isHospital: boolean = false
  userInfo?: UserInfo = new UserInfo()

  constructor(title?: string) {
    this.title = title
  }
}

interface FunctionResultRet {
  code: number
  desc: string
}


export interface CloudUserInfoResult {
  ret: FunctionResultRet,
  result: UserInfo[]
}

export interface CloudHomeListResult {
  ret: FunctionResultRet,
  result: HomeServiceList
}

export class InformationServiceList {
  commonlyUsed: GridBanner[] = []
  allService: GridBanner[] = []
  newsList: string[] = []
  convenienceService: GridBanner[] = []
}


export interface CloudInformationListResult {
  ret: FunctionResultRet,
  result: InformationTabsInfo[]
}

export interface CloudServiceListResult {
  ret: FunctionResultRet,
  result: ServiceListInfo[]
}

export interface CloudInstitutionsResult {
  ret: FunctionResultRet,
  result: InstitutionsItem[]
}

export interface CloudInquiryResult {
  ret: FunctionResultRet,
  result: DrugInquiryItem[]
}


export interface CloudFunctionUserResult {
  result: CloudUserInfoResult
}

export interface CloudFunctionHomeResult {
  result: CloudHomeListResult
}

export interface CloudFunctionInformationResult {
  result: CloudInformationListResult
}

export interface CloudFunctionServiceResult {
  result: CloudServiceListResult
}

export interface CloudFunctionInstitutionsResult {
  result: CloudInstitutionsResult
}

export interface CloudFunctionInquiryResult {
  result: CloudInquiryResult
}

export class Classifieds {
  name: string = ''
  state: string = ''
}

export class InstitutionsItem {
  name: string = ''
  siteId: string = ''
  address: string = ''
  call: string = ''
  location: Record<string, number> = {}
  level: number = 0
  classifieds: Classifieds[] = []
  organizationCode: string = ''
  organizationType: string = ''
  offSiteMedicalServices: string = ''
}


export class DrugInquiryItem {
  name: string = ''
  code: string = ''
  manufacturer: string = ''
  specification: string = ''
  dosage: string = ''
}

export class InformationTabsInfoContent {
  isHot?: boolean = false
  cover: string = ''
  access: string = ''
  title: string = ''
  date: string = ''
}


export class InformationTabsInfo {
  name: string = ''
  content: InformationTabsInfoContent[] = []
}

export class ServiceListInfo {
  categoryName: string = ''
  categoryId: string = ''
  serviceList: ServiceList[] = []
}

export class ServiceList {
  serviceId: string = ''
  name: string = ''
  icon: string = ''
}

export class HomeServiceList {
  commonlyUsed: GridBanner[] = []
  allService: GridBanner[] = []
  hotServices: HotService[] = []
  convenienceService: GridBanner[] = []
}

export class ReservationRecord {
  recordName: string = ''
  calendarStartTime: number = 0
  calendarEndTime: number = 0
  eventId: number = -1
}

export interface CardInfo {
  icon: string
  name: string
  buttonName: string
  color: string
}

export interface MineGridInfo {
  pic: string
  name: string
}

export interface MessageInfo {
  title: string;
  icon: string;
  message: string[];
}

export interface SettingItem {
  id: string
  icon?: string
  name: string
  moreIcon: string
}

export interface ProgressItem {
  id: string
  icon?: string
  name: string
}

export class CalendarResult {
  data?: number = -1
  status: string = ''
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

export class CallSheetParams {
  modelShow: boolean = false
}