import cryptoFramework from '@ohos.security.cryptoFramework';

export class MathUtil {
  private static readonly INT32_BYTE_SIZE: number = 4;

  public static generateInt32InRange(min: number, max: number): number {
    if (min >= max) {
      return 0;
    }
    min = Math.ceil(min);
    max = Math.floor(max);
    const range: number = max - min;
    const randomValue: bigint = MathUtil.generateRandomNumber(MathUtil.INT32_BYTE_SIZE);
    return Number(randomValue % BigInt(range)) + min;
  }

  public static generateRandomNumber(byteSize: number): bigint {
    try {
      const random: cryptoFramework.Random = cryptoFramework.createRandom();
      const randomBlob: cryptoFramework.DataBlob = random.generateRandomSync(byteSize);
      return MathUtil.arrayToBigInt(randomBlob.data);
    } catch (error) {
      return 0n;
    }
  }

  public static arrayToBigInt(data: Uint8Array): bigint {
    let result: bigint = 0n;
    for (let i = 0; i < data.length; i++) {
      result = (result << 8n) | BigInt(data[i]);
    }
    return result;
  }
}
