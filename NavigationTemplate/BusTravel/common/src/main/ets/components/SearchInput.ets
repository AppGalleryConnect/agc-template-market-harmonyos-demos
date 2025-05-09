import { SearchSet } from '../model/commonInterface';
import { getDataFromJSON } from '../utils/RawFileDealUtils';
import { RouteEntryVM } from '../utils/RouteEntryVM';
import { SymbolGlyphModifier } from '@kit.ArkUI';

@Component
export struct SearchInput { // 查找线路

  @State searchWidth: number = 211
  @State searchHeight: number = 32
  @State searchPlaceholder: string = '搜索公交线路、站点'
  @State searchIconSize: number = 24
  @State searchIconColor: Color = Color.White
  @State searchFontColor: Color = Color.White
  @State searchFontSize: number = 12
  @State listInfoItem: Array<SearchSet> = []
  @Link changeValue: string
  @State searchListInfoItem: Array<SearchSet> = []
  @State searchLineName: Array<string> = []
  vm: RouteEntryVM = RouteEntryVM.instance;

  aboutToAppear(): void {
    this.initDataSource()
    console.log('============' + JSON.stringify(this.listInfoItem))
  }

  initDataSource() {
    this.listInfoItem = getDataFromJSON<SearchSet>('Bus_Station.json', this);
    for (let i = 0; i < this.listInfoItem.length; i++) {
      this.searchLineName.push(this.listInfoItem[i].lineName)
    }
  }

  getSearchListInfo() {
    if (this.changeValue) { // 判断用户是否输入了内容
      this.searchLineName = this.searchLineName.filter((item, index) => { // filter遍历listInfoItem
        return item.indexOf(this.changeValue) !== -1 // 若indexOf()返回的结果不为-1即name中包含changeValue，则保留该项
      }) // 筛选完后的值会被赋值到searchListInfoItem中
    }
  }

  build() {
    Search({ value: this.changeValue, placeholder: this.searchPlaceholder })
      .caretStyle({width:1.5, color:$r('app.color.system_color_green')})
      .width(this.searchWidth)
      .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontSize('16vp'))
      .textFont({ size: $r('sys.float.Body_L') })
      .fontColor($r('sys.color.font_primary'))
      .placeholderFont({ size: $r('sys.float.Body_L') })
      .margin({ right: 22 })
      .onClick(() => {
        this.vm.toSearchDetail(this.searchLineName, (popInfo: PopInfo) => { // 跳转SpecificContentSearch
          this.changeValue = `${popInfo.result}`
          this.getSearchListInfo()
        })
      })
  }
}