import { BaseApi, RequestMethod } from 'common';
import { PatientModel } from '../model/PatientModel';

export class PatientApi extends BaseApi {
  constructor() {
    super({
      isMock: true
    })
  }

  /**
   * 添加或编辑就诊人
   */
  public bindPatient(item: PatientModel) {
    return this.sendRequest<PatientModel>('/patient', RequestMethod.POST, item)
  }

  /**
   * 解绑就诊人
   */
  public unbindPatient(item: PatientModel) {
    return this.sendRequest<PatientModel>('/patient', RequestMethod.DELETE, item)
  }

  /**
   * 获取就诊人列表
   */
  public getPatientList(onCacheCallback?: (data: PatientModel[]) => void, showLoading: boolean = true) {
    return this.sendRequest<PatientModel[]>('/patient', RequestMethod.GET, undefined, showLoading, onCacheCallback)
  }

  /**
   * 获取默认就诊人
   */
  public getDefaultPatient(onCacheCallback?: (data: PatientModel) => void, showLoading: boolean = true) {
    return this.sendRequest<PatientModel>('/patient/default', RequestMethod.GET, undefined, showLoading,
      onCacheCallback)
  }

  /**
   * 设置默认就诊人
   */
  public setDefaultPatient(item: PatientModel) {
    return this.sendRequest<PatientModel>('/patient/default', RequestMethod.POST, item)
  }
}