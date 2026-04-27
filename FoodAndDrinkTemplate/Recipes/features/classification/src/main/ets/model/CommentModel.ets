@ObservedV2
export class CommentModel {
  recipeId: number = 0;
  commentId: number = 0;
  authorId: number = 0;
  icon?: ResourceStr;
  nickName: string = '';
  comment: string = '';
  time: number = 0;
  score: number = 1;
}

@ObservedV2
export class Score {
  idx: string = '0'
  @Trace select: boolean = false

  constructor(idx: string, select: boolean) {
    this.idx = idx
    this.select = select
  }
}