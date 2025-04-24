import { ShowCardView, LocationVM ,ShopCardModel} from '@ohos_agcit/car_beauty_care_shop'
import { AppointmentTimePicker } from './AppointmentTimePicker'
import { AppointmentVM } from '../mode/AppointmentVM'

@ComponentV2
export struct AppointmentCard {
  locationVM: LocationVM = LocationVM.instance;
  appointmentVM: AppointmentVM = AppointmentVM.instance;
  @Param card:ShopCardModel = this.locationVM.shopCardList[0];
  @Local selected: boolean = false;
  build() {
    Column() {
      Row() {
        Radio({ value: 'Radio1', group: 'radioGroup' })
          .checked(this.selected)
          .radioStyle({
            checkedBackgroundColor:$r('app.color.lightRed')
          })
          .margin({
            right:14
          })
          .onChange((value:boolean) => {
            this.selected = value;
            this.appointmentVM.setShowSubmitBtn(false)
          })

        ShowCardView({
          card:this.card,
          showMark: false,
          imgRect: 72,
          showLine: true
        })
          .layoutWeight(1)
      }

      if (this.selected) {
        Row() {
          AppointmentTimePicker({card: this.card})
        }
      }
    }
  }
}