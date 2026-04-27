import { LayoutType, ModelItemInfo } from 'category_list';
import { CameraModelListView } from '../components/CameraModelListView';
import { MockData } from '../data/MockData';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

@ComponentV2
export struct CameraModelDialog {
  @Require @Param vm: CommonPageVM
  @Local currentIndex: number = 0
  // 默认的型号变量
  @Local localModelItem: string = ''
  @Local themeColor: ResourceColor = 'rgba(255, 75, 75, 1)'

  aboutToAppear(): void {
    this.localModelItem = this.vm.cameraModelSelected
  }

  build() {
    Column() {
      // 标题部分
      RelativeContainer() {
        Text('选择型号')
          .fontColor('rgba(0, 0, 0, 0.85)')
          .fontSize(20)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .fontWeight(FontWeight.Medium)

        Image($r('app.media.ic_close'))
          .margin({ right: 20 })
          .onClick(() => {
            this.vm.showBottomWindow = false
          })
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            end: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .width(16)
          .height(16)
      }
      .width('100%')
      .height(56)

      // 分类列表
      CameraModelListView({
        vm: this.vm,
        currentSelectItem: this.localModelItem,
        initIndex: this.currentIndex,
        productList: this.recipeCategoryList,
        tabBarScroller: new Scroller(),
        subBarScroller: new Scroller(),
        layoutType: LayoutType.GRID,
        themeColor: this.themeColor,
        scroller: new Scroller(),
        onTabClick: (tabItem: ModelItemInfo) => {

        },
        onItemClick: (itemContent: string, cameraType: string) => {
          // 待实现，跳转详情页
          this.localModelItem = `${itemContent}-${cameraType}`
        },
      }).layoutWeight(1)

      Row() {
        Text('确定')
          .height(40)
          .layoutWeight(1)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .borderRadius(20)
          .fontColor('rgba(255, 255, 255, 1)')
          .backgroundColor('rgba(255, 75, 75, 1)')
          .margin({
            left: 28,
            top: 16,
            right: 28,
            bottom: 28
          })
          .onClick(() => {
            this.vm.cameraModelSelected = this.localModelItem
            this.vm.showBottomWindow = false
          })
      }.width('100%').height(84).backgroundColor(Color.White)
    }
    .backgroundColor(Color.White)
    .borderRadius({
      topLeft: 32,
      topRight: 32
    })
    .padding({
      bottom: 8
    })
    .width('100%')
  }

  @Local recipeCategoryList: ModelItemInfo[] = MockData.cameraModelCategoryList;
}