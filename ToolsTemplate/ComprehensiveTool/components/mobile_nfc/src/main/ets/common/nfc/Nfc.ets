import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { bundleManager, Want } from '@kit.AbilityKit';
import { tag } from '@kit.ConnectivityKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { Application, Card, PROP } from './Spec';
import Util from '../Util';
import StandardPboc from './reader/pboc/StandardPboc';
import MifareClassicReader from './reader/MifareClassicReader';
import { NfcInfo, nfcCardInfo } from '../../db/NfcCardInfo';
import KeyMapCreator from './mifaretool/KeyMapCreator';
import MCFormatter from './MCFormatter';
import Common from './Common';
import FeliCaReader from './reader/FeliCaReader';
import { ActionModel } from '../../model/Index';
import { KEY_MAP } from '../Constant';
import { NFC_TYPE } from '../Enum';

export function getNfcName(nfcType: number): string {
  switch (nfcType) {
    case NFC_TYPE.NFC_TYPE_DOOR:
      return '门禁卡';
    case NFC_TYPE.NFC_TYPE_BUS:
      return '公交卡';
    case NFC_TYPE.NFC_TYPE_ELEVATOR:
      return '电梯卡';
    case NFC_TYPE.NFC_TYPE_BANK:
      return '银行卡';
    case NFC_TYPE.NFC_TYPE_BIKE:
      return '电动车卡';
    default:
      return '';
  }
}

export function getMyNfcName(nfcType: number): string {
  return '我的' + getNfcName(nfcType);
}

export function getNfcItemImg(nfcType: number): Resource {
  switch (nfcType) {
    case NFC_TYPE.NFC_TYPE_DOOR:
    default:
      return $r('app.media.ic_doorcard_bg');
    case NFC_TYPE.NFC_TYPE_BUS:
      return $r('app.media.ic_transport_bg');
    case NFC_TYPE.NFC_TYPE_BANK:
      return $r('app.media.ic_bankcard_bg');
  }
}

export function getNfcCardBgImg(nfcType: number): Resource {
  switch (nfcType) {
    case NFC_TYPE.NFC_TYPE_DOOR:
    default:
      return $r('app.media.ic_doorcard_bg');
    case NFC_TYPE.NFC_TYPE_BUS:
      return $r('app.media.ic_transport_bg');
    case NFC_TYPE.NFC_TYPE_BANK:
      return $r('app.media.ic_bankcard_bg');
  }
}

export class OnNfcChanged {
  nfcType: number;
  history: boolean;
  mine: boolean;

  constructor(nfcType: number, history: boolean, mine: boolean) {
    this.nfcType = nfcType;
    this.history = history;
    this.mine = mine;
  }
}

const MODE_READER = 0;

export default class NFC {
  static startWant: Want
  static uuid: number;
  static running: boolean = false;
  static tagMode: number = MODE_READER;
  static nfcTagElementName: bundleManager.ElementName;
};

export async function initNFC(want: Want) {
  NFC.startWant = want
  NFC.nfcTagElementName = {
    bundleName: want.bundleName ?? '',
    abilityName: want.abilityName ?? '',
    moduleName: want.moduleName,
  };
}

export async function startReadNFC(nfcType: number, callback: AsyncCallback<NFCState>) {
  stopNFC((err, result) => {
    if (NFC.nfcTagElementName) {
      // 调用tag模块中前台优先的接口，使能前台应用程序优先处理所发现的NFC标签功能
      // 门禁卡 1 8 7
      // 银行卡 3 1
      // 公交卡 3 1 1 8 7
      let techList: number[] = [tag.NFC_A, tag.ISO_DEP, tag.NFC_F, tag.MIFARE_CLASSIC];
      try {
        callback(undefined, new NFCState(NFC_STATE_WAIT));
        tag.on('readerMode', NFC.nfcTagElementName, techList, (error: BusinessError, tagInfo: tag.TagInfo) => {
          if (error) {
            UtilLog.info(0x0000, 'MobileNFC', 'readerModeCb readerModeCb error %{public}s', JSON.stringify(error));
            promptAction.showToast({
              message: 'readerModeCb readerModeCb error ' + JSON.stringify(error),
            });
            callback(new NFCError(-1, '读取NFC失败'), undefined);
          } else {
            readNFC(nfcType, tagInfo, callback);
          }
        });
        NFC.running = true;
      } catch (error) {
        UtilLog.error(0x0000, 'MobileNFC', 'on readerMode error = %{public}s', JSON.stringify(error));
        callback(new NFCError(-1, '读取NFC失败'), undefined);
      }
    } else {
      callback(new NFCError(-1, '不支持NFC功能'), undefined);
    }
  });
}

export async function startCloneNFC(uiContext: UIContext, nfcType: number, nfcInfo: NfcInfo,
  callback: AsyncCallback<NFCState>) {
  stopNFC((err, result) => {
    if (NFC.nfcTagElementName) {
      // 门禁卡 1 8 7
      // 银行卡 3 1
      // 公交卡 3 1 1 8 7
      let techList: number[] = [tag.NFC_A, tag.ISO_DEP, tag.NFC_F, tag.MIFARE_CLASSIC];
      try {
        callback(undefined, new NFCState(NFC_STATE_WAIT));
        tag.on('readerMode', NFC.nfcTagElementName, techList, (error: BusinessError, tagInfo: tag.TagInfo) => {
          if (error) {
            UtilLog.info(0x0000, 'MobileNFC', 'readerModeCb readerModeCb error %{public}s', JSON.stringify(error));
            promptAction.showToast({
              message: 'readerModeCb readerModeCb error ' + JSON.stringify(error),
            });
            callback(new NFCError(-1, '克隆NFC失败'), undefined);
          } else {
            readNFC(nfcType, tagInfo, (err, result) => {
              if (err) {
                callback(err, undefined);
              } else {
                switch (result.state) {
                  case NFC_STATE_WAIT:
                    break;
                  case NFC_STATE_READ:
                    callback(undefined, new NFCState(NFC_STATE_READ));
                    break;
                  case NFC_STATE_COMPLETE:
                    if (result.nfcInfo) {
                      cloneNFC(uiContext, nfcType, nfcInfo, result.nfcInfo, tagInfo, callback);
                    } else {
                      callback(new NFCError(-1, '克隆NFC失败'), undefined);
                    }
                    break;
                }
              }
            });
          }
        });
        NFC.running = true;
      } catch (error) {
        UtilLog.error(0x0000, 'MobileNFC', 'on readerMode error = %{public}s', JSON.stringify(error));
        callback(new NFCError(-1, '读取NFC失败'), undefined);
      }
    } else {
      callback(new NFCError(-1, '不支持NFC功能'), undefined);
    }
  });
}

export async function startFormatNFC(nfcType: number, actionModel: ActionModel, callback: AsyncCallback<NFCState>) {
  stopNFC((err, result) => {
    if (NFC.nfcTagElementName) {
      // 门禁卡 1 8 7
      // 银行卡 3 1
      // 公交卡 3 1 1 8 7
      let techList: number[] = [tag.NFC_A, tag.NDEF_FORMATABLE, tag.MIFARE_CLASSIC];
      try {
        callback(undefined, new NFCState(NFC_STATE_WAIT));
        tag.on('readerMode', NFC.nfcTagElementName, techList, (error: BusinessError, tagInfo: tag.TagInfo) => {
          if (error) {
            UtilLog.info(0x0000, 'MobileNFC', 'readerModeCb readerModeCb error %{public}s', JSON.stringify(error));
            promptAction.showToast({
              message: 'readerModeCb readerModeCb error ' + JSON.stringify(error),
            });
            callback(new NFCError(-1, '格式化NFC失败'), undefined);
          } else {
            formatNFC(nfcType, tagInfo, actionModel, callback);
          }
        });
        NFC.running = true;
      } catch (error) {
        UtilLog.error(0x0000, 'MobileNFC', 'on readerMode error = %{public}s', JSON.stringify(error));
        callback(new NFCError(-1, '读取NFC失败'), undefined);
      }
    } else {
      callback(new NFCError(-1, '不支持NFC功能'), undefined);
    }
  });
}

export async function stopNFC(callback?: AsyncCallback<void>) {
  // 退出应用程序NFC标签页面时，调用tag模块退出前台优先功能
  if (NFC.running) {
    NFC.running = false;
    try {
      tag.off('readerMode', NFC.nfcTagElementName);
    } catch (error) {
      UtilLog.error(0x0000, 'MobileNFC', 'off readerMode error = %{public}s', JSON.stringify(error));
    }

  }
  if (callback) {
    callback(undefined, undefined);
  }
}

export class NFCError implements BusinessError {
  code: number;
  data?: void | undefined;
  name: string = '';
  message: string;
  stack?: string | undefined;

  constructor(code: number, message: string, name: string = 'RemoteError') {
    this.code = code;
    this.message = message;
    this.name = name;
  }
}

export const NFC_STATE_FAIL = -1;

export const NFC_STATE_NORMAL = 0;

export const NFC_STATE_WAIT = 1;

export const NFC_STATE_READ = 2;

export const NFC_STATE_WRITE = 3;

export const NFC_STATE_FORMAT = 4;

export const NFC_STATE_COMPLETE = 10;

export class NFCState {
  state: number = NFC_STATE_NORMAL;
  nfcInfo?: NfcInfo;
  msg?: string;

  constructor(state: number, nfcInfo?: NfcInfo, msg?: string) {
    this.state = state;
    this.nfcInfo = nfcInfo;
    this.msg = msg;
  }
}

async function readNFC(nfcType: number, tagInfo: tag.TagInfo, callback: AsyncCallback<NFCState>) {
  callback(undefined, new NFCState(NFC_STATE_READ));

  // 获取特定技术类型的NFC标签对象
  if (tagInfo === null || tagInfo === undefined) {
    UtilLog.error(0x0000, 'MobileNFC', 'readerModeCb tagInfo is invalid');
    callback(new NFCError(-1, 'NFC读取失败'), undefined);
    return;
  }
  if (tagInfo.uid === null || tagInfo.uid === undefined) {
    UtilLog.error(0x0000, 'MobileNFC', 'readerModeCb uid is invalid');
    callback(new NFCError(-1, 'NFC读取失败'), undefined);
    return;
  }
  if (tagInfo.technology === null || tagInfo.technology === undefined || tagInfo.technology.length === 0) {
    UtilLog.error(0x0000, 'MobileNFC', 'readerModeCb technology is invalid');
    callback(new NFCError(-1, 'NFC读取失败'), undefined);
    return;
  }

  let card = new Card();

  card.setProperty(PROP.ID, Util.toHexString(tagInfo.uid));

  switch (nfcType) {
    case NFC_TYPE.NFC_TYPE_DOOR:
    case NFC_TYPE.NFC_TYPE_ELEVATOR:
    case NFC_TYPE.NFC_TYPE_BIKE:
    default:
      try {
        let mMFC = tag.getMifareClassic(tagInfo);
        if (mMFC != null) {
          let nfcInfo = await new MifareClassicReader(mMFC).readCard(nfcType);
          card.setProperty(PROP.NFCINFO, nfcInfo);
        }
      } catch (e) {
        UtilLog.error(0x0000, 'readNFC', 'nfcF error: ', JSON.stringify(e));
        if (checkTagError(e, callback)) {
          return;
        }
      }
      break;
    case NFC_TYPE.NFC_TYPE_BUS:
      try {
        let nfcF = tag.getNfcF(tagInfo);
        if (nfcF != null) {
          await FeliCaReader.readCard(nfcF, card);
        }
      } catch (e) {
        UtilLog.error(0x0000, 'readNFC', 'nfcF error: ', JSON.stringify(e));
        if (checkTagError(e, callback)) {
          return;
        }
      }
      break;
    case NFC_TYPE.NFC_TYPE_BANK:
      try {
        let isoDep: tag.IsoDepTag = tag.getIsoDep(tagInfo);
        if (!isoDep) {
          StandardPboc.readCard(isoDep, card);
        }
      } catch (e) {
        UtilLog.error(0x0000, 'readNFC', 'nfcF error: ', JSON.stringify(e));
        if (checkTagError(e, callback)) {
          return;
        }
      }
      break;
  }

  let nfcInfo: NfcInfo | undefined;
  if (card.getApplications().length !== 0) {
    nfcInfo = saveNfcInfoForDATA2(card);
  } else {
    nfcInfo = saveNfcInfoForDATA1(card);
  }

  callback(undefined, new NFCState(NFC_STATE_COMPLETE, nfcInfo));
}

async function cloneNFC(uiContext: UIContext, nfcType: number, nfcInfo: NfcInfo, curNfcInfo: NfcInfo,
  tagInfo: tag.TagInfo,
  callback: AsyncCallback<NFCState>) {

  curNfcInfo.name = await Util.getCardName(nfcType, '写卡自动备份');

  let id: number;
  try {
    id = await nfcCardInfo.insertNfcInfo(curNfcInfo);
    uiContext.getHostContext()!.eventHub.emit(OnNfcChanged.name, new OnNfcChanged(curNfcInfo.type, true, false));
  } catch (e) {
    id = -1;
  }

  callback(undefined, new NFCState(NFC_STATE_WRITE));

  let mifareClassic = tag.getMifareClassic(tagInfo);

  //开始克隆UID
  let uid = nfcInfo.cardId;
  let mUidLen = uid.length;
  let mBlock0Rest = '080400475955D141103607';
  let curSectionInfo: string[][] = JSON.parse(curNfcInfo.sectionInfo) as string[][];
  if (curSectionInfo && curSectionInfo.length > 0) {
    let section: string[] = curSectionInfo[0];
    if (section != null && section.length > 0) {
      let origin = section[0];
      if (Util.isNotBlank(origin) && origin.length > mUidLen + 2) {
        mBlock0Rest = origin.substring(mUidLen + 2);
      }
    }
  }
  mUidLen = mUidLen / 2;
  let bcc: number = Common.calcBcc(Util.hex2Bytes(uid));
  let mBlock0Complete = uid + bcc.toString(16).padStart(2, '0') + mBlock0Rest;

  let uidLen = tagInfo.uid.length;
  if (uidLen !== mUidLen) {
    return;
  }

  let sakAndAtqa: string | undefined = calcSakAtqa(uidLen, mifareClassic.getTagSize());
  if (!sakAndAtqa) {
  } else {
    let sakStart: number = (uidLen === 4) ? uidLen * 2 + 2 : uidLen * 2;
    mBlock0Complete = mBlock0Complete.substring(0, sakStart) + sakAndAtqa +
    mBlock0Complete.substring(sakStart + sakAndAtqa.length);
  }

  //开始写入验证
  if (mifareClassic.getSectorCount() <= 0) {
    return;
  }

  if (mifareClassic.getBlockCountInSector(0) <= 0) {
    return;
  }

  if (!mifareClassic.isConnected()) {
    mifareClassic.connect();
  }

  let auth = await authenticateSector(mifareClassic, callback);
  if (!auth) {
    return;
  } else if (!auth) {
    callback(new NFCError(-1, '克隆失败'), undefined);
  }

  //开始写入
  let block: number = mifareClassic.getBlockIndex(0) + 1;
  try {
    await mifareClassic.writeSingleBlock(block, Util.hex2Bytes(mBlock0Complete));
    callback(undefined, new NFCState(NFC_STATE_COMPLETE));
  } catch (e) {
    callback(e, undefined);
  }
}

async function authenticateSector(mifareClassic: tag.MifareClassicTag,
  callback: AsyncCallback<NFCState>): Promise<boolean | undefined> {
  let auth = false;
  // todo: KEY_MAP为扇区数据的加解密秘钥，您需要根据NFC卡的类型替换秘钥内容，当前仅支持解密MIFARE Classic卡
  for (let element of KEY_MAP) {
    try {
      await mifareClassic.authenticateSector(0, Util.hex2Bytes(element), true);
      auth = true;
      break;
    } catch (e) {
      UtilLog.error(0x0000, 'cloneNFC', 'mifareClassic error: ', JSON.stringify(e));
      if (checkTagError(e, callback)) {
        return undefined;
      }
    }
  }
  return auth;
}

function calcSakAtqa(uidLen: number, tagSize: number): string | undefined {
  if ((uidLen !== 4 && uidLen !== 7) || (
    tagSize !== tag.MifareClassicSize.MC_SIZE_MINI &&
      tagSize !== tag.MifareClassicSize.MC_SIZE_1K &&
      tagSize !== tag.MifareClassicSize.MC_SIZE_2K &&
      tagSize !== tag.MifareClassicSize.MC_SIZE_4K)) {
    return undefined;
  }

  let atqa: string | undefined = undefined;
  if (uidLen === 4 && (tagSize === tag.MifareClassicSize.MC_SIZE_1K ||
    tagSize === tag.MifareClassicSize.MC_SIZE_2K ||
    tagSize === tag.MifareClassicSize.MC_SIZE_MINI)) {
    atqa = '0400';
  } else if (uidLen === 4 && tagSize === tag.MifareClassicSize.MC_SIZE_4K) {
    atqa = '0200';
  } else if (uidLen === 7 && (tagSize === tag.MifareClassicSize.MC_SIZE_1K ||
    tagSize === tag.MifareClassicSize.MC_SIZE_2K ||
    tagSize === tag.MifareClassicSize.MC_SIZE_MINI)) {
    atqa = '4400';
  } else if (uidLen === 7 && tagSize === tag.MifareClassicSize.MC_SIZE_4K) {
    atqa = '4200';
  }

  let sak: string | undefined = undefined;
  if (tagSize === tag.MifareClassicSize.MC_SIZE_MINI) {
    sak = '09';
  } else if (tagSize === tag.MifareClassicSize.MC_SIZE_1K || tagSize === tag.MifareClassicSize.MC_SIZE_2K) {
    sak = '08';
  } else if (tagSize === tag.MifareClassicSize.MC_SIZE_4K) {
    sak = '18';
  }

  if (!sak || !atqa) {
    return undefined;
  }
  return sak + atqa;
}

async function formatNFC(nfcType: number, tagInfo: tag.TagInfo, actionModel: ActionModel,
  callback: AsyncCallback<NFCState>) {
  callback(undefined, new NFCState(NFC_STATE_FORMAT));

  let keyMapCreator = new KeyMapCreator();
  await keyMapCreator.onCreateKeyMap(tagInfo);
  try {
    await new MCFormatter(tagInfo, nfcType).createFactoryFormattedDump(tagInfo, actionModel);
    callback(undefined, new NFCState(NFC_STATE_COMPLETE));
  } catch (e) {
    callback(e, undefined);
  }
}

export function checkTagError(e: BusinessError, callback: AsyncCallback<NFCState>): boolean {
  if (e) {
    switch (e.code.toString()) {
      case '3100101':
      case '3100201':
      case '3100202':
        callback(e, undefined);
        return true;
    }
  }
  return false;
}

//不带有余额的数据，扇区数据，除公交卡
function saveNfcInfoForDATA1(card: Card): NfcInfo {
  let nfcInfo = card.getProperty(PROP.NFCINFO) as NfcInfo;
  if (nfcInfo) {
    nfcInfo.ltime = new Date().getTime();
  }
  return nfcInfo;
}

//带有余额的数据(公交卡)
function saveNfcInfoForDATA2(card: Card): NfcInfo | undefined {
  let nfcInfo: NfcInfo;
  let applications: Application[] = card.getApplications();
  if (applications.length > 0) {
    nfcInfo = card.getProperty(PROP.NFCINFO) as NfcInfo;
    if (nfcInfo) {
      let application = applications[0];
      let balance = application.getProperty(PROP.BALANCE) as string; //余额
      let date = application.getProperty(PROP.DATE) as string; //发行日期-有效日期
      let city = application.getProperty(PROP.ID) as string; //城市

      nfcInfo.balance = parseFloat(balance);

      let dateStr = date;
      let split = dateStr.split('-');
      nfcInfo.issuing = split[0];
      nfcInfo.effective = split[split.length - 1];

      nfcInfo.city = city.toString();
      nfcInfo.ltime = new Date().getTime();

      return nfcInfo;
    }
  }
  return undefined;
}