import { ScenicBasicInfo } from 'types';
import { AttractionListItem } from './GetAttractionListResp';
import { NoteListItem } from './GetNoteListResp';

export interface GetHomeInfoResp extends ScenicBasicInfo {
  /*当前日期*/
  currentDate?: Date,

  /*天气ID*/
  weatherId: WeatherType,

  /*当前温度*/
  temperature: number,

  /*空气质量Id*/
  atmosphereId: AtmosphereType,

  /*当前游客数*/
  currentVisitors: number,

  /*当日累计游客数*/
  currentDayVisitors: number,

  /*最大游客数*/
  maxVisitors: number,

  /*瞬时游客数*/
  maxInstantVisitors: number,

  /*开放时间*/
  openTime: string,

  /*售票时间*/
  ticketTime: string,

  /*救援电话*/
  rescuePhone: string,

  /*投诉电话*/
  complaintPhone: string,

  /*热门景点*/
  hotAttractions: AttractionListItem[],

  /*停车场信息*/
  parks: ParkInfo[],

  /*游记攻略*/
  hotNotes: NoteListItem[],
}

export interface ParkInfo {
  parkId: number,
  name: string,
  spaces: number,
  longitude: number,
  latitude: number,
}

export enum WeatherType {
  CLOUDY = '多云',
  SUNNY = '晴',
  DRIZZLE = '小雨',
  MODERATE = '中雨',
  DOWNPOUR = '大雨'
}

export enum AtmosphereType {
  GOOD = '良好',
  GENERAL = '一般',
  MILD_POLLUTION = '轻度污染',
  MODERATE_POLLUTION = '中度污染',
  HEAVY_POLLUTION = '重度污染'
}