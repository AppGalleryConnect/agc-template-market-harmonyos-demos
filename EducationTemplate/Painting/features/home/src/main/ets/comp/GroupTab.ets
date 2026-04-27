import { Constants, GlobalContext } from 'common'
import { GroupItem } from '../types/StyleType'

@ComponentV2
export struct GroupTab {
  @Once
  @Param showGroup: string = 'Regular'
  @Param @Require groupList: GroupItem[]
  @Event changeGroup: (group: string) => void = (group: string) => {
  }

  build() {
    Row() {
      Row() {
        ForEach(this.groupList, (group: GroupItem) => {
          Row() {
            Text(group.name)
              .fontWeight(group.type === this.showGroup ? FontWeight.Medium : FontWeight.Normal)
              .fontSize(14)
              .textAlign(TextAlign.Center)
              .fontColor(group.type === this.showGroup ? $r('app.color.mask_black') : '#99000000')

          }
          .padding({ left: 18, right: 18, })
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .height(Constants.FULL_SIZE)
          .alignItems(VerticalAlign.Center)
          .backgroundColor(group.type === this.showGroup ? Color.White : Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level9'))
          .onClick(() => {
            this.showGroup = group.type
            this.changeGroup(group.type)
          })
        },(group: GroupItem) => group.type)
      }
      .backgroundColor('#f2f2f2')
      .borderRadius($r('sys.float.corner_radius_level10'))
      .width(Constants.FULL_SIZE)
      .padding(2)
    }
    .height(40)
    .width(Constants.FULL_SIZE)
    .backgroundColor(Color.White)
    .padding({ left: 16, right: 16 })
  }
}