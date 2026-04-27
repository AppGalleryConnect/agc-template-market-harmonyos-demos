

// 额外分享信息所需处理的数据
@ObservedV2
export class ShareExtureInfoViewModel {
  @Trace usefullTime?: string // 有效时间
  usefullTimeId?: number // 有效时间id
  @Trace autoInputCode?: boolean // 是否自动填充提取码
  @Trace randomCode?: string // 随机提取码

}