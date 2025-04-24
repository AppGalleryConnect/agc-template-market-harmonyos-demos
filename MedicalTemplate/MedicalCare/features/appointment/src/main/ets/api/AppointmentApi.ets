import { RequestMethod } from 'common/src/main/ets/api/BaseApi';
import { DepartmentModel } from '../model/DepartmentModel';
import { AppointmentDateInfoModel, AppointmentInfoModel, DoctorAppointmentModel } from '../model/AppointmentModels';
import { HospitalModel } from '../model/HospitalModel';
import { BaseApi } from 'common';

export interface AppointmentScheduleRequest {
  hospitalId: string
  departmentId?: string
  doctorId?: string
}

export interface AppointmentOrderRequest {
  orderId?: string
  hospitalId?: string
  departmentId?: string
  doctorId?: string
  date?: string
  patientId?: string
}

export class AppointmentApi extends BaseApi {
  constructor() {
    super({
      isMock: true
    })
  }

  /**
   * 获取医院分部列表
   */
  public getHospitalList() {
    return this.sendRequest<HospitalModel[]>('/appointment/hospital', RequestMethod.GET, undefined, false);
  }

  /**
   * 获取医院挂号科室列表
   *
   * @param hospitalId 医院ID
   */
  public getDepartmentList(hospitalId: string) {
    const request: AppointmentScheduleRequest = {
      hospitalId: hospitalId
    };
    return this.sendRequest<DepartmentModel[]>(`/appointment/department`, RequestMethod.GET, request);
  }

  /**
   * 获取挂号医生列表
   *
   * @param hospitalId 医院ID
   */
  public getDoctorList(hospitalId: string) {
    const request: AppointmentScheduleRequest = {
      hospitalId: hospitalId
    };
    return this.sendRequest<DoctorAppointmentModel[]>(`/appointment/doctor`, RequestMethod.GET, request, false);
  }

  /**
   * 获取科室挂号排班信息
   */
  public getDepartmentSchedule(hospitalId: string, departmentId: string) {
    const request: AppointmentScheduleRequest = {
      hospitalId: hospitalId,
      departmentId: departmentId
    };
    return this.sendRequest<AppointmentDateInfoModel[]>(`/appointment/department/schedule`, RequestMethod.GET, request);
  }

  /**
   * 获取医生挂号排班信息
   */
  public getDoctorSchedule(hospitalId: string, doctorId: string, showLoading: boolean = true) {
    const request: AppointmentScheduleRequest = {
      hospitalId: hospitalId,
      doctorId: doctorId
    };
    return this.sendRequest<AppointmentDateInfoModel[]>(`/appointment/doctor/schedule`, RequestMethod.GET, request,
      showLoading);
  }

  /**
   * 提交挂号订单
   */
  public createAppointmentOrder(appointmentInfo: AppointmentInfoModel) {
    const request: AppointmentOrderRequest = {
      orderId: appointmentInfo.orderId,
      hospitalId: appointmentInfo.hospitalInfo.id,
      departmentId: appointmentInfo.departmentInfo.id,
      doctorId: appointmentInfo.doctorInfo.id,
      date: appointmentInfo.datetime,
      patientId: appointmentInfo.patientInfo.cardId,
    };
    return this.sendRequest<AppointmentInfoModel>(`/appointment/order`, RequestMethod.POST, request);
  }

  /**
   * 获取挂号订单列表
   */
  public getAppointmentList(patientId: string, showLoading: boolean = true) {
    const request: AppointmentOrderRequest = {
      patientId: patientId
    };
    return this.sendRequest<AppointmentInfoModel[]>(`/appointment`, RequestMethod.GET, request, showLoading);
  }

  /**
   * 取消挂号订单
   */
  public cancelAppointmentOrder(orderId: string) {
    const request: AppointmentOrderRequest = {
      orderId: orderId
    };
    return this.sendRequest<AppointmentInfoModel>(`/appointment/order`, RequestMethod.DELETE, request);
  }
}