import {
  GetAttractionDetailResp,
  GetAttractionsInfoResp,
  GetBulletinDetailResp,
  GetBulletinListResp,
  GetHomeInfoResp,
} from 'network';
import { AttractionInfo, NoteInfo, ToiletInfo, AttractionsInfo } from 'types';
import { BulletinInfo } from '../model/BulletinInfo';
import { site } from '@kit.MapKit';
import { ParkingSlotInfo } from '../model/ParkingSlotInfo';
import { LocationUtil } from 'common';

export function mapperAttractionInfo(attractionDetailResp: GetAttractionDetailResp) {
  let attractionInfo = new AttractionInfo();
  attractionInfo.attractionId = attractionDetailResp.attractionId;
  attractionInfo.labels = attractionDetailResp.labels;
  attractionInfo.detailImages = attractionDetailResp.detailImages;
  attractionInfo.brief = attractionDetailResp.brief;
  attractionInfo.name = attractionDetailResp.name;
  attractionInfo.location = attractionDetailResp.location;
  attractionInfo.longitude = attractionDetailResp.longitude;
  attractionInfo.latitude = attractionDetailResp.latitude;
  attractionInfo.banner = attractionDetailResp.banner;
  attractionInfo.introduction = attractionDetailResp.introduction;
  attractionInfo.consultPhone = attractionDetailResp.consultPhone;
  attractionInfo.audio = attractionDetailResp.audio;
  return attractionInfo;
}

export function mapperBulletinInfo(bulletinDetailResp: GetBulletinDetailResp) {
  let bulletinInfo = new BulletinInfo();
  bulletinInfo.id = bulletinDetailResp.id;
  bulletinInfo.title = bulletinDetailResp.title;
  bulletinInfo.detail = bulletinDetailResp.detail;
  bulletinInfo.releaseTime = bulletinDetailResp.releaseTime;
  bulletinInfo.banner = bulletinDetailResp.banner;
  bulletinInfo.detailImages = bulletinDetailResp.detailImages;
  return bulletinInfo;
}

export function mapperAttractionsInfo(attractionListResp: GetAttractionsInfoResp) {
  let attractionsInfo: AttractionsInfo = new AttractionsInfo();
  attractionsInfo.banners = attractionListResp.banners;
  attractionListResp.attractions.forEach(item => {
    let attractionInfo = new AttractionInfo();
    attractionInfo.attractionId = item.attractionId;
    attractionInfo.labels = item.labels;
    attractionInfo.detailImages = item.detailImages;
    attractionInfo.name = item.name;
    attractionInfo.banner = item.banner;
    attractionInfo.isHot = item.isHot;
    attractionInfo.longitude = item.longitude;
    attractionInfo.latitude = item.latitude;
    attractionInfo.icon = item.icon;
    attractionInfo.audio = item.audio;
    attractionsInfo.attractions.push(attractionInfo);
  });
  return attractionsInfo;
}

export function mapperBulletinList(bulletinListResp: GetBulletinListResp) {
  let bulletinList: BulletinInfo[] = [];
  bulletinListResp.forEach(item => {
    let bulletinInfo = new BulletinInfo();
    bulletinInfo.id = item.id;
    bulletinInfo.title = item.title;
    bulletinInfo.releaseTime = item.releaseTime;
    bulletinList.push(bulletinInfo);
  });
  return bulletinList;
}

export function mapperHotNote(rollupInfo: GetHomeInfoResp) {
  let hotNoteList: NoteInfo[] = [];
  rollupInfo.hotNotes.forEach(item => {
    let hotNoteInfo = new NoteInfo();
    hotNoteInfo.noteId = item.noteId;
    hotNoteInfo.name = item.name;
    hotNoteInfo.banner = item.banner;
    hotNoteList.push(hotNoteInfo);
  });
  return hotNoteList;
}

export function mapperHotAttraction(rollupInfo: GetHomeInfoResp) {
  let hotAttractionList: AttractionInfo[] = [];
  rollupInfo.hotAttractions.forEach(item => {
    let hotAttractionInfo = new AttractionInfo();
    hotAttractionInfo.attractionId = item.attractionId;
    hotAttractionInfo.name = item.name;
    hotAttractionInfo.banner = item.banner;
    hotAttractionInfo.detailImages = item.detailImages;
    hotAttractionInfo.labels = item.labels;
    hotAttractionList.push(hotAttractionInfo);
  });
  return hotAttractionList;
}

export function mapperParkingSlot(sites: site.Site[]) {
  let parkingSlotList: ParkingSlotInfo[] = [];
  sites.forEach(site => {
    let parkingSlotInfo = new ParkingSlotInfo();
    parkingSlotInfo.siteId = site.siteId;
    parkingSlotInfo.name = site.name ?? '';
    parkingSlotInfo.longitude = site.location?.longitude ?? LocationUtil.getLocationInfo().longitude;
    parkingSlotInfo.latitude = site.location?.latitude ?? LocationUtil.getLocationInfo().latitude;
    parkingSlotInfo.distance =
      LocationUtil.calDistance(parkingSlotInfo.longitude,
        parkingSlotInfo.latitude);
    parkingSlotInfo.icon = site.poi?.icon ?? '';
    parkingSlotList.push(parkingSlotInfo);
  });
  return parkingSlotList.sort((a, b) => a.distance - b.distance);
}