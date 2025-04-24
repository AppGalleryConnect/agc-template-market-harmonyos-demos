import { AttractionsInfo } from 'types';
import { PersistenceV2 } from '@kit.ArkUI';

@ObservedV2
export class AttractionUtil {
  private static attractionPersist: AttractionsInfo =
    PersistenceV2.connect(AttractionsInfo, 'AttractionsInfo', () => new AttractionsInfo())!;

  static setAttraction(attractions: AttractionsInfo) {
    AttractionUtil.attractionPersist = attractions
  }

  static getAttraction() {
    return AttractionUtil.attractionPersist;
  }
}