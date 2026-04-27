/**
 * 记录历史，用于redo和undo操作
 */
export class ChangeRecord {
  styledString: MutableStyledString;

  constructor(styledString: MutableStyledString) {
    this.styledString = styledString;
  }
}