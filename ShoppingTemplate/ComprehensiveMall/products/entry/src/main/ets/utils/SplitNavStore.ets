/** 分屏导航参数缓存 */
class SplitNavStoreData {
  productId: string | undefined = undefined;
  slotId: string | undefined = undefined;
  isSplitPage: boolean | undefined = undefined;
}

/** 分屏导航参数缓存，供 EntryAbility 写入、Index.ets 读取 */
export const splitNavStore: SplitNavStoreData = new SplitNavStoreData();
