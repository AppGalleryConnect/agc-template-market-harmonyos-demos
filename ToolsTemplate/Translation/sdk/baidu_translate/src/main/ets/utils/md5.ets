import cryptoFramework from '@ohos.security.cryptoFramework'
import util from '@ohos.util'

/**
 * MD5加密工具
 */
export class MD5Util {
  /**
   * 计算字符串的MD5值
   * @param str 待加密字符串
   * @returns MD5值（32位小写）
   */
  static async md5(str: string): Promise<string> {
    try {
      // 创建MD5消息摘要对象
      // 注意：MD5用于百度翻译API签名，这是第三方API的要求，非安全敏感场景
      const md = cryptoFramework.createMd('MD5') // arkts-no-unsafe-hash-algorithm

      // 将字符串转换为Uint8Array
      const encoder = new util.TextEncoder()
      const data = encoder.encodeInto(str)

      // 更新数据
      await md.update({ data: data })

      // 计算摘要
      const result = await md.digest()

      // 将结果转换为16进制字符串
      return MD5Util.arrayBufferToHex(result.data)
    } catch (error) {
      throw new Error('MD5加密失败: ' + (error as Error).message)
    }
  }

  /**
   * 计算ArrayBuffer的MD5值
   * @param buffer 待加密的ArrayBuffer
   * @returns MD5值（32位小写）
   */
  static async md5Buffer(buffer: ArrayBuffer): Promise<string> {
    try {
      // 创建MD5消息摘要对象
      const md = cryptoFramework.createMd('MD5')

      // 将ArrayBuffer转换为Uint8Array
      const data = new Uint8Array(buffer)

      // 更新数据
      await md.update({ data: data })

      // 计算摘要
      const result = await md.digest()

      // 将结果转换为16进制字符串
      return MD5Util.arrayBufferToHex(result.data)
    } catch (error) {
      throw new Error('MD5加密失败: ' + (error as Error).message)
    }
  }


  /**
   * 将ArrayBuffer转换为16进制字符串
   * @param buffer ArrayBuffer
   * @returns 16进制字符串
   */
  private static arrayBufferToHex(buffer: ArrayBuffer): string {
    const byteArray = new Uint8Array(buffer)
    let hexString = ''

    for (let i = 0; i < byteArray.length; i++) {
      const hex = byteArray[i].toString(16)
      hexString += hex.length === 1 ? '0' + hex : hex
    }

    return hexString
  }
}
