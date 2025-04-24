import { FormatUtil } from 'commonlib';
import { GetRoomDetailResp, RoomInfoLabel } from 'network';
import { MappedRoomDetail } from '../models/MappedRoomInfo';

export function mapRoomInfoResponse(roomInfo: GetRoomDetailResp): MappedRoomDetail {
  let mappedRoomInfo: MappedRoomDetail = {
    name: roomInfo.roomName ?? '',
    amenities: roomInfo.amenities ?? '',
    beds: roomInfo.beds ?? '',
    mediaTech: roomInfo.mediaTech ?? '',
    foodDrink: roomInfo.foodDrink ?? '',
    toiletries: roomInfo.toiletries ?? '',
    bath: roomInfo.bath ?? '',
    other: roomInfo.other ?? '',
    textTags: roomInfo.roomLabel ? roomInfo.roomLabel.split('|') : [],
    iconTags: convertLabelList(roomInfo.labelList ?? []),
    banners: convertBannerList(roomInfo.bannerList ?? []),
  };
  return mappedRoomInfo;
}

function convertBannerList(bannerList: string[]): ResourceStr[] {
  let banners: ResourceStr[] = [];
  for (let banner of bannerList) {
    banners.push(FormatUtil.getImgResource(banner));
  }
  return banners;
}

function convertLabelList(labelList: RoomInfoLabel[]): [ResourceStr, string][] {
  let iconTags: [ResourceStr, string][] = [];
  for (let label of labelList) {
    if (label.resourceName && label.resourceUrl) {
      iconTags.push([FormatUtil.getImgResource(label.resourceUrl), label.resourceName]);
    }
  }
  return iconTags;
}
