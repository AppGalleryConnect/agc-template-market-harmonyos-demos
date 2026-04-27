@ObservedV2
export class RecordItem {
  @Trace id: string = '';
  @Trace height: number = 0;
  @Trace weight: number = 0;
  @Trace bmiValue: number = 0;
  @Trace evaluation: string = '';
  @Trace timestamp: number = 0;
  @Trace date: string = '';
  @Trace time: string = '';

  constructor(height?: number, weight?: number, bmiValue?: number, evaluation?: string) {
    if (height !== undefined && weight !== undefined && bmiValue !== undefined && evaluation !== undefined) {
      const now = new Date();
      this.id = now.getTime().toString();
      this.height = height;
      this.weight = weight;
      this.bmiValue = bmiValue;
      this.evaluation = evaluation;
      this.timestamp = now.getTime();
      this.date = `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')}`;
      this.time = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    }
  }
}
