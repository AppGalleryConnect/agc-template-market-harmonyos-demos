import { FormatUtil } from 'commonlib';
import { VipGradeItem } from 'network';

@ObservedV2
export class VipGradeItemModel implements VipGradeItem {
  @Trace gradeName: string = '';
  @Trace gradeNum: number = 0;
  @Trace gradeCover: ResourceStr = '';
  @Trace introTitle: string = '';
  @Trace introText: string = '';
  @Trace equityList: EquityItem[] = [];

  constructor(item?: VipGradeItem) {
    if (item) {
      this.gradeName = item.gradeName;
      this.gradeNum = item.gradeNum;
      this.gradeCover = FormatUtil.getImgResource(item.gradeCover as string);
      this.introTitle = item.introTitle;
      this.introText = item.introText;
      this.equityList = item.equityList.map((equityItem) => {
        return {
          id: equityItem.id,
          equityName: equityItem.equityName,
          equityIcon: equityItem.equityIcon.length ?
          FormatUtil.getImgResource(equityItem.equityIcon) :
          equityItem.equityIcon,
          equityIntro: equityItem.equityIntro,
        } as EquityItem;
      });
    }
  }

  public update(item: VipGradeItem) {
    this.gradeName = item.gradeName;
    this.gradeNum = item.gradeNum;
    this.gradeCover = FormatUtil.getImgResource(item.gradeCover as string);
    this.introTitle = item.introTitle;
    this.introText = item.introText;
    this.equityList = item.equityList;
  }
}

export interface EquityItem {
  id: number;
  equityName: string;
  equityIcon: string;
  equityIntro: string;
}
