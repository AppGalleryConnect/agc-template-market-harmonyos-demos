import { Constants } from 'constant';
import { Tag } from 'type';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Component
export struct Reservation {
  vm: HomePageVM = HomePageVM.instance;
  @Prop reservation: Array<Tag>;

  build() {
    Column({ space: 16 }) {
      Text(`订房必读`).fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start);

      Row() {
        Column() {
          Text('入离').fontSize(12).opacity(0.6).width(32);
        };

        Column() {
          ForEach(this.vm.getTags(this.reservation, '入离'),
            (item: string) => {
              Text(`${item}`).fontSize(12).margin({ bottom: 12 });
            }, (item: string) => item);
        }.margin({ left: 16 });
      }.alignItems(VerticalAlign.Top).width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);
    };
  }
}