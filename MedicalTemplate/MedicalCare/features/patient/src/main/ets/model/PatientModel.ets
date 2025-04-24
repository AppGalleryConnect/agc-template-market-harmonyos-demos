@ObservedV2
export class PatientModel {
  @Trace cardId: string = '' // 就诊码
  @Trace patientName: string = ''
  @Trace phone: string = ''
  @Trace idCardType: string = ''
  @Trace idCard: string = '' // 身份证号
  @Trace sex: string = ''
  @Trace birthday: string = ''
  @Trace country: string = ''
  @Trace city: string = ''
  @Trace address: string = ''
  @Trace insuranceType: string = '' // 医保类型
  @Trace picUrl: string = ''
}