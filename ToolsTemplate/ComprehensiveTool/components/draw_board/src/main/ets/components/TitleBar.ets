import { DrawBoardVM } from '../viewmodel/DrawVM';
import { baseToast } from './ConfirmDialog';
import { PersistenceV2, SymbolGlyphModifier } from '@kit.ArkUI';
import { DrawHistory } from '../model/Model';

@ComponentV2
export struct TitleBar {
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance;
  @Param isHideBack: boolean = false;
  @Event onDrawHistory: () => void = () => {
  };
  @Local saveIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.save')).fontSize('24vp');
  @Local cleanIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.clean')).fontSize('24vp');
  @Local fileIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.list_bullet')).fontSize('24vp');
  @Local drawHistory: DrawHistory = PersistenceV2.connect(DrawHistory, () => new DrawHistory())!;

  @Builder
  drawTitle() {
    Column() {
      TextInput({
        text: this.drawHistory.drawInfoList[this.drawBoardVM.currentEditIndex]?.title ?? this.drawBoardVM.title,
        placeholder: '请输入名称',
      })
        .onChange((value) => {
          this.drawBoardVM.title = value;
        });
    };
  }

  @Builder
  drawMenu() {
    Menu() {
      MenuItem({ symbolStartIcon: this.saveIconModifier, content: '保存' })
        .onClick(() => {
          if (this.drawBoardVM.hasContent()) {
            baseToast.show({
              type: 'dialog',
              messageBuilder: () => {
                this.drawTitle();
              },
              confirmAction: () => {
                if (this.drawBoardVM.validate(this.getUIContext())) {
                  this.drawBoardVM.saveDrawBoard();
                  baseToast.hide();
                }
              },
              cancelAction: () => {
                this.drawBoardVM.title = '';
              },
            }, this.getUIContext());
          } else {
            baseToast.show({
              type: 'dialog',
              hasTitle: '提示',
              message: '画布暂无改动内容',
              confirmAction: () => {
                baseToast.hide();
              },
              cancelAction: () => {
                baseToast.hide();
              },
            }, this.getUIContext());
          }
        });
      MenuItem({ symbolStartIcon: this.cleanIconModifier, content: '清空' })
        .onClick(() => {
          baseToast.show({
            type: 'dialog',
            hasTitle: '提示',
            message: '是否确认清空画布',
            confirmAction: () => {
              this.drawBoardVM.clear();
              this.drawBoardVM.context.clearRect(0, 0, this.drawBoardVM.context.width, this.drawBoardVM.context.height);
              this.drawBoardVM.drawInvoker.execute(this.drawBoardVM.context);
              this.drawBoardVM.clean = true;
              baseToast.hide();
            },
            cancelAction: () => {
              baseToast.hide();
            },
          }, this.getUIContext());
        });
      MenuItem({ symbolStartIcon: this.fileIconModifier, content: '文件管理' })
        .onClick(() => {
          this.onDrawHistory();
        });
    }
    .width(224);
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.back'))
          .width(42)
          .height(42)
          .onClick(() => {
            if (this.drawBoardVM.hasContent()) {
              baseToast.show({
                type: 'dialog',
                hasTitle: '温馨提示',
                message: '当前绘画未保存，请确认是否退出',
                confirmAction: () => {
                  baseToast.hide();
                  this.drawBoardVM.pathStack.pop();
                },
              }, this.getUIContext());
            } else {
              this.drawBoardVM.pathStack.pop();
            }
          })
          .margin({
            right: 10,
          })
          .visibility(this.isHideBack ? Visibility.None : Visibility.Visible);
        Text($r('app.string.canvas'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold);
      };

      Row({ space: 10 }) {
        Image(this.drawBoardVM.unDoDraw ? $r('app.media.recall_active') : $r('app.media.recall'))
          .width(40)
          .height(40)
          .enabled(this.drawBoardVM.unDoDraw)
          .onClick(async () => {
            this.drawBoardVM.drawOperateUndo();
            this.drawBoardVM.context.clearRect(0, 0, this.drawBoardVM.context.width, this.drawBoardVM.context.height);
            this.drawBoardVM.drawInvoker.execute(this.drawBoardVM.context);
          });

        Image(this.drawBoardVM.redoDraw ? $r('app.media.redo_active') : $r('app.media.redo'))
          .width(40)
          .height(40)
          .enabled(this.drawBoardVM.redoDraw)
          .onClick(async () => {
            this.drawBoardVM.drawOperateRedo();
            this.drawBoardVM.context.clearRect(0, 0, this.drawBoardVM.context.width, this.drawBoardVM.context.height);
            this.drawBoardVM.drawInvoker.execute(this.drawBoardVM.context);
          });

        Stack() {
          Column() {
            Image($r('app.media.draw_menu'))
              .width(15)
              .height(15);
          }
          .justifyContent(FlexAlign.Center)
          .width($r('app.float.image_width'))
          .height($r('app.float.image_width'))
          .borderRadius('50%')
          .backgroundColor($r('sys.color.comp_background_tertiary'));

          Button({ type: ButtonType.Normal })
            .backgroundColor(Color.Transparent)
            .width($r('app.float.image_width'))
            .height($r('app.float.image_width'))
            .borderRadius('50%')
            .bindMenu(this.drawMenu);
        };
      };

    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      top: 12,
    });
  }
}