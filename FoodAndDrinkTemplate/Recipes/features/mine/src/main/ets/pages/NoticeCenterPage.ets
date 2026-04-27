import { buildTitleBar, CommonConstants } from 'commonlib';
import { Notice } from 'network';
import { LengthMetrics } from '@kit.ArkUI';
import { NoticeCenterPageVM } from '../viewModels/NoticeCenterPageVM';

@Builder
export function NoticeCenterPageBuilder() {
  NoticeCenterPage();
}


@ComponentV2
struct NoticeCenterPage {
  vm: NoticeCenterPageVM = new NoticeCenterPageVM();

  aboutToAppear(): void {
    this.vm.getMyNoticeList();
  }

  build() {
    NavDestination() {
      Divider().strokeWidth('1px')
      if (this.vm.noticeList.length) {
        List({ space: 8 }) {
          ForEach(this.vm.noticeList, (item: Notice) => {
            ListItem() {
              Row() {
                Row() {
                  Image($r(`app.media.${item.icon}`)).width(40).height(40).borderRadius(20)
                  Column() {
                    Text(item.title)
                      .fontSize(16)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.subTitle)
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
                }.layoutWeight(1)

                Column() {
                  Text(this.vm.getFmtTime(item.time)).fontSize(10).fontColor($r('sys.color.font_secondary'))
                }.height(40).margin({ left: 8 })
              }
              .width('100%')
              .padding(12)
              .justifyContent(FlexAlign.SpaceBetween)
              .backgroundColor($r('sys.color.comp_background_gray'))
              .borderRadius(16)
              .onClick(() => {
                this.vm.jumpUrl(item)
              })
            }
          }, (item: Notice) => item.id.toString())
        }.layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .contentStartOffset(18)
        .contentEndOffset(8)
      } else {
        Column() {
          Image($r('app.media.ic_empty')).size({ width: 160, height: 160 });
          Text('~~空空如也~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
        }.margin({ top: 72 });
      }
    }
    .title(buildTitleBar('消息中心'), { paddingStart: LengthMetrics.vp(16) })
    .padding({ top: CommonConstants.STATUS_BAR_HEIGHT })
  }
}

