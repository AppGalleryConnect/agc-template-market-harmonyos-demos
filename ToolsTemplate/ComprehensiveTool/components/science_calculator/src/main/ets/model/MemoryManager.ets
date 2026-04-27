export class MemoryManager {
  private memory: number = 0;
  private hasMemory: boolean = false; // 标记内存中是否有值

  // 内存清除 (MC - Memory Clear)
  memoryClear(): void {
    this.memory = 0;
    this.hasMemory = false;
  }

  // 内存加 (M+ - Memory Plus)
  memoryPlus(value: number): void {
    this.memory += value;
    this.hasMemory = true;
  }

  // 内存减 (M- - Memory Minus)
  memoryMinus(value: number): void {
    this.memory -= value;
    this.hasMemory = true;
  }

  // 内存读取 (MR - Memory Recall)
  memoryRecall(): number {
    return this.memory;
  }

  // 内存存储 (MS - Memory Store)
  memoryStore(value: number): void {
    this.memory = value;
    this.hasMemory = true;
  }

  // 检查内存中是否有值
  hasValue(): boolean {
    return this.hasMemory;
  }

  // 获取内存值（用于显示）
  getMemoryValue(): number {
    return this.memory;
  }
}