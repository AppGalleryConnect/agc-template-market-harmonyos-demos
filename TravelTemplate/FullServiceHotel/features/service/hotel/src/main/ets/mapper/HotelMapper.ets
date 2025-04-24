import { FormatUtil, LocationUtil } from 'commonlib';

import { mapCommon } from '@kit.MapKit';
import { MappedHotel } from '../models/MappedHotel';
import { HotelItem } from 'network';

export function mapHotelInfoListResponse(hotelInfoList: HotelItem[], gcj02LatLng?: mapCommon.LatLng): MappedHotel[] {
  return hotelInfoList
    .sort((a, b) => {
      const sortA = a.sortNum ?? Infinity;
      const sortB = b.sortNum ?? Infinity;
      return sortA - sortB;
    })
    .map(
      (hotel) =>
        ({
          id: hotel.id ?? -1,
          name: hotel.name ?? '',
          address: hotel.address ?? '',
          distanceInMeters: convertDistanceDisplay(gcj02LatLng, hotel.coordinate),
          phoneNumber: hotel.tel ?? '',
          basePrice:
            hotel.minPrice && typeof hotel.minPrice === 'number' && hotel.minPrice > 0 ? hotel.minPrice : '---',
          tags: hotel.labelList ?? [],
          cover: FormatUtil.getImgResource(hotel.imageUrl),
          orgUnitNo: hotel.orgUnitNo ?? '',
        }) as MappedHotel,
    );
}

function convertDistanceDisplay(
  fromLatLng: mapCommon.LatLng | null | undefined,
  coordinate: string | null | undefined,
): string {
  if (!fromLatLng) {
    return '--km';
  }
  const toLatLng: mapCommon.LatLng | null = coordinate ? LocationUtil.parseLatLng(coordinate) : null;
  if (!toLatLng) {
    return '--km';
  }
  const distanceInMeters: number = LocationUtil.calculateDistance(fromLatLng, toLatLng);
  return FormatUtil.distanceDisplay(distanceInMeters);
}
