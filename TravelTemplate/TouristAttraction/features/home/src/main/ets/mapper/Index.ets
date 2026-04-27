import { AttractionInfo, RouteModel } from 'module_base';
import {
  GetAttractionDetailResp,
  GetBulletinDetailResp,
  GetBulletinListResp,
  GetCommodityDetailResp,
  GetCommodityListResp,
  GetHomeInfoResp,
  GetNoteDetailResp,
  GetNoteListResp,
  GetRouteLineDetailResp,
  GetRouteLineListResp,
} from 'network';
import { NoteInfo } from 'types';
import { BulletinInfo } from '../model/BulletinInfo';
import { CommodityInfo } from '../model/CommodityInfo';
import { RouteLineInfo } from '../model/RouteLineInfo';

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

export function mapperRouteLineList(getRouteListResp: GetRouteLineListResp) {
  let routeLineList: RouteModel[] = [];
  getRouteListResp.forEach(item => {
    let routeLine = new RouteModel();
    routeLine.routeId = item.routeId;
    routeLine.routeName = item.routeName;
    routeLine.routeDistance = item.routeDistance;
    routeLine.duration = item.duration;
    routeLine.routeBanner = item.routeBanner;
    routeLine.attractionIds = item.attractionIds;
    routeLine.brief = item.brief ?? '';
    routeLineList.push(routeLine);
  });
  return routeLineList;
}

export function mapperRouteLineDetail(getRouteDetailResp: GetRouteLineDetailResp) {
  let routeLine = new RouteLineInfo();
  let attractions: AttractionInfo [] = [];
  routeLine.routeId = getRouteDetailResp.routeId;
  routeLine.routeName = getRouteDetailResp.routeName;
  routeLine.routeDistance = getRouteDetailResp.routeDistance;
  routeLine.duration = getRouteDetailResp.duration;
  routeLine.routeBanner = getRouteDetailResp.routeBanner;
  routeLine.labels = getRouteDetailResp.labels;
  routeLine.brief = getRouteDetailResp.brief;
  routeLine.introduction = getRouteDetailResp.introduction;
  getRouteDetailResp.attractions.forEach((attraction) => {
    let attractionInfo = new AttractionInfo();
    attractionInfo.attractionId = attraction.attractionId;
    attractionInfo.labels = attraction.labels;
    attractionInfo.detailImages = attraction.detailImages;
    attractionInfo.name = attraction.name;
    attractionInfo.banner = attraction.banner;
    attractions.push(attractionInfo);
  });
  routeLine.attractions = attractions;
  return routeLine;
}

export function mapperCommodityList(getCommodityListResp: GetCommodityListResp) {
  let commodityList: CommodityInfo[] = [];
  getCommodityListResp.forEach(item => {
    let commodityInfo = new CommodityInfo();
    commodityInfo.commodityId = item.commodityId;
    commodityInfo.banner = item.banner;
    commodityInfo.basicSpu = item.basicSpu;
    commodityInfo.name = item.name;
    commodityInfo.spuInfo = item.spuInfo;
    commodityList.push(commodityInfo);
  });
  return commodityList;
}

export function mapperCommodityDetail(getCommodityDetailResp: GetCommodityDetailResp) {
  let commodityInfo = new CommodityInfo();
  commodityInfo.commodityId = getCommodityDetailResp.commodityId;
  commodityInfo.banner = getCommodityDetailResp.banner;
  commodityInfo.basicSpu = getCommodityDetailResp.basicSpu;
  commodityInfo.name = getCommodityDetailResp.name;
  commodityInfo.spuInfo = getCommodityDetailResp.spuInfo;
  commodityInfo.banners = getCommodityDetailResp.banners;
  commodityInfo.introduction = getCommodityDetailResp.introduction;
  commodityInfo.detailImages = getCommodityDetailResp.detailImages;
  commodityInfo.detail = getCommodityDetailResp.detail;
  return commodityInfo;
}

export function mapperNoteInfo(getNoteDetailResp: GetNoteDetailResp) {
  let noteInfo = new NoteInfo;
  noteInfo.noteId = getNoteDetailResp.noteId;
  noteInfo.name = getNoteDetailResp.name;
  noteInfo.banner = getNoteDetailResp.banner;
  noteInfo.banners = getNoteDetailResp.banners;
  noteInfo.detail = getNoteDetailResp.detail;
  noteInfo.createTime = getNoteDetailResp.createTime;
  return noteInfo;
}

export function mapperNoteList(getNoteListResp: GetNoteListResp) {
  let noteList: NoteInfo[] = [];
  getNoteListResp.forEach(item => {
    let noteInfo = new NoteInfo();
    noteInfo.noteId = item.noteId;
    noteInfo.name = item.name;
    noteInfo.banner = item.banner;
    noteList.push(noteInfo);
  });
  return noteList;
}