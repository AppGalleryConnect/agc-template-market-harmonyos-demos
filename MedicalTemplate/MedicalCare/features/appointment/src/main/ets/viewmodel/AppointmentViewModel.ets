import { BaseViewModel, DataUtil, LogUtil, MapParam, RouterUtil, ToastUtil } from 'common';
import { AppointmentApi } from '../api/AppointmentApi';
import { DepartmentModel } from '../model/DepartmentModel';
import { AppointmentDateInfoModel, AppointmentInfoModel, DoctorAppointmentModel } from '../model/AppointmentModels';
import { HospitalModel } from '../model/HospitalModel';
import { JSON } from '@kit.ArkTS';
import { PatientApi, PatientModel } from 'patient';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { OrderState } from '../constant/Constant';

@ObservedV2
export class AppointmentViewModel extends BaseViewModel {
  private static instance: AppointmentViewModel
  @Trace hospitalList: HospitalModel[] = [] // 医院列表
  @Trace departmentList: DepartmentModel[] = [] // 科室列表
  @Trace doctorList: DoctorAppointmentModel[] = [] // 医生列表
  @Trace patientList: PatientModel[] = [] // 就诊人列表
  @Trace departmentScheduleList: AppointmentDateInfoModel[] = [] // 科室挂号排班列表
  @Trace doctorScheduleList: AppointmentDateInfoModel[] = [] // 医生挂号排班列表
  @Trace appointmentInfoModel: AppointmentInfoModel = new AppointmentInfoModel() // 用于保存当前挂号信息
  @Trace appointmentOrderList: AppointmentInfoModel[] = []
  @Trace isHospitalListLoading: boolean = false
  @Trace isAppointmentOrderListLoading: boolean = false
  private appointmentApi: AppointmentApi = new AppointmentApi()
  private patientApi: PatientApi = new PatientApi()
  private currentOrderIndex: number | undefined = undefined

  public constructor() {
    super()
    this.appointmentApi.config.onLoadingCallback = this.getLoadingCallback()
  }

  public static getInstance(newInstance: boolean = false) {
    if (!AppointmentViewModel.instance || newInstance) {
      AppointmentViewModel.instance = new AppointmentViewModel()
    }

    return AppointmentViewModel.instance
  }

  public initOrderData() {
    // 从外部进入订单详情页
    let param = RouterUtil.getLatestParam()
    if (param) {
      this.initAppointmentOrder(param as AppointmentInfoModel)
    } else if (this.currentOrderIndex !== undefined) { // 从订单列表进入订单详情页
      this.initAppointmentOrder(this.appointmentOrderList[this.currentOrderIndex])
    } else { // 从挂号预约进入订单详情页
      this.requestPayment()
    }
  }

  public async loadHospitalList() {
    this.isHospitalListLoading = true
    this.loadPatientInfo(false)
    this.hospitalList = await this.appointmentApi.getHospitalList().finally(() => {
      this.isHospitalListLoading = false
    })
  }

  public loadDepartmentList() {
    this.appointmentApi.getDepartmentList(this.appointmentInfoModel.hospitalInfo.id).then((data) => {
      LogUtil.info(`Department list: ${JSON.stringify(data)}`)
      this.departmentList = data
    })
  }

  public loadDoctorList() {
    this.appointmentApi.getDoctorList(this.appointmentInfoModel.hospitalInfo.id).then((data) => {
      this.doctorList = data
    })
  }

  public loadDepartmentSchedule() {
    this.appointmentApi.getDepartmentSchedule(this.appointmentInfoModel.hospitalInfo.id,
      this.appointmentInfoModel.departmentInfo.id).then((data) => {
      this.departmentScheduleList = data
    })
  }

  public loadDoctorSchedule() {
    this.appointmentApi.getDoctorSchedule(
      this.appointmentInfoModel.hospitalInfo.id,
      this.appointmentInfoModel.doctorInfo.id,
      false
    )
      .then((data) => {
        this.doctorScheduleList = data
      })
  }

  public async loadPatientInfo(showLoading: boolean = true) {
    this.patientApi.config.showLoading = showLoading
    try {
      // 获取默认就诊人信息
      const defaultPatient = await this.patientApi.getDefaultPatient((patient) => {
        this.appointmentInfoModel.patientInfo = patient;
      })
      // 设置预约信息中的就诊人信息
      this.appointmentInfoModel.patientInfo = defaultPatient;
      // 获取就诊人列表
      this.patientList = await this.patientApi.getPatientList((data) => {
        this.patientList = data
      });
    } catch (error) {
      ToastUtil.showToast(`获取默认就诊人信息失败，请先设置默认就诊人`);
      RouterUtil.back()
    }
  }

  public createAppointmentOrder() {
    this.appointmentApi.createAppointmentOrder(this.appointmentInfoModel).then((data) => {
      this.appointmentInfoModel.orderId = data.orderId
      this.appointmentInfoModel.orderStr = data.orderStr
      this.appointmentInfoModel.hospitalInfo.address = data.hospitalInfo.address
      this.appointmentInfoModel.orderState = OrderState.ORDER_STATE_NEED_PAYMENT
      this.toPage('AppointmentOrderPage')
    })
  }

  public requestPayment() {
    if (!this.needPayment()) {
      return
    }
    this.appointmentInfoModel.orderState = OrderState.ORDER_STATE_NEED_PAYMENT
    this.appointmentInfoModel.paymentMessage = '支付中'
    paymentService?.requestPayment(getContext() as common.UIAbilityContext, this.appointmentInfoModel.orderStr)
      .then(() => {
        ToastUtil.showToast('支付成功')
        this.appointmentInfoModel.orderState = OrderState.ORDER_STATE_SUCCESS
      })
      .catch((error: object) => {
        LogUtil.info(`Payment failed. Cause: ${JSON.stringify(error)}`)
        this.appointmentInfoModel.orderState = OrderState.ORDER_STATE_NEED_PAYMENT
      })
      .finally(() => {
        this.appointmentInfoModel.paymentMessage = this.getOrderStateMessage()
        if (this.currentOrderIndex !== undefined) {
          DataUtil.replaceListItem(this.appointmentOrderList, this.currentOrderIndex, this.appointmentInfoModel)
        }
      })
  }

  public initAppointmentOrder(appointmentModel: AppointmentInfoModel) {
    this.appointmentInfoModel = DataUtil.copyObject(new AppointmentInfoModel(), appointmentModel)
    this.appointmentInfoModel.paymentMessage = this.getOrderStateMessage()
  }

  public async loadDefaultAppointmentOrderList() {
    this.isLoading = true
    this.isAppointmentOrderListLoading = true
    await this.loadPatientInfo(false)
    await this.loadAppointmentOrderList(this.appointmentInfoModel.patientInfo.cardId)
      .finally(() => {
        this.isLoading = false
        this.isAppointmentOrderListLoading = false
      })
  }

  public async loadAppointmentOrderList(patientId: string) {
    this.isAppointmentOrderListLoading = true
    return this.appointmentApi.getAppointmentList(patientId, false).then(data => {
      this.appointmentOrderList = data
      this.isAppointmentOrderListLoading = false
    })
  }

  public cancelOrder(index: number, orderId: string) {
    this.appointmentApi.cancelAppointmentOrder(orderId).then(() => {
      ToastUtil.showToast('取消成功')
      this.appointmentOrderList[index].orderState = OrderState.ORDER_STATE_CANCELED
      DataUtil.replaceListItem(this.appointmentOrderList, index, this.appointmentOrderList[index])
    })
  }

  public selectHospital(hospital: HospitalModel) {
    this.appointmentInfoModel.hospitalInfo = hospital
    this.departmentList = []
    this.doctorList = []
    this.toPage('AppointmentMainPage')
  }

  public selectDepartment(department: DepartmentModel) {
    this.appointmentInfoModel.departmentInfo = department
    this.departmentScheduleList = []
    this.toPage('DepartmentAppointmentPage')
  }

  public setSelectedDoctor(doctor: DoctorAppointmentModel) {
    this.appointmentInfoModel.doctorInfo = doctor
  }

  public setSelectedPatient(index: number) {
    this.appointmentInfoModel.patientInfo = this.patientList[index]
  }

  public selectDoctor(doctor: DoctorAppointmentModel) {
    this.appointmentInfoModel.doctorInfo = doctor
    this.appointmentInfoModel.departmentInfo.id = doctor.departmentId
    this.appointmentInfoModel.departmentInfo.name = doctor.departmentName
    this.doctorScheduleList = []
    this.toPage('DoctorInfoPage')
  }

  public selectDate(year: string, month: string, day: string, time: string) {
    this.appointmentInfoModel.datetime = `${year}-${month}-${day} ${time}`
    this.toPage('AppointmentInfoConfirmPage')
  }

  public selectHospitalPosition(index: number) {
    this.toPage('MapPage', {
      latitude: this.hospitalList[index].latitude,
      longitude: this.hospitalList[index].longitude
    } as MapParam)
  }

  public getSearchDepartmentList(searchText: string) {
    let searchResult: DepartmentModel[] = []
    for (let parentDepartment of this.departmentList) {
      for (let childDepartment of parentDepartment.children) {
        if (childDepartment.name.includes(searchText)) {
          searchResult.push(childDepartment)
          continue
        }

        for (let grandChildDepartment of childDepartment.children) {
          if (grandChildDepartment.name.includes(searchText)) {
            searchResult.push(childDepartment)
          }
        }
      }
    }

    return searchResult
  }

  public getDoctorNameAndTitleString() {
    if (this.appointmentInfoModel.doctorInfo.name === '普通号') {
      return `${this.appointmentInfoModel.doctorInfo.name}`
    } else {
      return `${this.appointmentInfoModel.doctorInfo.name}-${this.appointmentInfoModel.doctorInfo.title}`
    }
  }

  public toOrderDetail(index: number) {
    this.currentOrderIndex = index
    this.toPage('AppointmentOrderPage')
  }

  public shouldAllowCancelAppointment(orderState: number) {
    let enableStatus =
      [OrderState.ORDER_STATE_SUCCESS, OrderState.ORDER_STATE_NEED_PAYMENT]
    return enableStatus.includes(orderState)
  }

  public shouldShowPaymentButton() {
    let enableStatus = [OrderState.ORDER_STATE_NEED_PAYMENT]
    return enableStatus.includes(this.appointmentInfoModel.orderState)
  }

  private getOrderStateMessage(): string {
    return OrderState.getOrderStateString(this.appointmentInfoModel.orderState)
  }

  private needPayment(): boolean {
    let needPaymentStatus = [OrderState.ORDER_STATE_NEED_PAYMENT]
    return needPaymentStatus.includes(this.appointmentInfoModel.orderState)
  }
}