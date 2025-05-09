import { PassengerApi, PassengerInfo, PassengerListResult, CommonFuncResult,
  maskPhone,
  maskCertificate,
  CardMap,
  AppRouter} from 'common'
import { BaseTitle, GlobalDialog } from 'components'
import { AddPassengerView } from '../components/AddPassengerView'

@Builder
export function passengerListPageBuilder() {
  PassengerListPage()
}

@ComponentV2
export struct PassengerListPage {
  // 乘机人列表信息
  @Local passengerList: PassengerInfo[] = []

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
          resList.push(resItem)
        }
        this.passengerList = resList
      }
    }).finally(() =>{
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
    PassengerApi.deletePassenger(paramData).then((res) => {
      let result = res.result as CommonFuncResult
      if (result.ret.code === 0 && result.result === 1) {
        this.passengerList.splice(index, 1)
      }
    })
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        BaseTitle({
          title: '乘机人管理',
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
              this.PassengerItem(item)
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
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.color_page_bg'))
    .onWillShow(() =>{
      // 获取乘机人列表
      this.getPassengerList()
    })
  }

  @Builder
  PassengerItem(item: PassengerInfo) {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Text(item.name).fontWeight(600)

        Row({ space: 4 }) {
          Text(CardMap[item.certificateType]).fontSize(12).fontColor('#999')
          Text(maskCertificate(item.certificateNo, item.certificateType)).fontSize(12).fontColor('#999')
        }

        Row({ space: 4 }) {
          Text('手机号').fontSize(12).fontColor('#999')
          Text('+86-' + maskPhone(item.phone)).fontSize(12).fontColor('#999')
        }
      }
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.ic_edit')).width(26).height(26)
        .onClick(() => {
          AppRouter.push({
            url: 'AddPassengerPage',
            param: item
          })
        })
    }
    .width('100%')
    .padding(14)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
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
