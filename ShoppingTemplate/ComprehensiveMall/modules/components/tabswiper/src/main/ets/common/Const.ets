import { Position } from '@ohos.arkui.node';

export class CustomNodeConst {

  public static readonly DEFAULT_POSITION: Position = { x: 0, y: 0 }; // 有多个名为 Position 的类型, 当前引用的类型为 Vector2

  public static readonly DEFAULT_CONSTRAINT_OPTIONS: ConstraintSizeOptions = {
    minWidth: 0,
    maxWidth: Number.POSITIVE_INFINITY,
    minHeight: 0,
    maxHeight: Number.POSITIVE_INFINITY
  };

  public static readonly MIN_SIZE: Size = { width: 0, height: 0 };

  public static readonly MAX_SIZE: Size = { width: Number.POSITIVE_INFINITY, height: Number.POSITIVE_INFINITY };
}
