import { BaseApi, RequestMethod } from 'common';
import { ReportModel } from '../model/ReportModel';

interface GetReportListRequest {
  patientCardId: string;
}

export class ReportApi extends BaseApi {
  constructor(onLoadingCallback?: (isLoading: boolean) => void) {
    super({
      isMock: true,
      showLoading: false,
      onLoadingCallback: onLoadingCallback
    })
  }

  /**
   * 获取报告列表
   *
   * @param patientCardId 就诊人卡号
   */
  public getReportList(patientCardId: string) {
    return this.sendRequest<ReportModel[]>('/report', RequestMethod.GET, {
      patientCardId: patientCardId
    } as GetReportListRequest)
  }
}