import { promptAction } from '@kit.ArkUI';
import { TravelPeopleModel } from '../model/TravelPeopleModel';

export class TravelPeopleUtil {
  static validEditInfo(peopleList: TravelPeopleModel[], peopleItem: TravelPeopleModel, isEdit: boolean): boolean {
    if (!peopleItem.name) {
      promptAction.showToast({ message: '请输入您的姓名', duration: 2000 });
      return false
    }
    if (!TravelPeopleUtil.isValidChineseID(peopleItem.idNumber)) {
      promptAction.showToast({ message: '身份证格式错误', duration: 2000 });
      return false
    }
    if (TravelPeopleUtil.idNumberRepeat(peopleList, peopleItem)) {
      promptAction.showToast({ message: '身份证不能重复', duration: 2000 });
      return false
    }
    if (!TravelPeopleUtil.regPhone(peopleItem.phone)) {
      promptAction.showToast({ message: '手机号格式错误', duration: 2000 });
      return false
    }
    return true
  }

  // 校验身份证是否重复
  static idNumberRepeat(peopleList: TravelPeopleModel[], peopleItem: TravelPeopleModel) {
    let id: string | undefined = ''
    if (peopleList.length) {
      let item = peopleList.find((item: TravelPeopleModel) => item.idNumber === peopleItem.idNumber)
      id = item?.id
    }
    let isRepeat = id && id !== peopleItem.id
    return isRepeat
  }

  // 校验身份证
  static isValidChineseID(idCode: string) {
    const iDCodeReg = /^[1-9]\d{5}(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dX]$/;
    return iDCodeReg.test(idCode)
  }

  // 校验手机号
  static regPhone(phone: string) {
    const phoneRegex = /^1(?:3[0-9]|4[014-9]|5[0-35-9]|6[2567]|7[0-8]|8[0-9]|9[0-35-9])\d{8}$/;
    return phoneRegex.test(phone)
  }
}