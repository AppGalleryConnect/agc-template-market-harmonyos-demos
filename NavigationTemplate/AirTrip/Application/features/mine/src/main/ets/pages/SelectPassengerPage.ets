import { PassengerApi, PassengerInfo, PassengerListResult, CommonFuncResult, AppRouter } from 'common'
import { BaseTitle, GlobalDialog } from 'components'
import { AddPassengerView } from '../components/AddPassengerView'
import { PassengerItem } from '../components/PassengerItem'

@Builder
export function selectPassengerPageBuilder() {
  SelectPassengerPage()
}

@ComponentV2
export struct SelectPassengerPage {
  // 乘机人列表信息
  @Local passengerList: PassengerInfo[] = []
  // 选择的乘机人
  @Local selectedPassengers: PassengerInfo[] = []

  getPassengerList() {
    GlobalDialog.showLoadingDialog()
    PassengerApi.getPassengerList().then((res) => {
      let response: PassengerListResult = res.result as PassengerListResult
      if (response.ret.code === 0) {
        let resList: PassengerInfo[] = []
        let data = response.result ?? []
        for (let i = 0; i < data.length; i++) {
          let resItem: PassengerInfo = new PassengerInfo()
          let item = data[i]
          resItem.id = item.id
          resItem.name = item.name
          resItem.certificateType = item.certificateType
          resItem.certificateNo = item.certificateNo
          resItem.phone = item.phone
          let selectedItem = this.selectedPassengers.find((passenger: PassengerInfo) => passenger.id === item.id)
          resItem.isChecked = !!selectedItem
          resList.push(resItem)
        }
        this.passengerList = resList
      }
    }).finally(() => {
      GlobalDialog.close()
    })
  }

  // 删除乘机人
  deletePassenger(item: PassengerInfo, index: number) {
    let paramData = {
      id: item.id,
      name: item.name,
      certificateType: item.certificateType,
      certificateNo: item.certificateNo,
      phone: item.phone,
    } as PassengerInfo
    GlobalDialog.showLoadingDialog()
    PassengerApi.deletePassenger(paramData).then((res) => {
      let result = res.result as CommonFuncResult
      if (result.ret.code === 0 && result.result === 1) {
        this.passengerList.splice(index, 1)
      }
    }).finally(() => {
      GlobalDialog.close()
    })
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        BaseTitle({
          title: '选择乘机人',
          bgColor: $r('sys.color.white'),
          showBackBtn: true,
          onBack: () => {
            AppRouter.pop()
          }
        })

        List({ space: 10 }) {
          ListItem() {
            AddPassengerView()
          }

          ForEach(this.passengerList, (item: PassengerInfo, index: number) => {
            ListItem() {
              PassengerItem({
                data: item,
                edit: () => {
                  AppRouter.push({
                    url: 'AddPassengerPage',
                    param: item
                  })
                },
                changePassenger: (data: PassengerInfo) => {
                  for (let passenger of this.passengerList) {
                    if (data.id === passenger.id) {
                      passenger.isChecked = data.isChecked
                      return
                    }
                  }
                }
              })
            }
            .transition({ type: TransitionType.Delete, opacity: 0 })
            .swipeAction({
              end: this.ItemEnd(item, index)
            })
          })

          // 防止按钮遮挡列表数据
          ListItem() {
            Row(){}.height(50 + px2vp(91))
          }
        }
        .width('100%')
        .height('calc(100% - 46vp)')
        .scrollBar(BarState.Off)
        .padding({ left: 14, right: 14 })

        Column({ space: 10 }) {
          Button('确定', { type: ButtonType.Capsule, stateEffect: true })
            .width('100%')
            .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
            .onClick(() => {
              let selectedPassengers = this.passengerList.filter((passenger: PassengerInfo) => passenger.isChecked)
              if (selectedPassengers.length > 0) {
                AppRouter.navStack.pop({selectedPassengers: selectedPassengers})
              } else {
                GlobalDialog.showToast('请先选择乘机人')
              }
            })
        }
        .width('100%')
        .padding({
          left: 16,
          top: 10,
          right: 16,
          bottom: 10 + px2vp(91)
        })
        .backgroundColor(Color.Transparent)
        .borderRadius(6)
        .position({
          bottom: px2vp(-91),
          left: 0
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor('#fff5f3f3')
    .onReady((cxt) => {
      this.selectedPassengers = cxt.pathInfo.param as PassengerInfo[]
    })
    .onWillShow(() =>{
      // 获取乘机人列表
      this.getPassengerList()
    })
  }

  @Builder
  ItemEnd(item: PassengerInfo, index: number) {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_delete')).fillColor($r('sys.color.ohos_id_color_warning')).width(24).height(24)
      }.width(48).height(48).backgroundColor($r('sys.color.white'))
      .onClick(() => {
        this.deletePassenger(item, index)
      })
    }.padding({left: 8}).justifyContent(FlexAlign.SpaceEvenly)
  }
}
