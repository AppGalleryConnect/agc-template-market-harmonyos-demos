import { HashMap, PlainArray } from '@kit.ArkTS';

declare type Everything = object | string | string[] ;

export class Application {
  properties: PlainArray<Everything> = new PlainArray()

  setProperty(prop: PROP, value: Everything) {
    this.properties.add(getPropIndex(prop), value)
  }

  getProperty(prop: PROP): Everything {
    return this.properties.get(getPropIndex(prop))
  }

  getProperties(): PlainArray<Everything> {
    return this.properties;
  }

  hasProperty(prop: PROP): boolean {
    return this.properties.has(getPropIndex(prop))
  }
}

export class Card extends Application {
  applications: HashMap<Everything, Application> = new HashMap<Everything, Application>()

  isUnknownCard(): boolean {
    return this.applicationCount() === 0;
  }

  applicationCount(): number {
    return this.applications.length;
  }

  getApplications(): Application[] {
    let ret: Application[] = []
    let values = this.applications.values()
    for (let valuesElement of values) {
      ret.push(valuesElement)
    }
    return ret
  }

  addApplication(app: Application | undefined) {
    if (app) {
      let id = app.getProperty(PROP.ID);
      if (id && !this.applications.hasKey(id)) {
        this.applications.set(id, app);
      }
    }
  }
}

export function getPropIndex(prop: PROP): number {
  let result: number = 0
  switch (prop) {
    case PROP.ID:
      result++
    case PROP.SERIAL:
      result++
    case PROP.PARAM:
      result++
    case PROP.VERSION:
      result++
    case PROP.DATE:
      result++
    case PROP.COUNT:
      result++
    case PROP.CURRENCY:
      result++
    case PROP.TLIMIT:
      result++
    case PROP.DLIMIT:
      result++
    case PROP.ECASH:
      result++
    case PROP.BALANCE:
      result++
    case PROP.OLIMIT:
      result++
    case PROP.TRANSLOG:
      result++
    case PROP.ACCESS:
      result++
    case PROP.NFCINFOID:
      result++
    case PROP.NFCINFO:
      result++
    case PROP.EXCEPTION:
      result++
  }
  return result
}

export enum PROP {
  ID = '应用',
  SERIAL = '卡号：',
  PARAM = '参数：',
  VERSION = '版本：',
  DATE = '生效：',
  COUNT = '交易：',
  CURRENCY = '币种：',
  TLIMIT = '单笔上限',
  DLIMIT = '圈存上限',
  ECASH = '电子现金',
  BALANCE = '余额：',
  OLIMIT = '透支上限',
  TRANSLOG = '交易记录',
  ACCESS = '访问受限',
  NFCINFOID = 'NFC信息ID',
  NFCINFO = 'NFC信息',
  EXCEPTION = '错误：'
}

export enum CUR {
  UNKNOWN = '未知',
  USD = '美元',
  CNY = '元',
  HKD = '港币'
}

export enum APP {
  UNKNOWN = '未知卡',
  UNKNOWNCITY = '深圳通',
  SHENZHENTONG = '银联闪付卡',
  QUICKPASS = '香港八达通',
  OCTOPUS = '长安通',
  BEIJINGMUNICIPAL = '武汉城市一卡通',
  WUHANTONG = '北京市政交通卡',
  CHANGANTONG = '上海公交卡',
  SHANGHAIGJ = '借记卡',
  DEBIT = '信用卡',
  CREDIT = '准贷记卡',
  QCREDIT = '交通联合卡',
  TUNIONEC = '交通联合卡',
  TUNIONEP = '城市一卡通',
  CITYUNION = '未知城市'
}