import { AttractionsInfo } from 'types';
import { https, mapperAttractionsInfo } from 'network';

@ObservedV2
export class GuideVM {
  // 默认展示景点列表
  @Trace attractionsInfo: AttractionsInfo = new AttractionsInfo();
  public static _instance: GuideVM;

  public static get instance() {
    if (!GuideVM._instance) {
      GuideVM._instance = new GuideVM();
    }
    return GuideVM._instance;
  }

  getAttractionList() {
    https.getAttractionList().then((res) => {
      this.attractionsInfo = mapperAttractionsInfo(res.data);
    });
  }
}