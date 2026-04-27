import { KeyboardAvoidMode } from '@kit.ArkUI';
import { MoreFunction, MORE_ACTION_LIST } from '../commons/Constant';
import { RichEditorArea } from '../components/RichEditorArea';
import { EditNotePageVM } from '../viewmodel/EditNotePageVM';

@Builder
export function EditNotePageBuilder() {
  EditNotePage()
}


@ComponentV2
export struct EditNotePage {

  vm: EditNotePageVM = new EditNotePageVM(this.getUIContext());

  aboutToAppear(): void {
    // 启用压缩模式避让软键盘
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET);
  }

  aboutToDisappear(): void {
    // 还原默认上抬模式
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);

    this.vm.handleDisappear()
  }

  build() {
    NavDestination() {
      Column() {
        RichEditorArea({
          noteTitle: this.vm.currentNote.title,
          noteContent: this.vm.currentNote.styledString,
          snapShotController: this.vm.snapShotController,
          titleChange: (title: string) => {
            this.vm.noteTitle = title;
          },
        })
      }
      .height('100%')
      .width('100%');
    }
    .menus(this.toolBar())
    .onReady((cxt: NavDestinationContext) => {
      this.vm.pathStack = cxt.pathStack;
      let params = cxt.pathInfo.param as Record<string, Object>;
      this.vm.init(params)
    })
    .onBackPressed(() => {
      this.vm.onBack();
      return true
    });
  }

  /**
   * 显示更多选项视图
   */
  @Builder
  moreFunctionMenu() {
    Column(){
      List() {
        ForEach(MORE_ACTION_LIST, (item: MoreFunction) => {
          ListItem(){
            Row(){
              Image(item.icon)
                .width(24)
                .height(24)
                .margin({ left: 12, right: 8 })

              Text(item.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('100%')
            .height(48)
            .onClick(() => {
              this.vm.onMoreAction(item)
            })
          }
        }, (item: MoreFunction) => JSON.stringify(item))
      }
      .divider({ strokeWidth: 0.5 })
      .scrollBar(BarState.Off)
    }
    .width(114)
    .backgroundColor(Color.White)
    .margin({ top: 4, bottom: 4 })
  }

  @Builder
  toolBar() {
    if (this.vm.richEditorController.showMoreFunction){
      Row(){
        Image($r('app.media.show_more_function'))
          .width(40)
          .height(40)
          .bindMenu(this.moreFunctionMenu)
      }
      .height('100%')
      .width(150)
      .justifyContent(FlexAlign.End)
      .margin({ right: 16, });
    } else {
      Row({ space: 12 }) {
        Image(this.vm.getUnDoIcon())
          .width(40)
          .height(40)
          .onClick(() => {
            this.vm.richEditorController.onDo();
          });

        Image(this.vm.getRedoIcon())
          .width(40)
          .height(40)
          .onClick(() => {
            this.vm.richEditorController.reDo();
          });

        Image($r('app.media.save'))
          .height(40)
          .width(40)
          .onClick(() => {
            this.vm.saveNote()
          });
      }
      .height('100%')
      .width(150)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })
    }
  }
}