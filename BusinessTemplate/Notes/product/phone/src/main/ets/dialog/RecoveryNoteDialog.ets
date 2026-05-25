import { NoteService } from '@ohos_agcit/notes_datasource';
import { Note } from 'richeditor';
import { ThemeController } from '../controller/ThemeController';
import { KVStore } from 'serializer';

@Builder
export function RecoveryNoteDialogBuilder() {
  RecoveryNoteDialog();
}

/**
 * 回收站-恢复笔记弹窗
 */
@ComponentV2
export struct RecoveryNoteDialog {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Consumer() kvStore: KVStore | undefined = undefined;
  private themeController: ThemeController = ThemeController.instance
  private noteService: NoteService = NoteService.instance;
  private uiContext: UIContext = this.getUIContext() as UIContext;
  @Local currentNote: Note | undefined;

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Column({ space: 18 }) {
          Text('恢复笔记')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text('请确认是否恢复此笔记至原分类？')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))

          Flex({justifyContent: FlexAlign.SpaceAround}){
            Row(){
              Text('取消')
                .fontColor($r('sys.color.icon_emphasize'))
                .fontSize(16)
            }
            .justifyContent(FlexAlign.Center)
            .width('50%')
            .onClick(() => {
              this.appPathStack.pop();
            })

            Row(){
              Text('确定')
                .fontColor($r('sys.color.icon_emphasize'))
                .fontSize(16)
            }
            .justifyContent(FlexAlign.Center)
            .width('50%')
            .onClick(() => {
              if (this.currentNote) {
                this.noteService.recoverNote(this.currentNote.id, this.kvStore, this.uiContext);
              }
              this.appPathStack.pop();
            })
          }
          .padding({
            top: 10
          })
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeController.dialogBgWhite)
        .borderRadius(32)
        .height(139)
        .width('92%')
      }
      .height('100%')
      .width('100%')
    }
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, Object>;
      if (params && params !== null) {
        this.currentNote = params.note as Note | undefined;
      }
    })
    .backgroundColor($r('sys.color.mask_fourth'))
    .hideTitleBar(true)
    .mode(NavDestinationMode.DIALOG);
  }
}
