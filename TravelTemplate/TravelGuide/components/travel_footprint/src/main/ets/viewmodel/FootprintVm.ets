import { FootPrintItem, FootPrintList } from './FootprintModel';


@ObservedV2
export class FootprintVm {
  @Trace selectList: SelectOption[] = []
  @Trace selectYear: ResourceStr = ''
  @Trace selectIndex: number = 0
  @Trace allFootPrintList: FootPrintList[] = []
  @Trace footPrintList: FootPrintList[] = []
  @Trace lightItems: FootPrintItem[] = []
  @Trace showAll: boolean = false

  initData(data: FootPrintItem[]) {
    this.allFootPrintList = []
    let yearList = data.map(item => item.year)
    yearList = Array.from(new Set(yearList))
    this.selectList = yearList.map(item => {
      return { value: item } as SelectOption
    })
    yearList.forEach(year => {
      let obj: FootPrintList = { year: year, list: data.filter(item => item.year === year) }
      this.allFootPrintList.push(obj)
    })
    this.selectIndex = 0
    this.selectYear = yearList[0]
    this.changeSelect()
  }

  changeSelect() {
    if (this.showAll) {
      this.footPrintList = this.allFootPrintList
    } else {
      this.footPrintList = this.allFootPrintList.filter(item => item.year === this.selectYear)
    }
    this.getLightItems()
  }

  getLightItems() {
    let lightItems: FootPrintItem[] = []
    this.footPrintList.forEach(item => {
      lightItems = lightItems.concat(item.list)
    })
    this.lightItems = lightItems.filter((item, index) => {
      return lightItems.findIndex(i => i.city === item.city) === index;
    })
  }

  getMiles() {
    let singItemMile = 179
    let miles = 0
    this.footPrintList.forEach(item => {
      miles += item.list.length * singItemMile
    })
    return miles.toString()
  }
}