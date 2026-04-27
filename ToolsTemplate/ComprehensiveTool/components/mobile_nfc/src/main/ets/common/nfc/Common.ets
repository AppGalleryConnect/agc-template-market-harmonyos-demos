import { tag } from '@kit.ConnectivityKit';
import { PlainArray } from '@kit.ArkTS';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import MCReader from './MCReader';
import { RTYPE } from '../Enum';
import { ResultInfo } from '../../model/Index';

export default class Common {
  private static mKeyMap: PlainArray<number[][]> = new PlainArray();

  public static setKeyMap(value: PlainArray<number[][]>) {
    Common.mKeyMap = value;
  }

  public static getKeyMap(): PlainArray<number[][]> {
    return Common.mKeyMap;
  }

  static bytes2Hex(bytes: number[]): string {
    let ret = '';
    if (bytes) {
      for (let b of bytes) {
        ret += (b & 0xFF).toString(16).padStart(2, '0');
      }
    }
    return ret.toString();
  }

  public static checkForTagAndCreateReader(tagInfo: tag.TagInfo): MCReader | undefined {
    let reader: MCReader | undefined;
    let tagLost: boolean = false;
    if (tagInfo && (reader = MCReader.get(tagInfo))) {
      try {
        reader.connect();
      } catch (e) {
        tagLost = true;
      }
      if (!tagLost && !reader.isConnected()) {
        reader.close();
        tagLost = true;
      }
      if (!tagLost) {
        return reader;
      }
    }

    promptAction.showToast({
      message: '错误:未发现MIFARE Classic标签',
    });

    return undefined;
  }

  static calcBcc(uid: number[]): number {
    if (uid.length !== 4) {
      throw new Error('UID length is not 4 bytes.');
    }
    let bcc: number = uid[0];
    for (let i = 1; i < uid.length; i++) {
      bcc = (bcc ^ uid[i]);
    }
    return bcc;
  }
};

export const RESULT_INFO_MAP: Map<RTYPE, ResultInfo> =
  new Map([[RTYPE.RTYPE_NOT_FOUND, new ResultInfo('未找到卡片', '没有检测到卡片，请重试')],
    [RTYPE.RTYPE_READ_FAIL, new ResultInfo('读卡失败', '读取失败，请重试')],
    [RTYPE.RTYPE_CLONE_FAIL, new ResultInfo('克隆失败', '克隆失败，可能是卡片信息不匹配')],
    [RTYPE.RTYPE_CLONE_SUCCESS, new ResultInfo('克隆完成', '克隆完成，请返回', false)],
    [RTYPE.RTYPE_FEEDBACK_SUCCESS, new ResultInfo('反馈成功', '提交成功，请返回', false)]]);