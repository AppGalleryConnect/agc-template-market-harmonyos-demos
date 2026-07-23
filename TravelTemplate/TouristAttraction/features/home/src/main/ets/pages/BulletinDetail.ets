import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, Constant, GridRowColSetting } from 'common';
import { https } from 'network';
import { AsWebRichText, TitleBar } from 'uicomponents';
import { mapperBulletinInfo } from '../mapper/Index';
import { BulletinInfo } from '../model/BulletinInfo';

@Builder
export function BulletinDetailBuilder() {
  BulletinDetail();
}

@ComponentV2
export struct BulletinDetail {
  @Local bulletinId: number = 0;
  @Local bulletinInfo: BulletinInfo = new BulletinInfo();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  getBulletinById() {
    https.getBulletinDetail(this.bulletinId).then((res) => {
      this.bulletinInfo = mapperBulletinInfo(res.data);
      this.bulletinInfo.detail =
        `<meta name="viewport" content="width=device-width, initial-scale=1.0">${this.bulletinInfo.detail}`;
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '资讯详情', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Scroll() {
          GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
            GridCol({
              span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
              offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
            }) {
              Column({ space: 24 }) {
                Column({ space: 4 }) {
                  Text(this.bulletinInfo.title)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Subtitle_L'));

                  Text(`时间：${this.bulletinInfo.releaseTime}`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor($r('sys.color.font_secondary'));
                }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT);

                if (this.bulletinInfo.detail) {
                  Column() {
                    AsWebRichText({ url: Constant.RICH_TEXT_URI, richTextStr: this.bulletinInfo.detail })
                      .layoutWeight(1);
                  }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT).layoutWeight(1);
                }
              };
            };
          };
        }
        .padding({ top: 12, bottom: 16 })
        .margin({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
        .layoutWeight(1)
        .align(Alignment.Top);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.bulletinId = context.pathInfo.param as number;
      this.getBulletinById();
    });
  }
}