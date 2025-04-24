import { curves } from '@kit.ArkUI';

export interface VerticalAnchor {
  anchor: string;
  align: VerticalAlign;
}

export interface HorizontalAnchor {
  anchor: string;
  align: HorizontalAlign;
}

export class ComponentConst {
  static readonly FULL_PARENT = '100%';
  static readonly AUTO_SIZE = 'auto';

  // 相对布局绑定参数，不传anchor默认绑定父组件
  static readonly PARENT_ANCHOR = '__container__';
  public static bindBottom(anchor?: string): VerticalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: VerticalAlign.Bottom };
  }

  public static bindTop(anchor?: string): VerticalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: VerticalAlign.Top };
  }

  public static bindVerticalCenter(anchor?: string): VerticalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: VerticalAlign.Center };
  }

  public static bindStart(anchor?: string): HorizontalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: HorizontalAlign.Start };
  }

  public static bindEnd(anchor?: string): HorizontalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: HorizontalAlign.End };
  }

  public static bindHorizontalCenter(anchor?: string): HorizontalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: HorizontalAlign.Center };
  }

  public static startSpringAnimation(event: () => void) {
    animateTo({
      duration: 800,
      // 弹簧曲线：初始速度100，质量1，刚度80，阻尼10
      curve: curves.springCurve(100, 1, 80, 10),
    }, event);
  }
}