import { Instructions } from './Index';

export class RoomType {
  /*主键ID */
  id: number = 0;
  /*房型名称 */
  roomTypeName: string = '';
  /*房型banner图地址 */
  roomTypeBanner: string | Resource = '';
  /*房型详细图片列表 */
  roomTypeDetailImageList: string[] | Resource[] = [];
  /*标签列表 */
  labelList: string[] = [];
  /*入住人数限制 */
  occupancyLimit: number = 0;
  /*房型介绍 */
  introduction: string = '';
  /*房型床信息列表 */
  roomTypeBedList: RoomTypeBed[] = [];
  /*房型价格列表 */
  roomTypePriceList: RoomTypePrice[] = [];
  /*是否推荐房型 */
  isRecommended: boolean = false;
  /*房型设施服务 */
  instructions: Instructions = {
    foundations: [],
    reservation: [],
    checkOut: [],
  };
}

export interface RoomTypeBed {
  /*主键ID */
  id: number;

  /*床类型 */
  bedTypeCode: string;

  /*床类型名称 */
  bedTypeName: string;

  /*数量 */
  bedCount: number;

  /*房型ID */
  roomTypeId: number;
}

export interface RoomTypePrice {
  /*主键ID */
  id: number;

  /*房型ID */
  roomTypeId: number;

  /*原价 */
  originalPrice: number;

  /*实付价格 */
  actualPrice: number;

  /*价格时间 */
  roomPriceDay: string;
}

