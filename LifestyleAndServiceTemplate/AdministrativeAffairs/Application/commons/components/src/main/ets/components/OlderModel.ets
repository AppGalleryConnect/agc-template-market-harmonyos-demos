import { BaseStyleData, Constants, GridBanner, HomeServiceList, HotService } from 'common'
import { ConvenientService } from './ConvenientService'
import { HotServiceCard } from './HotServiceCard'
import { MedicalPersonCardInfo } from './MedicalPersonCardInfo'

@ComponentV2
export struct OlderModel {
  @Param title: string = ''
  @Consumer('baseStyleData') baseStyleData: BaseStyleData = new BaseStyleData()
  @Local hotServices: HotService[] = [];
  @Local serviceList: GridBanner[] = [];
  @Local isOlder: boolean = true

  setOlderModel() {

  }

  aboutToDisappear(): void {
    this.isOlder = !this.isOlder
  }

  aboutToAppear(): void {
    this.setOlderModel()
    if (AppStorage.get('homeServiceList')) {
      this.hotServices =
        JSON.parse(JSON.stringify((AppStorage.get('homeServiceList') as HomeServiceList).hotServices ?? []))
      this.serviceList =
        JSON.parse(JSON.stringify((AppStorage.get('homeServiceList') as HomeServiceList).convenienceService ?? []))
      /*
       * mock添加医保项
       * */
      this.hotServices.unshift({
        serviceId: 'code',
        icon: $r('app.media.older_code'),
        olderPic: $r('app.media.code_bg'),
        name: $r('app.string.medical_insurance_code'),
      })
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          MedicalPersonCardInfo({
            isOlder: this.isOlder,
          })
          HotServiceCard({
            hotServices: this.hotServices,
            isOlder: this.isOlder,
          })
          ConvenientService({
            serviceList: this.serviceList,
            isOlder: this.isOlder,
          })
        }
      }
      .height(Constants.FULL_PERCENT_HEIGHT)
      .scrollBar(BarState.Off)
    }
    .padding({
      top: Number(AppStorage.get('topRectHeight')),
    })
    .title(this.title)
    .linearGradient({
      angle: 180,
      colors: [
        ['#1B58FF', 0.0],
        ['#F1F3F5', 0.4],
        ['#F1F3F5', 1.0],
      ],
    })
  }
}