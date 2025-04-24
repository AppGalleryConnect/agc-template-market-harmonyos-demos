import { BaseViewModel, DataUtil, LogUtil, RouterUtil, ToastUtil } from 'common'
import { PatientApi } from '../api/PatientApi'
import { PatientModel } from '../model/PatientModel'
import { generateBarcode, scanCore } from '@kit.ScanKit'
import { image } from '@kit.ImageKit'

@ObservedV2
export class PatientViewModel extends BaseViewModel {
  private static instance: PatientViewModel
  @Trace patientList: PatientModel[] = [] // 就诊人列表
  @Trace defaultPatient: PatientModel | null = null // 默认就诊人
  @Trace patientDetailInfo: PatientModel = new PatientModel() // 就诊人详情编辑界面数据
  private patientApi: PatientApi = new PatientApi()
  private isSelectMode: boolean = false // （就诊人列表）是否为选择就诊人的模式
  private editedIndex: number = 0

  public constructor() {
    super()
  }

  private _isAddMode: boolean = false // （就诊人详情页）是否为添加就诊人的模式，否则为编辑模式

  public get isAddMode() {
    return this._isAddMode
  }

  public set isAddMode(value: boolean) {
    this._isAddMode = value
  }

  public static getInstance() {
    if (!PatientViewModel.instance) {
      PatientViewModel.instance = new PatientViewModel();
    }
    return PatientViewModel.instance;
  }

  public bindPatient() {
    if (!this.checkPatientInfo()) {
      LogUtil.info(`${JSON.stringify(this.patientDetailInfo)}`)
      return
    }
    this.patientApi.bindPatient(this.patientDetailInfo).then((data) => {
      ToastUtil.showToast('绑定成功')

      if (this.isAddMode) {
        this.patientDetailInfo.cardId = data.cardId
        this.patientList.push(this.patientDetailInfo)
      } else {
        DataUtil.replaceListItem(this.patientList, this.editedIndex, this.patientDetailInfo)
      }

      RouterUtil.back()
      LogUtil.info('patient List to: ' + JSON.stringify(this.patientList))
    })
  }

  public unbindPatient() {
    this.patientApi.unbindPatient(this.patientDetailInfo).then(() => {
      ToastUtil.showToast('解绑成功')
      this.patientList.splice(this.editedIndex, 1)
      if (this.defaultPatient?.cardId === this.patientDetailInfo.cardId) {
        this.loadDefaultPatient()
      }
      RouterUtil.back()
    })
  }

  public loadPatientList() {
    if (this.patientList.length !== 0) {
      return
    }
    this.patientApi.getPatientList((data) => {
      LogUtil.info(`getPatientList onSuccess: ${JSON.stringify(data)}`)
      DataUtil.pushItems(this.patientList, data, () => new PatientModel())
    })
  }

  public loadDefaultPatient() {
    this.patientApi.getDefaultPatient(data => {
      this.defaultPatient = data
    }, false).catch(() => {
      this.defaultPatient = null
    })
  }

  public toPatientSelectListPage() {
    this.toPage('PatientListPage')
    this.isSelectMode = true
  }

  public toPatientEditListPage() {
    this.toPage('PatientListPage')
    this.isSelectMode = false
  }

  public toPatientAddPage() {
    this.isAddMode = true
    this.patientDetailInfo = new PatientModel()
    this.toPage('PatientDetailPage')
  }

  public onPatientClicked(index: number) {
    LogUtil.info(`onPatientClicked: ${index}, isAddMode: ${this.isAddMode}, isSelectMode: ${this.isSelectMode}`)
    this.isAddMode = false
    if (this.isSelectMode) {
      this.setDefaultPatient(this.patientList[index])
    } else {
      this.toPatientEditPage(index)
    }
  }

  public generateScanCodeImage(content: string): Promise<[image.PixelMap, image.PixelMap]> {
    return Promise.all([generateBarcode.createBarcode(content, {
      scanType: scanCore.ScanType.CODE128_CODE,
      width: 600,
      height: 200,
    }), generateBarcode.createBarcode(content, {
      scanType: scanCore.ScanType.QR_CODE,
      width: 200,
      height: 200,
    })])
  }

  private setDefaultPatient(item: PatientModel | null) {
    if (item === null) {
      this.isSelectMode = false
      return
    }

    this.patientApi.setDefaultPatient(item).then(() => {
      ToastUtil.showToast(`设置默认就诊人${item.patientName}成功`)
      RouterUtil.back()
      this.defaultPatient = item
      this.isSelectMode = false
    })
  }

  private toPatientEditPage(index: number) {
    this.toPage('PatientDetailPage')
    this.patientDetailInfo = new PatientModel()
    DataUtil.copyObject(this.patientDetailInfo, this.patientList[index])
    LogUtil.info('patient detail info: ' + JSON.stringify(this.patientDetailInfo))
    this.editedIndex = index
  }

  private checkPatientInfo(): boolean {
    const patient = this.patientDetailInfo;

    if (patient.patientName.trim().length === 0) {
      ToastUtil.showToast('请填写姓名');
      return false;
    }
    if (patient.patientName.trim().length > 8) {
      ToastUtil.showToast('姓名长度超出限制');
      return false;
    }
    if (patient.phone.trim().length === 0) {
      ToastUtil.showToast('请填写手机号码');
      return false;
    }
    if (patient.idCardType.trim().length === 0) {
      ToastUtil.showToast('请填写证件类型');
      return false;
    }
    if (patient.idCard.trim().length === 0) {
      ToastUtil.showToast('请填写证件号码');
      return false;
    }
    if (patient.sex.trim().length === 0) {
      ToastUtil.showToast('请填写性别');
      return false;
    }
    if (patient.birthday.trim().length === 0) {
      ToastUtil.showToast('请填写出生日期');
      return false;
    }
    if (patient.country.trim().length === 0) {
      ToastUtil.showToast('请填写国家');
      return false;
    }
    if (patient.city.trim().length === 0) {
      ToastUtil.showToast('请填写城市');
      return false;
    }
    if (patient.address.trim().length === 0) {
      ToastUtil.showToast('请填写地址');
      return false;
    }
    if (patient.insuranceType.trim().length === 0) {
      ToastUtil.showToast('请填写医保类型');
      return false;
    }

    if (patient.phone.trim().length !== 11) {
      ToastUtil.showToast('手机号码长度应为11位');
      return false;
    } else if (patient.idCardType === '身份证') {
      if (patient.idCard.trim().length !== 18 && patient.idCard.trim().length !== 15) {
        ToastUtil.showToast('身份证号码长度应为15位或18位');
        return false;
      }
    } else if (patient.idCardType === '护照') {
      if (patient.idCard.trim().length < 7 || patient.idCard.trim().length > 10) {
        ToastUtil.showToast('护照号码长度应为7-10位');
        return false;
      }
    } else if (patient.idCardType === '港澳通行证') {
      if (patient.idCard.trim().length < 8 || patient.idCard.trim().length > 11) {
        ToastUtil.showToast('港澳通行证号码长度应为8-11位');
        return false;
      }
    }

    return true;
  }
}
