import { getString } from '@agctemplate/resources'
import { MainTitleModifier } from '../../AttributeModifiers'
import { ListItemModel } from '../../model/ListItemModel'
import { CommonServices } from './CommonServices'
import { UserLogin } from './UserLogin'

@ComponentV2
export struct Mine {
  scroller: Scroller = new Scroller();
  modifier: MainTitleModifier = new MainTitleModifier();
  @Param @Require commonServicesContents: ListItemModel[]
  @Param @Require commonServicesContents_2: ListItemModel[]
  @Param userInfoHandler?: Function = undefined

  build() {
    Column() {
      Text(getString('app.string.mine'))
        .attributeModifier(this.modifier)
        .padding({ top: 12, bottom: 12 })
        .margin({ bottom: 8 })

      List({ scroller: this.scroller, space: 12 }) {
        ListItem() {
          UserLogin({
            userInfoHandler: this.userInfoHandler
          })
        }

        ListItem() {
          CommonServices({
            title: getString('app.string.mine_common_service'),
            commonServicesContents: this.commonServicesContents
          });
        }

        ListItem() {
          CommonServices({
            commonServicesContents: this.commonServicesContents_2
          });
        }
        ListItem() {}
        .height(88).width('100%')
      }
      .edgeEffect(EdgeEffect.Spring)
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .alignItems(HorizontalAlign.Start)
    .height('100%')
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}