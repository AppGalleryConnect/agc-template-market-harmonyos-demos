import { HomeDetailResp } from 'network';
import { CarouselImage, RoomType, RoomTypeBed, RoomTypePrice, HotelInfo } from 'type';

export function mapHotelInfoResponse(response: HomeDetailResp): HotelInfo {
  let hotelInfo: HotelInfo = new HotelInfo();
  hotelInfo.appInfo = response.data.appInfo;
  hotelInfo.carouselImageList = mapCarouselImageList(response.data.carouselImageList);
  hotelInfo.roomTypeList = mapRoomTypeList(response.data.roomTypeList);
  return hotelInfo;
}

function mapCarouselImageList(carouselImageResp: CarouselImage[]): CarouselImage[] {
  const respList: CarouselImage[] = [];
  carouselImageResp.forEach((item: CarouselImage) => {
    const carouselImageItem: CarouselImage = {
      id: item.id,
      image: item.image,
    };
    respList.push(carouselImageItem);
  });
  return respList;
}

function mapRoomTypeList(roomTypeResp: RoomType[]): RoomType[] {
  const roomTypeList: RoomType[] = [];
  const roomTypeBedList: RoomTypeBed[] = [];
  const roomTypePriceList: RoomTypePrice[] = [];

  roomTypeResp.forEach((item: RoomType) => {
    const roomTypeBedResp: RoomTypeBed[] = item?.roomTypeBedList;
    if (roomTypeBedResp) {
      roomTypeBedResp.forEach((bedItem: RoomTypeBed) => {
        const roomTypeBedItem: RoomTypeBed = {
          id: bedItem.id,
          bedTypeCode: bedItem.bedTypeCode,
          bedTypeName: bedItem.bedTypeName,
          bedCount: bedItem.bedCount,
          roomTypeId: bedItem.roomTypeId,
        };
        roomTypeBedList.push(roomTypeBedItem);
      });
    }

    const roomTypePriceResp: RoomTypePrice[] = item?.roomTypePriceList;
    if (roomTypePriceResp) {
      roomTypePriceResp.forEach((priceItem: RoomTypePrice) => {
        const roomTypePriceItem: RoomTypePrice = {
          id: priceItem.id,
          roomTypeId: priceItem.roomTypeId,
          originalPrice: priceItem.originalPrice,
          actualPrice: priceItem.actualPrice,
          roomPriceDay: priceItem.roomPriceDay,
        };
        roomTypePriceList.push(roomTypePriceItem);
      });
    }

    const rootTypeItem: RoomType = {
      id: item.id,
      roomTypeName: item.roomTypeName,
      roomTypeBanner: item.roomTypeBanner,
      roomTypeDetailImageList: item.roomTypeDetailImageList,
      labelList: item.labelList,
      introduction: item.introduction,
      occupancyLimit: item.occupancyLimit,
      roomTypeBedList: roomTypeBedList.length ? item.roomTypeBedList : [],
      roomTypePriceList: roomTypePriceList.length ? item.roomTypePriceList : [],
      isRecommended: item.isRecommended,
      instructions: item.instructions,
    };

    roomTypeList.push(rootTypeItem);
  });
  return roomTypeList;
}
