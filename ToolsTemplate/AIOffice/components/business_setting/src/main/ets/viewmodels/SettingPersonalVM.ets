import { BusinessError } from '@kit.BasicServicesKit';
import {
  BaseViewModel,
  FileUtils,
  Logger,
  PhoneNumberUtils,
  RouterUtils,
  CommonConstants,
  CommonTipDialog,
  GlobalContext,
} from 'lib_common';
import { MineServiceApi } from 'lib_api';
import { getAccountErrorMsg, ErrorCode } from 'lib_account';

const TAG = '[SettingPersonalVM]';

@ObservedV2
export class SettingPersonalVM extends BaseViewModel {
  readonly defaultSheetH: SheetSize | Length = SheetSize.LARGE;
  @Trace nickName: string = this.userInfoModel.authorNickName;
  @Trace contactPhone: string = this.userInfoModel.authorPhone;
  @Trace personalDesc: string = this.userInfoModel.authorDesc;
  @Trace showNickNameSheet: boolean = false;
  @Trace showPersonDescSheet: boolean = false;
  @Trace showPhoneSheet: boolean = false;
  @Trace hasModify: boolean = false;
  @Trace sheetType: SheetType = SheetType.BOTTOM;

  getSheetOptions(title: string) {
    return {
      title: { title },
      height: this.defaultSheetH,
      detents: [this.defaultSheetH, SheetSize.MEDIUM],
      showClose: true,
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      preferType: SheetType.CENTER,
      onTypeDidChange: (type: SheetType) => {
        this.setSheetType(type);
      },
    } as SheetOptions
  }

  modifyNickName() {
    if (!this.nickName) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '昵称不能为空' });
      return
    }
    MineServiceApi.modifyPersonalInfo({ authorNickName: this.nickName });
    this.userInfoModel.authorNickName = this.nickName;
    this.showNickNameSheet = false;
    this.hasModify = true;
  }

  modifyContactPhone() {
    if (!this.contactPhone) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '手机号码不能为空' });
      return;
    }
    if (!PhoneNumberUtils.isPhoneNumberValid(this.contactPhone)) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '请输入正确的手机号码' });
      return;
    }
    MineServiceApi.modifyPersonalInfo({ authorPhone: this.contactPhone });
    this.userInfoModel.authorPhone = PhoneNumberUtils.encryptPhone(this.contactPhone);
    this.showPhoneSheet = false;
    this.hasModify = true;
  }

  modifyPersonalDesc() {
    MineServiceApi.modifyPersonalInfo({ authorDesc: this.personalDesc });
    this.userInfoModel.authorDesc = this.personalDesc;
    this.showPersonDescSheet = false;
    this.hasModify = true;
  }

  saveUserIcon(uri: string) {
    if (!uri) {
      return;
    }
    const resp = FileUtils.handleUri(uri);
    Logger.info(TAG, 'user icon saved success, url:' + resp);
    MineServiceApi.modifyPersonalInfo({ authorIcon: resp });
    this.userInfoModel.authorIcon = resp;
    this.hasModify = true;
  }

  handleAvatarError(error: BusinessError) {
    Logger.error(TAG, 'onChooseAvatar failed, error: ' + JSON.stringify(error));
    if (error.code === ErrorCode.ERROR_CODE_CANCEL) {
      return;
    }
    let errorMsg: string = getAccountErrorMsg(error.code);

    CommonTipDialog.show({
      primaryTitle: '温馨提示',
      content: errorMsg,
      priBtnV: '确定',
    })
  }

  customBack() {
    RouterUtils.pop(this.hasModify ? 'modify-flag' : undefined);
  }

  setSheetType(sheetType: SheetType) {
    this.sheetType = sheetType;
  }

  getSheetPaddingBottom() {
    if (this.sheetType === SheetType.BOTTOM) {
      return Math.max(this.windowModel.windowBottomPadding, CommonConstants.PADDING_L);
    }
    return CommonConstants.PADDING_L;
  }
}