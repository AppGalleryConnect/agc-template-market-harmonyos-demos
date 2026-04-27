import { tag } from '@kit.ConnectivityKit';
import { PlainArray } from '@kit.ArkTS';
import Common from '../Common';
import MCReader from '../MCReader';

export default class KeyMapCreator {
  mProgressStatus: number = 0;
  mIsCreatingKeyMap: boolean = false;
  mFirstSector: number = 0;
  mLastSector: number = 0;

  async onCreateKeyMap(tagInfo: tag.TagInfo) {
    let reader = Common.checkForTagAndCreateReader(tagInfo);
    if (!reader) {
      return;
    }

    let numberOfLoadedKeys = reader.setKeyFile('key-files/std.keys');
    if (numberOfLoadedKeys < 1) {
      reader.close();
      return;
    }
    this.mFirstSector = 0;
    this.mLastSector = reader.getSectorCount() - 1;
    if (!reader.setMappingRange(this.mFirstSector, this.mLastSector)) {
      reader.close();
      return;
    }
    this.mProgressStatus = -1;
    this.mIsCreatingKeyMap = true;
    await this.createKeyMap(reader);
  }

  async createKeyMap(reader: MCReader) {
    while (this.mProgressStatus < this.mLastSector) {
      this.mProgressStatus = await reader.buildNextKeyMapPart();
      if (this.mProgressStatus === -1 || !this.mIsCreatingKeyMap) {
        break;
      }
    }
    reader.close();
    if (this.mIsCreatingKeyMap && this.mProgressStatus !== -1) {
      this.keyMapCreated(reader);
    }
    this.mIsCreatingKeyMap = false;
  }

  keyMapCreated(reader: MCReader) {
    if (reader.getKeyMap().length === 0) {
      Common.setKeyMap(new PlainArray());
    } else {
      Common.setKeyMap(reader.getKeyMap());
    }
  }
};