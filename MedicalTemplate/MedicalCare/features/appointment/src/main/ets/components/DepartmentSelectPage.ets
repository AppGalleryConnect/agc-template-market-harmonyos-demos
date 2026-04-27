import { DepartmentModel } from '../model/DepartmentModel'
import { CollapseListView } from '../view/CollapseListView'
import { SearchBarView } from '../view/SearchBarView'
import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel'

/**
 * 挂号科室选择页面
 */
@ComponentV2
export struct DepartmentSelectPage {
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()
  @Local currentTabIndex: number = 0
  @Local searchText: string | undefined = undefined

  aboutToAppear(): void {
    this.appointmentViewModel.loadDepartmentList()
  }

  build() {
    Column() {
      SearchBarView({
        onSearch: (text) => {
          this.searchText = text
        }
      })
        .margin({ left: 16, right: 16, bottom: 16 })

      Row() {
        List() {
          ForEach(this.appointmentViewModel.departmentList, (item: DepartmentModel, index) => {
            this.departmentTabBarBuilder(item.name, index)
          }, (item: DepartmentModel) => item.id)
        }
        .width(108)
        .height('100%')
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .scrollBar(BarState.Off)

        Stack() {
          this.childDepartmentListBuilder()
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .alignContent(Alignment.TopStart)
      }
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }

  @Builder
  departmentTabBarBuilder(title: string, index: number) {
    Row() {
      Divider()
        .vertical(true)
        .width(4)
        .height(28)
        .backgroundColor($r('sys.color.ohos_id_color_activated'))
        .visibility(index === this.currentTabIndex ? Visibility.Visible : Visibility.Hidden)

      Text(title)
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .layoutWeight(1)
        .margin({
          left: 16,
          right: 16
        })
    }
    .padding({
      top: 7,
      bottom: 7
    })
    .height(48)
    .backgroundColor(
      index === this.currentTabIndex ?
      $r('sys.color.ohos_id_color_background') :
      $r('sys.color.ohos_id_color_sub_background')
    )
    .onClick(() => {
      this.currentTabIndex = index
    })
  }

  @Builder
  childDepartmentListBuilder() {
    if (this.appointmentViewModel.departmentList.length > 0) {
      List() {
        ForEach(this.searchText?.length ? this.appointmentViewModel.getSearchDepartmentList(this.searchText) :
        this.appointmentViewModel.departmentList[this.currentTabIndex].children,
          (item: DepartmentModel | undefined, index) => {
            CollapseListView({
              listTitle: item?.name,
              data: item?.children.map((child) => child.name),
              onItemClick: item ? (index) => {
                this.appointmentViewModel.selectDepartment(item?.children[index])
              } : undefined
            })
          }, (item: DepartmentModel | undefined) => item?.id)
      }
      .width('100%')
      .height('100%')
      .divider({
        strokeWidth: 0.5,
        color: $r('sys.color.ohos_id_color_list_separator')
      })
      .padding({
        left: 16,
        right: 23
      })
    }
  }
}