import { AppStorageV2 } from '@kit.ArkUI';
import { TicketOrderList } from '../model/TicketOrderInfo';

@ObservedV2
export class TicketOrderUtil {
  private static ticketOrderList: TicketOrderList =
    AppStorageV2.connect(TicketOrderList, 'ticketOrderList', () => new TicketOrderList())!;

    public static getTicketOrderList() {
      return TicketOrderUtil.ticketOrderList
    }
}