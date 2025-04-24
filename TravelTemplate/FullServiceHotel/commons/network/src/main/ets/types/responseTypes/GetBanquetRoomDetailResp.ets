export interface SiteInformationItem {
  id: number;
  content: string;
  siteName: string;
}

export interface LayoutMethodItem {
  icon: string;
  id: number;
  layoutName: string;
  personNum: string;
}

export interface GetBanquetRoomDetailResp {
  id: number;
  banquetName: string;
  banquetTel: string;
  labelList: string[];
  introduce: string;
  bannerList: ResourceStr[];
  profile: string;
  siteInformation: SiteInformationItem[];
  layoutMethod: LayoutMethodItem[];
}
