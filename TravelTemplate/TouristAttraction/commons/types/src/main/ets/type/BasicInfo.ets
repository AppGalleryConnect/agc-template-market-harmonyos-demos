export interface BasicInfo {
  /*地点Id*/
  siteId: string
  /*名称*/
  name: string;
  /*位置*/
  address: string;
  /*起步价格*/
  startPrice: number;
  /*联系电话*/
  phone: string;
  /*banner图片*/
  banner: ResourceStr;
  /*banner图片*/
  banners: ResourceStr[];
  /*经度*/
  longitude: number;
  /*纬度*/
  latitude: number;
  /*详情*/
  detail: string
  /*距离*/
  distance: number
  /*评论数量*/
  comments: number
  /*评分*/
  rating: number
}