export interface ScenicBasicInfo {
  /*名称*/
  name: string,

  /*位置*/
  location: string,

  /*经度*/
  longitude: number,

  /*纬度*/
  latitude: number,

  /*封面图片*/
  banner: ResourceStr,

  /*介绍*/
  introduction: string,

  /*咨询电话*/
  consultPhone: string,

  /*轮播图列表*/
  detailImages: ResourceStr[]

  /*标签列表*/
  labels: string[]
}