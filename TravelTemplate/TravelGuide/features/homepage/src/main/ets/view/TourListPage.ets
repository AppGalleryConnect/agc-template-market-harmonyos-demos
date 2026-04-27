import { BarVM, CommonEmpty, TValueType } from 'common'
import { phoneRouterControl } from 'oh_router'
import { TourPageParam, TourModel, TourGrid } from 'common_travel_guide'
import { TourListPageVM } from '../viewmodel/TourListPageVM'

@Builder
export function TourListPageBuilder(params?: TValueType) {
  TourListPage({ pageParam: params as TourPageParam })
}

const TAG = 'TourListPage'

@ComponentV2
export struct TourListPage {
  vm: TourListPageVM = new TourListPageVM()
  @Param pageParam: TValueType = null

  aboutToAppear() {
    // 加载 JSON 数据
    this.vm.tourList = this.vm.mockTourList;
    // 获取路由传参
    this.vm.searchParam = this.pageParam as TourPageParam;
    this.vm.doSearch(this.vm.searchParam)
  }

  // 搜索
  @Builder
  searchBuilder() {
    Row() {
      // 返回按钮
      Image($r('app.media.icon_back')).height('100%').width(40)
        .onClick(() => {
          this.vm.backPage()
        })
      // 城市关键字输入
      TextInput({ placeholder: '请输入关键字', text: this.vm.searchParam.keyword })
        .type(InputType.Normal)
        .caretColor($r('sys.color.font_emphasize'))
        .fontSize(14)
        .height(36)
        .backgroundColor('#F3F4F6')
        .borderRadius(18)
        .padding({ left: 12, right: 12 })
        .onChange((val: string) => this.vm.searchParam.keyword = val)
        .layoutWeight(1)
        .margin({ left: 10, right: 10 })
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: {
            size: 20,
            src: $r('app.media.icon_delete'),
          }
        })
      // 搜索按钮
      Button('搜索')
        .borderColor('rgba(0, 0, 0, 0.10)')
        .backgroundColor(Color.Transparent)
        .borderRadius(20)
        .borderWidth(0.5)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .padding({
          left: 15,
          top: 12,
          right: 15,
          bottom: 12
        })
        .onClick(() => {
          this.vm.doSearch(this.vm.searchParam)
        })
    }
    .width('100%')
    .height(40)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  render() {
    Column() {
      // 顶部搜索栏
      this.searchBuilder();
      //旅游列表
      if (this.vm.searchList.length > 0) {
        TourGrid({
          tourList: this.vm.searchList,
          jumpTourDetailPage: (listItem: TourModel) => {
            this.vm.jumpTourDetailPage(listItem)
          }
        })
      } else {
        CommonEmpty()
      }
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH,
      left: 16,
      right: 16,
    })
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
