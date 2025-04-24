export interface MappedHotel {
  id: number;
  name: string;
  address: string;
  distanceInMeters: string;
  phoneNumber: string;
  basePrice: number | string;
  tags: string[];
  cover: PixelMap | ResourceStr | DrawableDescriptor;
  orgUnitNo: string;
}
