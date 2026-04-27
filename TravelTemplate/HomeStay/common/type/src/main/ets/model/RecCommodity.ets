export interface RecCommodity {
  /*主键ID */
  id: number;
  /*商店ID */
  shopId: number;
  /*商品编号 */
  goodsSn: string;
  /*商品名称 */
  goodsName: string;
  /*商品页面商品图片 */
  banner: string | Resource;
  /*商品宣传图片列表，采用JSON数组格式 */
  imagesJson: string;
  /*商品宣传图片列表 */
  imageList: string[];
  /*规格 */
  specification: string | [];
  /*专柜价格 */
  counterPrice: number;
  /*零售价格 */
  retailPrice: number;
}