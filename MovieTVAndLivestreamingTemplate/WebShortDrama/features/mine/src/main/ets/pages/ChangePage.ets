import { getString } from '@agctemplate/resources';
import { appRouter } from '@agctemplate/utils';
import { MinePageVM, NavDestinationModifier } from '@agctemplate/widgets';
import { AvatarButton } from '../component/AvatarButton';


@ComponentV2
export struct ChangePage {
  @Local vm: MinePageVM = MinePageVM.instance;
  @Local name: string = this.vm.localInfo.nickname ? this.vm.localInfo.nickname : this.vm.userInfo.nickname;
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();

  build() {
    NavDestination() {
      Scroll(){
        Column() {
          Text(getString('app.string.modify_avatar'))
            .fontSize(20)
            .margin({ top: 10, bottom: 10 })
          AvatarButton()

          Text(getString('app.string.modify_name'))
            .fontSize(20)
            .margin({ top: 10, bottom: 10 })
          TextInput({ text: this.name })
            .height(60)
            .width('90%')
            .maxLength(10)
            .onChange((value: string) => {
              this.name = value;
            })

          Flex({ justifyContent: FlexAlign.SpaceAround }) {
            Button(getString('app.string.cancel'))
              .onClick(() => {
              appRouter.back()
              })
              .backgroundColor(0xffffff)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))

            Button(getString('app.string.confirm'))
              .onClick(() => {
                if (this.vm.saveEdit(this.name)) {
                  this.vm.userInfo.nickname = this.name ? this.name : this.vm.userInfo.nickname;
                  this.vm.localInfo.nickname = this.name ? this.name : this.vm.localInfo.nickname;
                  appRouter.back(true)
                  appRouter.back(true)
                }
              })
              .backgroundColor(0xffffff)
              .fontColor($r('sys.color.warning'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
          }
          .margin({ top: 10, bottom: 10 })
        }
        .borderRadius(10)
      }
      .scrollBar(BarState.Off)
    }
    .onBackPressed(() => {
      appRouter.back(true)
      return true
    })
    .hideTitleBar(false)
    .title(this.title())
    .backgroundColor($r('sys.color.background_secondary'))
    .attributeModifier(this.navDestinationModifier)
    .height('100%')
  }

  @Builder
  title() {
    Text(getString('app.string.modify_info'))
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .height(27)
      .margin({ top: 15, left: 8 })
  }
}

@Builder
export function ChangePageBuilder() {
  ChangePage()
}
