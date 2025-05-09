import { AddAddressComp, NavHeaderBar, RouterMap } from 'common'

@Builder
export function AddAddressPageBuilder() {
  AddAddressPage()
}

@ComponentV2
struct AddAddressPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local addressId: number = 0

  aboutToAppear(): void {
    this.getParams()
  }

  getParams() {
    let paramsArr: number[] = this.pageStack?.getParamByName(RouterMap.ADD_ADDRESS_PAGE) as number[];
    if (paramsArr.length) {
      this.addressId = paramsArr[paramsArr.length-1];
    }
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: this.addressId ? $r('app.string.modify_address') : $r('app.string.add_address') })
      AddAddressComp({
        addressId: this.addressId, callback: () => {
          this.pageStack?.pop(null)
        },
      })
    }.hideTitleBar(true)
  }
}