export class TaskUtil {
  public static getTaskIndex(index: number) {
    let displayIndex = index + 1;
    if (displayIndex < 10) {
      return '0' + displayIndex;
    } else {
      return displayIndex.toString();
    }
  }
}