/**
 * Calculate the snapshot preview pop-up position class
 */
export class PopupUtils {
  static calcPopupCenter(displayWidth: number, displayHeight: number, snapPopupWidth: number,
    snapPopupHeight: number): Position {
    return {
      x: (displayWidth - snapPopupWidth) / 2,
      y: (displayHeight - snapPopupHeight) / 2
    };
  }

  static calcPopupBottomLeft(displayHeight: number, snapPopupHeight: number): Position {
    return {
      x: 20,
      y: displayHeight - snapPopupHeight - 40
    };
  }
}