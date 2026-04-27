import { tag } from '@kit.ConnectivityKit';
import { HashMap, PlainArray } from '@kit.ArkTS';
import Util from '../Util';
import { KEY_MAP } from '../Constant';
import { Operation } from '../Enum';

export default class MCReader {
  public static get(tagInfo: tag.TagInfo): MCReader | undefined {
    if (tagInfo) {
      let mcr: MCReader = new MCReader(tagInfo);
      if (mcr.isMifareClassic()) {
        return mcr;
      }
    }
    return undefined;
  }

  static DEFAULT_KEY = 'FFFFFFFFFFFF';
  mMFC: tag.MifareClassicTag;
  private mKeyMap: PlainArray<number[][]> = new PlainArray<number[][]>();
  mKeyMapStatus = 0;
  mLastSector = -1;
  mFirstSector = 0;
  mKeysWithOrder: string[] = [];
  mHasAllZeroKey = false;
  retryAuth = false;
  retryCount = 2;

  constructor(tagInfo: tag.TagInfo) {
    this.mMFC = tag.getMifareClassic(tagInfo);
  }

  async writeBlock(sectorIndex: number, blockIndex: number, data: number[],
    key: number[], useAsKeyB: boolean): Promise<number> {
    if (this.getSectorCount() - 1 < sectorIndex) {
      return 1;
    }
    if (this.mMFC.getBlockCountInSector(sectorIndex) - 1 < blockIndex) {
      return 2;
    }
    if (data.length !== 16) {
      return 3;
    }
    let auth = await this.authenticate(sectorIndex, key, useAsKeyB);
    if (!auth) {
      return 4;
    }
    let block = this.mMFC.getBlockIndex(sectorIndex) + blockIndex;
    try {
      await this.mMFC.writeSingleBlock(block, data);
    } catch (e) {
      return -1;
    }
    return 0;
  }

  async buildNextKeyMapPart(): Promise<number> {
    let error = false;
    if (this.mKeysWithOrder && this.mLastSector !== -1) {
      if (this.mKeyMapStatus === this.mLastSector + 1) {
        this.mKeyMapStatus = this.mFirstSector;
        this.mKeyMap = new PlainArray<number[][]>();
      }

      let autoReconnect = false;
      let retryAuth = true;

      let retryAuthCount = 2;

      let keys: string[] = [];
      let foundKeys = [false, false];
      let auth: boolean;

      keysloop:
        for (let i = 0; i < this.mKeysWithOrder.length; i++) {
          let key = this.mKeysWithOrder[i];
          let bytesKey = Util.hex2Bytes(key);
          for (let j = 0; j < retryAuthCount + 1; ) {
            try {
              if (!foundKeys[0]) {
                await this.mMFC.authenticateSector(
                  this.mKeyMapStatus, bytesKey, true);
                auth = true;
                if (auth) {
                  keys[0] = key;
                  foundKeys[0] = true;
                }
              }
              if (!foundKeys[1]) {
                await this.mMFC.authenticateSector(
                  this.mKeyMapStatus, bytesKey, false);
                auth = true;
                if (auth) {
                  keys[1] = key;
                  foundKeys[1] = true;
                }
              }
            } catch (e) {
              if (autoReconnect) {
                if (this.isConnectedButTagLost()) {
                  this.close();
                }
                while (!this.isConnected()) {
                  try {
                    await new Promise<void>((resolve) => {
                      setTimeout(resolve, 500);
                    });
                  } catch (ex) {
                  }
                  try {
                    this.connect();
                  } catch (ex) {
                  }
                }
                continue;
              } else {
                error = true;
                break keysloop;
              }
            }
            if ((foundKeys[0] && foundKeys[1]) || !retryAuth) {
              break;
            }
            j++;
          }
          if ((foundKeys[0] && foundKeys[1])) {
            break;
          }
        }
      if (!error && (foundKeys[0] || foundKeys[1])) {
        let bytesKeys: number[][] = [];
        bytesKeys[0] = Util.hex2Bytes(keys[0]);
        bytesKeys[1] = Util.hex2Bytes(keys[1]);
        this.mKeyMap.add(this.mKeyMapStatus, bytesKeys);
        if (this.mKeysWithOrder.length > 2) {
          if (foundKeys[0]) {

            this.mKeysWithOrder = Util.filterString(this.mKeysWithOrder, keys[0]);
            if (this.mHasAllZeroKey && keys[0] !== MCReader.DEFAULT_KEY) {
              this.mKeysWithOrder.unshift(keys[0]);
            } else {
              this.mKeysWithOrder.unshift(keys[0]);
            }
          }
          if (foundKeys[1]) {
            this.mKeysWithOrder = Util.filterString(this.mKeysWithOrder, keys[1]);
            if (this.mHasAllZeroKey && keys[1] !== MCReader.DEFAULT_KEY) {
              this.mKeysWithOrder.unshift(keys[1]);
            } else {
              this.mKeysWithOrder.unshift(keys[1]);
            }
          }
        }
      }
      this.mKeyMapStatus++;
    } else {
      error = true;
    }
    if (error) {
      this.mKeyMapStatus = 0;
      this.mKeyMap = new PlainArray<number[][]>();
      return -1;
    }
    return this.mKeyMapStatus - 1;
  }

  async isWritableOnPositions(pos: HashMap<number, number[]>,
    keyMap: PlainArray<number[][]>): Promise<HashMap<number,
    HashMap<number, number>>> {
    let ret: HashMap<number, HashMap<number, number>> = new HashMap<number, HashMap<number, number>>();
    for (let i = 0; i < keyMap.length; i++) {
      let sector = keyMap.getKeyAt(i);
      if (pos.hasKey(sector)) {
        let keys = keyMap.get(sector);
        let ac: number[];
        if (keys && keys.length > 0 && keys[0]) {
          if (!await this.authenticate(sector, keys[0], false)) {
            return ret;
          }
        } else if (keys && keys.length > 1 && keys[1]) {
          if (!await this.authenticate(sector, keys[1], true)) {
            return ret;
          }
        } else {
          return ret;
        }
        let acBlock = this.mMFC.getBlockIndex(sector) + this.mMFC.getBlockCountInSector(sector) - 1;
        try {
          ac = await this.mMFC.readSingleBlock(acBlock);
        } catch (e) {
          ret.set(sector, undefined);
          continue;
        }
        if (ac.length < 16) {
          ret.set(sector, undefined);
          continue;
        }

        ac = ac.slice(6, 9);
        let acMatrix = Util.acBytesToACMatrix(ac);
        if (!acMatrix) {
          ret.set(sector, undefined);
          continue;
        }
        let isKeyBReadable = Util.isKeyBReadable(
          acMatrix[0][3], acMatrix[1][3], acMatrix[2][3]);

        let blockWithWriteInfo = new HashMap<number, number>();
        for (let block of pos.get(sector)) {
          if ((block === 3 && sector <= 31) ||
            (block === 15 && sector >= 32)) {
            let acValue = Util.getOperationRequirements(
              acMatrix[0][3],
              acMatrix[1][3],
              acMatrix[2][3],
              Operation.WriteAC,
              true, isKeyBReadable);
            let keyABValue = Util.getOperationRequirements(
              acMatrix[0][3],
              acMatrix[1][3],
              acMatrix[2][3],
              Operation.WriteKeyA,
              true, isKeyBReadable);

            let result = keyABValue;
            if (acValue === 0 && keyABValue !== 0) {
              result += 3;
            } else if (acValue === 2 && keyABValue === 0) {
              result = 6;
            }
            blockWithWriteInfo.set(block, result);
          } else {
            let acBitsForBlock = block;
            if (sector >= 32) {
              if (block >= 0 && block <= 4) {
                acBitsForBlock = 0;
              } else if (block >= 5 && block <= 9) {
                acBitsForBlock = 1;
              } else if (block >= 10 && block <= 14) {
                acBitsForBlock = 2;
              }
            }
            blockWithWriteInfo.set(
              block, Util.getOperationRequirements(
              acMatrix[0][acBitsForBlock],
              acMatrix[1][acBitsForBlock],
              acMatrix[2][acBitsForBlock],
              Operation.Write,
              false, isKeyBReadable));
          }

        }
        if (blockWithWriteInfo.length > 0) {
          ret.set(sector, blockWithWriteInfo);
        }
      }
    }
    return ret;
  }

  setKeyFile(assets: string): number {
    if (Util.isBlank(assets)) {
      return -1;
    }
    let keys = KEY_MAP;
    if (keys.length > 0) {
      this.mKeysWithOrder = keys.slice();
      return keys.length;
    }
    return 0;
  }

  setMappingRange(firstSector: number, lastSector: number): boolean {
    if (firstSector >= 0 && lastSector < this.getSectorCount() &&
      firstSector <= lastSector) {
      this.mFirstSector = firstSector;
      this.mLastSector = lastSector;
      this.mKeyMapStatus = lastSector + 1;
      return true;
    }
    return false;
  }

  async authenticate(sectorIndex: number, key: number[],
    useAsKeyB: boolean): Promise<boolean> {
    if (!key) {
      return false;
    }
    let ret = false;
    for (let i = 0; i < this.retryCount + 1; i++) {
      try {
        if (!useAsKeyB) {
          await this.mMFC.authenticateSector(sectorIndex, key, true);
          ret = true;
        } else {
          await this.mMFC.authenticateSector(sectorIndex, key, false);
          ret = true;
        }
      } catch (e) {
        return false;
      }
      if (ret || !this.retryAuth) {
        break;
      }
    }
    return ret;
  }

  isKeyBReadable(ac: number[]): boolean {
    if (ac) {
      let c1 = ((ac[1] & 0x80) >>> 7);
      let c2 = ((ac[2] & 0x08) >>> 3);
      let c3 = ((ac[2] & 0x80) >>> 7);
      return c1 === 0 && (c2 === 0 && c3 === 0) ||
        (c2 === 1 && c3 === 0) || (c2 === 0 && c3 === 1);
    }
    return false;
  }

  getKeyMap(): PlainArray<number[][]> {
    return this.mKeyMap;
  }

  isMifareClassic(): boolean {
    return this.mMFC !== undefined;
  }

  getSize(): number {
    return this.mMFC.getTagSize();
  }

  getSectorCount(): number {
    return this.mMFC.getSectorCount();
  }

  isConnected(): boolean {
    return this.mMFC.isConnected();
  }

  isConnectedButTagLost(): boolean {
    if (this.isConnected()) {
      try {
        this.mMFC.readSingleBlock(0);
      } catch (e) {
        return true;
      }
    }
    return false;
  }

  connect() {
    this.mMFC.connect();
  }

  close() {
  }
};