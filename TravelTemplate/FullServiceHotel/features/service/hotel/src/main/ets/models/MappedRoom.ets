export interface MappedRoom {
  id: number;
  name: string;
  basePrice: number | string;
  cover: PixelMap | ResourceStr | DrawableDescriptor;
  tags: string[];
  code: string;
  shopId: number | null;
  mappedRoomRateList: MappedRoomRate[];
}

export interface MappedRoomRate {
  name: string;
  rate: number | string;

  // remainingRooms: number;
  // currency: string;
  // isPrepaid: string;
  code: string;
}
