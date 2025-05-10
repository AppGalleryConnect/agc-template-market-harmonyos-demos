import dayjs from 'dayjs'

export class LunarModel {
  dayjsObj: dayjs.Dayjs // dayjs时间
  yangli: string // 阳历日期
  yinli: string // 阴历日期
  wuxing: string // 五行
  chongsha: string // 冲煞
  baiji: string // 百祭
  jishen: string // 吉神
  yi: string // 宜
  ji: string // 忌
  xiongshen: string // 凶神

  constructor(dayjsObj: dayjs.Dayjs, result: ESObject) {
    this.dayjsObj = dayjsObj
    this.yangli = result.yangli
    this.yinli = result.yinli
    this.wuxing = result.wuxing
    this.chongsha = result.chongsha
    this.baiji = result.baiji
    this.jishen = result.jishen
    this.yi = result.yi
    this.ji = result.ji
    this.xiongshen = result.xiongshen
  }
}