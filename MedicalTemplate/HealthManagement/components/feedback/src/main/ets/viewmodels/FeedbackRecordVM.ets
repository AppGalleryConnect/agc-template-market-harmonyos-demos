import { formatTimestamp } from '../utils/DateUtils';
import { FeedbackRecordDTO } from '../models/FeedbackRecordDTO';

@ObservedV2
export class FeedbackRecordVM {

  @Trace
  public id: string = '';

  @Trace
  public description: string = '';

  @Trace
  public images: string[] = [];

  @Trace
  public createAt: number = 0;

  @Computed
  public get displayDate():string {
    return formatTimestamp(this.createAt);
  }

  public assignFromDTO(record: FeedbackRecordDTO): void {
    this.id = record.id ?? '';
    this.description = record.description ?? '';
    this.images = record.images ?? [];
    this.createAt = record.createAt ?? 0;
  }
}
