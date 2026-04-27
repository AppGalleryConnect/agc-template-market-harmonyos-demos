import { ModelItemInfo, ModelItemContentInfo, LayoutType } from 'category_list';
import { PhoneModelListView } from '../components/PhoneModelListView';
import { MockData } from '../data/MockData';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

@ComponentV2
export struct PhoneModelDialog {
  @Require @Param vm: CommonPageVM
  @Local currentIndex: number = 0
  @Local themeColor: ResourceColor = 'rgba(255, 75, 75, 1)'
  // 默认的型号变量
  @Local localModelItem: string = ''

  aboutToAppear(): void {
    this.localModelItem = this.vm.modelSelected
  }

  build() {
    Column() {
      // 标题部分
      RelativeContainer() {
        Text('选择型号')
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .fontSize(20).fontColor('rgba(0, 0, 0, 0.85)').fontWeight(FontWeight.Medium)

        Image($r('app.media.ic_close'))
          .onClick(() => {
            this.vm.showBottomWindow = false
          })
          .margin({ right: 20 })
          .width(16)
          .height(16)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            end: { anchor: '__container__', align: HorizontalAlign.End }
          })
      }
      .width('100%')
      .height(56)

      // 分类列表
      PhoneModelListView({
        vm: this.vm,
        productList: this.recipeCategoryList,
        currentSelectItem: this.localModelItem,
        layoutType: LayoutType.GRID,
        themeColor: this.themeColor,
        initIndex: this.currentIndex,
        scroller: new Scroller(),
        tabBarScroller: new Scroller(),
        subBarScroller: new Scroller(),
        onTabClick: (tabItem: ModelItemInfo) => {

        },
        onItemClick: (itemContent: string, itemDetail: ModelItemContentInfo) => {
          // 待实现，跳转详情页
          this.localModelItem = itemContent
        },
      }).layoutWeight(1)

      Row() {
        Text('确认')
          .height(40)
          .layoutWeight(1)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .fontColor('rgba(255, 255, 255, 1)')
          .borderRadius(20)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .margin({
            left: 28,
            right: 28,
            top: 16,
            bottom: 28
          })
          .onClick(() => {
            this.vm.modelSelected = this.localModelItem
            this.vm.showBottomWindow = false
          })
      }.width('100%').height(84).backgroundColor(Color.White)
    }
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: 32,
      topRight: 32
    })
    .width('100%')
    .padding({
      bottom: 8
    })
  }

  @Local recipeCategoryList: ModelItemInfo[] = MockData.modelCategoryList;
}