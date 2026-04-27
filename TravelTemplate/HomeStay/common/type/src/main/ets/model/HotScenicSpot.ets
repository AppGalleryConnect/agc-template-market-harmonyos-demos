export interface HotScenicSpot {
  /*主键ID */
  id: number;
  /*景区名称 */
  name: string;
  /*景区分类名称 */
  categoryName: string;
  /*景区分类banner图地址 */
  categoryBanner: string | Resource;
  /*景区详细图片列表，采用JSON数组格式 */
  categoryDetailImagesJson: string;
  /*景区详细图片列表 */
  categoryDetailImageList: string[];
  /*标签列表 */
  labelList: string[];
  /*是否当季热门,0：否 1：是 */
  isHot: number;
}