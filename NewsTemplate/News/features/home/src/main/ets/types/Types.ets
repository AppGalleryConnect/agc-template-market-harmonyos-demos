export interface TabListItem {
  label: string;
  icon: Resource;
  iconChecked: Resource;
}

export interface CommentListModel {
  keywordList: KeywordItem[];
  commentList: CommentItem[];
}

export interface KeywordItem {
  desc: string;
  count: number;
}

export interface CommentItem {
  avatar?: ResourceStr;
  userName: string;
  date: string;
  location: string;
  star: number;
  desc: string;
}

export interface CommentItemResp {
  commentMakerIcon: ResourceStr | null;
  commentMakerName: string;
  commentTime: string;
  hotelName: string;
  score: number;
  comment: string;
  replyInfos: null | string;
}

export interface SubmitComment {
  location: string;
  totalRate: number;
  detailRate: DetailRate;
  arrivalType: ArrivalType | undefined;
  desc: string;
  isAnonymous: number;
  enableImg: boolean;
  img?: string;
}

export interface DetailRate {
  service: number;
  environment: number;
  device: number;
  experience: number;
}

export interface ArrivalType {
  label: string;
}

export interface CommentForSubmit {
  comment: string;
  environmentScore: number;
  facilityScore: number;
  hotelId: number;
  hotelType: string;
  isAnonymous: number;
  overallScore: number;
  recommendScore: number;
  serviceScore: number;
  tenantId: number;
  tourType: string;
  userId: number;
}
