export interface EquityItem {
  id: number;
  equityName: string;
  equityIcon: string;
  equityIntro: string;
}

export interface VipGradeItem {
  gradeName: string;
  gradeNum: number;
  gradeCover: ResourceStr;
  introTitle: string;
  introText: string;
  equityList: EquityItem[];
}

export type GetGradeListResp = VipGradeItem[];
