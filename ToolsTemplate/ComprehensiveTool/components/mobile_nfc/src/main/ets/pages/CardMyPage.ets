import { CardAllView } from './CardListView';
import { CardMyModel } from '../model/Index';

@Builder
export function CardMyPageBuilder() {
  CardMyPage();
}

@ComponentV2
struct CardMyPage {
  @Local nfcType: number = 0;
  @Local editMode: boolean | undefined = undefined;

  onBackPress(): boolean | void {
    return this.back();
  }

  private back(): boolean {
    if (this.editMode) {
      this.editMode = !this.editMode;
      return true;
    }
    return false;
  }

  build() {
    NavDestination() {
      Column() {
        CardAllView({
          isShowTitle: true,
          nfcType: this.nfcType,
          index: 0,
          editMode: this.editMode,
          clonePage: false,
          changeEditMode: (isEdit: boolean) => {
            this.editMode = isEdit;
          },
        }).width('100%')
          .layoutWeight(1);
      }.width('100%')
      .height('100%');
    }.hideTitleBar(true).onReady((ctx) => {
      this.nfcType = (ctx.pathInfo.param as CardMyModel).nfcType;
    });
  }
}