import { PatientModel } from 'patient'
import { DepartmentModel } from './DepartmentModel'
import { HospitalModel } from './HospitalModel'

@ObservedV2
export class AppointmentScheduleSlotModel {
  @Trace startTime: string = '' // 挂号时间段的开始时间
  @Trace endTime: string = '' // 挂号时间段的结束时间
  @Trace remainingAppointments: number = 0 // 剩余号源数量
}

/**
 * 以日期分组的挂号信息
 */
@ObservedV2
export class AppointmentDateInfoModel {
  @Trace dayOfWeek: string = '' // 星期
  @Trace year: string = ''
  @Trace month: string = ''
  @Trace day: string = ''
  @Trace remainingAppointments: number = 0 // 剩余号源数量
  @Trace availableSlots: AppointmentScheduleSlotModel[] = [] // 挂号时间段信息
  @Trace doctors: DoctorAppointmentModel[] = [] // 挂号医生信息
}

/**
 * 特定医生（或普通号）的挂号信息
 */
@ObservedV2
export class DoctorAppointmentModel {
  @Trace id: string = '' // 医生ID
  @Trace name: string = ''
  @Trace title: string = '' // 医生职称
  @Trace picUrl: string = '' // 医生头像URL
  @Trace appointmentType: string = '' // 挂号类型（普通号/专家号）
  @Trace remainingAppointments: number = 0 // 剩余号源数量
  @Trace price: number = 0 // 挂号价格
  @Trace departmentId: string = '' // 科室ID
  @Trace departmentName: string = '' // 科室名称
  @Trace description: string = '' // 医生简介
  @Trace availableSlots: AppointmentScheduleSlotModel[] = [] // 挂号时间段信息
}

/**
 * 当前挂号信息
 */
@ObservedV2
export class AppointmentInfoModel {
  @Trace orderId: string = '' // 挂号订单ID
  @Trace datetime: string = '' // 挂号时间
  @Trace orderStr: string = '' // 挂号订单OrderStr（用于支付）
  @Trace orderState: number = 0
  @Trace paymentMessage: string = '' // 挂号支付信息
  @Trace hospitalInfo: HospitalModel = new HospitalModel() // 挂号医院信息
  @Trace departmentInfo: DepartmentModel = new DepartmentModel() // 挂号科室信息
  @Trace doctorInfo: DoctorAppointmentModel = new DoctorAppointmentModel() // 挂号医生信息
  @Trace patientInfo: PatientModel = new PatientModel() // 挂号患者信息

  constructor() {
    this.orderId = `${Date.now()}`
  }
}