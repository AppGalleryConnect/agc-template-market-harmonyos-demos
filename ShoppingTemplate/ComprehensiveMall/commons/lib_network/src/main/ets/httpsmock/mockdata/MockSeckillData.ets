import { SeckillStatus } from '../../types/EnumTypes';
import {
  SeckillTimeSlot,
  SeckillProductInfo,
  SeckillSession,
  BaseSeckillTimeInfo,
} from '../../types/ProductTypes';

export class MockSeckillData {
  // ==================== 每天固定两个时段 ====================

  private static readonly TIME_SLOT_CONFIG: BaseSeckillTimeInfo[] = [
    { slotId: 'slot_08', startTime: '08:00', endTime: '16:00' },
    { slotId: 'slot_16', startTime: '16:00', endTime: '24:00' },
  ];

  /**
   * 日期格式化辅助方法
   * @param date Date对象
   * @returns "YYYYMMDD" 格式字符串，例如 "20260122"
   */
  private static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}${month}${day}`;
  }

  /**
   * 生成今天及未来的秒杀时段（返回4条数据）
   * 规则：
   * 1. 如果当前有正在进行的秒杀，包含该场次
   * 2. 然后返回之后的3个场次
   * 3. 跨天自动计算日期
   */
  public static generateTodayTimeSlots(): SeckillTimeSlot[] {
    const now = new Date();
    const currentTime = Date.now();
    const result: SeckillTimeSlot[] = [];

    // 生成今天和明天的所有时段 (扩大范围以确保足够填满4个)
    const allSlots: SeckillTimeSlot[] = [];

    // 遍历今天(0)和明天(1)
    for (let dayOffset = 0; dayOffset <= 1; dayOffset++) {
      const targetDate = new Date(
        now.getFullYear(),
        now.getMonth(),
        now.getDate() + dayOffset,
      );

      const dateStr = MockSeckillData.formatDate(targetDate);

      MockSeckillData.TIME_SLOT_CONFIG.forEach(config => {
        const start = config.startTime.split(':').map(Number);
        const startHour = start[0];
        const startMinute = start[1];
        const end = config.endTime.split(':').map(Number);
        const endHour = end[0];
        const endMinute = end[1];

        const startTimestamp = new Date(
          targetDate.getFullYear(),
          targetDate.getMonth(),
          targetDate.getDate(),
          startHour,
          startMinute,
        ).getTime();

        const endTimestamp = new Date(
          targetDate.getFullYear(),
          targetDate.getMonth(),
          targetDate.getDate(),
          endHour,
          endMinute,
        ).getTime();

        let status: SeckillStatus;

        if (currentTime < startTimestamp) {
          status = SeckillStatus.WAITING;
        } else if (currentTime >= startTimestamp && currentTime <= endTimestamp) {
          status = SeckillStatus.ONGOING;
        } else {
          status = SeckillStatus.ENDED;
        }

        allSlots.push({
          slotId: `${config.slotId}_${dateStr}`,
          startTime: config.startTime,
          endTime: config.endTime,
          startTimestamp,
          endTimestamp,
          status,
        });
      });
    }

    // 找到当前正在进行的场次
    const ongoingSlot = allSlots.find(slot => slot.status === SeckillStatus.ONGOING);

    if (ongoingSlot) {
      result.push(ongoingSlot);
      const ongoingIndex = allSlots.indexOf(ongoingSlot);
      const nextSlots = allSlots
        .slice(ongoingIndex + 1)
        .filter(slot => slot.status !== SeckillStatus.ENDED)
        .slice(0, 3);
      result.push(...nextSlots);
    } else {
      const upcomingSlots = allSlots
        .filter(slot => slot.status !== SeckillStatus.ENDED)
        .slice(0, 4);
      result.push(...upcomingSlots);
    }

    return result;
  }

  /**
   * 获取当前进行中的时段ID
   */
  public static getCurrentSlotId(): string | undefined {
    const slots = MockSeckillData.generateTodayTimeSlots();
    const ongoingSlot = slots.find(slot => slot.status === SeckillStatus.ONGOING);
    return ongoingSlot?.slotId;
  }

  // ==================== 秒杀商品映射 ====================

  /**
   * 秒杀商品配置
   * Key: 基础slotId (如 slot_08)
   * Value: 参与该时段秒杀的商品ID列表
   * 修改说明：Key不再包含日期，表示该时段每天的默认配置
   */
  private static readonly SECKILL_PRODUCT_MAP: Record<string, string[]> = {
    'slot_08': [
      'product_30001', 'product_30002', 'product_30003',
      'product_30004', 'product_30005',
    ],
    'slot_16': [
      'product_30001', 'product_30002', 'product_30003',
      'product_30004', 'product_30005',
    ],
  };
  /**
   * 秒杀价格配置
   */
  private static readonly SECKILL_PRICE_MAP: Record<string, number> = {
    'product_30001': 128,
    'product_30002': 10.8,
    'product_30003': 8.8,
    'product_30004': 8.8,
    'product_30005': 10.8,
  };

  /**
   * 获取所有场次(只返回未结束的)
   */
  public static getAllSessions(): SeckillSession[] {
    const slots = MockSeckillData.generateTodayTimeSlots();
    return slots.map(slot => ({
      timeSlot: slot,
      productList: MockSeckillData.getProductsBySlotId(slot.slotId),
    } as SeckillSession));
  }

  /**
   * 根据时段ID获取秒杀商品列表
   * @param slotId 完整ID (如 slot_08_20260122)
   */
  public static getProductsBySlotId(slotId: string): SeckillProductInfo[] {
    // 1. 提取基础ID (从 slot_08_20260122 提取 slot_08)
    const lastSeparatorIndex = slotId.lastIndexOf('_');
    const baseSlotId = lastSeparatorIndex !== -1 ? slotId.substring(0, lastSeparatorIndex) : slotId;

    // 2. 使用基础ID查找配置
    const productIds = MockSeckillData.SECKILL_PRODUCT_MAP[baseSlotId] || [];

    // 3. 获取时段详情 (用于验证时段是否存在)
    const slots = MockSeckillData.generateTodayTimeSlots();
    const slot = slots.find(s => s.slotId === slotId);

    if (!slot) {
      // 如果生成的列表中没有这个slotId，说明可能过期了或者非法
      // 但为了Mock数据的健壮性，这里不强制返回空，仅依赖baseId返回数据
    }

    return productIds.map(productId => {
      const seckillPrice = MockSeckillData.SECKILL_PRICE_MAP[productId] || 0;
      const totalStock = 1000;
      let remainStock = Math.floor(Math.random() * 1001);
      remainStock = remainStock < 50 ? 0 : remainStock;

      return {
        productId,
        seckillId: `${slotId}_${productId}`, // 使用完整日期slotId作为唯一键
        slotId,
        title: '',
        banner: '',
        price: 0,
        seckillPrice,
        categoryId: productId.substring(0, productId.indexOf('_')),
        totalStock,
        remainStock,
      } as SeckillProductInfo;
    });
  }

  /**
   * 根据商品ID获取时段ID
   * 返回最近的一个包含该商品的有效时段ID
   */
  public static getSlotIdByProductId(productId: string): string | undefined {
    // 1. 找到该商品属于哪个基础时段 (如 slot_08)
    let matchedBaseSlotId: string | null = null;
    for (const product of Object.entries(MockSeckillData.SECKILL_PRODUCT_MAP)) {
      if (product[1].includes(productId)) {
        matchedBaseSlotId = product[0];
        break;
      }
    }

    if (!matchedBaseSlotId) {
      return undefined;
    }

    // 2. 在生成的有效时段中，找到匹配该基础时段的第一个完整ID
    const slots = MockSeckillData.generateTodayTimeSlots();
    const targetSlot = slots.find(s => s.slotId.startsWith(matchedBaseSlotId!));

    return targetSlot ? targetSlot.slotId : undefined;
  }

  /**
   * 根据 slotId 获取对应的时段信息
   * @param targetSlotId 完整的时段ID (如: "slot_08_20260122")
   * @returns SeckillTimeSlot | undefined
   */
  public static getSlotBySlotId(targetSlotId: string): SeckillTimeSlot | undefined {
    if (!targetSlotId) {
      return undefined;
    }

    // 1. 解析 ID (格式: baseId_YYYYMMDD)
    const separatorIndex = targetSlotId.lastIndexOf('_');
    if (separatorIndex === -1) {
      return undefined;
    }

    const baseId = targetSlotId.substring(0, separatorIndex); // slot_08
    const dateStr = targetSlotId.substring(separatorIndex + 1); // 20260122

    // 2. 校验并解析日期字符串
    if (dateStr.length !== 8) {
      return undefined;
    }
    const year = parseInt(dateStr.substring(0, 4));
    const month = parseInt(dateStr.substring(4, 6)) - 1; // JS月份 0-11
    const day = parseInt(dateStr.substring(6, 8));

    // 3. 找到对应的基础配置
    const config = MockSeckillData.TIME_SLOT_CONFIG.find(c => c.slotId === baseId);
    if (!config) {
      console.warn(`[MockSeckillData] Config not found for baseId: ${baseId}`);
      return undefined;
    }

    const now = new Date();
    const currentTime = now.getTime();

    // 目标日期对象
    const targetDate = new Date(year, month, day);

    // 4. 计算时间戳
    const start = config.startTime.split(':').map(Number);
    const end = config.endTime.split(':').map(Number);

    const startTimestamp = new Date(
      targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(),
      start[0], start[1],
    ).getTime();

    const endTimestamp = new Date(
      targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(),
      end[0], end[1],
    ).getTime();

    // 5. 计算状态
    let status: SeckillStatus;
    if (currentTime < startTimestamp) {
      status = SeckillStatus.WAITING;
    } else if (currentTime >= startTimestamp && currentTime <= endTimestamp) {
      status = SeckillStatus.ONGOING;
    } else {
      status = SeckillStatus.ENDED;
    }

    return {
      slotId: targetSlotId,
      startTime: config.startTime,
      endTime: config.endTime,
      startTimestamp,
      endTimestamp,
      status,
    };
  }

  /**
   * 检查商品是否在秒杀中
   */
  public static isProductInSeckill(productId: string): boolean {
    return MockSeckillData.getSlotIdByProductId(productId) !== null;
  }

  /**
   * 获取商品的秒杀价格
   */
  public static getSeckillPrice(productId: string): number | null {
    return MockSeckillData.SECKILL_PRICE_MAP[productId] || null;
  }
}
