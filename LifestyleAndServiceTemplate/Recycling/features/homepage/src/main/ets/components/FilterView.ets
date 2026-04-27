import { Drawer, DrawerController, ResultItem } from 'module_filter_list'
import { FilterItem } from '../viewmodel/MainPageVM'
import { PriceSelectDialog } from './PriceSelectDialog'
import { PriceSortingDialog } from './PriceSortingDialog'
import { CommonFilterDialog } from './CommonFilterDialog'
import { PhoneModelDialog } from './PhoneModelDialog'
import { CameraModelDialog } from './CameraModelDialog'
import { CommonPageVM } from '../viewmodel/CommonPageVM'
import { MockData } from '../data/MockData'

/**
 * @usage: 筛选视图组件，提供价格排序、价格区间、型号选择、通用筛选等多种筛选功能。支持抽屉式展开筛选面板。
 * @layout: 采用垂直布局（Column），顶部为筛选条件栏（横向排列），下方为抽屉式筛选面板和列表内容区域。
 * @constraints: 需要传入 CommonPageVM 类型的视图模型，modelIndex 控制不同品类的筛选列表。
 * @isGen: true
 * @fileType: component
 * @zhName: 筛选视图组件
 * @component: PriceSelectDialog,PriceSortingDialog,CommonFilterDialog,PhoneModelDialog,CameraModelDialog
 * @image: screenshots/homepage/filterView.png
 */

@ComponentV2
export struct FilterView {
  @Require @Param vm: CommonPageVM
  @Local selectedIndex: number = -1
  controller: DrawerController = new DrawerController();
  @Local isDrawOpen: boolean = false;
  @Local selectResult: ResultItem[] = [];
  @Event onchange: (res: ResultItem[]) => void = () => {
  };
  @Event onDrawChange: (res: boolean) => void = () => {
  }
  @BuilderParam listBuilderParam: () => void = this.lisBuilder;
  // 控制头部筛选条件栏是否固定
  @Param isFixed: boolean = false;
  // 增加上边距
  @Param topMargin: number = 0;
  // 型号下标
  @Param modelIndex: number = 1;

  aboutToAppear(): void {
    if (this.modelIndex === 1) {
      // 返回手机分类列表
      this.vm.productList = MockData.phoneProductList
    } else if (this.modelIndex === 2) {
      // 返回平板分类列表
      this.vm.productList = MockData.padProductList
    } else if (this.modelIndex === 3) {
      // 返回笔记本分类列表
      this.vm.productList = MockData.notebookProductList
    } else if (this.modelIndex === 4) {
      // 返回家电分类列表
      this.vm.productList = MockData.watchProductList
    } else if (this.modelIndex === 5) {
      // 返回智能穿戴
      this.vm.productList = MockData.iWatchProductList
    } else if (this.modelIndex === 6) {
      // 返回相机分类列表
      this.vm.productList = MockData.cameraProductList
    } else if (this.modelIndex === 7) {
      // 获取无人机分类列表
      this.vm.productList = MockData.noPersonProductList
    }
    // 初始化展开状态
    this.isDrawOpen = this.vm.isExpanded
  }

  @Builder
  lisBuilder() {

  }

  @Monitor('vm.showBottomWindow')
  changeOpenDialogStatus() {
    if (!this.vm.showBottomWindow) {
      this.controller.close();
      this.selectedIndex = -1;
    }
  }

  // 获取当前的字体颜色
  getTextColor(item: FilterItem) {
    let isSelected: boolean = (item.index === this.selectedIndex && this.isDrawOpen)
    // 如果是排序筛选
    if (item.index === 0) {
      isSelected = isSelected || (this.vm.priceSortingSelected !== '综合')
    }
    // 如果是价格筛选
    if (item.index === 1) {
      isSelected = isSelected || (this.vm.priceSelected[0] !== 0 || this.vm.priceSelected[1] !== 100000)
    }
    // 如果是型号筛选
    if (item.index === 2) {
      if (this.modelIndex !== 6) {
        isSelected = isSelected || (this.vm.modelSelected !== '不限型号')
      } else {
        isSelected = isSelected || (this.vm.cameraModelSelected.indexOf('不限型号') < 0)
      }
    }
    // 如果是通用筛选
    if (item.index === 3) {
      const temp: boolean = (this.vm.filterSelected.size === 1 && this.vm.filterSelected.has('品牌型号')) ||
        (this.vm.filterSelected.size === 0)
      isSelected = isSelected || !temp
    }
    return isSelected ? item.selectedTextColor : item.unselectedTextColor
  }

  // 获取图标
  getIcon(item: FilterItem) {
    let isSelected: boolean = false
    if (item.index === 0) {
      isSelected = this.vm.priceSortingSelected !== '综合'
    }
    // 如果是价格筛选
    if (item.index === 1) {
      isSelected = this.vm.priceSelected[0] !== 0 || this.vm.priceSelected[1] !== 100000
    }
    // 如果是型号筛选
    if (item.index === 2) {
      if (this.modelIndex !== 6) {
        isSelected = this.vm.modelSelected !== '不限型号'
      } else {
        isSelected = this.vm.cameraModelSelected.indexOf('不限型号') < 0
      }
    }
    // 如果是通用筛选
    if (item.index === 3) {
      const temp: boolean = (this.vm.filterSelected.size === 1 && this.vm.filterSelected.has('品牌型号')) ||
        (this.vm.filterSelected.size === 0)
      isSelected = !temp
    }
    return item.index === this.selectedIndex && this.isDrawOpen ? item.selectedIcon :
      isSelected ? item.existSelectedIcon : item.unselectedIcon
  }

  @Builder
  buildBody() {
    Column() {
      Row() {
        Row() {
          ForEach(this.vm.filterList, (item: FilterItem, index: number) => {
            Row() {
              Text(index === 0 ? this.vm.priceSortingSelected : item.name)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getTextColor(item))
                .height(16)
                .textAlign(TextAlign.Center)

              Image(this.getIcon(item))
                .width(24)
                .height(24)

            }
            .layoutWeight(1)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              if (this.isDrawOpen && this.selectedIndex === item.index) {
                this.controller.close();
                this.selectedIndex = -1;
              } else {
                this.selectedIndex = item.index;
                this.controller.open();
              }
              this.vm.popupWindowStyle = item.name
              // 点击显示上拉框
              if (item.name === '筛选' || item.name === '型号') {
                this.vm.showBottomWindow = true
              }
            })

          }, (item: FilterItem, index: number) => JSON.stringify(item) + index)
        }
        .layoutWeight(1)
        .height(44)
        .padding({
          left: 16,
          right: 16
        })
        .bindSheet($$this.vm.showBottomWindow, this.dealWithFileSheet(),
          {
            showClose: false,
            height: this.getSheetHeight(),
            enableOutsideInteractive: false,
            radius: {
              topLeft: 32,
              topRight: 32
            },
            preferType: SheetType.BOTTOM,
          })

      }
      .width('100%')

      Drawer({
        controller: this.controller,
        onDrawChange: (res) => {
          this.isDrawOpen = res;
          this.vm.isExpanded = res;
          this.onDrawChange(res);
        },
      }) {
        if (this.vm.popupWindowStyle === '价格降序') {
          PriceSortingDialog({
            priceSorting: this.vm.priceSortingSelected,
            priceSortingArray: this.vm.filterList[0].selectArr,
            priceSortingResult: (index: number) => {
              this.vm.priceSortingSelected = this.vm.filterList[0].selectArr[index]
              this.selectResult = this.vm.filterList[0].selectArr.map((item: string, index: number) => {
                const obj: ResultItem = {
                  filterName: item,
                  selectIndex: index,
                };
                return obj;
              });
              this.onchange(this.selectResult);
              this.controller.close();
            }
          })
        } else if (this.vm.popupWindowStyle === '价格') {
          PriceSelectDialog({
            priceArray: this.vm.filterList[1].selectArr,
            price: this.vm.priceSelected,
            vm: this.vm,
            priceResult: (arr: string[]) => {
              this.vm.priceSelected = this.getPriceArray(arr)
              this.selectResult = this.vm.filterList[1].selectArr.map((item: string, index: number) => {
                const obj: ResultItem = {
                  filterName: item,
                  selectIndex: index,
                };
                return obj;
              });
              this.onchange(this.selectResult);
              this.controller.close();
            }
          })
        }

      };

      this.listBuilderParam();
    }
    .width('100%')
    .layoutWeight(this.isFixed ? 1 : 0)
    .margin({ top: this.isFixed ? 0 : this.topMargin })

  }

  // 获取价格区间的数组
  getPriceArray(array: string[]): number[] {
    if (array.length === 2) {
      const min = array[0] === '' ? 0 : parseInt(array[0])
      const max = array[1] === '' ? 100000 : parseInt(array[1])
      return [min, max]
    }
    return [0, 0]
  }

  build() {
    this.buildBody()
  }

  // 绑定上拉新建文件夹操作栏
  @Builder
  dealWithFileSheet() {
    if (this.vm.popupWindowStyle === '型号') {
      if (this.modelIndex !== 6) {
        PhoneModelDialog({
          vm: this.vm
        })
      } else {
        CameraModelDialog({
          vm: this.vm
        })
      }
    } else if (this.vm.popupWindowStyle === '筛选') {
      CommonFilterDialog({
        vm: this.vm
      })
    }
  }

  // 根据选中的筛选项，高度
  getSheetHeight(): number {
    if (this.vm.popupWindowStyle === '型号') {
      return 616
    } else if (this.vm.popupWindowStyle === '筛选') {
      return 616
    }
    return 0
  }
}