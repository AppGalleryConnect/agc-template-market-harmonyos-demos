@ObservedV2
export class BulletItem {
  private static trackIndex: number = 0;
  content: Resource | string; // 弹幕内容
  @Trace opacity: number; //不透明度
  @Trace speed: number; // 弹幕速度
  @Trace size: number; // 弹幕字号
  positionY: number;
  isUser: boolean = false; // 标记是否用户发送，用户发送的弹幕带有边框

  constructor(content: Resource | string, isUser: boolean = false, rows: number,
    opacity: number, speed: string, size: string) {
    BulletItem.trackIndex = (BulletItem.trackIndex + 1) % rows;
    this.content = content;
    this.opacity = opacity / 100;
    this.speed = speed === '慢' ? 3 : (speed === '适中' ? 6 : 12)
    this.size = size === '小' ? 12 : (size === '适中' ? 16 : 20)
    this.positionY = BulletItem.trackIndex * 30;
    this.isUser = isUser;
  }
}