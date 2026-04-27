import { tag } from '@kit.ConnectivityKit';
import { HashMap, HashSet, PlainArray } from '@kit.ArkTS';
import Common from './Common';
import MCReader from './MCReader';
import { ActionModel, ResultModel } from '../../model/Index';
import { getNavPathStack } from '../Route';
import { ACTION_TYPE, RTYPE } from '../Enum';

export default class MCFormatter {
  tag: tag.TagInfo;
  cardType: number;
  mDumpWithPos: HashMap<number, HashMap<number, number[]>> = new HashMap();
  isChecked = false;

  constructor(tag: tag.TagInfo, cardType: number) {
    this.tag = tag;
    this.cardType = cardType;
  }

  async createFactoryFormattedDump(tagInfo: tag.TagInfo, actionModel: ActionModel) {
    this.mDumpWithPos.clear();
    let mifareClassic = tag.getMifareClassic(tagInfo);
    let sectors = mifareClassic.getSectorCount();
    let emptyBlock: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let normalSectorTrailer = [-1, -1, -1, -1, -1, -1, -1, 7, -128, 105, -1, -1, -1, -1, -1, -1];
    let lastSectorTrailer = [-1, -1, -1, -1, -1, -1, -1, 7, -128, -68, -1, -1, -1, -1, -1, -1];
    let empty4BlockSector = new HashMap<number, number[]>();
    for (let i = 0; i < 3; i++) {
      empty4BlockSector.set(i, emptyBlock);
    }
    empty4BlockSector.set(3, normalSectorTrailer);
    let empty16BlockSector = new HashMap<number, number[]>();
    for (let i = 0; i < 15; i++) {
      empty16BlockSector.set(i, emptyBlock);
    }
    empty16BlockSector.set(15, normalSectorTrailer);
    let lastSector: HashMap<number, number[]>;

    let firstSector = new HashMap<number, number[]>();
    firstSector.set(1, emptyBlock);
    firstSector.set(2, emptyBlock);
    firstSector.set(3, normalSectorTrailer);
    this.mDumpWithPos.set(0, firstSector);
    for (let i = 1; i < sectors && i < 32; i++) {
      this.mDumpWithPos.set(i, empty4BlockSector);
    }
    if (sectors === 40) {
      for (let i = 32; i < sectors && i < 39; i++) {
        this.mDumpWithPos.set(i, empty16BlockSector);
      }
      lastSector = new HashMap<number, number[]>();
      lastSector.setAll(empty16BlockSector);
      lastSector.set(15, lastSectorTrailer);
    } else {
      lastSector = new HashMap<number, number[]>();
      lastSector.setAll(empty4BlockSector);
      lastSector.set(3, lastSectorTrailer);
    }
    this.mDumpWithPos.set(sectors - 1, lastSector);
    await this.checkDumpAgainstTag(tagInfo, actionModel);
  }


  async checkDumpAgainstTag(tagInfo: tag.TagInfo, actionModel: ActionModel) {
    let reader = Common.checkForTagAndCreateReader(tagInfo);
    if (!reader) {
      this.formatFail(100, '错误:测试转储时标签丢失', actionModel);
      return;
    }

    let max: number = 0;
    let keys = this.mDumpWithPos.keys();
    for (let key of keys) {
      max = key > max ? key : max;
    }
    if (reader.getSectorCount() - 1 < max) {
      this.formatFail(100, '错误:标签容量小于选定的转储', actionModel);
      reader.close();
      return;
    }

    let keyMap: PlainArray<number[][]> = Common.getKeyMap();
    let dataPos: HashMap<number, number[]> = new HashMap<number, number[]>();
    for (let sector of this.mDumpWithPos.keys()) {
      let i = 0;
      let blocks: number[] = [];
      for (let block of this.mDumpWithPos.get(sector).keys()) {
        blocks.push(block);
      }
      dataPos.set(sector, blocks);
    }
    let writeOnPos: HashMap<number, HashMap<number, number>> = await reader.isWritableOnPositions(dataPos, keyMap);
    reader.close();

    if (!writeOnPos) {
      this.formatFail(100, '错误:测试转储时标签丢失', actionModel);
      return;
    }

    let list: Array<HashMap<string, string>> = [];
    let writeOnPosSafe: HashMap<number, HashMap<number, number>> = new HashMap<number, HashMap<number, number>>();

    let sectors: HashSet<number> = new HashSet<number>();
    for (let sector of this.mDumpWithPos.keys()) {
      if (keyMap.getIndexOfKey(sector) < 0) {
        this.addToList(list, '扇区: ' + sector, '密钥(A和B)未知');
      } else {
        sectors.add(sector);
      }
    }

    for (let sector of sectors) {
      if (!writeOnPos.get(sector)) {
        this.addToList(list, '扇区: ' + sector,
          '无效的访问条件或死扇区:(');
        continue;
      }
      let keys = keyMap.get(sector);
      let blocks = this.mDumpWithPos.get(sector).keys();
      for (let block of blocks) {
        let isSafeForWriting = true;
        let position = '扇区: ' + sector + ', 块' + ': ' + block;

        if (!this.isChecked &&
          sector === 0 && block === 0) {
          continue;
        }

        let writeInfo = writeOnPos.get(sector).get(block);
        switch (writeInfo) {
          case 0:
            this.addToList(list, position, '只读块');
            isSafeForWriting = false;
            break;
          case 1:
            if (!keys || keys.length < 1 || !keys[0]) {
              this.addToList(list, position, '写访问密钥(A)未知');
              isSafeForWriting = false;
            }
            break;
          case 2:
            if (!keys || keys.length < 2 || !keys[1]) {
              this.addToList(list, position, '写访问密钥(B)未知');
              isSafeForWriting = false;
            }
            break;
          case 3:
            writeInfo = (keys && keys.length > 0 && keys[0]) ? 1 : 2;
            break;
          case 4:
            if (!keys || keys.length < 1 || !keys[0]) {
              this.addToList(list, position, '写访问密钥(A)未知');
              isSafeForWriting = false;
            } else {
              this.addToList(list, position, '访问条件为只读');
            }
            break;
          case 5:
            if (!keys || keys.length < 2 || !keys[1]) {
              this.addToList(list, position, '写访问密钥(B)未知');
              isSafeForWriting = false;
            } else {
              this.addToList(list, position, '访问条件为只读');
            }
            break;
          case 6:
            if (!keys || keys.length < 2 || !keys[1]) {
              this.addToList(list, position, '写访问密钥(B)未知');
              isSafeForWriting = false;
            } else {
              this.addToList(list, position, '密钥(A和B)只读');
            }
            break;
          case -1:
            this.addToList(list, position, '发生了一些奇怪的错误:(');
            isSafeForWriting = false;
        }
        if (isSafeForWriting) {
          if (!writeOnPosSafe.get(sector)) {
            let blockInfo: HashMap<number, number> = new HashMap<number, number>();
            blockInfo.set(block, writeInfo);
            writeOnPosSafe.set(sector, blockInfo);
          } else {
            writeOnPosSafe.get(sector).set(block, writeInfo);
          }
        }
      }
    }

    await this.writeDump(tagInfo, writeOnPosSafe, keyMap, actionModel);
  }

  addToList(list: Array<HashMap<string, string>>, position: string, reason: string) {
    let item: HashMap<string, string> = new HashMap<string, string>();
    item.set('position', position);
    item.set('reason', reason);
    list.push(item);
  }

  formatFail(code: number, msg: string, actionModel: ActionModel) {
    getNavPathStack().pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_FORMAT, RTYPE.RTYPE_FORMAT_FAIL, actionModel));
  }

  async writeDump(tagInfo: tag.TagInfo, writeOnPos: HashMap<number, HashMap<number, number>>,
    keyMap: PlainArray<number[][]>, actionModel: ActionModel) {
    if (writeOnPos.length === 0) {
      this.formatFail(100, '没有数据可写', actionModel);
      return;
    }

    let reader: MCReader | undefined = Common.checkForTagAndCreateReader(tagInfo);
    if (!reader) {
      return;
    }

    for (let sector of writeOnPos.keys()) {
      let keys = keyMap.get(sector);
      for (let block of writeOnPos.get(sector).keys()) {
        let writeKey: number[] = [];
        let useAsKeyB = true;
        let wi = writeOnPos.get(sector).get(block);
        if (wi === 1 || wi === 4) {
          writeKey = keys[0];
          useAsKeyB = false;
        } else if (wi === 2 || wi === 5 || wi === 6) {
          writeKey = keys[1];
        }

        let result = 0;
        for (let i = 0; i < 2; i++) {
          let result: number =
            await reader.writeBlock(sector, block, this.mDumpWithPos.get(sector).get(block), writeKey, useAsKeyB);
          if (result === 0) {
            break;
          }
        }

        if (result !== 0) {
          getNavPathStack()
            .pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_FORMAT, RTYPE.RTYPE_FORMAT_FAIL, actionModel));
          return;
        }
      }
    }
    reader.close();

    getNavPathStack().pushPathByName('ResultPage', new ResultModel(ACTION_TYPE.ACTION_FORMAT, RTYPE.RTYPE_FORMAT_SUCCESS, actionModel));
  }
};