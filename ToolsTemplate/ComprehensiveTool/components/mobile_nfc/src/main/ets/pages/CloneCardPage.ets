import { ComponentContent, LevelMode } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { ALL_CARD_TAB, NFC_TYPE } from '../common/Enum';
import { getNfcName } from '../common/nfc/Nfc';
import { getNavPathStack } from '../common/Route';
import { cloneTipDialog } from '../components/CloneTipDialog';
import { CardAllView } from './CardListView';
import { CloneTipDialogParams } from '../model/Index';
import { PromptActionUtil } from '../common/PromptActionUtil';

@Builder
export function CloneCardPageBuilder() {
  CloneCardPage();
}

@ComponentV2
struct CloneCardPage {
  @Local currentIndex: number = ALL_CARD_TAB.TAB_INDEX_DOOR;
  @Local editMode: boolean = false;
  private tabsController: TabsController = new TabsController();

  build() {
    NavDestination() {
      Column() {
        Row() {
          Row({ space: 8 }) {
            Image($r('app.media.chevron_left')).size({ width: 40, height: 40 }).onClick(() => {
              getNavPathStack().pop();
            });
            Text('克隆卡片').fontSize(20).fontWeight(FontWeight.Bold).opacity(0.9);
          };

          Image($r('app.media.ic_tutorial_right')).size({ width: 40, height: 40 }).onClick(() => {
            let params = new CloneTipDialogParams()
            params.confirm = () => {
              PromptActionUtil.closeDialog(cloneTipContentNode);
            }

            let uiContext = this.getUIContext()
            let cloneTipContentNode: ComponentContent<Object> =
              new ComponentContent(uiContext, wrapBuilder<[CloneTipDialogParams]>(cloneTipDialog), params);
            PromptActionUtil.setContext(uiContext);
            PromptActionUtil.setContentNode(cloneTipContentNode);
            PromptActionUtil.setOptions({
              levelMode: LevelMode.EMBEDDED,
              onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                UtilLog.info(JSON.stringify(dismissDialogAction.reason));
              },
            });

            PromptActionUtil.openDialog();
          });
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 });

        Column() {
          Tabs({
            barPosition: BarPosition.Start,
            index: this.currentIndex,
            controller: this.tabsController,
          }) {
            TabContent() {
              CardAllView({
                isShowTitle: false,
                nfcType: NFC_TYPE.NFC_TYPE_DOOR,
                index: ALL_CARD_TAB.TAB_INDEX_DOOR,
                editMode: this.editMode,
                clonePage: true,
                changeEditMode: (isEdit: boolean) => {
                  this.editMode = isEdit;
                },
              });
            }
            .tabBar(this.TabBuilder(ALL_CARD_TAB.TAB_INDEX_DOOR, getNfcName(NFC_TYPE.NFC_TYPE_DOOR)));
          }
          .barHeight(36)
          .width('100%')
          .layoutWeight(1)
          .barMode(BarMode.Fixed)
          .onChange((index: number) => {
            this.currentIndex = index;
          });
        };
      }
      .width('100%')
      .height('100%');
    }.hideTitleBar(true);
  }

  @Builder
  TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.currentIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'));
    }
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    });
  }
}