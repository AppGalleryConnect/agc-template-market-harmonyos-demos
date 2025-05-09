import { AppRouter, BaseTabBarItem,
  DayFormat,
  getDayLabel,
  LocationType
} from 'common';
import { BaseTabBar, BaseTitle, GlobalDialog } from 'components';
import { FlightApi } from '../api/FlightApi';
import { FlightListResult } from '../model/FlightPageModel';

@Builder
export function flightPageBuilder() {
  FlightPage()
}

@ComponentV2
export struct FlightPage {
  private textInputController: TextInputController = new TextInputController()
  @Local departureCity: string = ''
  @Local destinationCity: string = ''
  @Local departureDate: Date = new Date()
  @Local weekDay: string = getDayLabel(new Date());
  @Local tabBarList: BaseTabBarItem[] = [
    new BaseTabBarItem('BY_CITY', '按起降地'),
    new BaseTabBarItem('BY_FLIGHT_NUM', '按航班号'),
  ]
  @Local selectedBarIndex: number = 0
  @Local flightNumValue: string = ''

  selectedDepartureDate() {
    let today = new Date();
    let y = today.getFullYear();
    let startDate = new Date(`${y}-1-1`);
    let endY = y + 1
    let endDate = new Date(`${endY}-12-31`)
    this.getUIContext().showDatePickerDialog({
      start: startDate,
      end: endDate,
      selected: this.departureDate,
      onDateAccept: (value: Date) => {
        this.departureDate = value
        this.weekDay = getDayLabel(value)
      },
    })
  }

  searchFlight() {
    // 按起降地查询
    if (this.selectedBarIndex === 0) {
      if (this.departureCity === '') {
        GlobalDialog.showToast('请选择出发地')
        return
      }
      if (this.destinationCity === '') {
        GlobalDialog.showToast('请选择目的地')
        return
      }
      if (this.departureCity === this.destinationCity) {
        GlobalDialog.showToast('出发地和目的地不能相同')
        return
      }

      let paramData: Record<string, string|Date> = {
        'departureCity': this.departureCity,
        'destinationCity': this.destinationCity,
        'departureDate': this.departureDate
      }
      AppRouter.push({
        url: 'FlightSearchListPage',
        param: paramData
      })
    } else {
      // 按航班号查询
      if (this.flightNumValue === '') {
        GlobalDialog.showToast('请输入航班号')
        return
      }
      // 退出输入框的编辑状态
      this.textInputController.stopEditing()
      GlobalDialog.showLoadingDialog();
      FlightApi.getFlightDetail(this.flightNumValue).then((res) => {
        GlobalDialog.close()
        let result = res.result as FlightListResult;
        if (result.ret.code === 0) {
          if (result.result?.length) {
            if (result.result.length > 1) {
              AppRouter.push({
                url: 'FlightNumListPage',
                param: result.result
              })
            } else {
              AppRouter.push({
                url: 'FlightTrackInfoPage',
                param: result.result[0]
              })
            }
          } else {
            GlobalDialog.showToast('没有找到符合条件的航班')
          }
        } else {
          GlobalDialog.showToast('没有找到符合条件的航班')
        }
      }).catch(() => {
        GlobalDialog.close()
        GlobalDialog.showToast('没有找到符合条件的航班')
      })
    }
  }

  build() {
    Column() {
      BaseTitle({
        customTitle: () => {
          this.FlightTitleBuilder()
        }
      })

      Scroll() {
        Column({ space: 14 }) {
          BaseTabBar({
            tabBarList: this.tabBarList,
            currentIndex: this.selectedBarIndex!!
          })

          Column({space: 24}) {
            if (this.tabBarList[this.selectedBarIndex].type === 'BY_CITY') {
              this.SearchFlightByCityView()
            } else {
              this.SearchFlightByFlightNumView()
            }
            // 选择出发日期
            this.SelectedDateView()
            // 搜索按钮
            this.SearchBtnView()
          }
          .width('100%')
          .padding({ left: 14, right: 14 })
        }
        .backgroundColor($r('sys.color.white'))
        .borderRadius(16)
        .margin(16)
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .linearGradient(
      {
        angle: 180,
        colors: [ [ 'rgba(194,207,255,1)', 0.1 ], [ 'rgba(241,243,245,1)', 0.4 ] ]
      })
    .expandSafeArea([ SafeAreaType.SYSTEM ], [ SafeAreaEdge.TOP ])
  }

  @Builder
  SearchFlightByCityView() {
    Row() {
      Column({ space: 4 }) {
        Text('出发城市')
          .fontSize(12)
          .fontColor('#99000000')
          .fontWeight(FontWeight.Regular)
        Text(this.departureCity || '请选择')
          .fontColor(this.departureCity ? $r('sys.color.ohos_id_color_text_primary') : '#99000000')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .width('40%')
      .justifyContent(FlexAlign.Center)
      .height(64)
      .padding({left: 8, right:8})
      .backgroundColor('#F3F3F3')
      .borderRadius(14)
      .onClick(() => {
        let paramData: Record<string, LocationType | boolean> = {
          'type': LocationType.DEPARTURE,
          'isFlightSearch': true
        }
        AppRouter.navStack.pushPathByName('CitySelectionPage', paramData, (popInfo) => {
          this.departureCity = popInfo.result as string || ''
        })
      })

      Image($r('app.media.ic_transfer')).width(36).height(36)
        .onClick(() => {
          if (this.departureCity && this.destinationCity) {
            let temp = this.departureCity
            this.departureCity = this.destinationCity
            this.destinationCity = temp
          }
        });

      Column({ space: 4 }) {
        Text('到达城市')
          .fontSize(12)
          .fontColor('#99000000')
          .fontWeight(FontWeight.Regular)
        Text(this.destinationCity || '请选择')
          .fontColor(this.departureCity ? $r('sys.color.ohos_id_color_text_primary') : '#99000000')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .width('40%')
      .justifyContent(FlexAlign.Center)
      .height(64)
      .padding({left: 8, right:8})
      .backgroundColor('#F3F3F3')
      .borderRadius(16)
      .onClick(() => {
        let paramData: Record<string, LocationType | boolean> = {
          'type': LocationType.DESTINATION,
          'isFlightSearch': true
        }
        AppRouter.navStack.pushPathByName('CitySelectionPage', paramData, (popInfo) => {
          this.destinationCity = popInfo.result as string || ''
        })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  SearchFlightByFlightNumView() {
    Column({space: 10}) {
      Text('航班号').fontSize(16).fontWeight(FontWeight.Medium)

      TextInput({ placeholder: '请输入航班号，例如CA1516', text: this.flightNumValue, controller: this.textInputController  })
        .width('100%')
        .backgroundColor('#F3F3F3')
        .padding({left: 18, top:14, bottom: 14, right: 14 })
        .borderRadius(16)
        .maxLength(7)
        .placeholderFont({ size: 14, weight: FontWeight.Regular })
        .placeholderColor('#66000000')
        .onChange((value: string) => {
          this.flightNumValue = value.toLocaleUpperCase()
        })
        .inputFilter('[0-9a-zA-Z]', (e) => {
        })
        .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
          // 调用keepEditableState方法，输入框保持编辑态
          event.keepEditableState();
        })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SelectedDateView() {
    Column({space: 10}) {
      Text('出发日期').fontSize(16).fontWeight(FontWeight.Medium)

      Row({ space: 6 }) {
        Text(new DayFormat(this.departureDate).format('YYYY年MM月DD日'))
          .fontSize(14).fontWeight(FontWeight.Medium)
        Text(this.weekDay).fontWeight(FontWeight.Medium).fontSize(14)
      }
      .width('100%')
      .backgroundColor('#F3F3F3')
      .padding({left: 18, top:14, bottom: 14})
      .borderRadius(16)
      .onClick(() => {
        this.selectedDepartureDate()
      })
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SearchBtnView() {
    Row() {
      Button('航班查询', { type: ButtonType.Capsule, stateEffect: true })
        .backgroundColor($r('sys.color.ohos_id_color_emphasize')).width('100%')
        .shadow(ShadowStyle.OUTER_DEFAULT_SM)
    }
    .width('100%')
    .margin({ bottom: 24 })
    .onClick(() => {
      this.searchFlight()
    })
  }

  @Builder
  FlightTitleBuilder() {
    Text('航班动态')
      .fontSize($r('app.float.title_lg_font_size'))
      .fontWeight(FontWeight.Bold)
  }
}
