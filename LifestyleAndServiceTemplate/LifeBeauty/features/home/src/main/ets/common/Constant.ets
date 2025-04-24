export interface ImgDesc {
  src: ResourceStr;
  desc: ResourceStr;
}

export enum STORE_STATUS {
  IN = 1, // 营业中
  OUT = 0, // 已打样
}

export const TAG_CONSTANT_LIST: ImgDesc[] = [
  { src: $r('app.media.icon_service_promise'), desc: $r('app.string.tag_service') },
  { src: $r('app.media.icon_zero'), desc: $r('app.string.tag_zero_pay') },
  { src: $r('app.media.icon_chain'), desc: $r('app.string.tag_chain_store') },
];

export enum RuleID {
  STORE_CARD_ID = 'store_card_id',
  BANNER_ID = 'banner_id',
  GOOD_LIST_ID = 'good_list_id',
  DIVIDER_ID = 'dividerId',
}

export class ConstantsHome {
  static MAX_CONTACT_NAME_LENGTH: number = 10;
  static MIN_NUMS: number = 1;
  static MAX_NUMS: number = 9;
  static MAX_REMARK_LENGTH = 50;
}

export const STORE_CARD_RULE: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': RuleID.BANNER_ID, 'align': VerticalAlign.Center },
  'left': { 'anchor': RuleID.BANNER_ID, 'align': HorizontalAlign.Start },
};

export const LIST_RULE: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': RuleID.BANNER_ID, 'align': VerticalAlign.Center },
  'left': { 'anchor': RuleID.BANNER_ID, 'align': HorizontalAlign.Start },
};

export const ALIGN_RULE_COUNT: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
};

export const ALIGN_RULE_DIVIDER: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': '__container__', 'align': HorizontalAlign.Center },
};

export const ALIGN_RULE_CATEGORY: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': RuleID.DIVIDER_ID, 'align': HorizontalAlign.Start },
};

export const WEEK_LABELS: ResourceStr[] = [
  $r('app.string.week_weekday'),
  $r('app.string.week_monday'),
  $r('app.string.week_tuesday'),
  $r('app.string.week_wednesday'),
  $r('app.string.week_thursday'),
  $r('app.string.week_friday'),
  $r('app.string.week_saturday'),
  $r('app.string.week_today'),
  $r('app.string.week_tomorrow'),
];
