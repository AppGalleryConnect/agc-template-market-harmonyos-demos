import { PatientModel } from '../model/PatientModel';
import { PatientCardView } from '../view/PatientCardView';
import { PatientViewModel } from '../viewmodel/PatientViewModel';
import { CommonNavDestination } from 'common';

@Builder
export function PatientListPageBuilder() {
  CommonNavDestination({ title: '就诊人管理', contentPadding: {} }) {
    PatientListPage()
  }
}

@ComponentV2
export struct PatientListPage {
  @Param patientViewModel: PatientViewModel = PatientViewModel.getInstance()

  aboutToAppear(): void {
    this.patientViewModel.loadPatientList()
  }

  build() {
    List() {
      ForEach(this.patientViewModel.patientList, (item: PatientModel, index) => {
        ListItem() {
          PatientCardView({
            patientName: item.patientName,
            patientCardId: item.cardId,
            picUrl: item.picUrl,
            cardColor: $r('sys.color.ohos_id_color_card_bg'),
            fontColor: $r('sys.color.ohos_id_color_text_primary'),
            onPatientClick: () => {
              this.patientViewModel.onPatientClicked(index)
            }
          })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 16
        })
      }, (item: PatientModel) => JSON.stringify(item))

      ListItem() {
        PatientCardView({
          addMode: true,
          cardColor: $r('sys.color.ohos_id_color_card_bg'),
          fontColor: $r('sys.color.ohos_id_color_text_primary'),
          onPatientClick: () => {
            this.patientViewModel.toPatientAddPage()
          }
        })
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 32
      })

    }
    .width('100%')
    .height('100%')

  }
}
