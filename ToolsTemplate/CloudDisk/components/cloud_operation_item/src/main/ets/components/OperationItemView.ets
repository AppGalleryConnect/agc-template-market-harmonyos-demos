import { OperationItemModel } from '../model/OperationItemModel';
import { OperationItemViewModel } from '../viewmodel/OperationItemViewModel';

/**
 * @usage: 文件操作项组件：以网格方式展示操作入口（如重命名、删除、移动等）。
 * @layout: GridRow/GridCol 布局，列数根据 originalOperationCount 自适应；可作为底部操作栏或列表项内操作入口。
 * @constraints: 仅依赖本模块模型与视图模型；无循环依赖；点击回调由 ViewModel 统一处理。
 * @isGen: false
 * @domain: 云存储
 * @fileType: component
 * @zhName: 云盘操作项组件-操作栏
 * @subPage:
 * @component:
 */
@ComponentV2
export struct OperationItemView {
  @Param vm: OperationItemViewModel = new OperationItemViewModel()
  @Param bgColor: Color | string | Resource = Color.White

  @Computed
  get checkColomns() {
    // 初始值超过5按4列多行布局
    if (this.vm.originalOperationCount > 5) {
      return 4
    }

    // 按一行布局
    const columns = this.vm.showList.length
    return columns
  }

  build() {
    Column() {
      GridRow({ columns: this.checkColomns }) {
        ForEach(this.vm.showList, (item: OperationItemModel) => {
          GridCol({ span: 1 }) {
            Column() {
              Image(item.iconSource)
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
              Text(item.iconName)
                .margin({ top: 4 })
                .fontSize(10)
            }
            .width('100%')
            .height(48)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.vm.didSelectedItemAction(item.operationType)
            })
          }
          .width('100%')
        }, (item: OperationItemModel, idx: number) => JSON.stringify(item) + idx)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .padding({ bottom: 28, top: 12 })
    .justifyContent(FlexAlign.Center)
  }
}
