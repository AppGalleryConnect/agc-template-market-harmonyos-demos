import { BaseViewModel, CommonWebPageParam, RouterUtil, ToastUtil } from 'common'
import { PatientApi, PatientModel } from 'patient'
import { ReportApi } from '../api/ReportApi'
import { ReportModel } from '../model/ReportModel'

@ObservedV2
export class ReportViewModel extends BaseViewModel {
  // 报告列表
  @Trace reportList: ReportModel[] = []
  // 当前就诊人
  @Trace patient: PatientModel = new PatientModel()
  // 就诊人列表
  @Trace patientList: PatientModel[] = []
  private reportApi: ReportApi = new ReportApi(this.getLoadingCallback())
  private patientApi: PatientApi = new PatientApi()

  public initData() {
    try {
      this.patientApi.getDefaultPatient((patient) => {
        this.patient = patient
      }, false).catch(() => {
        RouterUtil.back()
        ToastUtil.showToast('获取默认就诊人失败，请先设置默认就诊人')
      })
      this.loadReportList();
      this.loadPatientList();
    } catch (error) {
      ToastUtil.showToast('获取就诊人失败');
    }
  }

  public loadReportList() {
    this.reportApi.getReportList(this.patient.cardId).then((data) => {
      this.reportList = data
    })
  }

  public changePatient(patient: PatientModel) {
    this.patient = patient
    this.loadReportList()
  }

  public onDetailClick(periodIndex: number, reportIndex: number) {
    this.toPage('CommonWebPage', {
      src: this.reportList[periodIndex].detail[reportIndex].url,
      title: '报告详情'
    } as CommonWebPageParam)
  }

  private loadPatientList() {
    this.patientApi.getPatientList((data) => {
      this.patientList = data
    }, false)
  }
}