import { ResumeEntity } from './ResumeEntity';
import { Type } from '@kit.ArkUI';


@ObservedV2
export class AttachmentDatabase {
  @Type(ResumeEntity)
  @Trace attachmentList: Array<ResumeEntity> = [];
}
