import { LinkCategory } from 'link_category';
import { promptAction } from '@kit.ArkUI';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

@ComponentV2
export struct CommonFilterDialog {
  @Require @Param vm: CommonPageVM
  @Local localFilterSelected: Map<string, string> = new Map<string, string>()

  aboutToAppear(): void {
    this.localFilterSelected = this.vm.filterSelected
  }

  build() {
    Column() {
      // 标题部分
      RelativeContainer() {
        Text('全部筛选').fontSize(20).fontColor('rgba(0, 0, 0, 0.85)').fontWeight(FontWeight.Medium)
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })

        Image($r('app.media.ic_close')).width(16).height(16).margin({ right: 20 })
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            end: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .onClick(() => {
            this.vm.showBottomWindow = false
          })
      }
      .width('100%')
      .height(56)

      // 选择区域
      LinkCategory({
        recipeCategoryList: this.vm.recipeCategoryList,
        currentIndex: this.vm.currentFilterIndex,
        selectedItems: this.localFilterSelected,
        onRecipeClick: (listItem, categoryName) => {
          if (this.localFilterSelected.has(categoryName)) {
            if (this.localFilterSelected.get(categoryName) === listItem.title) {
              this.localFilterSelected.delete(categoryName)
            } else {
              this.localFilterSelected.set(categoryName, listItem.title)
              promptAction.showToast({
                message: `已选择: ${listItem.title}`,
                duration: 1000
              })
            }
          } else {
            this.localFilterSelected.set(categoryName, listItem.title)
            promptAction.showToast({
              message: `已选择: ${listItem.title}`,
              duration: 1000
            })
          }

          let mapStr: string = ''
          this.localFilterSelected.forEach((value, key) => {
            mapStr += `${key}_${value}, `
          })
        },
        changeCurrentIndex: (index: number) => {
          // 点击分类标签切换index事件
          this.vm.currentFilterIndex = index
        },
      })
        .layoutWeight(1)

      Row() {
        Text('重置')
          .height(40)
          .layoutWeight(1)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .border({
            width: 1,
            color: 'rgba(0, 0, 0, 0.2)',
            radius: 20
          })
          .backgroundColor('rgba(255, 255, 255, 1)')
          .margin({
            left: 16,
            top: 16,
            bottom: 28
          })
          .onClick(() => {
            this.localFilterSelected.clear()
          })

        Text('确定')
          .height(40)
          .layoutWeight(1)
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 1)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .borderRadius(20)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .margin({
            left: 8,
            right: 16,
            top: 16,
            bottom: 28
          })
          .onClick(() => {
            this.vm.filterSelected = this.localFilterSelected
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
}