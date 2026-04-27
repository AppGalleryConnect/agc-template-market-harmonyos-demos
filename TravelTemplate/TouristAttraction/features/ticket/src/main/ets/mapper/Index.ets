import { GetTicketDetailResp, GetTicketListResp, GetTouristListResp } from 'network';
import { TouristInfo } from 'types';
import { TicketInfo } from '../model/TicketInfo';

export function mapperTicketInfo(getTicketInfoResp: GetTicketDetailResp) {
  let ticketInfo = new TicketInfo();
  ticketInfo.ticketId = getTicketInfoResp.ticketId;
  ticketInfo.ticketName = getTicketInfoResp.ticketName;
  ticketInfo.basicTicketTypeId = getTicketInfoResp.basicTicketTypeId;
  ticketInfo.banner = getTicketInfoResp.banner;
  ticketInfo.labels = getTicketInfoResp.labels;
  ticketInfo.toKnow = getTicketInfoResp.toKnow;
  ticketInfo.phone = getTicketInfoResp.phone;
  ticketInfo.description = getTicketInfoResp.description;
  ticketInfo.ticketType = getTicketInfoResp.ticketType;
  return ticketInfo;
}

export function mapperTicketList(getTicketListResp: GetTicketListResp) {
  let ticketList: TicketInfo[] = [];
  getTicketListResp.forEach(item => {
    let ticketInfo = new TicketInfo();
    ticketInfo.ticketId = item.ticketId;
    ticketInfo.ticketName = item.ticketName;
    ticketInfo.basicTicketTypeId = item.basicTicketTypeId;
    ticketInfo.banner = item.banner;
    ticketInfo.labels = item.labels;
    ticketInfo.ticketType = item.ticketType;
    ticketList.push(ticketInfo);
  });
  return ticketList;
}

export function mapTouristInfo(getTouristListResp: GetTouristListResp) {
  let touristList: TouristInfo[] = [];
  getTouristListResp.forEach((item => {
    let tourist: TouristInfo = new TouristInfo();
    tourist.id = item.id;
    tourist.name = item.name;
    tourist.phone = item.phone;
    tourist.cardType = item.cardType;
    tourist.cardNo = item.cardNo;
    tourist.isChecked = item.isChecked;
    touristList.push(tourist);
  }));
  return touristList;
}