import { NFC_TYPE } from '../common/Enum';
import { NfcInfo } from '../db/NfcCardInfo';

export interface CardModule {
  src: ResourceStr
  text: string
  clickEvent: () => void
}

@ObservedV2
export class ResultInfo {
  title: string;
  hintInfo: string;
  retry?: boolean = true;

  constructor(title: string = '读卡失败', hintInfo: string = '读取失败，请重试', retry: boolean = true) {
    this.title = title;
    this.hintInfo = hintInfo;
    this.retry = retry;
  }
}

@ObservedV2
export class ActionModel {
  @Trace action: number;
  @Trace nfcType?: number;
  @Trace nfcInfo?: NfcInfo;

  constructor(action: number, nfcType?: number, nfcInfo?: NfcInfo) {
    this.action = action;
    this.nfcType = nfcType;
    this.nfcInfo = nfcInfo;
  }
}

export class CardMyModel {
  nfcType: number;

  constructor(nfcType: number = NFC_TYPE.NFC_TYPE_DOOR) {
    this.nfcType = nfcType;
  }
}

export class ResultModel {
  action: number;
  rtype: number;
  actionModel: ActionModel;
  msg?: string;

  constructor(action: number = 0, rtype: number = 0, actionModel: ActionModel = new ActionModel(0), msg?: string) {
    this.action = action;
    this.rtype = rtype;
    this.actionModel = actionModel;
    this.msg = msg;
  }
}

export class DetailModel {
  pageType: number;
  nfcInfo: NfcInfo;

  constructor(pageType: number = 0, nfcInfo: NfcInfo) {
    this.pageType = pageType;
    this.nfcInfo = nfcInfo;
  }
}

export class RenameDialogParams {
  name?: string;
  confirm?: Function;
  cancel?: Function;
}

export class AddMineDialogParams {
  confirm?: Function;
}

export class CloneTipDialogParams {
  confirm?: Function;
}