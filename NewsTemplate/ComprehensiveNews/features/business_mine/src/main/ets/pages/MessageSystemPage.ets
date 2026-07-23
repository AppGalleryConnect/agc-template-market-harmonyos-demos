import { CommonConstants, RouterUtils, TimeUtils } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { SystemMessageInfo } from '../common/ObservedModel';
import { MsgSystemViewModel } from '../viewmodels/MessageSystemVM';

@Builder
export function MsgSystemPageBuilder() {
  MsgSystemPage()
}

@ComponentV2
struct MsgSystemPage {
  @Local vm: MsgSystemViewModel = new MsgSystemViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '系统消息',
          onBack: () => {
            RouterUtils.pop('1');
          },
        })
        Column() {
          List({ space: CommonConstants.SPACE_S }) {
            ForEach(this.vm.list, (v: SystemMessageInfo) => {
              ListItem() {
                this.infoItem(v)
              }
            }, (v: SystemMessageInfo) => v.content + v.createTime)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: CommonConstants.SPACE_S,
          })
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      RouterUtils.pop('1');
      return true;
    })
  }

  @Builder
  infoItem(v: SystemMessageInfo) {
    Column({ space: CommonConstants.SPACE_S }) {
      Row({ space: CommonConstants.SPACE_S }) {
        Image($r('app.media.ic_system_avatar'))
          .width($r('app.float.head_icon_width'))
          .aspectRatio(1)
          .draggable(false)
        Column({ space: CommonConstants.SPACE_XXS }) {
          Text('系统消息')
            .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(21)
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(TimeUtils.handleMsgTimeDiff(v.createTime))
            .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
      }

      Divider()
      Text(v.content)
        .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
    })
  }
}