import { BaseViewModel, LogUtil, PreferenceUtil } from 'common';
import { AppointmentApi, OrderState } from 'appointment';
import { formBindingData, formProvider } from '@kit.FormKit';
import { BusinessError } from '@ohos.base';
import { PatientApi } from 'patient';

class FormData {
  hasData: boolean = false
  departmentName?: string = ''
  datetime?: string = ''
  status?: string = ''
}

export class AppointmentStatusWidgetViewModel extends BaseViewModel {
  private appointmentApi: AppointmentApi = new AppointmentApi()
  private patientApi: PatientApi = new PatientApi()

  public constructor() {
    super()
    this.appointmentApi.config.showLoading = false
    this.patientApi.config.showLoading = false
  }

  public async getAppointmentStatusInfo() {
    try {
      let patientId = (await this.patientApi.getDefaultPatient(undefined, false)).cardId
      let appointmentList = await this.appointmentApi.getAppointmentList(patientId, false)
      let latestAppointment = appointmentList[0]
      if (!latestAppointment) {
        return
      }
      this.updateFormData({
        hasData: true,
        departmentName: latestAppointment.departmentInfo.name,
        datetime: latestAppointment.datetime,
        status: OrderState.getOrderStateString(latestAppointment.orderState)
      })
    } catch (e) {
      LogUtil.error(`getAppointmentStatusInfo failed. Cause: ${JSON.stringify(e)}`)
    }
  }

  public getFormIdArray() {
    return PreferenceUtil.getInstance().get(this.getFormPreferenceKey()) as Array<string>
  }

  public createFormData(data: FormData): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(data);
  }

  public updateFormData(data: FormData, formId?: string) {
    if (!this.getFormIdArray()) {
      return
    }

    let formInfo = this.createFormData(data);

    let formIdArray: Array<string> = this.getFormIdArray()
    for (let id of formIdArray) {
      if (formId && id !== formId) {
        continue
      }
      formProvider.updateForm(id, formInfo).then(() => {
        LogUtil.info(`updateForm success. ${JSON.stringify(data)}`)
      }).catch((error: BusinessError) => {
        LogUtil.info(`Operation updateForm failed. Cause: ${JSON.stringify(error)}`);
      })
    }
  }

  private getFormPreferenceKey() {
    return `appointment_status_widget_form_id`
  }
}