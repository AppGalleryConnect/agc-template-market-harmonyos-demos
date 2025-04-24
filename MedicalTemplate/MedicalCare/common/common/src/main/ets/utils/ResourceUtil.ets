import { common } from '@kit.AbilityKit';
import util from '@ohos.util';

export class ResourceUtil {
  /**
   * 从资源文件中读取文本内容。
   *
   * @param context UIAbilityContext
   * @param path 资源文件的路径
   * @returns 资源文件的文本内容，如果读取失败则返回 null
   */
  static async readTextFromResource(path: string): Promise<string | null> {
    try {
      let context = getContext() as common.UIAbilityContext
      let getJson = await context.resourceManager.getRawFileContent(path);
      let textDecoderOptions: util.TextDecoderOptions = {
        ignoreBOM: true
      };
      let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
      return textDecoder.decodeToString(getJson);
    } catch (error) {
      return null;
    }
  }

  static async readObjectFromResource<T>(path: string): Promise<T | null> {
    try {
      let jsonStr: string | null = await ResourceUtil.readTextFromResource(path)
      let obj: T = JSON.parse(jsonStr ?? '')
      return obj
    } catch (error) {
      return null
    }
  }

  static readStringArray(stringArrayRes: Resource) {
    let context = getContext() as common.UIAbilityContext
    return context.resourceManager.getStringArrayValueSync(stringArrayRes)
  }
}
