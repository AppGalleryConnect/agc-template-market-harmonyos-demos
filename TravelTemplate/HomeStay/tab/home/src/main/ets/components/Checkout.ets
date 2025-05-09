import { Constants } from 'constant';
import { Tag } from 'type';
import { HomePageVM } from '../viewmodel/HomePageVM';

@Component
export struct Checkout {
  vm: HomePageVM = HomePageVM.instance;
  @Prop checkOut: Array<Tag>;

  build() {
    Column({ space: 16 }) {
      Text(`退房政策`).fontSize(16).fontWeight(500).alignSelf(ItemAlign.Start);

      ForEach(this.checkOut, (item: Tag) => {
        Row() {
          Text(`${item.tag}`).fontSize(12).opacity(0.6).width(32);
          Text(`${item.subTags}`).fontSize(12).margin({ left: 16 });
        }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.Start);
      }, (item: Tag) => item.tag);
    };
  }
}