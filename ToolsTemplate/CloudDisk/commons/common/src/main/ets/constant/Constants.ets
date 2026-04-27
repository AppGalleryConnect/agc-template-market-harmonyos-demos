/**
 * @fileType: common
 * @zhName: 常量定义类
 */
// 泛型类型
export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)

export class Constants {
  public static readonly FULL_SIZE = '100%';
  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;
  public static readonly JUMPTO_DIRECTORPAGE_KEY: string = 'eventJumpToDirectorPage'
  public static readonly JUMPTO_FILETRANSFERMANAGERPAGE_KEY: string = 'eventJumpToFileTransferManagerPage'
  public static readonly FILETRANSFERSTATUS_KEY: string = 'eventFileTransfeStatus'
  public static readonly ADDFILELIST_KEY: string = 'eventAddFileList'
}

