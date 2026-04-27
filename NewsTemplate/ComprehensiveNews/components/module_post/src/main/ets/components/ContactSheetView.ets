import { User } from '../types/Types';
import { emptyBuilder } from './EmptyView';

@ComponentV2
export struct ContactSheetView {
  @Param userList: User[] = [];
  @Event onSelect: (user: User) => void = () => {
  };
  @Local contactSearchValue: string = '';

  @Computed
  get filterList() {
    return this.userList.filter(user => user.authorNickName.includes(this.contactSearchValue));
  }

  build() {
    Column() {
      Search({ value: $$this.contactSearchValue, placeholder: '搜索' })
        .width('100%')
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 8 })

      Text('我的关注')
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(700)
        .margin({ top: 24, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start)

      List() {
        ForEach(this.filterList, (contact: User) => {
          ListItem() {
            Row() {
              Image(contact.authorIcon)
                .width(40)
                .height(40)
                .borderRadius('50%')

              Text(contact.authorNickName)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Start)
                .margin({ left: 8 })
                .layoutWeight(1)
            }
            .width('100%')
            .height(64)
            .onClick(() => {
              this.onSelect(contact);
            })
          }
        }, (contact: User) => contact.authorId)

        ListItem() {
          emptyBuilder()
        }
        .layoutWeight(1)
        .visibility(this.filterList.length <= 0 ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .padding({ bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }
}