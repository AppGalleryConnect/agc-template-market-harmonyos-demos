import { emitter } from '@kit.BasicServicesKit';
import { BaseViewModel, GlobalContextUtils, PopViewUtils, EventEnum } from 'lib_common';
import { NewsResponse } from 'lib_news_api';
import { PlayerLayoutSize } from 'module_swipeplayer';
import { CommentView } from '../components/CommentView';
import { CommentController } from '../controller/CommentController';

@ObservedV2
export class CommentSheetParams extends BaseViewModel {
  @Trace videoInfo: NewsResponse = {} as NewsResponse;
  @Trace isShowKeyboard: boolean = false;
  @Trace playerLayoutSize: PlayerLayoutSize = new PlayerLayoutSize();
  @Trace commentController: CommentController = new CommentController();
  @Trace sheetTargetId: number = -1;
}

@Builder
function commentSheetBuilder() {
  commentSheetView()
}

@ComponentV2
struct commentSheetView {
  @Local sheetParams: CommentSheetParams = CommentSheetUtils.sheetParams;

  build() {
    CommentView({
      videoInfo: this.sheetParams.videoInfo,
      isShowKeyboard: this.sheetParams.isShowKeyboard,
    })
  }
}

export class CommentSheetUtils {
  static sheetParams: CommentSheetParams = new CommentSheetParams();

  static initParams(sheetParam: CommentSheetParams) {
    CommentSheetUtils.sheetParams.videoInfo = sheetParam.videoInfo
    CommentSheetUtils.sheetParams.isShowKeyboard = sheetParam.isShowKeyboard
    CommentSheetUtils.sheetParams.playerLayoutSize = sheetParam.playerLayoutSize
    CommentSheetUtils.sheetParams.commentController = sheetParam.commentController;
    CommentSheetUtils.sheetParams.sheetTargetId = sheetParam.sheetTargetId
  }

  static open() {
    PopViewUtils.showSheet(wrapBuilder(commentSheetBuilder), {
      height: '70%',
      blurStyle: BlurStyle.Thick,
      showClose: true,
      mode: SheetMode.EMBEDDED,
      maskColor: Color.Transparent,
      preferType: SheetType.BOTTOM,
      backgroundColor: $r('sys.color.background_secondary'),
      onWillDisappear: () => {
        CommentSheetUtils.sheetParams.commentController.showComment = false
        CommentSheetUtils.sheetParams.playerLayoutSize.updateLayoutSizeChangeFlag(false);
        CommentSheetUtils.sheetParams.playerLayoutSize.updatePlayerHeight('100%')
        const eventData: emitter.EventData = {
          data: {
            showTabHeader: true,
          },
        };
        emitter.emit(EventEnum.SHOW_TAB_HEADER, eventData)
      },
      onDisappear: () => {
        CommentSheetUtils.sheetParams.isShowKeyboard = false;
      },
      onWillAppear: () => {
        CommentSheetUtils.sheetParams.commentController.showComment = true;
        CommentSheetUtils.sheetParams.playerLayoutSize.updateLayoutSizeChangeFlag(true);

        // 提前计算并设置目标高度，避免动画过程中的频繁更新
        const windowTop = CommentSheetUtils.sheetParams.windowModel.windowTopPadding;
        const tabHeight = CommentSheetUtils.sheetParams.tabModel.tabHeight as number;
        const windowHeight = GlobalContextUtils.globalUIContext.px2vp(
          CommentSheetUtils.sheetParams.windowModel.windowHeight,
        );
        // Sheet 高度为 70%，减去 tabHeight 得到实际占用高度
        const sheetHeight = windowHeight * 0.7;
        const targetPlayerHeight = windowHeight - (sheetHeight - tabHeight) - windowTop;
        CommentSheetUtils.sheetParams.playerLayoutSize.updatePlayerHeight(`${targetPlayerHeight}vp`);

        const eventData: emitter.EventData = {
          data: {
            showTabHeader: false,
          },
        };
        emitter.emit(EventEnum.SHOW_TAB_HEADER, eventData)
      },
    }, undefined, CommentSheetUtils.sheetParams.sheetTargetId);
  }
}