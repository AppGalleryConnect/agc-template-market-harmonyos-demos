import { AccountUtil } from 'account';
import { https } from 'network';
import { Passenger } from 'type';
import { LazyDataSource } from 'util';
import { promptAction } from '@kit.ArkUI';

@ObservedV2
export class GuestPageVM {
  @Trace openId: string | undefined = AccountUtil.getOpenId();
  @Trace passengers: Passenger[] = [];
  @Trace passenger: Passenger = new Passenger();
  private static _instance: GuestPageVM;

  mapPassengerInfo(list: Passenger[]) {
    let passengers: Passenger[] = [];
    list.forEach((item: Passenger) => {
      let passenger: Passenger = {
        passengerId: item.passengerId,
        openId: item.openId,
        passengerName: item.passengerName,
        passengerPhone: item.passengerPhone,
        passengerCardType: item.passengerCardType,
        passengerCardId: item.passengerCardId,
        appId: item.appId,
      };
      passengers.push(passenger);
    });
    return passengers;
  }

  async deleteGuest(passengerId: number) {
    let index = this.passengers.findIndex((item) => item.passengerId === passengerId);
    this.passengers.splice(index, 1);

    const res = await https.deletePassenger(passengerId);
    if (res.code === 200) {
      promptAction.showToast({
        message: '删除游客成功',
        duration: 2000,
      });
    }
  }

  public static get instance() {
    if (!GuestPageVM._instance) {
      GuestPageVM._instance = new GuestPageVM();
    }
    return GuestPageVM._instance;
  }
}
