import { UtilLog } from '@hw-agconnect/util-log';
import { tag } from '@kit.ConnectivityKit';
import { JSON, PlainArray } from '@kit.ArkTS';
import Common from '../Common';
import Util from '../../Util';
import { NfcInfo } from '../../../db/NfcCardInfo';
import { KEY_MAP } from '../../Constant';
import NFC from '../Nfc';

const NO_KEY = '------------';
const NO_DATA = '--------------------------------';

export default class MifareClassicReader {
  mMFC: tag.MifareClassicTag;

  constructor(mMFC: tag.MifareClassicTag) {
    this.mMFC = mMFC;
  }

  async readCard(nfcType: number): Promise<NfcInfo> {
    this.mMFC.connect();
    if (this.mMFC.isConnected()) {
      let size = this.mMFC.getTagSize();
      let sectorCount = this.mMFC.getSectorCount();
      let blockCount: number = 0;
      for (let i = 0; i < sectorCount; i++) {
        blockCount += this.mMFC.getBlockCountInSector(i);
      }

      let id = tag.getTagInfo(NFC.startWant).uid

      let keyMap: PlainArray<number[][]> = await MifareClassicReader.getKeyMap(this.mMFC, sectorCount);

      let sectors: Array<String[]> = [];
      if (keyMap) {
        let mRawDump: PlainArray<string[]> = await this.readAsMuchAsPossible(keyMap);
        if (mRawDump) {
          let sectorSize = mRawDump.length;
          for (let i = 0; i < sectorSize; i++) {
            sectors.push(mRawDump.get(i));
          }
        }
      }
      let nfcInfo: NfcInfo = new NfcInfo();
      try {
        nfcInfo = new NfcInfo(undefined, Util.toHexString(id),
          await Util.getCardName(nfcType), nfcType, size, sectorCount, blockCount, JSON.stringify(sectors), -1,
          undefined,
          undefined, undefined, undefined, new Date().getTime(), false, false);
      } catch (e) {
        UtilLog.error(`onKnockShareStart failed: ${e}`);
      }

      return nfcInfo;
    }
    throw new Error();
  }

  async readAsMuchAsPossible(keyMap: PlainArray<number[][]>): Promise<PlainArray<string[]>> {
    let resultSparseArray: PlainArray<string[]> = new PlainArray<string[]>();
    if (keyMap && keyMap.length > 0) {
      for (let i = 0; i < keyMap.length; i++) {
        let results: string[][] = [];
        try {
          if (keyMap.get(i)[0]) {
            results[0] = await this.readSector(
              keyMap.getKeyAt(i), keyMap.get(i)[0], false);
          }
          if (keyMap.get(i)[1]) {
            results[1] = await this.readSector(
              keyMap.getKeyAt(i), keyMap.get(i)[1], true);
          }
        } catch (e) {
          return resultSparseArray;
        }
        if (results[0] || results[1]) {
          resultSparseArray.add(keyMap.getKeyAt(i), this.mergeSectorData(
            results[0], results[1]));
        }
      }
    }
    return resultSparseArray;
  }


  async readSector(sectorIndex: number, key: number[], useAsKeyB: boolean): Promise<string[]> {
    let auth = await this.authenticate(sectorIndex, key, useAsKeyB);
    let ret: string[] = [];
    if (auth) {
      let blocks: Array<string> = [];
      let firstBlock = this.mMFC.getBlockIndex(sectorIndex);
      let lastBlock = firstBlock + 4;
      if (this.mMFC.getTagSize() === tag.MifareClassicSize.MC_SIZE_4K && sectorIndex > 31) {
        lastBlock = firstBlock + 16;
      }
      for (let i = firstBlock; i < lastBlock; i++) {
        try {

          let blockBytes: number[] = await this.mMFC.readSingleBlock(i);
          if (blockBytes.length < 16) {
            throw new Error();
          }
          if (blockBytes.length > 16) {
            blockBytes = blockBytes.slice(0, 16);
          }

          blocks.push(Common.bytes2Hex(blockBytes));
        } catch (e) {
          blocks.push(NO_DATA);
          if (!this.mMFC.isConnected()) {
            throw new Error('Tag removed during readSector(...)');
          }
          this.authenticate(sectorIndex, key, useAsKeyB);
        }
      }
      ret = blocks.slice();
      let last = ret.length - 1;

      let flag = true;
      for (let s of ret) {
        if (s !== NO_DATA) {
          flag = false;
          break;
        }
      }
      if (flag) {
        ret = [];
      } else {
        if (!useAsKeyB) {
          if (this.isKeyBReadable(Util.hex2Bytes(
            ret[last].substring(12, 20)))) {
            ret[last] = Common.bytes2Hex(key) +
            ret[last].substring(12, 32);
          } else {
            ret[last] = Common.bytes2Hex(key) +
            ret[last].substring(12, 20) + NO_KEY;
          }
        } else {
          ret[last] = NO_KEY + ret[last].substring(12, 20) +
          Common.bytes2Hex(key);
        }
      }
    }
    return ret;
  }

  private mergeSectorData(firstResult: string[], secondResult: string[]): string[] | undefined {
    let ret: string[] = [];
    if (firstResult || secondResult) {
      if ((firstResult && secondResult) &&
        firstResult.length !== secondResult.length) {
        return undefined;
      }
      let length = (firstResult != null)
        ? firstResult.length : secondResult.length;
      let blocks: Array<string> = [];
      for (let i = 0; i < length - 1; i++) {
        if (firstResult != null && firstResult[i] != null &&
          firstResult[i] !== NO_DATA) {
          blocks.push(firstResult[i]);
        } else if (secondResult != null && secondResult[i] != null &&
          secondResult[i] !== NO_DATA) {
          blocks.push(secondResult[i]);
        } else {
          blocks.push(NO_DATA);
        }
      }
      ret = blocks.slice();
      let last = length - 1;
      if (firstResult != null && firstResult[last] != null &&
        firstResult[last] !== NO_DATA) {
        ret[last] = firstResult[last];
        if (secondResult != null && secondResult[last] != null &&
          secondResult[last] !== NO_DATA) {
          ret[last] = ret[last].substring(0, 20) +
          secondResult[last].substring(20);
        }
      } else if (secondResult != null && secondResult[last] != null &&
        secondResult[last] !== NO_DATA) {
        ret[last] = secondResult[last];
      } else {
        ret[last] = NO_DATA;
      }
    }
    return ret;
  }


  isKeyBReadable(ac: number[]): boolean {
    if (ac === null) {
      return false;
    }
    let c1 = ((ac[1] & 0x80) >>> 7);
    let c2 = ((ac[2] & 0x08) >>> 3);
    let c3 = ((ac[2] & 0x80) >>> 7);
    return c1 === 0 && (c2 === 0 && c3 === 0) ||
      (c2 === 1 && c3 === 0) || (c2 === 0 && c3 === 1);
  }

  async authenticate(sectorIndex: number, key: number[], useAsKeyB: boolean): Promise<boolean> {
    let retryAuth = false;
    let retryCount = 1;
    if (!key) {
      return false;
    }
    let ret = false;
    for (let i = 0; i < retryCount + 1; i++) {
      try {
        if (!useAsKeyB) {
          // Key A.
          await this.mMFC.authenticateSector(sectorIndex, key, true);
          ret = true;
        } else {
          // Key B.
          await this.mMFC.authenticateSector(sectorIndex, key, false);
          ret = true;
        }
      } catch (e) {
        return false;
      }
      if (ret || !retryAuth) {
        break;
      }
    }
    return ret;
  }

  static async getKeyMap(mifareClassic: tag.MifareClassicTag, sectorCount: number): Promise<PlainArray<number[][]>> {
    let keys: string[] = Tool.getKeyMap(); //得到密钥字符串
    let a: boolean;
    let b: boolean;
    let keyResult: String[] = [];
    let keyMap: PlainArray<number[][]> = new PlainArray<number[][]>();

    for (let sectorIndex = 0; sectorIndex < sectorCount; ) {
      a = false;
      b = false;
      let retryCount = 0;
      let bytesKeys: number[][] = [];
      for (let key of keys) {
        let bytes: number[] = Util.hex2Bytes(key);
        if (!a) {
          try {
            await mifareClassic.authenticateSector(sectorIndex, bytes, true);
            keyResult[0] = key;
            bytesKeys[0] = bytes;
            a = true;
          } catch (e) {
          }
        }
        if (!b) {
          try {
            await mifareClassic.authenticateSector(sectorIndex, bytes, false);
            keyResult[1] = key;
            bytesKeys[1] = bytes;
            b = true;
          } catch (e) {
          }
        }
        if (a && b) {
          keyMap.add(sectorIndex, bytesKeys);
          sectorIndex++;
          break;
        } else {
          retryCount++;
          if (retryCount === 2) {
            sectorIndex++;
            break;
          }
        }
      }
    }
    return keyMap;

  }
};

export class Tool {
  static getKeyMap(): string[] {
    return KEY_MAP;
  }
}