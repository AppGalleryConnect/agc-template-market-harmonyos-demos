import { BaseViewModel, CommonConfirmDialog, LoadingModel } from 'lib_common';
import { AggregateNewsComment, MineServiceApi } from 'lib_news_api';
import { AggregateNewsCommentModel } from '../common/ObservedModel';

interface DelItem {
  newsId?: string
  commentId?: string
}

@ObservedV2
export class CommentViewModel extends BaseViewModel {
  @Trace isEditMode: boolean = false;
  @Trace toDeleteList: DelItem[] = [];
  @Trace list: AggregateNewsCommentModel[] = [];
  @Trace loadingModel: LoadingModel<AggregateNewsComment[]> = new LoadingModel(MineServiceApi.queryMineCommentList);

  constructor() {
    super();
    this.queryList();
  }

  queryList(showLoading: boolean = true): void {
    this.loadingModel.callApi({
      pageLoading: showLoading,
      dialogLoading: false,
    }).then((list) => {
      this.list = list.map(v => new AggregateNewsCommentModel(v));
    });
  }

  callDeleteApi(isDelAll: boolean, toDeleteList: DelItem[]): void {
    if (isDelAll) {
      this.list.forEach(v => {
        MineServiceApi.deleteComment(v.newsId, v.commentId);
      })
    } else {
      toDeleteList.forEach(v => {
        MineServiceApi.deleteComment(v.newsId!, v.commentId!);
      })
    }

    this.toDeleteList = [];
  }

  onChange(value: boolean, v: AggregateNewsCommentModel) {
    if (value) {
      this.toDeleteList.push({
        newsId: v.newsId,
        commentId: v.commentId,
      });
    } else {
      const index = this.toDeleteList.findIndex(item => item.commentId === v.commentId);
      if (index !== -1) {
        this.toDeleteList.splice(index, 1);
      }
    }
  }

  enterEdit() {
    this.isEditMode = true;
  }

  quitEdit() {
    this.isEditMode = false;
    this.toDeleteList = [];
  }

  deleteAllConfirm() {
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: '删除全部评论后，所有评论内容将被永久删除，无法找回，请确认是否继续。',
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(true, []);
        this.quitEdit();
        this.queryList(false);
        this.contextModel.showToast({ message: '已清空' });
      },
    })
  }

  deleteConfirm() {
    const dialogText: string =
      this.toDeleteList.length === 1 ? '删除动作不可恢复，是否删除此条评论？' :
        `删除动作不可恢复，是否删除 ${this.toDeleteList.length} 条评论？`;
    CommonConfirmDialog.show({
      primaryTitle: '温馨提示',
      content: dialogText,
      secBtnV: '删除',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        this.callDeleteApi(false, this.toDeleteList);
        this.quitEdit();
        this.queryList(false);
        this.contextModel.showToast({ message: '已删除' });
      },
    })
  }

  onBackPressed() {
    if (this.isEditMode) {
      this.quitEdit();
      return true;
    }
    return false;
  }

  @Computed
  get allowDelete() {
    return this.toDeleteList.length > 0;
  }

  @Computed
  get allowEnterEdit() {
    return this.list.length > 0;
  }
}